package org.ishafoundation.archives.transcript.fs
{
	import mx.controls.Alert;
	
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
	
	import org.ishafoundation.archives.transcript.db.CollectionRetriever;
	import org.ishafoundation.archives.transcript.db.DatabaseConstants;
	
	public class DbFileSystem
	{
		private var collectionRetriever:CollectionRetriever;
		
		private var collectionHierarchyXML:XML;
		
		public function DbFileSystem(rootCollectionPath:String, collectionRetriever:CollectionRetriever, successFunc:Function, failureFunc:Function) {
			this.collectionRetriever = collectionRetriever;
			if (rootCollectionPath == null) {
				rootCollectionPath = DatabaseConstants.ARCHIVES_COLLECTION_PATH;
			}
			refresh(rootCollectionPath, successFunc, failureFunc, true);
		}
		
		public function refresh(collectionPath:String, successFunc:Function, failureFunc:Function, deep:Boolean = false):void {
			retrieveCollectionHierarchy(collectionPath, function(hierarchyXML:XML):void {
				if (collectionHierarchyXML == null || collectionHierarchyXML.@id.toString() == hierarchyXML.@id.toString()) {
					collectionHierarchyXML = hierarchyXML;
				}
				else {
					var existingCollectionElement:XML = collectionHierarchyXML..collection.(@id == hierarchyXML.@id.toString())[0];
					if (existingCollectionElement == null) {
						trace("Could not find collection in original hierarchy, so just replacing whole hierarchy: " + collectionPath);
						collectionHierarchyXML = hierarchyXML;
					}
					else {
						var newElements:XMLList = new XMLList();
						newElements += hierarchyXML;
						XMLUtils.replaceElement(existingCollectionElement, newElements); 
					}
				}
				successFunc();
			}, function(msg:String):void {
				failureFunc(msg);
			}, false);
		}

		private function retrieveCollectionHierarchy(rootCollectionPath:String, successFunction:Function, failureFunction:Function, includeEmptyCollections:Boolean):void {
			new CollectionHierarchyBuilder(collectionRetriever, rootCollectionPath, includeEmptyCollections, successFunction, failureFunction);
		}
				
		public function getName(nodeId:String):String {
			var nodeElement:XML = getNodeElement(nodeId);
			if (nodeElement == null) {
				return null;
			}
			else {
				return nodeElement.@name;
			}
		}
		
		public function getRootCollection():Collection {
			return getCollection(collectionHierarchyXML.@id);
		}
		
		public function getAncestorOrSelfCollection(nodeId:String):Collection {
			var nodeElement:XML = getNodeElement(nodeId);
			if (nodeElement.localName() == "collection") {
				return getCollection(nodeElement.@id);
			}
			else {
				var parent:XML = nodeElement.parent();
				return getAncestorOrSelfCollection(parent.@id);
			}
		}
		
		private function getCollectionElement(collectionId:String):XML {
			return getNodeElementForType(collectionId, "collection");
		}
		
		public function getEventFile(eventId:String):EventFile {
			return new EventFile(eventId, this);
		}
		
		private function getEventElement(eventId:String):XML {
			return getNodeElementForType(eventId, "event");
		}
		
		public function getSessionFile(sessionId:String):SessionFile {
			return new SessionFile(sessionId, this);
		}
		
		private function getSessionElement(sessionId:String):XML {
			return getNodeElementForType(sessionId, "session");
		}
		
		internal function getEventFiles(collectionId:String):Array {
			var collectionElement:XML = getCollectionElement(collectionId);
			if (collectionElement == null) {
				return null;
			}
			var result:Array = [];
			for each (var eventElement:XML in collectionElement.event) {
				var eventFile:EventFile = new EventFile(eventElement.@id, this);
				result.push(eventFile);
			}
			return result;
		}
		
		internal function getOtherFiles(collectionId:String):Array {
			var collectionElement:XML = getCollectionElement(collectionId);
			if (collectionElement == null) {
				return null;
			}
			var result:Array = [];
			for each (var otherElement:XML in collectionElement.other) {
				var otherFile:File = new File(otherElement.@id, this);
				result.push(otherFile);
			}
			return result;
		}
		
		internal function getSessionFiles(eventId:String):Array {
			var eventElement:XML = getEventElement(eventId);
			if (eventElement == null) {
				return null;
			}
			var result:Array = [];
			for each (var sessionElement:XML in eventElement.session) {
				var sessionFile:SessionFile = getSessionFile(sessionElement.@id);
				result.push(sessionFile);
			}
			return result;
		}
		
		public function getPath(nodeId:String):String {
			var nodeElement:XML = getNodeElement(nodeId);
			if (nodeElement == null) {
				return null;
			}
			if (nodeElement.localName() == "collection") {
				// we've been passed a collection so just return the id (which is also the path)
				return nodeId;
			}
			else {
				var collection:Collection = getAncestorOrSelfCollection(nodeId);
				if (collection == null) {
					return null;
				}
				return collection.nodeId + "/" + nodeElement.@name;
			}
		}
		
		internal function getChildCollections(collectionId:String):Array {
			var collectionElement:XML = getCollectionElement(collectionId);
			if (collectionElement == null) {
				return null;
			}
			var result:Array = [];
			for each (var childCollectionElement:XML in collectionElement.collection) {
				var childCollection:Collection = getCollection(childCollectionElement.@id);
				result.push(childCollection);
			}
			return result;			
		}
		
		public function getCollection(collectionId:String):Collection {
			return new Collection(collectionId, this);
		}

		/**
		 * nodeType is "collection", "event", "session" or "other"
		 */
		private function getNodeElementForType(nodeId:String, nodeType:String):XML {
			var nodeElement:XML = getNodeElement(nodeId);
			if (nodeElement == null) {
				return null;
			}
			if (nodeElement.localName() == nodeType) {
				return nodeElement;
			}
			else {
				throw new Error("Passed a " + nodeType + " id but does not represent a " + nodeType +": " + nodeId);
			}
		}
		
		private function getNodeElement(nodeId:String):XML {
			if (collectionHierarchyXML.@id.toString() == nodeId) {
				return collectionHierarchyXML;
			}
			var nodeElements:XMLList = collectionHierarchyXML..*.(@id == nodeId);
			switch (nodeElements.length()) {
				case 0:
					return null;
				case 1:
					return nodeElements[0];
				default:
					Alert.show("Found more than one fsNode with id: " + nodeId);
					return nodeElements[0];
			}
		}
		
		public function getAllEventIds():ISet {
			var result:ISet = new HashSet();
			for each (var eventId:String in collectionHierarchyXML..event.@id) {
				result.add(eventId);
			}
			return result;
		}
		
		public function getAllSessionIds():ISet {
			var result:ISet = new HashSet();
			for each (var sessionId:String in collectionHierarchyXML..session.@id) {
				result.add(sessionId);
			}
			return result;
		}
		
		public function getAllEvents():Array {
			var result:Array = new Array();
			for each (var eventId:String in collectionHierarchyXML..event.@id) {
				var ef:EventFile = getEventFile(eventId);
				result.push(ef);
			}
			return result;			
		}
		
	}
}