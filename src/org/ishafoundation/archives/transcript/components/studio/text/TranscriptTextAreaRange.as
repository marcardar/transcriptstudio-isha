/*

   Transcript Markups Editor: An XML based application that allows users to define 
   and store contextual metadata for contiguous sections within a text document. 

   Copyright 2008 Mark Carter, Swami Kevala

   This file is part of Transcript Markups Editor.

   Transcript Markups Editor is free software: you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free Software 
   Foundation, either version 3 of the License, or (at your option) any later version.

   Transcript Markups Editor is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with 
   Transcript Markups Editor. If not, see http://www.gnu.org/licenses/.

*/

package org.ishafoundation.archives.transcript.components.studio.text
{
	import name.carter.mark.flex.project.mdoc.MSuperContent;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.project.mdoc.MSuperSegment;
	import name.carter.mark.flex.project.mdoc.MSegment;
	import name.carter.mark.flex.project.mdoc.MUtils;
	
	/*
	An instance of this class says that from the char immediately after beginIndex to the char immediately
	before endIndex, every char has the properties described by ttaChar;
	*/
	public class TranscriptTextAreaRange
	{
		public var beginIndex:int;
		public var endIndex:int;
		// the corresponding element in the transcript XML
		// 1. For the header - outline element
		// 2. For text in a paragraph (whether in an inline or not) - text node element
		public var node:MNode; 
		private var header:Boolean;
		
		public function TranscriptTextAreaRange(beginIndex:int, endIndex:int, node:MNode, header:Boolean) {
			this.beginIndex = beginIndex;
			this.endIndex = endIndex;
			this.node = node;
			this.header = header;
		}
		
		public function isHeader():Boolean {
			return header;
		}
		
		public function getSurroundingSegmentElement():MSegment {
			if (isHeader()) {
				return null;
			}
			return MUtils.getAncestorOrSelfNode(node, MSegment) as MSegment;
		}
		
		/**
		 * Returns the surrounding inlineElement (if any). If more than one inline surrounds it then
		 * the nearest one is returned
		 */
		public function getSurroundingInlineElement():MSuperContent {
			return MUtils.getAncestorOrSelfNode(node, MSuperContent) as MSuperContent;
		}
		
		public function getSurroundingOutlineElement():MSuperSegment {
			return MUtils.getAncestorOrSelfNode(node, MSuperSegment) as MSuperSegment;
		}
		
		public function isDescendantOrSelfOf(ancestorNodeId:String):Boolean {
			var currentNode:MNode = node;
			while (currentNode != null) {
				if (currentNode.id == ancestorNodeId) {
					return true;
				}
				currentNode = currentNode.parent;
			}
			return false;
		}
		
		public function toString():String {
			var result:String = "[" + beginIndex + "-" + endIndex + "]#";
			if (isHeader()) {
				result += "header:" + node.id;
			}
			else if (getSurroundingInlineElement() != null) {
				result += "inline:" + getSurroundingInlineElement().id;// + "-" + node.toString();
			}
			else {
				result += "block:" + getSurroundingSegmentElement().id;// + "-" + node.toString();				
			}
			return result;
		}
	}
}