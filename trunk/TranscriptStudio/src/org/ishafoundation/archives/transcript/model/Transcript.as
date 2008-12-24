package org.ishafoundation.archives.transcript.model
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	
	import name.carter.mark.flex.project.mdoc.MDocument;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MSuperNode;
	import name.carter.mark.flex.project.mdoc.MSuperNodeProperties;
	
	public class Transcript
	{
		[Bindable]
		public var referenceMgr:ReferenceManager;
		
		[Bindable]
		public var mdoc:MDocument;
		
		private var committedMarkupPropsMap:IMap = new HashMap(); // key is id, value is MarkupAttributes		

		public function Transcript(transcriptXML:XML, referenceMgr:ReferenceManager) {
			this.referenceMgr = referenceMgr;
			this.mdoc = new MDocument(transcriptXML);
			populateCommittedMarkupPropsMap();
		}
		
		internal function populateCommittedMarkupPropsMap():void {
			this.committedMarkupPropsMap.clear();
			populateCommittedMarkupPropsMapInternal(mdoc);
		}
		
		private function populateCommittedMarkupPropsMapInternal(node:MNode):void {
			for each (var child:MNode in node.childNodes) {
				if (child is MSuperNode) {
					var markup:MSuperNode = child as MSuperNode;
					var copyElement:XML = markup.nodeElement.copy();
					var markupProps:MSuperNodeProperties = new MSuperNode(copyElement, null).props;
					this.committedMarkupPropsMap.put(child.id, markupProps);
				}
				populateCommittedMarkupPropsMapInternal(child);
			}
		}
		
		public function getCommittedMarkupProps(markup:MSuperNode):MSuperNodeProperties {
			return this.committedMarkupPropsMap.getValue(markup.id);
		}
		
		public function createMarkupTitle(markupAttrs:MSuperNodeProperties, includeAdditionalConcepts:Boolean):String {
			return createMarkupTitleExternal(markupAttrs, includeAdditionalConcepts, referenceMgr);
		}
		
		public static function createMarkupTitleExternal(markupAttrs:MSuperNodeProperties, includeAdditionalConcepts:Boolean, referenceMgr:ReferenceManager):String {
			if (markupAttrs == null) {
				return "NULL MARKUP ATTRIBUTES";
			}
			var result:String = referenceMgr.getCategoryTypeNameFromId(markupAttrs.markupTypeId);
			if (markupAttrs.markupCategoryId != null) {
				result += ": " + referenceMgr.getCategoryName(markupAttrs.markupCategoryId);
				var catTags:Array = referenceMgr.getConceptsForCategoryId(markupAttrs.markupCategoryId);
				if (catTags.length > 0) {
					result += " [" + catTags.join(' ') + "]";
				}
			}
			else if (markupAttrs.markupCategorySuggestion != "") {
				result += ": #" + markupAttrs.markupCategorySuggestion;
			}
			else {
				// this is uncategorized
			}
			if (includeAdditionalConcepts && markupAttrs.additionalConcepts.length > 0) {
				result += " +[" + markupAttrs.additionalConcepts.join(' ') + "]";
			}
			return result;
		}
	}
}