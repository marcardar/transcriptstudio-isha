package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.Utils;
	
	/**
	 * Represents a range of contents within the same segment.
	 */
	public class MContentRange extends MNodeRange
	{
		public function MContentRange(firstContent:MContent, lastContent:MContent) {
			super(firstContent, lastContent, MContent);
		}
		
		public function get first():MContent {
			return firstNode as MContent;
		}
		
		public function get last():MContent {
			return lastNode as MContent;
		}
		
		public function isSingleContent():Boolean {
			return first == last;
		}
		
		public function isWholeSegment():Boolean {
			if (!isWithinSingleSegment()) {
				return false;
			}
			var segmentContents:Array = MUtils.getDescendantsOrSelfByClass(getSpanningSegment(), MContent);
			return segmentContents[0] == first && segmentContents[segmentContents.length - 1] == last;
		}
		
		public function isWithinSingleSegment():Boolean {
			return MUtils.getAncestorOrSelfNode(first, MSegment) == MUtils.getAncestorOrSelfNode(last, MSegment);
		}
		
		public function getSpanningSegment():MSegment {
			if (!isWithinSingleSegment()) {
				return null;
			}
			return MUtils.getAncestorOrSelfNode(first, MSegment) as MSegment;
		}
		
		/**
		 * The inline must correspond exactly to this range, otherwise null is returned
		 */
		public function toSuperContent():MSuperContent {
			var inline:MSuperContent = getSpanningSuperContent();
			if (inline == null) {
				return null;
			}
			if (this.equals(inline.toContentRange())) {
				return inline;
			}
			else {
				return null;
			}
			return inline;
		}
		
		public function toSegmentSubset():MSegmentSubset {
			return new MSegmentSubset(getSpanningSegment(), startOffsetRelativeToSegment, endOffsetRelativeToSegment);
		}

		public function getSpanningSuperContent():MSuperContent {
			var result:MSuperContent = MUtils.getSpanningSuperContent(first, last);
			return result;
		}
		
		// relative to the start of the segment
		public function get startOffsetRelativeToSegment():int {
			return calculateStartOffsetRelativeToSegment(first);
		}
		
		// relative to the start of the segment
		public function get endOffsetRelativeToSegment():int {
			return calculateStartOffsetRelativeToSegment(last) + last.text.length;
		}
			
		private function calculateStartOffsetRelativeToSegment(content:MContent):int {
			var textSoFar:String = "";
			var segment:MSegment = MUtils.getAncestorOrSelfNode(content, MSegment) as MSegment;
			for each (var workingContent:MContent in segment.toContentRange().nodesInRange) {
				if (textSoFar.length > 0) {
					textSoFar += " ";
				}
				if (workingContent == content) {
					return textSoFar.length;
				}
				textSoFar += workingContent.text;
			}
			throw new Error("Unreachable code");
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
				if (first.parent is MSegment) {
					// segment can have one child (content or superContent) no problem
					return true;
				}
				else {
					// parent is an inline - so don't allow it to have just one inline child
					var siblingNodes:Array = first.parent.childNodes;
					// if the first and last are both contents then we will have a segment left,
					// otherwise it will be an outline left (which is not allowed)
					return siblingNodes[0] is MContent && siblingNodes[siblingNodes.length - 1] is MContent; 
				}
			}
			else {
				return true;
			}
		}
		
		/**
		 * Returns the newly edited text segment subset.
		 * 
		 * If the newText was blank then a zero-length segmentSubset (positioned at start of deletion) is returned
		 */		
		public function editText(newText:String):MContent {
			newText = Utils.normalizeSpace(newText); 
			if (newText.length == 0) {
				throw new Error("Passed a blank newText");
			}
			var result:MContent = mergeIntoOne();
			result.text = newText;
			return result;
		}

		public function remove():void {
			if (!allowRemove()) {
				throw new Error("Remove not allowed");
			}
			for each (var content:MContent in nodesInRange) {
				content.remove();
			}
		}
		
		public function toString():String {
			return "selected content range: " + first.id + " to " + last.id; 
		}
		
		public static function createSingleContentInstance(content:MContent):MContentRange {
			return new MContentRange(content, content);
		}
		
		private static function isSameSegment(content1:MContent, content2:MContent):Boolean {
			return MUtils.getSpanningSegment(content1, content2) != null;
		}

		public function mergeWithNeighbouringContents():Boolean {
			return new MContentRangeSubset(this).mergeWithNeighbouringContents();
		}
		
		public function mergeWhereNecessary():void {
			new MContentRangeSubset(this).mergeContentsWhereNecessary();			
		}		

		public function getText():String {
			var result:String = "";
			for each (var content:MContent in nodesInRange) {
				if (result.length > 0) {
					result += " ";
				}
				result += content.text;
			}
			return result;			
		}

		public function mergeIntoOne():MContent {
			first.parent.modified = true;
			first.modified = true;
			// collect the contents' child nodes together
			var newText:String = "";
			for each (var oldContent:MContent in nodesInRange) {
				var oldText:String = oldContent.text;
				if (oldContent == first) {
					newText = oldText;
				}
				else {
					newText += " ";
					newText += oldText;
					oldContent.remove();
				}
			}
			first.text = newText;
			first.props.endSyncPointId = last.props.endSyncPointId; 
			lastNode = first;
			return first;
		}
	}
}