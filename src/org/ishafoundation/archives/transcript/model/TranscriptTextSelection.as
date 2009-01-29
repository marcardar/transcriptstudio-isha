package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.project.mdoc.MContentRange;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MSegment;
	import name.carter.mark.flex.project.mdoc.MSegmentRange;
	import name.carter.mark.flex.project.mdoc.MSegmentSubset;
	import name.carter.mark.flex.project.mdoc.MSuperContent;
	import name.carter.mark.flex.project.mdoc.MSuperNode;
	import name.carter.mark.flex.project.mdoc.MSuperSegment;
	import name.carter.mark.flex.project.mdoc.MUtils;
	import name.carter.mark.flex.project.mdoc.Nudgeable;
	
	public class TranscriptTextSelection implements Nudgeable
	{
		// neither, one or other or both can be populated
		public var selectedObj:Object; // SuperSegment (heading), SegmentRange (more than one segment), Segment, SegmentSubset (less than one segment)
		
		/**
		 * Pass either a String (markupId), SegmentRange, Segment, or SegmentSubset
		 */
		public function TranscriptTextSelection(selectedObj:Object)
		{
			if (selectedObj == null) {
				throw new Error("Passed a null selectedObj");
			}
			if (selectedObj is MSuperContent) {
				selectedObj = (selectedObj as MSuperContent).toSegmentSubset();
			}
			
			if (selectedObj is MSuperSegment) {
				this.selectedObj = selectedObj;
			}
			else if (selectedObj is MSegmentRange) {
				var segmentRange:MSegmentRange = selectedObj as MSegmentRange;
				if (segmentRange.isSingleSegment()) {
					this.selectedObj = segmentRange.first;
				}
				else {
					segmentRange.expandAccordingToHierarchy();
					this.selectedObj = segmentRange;
				}
			}
			else if (selectedObj is MSegment) {
				this.selectedObj = selectedObj;
			}
			else if (selectedObj is MSegmentSubset) {
				var segmentSubset:MSegmentSubset = selectedObj as MSegmentSubset;
				if (segmentSubset.isWholeSegment()) {
					this.selectedObj = segmentSubset.segment;
				}
				else {
					segmentSubset.expandAccordingToSuperContents();
					this.selectedObj = segmentSubset;
				}
			}
			else {
				throw new Error("selectedObj invalid type: " + selectedObj);
			}
		}
		
		public static function createSuperNodeInstance(superNode:MSuperNode):TranscriptTextSelection {
			var selectedObj:Object;
			if (superNode is MSuperSegment) {
				selectedObj = superNode;
			}
			else if (superNode is MSuperContent) {
				var range:MContentRange = (superNode as MSuperContent).toContentRange();
				if (range.isWholeSegment()) {
					selectedObj = range.getSpanningSegment();
				}
				else {
					selectedObj = range.toSegmentSubset();
				} 
			}
			else {
				throw new Error("Unknown superNode type: " + superNode);
			}
			var result:TranscriptTextSelection = new TranscriptTextSelection(selectedObj);
			return result;
		}
		
		public function isTextSelected():Boolean {
			return !(selectedObj is MSuperSegment);
		}
		
		public function toSuperNode():MSuperNode {
			if (selectedObj is MSuperSegment) {
				return selectedObj as MSuperNode;
			}			
			else if (selectedObj is MSegmentRange) {
				return (selectedObj as MSegmentRange).toSuperSegment();
			}
			else if (selectedObj is MSegment) {
				// could be an inline or an outline - but since _selectedObj is not an outline
				// lets return the inline, in preference
				var segment:MSegment = selectedObj as MSegment;
				var inline:MSuperContent = segment.toContentRange().toSuperContent();
				if (inline != null) { 
					return inline;
				}
				else {
					// might as well return an outline if one exists
					var outline:MSuperSegment = MSegmentRange.createSingleSegmentInstance(segment).toSuperSegment();
					if (outline != null) {
						return outline;
					}
				}
			}
			else if (selectedObj is MSegmentSubset) {
				return (selectedObj as MSegmentSubset).toContentRangeSubset().toSuperContent();
			}
			return null;
		}
		
		public function toSegmentRange():MSegmentRange {
			if (selectedObj is MSuperSegment) {
				return (selectedObj as MSuperSegment).toSegmentRange();
			}
			else if (selectedObj is MSegmentRange) {
				return selectedObj as MSegmentRange;
			}
			else if (selectedObj is MSegment) {
				return MSegmentRange.createSingleSegmentInstance(selectedObj as MSegment);
			}
			return null;
		}
		
		public function toSegment():MSegment {
			if (selectedObj is MSuperSegment) {
				var segmentRange:MSegmentRange = (selectedObj as MSuperSegment).toSegmentRange();
				if (segmentRange.isSingleSegment()) {
					return segmentRange.first;
				} 
			}
			else if (selectedObj is MSegmentRange) {
				if ((selectedObj as MSegmentRange).isSingleSegment()) {
					return (selectedObj as MSegmentRange).first;
				} 
			}
			else if (selectedObj is MSegment) {
				return selectedObj as MSegment;
			}
			else if (selectedObj is MSegmentSubset) {
				var segmentSubset:MSegmentSubset = selectedObj as MSegmentSubset;
				if (segmentSubset.isWholeSegment()) {
					return segmentSubset.segment;
				}
			}
			return null;
		}
		
		public function toSegmentSubset():MSegmentSubset {
			if (selectedObj is MSegment) {
				return new MSegmentSubset(selectedObj as MSegment);
			}
			else if (selectedObj is MSegmentSubset) {
				return selectedObj as MSegmentSubset;
			}
			return null;
		}
		
		/**
		 * Keep this simple for the moment. Don't let them markup a segment twice.
		 */
		public function allowMarkup():Boolean {
			if (selectedObj is MSuperSegment) {
				// don't really need this check because it would be caught later - but easy to check anyway
				return false;
			}
			else if (selectedObj is MSegment) {
				// can have two markups on a segment - one inline and one outline
				if (toSegmentRange().toSuperSegment() == null) {
					// no outline so default to that
					return true;
				}
				else if (toSegmentSubset().toContentRangeSubset().toSuperContent() == null) {
					return true;
				}
				else {
					// both an inline and outline already exist
					return false;
				}
			}
			else {
				return toSuperNode() == null;
			}
		}
		
		public function markup():MSuperNode {
			if (!allowMarkup()) {
				throw new Error("Tried to call markup() when not allowed");
			}
			if (toSegment() != null) {
				if (toSuperNode() is MSuperSegment) {
					// already has an outline - so make an inline
					return toSegmentSubset().createSuperContent();
				}
				else {
					// doesnt have an outline so make one
					return toSegmentRange().createOutline();
				}
			}
			else if (toSegmentRange() != null) {
				return toSegmentRange().createOutline();
			}
			else if (toSegmentSubset() != null) {
				return toSegmentSubset().createSuperContent();
			}
			else {
				// markup could not be created
				throw new Error("Tried to create a markup where it is not allowed - this should not be possible");
			}
		}

		public function allowRemoveMarkup():Boolean {
			if (selectedObj is MSuperSegment) {
				// heading is selected
				return true;
			}
			else if (toSuperNode() is MSuperContent) {
				// inline is selected
				return true;
			}
			else {
				// so don't allow if contents of outline are selected (but not header)
				return false;
			}
		}
		
		public function allowEditText():Boolean {
			if (selectedObj is MSuperSegment) {
				return false;
			}
			if (selectedObj is MSegment) {
				return (selectedObj as MSegment).allowEditText();
			}
			else if (selectedObj is MSegmentSubset) {
				return (selectedObj as MSegmentSubset).allowEditText();
			}
			else {
				return false;
			}
		}
		
		public function editText(texts:Array):Object {
			if (!allowEditText()) {
				throw new Error("Tried to edit text but not allowed");
			}
			if (texts.length == 0) {
				throw new ArgumentError("Passed an empty texts array");
			}
			if (selectedObj is MSegmentSubset) {
				if (texts.length > 1) {
					throw new Error("Tried to set multiple texts on a segment subset: " + selectedObj);
				}
				var segmentSubset:MSegmentSubset = selectedObj as MSegmentSubset;
				return segmentSubset.editText(texts[0]);
			}
			else if (selectedObj is MSegment) {
				var segment:MSegment = selectedObj as MSegment;
				return segment.editText(texts);
			}
			else {
				// cannot reach this part of the code
				return null;
			}
		}
		
		public function allowMerge():Boolean {
			if (selectedObj is MSegmentRange) {
				return (selectedObj as MSegmentRange).allowMerge();
			}
			else {
				return false;
			}
		}
		
		public function merge():MSegment {
			if (!allowMerge()) {
				throw new Error("Tried to merge but not allowed");
			}
			return (selectedObj as MSegmentRange).mergeIntoOne();
		}

		public function allowDeleteText():Boolean {
			if (selectedObj is MSegment) {
				var segment:MSegment = selectedObj as MSegment;
				if (MUtils.getDescendantsOrSelfByClass(segment, MSuperContent).length > 0) {
					// at least one inline
					return false;
				}
				else {
					var numRemaining:int = segment.parent.childNodes.length - 1;
					if (numRemaining == 0) {
						// this is an only child of a superSegment or document
						return false;
					}
					else if (numRemaining == 1) {
						if (segment.parent is MSuperSegment) {
							// parent is an outline - so make sure we don't leave it with a single outline child
							if (segment.precedingSibling is MSegment || segment.followingSibling is MSegment) {
								return true;
							}
							else {
								return false;
							}
						}
						else {
							return true;
						}
					}
					else {
						return true;
					}
				}
			}
			else if (selectedObj is MSegmentRange) {
				return (selectedObj as MSegmentRange).allowRemove();
			}
			else if (selectedObj is MSegmentSubset) {
				return (selectedObj as MSegmentSubset).allowRemove();
			}
			else {
				return false;
			}
		}
			
		public function deleteText():void {
			if (!allowDeleteText()) {
				throw new Error("Tried to delete text but not allowed");
			}			
			var segmentRange:MSegmentRange = toSegmentRange();
			if (segmentRange != null) {
				segmentRange.remove();
			}
			else {
				var segmentSubset:MSegmentSubset = toSegmentSubset();
				if (segmentSubset != null) {
					segmentSubset.deleteText();
				}
			}
		}
		
		public function toNudgeable():Nudgeable {
			var sn:MSuperNode = toSuperNode();
			if (sn != null) {
				if (sn is MSuperSegment) {
					return sn as MSuperSegment;
				}
				else {
					return null;
				}
			}
			var sr:MSegmentRange = toSegmentRange();
			if (sr != null) {
				return sr;
			}
			var ss:MSegmentSubset = toSegmentSubset();
			if (ss != null) {
				return null;
			}
			throw new Error("I thought this was unreachable");
		}
		
		private function getNudgeUpFunc():Function {
			if (selectedObj is MSuperSegment) {
				// header selected
				var outline:MSuperSegment = selectedObj as MSuperSegment;
				if (outline.precedingSibling is MSegment) {
					var precedingSegment:MSegment = outline.precedingSibling as MSegment;
					if (precedingSegment.allowNudgeDown()) {
						return precedingSegment.nudgeDown;
					}
					else {
						return null;
					}
				}
				else {
					return null;
				}
			}
			var nudgeable:Nudgeable = toNudgeable();
			if (nudgeable != null) {
				if (nudgeable.allowNudgeUp()) {
					return nudgeable.nudgeUp;
				}
				else {
					return null;
				}
			}
			else {
				return null;
			}
		}
		
		private function getNudgeDownFunc():Function {
			if (selectedObj is MSuperSegment) {
				// header selected
				var outline:MSuperSegment = selectedObj as MSuperSegment;
				var firstChild:MNode = outline.childNodes[0];
				if (firstChild is MSegment) {
					if ((firstChild as MSegment).allowNudgeUp()) {
						return (firstChild as MSegment).nudgeUp;
					}
					else {
						return null;
					}
				}
				else {
					return null;
				}
			}
			var nudgeable:Nudgeable = toNudgeable();
			if (nudgeable != null) {
				if (nudgeable.allowNudgeDown()) {
					return nudgeable.nudgeDown;
				}
				else {
					return null;
				}
			}
			else {
				return null;
			}
		}
		
		public function allowNudgeUp():Boolean {
			return getNudgeUpFunc() != null;
		}
		
		public function nudgeUp():void {
			getNudgeUpFunc()();
		}
		
		public function allowNudgeDown():Boolean {
			return getNudgeDownFunc() != null;
		}
		
		public function nudgeDown():void {
			getNudgeDownFunc()();
		}
		
		public function getText():String {
			if (toSegmentRange() != null) {
				return toSegmentRange().getText();
			}
			else if (toSegmentSubset() != null) {
				return toSegmentSubset().getText();
			}
			else {
				return null;
			}
		}
		
		public function toString():String {
			if (toSuperNode() != null) {
				return "id: " + toSuperNode().id;
			}
			else if (selectedObj is MNode) {
				return "id: " + (selectedObj as MNode).id;
			}
			else {
				return selectedObj.toString();
			}
		}
		
		public function equals(obj:Object):Boolean {
			if (obj == this) {
				return true;
			}
			if (!(obj is TranscriptTextSelection)) {
				return false;
			}
			var guest:TranscriptTextSelection = obj as TranscriptTextSelection;
			return selectedObj == guest.selectedObj;
		}
	}
}