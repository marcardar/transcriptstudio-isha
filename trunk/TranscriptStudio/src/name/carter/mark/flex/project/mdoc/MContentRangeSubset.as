package name.carter.mark.flex.project.mdoc
{
	import mx.utils.StringUtil;
	
	public class MContentRangeSubset
	{
		public var spanningContentRange:MContentRange;
		public var startOffsetRelativeToFirstContent:int;
		private var _endOffsetRelativeToLastContent:int;
		
		public function MContentRangeSubset(contentRange:MContentRange, startOffset:int = 0, endOffset:int = -1) {
			if (contentRange == null) {
				throw new ArgumentError("Passed a null contentRange");				
			}
			if (startOffset < 0) {
				throw new ArgumentError("Passed a negative startOffset");				
			}
			this.spanningContentRange = contentRange;
			this.startOffsetRelativeToFirstContent = startOffset;
			this._endOffsetRelativeToLastContent = endOffset;
		}
		
		public function get endOffsetRelativeToLastContent():int {
			if (_endOffsetRelativeToLastContent < 0) {
				return spanningContentRange.last.text.length;							
			}
			else {
				return _endOffsetRelativeToLastContent;
			}
		}
		
		// relative to the start of the segment
		public function get startOffsetRelativeToSegment():int {
			return spanningContentRange.toSegmentSubset().startOffsetRelativeToSegment + startOffsetRelativeToFirstContent;
		}
		
		// relative to the start of the segment
		public function get endOffsetRelativeToSegment():int {
			// no good using the end offset of the content range, because our endoffset is relative to start of last content
			var rangeForLastContent:MContentRange = MContentRange.createSingleContentInstance(spanningContentRange.last);
			return rangeForLastContent.toSegmentSubset().startOffsetRelativeToSegment + endOffsetRelativeToLastContent;
		}
			
		public function toSegmentSubset():MSegmentSubset {
			if (!spanningContentRange.isWithinSingleSegment()) {
				throw new Error("spanningContentRange not within single segment");
			}
			var segment:MSegment = spanningContentRange.getSpanningSegment();
			return new MSegmentSubset(segment, startOffsetRelativeToSegment, endOffsetRelativeToSegment);
		}
		
		public function isWholeSegment():Boolean {
			return spanningContentRange.isWholeSegment() && isWholeContentRange();
		}
		
		public function isWholeContentRange():Boolean {
			return startOffsetRelativeToFirstContent == 0 && endOffsetRelativeToLastContent >= spanningContentRange.last.text.length;
		}
		
		/**
		 * Only returns the inline element if it is exactly the same
		 */
		public function toSuperContent():MSuperContent {
			if (isWholeContentRange()) {
				return spanningContentRange.toSuperContent();
			}
			else {
				return null;
			}
		}
		
		public function getText():String {
			return toSegmentSubset().getText();
		}

		public function expandAccordingToSuperContents():void {
			// the selection needs to be on the same level
			spanningContentRange.expandAccordingToHierarchy();
			var ancestorSiblings:Array = MUtils.getCorrespondingAncestorSiblings(spanningContentRange.first, spanningContentRange.last);
			if (ancestorSiblings[0] is MSuperContent) {
				// we cannot split the inline
				startOffsetRelativeToFirstContent = 0;
			}
			else {
				// so the first node is a content - this would not have been
				// a result of expansion since only inlines can cause expansion - so nothing to do
			}
			if (ancestorSiblings[ancestorSiblings.length - 1] is MSuperContent) {
				_endOffsetRelativeToLastContent = -1;
			}
		}
		
		/**
		 * Breaks up the contentRange so that this segment subset has startOffset == 0 and endOffset equal to
		 * the length of the final content. The first and last vars are adjusted accordingly
		 */
		public function breakContentRange():MContentRange {		
			var mdoc:MDocument = spanningContentRange.first.document;
			var startText:String;
			if (spanningContentRange.isSingleContent()) {
				startText = spanningContentRange.first.text;
				var externalContents:Array = new Array();
				if (startOffsetRelativeToFirstContent > 0) {
					externalContents.push(StringUtil.trim(startText.substring(0, startOffsetRelativeToFirstContent)));
				}
				externalContents.push(StringUtil.trim(startText.substring(startOffsetRelativeToFirstContent, endOffsetRelativeToLastContent)));
				if (endOffsetRelativeToLastContent < startText.length) {
					externalContents.push(StringUtil.trim(startText.substring(endOffsetRelativeToLastContent)));
				}
				var newSingleContentRange:MContentRange = breakContent(spanningContentRange.first, externalContents);
				if (startOffsetRelativeToFirstContent > 0) {
					spanningContentRange.firstNode = newSingleContentRange.nodesInRange[1];
				}
				else {
					spanningContentRange.firstNode = newSingleContentRange.nodesInRange[0];
				}
				if (endOffsetRelativeToLastContent < startText.length) {
					spanningContentRange.lastNode = newSingleContentRange.nodesInRange[newSingleContentRange.nodesInRange.length - 2];
				}
				else {
					spanningContentRange.lastNode = newSingleContentRange.nodesInRange[newSingleContentRange.nodesInRange.length - 1];
				}
			}
			else {
				if (startOffsetRelativeToFirstContent > 0) {
					// need to chop the first node
					startText = spanningContentRange.first.text;
					var beforeStartText:String = startText.substring(0, startOffsetRelativeToFirstContent);
					var insideStartText:String = startText.substring(startOffsetRelativeToFirstContent);
					var newStarMContentRange:MContentRange = breakContent(spanningContentRange.first, [beforeStartText, insideStartText]);
					spanningContentRange.firstNode = newStarMContentRange.last;
				}
				var endText:String = spanningContentRange.last.text;
				if (endOffsetRelativeToLastContent < endText.length) {
					var insideEndText:String = endText.substring(0, endOffsetRelativeToLastContent);
					var afterEndText:String = endText.substring(endOffsetRelativeToLastContent);
					var newEndContentRange:MContentRange = breakContent(spanningContentRange.last, [insideEndText, afterEndText]);
					spanningContentRange.lastNode = newEndContentRange.first;
				}
			}
			startOffsetRelativeToFirstContent = 0;
			_endOffsetRelativeToLastContent = -1;
			return spanningContentRange;
		}

		private function breakContent(oldContent:MContent, newExternalContents:Array):MContentRange {
			var mdoc:MDocument = spanningContentRange.first.document as MDocument;
			var oldElement:XML = (oldContent as MNode).nodeElement;
			var newElements:XMLList = new XMLList();
			for (var i:int = 0; i < newExternalContents.length; i++) {
				var newExternalContent:String = newExternalContents[i];
				var newElement:XML = mdoc.createContentElement(oldElement);
				newElements += newElement;
				if (i > 0) {
					delete newElement.@startSyncPointId;
				}
				if (i < newExternalContents.length - 1) {
					delete newElement.@endSyncPointId;
				}
				newElement.appendChild(newExternalContent);
			}
			return oldContent.breakContent(newElements);
		}
		
		/**
		 * Merges the preceding content of the first content if the properties are the same (and they are siblings). 
		 * Also merges the following content of the last content if the properties are the same (and they are siblings).
		 * 
		 * returns true iff at least one content was merged.
		 */
		public function mergeWithNeighbouringContents():Boolean {
			var result:Boolean = false;
			var firstContent:MContent = spanningContentRange.first;
			var lastContent:MContent = spanningContentRange.last;
			var prependedText:String = firstContent.mergePrecedingContentIfNecessary();
			if (prependedText != null) {
				startOffsetRelativeToFirstContent += prependedText.length;
				if (firstContent == lastContent && _endOffsetRelativeToLastContent >= 0) {
					// also need to adjust the end offset
					_endOffsetRelativeToLastContent += prependedText.length;
				}
				result = true;
			}
			var originalEndOffsetRelativeToLastContent:int = endOffsetRelativeToLastContent;
			var appendedText:String = lastContent.mergeFollowingContentIfNecessary();
			if (appendedText != null) {
				if (_endOffsetRelativeToLastContent < 0) {
					// no longer at end of text
					_endOffsetRelativeToLastContent = originalEndOffsetRelativeToLastContent;
				}
				result = true;
			}
			return result;
		}
		
		public function mergeContentsWhereNecessary():void {
			for each (var content:MContent in spanningContentRange.nodesInRange) {
				var prependedText:String = content.mergePrecedingContentIfNecessary();
				if (prependedText != null) {
					if (content == this.spanningContentRange.first) {
						// just merged the preceding to the first
						startOffsetRelativeToFirstContent += prependedText.length;
					}
					else if (this.spanningContentRange.first.parent == null) {
						// old first was merged into next
						this.spanningContentRange.firstNode = content;
					}
					if (content == this.spanningContentRange.last) {
						_endOffsetRelativeToLastContent += prependedText.length;
					}
				}
			}
			var appendedText:String = spanningContentRange.last.mergeFollowingContentIfNecessary();
			if (appendedText != null) {
				_endOffsetRelativeToLastContent = endOffsetRelativeToLastContent; // this makes sure that we are not using "-1"
			}			
		}
		
		public function allowRemove():Boolean {
			if (!spanningContentRange.allAtSameLevel()) {
				// cannot delete when content range not at same level (inlines involved)
				return false;
			}
			// we can edit it - but be careful we don't leave an empty inline or segment
			// because we can edit it we can assume contentRange is on same level.
			if (!isWholeContentRange()) {
				// there will be something left in the content range
				return true;
			}
			else {
				// the whole content range so check if we can remove the whole content range
				return spanningContentRange.allowRemove();
			}
		}
		
		public function toString():String {
			return "content range subset (first id: " + spanningContentRange.firstNode.id.toString() + ", last id: " + spanningContentRange.last.id + "): " + getText().substring(0, 20) + "..." + getText().substring(getText().length - 20); 
		}
	}
}