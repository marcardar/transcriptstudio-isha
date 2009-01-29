package org.ishafoundation.archives.transcript.components.studio.collection
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	import org.ishafoundation.archives.transcript.fs.Collection;
	import org.ishafoundation.archives.transcript.fs.EventFile;
	import org.ishafoundation.archives.transcript.fs.File;

	public class EventChooserTreeDataDescriptor implements ITreeDataDescriptor
	{
		public function EventChooserTreeDataDescriptor()
		{
		}

		public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			var file:File = node as File;
			if (file is EventFile) {
				var ef:EventFile = file as EventFile;
				var result:Array = ef.getSessionFiles();
				result.sort();
				return new ArrayCollection(result);
			}
			else {
				return new ArrayCollection();
			}
		}
		
		public function hasChildren(node:Object, model:Object=null):Boolean
		{
			var collection:Collection = node as Collection;
			return getChildren(node, model).length > 0;
		}
		
		public function isBranch(node:Object, model:Object=null):Boolean
		{
			return node is EventFile;
		}
		
		public function getData(node:Object, model:Object=null):Object
		{
			return node;
		}
		
		public function addChildAt(parent:Object, newChild:Object, index:int, model:Object=null):Boolean
		{
			throw new Error("not implemented");
		}
		
		public function removeChildAt(parent:Object, child:Object, index:int, model:Object=null):Boolean
		{
			throw new Error("not implemented");
		}
		
	}
}