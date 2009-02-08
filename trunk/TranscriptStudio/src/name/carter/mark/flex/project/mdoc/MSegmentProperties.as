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

package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
		
	public class MSegmentProperties {
		public static const CONFIDENTIAL_PROP_NAME:String = "confidential";
		public static const CONFIDENTIAL_DEFAULT:Boolean = false;
		public static const SPEAKER_PROP_NAME:String = "speaker";
		public static const SPEAKER_DEFAULT:String = "none";
		public static const SPEAKER_SADHGURU:String = "sadhguru";
		
		private var segmentElement:XML;
		
		public function MSegmentProperties(segmentElement:XML) {
			this.segmentElement = segmentElement;
		}
		
		public function set speaker(newValue:String):void {
			XMLUtils.setAttributeValue(segmentElement, SPEAKER_PROP_NAME, newValue, SPEAKER_DEFAULT);
		}
		
		public function get speaker():String {
			return XMLUtils.getAttributeValue(segmentElement, SPEAKER_PROP_NAME, SPEAKER_DEFAULT);
		}
		
		public function set confidential(newValue:Boolean):void {
			XMLUtils.setAttributeValue(segmentElement, CONFIDENTIAL_PROP_NAME, newValue, CONFIDENTIAL_DEFAULT);
		}
		
		public function get confidential():Boolean {
			return XMLUtils.getAttributeValueAsBoolean(segmentElement, CONFIDENTIAL_PROP_NAME, CONFIDENTIAL_DEFAULT);
		}
		
		public static function getCumulativePropertyValueAsBoolean(segmentRange:MSegmentRange, propName:String):Object {
			var result:Object = getCumulativePropertyValue(segmentRange, propName);
			if (result == null) {
				return null;
			}
			else {
				return result == "true";
			}
		}
		
		public static function getCumulativePropertyValue(segmentRange:MSegmentRange, propName:String):String {
			var values:ISet = new HashSet();
			for each (var segment:MSegment in segmentRange.nodesInRange) {
				var propValue:String = segment.props[propName];
				values.add(propValue);
			}
			switch (values.size()) {
			case 0:
				throw new Error("No values");
			case 1:
				return values.toArray()[0];
			default:
				return null;
			}
		}
		
		public function equals(obj:Object):Boolean {
			if (obj == this) {
				return true;
			}
			if (!(obj is MSegmentProperties)) {
				return false;
			}
			var guest:MSegmentProperties = obj as MSegmentProperties;
			if (confidential != guest.confidential) {
				return false;
			}
			if (speaker != guest.speaker) {
				return false;
			}
			return true;
		}		
	}
}