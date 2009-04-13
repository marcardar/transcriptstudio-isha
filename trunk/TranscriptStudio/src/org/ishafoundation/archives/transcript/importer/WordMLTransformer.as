package org.ishafoundation.archives.transcript.importer
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MContentProperties;
	import name.carter.mark.flex.project.mdoc.MSegmentProperties;
	import name.carter.mark.flex.util.DateUtils;
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
	
	import org.ishafoundation.archives.transcript.model.EventProperties;
	import org.ishafoundation.archives.transcript.model.SessionProperties;
	import org.ishafoundation.archives.transcript.util.ApplicationUtils;
	
	public class WordMLTransformer
	{
		private static const CONSECUTIVE_WHITESPACE_PATTERN:RegExp = /\s{2,}/g;
		private static const DOUBLE_QUOTE_PATTERN:RegExp = /[\u201c\u201d]/g;
		private static const SINGLE_QUOTE_PATTERN:RegExp = /[\u2018\u2019]/g;
		private static const DOT_DOT_DOT_PATTERN:RegExp = /[\u2026]/g;
		private static const HYPHEN_PATTERN:RegExp = /[\u2012\u2013\u2014\u2015]/g;
		private static const NON_BREAKING_SPACE_PATTERN:RegExp = /[\u00A0]/g;
		private static const TIME_PATTERN:RegExp = /^Time:?\s*(\d+):(\d{2})\W*/i;
		private static const TRACK_TIME_PATTERN:RegExp = /^track[^a-z]+/i;
		private static const SPEAKER_PATTERN:RegExp = /^(?:sadhguru\s*:|(.{1,30})\s*(?:\s*:))/i;
		
		private static const IMPORT_FILENAME_PATTERN:RegExp = /^([a-zA-Z0-9\-]+).*$/
		private static const SOURCE_ID_PATTERN:RegExp = /^([a-z]+).+$/;
		
		private static const ACTION_PATTERN:RegExp = /^(.+)\s*\((.+)\)/;
		
		public static const TRANSCRIBED_BY_ATTR_NAME:String = "transcribedBy";
		public static const TRANSCRIBED_AT_ATTR_NAME:String = "transcribedAt";
		public static const PROOFED_BY_ATTR_NAME:String = "proofedBy";
		public static const PROOFED_AT_ATTR_NAME:String = "proofedAt";
		public static const PROOFREAD_BY_ATTR_NAME:String = "proofreadBy";
		public static const PROOFREAD_AT_ATTR_NAME:String = "proofreadAt";
		
		private static const AUDIO_QUALITY_ATTR_NAME:String = "audioQuality";

		private static const EMPHASIZED:String = "emphasized";
		private static const TAMIL:String = "tamil";

		private static const WORD_TAG_MAP:IMap = createWordTagToTagElementMap();
		private static function createWordTagToTagElementMap():IMap {
			var result:IMap = new HashMap();
			result.put("b", EMPHASIZED);
			result.put("i", EMPHASIZED);
			result.put("color", TAMIL);
			return result;
		}
		
		public var audioTranscriptElement:XML; // parent for segment elements. Also holds transcribedBy,proofedBy etc 
		public var mediaElement:XML; // properties and syncPoints
		public var sessionElement:XML; // only properties
		public var eventElement:XML; // only properties
		
		public function WordMLTransformer(importName:String, wordMLDoc:XML, idFunc:Function)
		{
			var sourceId:String = extractSourceIdFromName(importName);
			var eventType:String = extractEventTypeFromSourceId(sourceId);
			
			this.audioTranscriptElement = <audioTranscript filename={importName}/>;
			var importedBy:String = Utils.getClassName(this) + "-v" + ApplicationUtils.getApplicationVersion();
			var audioIdInt:String = sourceId.replace(/\D/, '');
			var prefix:String = sourceId.replace(/\d+.*/, '');
			var mediaId:String = prefix + "-" + audioIdInt; 
			this.mediaElement = <audio id={mediaId}/>;
			this.sessionElement = <session/>;
			this.eventElement = <event {EventProperties.TYPE_ATTR_NAME}={eventType}><metadata/></event>;

			transformXML(wordMLDoc, idFunc);

			extractHeaders();
		}
		
		public function get sourceId():String {
			return XMLUtils.getAttributeValue(mediaElement, "id");
		}
		
		public function get name():String {
			return XMLUtils.getAttributeValue(audioTranscriptElement, "name");
		}
		
		public function get text():String {
			var result:String = "";
			for each (var segmentElement:XML in audioTranscriptElement.segment) {
				var segmentText:String = getSegmentText(segmentElement, true);
				if (segmentText.length == 0) {
					continue;
				}
				if (result.length > 0) {
					result += "\n\n";
				}
				result += segmentText;
			}
			return result;
		}
		
		private static function extractEventTypeFromSourceId(sourceId:String):String {
			var arr:Array = SOURCE_ID_PATTERN.exec(sourceId);
			if (arr == null) {
				return null;
			}
			return arr[1];
		}
		
		private static function extractSourceIdFromName(importName:String):String {
			var arr:Array = IMPORT_FILENAME_PATTERN.exec(importName);
			if (arr == null) {
				throw new Error("Passed an invalid importName: " + importName);
			}
			return arr[1].toString().toLowerCase();
		}

		/**
		 * idFunc(prefix:String):String
		 */
		private function transformXML(wordMLDoc:XML, idFunc:Function):void {
			var wordNS:Namespace = wordMLDoc.namespace("w");
			
			var startTime:int = -1;
			var speaker:String = null;

			for each ( var para:XML in wordMLDoc..wordNS::p ) {
				var segmentElement:XML = <segment type="paragraph"/>;
				
				var contentText:String = "";
				var activeStyles:ISet = new HashSet();

				for each ( var text:XML in para..wordNS::t ) {					
					var row:XML = text.parent();
					
					var rawText:String = row.wordNS::t[0];
					
					if (rawText == "") {
						continue;
					}

					if (StringUtil.trim(rawText) == "") {
						contentText += " ";
						continue;
					}
					
					var thisContentStyles:ISet = new HashSet();
					for each (var tag:String in WORD_TAG_MAP.getKeys()) {
						var search:XMLList = row..wordNS::rPr.*.(localName() == tag);
						if (search.length() > 0) {
							var style:String = WORD_TAG_MAP.getValue(tag);
							thisContentStyles.add(style);
						}
					}
					
					if (activeStyles.equals(thisContentStyles)) {
						// the style situation is the same as for the previous text
						contentText += rawText;
					}
					else {
						// change in styling
						appendContentText(contentText, activeStyles, segmentElement);
						contentText = rawText;
						activeStyles = thisContentStyles;
					}
				}
				
				if (contentText.length == 0) {
					continue;
				}
				
				// append the rest of the text
				appendContentText(contentText, activeStyles, segmentElement);

				var thisStartTime:int = extractStartTime(segmentElement);
				if (thisStartTime >= 0) {
					startTime = thisStartTime;
				}
				
				if (segmentElement.content.length() == 0) {
					continue;
				}

				var thisSpeaker:String = extractSpeaker(segmentElement);
				if (thisSpeaker != null) {
					speaker = thisSpeaker;
				}
				
				if (segmentElement..content.length() == 0) {
					continue;
				}
				
				removeTrackTime(segmentElement);

				segmentElement.@id = idFunc("p");
				for each (var contentElement:XML in segmentElement..content) {
					contentElement.@id = idFunc("c");
				}
				new MSegmentProperties(segmentElement).speaker = speaker;
				if (startTime >= 0) {
					var syncPointId:String = idFunc("t");
					var syncElement:XML = <sync timecode={startTime} timeIdRef={syncPointId}/>;
					mediaElement.appendChild(syncElement);
					var firstContentElement:XML = segmentElement.content[0];
					XMLUtils.setAttributeValue(firstContentElement, MContentProperties.START_ID_PROP_NAME, syncPointId);
					startTime = -1; // don't use this start time for any other segment					
				}
				audioTranscriptElement.appendChild(segmentElement);
			}
		}
		
		private static function appendContentText(contentText:String, styles:ISet, segmentElement:XML):void {
			// change in tagging so lets close off the current tags and then start a new superContent for the new tags
			contentText = replaceSpecialChars(contentText);
			contentText = Utils.normalizeSpace(contentText);
			//contentText = removeTamil(contentText);
			if (contentText.length == 0) {
				return;
			}
			var contentElement:XML = <content/>;
			contentElement.appendChild(contentText);
			if (styles.isEmpty()) {
				// no need for general properties
				segmentElement.appendChild(contentElement);
			}
			else {
				var contentProps:MContentProperties = new MContentProperties(contentElement);
				if (styles.contains(EMPHASIZED)) {
					contentProps.emphasis = true;
				}
				if (styles.contains(TAMIL)) {
					contentProps.spokenLanguage = TAMIL; 
				}
				segmentElement.appendChild(contentElement);
			}
		}
		
		private static function replaceSpecialChars(segmentText:String):String {
			segmentText = segmentText.replace(DOUBLE_QUOTE_PATTERN, "\"");
			segmentText = segmentText.replace(SINGLE_QUOTE_PATTERN, "\'");
			segmentText = segmentText.replace(DOT_DOT_DOT_PATTERN, "...");
			segmentText = segmentText.replace(HYPHEN_PATTERN, "\-");
			segmentText = segmentText.replace(NON_BREAKING_SPACE_PATTERN, " ");
			return segmentText;
		}
 
		private static function extractSpeaker(segmentElement:XML):String {
			var children:XMLList = segmentElement.content;
			if (!new MContentProperties(children[0]).emphasis) {
				// looks like the text is not in bold
				return null;
			}
			var segmentText:String = getSegmentText(segmentElement, false, "");
			var arr:Array = SPEAKER_PATTERN.exec(segmentText);
			if (arr == null) {
				return null;
			}
			// remove the corresponding text
			var numCharsToRemove:int = (arr[0] as String).length;
			removeLeadingChars(numCharsToRemove, segmentElement);
			if (arr[1] == null) {
				// matched on sadhguru
				return "sadhguru";
			}
			else {
				// we didnt match on sadhguru without the leading asterisk
				var speakerStr:String = StringUtil.trim(arr[1] as String).toLowerCase();
				return speakerStr;
			}
		}
		 
		private static function extractStartTime(segmentElement:XML):int {
			var segmentText:String = getSegmentText(segmentElement, false, "");
			var arr:Array = TIME_PATTERN.exec(segmentText);
			if (arr == null) {
				return -1;
			}
			var minInt:int = new int(arr[1]);
			var secInt:int = new int(arr[2]);
			var result:int = 60 * minInt + secInt;
			// remove the corresponding text
			var numCharsToRemove:int = (arr[0] as String).length;
			removeLeadingChars(numCharsToRemove, segmentElement);
			return result;
 		}
 		
 		private static function removeLeadingChars(numChars:int, segmentElement:XML):Boolean {
 			var contentElements:XMLList = segmentElement..content;
 			if (contentElements.length() == 0) {
 				return false;
 			}
 			if (numChars <= 0) {
 				// nothing to remove
 				return true;
 			}
 			var contentElement:XML = contentElements[0];
			var contentText:String = contentElement.text();
			if (contentText.length <= numChars) {
				// we need to remove the contentElement
				removeContentElement(contentElement);
				numChars -= contentText.length;
				return removeLeadingChars(numChars, segmentElement);
			}
			else {
				/* The trim() in this next line was the conclusion to one day's (27.03.2009) debugging work
				  to find out why there was leading whitespace in content text nodes(). I still do not know
				  why this error was not showing up before */
				contentText = StringUtil.trim(contentText.substring(numChars));
				XMLUtils.setElementText(contentElement, contentText);
				return true;
			}
 		}
 		
 		private static function removeContentElement(contentElement:XML):void {
 			contentElement.setLocalName("extractedContent");
 		}
 		
 		private static function getSegmentText(segmentElement:XML, includeRemovedContent:Boolean, contentDivider:String = " "):String {
 			var result:String = "";
 			var contentElements:XMLList = includeRemovedContent ? segmentElement.* : segmentElement.content;
 			for each (var contentElement:XML in contentElements) {
 				var contentText:String = contentElement.text();
 				if (result.length > 0) {
 					result += contentDivider;
 				}
 				result += contentText;
 			}
 			return result;
 		}
 		 		
		private function extractHeaders():void {
			var eventMetadataElement:XML = eventElement.metadata[0];
 			for each (var contentElement:XML in getHeaderContents()) {
 				// actions
 				extractAttributeFromHeader(contentElement, audioTranscriptElement, ["TRANSCRIBED BY"], false, TRANSCRIBED_BY_ATTR_NAME, true);
 				extractAttributeFromHeader(contentElement, audioTranscriptElement, ["PROOFED BY"], false, PROOFED_BY_ATTR_NAME, true);
 				extractAttributeFromHeader(contentElement, audioTranscriptElement, ["PROOFREAD BY", "PROOF READ BY"], false, PROOFREAD_BY_ATTR_NAME, true);
 				extractAttributeFromHeader(contentElement, audioTranscriptElement, ["EVENT"], false, "name", false);

 				// now for the audio stuff
 				//extractAttributeFromHeader(contentElement, mediaElement, ["MEDIA CODE #", "MEDIA CODE"], true, "id", true);
 				// now this is hardcoded as "mixer": extractAttributeFromHeader(contentElement, sourceElement, ["MEDIA SOURCE"], false, "type", true);
 				extractAttributeFromHeader(contentElement, mediaElement, ["AUDIO CLARITY (E G F P)"], false, AUDIO_QUALITY_ATTR_NAME, true); 				

 				// session - allow multiple dates to pile up because dates are in a special format
 				extractAttributeFromHeader(contentElement, sessionElement, ["DATE"], true, SessionProperties.START_AT_ATTR_NAME, false); 
 				extractAttributeFromHeader(contentElement, sessionElement, ["NOTES", "NOTE"], false, SessionProperties.NOTES_ELEMENT_NAME, false);
 				// hack time - actually we want notes as an element
 				var notes:String = XMLUtils.getAttributeValue(sessionElement, SessionProperties.NOTES_ELEMENT_NAME, null);
 				if (notes != null) {
 					notes = "\r" + notes;
	 				XMLUtils.appendChildElementText(sessionElement, SessionProperties.NOTES_ELEMENT_NAME, notes, false);
	 				delete sessionElement.@notes[0];
	 			} 
				
				// event
 				var newValue:String = extractAttributeFromHeader(contentElement, eventMetadataElement, ["LOCATION"], false, EventProperties.VENUE_ATTR_NAME, false);
 				if (newValue != null) {
 					// make sure only certain characters are used
 					newValue = newValue.replace(/[^a-zA-Z0-9\ ]+/g, " ");
 					newValue = Utils.normalizeSpace(newValue);
 					XMLUtils.setAttributeValue(eventMetadataElement, EventProperties.VENUE_ATTR_NAME, newValue, "");
 				}
 				extractAttributeFromHeader(contentElement, eventMetadataElement, ["LANGUAGE"], false, EventProperties.LANGUAGE_ATTR_NAME, true, EventProperties.LANGUAGE_DEFAULT);
 			}
 			// handle actionBy's properly (i.e. extract bracketed dates
			processActionBy(TRANSCRIBED_AT_ATTR_NAME, TRANSCRIBED_BY_ATTR_NAME);
			processActionBy(PROOFED_AT_ATTR_NAME, PROOFED_BY_ATTR_NAME);
			processActionBy(PROOFREAD_AT_ATTR_NAME, PROOFREAD_BY_ATTR_NAME);
 			
 			// handle media element properly
 			var quality:String = XMLUtils.getAttributeValue(mediaElement, AUDIO_QUALITY_ATTR_NAME);
 			if (quality != null) {
 				var ac:String;
 				if (quality == "e") {
 					quality = "excellent";
 				}
 				else if (quality == "g") {
 					quality = "good";
 				}
 				else if (quality == "f") {
 					quality = "fair";
 				}
 				else if (quality == "p") {
 					quality = "poor";
 				}
 				XMLUtils.setAttributeValue(mediaElement, AUDIO_QUALITY_ATTR_NAME, quality, "");
 			}
		}
		
		private function processActionBy(attrAtName:String, attrByName:String):void {
 			var by:String = XMLUtils.getAttributeValue(audioTranscriptElement, attrByName);
 			var regExpArr:Array = ACTION_PATTERN.exec(by);
 			if (regExpArr != null) {
 				// looks like the action pattern is in the standard format
 				by = regExpArr[1];
 				var at:String = formatNonStandardDateString(regExpArr[2]);
 				if (at != null) {
 					XMLUtils.setAttributeValue(audioTranscriptElement, attrAtName, at);
 					XMLUtils.setAttributeValue(audioTranscriptElement, attrByName, by);
 				}
 			}
			
		}
		
 		/**
 		 * Target can be either XML or XMLList
 		 */
 		private static function extractAttributeFromHeader(contentElement:XML, targetElement:XML, headerPrefixes:Array, ignoreDuplicates:Boolean, attrName:String, toLowerCase:Boolean, defaultValue:String = null):String {
 			if (contentElement.localName() != MContent.TAG_NAME) {
 				// looks like something was already extracted from this one
 				return null;
 			}
 			var contentText:String = contentElement.text();
 			var value:String;
 			for each (var headerPrefix:String in headerPrefixes) {
				value = substringAfter(contentText, headerPrefix);
 				if (value != null) {
 					break;
 				}
 			}
			if (value == null) {
				return null;
			}
			if (toLowerCase) {
				value = value.toLowerCase();
			}
			var colonIndex:int = value.indexOf(":");
			if (colonIndex == 0) {
				value = StringUtil.trim(value.substring(colonIndex + 1));
			}
			// HACK!
			if (attrName == SessionProperties.START_AT_ATTR_NAME) {
				value = formatNonStandardDateString(value);
			}
 			var existingValue:String = XMLUtils.getAttributeValue(targetElement, attrName, defaultValue);
 			if (existingValue == null) {
 				XMLUtils.setAttributeValue(targetElement, attrName, value, defaultValue);
 			} 
 			else {
 				// something already there
 				if (existingValue != value) {
 					if (!ignoreDuplicates) {
	 					XMLUtils.setAttributeValue(targetElement, attrName, existingValue + "; " + value, defaultValue);
	 				}
	 				else {
	 					// there is another definition for this name, and its different
	 					// so don't delete it but don't add it to the attribute either
	 					return null;
	 				}
 				}
 			}
			removeContentElement(contentElement);
			return value;
 		}
 		
 		private static function substringAfter(text:String, dividingChar:String):String {
 			var index:int = text.indexOf(dividingChar);
 			if (index < 0) {
 				return null;
 			}
 			else {
 				return StringUtil.trim(text.substring(index + dividingChar.length));
 			}
 		}
 		
 		private static function formatNonStandardDateString(dateString:String):String {
 			var date:Date = DateUtils.parseNonStandardDateString(dateString);
 			if (date == null) {
 				return null;
 			}
 			var df:DateFormatter = new DateFormatter();
 			df.formatString = "YYYY-MM-DD";
 			var result:String = df.format(date);
 			return result;
 		}
 		
 		private function getHeaderContents():XMLList {
 			var segmentElements:XMLList = audioTranscriptElement.segment;
 			var result:XMLList = new XMLList();
 			for (var i:int = 0; i < Math.min(segmentElements.length(), 30); i++) {
 				var segmentElement:XML = segmentElements[i];
 				if (getSegmentText(segmentElement, true) == "INDEX") {
 					break;
 				}
 				for each (var contentElement:XML in segmentElement.content) {
 					result += contentElement;
 				}
 			}
 			return result;
 		}

		/**
		 * For some sources, timings are given as track: 123 00:12 - which is of no use to us so just remove
		 */
		private function removeTrackTime(segmentElement:XML):void {
			var arr:Array = TRACK_TIME_PATTERN.exec(getSegmentText(segmentElement, false));
			if (arr != null) {
				removeLeadingChars((arr[0] as String).length, segmentElement);
			}
		}
		
 		public static function mergeInGuestProperties(targetElement:XML, guestElement:XML):void {
 			for each (var attr:XML in guestElement.attributes()) {
 				var attrName:String = attr.localName();
 				var attrValue:String = attr.toString();
 				var existingValue:String = XMLUtils.getAttributeValue(targetElement, attrName);
 				var newValue:String;
 				if (existingValue == null) {
 					newValue = attrValue;
 				}
 				else if (existingValue == attrValue) {
 					newValue = existingValue;
 				}
 				else {
 					// HACK TIME
 					if (attrName == EventProperties.START_AT_ATTR_NAME || attrName == EventProperties.TYPE_ATTR_NAME) {
 						// we have conflicting data
 						var notes:String = XMLUtils.getChildElementText(targetElement, EventProperties.NOTES_ELEMENT_NAME, "");
 						notes += "\nInconsistent " + attrName + ": " + attrValue.toString(); 
 						XMLUtils.setChildElementText(targetElement, EventProperties.NOTES_ELEMENT_NAME, notes);
 						continue;
 					}
 					else {
	 					newValue = existingValue + "; " + attrValue;
	 				}
 				}
 				XMLUtils.setAttributeValue(targetElement, attrName, newValue, "");
 			}
 		}
	}
}