package name.carter.mark.flex.project.mdoc
{
	public class MNodeRange
	{
		public var firstNode:MNode;
		public var lastNode:MNode;
		private var nodeClass:Class;
		
		public function MNodeRange(firstNode:MNode, lastNode:MNode, nodeClass:Class)
		{
			if (firstNode == null) {
				throw new Error("Passed a null firstNode");
			}
			if (lastNode == null) {
				throw new Error("Passed a null lastNode");
			}
			this.firstNode = firstNode;
			this.lastNode = lastNode;
			this.nodeClass = nodeClass;
		}

		public function get nodesInRange():Array {
			var result:Array = new Array();
			var mdoc:MDocument = MUtils.getDocument(firstNode);
			for each (var node:MNode in MUtils.getDescendantsOrSelfByClass(mdoc, nodeClass)) {
				if (result.length == 0) {
					// havent started yet so look for first segment
					if (node != firstNode) {
						continue;
					}
				}
				result.push(node);
				if (node == lastNode) {
					return result;
				}
			}
			throw new Error("Could not find last node in range: " + lastNode);
		}

		/**
		 * returns true iff every node in the range has the same parent (outline or top level) 
		 */
		public function allAtSameLevel():Boolean {
			var parent:MNode = null;
			for each (var node:MNode in nodesInRange) {
				if (parent == null) {
					// first element so just set the parent
					parent = node.parent;
				}
				else {
					if (parent != node.parent) {
						return false;
					}
				}
			}
			return true;
		}

		public function expandAccordingToHierarchy():void {
			var ancestorSiblings:Array = MUtils.getCorrespondingAncestorSiblings(firstNode, lastNode);
			firstNode = MUtils.getDescendantsOrSelfByClass(ancestorSiblings[0] as MNode, nodeClass)[0];
			var nodesOfLastSibling:Array = MUtils.getDescendantsOrSelfByClass((ancestorSiblings[ancestorSiblings.length - 1] as MNode), nodeClass);
			lastNode = nodesOfLastSibling[nodesOfLastSibling.length - 1];
		}
		
		
		public function setProperty(propName:String, propValue:String):void {
			for each (var node:MNode in nodesInRange) {
				node.setProperty(propName, propValue);
			}
		}

		public function equals(obj:Object):Boolean {
			if (obj == this) {
				return true;
			}
			if (!(obj is MNodeRange)) {
				return false;
			}
			var guest:MNodeRange = obj as MNodeRange;
			if (this.firstNode != guest.firstNode) {
				return false;
			}
			if (this.lastNode != guest.lastNode) {
				return false;
			}
			return true;
		}
	}
}