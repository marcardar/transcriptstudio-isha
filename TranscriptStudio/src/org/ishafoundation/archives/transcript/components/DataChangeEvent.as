package org.ishafoundation.archives.transcript.components
{
	import flash.events.Event;

	public class DataChangeEvent extends Event
	{
		public static const MARKUP_HIERARCHY_CHANGE:String = "MARKUP_HIERARCHY_CHANGE"; // creation/deletion of these superSegment and superContent
		public static const MARKUP_PROPERTIES_CHANGE:String = "MARKUP_PROPERTIES_CHANGE"; // attributes of superSegment and superContent and creation/deletion of these elements
		public static const TEXT_CHANGE:String = "TEXT_CHANGE"; // attributes or text nodes of segment and content elements and creation/deletion of these elements 
		public static const SESSION_PROPERTIES_CHANGE:String = "SESSION_PROPERTIES_CHANGE"; // attributes of session OR transcript element
		
		public var affectedObj:Object;
		
		public function DataChangeEvent(type:String, affectedObj:Object = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.affectedObj = affectedObj;
		}
	}
}