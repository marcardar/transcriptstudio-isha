package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;
	
	internal class XMLBasedMTag implements MTag
	{
		public var tagElement:XML;
		
		public function XMLBasedMTag(tagElement:XML)
		{
			this.tagElement = tagElement;
		}

		public function get type():String
		{
			return tagElement.@type;
		}
		
		public function get value():String
		{
			return tagElement.@value;
		}
		
		public function remove():void
		{
			XMLUtils.removeElement(tagElement);
		}

		public static function addNewTag(node:TaggableMNode, type:String, value:String):XMLBasedMTag {
			var tagElement:XML = <tag type={type} value={value}/>;
			var existingTagElements:XMLList = node.nodeElement.tag;
			if (existingTagElements.length() == 0) {
				// no existing tags so put it at as the first child
				node.nodeElement.prependChild(tagElement);
			}
			else {
				// put it after the last existing tag element
				XMLUtils.insertSiblingAfter(existingTagElements[existingTagElements.length() - 1], tagElement);
			}
			return new XMLBasedMTag(tagElement);
		}		
	}
}