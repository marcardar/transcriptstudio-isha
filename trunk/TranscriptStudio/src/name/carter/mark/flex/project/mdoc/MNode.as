package name.carter.mark.flex.project.mdoc
{
	import mx.core.IUID;
	
	import name.carter.mark.flex.util.XMLUtils;

	public class MNode implements IUID
	{
		public static const LAST_ACTION_ATTR_NAME:String = "lastAction";
		public static const LAST_ACTION_AT_ATTR_NAME:String = LAST_ACTION_ATTR_NAME + "At";
		public static const LAST_ACTION_BY_ATTR_NAME:String = LAST_ACTION_ATTR_NAME + "By";
		
		public static const MODIFIED_ACTION:String = "modified";
		public static const PROOFED_ACTION:String = "proofed";
		public static const PROOFREAD_ACTION:String = "proofread";

		public var nodeElement:XML;
		private var _xmlBasedDoc:MDocument
		private var _modified:Boolean = false;		
		
		public function MNode(element:XML, xmlBasedDoc:MDocument)
		{
			this.nodeElement = element;
			this._xmlBasedDoc = xmlBasedDoc;
		}
		
		public function get uid():String {
			return id;
		}
		
		public function set uid(newValue:String):void {
			// we do not allow setting the uid
			throw new Error("Tried to change the uid from " + uid + " to " + newValue);
		}
		
		public function get xmlBasedDoc():MDocument {
			return _xmlBasedDoc == null ? (this as MDocument) : _xmlBasedDoc; 
		}

		public function get id():String
		{
			return this.nodeElement.@id;
		}
		
		public function getPropertyValue(propName:String, defaultValue:String = null):String {
			var attrs:XMLList = nodeElement.attribute(propName);
			if (attrs.length() == 0) {
				return defaultValue;
			}
			else {
				return attrs.toString();
			}
		}
	
		public function setProperty(name:String, value:String, defaultValue:String = null):void {
			this.modified = true;
			XMLUtils.setAttributeValue(nodeElement, name, value);
		}
		
		public function get childNodes():Array
		{
			var result:Array = new Array();
			for each (var childElement:XML in XMLUtils.getChildElements(nodeElement)) {
				var node:MNode = xmlBasedDoc.resolveElement(childElement);
				if (node != null) {
					result.push(node);
				}
			}
			return result;
		}
		
		public function get parent():MNode
		{
			return xmlBasedDoc.resolveElement(nodeElement.parent());
		}
		
		internal function prependChild(childElement:XML):void {
			modified = true;
			var tagElements:XMLList = nodeElement.tag;
			if (tagElements.length() == 0) {
				appendChild(childElement);
			}
			else {
				XMLUtils.insertSiblingAfter(tagElements[tagElements.length() - 1] as XML, childElement);
			}
		}
		
		internal function appendChild(childElement:XML):void {
			modified = true;
			nodeElement.appendChild(childElement);
		}
		
		public function get precedingSibling():MNode
		{
			var precedingElement:XML = XMLUtils.getPrecedingSibling(nodeElement);
			return xmlBasedDoc.resolveElement(precedingElement);
		}
		
		internal function insertSiblingBefore(newSiblingElement:XML):void {
			modified = true;
			XMLUtils.insertSiblingBefore(nodeElement, newSiblingElement);
		}
		
		public function get followingSibling():MNode
		{
			var followingElement:XML = XMLUtils.getFollowingSibling(nodeElement);
			return xmlBasedDoc.resolveElement(followingElement);
		}
		
		internal function insertSiblingAfter(newSiblingElement:XML):void {
			modified = true;
			XMLUtils.insertSiblingAfter(nodeElement, newSiblingElement);
		}
		
		public function get document():MDocument {
			return MUtils.getDocument(this);
		}
		
		[Bindable]
		public function set modified(value:Boolean):void {
			_modified = value;
			if (value) {
				// true - so also set the document
				var document:MDocument = document;
				if (document != null && document != this) {
					document.modified = true;
				}
			}
			else {
				// false is filtered down
				for each (var child:MNode in childNodes) {
					child.modified = false;
				}
			}
		}
		
		public function get modified():Boolean {
			return _modified;
		}
		
		public function remove():void {
			// may have been removed already from underlying structure
			if (parent != null) {
				parent.modified = true;
				XMLUtils.removeElement(nodeElement);
			}
			xmlBasedDoc.idToNodeMap.remove(id);
		}
		
		public function toString():String {
			return nodeElement.toXMLString();
		}
	}
}