package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
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
		
		public static const LANGUAGES:Array = [EventProperties.LANGUAGE_DEFAULT, "tamil", "other"];
		public static const TYPES:Array = createTypesArray();
		
		public var eventElement:XML;
		
		public function EventProperties(eventElement:XML)
		{
			this.eventElement = eventElement;
		}

		private static function createTypesArray():Array {
			var result:Array = [];
			for (var i:int = 0; i < 26; i++) {
				result.push(String.fromCharCode(i + 97));
			}
			return result;
		}

		[Bindable]
		public function get id():String {
			return XMLUtils.getAttributeValue(eventElement, ID_ATTR_NAME);
		}
		
		public function set id(newValue:String):void {
			if (!IdUtils.isValidEventId(newValue)) {
				throw new Error("Passed an invalid event id: " + newValue);
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
		
		public function generateFilename():String {
			var filename:String = id + "_" + type;
			if (subTitle != null) {
				filename += "_" + subTitle;
			}
			if (location != null) {
				filename += "_" + location;
			}
			if (venue != null) {
				filename += "_" + venue;
			}
			filename += ".xml";
			// replace spaces with underscores and make lower case
			filename = filename.replace(/ /g, "-").toLowerCase();
			return filename;
		}
	}
}