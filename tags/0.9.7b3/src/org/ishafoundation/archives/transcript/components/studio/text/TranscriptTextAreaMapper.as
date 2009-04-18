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
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.TaggableMNode;
	
	internal class TranscriptTextAreaMapper
	{
		public var characterRangeArray:Array = new Array();
		public var currentTextAreaIndex:int = 0;

		public function TranscriptTextAreaMapper()	{
		}

		public function addedMarkupHeading(node:TaggableMNode, length:int):void {
			var beginTextAreaIndex:int = currentTextAreaIndex;
			currentTextAreaIndex += length; 
			var ttaCharRange:TranscriptTextAreaRange = new TranscriptTextAreaRange(beginTextAreaIndex, currentTextAreaIndex, node, true);
			characterRangeArray.push(ttaCharRange);			
		}
		
		public function addedText(content:MContent):void {
			var beginTextAreaIndex:int = currentTextAreaIndex;
			currentTextAreaIndex += (content.text as String).length; 
			var ttaCharRange:TranscriptTextAreaRange = new TranscriptTextAreaRange(beginTextAreaIndex, currentTextAreaIndex, content, false);
			characterRangeArray.push(ttaCharRange);						
		} 
		
		public function addedGap(length:int):void {
			currentTextAreaIndex += length;
		}
	}
}