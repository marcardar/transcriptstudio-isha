package org.ishafoundation.archives.transcript.components.studio.text
{
	import flash.events.Event;
	
	import org.ishafoundation.archives.transcript.model.TranscriptTextSelection;

	public class TranscriptTextEvent extends Event
	{
		public static const DATA_CHANGE:String = "TRANSCRIPT_TEXT_DATA_CHANGE"; // attributes or text nodes of segment and content elements and creation/deletion of these elements 
		public static const SELECTION_CHANGE:String = "TRANSCRIPT_TEXT_SELECTION_CHANGE";
		
		public var affectedTtSelection:TranscriptTextSelection;
		
		public function TranscriptTextEvent(type:String, affectedTtSelection:TranscriptTextSelection = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.affectedTtSelection = affectedTtSelection;
		}
	}
}