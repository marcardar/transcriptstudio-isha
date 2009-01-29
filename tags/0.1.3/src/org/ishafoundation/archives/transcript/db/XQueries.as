package org.ishafoundation.archives.transcript.db
{
	public class XQueries
	{
		public static const ALL_EVENTS:String = "(: all event ids :)\nfor $event in /event\nreturn $event";
		public static const ALL_EVENT_IDS:String = "(: all events :)\nfor $event in /event return <eventId>{string($event/@id)}</eventId>";
		public static const EVENT_IDS_WITH_PREFIX:String = "(: event ids starting with :)\nfor $event in /event\nlet $id := $event/@id\nwhere starts-with($id, $arg0)\nreturn <eventId>{string($event/@id)}</eventId>";
		public static const EVENTS_WITH_PREFIX:String = "(: events with id starting with :)\nfor $event in /event\nlet $id := $event/@id\nwhere starts-with($id, $arg0)\nreturn $event";
		
		public static const SESSION:String = "(: document :)\nfor $session in /session\nlet $id := $session/@id\nwhere $id = $arg0\nreturn $session";		

		public static const ALL_OUTLINES:String = "(: all outlines :)\nfor $outline in /session/transcript//superSegment\nreturn $outline";
		public static const OUTLINES_TAGGED_WITH:String = "(: outlines tagged with :)\nfor $outline in /session/transcript//superSegment\nreturn $outline";

		public static const ALL_XQUERIES:Array = [ALL_EVENTS, ALL_EVENT_IDS, EVENT_IDS_WITH_PREFIX, EVENTS_WITH_PREFIX, SESSION, ALL_OUTLINES];
		
		public function XQueries()
		{
		}

	}
}