package org.ishafoundation.archives.transcript.fs
{
	public class Collection extends File
	{
		public function Collection(collectionId:String, fileSystem:DbFileSystem)
		{
			super(collectionId, fileSystem);
		}
		
		public function get eventFiles():Array {
			return fileSystem.getEventFiles(nodeId);
		}
		
		public function getEventFile(eventId:String):EventFile {
			for each (var eventFile:EventFile in eventFiles) {
				if (eventFile.nodeId == eventId) {
					return eventFile;
				}
			}
			return null;
		}
		
		public function get otherFiles():Array {
			return fileSystem.getOtherFiles(nodeId);
		}
		
		public function get childCollections():Array {
			return fileSystem.getChildCollections(nodeId);
		}
	}
}