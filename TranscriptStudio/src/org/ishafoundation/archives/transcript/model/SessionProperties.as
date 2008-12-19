package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
	public class SessionProperties
	{
		public static const ID_ATTR_NAME:String = "id";
		public static const NAME_ATTR_NAME:String = "name";
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
		public function get name():String {
			return XMLUtils.getAttributeValue(sessionElement, NAME_ATTR_NAME);
		}
		
		public function set name(newValue:String):void {
			XMLUtils.setAttributeValue(sessionElement, NAME_ATTR_NAME, newValue);
		}
		
		[Bindable]
		public function get startAt():Date {
			return XMLUtils.getAttributeAsDate(sessionElement, START_AT_ATTR_NAME);
		}
		
		public function set startAt(newValue:Date):void {
			XMLUtils.setAttributeAsDate(sessionElement, START_AT_ATTR_NAME, newValue, false);
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