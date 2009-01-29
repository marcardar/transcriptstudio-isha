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
	
	import org.ishafoundation.archives.transcript.db.XMLRetriever;
	
	public class MSWordImporter
	{
		private static var DATE_FORMAT_STRINGS:Array = ["DD-MMMM-YY", "DD-MMM-YY", "DD-MM-YY"];
		
		private var xmlRetriever:XMLRetriever;
				
		public function MSWordImporter(xmlRetriever:XMLRetriever) {
			this.xmlRetriever = xmlRetriever;	
		}
		
		public function importAudioTranscripts(paths:Array, successFunc:Function, failureFunc:Function):void {
			var audioTranscripts:Array = [];
			var idFunc:Function = getIdFunc();
			importPathsInternal(paths, audioTranscripts, idFunc, function():void {
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
			}
			var transcriptElement:XML = <transcript id="t1"/>;
			for each (var audioTranscript:WordMLTransformer in audioTranscripts) {
				var sourceElement:XML = audioTranscript.sourceElement;
				sessionElement.appendChild(sourceElement);
				for each (var segmentElement:XML in audioTranscript.audioTranscriptElement.segment) {
					if (segmentElement.content.length() > 0) {
						// work on a copy
						segmentElement = segmentElement.copy();
						// remove all extracted content
						XMLUtils.removeAllElements(segmentElement.*.(localName() != "content"));
						// apply actions
			 			for each (var attr:XML in audioTranscript.audioTranscriptElement.attributes()) {
			 				var attrName:String = attr.localName();
			 				var attrValue:String = attr.toString();
			 				XMLUtils.setAttributeValue(segmentElement, attrName, attrValue);
			 			}
						transcriptElement.appendChild(segmentElement);
					}
				}				
			}
			sessionElement.appendChild(transcriptElement);
			return sessionElement;
		}
		
		private function importPathsInternal(paths:Array, audioTranscripts:Array, idFunc:Function, successFunc:Function, failureFunc:Function):void {
			if (paths.length == 0) {
				successFunc();
				return;
			}
			var nextPath:String = paths.shift();
			xmlRetriever.retrieveXML(nextPath, function(wordXML:XML):void {
				var audioTranscript:WordMLTransformer = new WordMLTransformer(nextPath, wordXML, idFunc);
				audioTranscripts.push(audioTranscript); 
				importPathsInternal(paths, audioTranscripts, idFunc, successFunc, failureFunc);
			}, function(msg:String):void {
				failureFunc(msg);
			}, false);
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