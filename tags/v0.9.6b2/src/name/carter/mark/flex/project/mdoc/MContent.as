package name.carter.mark.flex.project.mdoc
{
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.XMLUtils;

	public class MContent extends MNode
	{
		public static var TAG_NAME:String = "content";
		public static var ID_PREFIX:String = "c";
		
		private var _props:MContentProperties;
		
		public function MContent(contentElement:XML, xmlBasedDoc:MDocument)
		{
			super(contentElement, xmlBasedDoc);
		}
		
		public function get props():MContentProperties {
			return new MContentProperties(nodeElement);
		}
		
		public function get text():String {
			var result:String = nodeElement.text();
			if (result != StringUtil.trim(result)) {
				new Error("WARNING: text node is not trimmed: '" + result + "'");
			}
			return result;
		}
		
		public function set text(newValue:String):void {
			modified = true;
			XMLUtils.setElementText(nodeElement, StringUtil.trim(newValue));
		}
		
		public function get segment():MSegment {
			return MUtils.getAncestorOrSelfNode(this, MSegment) as MSegment;
		}
		
		public function toSegmentSubset():MSegmentSubset {
			var contentRange:MContentRange = MContentRange.createSingleContentInstance(this);
			return contentRange.toSegmentSubset();
		}

		public function get precedingContent():MContent {
			// go up to the segment
			var segmentContents:Array = segment.toContentRange().nodesInRange;
			var index:int = segmentContents.indexOf(this);
			if (index == 0) {
				// this is the first content in the segment
				var precedingSegment:MSegment = segment.precedingSegment;
				if (precedingSegment == null) {
					return null;
				}
				else {
					return precedingSegment.toContentRange().last;
				}
			}
			else {
				return segmentContents[index - 1];
			}
		}

		public function get followingContent():MContent {
			// go up to the segment
			var segmentContents:Array = segment.toContentRange().nodesInRange;
			var index:int = segmentContents.indexOf(this);
			if (index == segmentContents.length - 1) {
				// this is the last content in the segment
				var followingSegment:MSegment = segment.followingSegment;
				if (followingSegment == null) {
					return null;
				}
				else {
					return followingSegment.toContentRange().first;
				}
			}
			else {
				return segmentContents[index + 1];
			}
		}

		/**
		 * Returns the text prepended to the specified content
		 */
		public function mergePrecedingContentIfNecessary():String {
			if (!(precedingSibling is MContent)) {
				return null;
			}
			var precedingContent:MContent = precedingSibling as MContent;
			if (!this.props.equalsIgnoreSyncPoints(precedingContent.props)) {
				return null;
			}
			// we can merge these two
			parent.modified = true;
			var textToPrepend:String = precedingContent.text + " ";
			text = textToPrepend + text;
			// take the start time from the preceding content
			var startSyncPointId:String = precedingContent.getPropertyValue(MContentProperties.START_ID_PROP_NAME);
			setProperty(MContentProperties.START_ID_PROP_NAME, startSyncPointId);
			precedingContent.remove();
			return textToPrepend;
		}
		
		/**
		 * Returns the text prepended to the specified content
		 */
		public function mergeFollowingContentIfNecessary():String {
			if (!(followingSibling is MContent)) {
				return null;
			}
			var followingContent:MContent = followingSibling as MContent;
			if (!this.props.equalsIgnoreSyncPoints(followingContent.props)) {
				return null;
			}
			// we can merge these two
			parent.modified = true;
			var textToAppend:String = " " + followingContent.text;
			text += textToAppend;
			// take the start time from the folllowing content
			var endSyncPointId:String = followingContent.getPropertyValue(MContentProperties.END_ID_PROP_NAME);
			setProperty(MContentProperties.END_ID_PROP_NAME, endSyncPointId);
			followingContent.remove();
			return textToAppend;
		}
	
		public function breakContent(newElements:XMLList):MContentRange {
			parent.modified = true;
			var thisDocument:MDocument = document; // before we lose the reference to the document
			XMLUtils.replaceElement(nodeElement, newElements);
			var first:MContent = thisDocument.resolveElement(newElements[0]) as MContent;
			var last:MContent = thisDocument.resolveElement(newElements[newElements.length() - 1]) as MContent;
			remove();
			return new MContentRange(first, last);
		}

		//[Bindable] - must not place [Bindable] or method will not be overridden.
		public override function set modified(value:Boolean):void {
			if (value) {
				// make sure that corresponding segment is set to modified
				segment.modified = value;
			}
			// dont need to do anything when cleaing modified
		}
	}
}