package name.carter.mark.flex.project.mdoc
{
	public class MUtils
	{
		public static function getDocument(node:MNode):MDocument {
			return getAncestorOrSelfNode(node, MDocument) as MDocument;
		}
		
		// starts with markups element and finishes with self (element)
		public static function getAncestorsIncludingSelf(node:MNode):Array {
			if (node == null) {
				throw new Error("Passed a null node");
			}
			var result:Array = new Array();
			result.push(node);
			do {
				node = node.parent;
				result.unshift(node);
			} while (node.parent != null)
			return result;
		}
		
		public static function hasAncestorOrSelfId(startingNode:MNode, targetAncestorId:String):Boolean {
			var ancestors:Array = getAncestorsIncludingSelf(startingNode);
			for each (var ancestor:MNode in ancestors) {
				if (ancestor.id == targetAncestorId) {
					return true;
				}
			}
			return false;
		} 
				
		public static function getAncestorOrSelfNode(startingNode:MNode, ancestorClass:Class):MNode {
			if (startingNode == null) {
				return null;
			}
			else if (startingNode is ancestorClass) {
				return startingNode;
			}
			else {
				return getAncestorOrSelfNode(startingNode.parent, ancestorClass);
			}
		}

		public static function getDescendantOrSelfNodeById(startingNode:MNode, targetId:String):MNode {
			if (startingNode.id == targetId) {
				return startingNode;
			}
			for each (var childNode:MNode in startingNode.childNodes) {
				var result:MNode = getDescendantOrSelfNodeById(childNode, targetId);
				if (result != null) {
					return result;
				}
			}
			return null;
		}
		
		public static function getDescendantsOrSelfByClass(startingNode:MNode, targetClass:Class):Array {
			if (startingNode is targetClass) {
				return [startingNode];
			}
			var result:Array = new Array();
			for each (var childNode:MNode in startingNode.childNodes) {
				var childDescendants:Array = getDescendantsOrSelfByClass(childNode, targetClass);
				if (childDescendants.length == 0) {
					continue;
				}
				for each (var childDesc:MNode in childDescendants) {
					result.push(childDesc);					
				}
			}
			return result;
		}
		
		public static function getFirstContent(node:MNode):MContent {
			var contents:Array = getDescendantsOrSelfByClass(node, MContent);
			if (contents.length == 0) {
				return null
			}
			return contents[0];
		}
		
		public static function getLastContent(node:MNode):MContent {
			var contents:Array = getDescendantsOrSelfByClass(node, MContent);
			if (contents.length == 0) {
				return null
			}
			return contents[contents.length - 1];
		}
		
		/**
		 * Returns a new array containing only nodes of the specified class.
		 * 
		 * The original array is left unchanged.
		 */
		public static function filterNodes(nodes:Array, filterClass:Class):Array {
			return nodes.filter(function(node:MNode):Boolean {
				return node is filterClass;
			});
		}
		
		public static function getSpanningSuperSegment(firstNode:MNode, lastNode:MNode = null):MSuperSegment {
			return getCommonAncestor(firstNode, lastNode, MSuperSegment) as MSuperSegment;
		}
		
		public static function getSpanningSegment(firstNode:MNode, lastNode:MNode = null):MSegment {
			return getCommonAncestor(firstNode, lastNode, MSegment) as MSegment;
		}
		
		public static function getSpanningSuperContent(firstNode:MNode, lastNode:MNode = null):MSuperContent {
			return getCommonAncestor(firstNode, lastNode, MSuperContent) as MSuperContent;
		}
		
		public static function getCommonAncestor(node1:MNode, node2:MNode, targetClass:Class = null):MNode {
			var siblings:Array = getCorrespondingAncestorSiblings(node1, node2);
			if (siblings.length == 0) {
				return null;
			}
			else {
				var commonAncestor:MNode = (siblings[0] as MNode).parent;
				if (targetClass == null) {
					return commonAncestor;
				}
				else {
					return MUtils.getAncestorOrSelfNode(commonAncestor, targetClass);
				}
			}
		}

		/**
		 * Returns siblings where the first node is an ancestor (or self) of node1
		 * and the last node is an ancestor (or self) of node2.
		 * 
		 * The siblings' parent is the common ancestor of node1 and node2.
		 *
		 * If node1 is null then node2 is returned
		 * If node2 is null then node1 is returned
		 * If node1 == node2 then node1 is returned (i.e. single node list)
		 * If node1 and node2 have the same parent then the siblings from node1 to node2 (inclusive) are returned
		 * If node1 is an ancestor of node2 then node1 is returned.
		 * If node2 is an ancestor of node1 then node2 is returned.
		 * If node1 and node2 have no common ancestor (i.e. different MDocuments) then null is returned.
		 */
		public static function getCorrespondingAncestorSiblings(node1:MNode, node2:MNode):Array {
			if (node1 == null) {
				return [node2];
			}
			if (node2 == null) {
				return [node1];
			}
			if (node1 == node2) {
				var result:Array = new Array();
				result.push(node1);
				return result;
			}
			// expand selection at front to include appropriate complete outlines
			var ancestors1:Array = getAncestorsIncludingSelf(node1);
			var ancestors2:Array = getAncestorsIncludingSelf(node2);
			if (ancestors1[0] != ancestors2[0]) {
				// no common ancestor
				return null;
			}
			// find out where they deviate
			for (var i:int = 0; i < Math.min(ancestors1.length, ancestors2.length); i++) {
				if (ancestors1[i] != ancestors2[i]) {
					return getSiblingsBetweenAndSelves(ancestors1[i], ancestors2[i]);
				}
			}
			throw new Error("This code should not be reachable");			
		}
		
		/**
		 * Returns [firstSibling,...., lastSibling]
		 */
		private static function getSiblingsBetweenAndSelves(firstSibling:MNode, lastSibling:MNode):Array {
			var result:Array = new Array();
			var currentSibling:MNode = firstSibling;
			while (currentSibling != null) {
				result.push(currentSibling);
				if (currentSibling == lastSibling) {
					// we've just added the lastSibling
					return result;
				}
				currentSibling = currentSibling.followingSibling;
			}			
			throw new Error("These are not siblings: " + firstSibling + ", " + lastSibling);
		}
		
	}
}