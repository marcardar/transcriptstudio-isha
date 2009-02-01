/*
   Transcript Markups Editor: An XML based application that allows users to define 
   and store contextual metadata for contiguous sections within a text document. 

   Copyright 2008 Mark Carter, Swami Kevala

   This file is part of Transcript Markups Editor.

   Transcript Markups Editor is free software: you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free Software 
   Foundation, either version 3 of the License, or (at your option) any later version.

   Transcript Markups Editor is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with 
   Transcript Markups Editor. If not, see http://www.gnu.org/licenses/.
*/

package org.ishafoundation.archives.transcript.importer
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	
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
			var eventElement:XML = <event/>;
			for each (var audioTranscript:WordMLTransformer in audioTranscripts) {
				var audioEventElement:XML = audioTranscript.eventElement;
				WordMLTransformer.mergeInGuestProperties(eventElement, audioEventElement);
			}
			return eventElement;
		}
		
		public static function createSessionElement(audioTranscripts:Array):XML {
			var sessionElement:XML = <session/>;
			for each (var at1:WordMLTransformer in audioTranscripts) {
				var audioSessionElement:XML = at1.sessionElement;
				WordMLTransformer.mergeInGuestProperties(sessionElement, audioSessionElement);
				// remove the name attribute
				delete sessionElement.@name;
			}
			var transcriptElement:XML = <transcript id="t1"/>;
			for each (var audioTranscript:WordMLTransformer in audioTranscripts) {
				var sourceElement:XML = audioTranscript.sourceElement;
				sessionElement.appendChild(sourceElement);
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
				appendSessionCommentLine("\rImported file:", sessionElement);
				appendAttributesToSessionComment(audioTranscript.audioTranscriptElement, sessionElement);
			}
			sessionElement.appendChild(transcriptElement);
			return sessionElement;
		}
		
		private static function appendAttributesToSessionComment(audioTranscriptElement:XML, sessionElement:XML):void {
			appendSessionCommentLine("", sessionElement);
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
				appendSessionCommentLine(attrName + ": " + audioTranscriptElement.attribute(attrName), sessionElement);
			}
		}
		
		private static function appendSessionCommentLine(text:String, sessionElement:XML):void {
			/*text = Utils.normalizeSpace(text);
			if (text.length == 0) {
				return;
			}*/
			var comment:String = XMLUtils.getAttributeValue(sessionElement, SessionProperties.COMMENT_ATTR_NAME, "");
			comment += "\r"
			comment += text;
			XMLUtils.setAttributeValue(sessionElement, SessionProperties.COMMENT_ATTR_NAME, comment);
		}
		
		private function importPathsInternal(names:Array, audioTranscripts:Array, idFunc:Function, successFunc:Function, failureFunc:Function):void {
			if (names.length == 0) {
				successFunc();
				return;
			}
			var nextName:String = names.shift();
			xqueryExecutor.query("import module namespace transcriptstudio='http://ishafoundation.org/xquery/archives/transcript' at 'java:org.ishafoundation.archives.transcript.xquery.modules.TranscriptStudioModule';transcriptstudio:import-file-read($arg0)", [nextName], function(resultXML:XML):void {
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