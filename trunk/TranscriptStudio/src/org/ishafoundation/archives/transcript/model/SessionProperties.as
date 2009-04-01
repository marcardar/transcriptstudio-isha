package org.ishafoundation.archives.transcript.model
{
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.DateUtils;
	import name.carter.mark.flex.util.XMLUtils;
	
	public class SessionProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const EVENT_ID_ATTR_NAME:String = "eventId";
		public static const SUB_TITLE_ATTR_NAME:String = "subTitle";
		public static const START_AT_ATTR_NAME:String = "startAt";
		public static const COMMENT_ATTR_NAME:String = "comment";
		
		public var sessionElement:XML;
		
		public function SessionProperties(sessionElement:XML)
		{
			this.sessionElement = sessionElement;
		}

		[Bindable]
		public function get id():String {
			return sessionElement.attribute(ID_ATTR_NAME);
		}
		
		public function set id(newValue:String):void {
			if (newValue == null || StringUtil.trim(newValue).length == 0) {
				throw new Error("Passed an invalid session id: " + newValue);
			} 
			XMLUtils.setAttributeValue(sessionElement, ID_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get eventId():String {
			return sessionElement.attribute(EVENT_ID_ATTR_NAME);
		}
		
		public function set eventId(newValue:String):void {
			XMLUtils.setAttributeValue(sessionElement, EVENT_ID_ATTR_NAME, newValue);
		}
		
		public function get path():String {
			var result:String = sessionElement.attribute("_document-uri");
			return result;
		}
		
		[Bindable]
		public function get subTitle():String {
			return XMLUtils.getAttributeValue(sessionElement, SUB_TITLE_ATTR_NAME);
		}
		
		public function set subTitle(newValue:String):void {
			XMLUtils.setAttributeValue(sessionElement, SUB_TITLE_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get startAt():Date {
			return XMLUtils.getAttributeAsDate(sessionElement, START_AT_ATTR_NAME);
		}
		
		private function set startAt(newValue:Date):void {
			// this is a mega hack - we want to be able to say whether to write the time or not
			// so if number of millis is zero => no time, > 0 implies time
			XMLUtils.setAttributeAsDate(sessionElement, START_AT_ATTR_NAME, newValue, newValue != null && newValue.milliseconds > 0);			
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
			var startAt:String = XMLUtils.getAttributeValue(sessionElement, START_AT_ATTR_NAME);
			if (startAt == null) {
				return false;
			}
			return startAt.indexOf("T") > 0;
		}
		
		[Bindable]
		public function get comment():String {
			return XMLUtils.getAttributeValue(sessionElement, COMMENT_ATTR_NAME);
		}
		
		public function set comment(newValue:String):void {
			XMLUtils.setAttributeValue(sessionElement, COMMENT_ATTR_NAME, newValue);
		}
		
		private static const TIME_FORMATTER:DateFormatter = DateUtils.createDateFormatter("JJ:NN");

		public function getFullName(eventStartDate:Date):String {
			var eventDay:int = getEventDay(eventStartDate);
			var result:String = "Day " + (eventDay == 0 ? "?" : eventDay) + ": ";
			if (startAtIncludesTime()) {
				result += TIME_FORMATTER.format(startAt) + " ";
			}
			if (subTitle != null) {
				result += subTitle + " ";
			}
			result += "[" + id + "]";
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