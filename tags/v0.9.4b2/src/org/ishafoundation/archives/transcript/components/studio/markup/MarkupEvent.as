package org.ishafoundation.archives.transcript.components.studio.markup
{
	import flash.events.Event;
	
	import name.carter.mark.flex.project.mdoc.MSuperNode;

	public class MarkupEvent extends Event
	{
		public static const DATA_CHANGE:String = "MARKUP_DATA_CHANGE"; // creation/deletion of these superSegment and superContent
		public static const SELECTION_CHANGE:String = "MARKUP_SELECTION_CHANGE"; // attributes of superSegment and superContent and creation/deletion of these elements
		
		public var affectedMarkup:MSuperNode;
		// primarily to allow us to say that a selection change is strong or not - i.e. double-clicking on markup (strong), or single clicking (weak)
		// for data change: strong means - hierarchy change, weak means properties change
		public var isStrongChange:Boolean;
		
		public function MarkupEvent(type:String, isStrongChange:Boolean, affectedMarkup:MSuperNode = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.affectedMarkup = affectedMarkup;
			this.isStrongChange = isStrongChange;
		}
	}
}