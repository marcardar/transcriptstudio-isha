package org.ishafoundation.archives.transcript.fs
{
	public class EventFile extends File
	{
		public function EventFile(eventId:String, fileSystem:DbFileSystem)
		{
			super(eventId, fileSystem);
		}

		public function get collection():Collection {
			return fileSystem.getAncestorOrSelfCollection(nodeId);
		}

		public function getSessionFiles():Array {
			return fileSystem.getSessionFiles(nodeId);
		}
		
		public function getSessionFileById(sessionId:String):SessionFile {
			for each (var sessionFile:SessionFile in getSessionFiles()) {
				if (sessionFile.nodeId == sessionId) {
					return sessionFile;
				}
			}
			return null;
		}
	}
}