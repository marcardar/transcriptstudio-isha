package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
	public class SessionProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const SUB_TITLE_ATTR_NAME:String = "subTitle";
		public static const START_AT_ATTR_NAME:String = "startAt";
		public static const COMMENT_ATTR_NAME:String = "comment";
		
		private var sessionElement:XML;
		
		public function SessionProperties(sessionElement:XML)
		{
			this.sessionElement = sessionElement;
		}

		[Bindable]
		public function get id():String {
			return sessionElement.@id;
		}
		
		public function set id(newValue:String):void {
			if (!IdUtils.isValidSessionId(newValue)) {
				throw new Error("Passed an invalid session id: " + newValue);
			} 
			XMLUtils.setAttributeValue(sessionElement, ID_ATTR_NAME, newValue);
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
	}
}