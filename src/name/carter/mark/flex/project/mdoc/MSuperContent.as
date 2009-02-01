package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MContentRange;
	import name.carter.mark.flex.project.mdoc.MDocument;
	import name.carter.mark.flex.project.mdoc.MSuperContent;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MUtils;
	import name.carter.mark.flex.project.mdoc.Nudgeable;

	public class MSuperContent extends MSuperNode
	{
		public static var TAG_NAME:String = "superContent";
		public static var ID_PREFIX:String = "i";

		public function MSuperContent(inlineElement:XML, xmlBasedDoc:MDocument)
		{
			super(inlineElement, xmlBasedDoc);
		}

		public function toContentRange():MContentRange {
			var contents:Array = MUtils.getDescendantsOrSelfByClass(this, MContent);
			return new MContentRange(contents[0], contents[contents.length - 1]);
		}
		
		public function toSegmentSubset():MSegmentSubset {
			return toContentRange().toSegmentSubset();
		}
		
		public override function remove():void {
			// should consolidate the sibling contents
			var contentRange:MContentRange = this.toContentRange();
			super.remove();
			// removing an inline may well result in consecutive content nodes - so condense those
			contentRange.mergeWithNeighbouringContents();
		}
	}
}