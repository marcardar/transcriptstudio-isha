package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;

	public class MSuperNode extends TaggableMNode
	{
		public static var ID_PREFIX:String = "m";

		public function MSuperNode(element:XML, xmlBasedDoc:MDocument)
		{
			super(element, xmlBasedDoc);
		}
		
		public function get props():MSuperNodeProperties {
			return new MSuperNodeProperties(this);
		}
		
		public override function remove():void {
			// don't remove nested nodes (and their inlines etc)
			parent.modified = true;
			removeAllTags();
			XMLUtils.removeElement(nodeElement, true);
			xmlBasedDoc.idToNodeMap.remove(id);
		}
		
	}
}