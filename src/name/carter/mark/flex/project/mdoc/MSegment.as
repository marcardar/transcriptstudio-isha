package name.carter.mark.flex.project.mdoc
{
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;

	public class MSegment extends TaggableMNode
	{
		public static var TAG_NAME:String = "segment";
		public static var ID_PREFIX:String = "s";
		
		public function MSegment(segmentElement:XML, xmlBasedDoc:MDocument)
		{
			super(segmentElement, xmlBasedDoc);
		}
		
		public function get props():MSegmentProperties {
			return new MSegmentProperties(nodeElement);
		}
		
		public function get precedingSegment():MSegment {
			var segments:Array = MUtils.getDescendantsOrSelfByClass(document, MSegment);
			var index:int = segments.indexOf(this);
			if (index == 0) {
				// this is the first segment
				return null;
			}
			else {
				return segments[index - 1];
			}
		}
		
		public function get followingSegment():MSegment {
			var segments:Array = MUtils.getDescendantsOrSelfByClass(document, MSegment);
			var index:int = segments.indexOf(this);
			if (index == segments.length - 1) {
				// this is the last segment
				return null;
			}
			else {
				return segments[index + 1];
			}
		}
		
		public function toContentRange():MContentRange {
			var contents:Array = MUtils.getDescendantsOrSelfByClass(this, MContent);
			var contentRange:MContentRange = new MContentRange(contents[0], contents[contents.length - 1]);
			return contentRange;			
		}
		
		public function allowEditText():Boolean {
			var inline:MSuperContent = toContentRange().toSuperContent();
			if (inline != null) {
				// this segment has an inline for all the text
				for each (var childNode:MNode in inline.childNodes) {
					if (MUtils.getDescendantsOrSelfByClass(childNode, MSuperContent).length > 0) {					
						return false;
					}
				}
				// no nested inlines
				return true;
			}
			else {
				return MUtils.getDescendantsOrSelfByClass(this, MSuperContent).length == 0;				
			} 
		}
		
		public function editText(newSegmentTexts:Array):MSegmentRange {
			if (!allowEditText()) {
				throw new Error("Not allowed to edit segment: " + this);
			}
			if (newSegmentTexts.length == 1 && newSegmentTexts[0] == getText()) {
				return null;
			}
			newSegmentTexts = Utils.condenseWhitespaceForArray(newSegmentTexts);
			switch (newSegmentTexts.length) {
				case 0:
					throw new Error("Passed an empty array of new texts");
				case 1:
					var firstContent:MContent = toContentRange().first;
					var firstContentElement:XML = (firstContent as MContent).nodeElement;
					XMLUtils.setElementText(firstContentElement, newSegmentTexts[0]);
					// if the segment is also an inline then remove the children of the inline instead of the children of the segment
					var parentOfNodesToRemove:MNode;
					if (childNodes.length == 1 && childNodes[0] is MSuperContent) {
						parentOfNodesToRemove = childNodes[0] as MNode;
					}
					else {
						parentOfNodesToRemove = this;
					}
					for each (var nodeToRemove:MNode in parentOfNodesToRemove.childNodes) {
						nodeToRemove.remove();
					}
					parentOfNodesToRemove.nodeElement.appendChild(firstContentElement);
					return MSegmentRange.createSingleSegmentInstance(this);
				default:
					return breakSegment(newSegmentTexts);
			}
		}

		private function breakSegment(newSegmentTexts:Array):MSegmentRange {
			var oldContentElement:XML = nodeElement..content[0];
			var newSegmentElements:XMLList = new XMLList();
			for (var i:int = 0; i < newSegmentTexts.length; i++) {
				var newExternalContent:String = newSegmentTexts[i];
				var newSegmentElement:XML = document.createSegmentElement(nodeElement);
				newSegmentElements += newSegmentElement;
				var newContentElement:XML = document.createContentElement(oldContentElement);
				newContentElement.appendChild(newExternalContent);
				if (i > 0) {
					delete newContentElement.@startSyncPointId;
				}
				if (i < newSegmentTexts.length - 1) {
					delete newContentElement.@endSyncPointId;
				}
				newSegmentElement.appendChild(newContentElement);
			}
			parent.modified = true;
			var thisDocument:MDocument = document; // before we lose the reference to the document
			XMLUtils.replaceElement(nodeElement, newSegmentElements);
			var first:MSegment = thisDocument.resolveElement(newSegmentElements[0]) as MSegment;
			var last:MSegment = thisDocument.resolveElement(newSegmentElements[newSegmentElements.length() - 1]) as MSegment;
			remove();
			return new MSegmentRange(first, last);
		}
		
		public function allowNudgeUp():Boolean {
			return MSegmentRange.createSingleSegmentInstance(this).allowNudgeUp();
		}

		public function nudgeUp():void {
			if (!allowNudgeUp()) {
				throw new Error("Nudge up not allowed for: " + id);				
			}
			if (precedingSibling == null) {
				// must be moving it out of its current outline
				var parentOutline:MSuperSegment = parent as MSuperSegment; // grab this reference before its deleted
				parentOutline.modified = true;
				parentOutline.parent.modified = true; // because this is the new parent of the segment
				XMLUtils.removeElement(nodeElement);
				parentOutline.insertSiblingBefore(nodeElement);
			} else if (precedingSibling is MSuperSegment) {
				// move it into the previous outline
				var precedingOutline:MSuperSegment = precedingSibling as MSuperSegment; // grab this reference before its deleted
				parent.modified = true; // moving from this parent...
				precedingOutline.modified = true; // ...to this new parent
				XMLUtils.removeElement(nodeElement);
				precedingOutline.appendChild(nodeElement);
			}
			else {
				throw new Error("Unexpected state");
			}
		}
		
		public function allowNudgeDown():Boolean {
			return MSegmentRange.createSingleSegmentInstance(this).allowNudgeDown();
		}
		
		public function nudgeDown():void {
			if (!allowNudgeDown()) {
				throw new Error("Nudge down not allowed for: " + id);				
			}
			if (followingSibling == null) {
				// must be moving it out of its current outline
				var parentOutline:MSuperSegment = parent as MSuperSegment; // grab this reference before its deleted
				parentOutline.modified = true;
				parentOutline.parent.modified = true; // this is the new parent of the segment
				XMLUtils.removeElement(nodeElement);
				parentOutline.insertSiblingAfter(nodeElement);
			}
			else if (followingSibling is MSuperSegment) {
				// move it into the following outline
				var followingOutline:MSuperSegment = followingSibling as MSuperSegment; // grab this reference before its deleted
				parent.modified = true; // moved from here...
				followingOutline.modified = true; // ... to here
				XMLUtils.removeElement(nodeElement);
				followingOutline.prependChild(nodeElement);
			}
			else {
				throw new Error("Unexpected state");
			}
		}
		
		public function getText():String {
			return toContentRange().getText();
		}
	}
}