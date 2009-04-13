/*
   Transcript Studio for Isha Foundation: An XML based application that allows users to define 
   and store contextual metadata for contiguous sections within a text document. 

   Copyright 2008 Mark Carter, Swami Kevala

   This file is part of Transcript Studio for Isha Foundation.

   Transcript Studio for Isha Foundation is free software: you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free Software 
   Foundation, either version 3 of the License, or (at your option) any later version.

   Transcript Studio for Isha Foundation is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with 
   Transcript Studio for Isha Foundation. If not, see http://www.gnu.org/licenses/.
*/

package org.ishafoundation.archives.transcript.importer
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.db.XQueryExecutor;
	import org.ishafoundation.archives.transcript.model.SessionProperties;
	
	public class MSWordImporter
	{
		private static var DATE_FORMAT_STRINGS:Array = ["DD-MMMM-YY", "DD-MMM-YY", "DD-MM-YY"];
		
		private var xqueryExecutor:XQueryExecutor;
				
		public function MSWordImporter(xqueryExecutor:XQueryExecutor) {
			this.xqueryExecutor = xqueryExecutor;	
		}
		
		public function importAudioTranscripts(names:Array, successFunc:Function, failureFunc:Function):void {
			var audioTranscripts:Array = [];
			var idFunc:Function = getIdFunc();
			importPathsInternal(names, audioTranscripts, idFunc, function():void {
				successFunc(audioTranscripts);
			}, function (msg:String):void {
				failureFunc(msg);
			});
		}
		
		public static function createEventElement(audioTranscripts:Array):XML {
			// get the event type from the first source
			var firstSource:WordMLTransformer = audioTranscripts[0]
			var eventType:String = firstSource.eventElement.@type;
			var eventElement:XML = <event type={eventType}><metadata/></event>;
			var metadataElement:XML = eventElement.metadata[0];
			for each (var audioTranscript:WordMLTransformer in audioTranscripts) {
				var audioEventElement:XML = audioTranscript.eventElement;
				if (audioEventElement.@type != eventType) {
					throw new Error("All transcripts must have the same event type");
				}
				WordMLTransformer.mergeInGuestProperties(metadataElement, audioEventElement.metadata[0]);
			}
			return eventElement;
		}
		
		public static function createSessionElement(audioTranscripts:Array):XML {
			var sessionElement:XML = <session><metadata/></session>;
			var metadataElement:XML = sessionElement.*[0];
			for each (var at1:WordMLTransformer in audioTranscripts) {
				var audioSessionElement:XML = at1.sessionElement;
				WordMLTransformer.mergeInGuestProperties(metadataElement, audioSessionElement);
				// remove the name attribute
				delete metadataElement.@name;
			}
			var mediaMetadataElement:XML = <mediaMetadata/>;
			sessionElement.appendChild(mediaMetadataElement);
			var deviceElement:XML = <device id="a1"/>
			mediaMetadataElement.appendChild(deviceElement);
			var transcriptElement:XML = <transcript id="t1"/>;
			sessionElement.appendChild(transcriptElement);
			for each (var audioTranscript:WordMLTransformer in audioTranscripts) {
				var mediaElement:XML = audioTranscript.mediaElement;
				deviceElement.appendChild(mediaElement);
				var lastAction:String;
				if (audioTranscript.audioTranscriptElement.hasOwnProperty("@proofreadBy")) {
					lastAction = "proofread";
				}
				else if (audioTranscript.audioTranscriptElement.hasOwnProperty("@proofedBy")) {
					lastAction = "proofed";
				}
				else {
					lastAction = "modified";
				}
				var lastActionAt:Date = XMLUtils.getAttributeAsDate(audioTranscript.audioTranscriptElement, lastAction + "At");
				var lastActionBy:String = XMLUtils.getAttributeValue(audioTranscript.audioTranscriptElement, lastAction + "By");
				for each (var segmentElement:XML in audioTranscript.audioTranscriptElement.segment) {
					if (segmentElement.content.length() > 0) {
						// work on a copy
						segmentElement = segmentElement.copy();
						// remove all extracted content
						XMLUtils.removeAllElements(segmentElement.*.(localName() != "content"));
						// apply actions
		 				XMLUtils.setAttributeValue(segmentElement, "lastAction", lastAction);
		 				XMLUtils.setAttributeAsDate(segmentElement, "lastActionAt", lastActionAt);
		 				XMLUtils.setAttributeValue(segmentElement, "lastActionBy", lastActionBy);
						transcriptElement.appendChild(segmentElement);
					}
				}
				// the session notes can contain information about the imported file(s)
				appendSessionNotesLine("Imported file:", metadataElement);
				appendAttributesToSessionNotes(audioTranscript.audioTranscriptElement, metadataElement);
				appendSessionNotesLine("", metadataElement);
			}
			return sessionElement;
		}
		
		private static function appendAttributesToSessionNotes(audioTranscriptElement:XML, metadataElement:XML):void {
			appendSessionNotesLine("", metadataElement);
			var attrNames:Array = []
			for each (var attr:XML in audioTranscriptElement.@*) {
				// but put "filename" and "name" at front
				var attrName:String = attr.localName();
				if (attrName == "filename" || attrName == "name") {
					attrName = "_" + attrName;
				}
				attrNames.push(attrName);
			}
			attrNames = attrNames.sort();
			
			for each (attrName in attrNames) {
				if (attrName.indexOf("_") == 0) {
					attrName = attrName.substring(1);
				}
				appendSessionNotesLine(attrName + ": " + audioTranscriptElement.attribute(attrName), metadataElement);
			}
		}
		
		private static function appendSessionNotesLine(text:String, metadataElement:XML):void {
			text = "\r" + text;
			XMLUtils.appendChildElementText(metadataElement, SessionProperties.NOTES_ELEMENT_NAME, text, false);
		}
		
		private function importPathsInternal(names:Array, audioTranscripts:Array, idFunc:Function, successFunc:Function, failureFunc:Function):void {
			if (names.length == 0) {
				successFunc();
				return;
			}
			names = Utils.copyArray(names);
			var nextName:String = names.shift();
			var encodedNextName:String = encodeURIComponent(nextName);
			xqueryExecutor.query("import module namespace ts4isha='http://ishafoundation.org/ts4isha/xquery' at 'java:org.ishafoundation.ts4isha.xquery.modules.TranscriptStudioModule';ts4isha:import-file-read($arg0)", [encodedNextName], function(resultXML:XML):void {
				var existNS:Namespace = resultXML.namespace("exist");
				var wordXML:XML = resultXML.existNS::value.*.(nodeKind() == "element")[0];
				var audioTranscript:WordMLTransformer = new WordMLTransformer(nextName, wordXML, idFunc);
				audioTranscripts.push(audioTranscript); 
				importPathsInternal(names, audioTranscripts, idFunc, successFunc, failureFunc);
			}, function(msg:String):void {
				failureFunc(msg);
			});
		}
		
		private static function getIdFunc():Function {
			var prefixToLargestIdMap:IMap = new HashMap();
			return function(prefix:String):String {
				var newId:int;
				if (!prefixToLargestIdMap.containsKey(prefix)) {
					newId = 1;
				}
				else {
					newId = prefixToLargestIdMap.getValue(prefix) + 1;
				}
				prefixToLargestIdMap.put(prefix, newId);
				var result:String = prefix + newId;
				return result;
			};
		}
		
	}
}