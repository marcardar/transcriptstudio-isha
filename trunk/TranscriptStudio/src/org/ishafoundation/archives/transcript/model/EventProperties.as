package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
	public class EventProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const NAME_ATTR_NAME:String = "name";
		public static const TYPE_ATTR_NAME:String = "type";
		public static const TYPE_DEFAULT:String = "n";
		public static const START_AT_ATTR_NAME:String = "startAt";
		public static const END_AT_ATTR_NAME:String = "endAt";
		public static const LOCATION_ATTR_NAME:String = "location";
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
		public function get name():String {
			return XMLUtils.getAttributeValue(eventElement, NAME_ATTR_NAME);			
		}
		
		public function set name(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, NAME_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get type():String {
			return XMLUtils.getAttributeValue(eventElement, TYPE_ATTR_NAME);			
		}
		
		public function set type(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, TYPE_ATTR_NAME, newValue, TYPE_DEFAULT);
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
		public function get location():String {
			return XMLUtils.getAttributeValue(eventElement, LOCATION_ATTR_NAME);
		}
		
		public function set location(newValue:String):void {
			XMLUtils.setAttributeValue(eventElement, LOCATION_ATTR_NAME, newValue);
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
		
		
	}
}