/*
   Transcript Studio for Isha Foundation: An XML based application that allows users to define 
   and store contextual metadata for contiguous sections within a text document. 

   Copyright 2008 Mark Carter, Swami Kevala

   This file is part of Transcript Studio for Isha Foundation.

   Transcript Studio for Isha Foundation is free software: you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free Software 
   Foundation, either version 3 of the License, or (at your option) any later version.

   Transcript Studio for Isha Foundation is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with 
   Transcript Studio for Isha Foundation. If not, see http://www.gnu.org/licenses/.
*/

package name.carter.mark.flex.project.mdoc
{
	public class MSegmentSubset
	{
		public var segment:MSegment;
		public var startOffsetRelativeToSegment:int;
		private var _endOffsetRelativeToSegment:int;
		
		/**
		 * negative endOffset indicates the end of the final content in the content range.
		 * 
		 * However, endOffset as returned by the getter is always non-negative.
		 */
		public function MSegmentSubset(segment:MSegment, startOffset:int = 0, endOffset:int = -1) {
			if (segment == null) {
				throw new ArgumentError("Passed a null segment");				
			}
			if (startOffset < 0) {
				throw new ArgumentError("Passed a negative startOffset");				
			}
			this.segment = segment;
			this.startOffsetRelativeToSegment = startOffset;
			this._endOffsetRelativeToSegment = endOffset;
		}
		
		public function toContentRangeSubset():MContentRangeSubset {
			var offset:int = 0;
			var startOffset:int = -1;
			var endOffset:int = -2; // so as not to be confused with valid -1
			var firstContent:MContent = null;
			var lastContent:MContent = null;
			for each (var content:MContent in segment.toContentRange().nodesInRange) {
				var contentStartOffset:int = offset;
				var contentEndOffset:int = offset + content.text.length;
				if (firstContent == null && startOffsetRelativeToSegment < contentEndOffset) {
					firstContent = content;
					startOffset = startOffsetRelativeToSegment - contentStartOffset;
				}
				if (lastContent == null) {
					if (endOffsetRelativeToSegment == contentEndOffset) {
						lastContent = content;
						endOffset = -1;
						break;
					}
					else if (endOffsetRelativeToSegment < contentEndOffset) {
						lastContent = content;
						endOffset = endOffsetRelativeToSegment - contentStartOffset;
						break;
					}
				}
				offset = contentEndOffset + 1; // for the space
			}
			return new MContentRangeSubset(new MContentRange(firstContent, lastContent), startOffset, endOffset);
		}
		
		public function get endOffsetRelativeToSegment():int {
			if (_endOffsetRelativeToSegment < 0) {
				return getSegmentText(segment).length;
			}
			else {
				return _endOffsetRelativeToSegment;
			}
		}
		
		public function isWholeSegment():Boolean {
			if (startOffsetRelativeToSegment > 0) {
				return false;
			}
			if (_endOffsetRelativeToSegment < 0) {
				return true;
			}
			return _endOffsetRelativeToSegment >= getSegmentText(segment).length;
		}
		
		public function getText():String {
			return getSegmentText(segment).substring(startOffsetRelativeToSegment, endOffsetRelativeToSegment);
		}
		
		public static function getSegmentText(segment:MSegment):String {
			var result:String = "";
			for each (var content:MContent in segment.toContentRange().nodesInRange) {
				if (result.length > 0) {
					result += " ";
				}
				result += content.text;
			}
			return result;			
		}

		/**
		 *  TODO: REFACTOR
		 */
		public function createSuperContent():MSuperContent {
			toContentRangeSubset().breakContentRange();
			var inline:MSuperContent = segment.document.createSuperContent(spanningContentRange);
			inline.props.markupTypeId = "quote";
			return inline;
		}
		
		public function allowEditText():Boolean {
			// TODO: do we really want this? - would lose all formatting...
			return spanningContentRange.allAtSameLevel();
		}

		public function editText(newText:String):MSegmentSubset {
			if (!allowEditText()) {
				throw new Error("Not allowed to edit this segment subset: " + this);
			}
			if (getText() == newText) {
				return null;
			}
			var crs:MContentRangeSubset = toContentRangeSubset();
			crs.breakContentRange();
			var affectedContent:MContent = crs.spanningContentRange.editText(newText);
			var result:MSegmentSubset = affectedContent.toSegmentSubset();
			crs.mergeWithNeighbouringContents();
			return result;
		}

		public function allowRemove():Boolean {
			return toContentRangeSubset().allowRemove();
		}
		
		public function deleteText():void {
			if (!allowRemove()) {
				throw new Error("Not allowed to delete this segment subset: " + this);
			}
			var parent:MNode = spanningContentRange.first.parent;
			toContentRangeSubset().breakContentRange();
			var followingNode:MNode = spanningContentRange.last.followingSibling;
			spanningContentRange.remove();
			if (followingNode is MContent) {
				(followingNode as MContent).mergePrecedingContentIfNecessary();
			}
		}
		
		public function expandAccordingToSuperContents():void {
			var crs:MContentRangeSubset = toContentRangeSubset();
			crs.expandAccordingToSuperContents();
			this.startOffsetRelativeToSegment = crs.startOffsetRelativeToSegment;
			this._endOffsetRelativeToSegment = crs.endOffsetRelativeToSegment;
		}
		
		public function get spanningContentRange():MContentRange {
			return toContentRangeSubset().spanningContentRange; 
		}
		
		public function toString():String {
			return "selected segment subset (segment id: " + segment.id.toString() + "): " + getText().substring(0, 20) + "..." + getText().substring(getText().length - 20); 
		}
	}
}