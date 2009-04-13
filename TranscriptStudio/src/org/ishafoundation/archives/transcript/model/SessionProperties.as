package org.ishafoundation.archives.transcript.model
{
	import mx.formatters.DateFormatter;
	
	import name.carter.mark.flex.util.DateUtils;
	import name.carter.mark.flex.util.XMLUtils;
	
	public class SessionProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const EVENT_ID_ATTR_NAME:String = "eventId";
		public static const SUB_TITLE_ATTR_NAME:String = "subTitle";
		public static const START_AT_ATTR_NAME:String = "startAt";
		public static const NOTES_ELEMENT_NAME:String = "notes";
		
		public var metadataElement:XML;
		public var eventId:String;
		public var sessionId:String;
		
		public function SessionProperties(metadataElement:XML, eventId:String, sessionId:String = null)
		{
			if (metadataElement == null) {
				throw new Error("Passed a null metadata element");
			}
			this.metadataElement = metadataElement;
			this.eventId = eventId;
			this.sessionId = sessionId;
		}
		
		public static function createInstanceFromSessionXML(sessionXML:XML):SessionProperties {
			var metadataElement:XML = sessionXML.metadata[0];
			if (metadataElement == null) {
				throw new Error("Session XML does not have any metadata");
			}
			var eventId:String = sessionXML.@eventId;
			var sessionId:String = sessionXML.@id;
			return new SessionProperties(metadataElement, eventId, sessionId);
		}

		public function copy():SessionProperties {
			return new SessionProperties(metadataElement.copy(), eventId, sessionId);
		}

		public function get path():String {
			var result:String = metadataElement.attribute("_document-uri");
			return result;
		}
		
		[Bindable]
		public function get subTitle():String {
			return XMLUtils.getAttributeValue(metadataElement, SUB_TITLE_ATTR_NAME);
		}
		
		public function set subTitle(newValue:String):void {
			XMLUtils.setAttributeValue(metadataElement, SUB_TITLE_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get startAt():Date {
			return XMLUtils.getAttributeAsDate(metadataElement, START_AT_ATTR_NAME);
		}
		
		private function set startAt(newValue:Date):void {
			// this is a mega hack - we want to be able to say whether to write the time or not
			// so if number of millis is zero => no time, > 0 implies time
			XMLUtils.setAttributeAsDate(metadataElement, START_AT_ATTR_NAME, newValue, newValue != null && newValue.milliseconds > 0);			
		}
		
		public function setStartAt(newValue:Date, includesTime:Boolean):void {
			if (newValue != null) {
				if (includesTime) {
					newValue.milliseconds = 1;
				}
				else {
					newValue.milliseconds = 0;
				}
			}
			startAt = newValue;
		}
		
		public function startAtIncludesTime():Boolean {
			var startAt:String = XMLUtils.getAttributeValue(metadataElement, START_AT_ATTR_NAME);
			if (startAt == null) {
				return false;
			}
			return startAt.indexOf("T") > 0;
		}
		
		[Bindable]
		public function get notes():String {
			return XMLUtils.getChildElementText(metadataElement, NOTES_ELEMENT_NAME);
		}
		
		public function set notes(newValue:String):void {
			XMLUtils.setChildElementText(metadataElement, NOTES_ELEMENT_NAME, newValue);
		}
		
		private static const TIME_FORMATTER:DateFormatter = DateUtils.createDateFormatter("JJ:NN");

		public function getFullName(eventProps:EventProperties):String {
			var result:String = sessionId + ": ";
			var eventDay:int = getEventDay(eventProps.startAt);
			result += "Day " + (eventDay == 0 ? "?" : eventDay);
			var addedHyphen:Boolean = false;
			if (startAtIncludesTime()) {
				result += " - " + TIME_FORMATTER.format(startAt) + " ";
				addedHyphen = true;
			}
			if (subTitle != null) {
				if (!addedHyphen) {
					result += " - ";
					addedHyphen = true;
				}
				result += subTitle + " ";
			}
			return result;
		}
		
		/**
		 * 1-based day (0, means unknown)
		 */
		private function getEventDay(eventStartDate:Date):int {
			if (eventStartDate == null || startAt == null) {
				return 0;
			}
			// get start of day
			var startOfEventDay:Date = DateUtils.getStartOfDay(eventStartDate);
			var millisDiff:Number = DateUtils.getStartOfDay(startAt).getTime() - startOfEventDay.getTime();
			if (millisDiff < 0) {
				return 0;
			}
			return int(millisDiff / DateUtils.MILLIS_IN_DAY) + 1;
		}
	}
}