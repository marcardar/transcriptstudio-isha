package org.ishafoundation.archives.transcript.fs
{
	public class File
	{
		public var nodeId:String; // unique for any node in FS
		public var fileSystem:DbFileSystem;
		
		public function File(nodeId:String, fileSystem:DbFileSystem)
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