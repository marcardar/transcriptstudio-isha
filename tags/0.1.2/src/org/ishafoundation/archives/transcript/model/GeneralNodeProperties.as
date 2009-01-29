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

package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MContentProperties;
	import name.carter.mark.flex.project.mdoc.MContentRange;
	import name.carter.mark.flex.project.mdoc.MContentRangeSubset;
	import name.carter.mark.flex.project.mdoc.MNodeRange;
	import name.carter.mark.flex.project.mdoc.MSuperSegment;
	import name.carter.mark.flex.project.mdoc.MSegment;
	import name.carter.mark.flex.project.mdoc.MSegmentProperties;
	import name.carter.mark.flex.project.mdoc.MSegmentRange;
	import name.carter.mark.flex.project.mdoc.MSegmentSubset;
		
	[Bindable]
	public class GeneralNodeProperties {
		private var _confidential:Object = MSegmentProperties.CONFIDENTIAL_DEFAULT;
		public var confidentialEnabled:Boolean;
		private var _speaker:String = MSegmentProperties.SPEAKER_DEFAULT;
		public var speakerEnabled:Boolean;
		private var _spokenLanguage:String = MContentProperties.SPOKEN_LANGUAGE_DEFAULT;
		private var _emphasis:Object = MContentProperties.EMPHASIS_DEFAULT;
		public var emphasisEnabled:Boolean;
				
		private var ttSelection:TranscriptTextSelection;
		
		public function GeneralNodeProperties(ttSelection:TranscriptTextSelection) {
			if (ttSelection == null || ttSelection.selectedObj is MSuperSegment) {
				throw new Error("Passed an inappropraite ttSelection");
			}
			this.ttSelection = ttSelection;
		}
		
		public static function createInstance(ttSelection:TranscriptTextSelection):GeneralNodeProperties {
			if (ttSelection == null || ttSelection.selectedObj is MSuperSegment) {
				return null;
			}
			
			trace("Creating new general node properties instance for selection: " + ttSelection);
			
			var nodeRange:MNodeRange = ttSelection.toSegmentRange();
			if (nodeRange == null) {
				nodeRange = ttSelection.toSegmentSubset().spanningContentRange;
			}
			var result:GeneralNodeProperties = new GeneralNodeProperties(ttSelection);
			result.confidentialEnabled = ttSelection.selectedObj is MSegment;
			if (result.confidentialEnabled) {
				result._confidential = MSegmentProperties.getCumulativePropertyValueAsBoolean(nodeRange as MSegmentRange, MSegmentProperties.CONFIDENTIAL_PROP_NAME);
			}
			result.speakerEnabled = !(ttSelection.selectedObj is MSegmentSubset);
			if (result.speakerEnabled) {
				result._speaker = MSegmentProperties.getCumulativePropertyValue(nodeRange as MSegmentRange, MSegmentProperties.SPEAKER_PROP_NAME);
			}
			result._spokenLanguage = MContentProperties.getCumulativePropertyValue(nodeRange, MContentProperties.SPOKEN_LANGUAGE_PROP_NAME);
			result.emphasisEnabled = !(ttSelection.selectedObj is MSegmentRange);
			if (result.emphasisEnabled) {
				result._emphasis = MContentProperties.getCumulativePropertyValueAsBoolean(nodeRange, MContentProperties.EMPHASIS_PROP_NAME);
			}
			return result;
		}
		
		public function get confidential():Object {
			return _confidential;
		}
		
		public function set confidential(newValue:Object):void {
			_confidential = newValue;
			setPropertyValue(newValue, MSegmentProperties.CONFIDENTIAL_PROP_NAME, MSegmentProperties.CONFIDENTIAL_DEFAULT, true);
		}		
		
		public function get speaker():String {
			return _speaker;
		}
		
		public function set speaker(newValue:String):void {
			_speaker = newValue;
			setPropertyValue(newValue, MSegmentProperties.SPEAKER_PROP_NAME, MSegmentProperties.SPEAKER_DEFAULT, true);
		}
		
		public function get spokenLanguage():String {
			return _spokenLanguage;
		}
		
		public function set spokenLanguage(newValue:String):void {
			_spokenLanguage = newValue;
			setPropertyValue(newValue, MContentProperties.SPOKEN_LANGUAGE_PROP_NAME, MContentProperties.SPOKEN_LANGUAGE_DEFAULT, false);
		}
		
		public function get emphasis():Object {
			return _emphasis;
		}
		
		public function set emphasis(newValue:Object):void {
			_emphasis = newValue;
			setPropertyValue(newValue, MContentProperties.EMPHASIS_PROP_NAME, MContentProperties.EMPHASIS_DEFAULT, false);
		}
		
		private function setPropertyValue(newValue:Object, propName:String, defaultValue:Object, isSegmentProp:Boolean):void {
			var newValueStr:String;
			if (newValue == null || newValue == defaultValue) {
				newValueStr = null;
			}
			else {
				newValueStr = newValue.toString();
			}			
			if (isSegmentProp) {
				setSegmentProperty(propName, newValueStr);
			}
			else {
				setContentProperty(propName, newValueStr);
			}
		}
		
		private function setContentProperty(name:String, value:String):void {
			if (ttSelection.selectedObj is MSegmentSubset) {
				var segmentSubset:MSegmentSubset = ttSelection.selectedObj as MSegmentSubset;
				var contentRangeSubset:MContentRangeSubset = segmentSubset.toContentRangeSubset();
				contentRangeSubset.breakContentRange();
				contentRangeSubset.spanningContentRange.setProperty(name, value);
				contentRangeSubset.mergeContentsWhereNecessary();
			}
			else {
				var segmentRange:MSegmentRange = ttSelection.toSegmentRange();
				var firstContent:MContent = segmentRange.first.toContentRange().first;
				var lastContent:MContent = segmentRange.last.toContentRange().last;
				var contentRange:MContentRange = new MContentRange(firstContent, lastContent);
				contentRange.setProperty(name, value);
				new MContentRangeSubset(contentRange).mergeContentsWhereNecessary();
			}
		}
		
		private function setSegmentProperty(name:String, value:String):void {
			if (ttSelection.selectedObj is MSegmentSubset) {
				throw new Error("Tried to set a segment property for a SegmentSubset selection");
			}
			var segmentRange:MSegmentRange = ttSelection.toSegmentRange();
			segmentRange.setProperty(name, value);
		}
		
	}
}