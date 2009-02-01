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
	
	public class MSuperNodeProperties {
		public static const MARKUP_TYPE_TAG_NAME:String = "markupType";
		public static const MARKUP_CATEGORY_TAG_NAME:String = "markupCategory";
		public static const MARKUP_CATEGORY_SUGGESTION_TAG_NAME:String = "markupCategorySuggestion";
		public static const ADDITIONAL_CONCEPT_TAG_NAME:String = "concept";
		public static const SUMMARY_PROP_NAME:String = "summary";
		public static const COMMENT_PROP_NAME:String = "comment";
		public static const RATING_PROP_NAME:String = "rating";
		
		private var superNode:MSuperNode;
		
		public function MSuperNodeProperties(superNode:MSuperNode) {
			this.superNode = superNode;
		}
		
		public function overwrite(props:MSuperNodeProperties):void {
			markupTypeId = props.markupTypeId;
			markupCategoryId = props.markupCategoryId;
			markupCategorySuggestion = props.markupCategorySuggestion;
			additionalConcepts = props.additionalConcepts;
			summary = props.summary;
			comment = props.comment;
			rating = props.rating;
		}
		
		[Bindable]
		public function set markupTypeId(newValue:String):void {
			setSingletonTag(superNode, MARKUP_TYPE_TAG_NAME, newValue);
		}
		
		public function get markupTypeId():String {
			return getFirstTagValue(superNode, MARKUP_TYPE_TAG_NAME);
		}
		
		[Bindable]
		public function set markupCategoryId(newValue:String):void {
			setSingletonTag(superNode, MARKUP_CATEGORY_TAG_NAME, newValue);			
		}
		
		public function get markupCategoryId():String {
			return getFirstTagValue(superNode, MARKUP_CATEGORY_TAG_NAME);			
		}
		
		[Bindable]
		public function set markupCategorySuggestion(newValue:String):void {
			setSingletonTag(superNode, MARKUP_CATEGORY_SUGGESTION_TAG_NAME, newValue);			
		}
		
		public function get markupCategorySuggestion():String {
			return getFirstTagValueOrBlank(superNode, MARKUP_CATEGORY_SUGGESTION_TAG_NAME);			
		}
		
		[Bindable]
		public function set additionalConcepts(newValues:Array):void {
			setTags(superNode, ADDITIONAL_CONCEPT_TAG_NAME, newValues);
		}
		
		public function get additionalConcepts():Array {
			return superNode.getTagValues(ADDITIONAL_CONCEPT_TAG_NAME);
		}
		
		[Bindable]
		public function set summary(newValue:String):void {
			XMLUtils.setAttributeValue(superNode.nodeElement, SUMMARY_PROP_NAME, newValue);
		}
		
		public function get summary():String {
			return XMLUtils.getAttributeValue(superNode.nodeElement, SUMMARY_PROP_NAME, "");
		}
		
		[Bindable]
		public function set comment(newValue:String):void {
			XMLUtils.setAttributeValue(superNode.nodeElement, COMMENT_PROP_NAME, newValue);
		}
		
		public function get comment():String {
			return XMLUtils.getAttributeValue(superNode.nodeElement, COMMENT_PROP_NAME, "");
		}
		
		[Bindable]
		public function set rating(newValue:int):void {
			XMLUtils.setAttributeValue(superNode.nodeElement, RATING_PROP_NAME, newValue >= 0 ? newValue : null);
		}
		
		public function get rating():int {
			var ratingStr:String = XMLUtils.getAttributeValue(superNode.nodeElement, RATING_PROP_NAME);
			if (ratingStr == null || ratingStr.length == 0) {
				return -1;
			}
			else {
				return new int(ratingStr);
			}
		}
		
		public function equals(obj:Object):Boolean {
			if (obj == this) {
				return true;
			}
			if (!(obj is MSuperNodeProperties)) {
				return false;
			}
			var guest:MSuperNodeProperties = obj as MSuperNodeProperties;
			if (this.markupTypeId != guest.markupTypeId) {
				return false;
			}
			if (this.markupCategoryId != guest.markupCategoryId) {
				return false;
			}
			if (this.markupCategorySuggestion != guest.markupCategorySuggestion) {
				return false;
			}
			if (!arrayEquals(this.additionalConcepts, guest.additionalConcepts)) {
				return false;
			}
			if (this.summary != guest.summary) {
				return false;
			}
			if (this.comment != guest.comment) {
				return false;
			}
			if (this.rating != guest.rating) {
				return false;
			}
			return true;
		}
		
		private static function arrayEquals(arr1:Array, arr2:Array):Boolean {
			if (arr1 == arr2) {
				return true;
			}
			if (arr1 == null || arr2 == null) {
				return false;
			}
			// both non-null
			if (arr1.length != arr2.length) {
				return false;
			}
			for (var i:int = 0; i < arr1.length; i++) {
				if (arr1[i] != arr2[i]) {
					return false;
				}
			}
			return true;
		}
		
		private static function getFirstTagValue(node:TaggableMNode, tagType:String, throwException:Boolean = false):String {
			var values:Array = node.getTagValues(tagType);
			if (values.length == 0) {
				if (throwException) {
					throw new ArgumentError("Could not find tag type '" + tagType + "' for node: " + node);
				}
				else {
					return null;
				}
			}
			return values[0];
		}
		
		private static function getFirstTagValueOrBlank(node:TaggableMNode, tagType:String):String {
			var result:String = getFirstTagValue(node, tagType);
			if (result == null) {
				return "";
			}
			else {
				return result;
			}
		}
		
		private static function setTags(taggable:TaggableMNode, type:String, values:Array):void {
			taggable.removeAllTags(type);
			if (values != null) {
				for each (var value:* in values) {
					if (value == null) {
						continue;
					}
					var valueStr:String = value.toString();
					if (valueStr != null && valueStr.length > 0) {
						taggable.addTag(type, valueStr);
					}
				}
			}
		}
		
		private static function setSingletonTag(taggable:TaggableMNode, type:String, value:Object):void {
			taggable.removeAllTags(type);
			if (value != null) {
				var valueStr:String = value.toString();
				if (valueStr != null && valueStr.length > 0) {
					taggable.addTag(type, valueStr);
				}
			}
		}
	}
}