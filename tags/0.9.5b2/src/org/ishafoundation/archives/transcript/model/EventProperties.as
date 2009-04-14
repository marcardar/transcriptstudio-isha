package org.ishafoundation.archives.transcript.model
{
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.DateUtils;
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	
	public class EventProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const SUB_TITLE_ATTR_SUB_TITLE:String = "subTitle";
		public static const TYPE_ATTR_NAME:String = "type";
		public static const START_AT_ATTR_NAME:String = "startAt";
		public static const END_AT_ATTR_NAME:String = "endAt";
		public static const COUNTRY_ATTR_NAME:String = "country";
		public static const LOCATION_ATTR_NAME:String = "location";
		public static const VENUE_ATTR_NAME:String = "venue";
		public static const LANGUAGE_ATTR_NAME:String = "language";
		public static const LANGUAGE_DEFAULT:String = "english";
		public static const COMMENT_ATTR_NAME:String = "comment";
		
		public static const TYPES:Array = createTypesArray();
		private static const DATE_FORMATTER:DateFormatter = DateUtils.createDateFormatter("DD-MMM-YY");
		
		public var eventElement:XML;
		
		public function EventProperties(eventElement:XML = null)
		{
			if (eventElement == null) {
				this.eventElement = <event/>;
			}
			else {
				this.eventElement = eventElement;
			}
		}
		
		public function copy():EventProperties {
			return new EventProperties(eventElement.copy());
		}

		private static function createTypesArray():Array {
			var result:Array = [];
			for (var i:int = 0; i < 26; i++) {
				result.push(String.fromCharCode(i + 97));
			}
			return result;
		}

		public function get path():String {
			var result:String = eventElement.attribute("_document-uri");
			return result;
		}
		
		[Bindable]
		public function get id():String {
			return XMLUtils.getAttributeValue(eventElement, ID_ATTR_NAME);
		}
		
		public function set id(newValue:String):void {
			if (newValue == null || StringUtil.trim(newValue).length == 0) {
				throw new Error("Passed a blank event id");
			} 
			XMLUtils.setAttributeValue(eventElement, ID_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get subTitle():String {
			return XMLUtils.getAttributeValue(eventElement, SUB_TITLE_ATTR_SUB_TITLE);			
		}
		
		public function set subTitle(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, SUB_TITLE_ATTR_SUB_TITLE, newValue);
		}
		
		[Bindable]
		public function get type():String {
			return XMLUtils.getAttributeValue(eventElement, TYPE_ATTR_NAME);			
		}
		
		public function set type(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, TYPE_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get startAt():Date {
			return XMLUtils.getAttributeAsDate(eventElement, START_AT_ATTR_NAME);
		}
		
		public function set startAt(newValue:Date):void {
			XMLUtils.setAttributeAsDate(eventElement, START_AT_ATTR_NAME, newValue, false);
		}
		
		[Bindable]
		public function get endAt():Date {
			return XMLUtils.getAttributeAsDate(eventElement, END_AT_ATTR_NAME);
		}
		
		public function set endAt(newValue:Date):void {
			XMLUtils.setAttributeAsDate(eventElement, END_AT_ATTR_NAME, newValue, false);
		}
		
		[Bindable]
		public function get country():String {
			return XMLUtils.getAttributeValue(eventElement, COUNTRY_ATTR_NAME);
		}
		
		public function set country(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, COUNTRY_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get location():String {
			return XMLUtils.getAttributeValue(eventElement, LOCATION_ATTR_NAME);
		}
		
		public function set location(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, LOCATION_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get venue():String {
			return XMLUtils.getAttributeValue(eventElement, VENUE_ATTR_NAME);
		}
		
		public function set venue(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, VENUE_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get language():String {
			return XMLUtils.getAttributeValue(eventElement, LANGUAGE_ATTR_NAME, LANGUAGE_DEFAULT);
		}
		
		public function set language(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, LANGUAGE_ATTR_NAME, newValue, LANGUAGE_DEFAULT);
		}
		
		[Bindable]
		public function get comment():String {
			return XMLUtils.getAttributeValue(eventElement, COMMENT_ATTR_NAME);
		}
		
		public function set comment(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, COMMENT_ATTR_NAME, newValue);
		}

		/**
		 * Returns the place in the form Spanda Hall, Isha Yoga Center, India
		 */
		public function get place():String {
			var placeArr:Array = [venue, location, country];
			placeArr = Utils.condenseWhitespaceForArray(placeArr);
			var placeStr:String = placeArr.join(", ");
			return placeStr;
		}
		
		public function generateFullName(includeEventType:Boolean):String {
			var result:String = "";
			if (includeEventType) {
				result += type + ":";
			}
			if (startAt != null) {
				result += " " + DATE_FORMATTER.format(startAt);
			}
			if (subTitle != null) {
				result += " " + subTitle;
			}
			var place:String = place;
			if (place.length > 0) {
				result += " @ " + place;
			}
			result += " [" + id + "]";
			return result;
		}
		
		public function generateLongText(referenceMgr:ReferenceManager):String {
			var result:String = referenceMgr.getEventTypeName(type) + " (" + type + ")";
			if (subTitle != null) {
				result += " - " + subTitle;
			}
			result += "\n";
			result += "Start: ";
			if (startAt == null) {
				result += "<unknown>";
			}
			else {
				result += DATE_FORMATTER.format(startAt);
			}
			result += ", End: ";
			if (endAt == null) {
				result += "<unknown>";
			}
			else {
				result += DATE_FORMATTER.format(endAt);
			}
			result += "\n";
			result += "Place: ";
			var place:String = place;
			if (place == null || place.length == 0) {
				result += "<unknown>";
			}
			else {
				result += place;
			}
			result += "\nLanguage: " + language; 
			if (comment != null) {
				result += "\n";
				result += "Notes: " + comment;
			}
			return result;
		}
		
	}
}