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

package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
		
	public class MContentProperties {
		public static const SPOKEN_LANGUAGE_PROP_NAME:String = "spokenLanguage";
		public static const SPOKEN_LANGUAGE_DEFAULT:String = "english";
		public static const EMPHASIS_PROP_NAME:String = "emphasis";
		public static const EMPHASIS_DEFAULT:Boolean = false;
		
		public static const START_SYNC_POINT_ID_PROP_NAME:String = "startSyncPointId";
		public static const END_SYNC_POINT_ID_PROP_NAME:String = "endSyncPointId";

		private var contentElement:XML;
		
		public function MContentProperties(contentElement:XML) {
			this.contentElement = contentElement;
		}

		public function set spokenLanguage(newValue:String):void {
			XMLUtils.setAttributeValue(contentElement, SPOKEN_LANGUAGE_PROP_NAME, newValue, SPOKEN_LANGUAGE_DEFAULT);
		}
		
		public function get spokenLanguage():String {
			return XMLUtils.getAttributeValue(contentElement, SPOKEN_LANGUAGE_PROP_NAME, SPOKEN_LANGUAGE_DEFAULT);
		}
		
		public function set emphasis(newValue:Boolean):void {
			XMLUtils.setAttributeValue(contentElement, EMPHASIS_PROP_NAME, newValue, EMPHASIS_DEFAULT);
		}
		
		public function get emphasis():Boolean {
			return XMLUtils.getAttributeValueAsBoolean(contentElement, EMPHASIS_PROP_NAME, EMPHASIS_DEFAULT);
		}
		
		public function set startSyncPointId(newValue:String):void {
			XMLUtils.setAttributeValue(contentElement, START_SYNC_POINT_ID_PROP_NAME, newValue);			
		}
		
		public function get startSyncPointId():String {
			return XMLUtils.getAttributeValue(contentElement, START_SYNC_POINT_ID_PROP_NAME);			
		}
		
		public function set endSyncPointId(newValue:String):void {
			XMLUtils.setAttributeValue(contentElement, END_SYNC_POINT_ID_PROP_NAME, newValue);			
		}
		
		public function get endSyncPointId():String {
			return XMLUtils.getAttributeValue(contentElement, END_SYNC_POINT_ID_PROP_NAME);			
		}
		
		public static function getCumulativePropertyValueAsBoolean(nodeRange:MNodeRange, propName:String):Object {
			var result:Object = getCumulativePropertyValue(nodeRange, propName);
			if (result == null) {
				return null;
			}
			else {
				return result == "true";
			}
		}
		
		public static function getCumulativePropertyValue(nodeRange:MNodeRange, propName:String):String {
			var values:ISet = new HashSet();
			for each (var node:MNode in nodeRange.nodesInRange) {
				for each (var content:MContent in MUtils.getDescendantsOrSelfByClass(node, MContent)) {
					var propValue:String = content.props[propName];
					values.add(propValue);
				}
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
		
		public function equalsIgnoreSyncPoints(obj:Object):Boolean {
			if (obj == this) {
				return true;
			}
			if (!(obj is MContentProperties)) {
				return false;
			}
			var guest:MContentProperties = obj as MContentProperties;
			if (spokenLanguage != guest.spokenLanguage) {
				return false;
			}
			if (emphasis != guest.emphasis) {
				return false;
			}
			return true;
		}		
	}
}