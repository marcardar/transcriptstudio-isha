package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.XMLUtils;

	public class MSuperSegment extends MSuperNode implements Nudgeable
	{
		public static var TAG_NAME:String = "superSegment";
		public static var ID_PREFIX:String = "o";

		public function MSuperSegment(element:XML, xmlBasedDoc:MDocument)
		{
			super(element, xmlBasedDoc);
		}
			
		public function toSegmentRange():MSegmentRange {
			var segments:Array = MUtils.getDescendantsOrSelfByClass(this, MSegment);
			if (segments.length == 0) {
				throw new Error("outline has no segments");
			}
			return new MSegmentRange(segments[0], segments[segments.length - 1]);	
		}

		public function allowNudgeUp():Boolean {
			if (!(precedingSibling is MSegment)) {
				return false;
			}
			else {
				return (precedingSibling as MSegment).allowNudgeDown();
			}
		}
		
		public function nudgeUp():void {
			if (!allowNudgeUp()) {
				throw new Error("Nudge up not allowed for: " + id);				
			}
			modified = true;
			parent.modified = true;
			var segmentElement:XML = (precedingSibling as MSegment).nodeElement;
			XMLUtils.removeElement(segmentElement);
			prependChild(segmentElement);
		}
		
		public function allowNudgeDown():Boolean {
			if (!(childNodes[0] is MSegment)) {
				return false;
			}
			else {
				return (childNodes[0] as MSegment).allowNudgeUp();
			}
		}
		
		public function nudgeDown():void {
			if (!allowNudgeDown()) {
				throw new Error("Nudge down not allowed for: " + id);				
			}
			modified = true;
			parent.modified = true;
			var firstSegment:MSegment = childNodes[0] as MSegment;
			XMLUtils.removeElement(firstSegment.nodeElement);
			insertSiblingBefore(firstSegment.nodeElement);
		}
	}
}