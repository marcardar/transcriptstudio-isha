package name.carter.mark.flex.project.mdoc
{
	public class MSegmentRange extends MNodeRange implements Nudgeable
	{
		public function MSegmentRange(firstSegment:MSegment, lastSegment:MSegment) {
			super(firstSegment, lastSegment, MSegment);
		}

		public function get first():MSegment {
			return firstNode as MSegment;
		}
		
		public function get last():MSegment {
			return lastNode as MSegment;
		}
		
		public function isSingleSegment():Boolean {
			return first == last;
		}
		
		/**
		 * The outline must correspond exactly to this range, otherwise null is returned
		 */
		public function toSuperSegment():MSuperSegment {
			var result:MSuperSegment = MUtils.getSpanningSuperSegment(first, last);
			if (result != null) {
				if (!this.equals(result.toSegmentRange())) {
					// does not match exactly
					result = null;
				}
			}
			return result;
		}
		
		public function createOutline(markupTypeId:String = "topic"):MSuperSegment {
			var outline:MSuperSegment = first.document.createSuperSegment(this);
			outline.props.markupTypeId = markupTypeId;
			return outline;
		}
		
		public function allowRemove():Boolean {
			if (!allAtSameLevel()) {
				return false;
			}
			var numRemaining:int = first.parent.childNodes.length - nodesInRange.length;
			if (numRemaining == 0) {
				// there would be nothing left for the parent
				return false;
			}
			else if (numRemaining == 1) {
				var siblingNodes:Array = first.parent.childNodes;
				// if the first and last are both segments then we will have a segment left,
				// otherwise it will be an outline left (which is not allowed)
				return siblingNodes[0] is MSegment && siblingNodes[siblingNodes.length - 1] is MSegment; 
			}
			else {
				return true;
			}
		}
		
		public function remove():void {
			if (!allowRemove()) {
				throw new Error("Remove not allowed");
			}
			for each (var segment:MSegment in nodesInRange) {
				segment.remove();
			}
		}
		
		/**
		 * Can this range be merged into one segment?
		 */
		public function allowMerge():Boolean {
			return !isSingleSegment() && allAtSameLevel();
		}
		
		public function mergeIntoOne():MSegment {
			if (!allowMerge()) {
				throw new Error("Tried to merge but not allowed");
			}
			if (isSingleSegment()) {
				return first;
			}
			first.modified = true;
			first.parent.modified = true;
			// collect the segments' child nodes together
			var mergedChildNodes:Array = new Array();
			for each (var segment:MSegment in nodesInRange) {
				if (segment == first) {
					continue;
				}
				for each (var childNode:MNode in segment.childNodes) {
					first.appendChild(childNode.nodeElement);
				}
				segment.remove();
			}
			lastNode = first
			first.toContentRange().mergeWhereNecessary();
			return first;
		}
		
		public function allowNudgeUp():Boolean {
			return allowNudgeTowards(true);
		}
		
		public function nudgeUp():void {
			if (!allowNudgeUp()) {
				throw new Error("Nudge up not allowed for: " + this);
			}
			for each (var segment:MSegment in nodesInRange) { 
				segment.nudgeUp();
			}
		}
		
		public function allowNudgeDown():Boolean {
			return allowNudgeTowards(false);
		}
		
		/**
		 * towardsSibling is either the preceding sibling of the first segment or the following sibling of the last segment 
		 */
		private function allowNudgeTowards(up:Boolean):Boolean {
			if (!allAtSameLevel()) {
				return false;
			}
			var towardsSibling:MNode = up ? first.precedingSibling : last.followingSibling;
			var numChildNodesRemaining:int = first.parent.childNodes.length - nodesInRange.length; 
			if (towardsSibling == null) {
				// nudging out of an outline
				if (first.parent is MDocument) {
					return false;
				}
				if (numChildNodesRemaining == 0) {
					// the outline would be left empty
					return false;
				}
				else if (numChildNodesRemaining == 1) {
					// make sure its not just left with an outline
					var indexOfChildRemaining:int = up ? first.parent.childNodes.length - 1 : 0;
					return first.parent.childNodes[indexOfChildRemaining] is MSegment;
				}
				else {
					return true;
				}
			}
			else if (towardsSibling is MSegment) {
				// cannot nudge because there is a segment in the way
				return false;
			}
			else if (towardsSibling is MSuperSegment) {
				// nudging into an outline
				if (first.parent is MDocument) {
					// this is a top level - so no problem
					return true;
				}
				else {
					return numChildNodesRemaining > 1; // don't nudge if parent not left with more than the outline
				}
			}
			else {
				throw new Error("Unexpected sibling: " + towardsSibling);
			}			
		}
		
		public function nudgeDown():void {
			if (!allowNudgeDown()) {
				throw new Error("Nudge down not allowed for: " + this);
			}
			var segments:Array = nodesInRange;
			for (var i:int = segments.length - 1; i >= 0; i--) { 
				segments[i].nudgeDown();
			}
		}

		public function getText():String {
			var result:String = "";
			for each (var segment:MSegment in nodesInRange) {
				if (result.length > 0) {
					result += "\n\n";
				}
				result += segment.getText();
			}			
			return result;			
		}	
			
		public function toString():String {
			return "selected segment range: " + first.id + " to " + last.id; 
		}
		
		public static function createSingleSegmentInstance(segment:MSegment):MSegmentRange {
			return new MSegmentRange(segment, segment);
		}
		
		/**
		 * If node is document - return range spanning all segments
		 * If node is outline - return range spanning all segments in outline
		 * If node is segment - return single-segment range for node
		 * If node is inline or content - return single-segment range of segment spanning node
		 */
		public static function createInstanceCorrespondingToNode(node:MNode):MSegmentRange {
			var segments:Array = MUtils.getDescendantsOrSelfByClass(node, MSegment);
			if (segments.length > 0) {
				return new MSegmentRange(segments[0], segments[segments.length - 1]);
			}
			else {
				// no segments below so must be one above
				var segment:MSegment = MUtils.getAncestorOrSelfNode(node, MSegment) as MSegment;
				return createSingleSegmentInstance(segment);
			}
		}
		
		public static function createInstanceCorrespondingToNodes(firstNode:MNode, lastNode:MNode):MSegmentRange {
			var firstRange:MSegmentRange = createInstanceCorrespondingToNode(firstNode);
			var lastRange:MSegmentRange = createInstanceCorrespondingToNode(lastNode);
			return new MSegmentRange(firstRange.first, lastRange.last);
		}
		
	}
}