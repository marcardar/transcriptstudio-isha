package org.ishafoundation.archives.transcript.fs
{
	public class File
	{
		public var nodeId:String; // unique for any node in FS
		public var fileSystem:FileSystem;
		
		public function File(nodeId:String, fileSystem:FileSystem)
		{
			this.nodeId = nodeId;
			this.fileSystem = fileSystem;
		}

		public function get name():String {
			return fileSystem.getName(nodeId);
		}

		public function get path():String {
			return fileSystem.getPath(nodeId);
		}
		
		public function refresh(successFunc:Function, failureFunc:Function):void {
			var collectionPath:String = fileSystem.getAncestorOrSelfCollection(nodeId).path;
			fileSystem.refresh(collectionPath, successFunc, failureFunc);
		}
		
		public function toString():String {
			return nodeId;
		}
	}
}