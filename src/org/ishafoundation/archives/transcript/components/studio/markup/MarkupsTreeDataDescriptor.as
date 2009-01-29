package org.ishafoundation.archives.transcript.components.studio.markup
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MSegment;
	import name.carter.mark.flex.project.mdoc.MSuperNode;

	public class MarkupsTreeDataDescriptor implements ITreeDataDescriptor
	{
		public function MarkupsTreeDataDescriptor()
		{
		}

		public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			var mnode:MNode = node as MNode;
			var result:Array = [];
			for each (var child:MNode in mnode.childNodes) {
				if (child is MSuperNode) {
					result.push(child);
				}
				else if (child is MSegment) {
					for each (var sChild:MNode in child.childNodes) {
						if (sChild is MSuperNode) {
							result.push(sChild);
						}						
					}
				}
			}
			return new ArrayCollection(result);
		}
		
		public function hasChildren(node:Object, model:Object=null):Boolean
		{
			return getChildren(node).length > 0;
		}
		
		public function isBranch(node:Object, model:Object=null):Boolean
		{
			return hasChildren(node);
		}
		
		public function getData(node:Object, model:Object=null):Object
		{
			return node;
		}
		
		public function addChildAt(parent:Object, newChild:Object, index:int, model:Object=null):Boolean
		{
			throw new Error("not yet implemented");
		}
		
		public function removeChildAt(parent:Object, child:Object, index:int, model:Object=null):Boolean
		{
			throw new Error("not yet implemented");
		}
		
	}
}