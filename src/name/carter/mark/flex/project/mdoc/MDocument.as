package name.carter.mark.flex.project.mdoc
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
	
	public class MDocument extends TaggableMNode
	{
		internal var idToNodeMap:IMap = new HashMap();
		private var prefixToLargestIdMap:IMap = new HashMap();
		internal var username:String;

		public function MDocument(docElement:XML)
		{
			super(docElement, null);
			this.username = username;
			executeNodeFunc(function(node:MNode):Boolean {
				updateLargestIdMap(node.id); // might as well
				return true;
			});
			modified = false; // nothing changed yet
		}
		
		private function allNodes():Array {
			var result:Array = new Array();
			executeNodeFunc(function(node:MNode):Boolean {
				result.push(node);
				return true;
			});
			return result;
		}
		
		private function executeNodeFunc(nodeFunc:Function):void {
			for each (var element:XML in nodeElement..*.(localName() == MSuperSegment.TAG_NAME || localName() == MSegment.TAG_NAME || localName() == MSuperContent.TAG_NAME || localName() == MContent.TAG_NAME)) {
				var node:MNode = resolveElement(element);
				var moreToDo:Boolean = nodeFunc(node);
				if (!moreToDo) {
					break;
				}
			}			
		}

		public function resolveId(id:String):MNode {
			return MUtils.getDescendantOrSelfNodeById(this, id);
		}
		
		public function resolveElement(element:XML):MNode {
			if (element == null) {
				return null;
			}
			if (element == nodeElement) {
				return this;
			}
			var nodeId:String = element.@id;
			var result:MNode = idToNodeMap.getValue(nodeId);
			if (result == null) {
				if (element.localName() == MSuperSegment.TAG_NAME) {
					result = new MSuperSegment(element, this);
				}
				else if (element.localName() == MSegment.TAG_NAME) {
					result = new MSegment(element, this);
				}
				else if (element.localName() == MSuperContent.TAG_NAME) {
					result = new MSuperContent(element, this);
				}
				else if (element.localName() == MContent.TAG_NAME) {
					result = new MContent(element, this);
				}
				else {
					return null;
				}
				registerNodeForId(nodeId, result);
			}
			else {
				// check the element has not changed
				if (result.nodeElement != element) {
				}
			}
			return result;
		}
		
		private function registerNodeForId(id:String, node:MNode):void {
			var existingNode:MNode = idToNodeMap.getValue(id) as MNode;
			if (existingNode != null) {
				if (existingNode != node) {
					throw new Error("Registering different node for id: " + id + ": " + node);					
				}
				else {
					// we have already registered this so nothing more to do
				}
			}
			else {
				idToNodeMap.put(id, node);
				node.modified = true; // its a new element so assume its modified
			}
		}
		
		public function createSuperSegment(segmentRange:MSegmentRange):MSuperSegment {
			var ancestorSiblings:Array = MUtils.getCorrespondingAncestorSiblings(segmentRange.first, segmentRange.last);
			var markupElement:XML = createElement(MSuperSegment.TAG_NAME, MSuperSegment.ID_PREFIX);
			XMLUtils.insertParentElement(markupElement, nodesToElements(ancestorSiblings));
			return resolveElement(markupElement) as MSuperSegment;
		}
		
		private static function nodesToElements(nodes:Array):XMLList {
			var result:XMLList = new XMLList();
			for each (var node:MNode in nodes) {
				result += (node as MNode).nodeElement;
			}
			return result;
		}
		
		public function createSuperContent(conceptRange:MContentRange):MSuperContent {
			var ancestorSiblings:Array = MUtils.getCorrespondingAncestorSiblings(conceptRange.first, conceptRange.last);
			var markupElement:XML = createElement(MSuperContent.TAG_NAME, MSuperContent.ID_PREFIX);
			XMLUtils.insertParentElement(markupElement, nodesToElements(ancestorSiblings));
			return resolveElement(markupElement) as MSuperContent;
		}
		
		public function createSegmentElement(templateSegmentElement:XML = null):XML {
			if (templateSegmentElement == null) {
				return createElement(MSegment.TAG_NAME, MSegment.ID_PREFIX);
			}
			else {
				// use the template - only for the attributes
				var result:XML = templateSegmentElement.copy();
				XMLUtils.removeAllElements(result.*);
				result.@id = generateId(MSegment.ID_PREFIX);
				return result;
			}
		}
		
		public function createContentElement(templateContentElement:XML = null):XML {
			if (templateContentElement == null) {
				return createElement(MContent.TAG_NAME, MContent.ID_PREFIX);
			}
			else {
				// use the template - only for the attributes
				var result:XML = templateContentElement.copy();
				XMLUtils.removeAllElements(result.*);
				result.@id = generateId(MContent.ID_PREFIX);
				return result;
			}
		}
		
		internal function createElement(tagName:String, idPrefix:String):XML {
			return <{tagName} id={generateId(idPrefix)}/>;
		} 

		internal function generateId(prefix:String):String {
			var largestIdValue:int = prefixToLargestIdMap.getValue(prefix);
			var newIdValue:int = largestIdValue + 1;
			updateLargestIdValueMap(prefix, newIdValue);
			return prefix + new String(newIdValue);
		}
		
		private function updateLargestIdMap(id:String):void {
			var prefix:String = id.replace(/\d/g, "");
			var idValue:int = new int(id.replace(/\D/g, ""));
			updateLargestIdValueMap(prefix, idValue);
		}
		
		private function updateLargestIdValueMap(prefix:String, idValue:int):void {
			var largestIdValue:int = prefixToLargestIdMap.getValue(prefix);
			if (largestIdValue == 0 || largestIdValue < idValue) {
				prefixToLargestIdMap.put(prefix, idValue);
			}
		}
		
		public function getAllPropertyValues(propName:String):ISet {
			return getAllPropertyValuesInternal(this, propName);
		}
		
		private static function getAllPropertyValuesInternal(node:MNode, propName:String):ISet {
			var result:ISet = new HashSet();
			var value:String = node.getPropertyValue(propName);
			if (value != null) {
				result.add(value);
			}
			for each (var child:MNode in node.childNodes) {
				var childValues:ISet = getAllPropertyValuesInternal(child, propName);
				result.addAll(childValues.toArray());
			}
			return result;
		}
	}
}