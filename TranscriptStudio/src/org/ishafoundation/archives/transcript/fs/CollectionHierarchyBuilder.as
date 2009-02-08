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

package org.ishafoundation.archives.transcript.fs
{
	import org.ishafoundation.archives.transcript.db.CollectionRetriever;
	
	internal class CollectionHierarchyBuilder
	{
		private var collectionRetriever:CollectionRetriever;
		
		private var successFunc:Function;
		private var failureFunc:Function;
		
		private var collectionTreeXML:XML;
		
		private var pendingCount:int = 0;
		private var finished:Boolean = false;
		
		public function CollectionHierarchyBuilder(collectionRetriever:CollectionRetriever, rootCollectionPath:String, includeEmptyCollections:Boolean, successFunc:Function, failureFunc:Function) {
			this.collectionRetriever = collectionRetriever;
			this.successFunc = successFunc;
			this.failureFunc = failureFunc;
			this.collectionTreeXML = <collections><collection id={rootCollectionPath} name="transcript"/></collections>;
			readCollection(rootCollectionPath);			
		}
		
		private function readCollection(collectionPath:String):void {
			pendingCount++;
			collectionRetriever.retrieveCollection(collectionPath, function(collectionElement:XML):void {
				if (finished) {
					// don't process anymore
					trace("WARNING: Calling readCollectionSuccess even after finished");
					return;
				}
				pendingCount--;
				var collectionPath:String = collectionElement.@id;
				var existingCollectionElement:XML = collectionTreeXML..collection.(@id == collectionPath)[0];
				// we want to include this collection
				existingCollectionElement.* = collectionElement.*;
				for each (var childCollectionElement:XML in existingCollectionElement.collection) {
					readCollection(childCollectionElement.@id);
				}
				// nothing more to do?
				if (pendingCount == 0) {
					finished = true;
					successFunc(collectionTreeXML.*[0]);
				}
			}, function(msg:String):void {
				finished = true;
				failureFunc(msg);
			});
		}
	}
}