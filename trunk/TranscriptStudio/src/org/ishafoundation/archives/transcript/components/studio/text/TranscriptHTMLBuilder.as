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

package org.ishafoundation.archives.transcript.components.studio.text
{
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.icon.IconUtils;
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MDocument;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MSegment;
	import name.carter.mark.flex.project.mdoc.MSegmentProperties;
	import name.carter.mark.flex.project.mdoc.MSuperContent;
	import name.carter.mark.flex.project.mdoc.MSuperNode;
	import name.carter.mark.flex.project.mdoc.MSuperNodeProperties;
	import name.carter.mark.flex.project.mdoc.MSuperSegment;
	import name.carter.mark.flex.util.Utils;
	
	import org.ishafoundation.archives.transcript.model.Transcript;
	
	internal class TranscriptHTMLBuilder {				
		private static const INDENT_SIZE:int = 50;

		private var iconsEnabled:Boolean;
		public var transcriptHTML:XML;
		private var transcript:Transcript;
		public var transcriptTextAreaMapping:Array;
		private var transcriptTextAreaCharacterMapper:TranscriptTextAreaMapper = new TranscriptTextAreaMapper();

		public function TranscriptHTMLBuilder(transcript:Transcript, iconsEnabled:Boolean) {
			this.transcript = transcript;
			this.iconsEnabled = iconsEnabled;
			this.transcriptHTML = createTranscriptHTML();
			//trace(this.transcriptHTML);
			this.transcriptTextAreaMapping = transcriptTextAreaCharacterMapper.characterRangeArray;
			trace("mapping: " + transcriptTextAreaMapping);
		}
		
		private function get mdoc():MDocument {
			return transcript.mdoc;
		}
		
		private function createTranscriptHTML():XML {
			var result:XML = <body/>;
			if (mdoc == null) {
				return result;
			}
			processOutline(mdoc, result, 0);
			
			return result;
		}
		
		private function processOutline(outlineOrDocumentNode:MNode, targetElement:XML, depth:int):void {
			for each (var childNode:MNode in outlineOrDocumentNode.childNodes) {
				if (childNode is MSuperNode) {
					appendHeadingElements(childNode as MSuperSegment, targetElement, depth);
					processOutline(childNode, targetElement, depth + 1); // this flattens the HTML hierarchy in terms of outlines
				}
				else {
					// insert a gap if the previous sibling is an outline
					// - this will help separate the end of an outline from a following paragraph
					if (childNode.precedingSibling is MSuperNode) {
						targetElement.appendChild(<br/>);
						transcriptTextAreaCharacterMapper.addedGap(1);						
					}
					if (childNode is MSuperSegment) {
						// supersegment without markup info - just show it without a heading or indented
						processOutline(childNode, targetElement, depth);
					}
					else if (childNode is MSegment) {
						// this is a paragraph
						var paragraphElement:XML = createParagraphElement(childNode as MSegment, depth);
						targetElement.appendChild(paragraphElement);
					}
					else {
						throw new Error("Unexpected node type: " + childNode);
					}
				}
			}
		}
		
		private function appendHeadingElements(outline:MSuperSegment, targetElement:XML, depth:int):void {
			var imgElement:XML = null;
			if (iconsEnabled) {
				var iconPath:String = Utils.getIconPath(outline.props.markupTypeId);
				imgElement = IconUtils.createImgElement(iconPath, 24, 24, Utils.DEFAULT_ICON_PATH);
				if (imgElement == null) {
					if (IconUtils.isKnownToBeUnavailable(Utils.DEFAULT_ICON_PATH)) {
						// if the default icon could not be found then there is no hope for the others
						this.iconsEnabled = false;
					}
				}
				else {
					imgElement.@id = outline.id;
					imgElement.@vspace = "-2";
				}
			}
			var leftMargin:int = calculateIndentationIncludingMargin(depth + 1);
			targetElement.appendChild(<br/>);
			transcriptTextAreaCharacterMapper.addedGap(1);
			if (imgElement != null) {
				targetElement.appendChild(<textformat leftmargin={leftMargin - 41}>{imgElement}</textformat>);
			}
			var headingElement:XML = <textformat leftmargin={leftMargin}/>;
			targetElement.appendChild(headingElement);
			var markupProps:MSuperNodeProperties = outline.props;
			var headingText:String = transcript.createMarkupTitle(markupProps, true);
			headingElement.appendChild(<p class="heading" id={outline.id}>{headingText}</p>);
			transcriptTextAreaCharacterMapper.addedMarkupHeading(outline, (imgElement != null ? 1 : 0) + headingText.length);
			targetElement.appendChild(<br/>);
			transcriptTextAreaCharacterMapper.addedGap(1);
			
			transcriptTextAreaCharacterMapper.addedGap(1); // for the closing heading
		}
		
		private function createParagraphElement(segment:MSegment, depth:int):XML {
			// build up a list of all inline marked contents for this paragraph
			var contentId:String = segment.id;
			var result:XML = <p class="paragraph" id={contentId}/>;
			appendSubParagraphElements(segment, result, 0, 0);
			result.appendChild(<br/>);
			transcriptTextAreaCharacterMapper.addedGap(2); // when br followed by paragraph boundary - seems to add 2
			var blockIndent:int = calculateIndentationIncludingMargin(depth);
			result = <textformat blockindent={blockIndent}>{result}</textformat>;
			var segmentElement:XML = (segment as MSegment).nodeElement;
			if (!segmentElement.hasOwnProperty("@speaker")) {
				result = <b>{result}</b>; // would like to change the font to "mono" here but that doesnt work
			}
			else if (segmentElement.@speaker.toString() != MSegmentProperties.SPEAKER_SADHGURU) {
				result = <b>{result}</b>;
			}
			if (segmentElement.hasOwnProperty("@confidential")) {
				//result = <font color="#FF0000">{result}</font>;
				result = <u>{result}</u>;
			}
			return result;
		}
		
		/**
		 * The elements could be children of paragraph or children of inlines (so: text nodes and inlines)
		 */
		private function appendSubParagraphElements(segmentOrInline:MNode, parentElement:XML, currentOffset:int, inlineDepth:int):int {
			for each (var child:MNode in segmentOrInline.childNodes) {
				if (child is MContent) {
					// doesnt need to be changed
					var text:String = (child as MContent).text;
					if (text != StringUtil.trim(text)) {
						throw new Error("text node is not trimmed: '" + text + "'");
					}
					appendText(child as MContent, parentElement);
					currentOffset += text.length + 1; // one for the gap after the text
				}
				else if (child is MSuperContent) {
					// need to convert to a span
					var className:String = "inline" + ((inlineDepth % 3) + 1);
					var spanElement:XML = <span class={className} id={child.id}/>;
					parentElement.appendChild(spanElement);
					currentOffset = appendSubParagraphElements(child, spanElement, currentOffset, inlineDepth + 1);
				}
			}
			return currentOffset;
		}
		
		private function appendText(content:MContent, parentElement:XML):void {
			var contentElement:XML = (content as MContent).nodeElement;
			var text:String = content.text;
			if (StringUtil.trim(text) != text) {
				throw new Error("Text was not already trimmed: " + text);
			}
			if (contentElement.hasOwnProperty("@emphasis")) {
				parentElement = appendChild(parentElement, <i/>);
			}
			if (contentElement.hasOwnProperty("@spokenLanguage")) {
				parentElement = appendChild(parentElement, <font color="#0000FF"/>);
			}
			parentElement.appendChild(text);
			transcriptTextAreaCharacterMapper.addedText(content);
			transcriptTextAreaCharacterMapper.addedGap(1); // this is the space after the text
		}
		
		private static function appendChild(parent:XML, child:XML):XML {
			parent.appendChild(child);
			return child;
		}
		
		private static function calculateIndentationIncludingMargin(depth:int):int {
			return INDENT_SIZE * depth + 7;
		}
		
	}
}
		
