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

package org.ishafoundation.archives.transcript.components.studio.collection
{
	import mx.binding.utils.BindingUtils;
	import mx.containers.HDividedBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	
	import org.ishafoundation.archives.transcript.fs.Collection;

	public class TranscriptChooser extends HDividedBox
	{
		private var collectionHierarchyXML:XML;
		
       	[Bindable]
       	public var selectedTranscriptTextPath:String;
       	[Bindable]
       	public var selectedTranscriptId:String;
		
		// child components
		public var collectionChooser:CollectionChooserTree;
		public var collectionContentsDataGrid:DataGrid;
		
		public function TranscriptChooser()
		{
			super();
			
			this.collectionChooser = new CollectionChooserTree();
			this.collectionChooser.percentWidth = 50;
			this.collectionChooser.percentHeight = 100;
			this.collectionChooser.addEventListener(CollectionChooserTree.SELECTED_COLLECTION_PATH_CHANGED, collectionSelectionChanged);
			this.addChild(this.collectionChooser);

			// still create the datagrid but dont show it - easier this way			
			//this.collectionContentsDataGrid = createDataGrid();
			//this.addChild(this.collectionContentsDataGrid);
		}
		
		private function createDataGrid():DataGrid {
			var result:DataGrid = new DataGrid();
			result.enabled = false;
			result.percentWidth = 50;
			result.percentHeight = 100;
			result.doubleClickEnabled = true;
			var dg1:DataGridColumn = new DataGridColumn();
			dg1.headerText = "Name";
			dg1.dataField = "@id";
			result.columns = new Array(dg1);
		
			BindingUtils.bindSetter(transcriptSelectionChanged, result, "selectedItem");			
			return result;
		}
		
		public function setDataProviders(rootCollection:Collection):void {
			//this.collectionHierarchyXML = collectionHierarchyXML;
			this.collectionChooser.dataProvider = rootCollection;			
		}
		
		private function collectionSelectionChanged(event:Event):void {
			var selectedCollectionPath:String = collectionChooser.selectedCollectionPath;
			//this.collectionContentsDataGrid.enabled = selectedCollectionPath != null;
			//this.collectionContentsDataGrid.dataProvider = collectionHierarchyXML..collection.(@id == selectedCollectionPath).transcript;
		}
		
		private function transcriptSelectionChanged(selectedTranscript:XML):void {
			if (selectedTranscript == null) {
				this.selectedTranscriptTextPath = null;
				this.selectedTranscriptId = null;
			}
			else {
				this.selectedTranscriptTextPath = selectedTranscript.@textPath;
				this.selectedTranscriptId = selectedTranscript.@id;				
			}
		}		
	}

}