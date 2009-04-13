package org.ishafoundation.archives.transcript.model
{
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.DateUtils;
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	
	public class EventMetadata
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
		public static const NOTES_ELEMENT_NAME:String = "notes";
		
		public static const TYPES:Array = createTypesArray();
		private static const DATE_FORMATTER:DateFormatter = DateUtils.createDateFormatter("DD-MMM-YY");
		
		public var eventMetadataElement:XML;
		private var _type:String;
		private var _id:String;
		
		public function EventMetadata(eventMetadataElement:XML, eventType:String, eventId:String = null)
		{
			if (eventMetadataElement == null) {
				this.eventMetadataElement = <metadata/>;
			}
			else if (eventMetadataElement.localName() != "metadata") {
				throw new Error("Passed an invalid event metadata element: " + eventMetadataElement.localName());
			}
			else {
				this.eventMetadataElement = eventMetadataElement;
			}
			this.type = eventType;
			if (eventId != null) {
				this.id = eventId;
			}
		}
		
		public static function createInstance(eventXML:XML):EventMetadata {
			var eventType:String = eventXML.@type;
			var eventId:String = XMLUtils.getAttributeValue(eventXML, "id", null);
			return new EventMetadata(eventXML.metadata[0], eventType, eventId);
		}
		
		public function copy():EventMetadata {
			return new EventMetadata(eventMetadataElement.copy(), type, id);
		}

		private static function createTypesArray():Array {
			var result:Array = [];
			for (var i:int = 0; i < 26; i++) {
				result.push(String.fromCharCode(i + 97));
			}
			return result;
		}

		public function get path():String {
			var result:String = eventMetadataElement.attribute("_document-uri");
			return result;
		}
		
		[Bindable]
		public function get id():String {
			return this._id;
		}
		
		public function set id(newValue:String):void {
			if (newValue == null || StringUtil.trim(newValue).length == 0) {
				throw new Error("Passed a blank event id");
			} 
			this._id = newValue;
		}
		
		[Bindable]
		public function get subTitle():String {
			return XMLUtils.getAttributeValue(eventMetadataElement, SUB_TITLE_ATTR_SUB_TITLE);			
		}
		
		public function set subTitle(newValue:String):void {
			XMLUtils.setAttributeValue(eventMetadataElement, SUB_TITLE_ATTR_SUB_TITLE, newValue);
		}
		
		[Bindable]
		public function get type():String {
			return _type;			
		}
		
		public function set type(newValue:String):void {
			this._type = newValue;
		}
		
		[Bindable]
		public function get startAt():Date {
			return XMLUtils.getAttributeAsDate(eventMetadataElement, START_AT_ATTR_NAME);
		}
		
		public function set startAt(newValue:Date):void {
			XMLUtils.setAttributeAsDate(eventMetadataElement, START_AT_ATTR_NAME, newValue, false);
		}
		
		[Bindable]
		public function get endAt():Date {
			return XMLUtils.getAttributeAsDate(eventMetadataElement, END_AT_ATTR_NAME);
		}
		
		public function set endAt(newValue:Date):void {
			XMLUtils.setAttributeAsDate(eventMetadataElement, END_AT_ATTR_NAME, newValue, false);
		}
		
		[Bindable]
		public function get country():String {
			return XMLUtils.getAttributeValue(eventMetadataElement, COUNTRY_ATTR_NAME);
		}
		
		public function set country(newValue:String):void {
			XMLUtils.setAttributeValue(eventMetadataElement, COUNTRY_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get location():String {
			return XMLUtils.getAttributeValue(eventMetadataElement, LOCATION_ATTR_NAME);
		}
		
		public function set location(newValue:String):void {
			XMLUtils.setAttributeValue(eventMetadataElement, LOCATION_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get venue():String {
			return XMLUtils.getAttributeValue(eventMetadataElement, VENUE_ATTR_NAME);
		}
		
		public function set venue(newValue:String):void {
			XMLUtils.setAttributeValue(eventMetadataElement, VENUE_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get language():String {
			return XMLUtils.getAttributeValue(eventMetadataElement, LANGUAGE_ATTR_NAME, LANGUAGE_DEFAULT);
		}
		
		public function set language(newValue:String):void {
			XMLUtils.setAttributeValue(eventMetadataElement, LANGUAGE_ATTR_NAME, newValue, LANGUAGE_DEFAULT);
		}
		
		[Bindable]
		public function get notes():String {
			return XMLUtils.getChildElementText(eventMetadataElement, NOTES_ELEMENT_NAME);
		}
		
		public function set notes(newValue:String):void {
			XMLUtils.setChildElementText(eventMetadataElement, NOTES_ELEMENT_NAME, newValue);
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
		
		public function generateFullName(referenceMgr:ReferenceManager):String {
			var result:String = id + ":";
			if (startAt != null) {
				result += " " + DATE_FORMATTER.format(startAt);
			}
			result += " " + referenceMgr.getEventTypeName(type);
			if (subTitle != null) {
				result += " - " + subTitle;
			}
			var place:String = place;
			if (place.length > 0) {
				result += " @ " + place;
			}
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
			if (notes != null) {
				result += "\n";
				result += "Notes: " + notes;
			}
			return result;
		}
		
	}
}