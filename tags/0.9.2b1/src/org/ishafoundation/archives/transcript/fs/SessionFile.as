package org.ishafoundation.archives.transcript.fs
{
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
	public class SessionFile extends File
	{
		public function SessionFile(sessionId:String, fileSystem:DbFileSystem)
		{
			super(sessionId, fileSystem);
		}

		public function getEventFile():EventFile {
			var eventId:String = IdUtils.getEventId(nodeId, false);
			return fileSystem.getEventFile(eventId);
		}
	}
}