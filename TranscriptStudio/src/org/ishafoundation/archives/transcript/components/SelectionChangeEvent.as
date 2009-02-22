package org.ishafoundation.archives.transcript.components
{
	import flash.events.Event;

	public class SelectionChangeEvent extends Event
	{
		public static const MARKUP_TREE_SELECTION_CHANGE:String = "MARKUP_TREE_SELECTION_CHANGE";
		public static const TRANSCRIPT_TEXT_AREA_SELECTION_CHANGE:String = "TRANSCRIPT_TEXT_AREA_SELECTION_CHANGE";
		
		public var affectedObj:Object;
		
		public function SelectionChangeEvent(type:String, affectedObj:Object = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.affectedObj = affectedObj;
		}
	}
}