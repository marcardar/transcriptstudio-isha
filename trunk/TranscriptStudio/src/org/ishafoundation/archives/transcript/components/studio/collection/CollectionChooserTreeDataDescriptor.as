package org.ishafoundation.archives.transcript.components.studio.collection
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	import org.ishafoundation.archives.transcript.fs.Collection;

	public class CollectionChooserTreeDataDescriptor implements ITreeDataDescriptor
	{
		public function CollectionChooserTreeDataDescriptor()
		{
		}

		public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			var collection:Collection = node as Collection;
			var result:Array = collection.childCollections;
			result.sort();
			return new ArrayCollection(result);
		}
		
		public function hasChildren(node:Object, model:Object=null):Boolean
		{
			var collection:Collection = node as Collection;
			return collection.childCollections.length > 0;
		}
		
		public function isBranch(node:Object, model:Object=null):Boolean
		{
			return hasChildren(node, model);
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