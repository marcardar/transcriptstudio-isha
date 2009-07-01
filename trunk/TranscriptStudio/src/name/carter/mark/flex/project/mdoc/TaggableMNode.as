package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;
	
	public class TaggableMNode extends MNode
	{
		public function TaggableMNode(element:XML, xmlBasedDoc:MDocument)
		{
			super(element, xmlBasedDoc);
		}
		
		/*public function get tags():Array
		{
			var result:Array = new Array();
			for each (var tagElement:XML in nodeElement.tag) {
				var tag:XMLBasedMTag = new XMLBasedMTag(tagElement);
				result.push(tag);
			}
			return result;
		}*/
		
		/**
		 * returns an array of string values.
		 */
		internal function getTags(tagType:String = null):Array {
			var result:Array = new Array();
			for each (var tagElement:XML in nodeElement.tag) {
				var tag:MTag = new XMLBasedMTag(tagElement);
				if (tagType == null || tag.type == tagType) {
					result.push(tag);
				}
			}
			return result;
		}
		
		internal function getTagValues(tagType:String):Array {
			var tags:Array = getTags(tagType);
			return tags.map(function(tag:MTag, index:int, array:Array):String {
				return tag.value;
			});
		}
		
		internal function addTag(tagType:String, value:String):XMLBasedMTag {
			modified = true;
			var result:XMLBasedMTag = XMLBasedMTag.addNewTag(this, tagType, value);
			return result;
		}
		
		public function removeAllTags(type:String = null):void {
			modified = true;
			for each (var tag:MTag in getTags(type)) {
				tag.remove();
			}
		}
		
		public function removeAllNotesAndSummaries():void {
			modified = true;
			XMLUtils.removeAllElements(nodeElement.*.(localName() == MSuperNodeProperties.NOTES_PROP_NAME || localName() == MSuperNodeProperties.SUMMARY_PROP_NAME));
		}
		
	}
}