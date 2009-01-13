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

package org.ishafoundation.archives.transcript.db
{
	import mx.controls.Alert;
	
	import name.carter.mark.flex.exist.EXistRESTClient;
	import name.carter.mark.flex.exist.EXistXMLRPCClient;
	import name.carter.mark.flex.util.remote.ClientManager;
	
	import org.ishafoundation.archives.transcript.util.IdUtils;
	
	public class DatabaseManagerUsingEXist implements DatabaseManager
	{
		private var remoteMgr:ClientManager;
		private var loggedIn:Boolean = false;
		private var _isSuperUser:Boolean = false;
		
		public function DatabaseManagerUsingEXist(username:String, password:String) {
			trace("Using eXist URL: " + DatabaseConstants.EXIST_URL);
			this.remoteMgr = new ClientManager(DatabaseConstants.EXIST_URL, username, password);
		}

		public function testConnection(successFunction:Function, failureFunction:Function):void {
			// we test the connection by reading the top level collection
			remoteMgr.testConnection(function(response:Object):void {
				loggedIn = true;
				checkForSuperUser();
				successFunction();
			},
			function(msg:String):void {
				loggedIn = false;
				failureFunction("Login failed because: " + msg);
			});
		}
		
		public function retrieveCollection(collectionPath:String, successFunction:Function, failureFunction:Function):void {
			if (!this.loggedIn) {
				throw new Error("Tried to find collection but not logged in");
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).retrieveCollection(collectionPath, function(struct:Object):void {
				var collectionElement:XML = createCollectionElement(struct);
				successFunction(collectionElement);
			}, function(msg:String):void {
				failureFunction("Collection path could not be retrieved because: " + msg);			
			});
		}
		
		public function createCollectionElement(struct:Object):XML {
			var collections:Array = struct.collections as Array;
			collections.sort();
			var documents:Array = struct.documents as Array;
			//documents.sort();
			var collectionPath:String = decodeURIComponent(struct.name);
			var i:int = collectionPath.lastIndexOf("/");
			if (i < 0) {
				throw new Error("Illegal collection path: " + collectionPath);
			}
			var collectionName:String = collectionPath.substring(i + 1); 
			var collectionElement:XML = <collection id={collectionPath} name={collectionName}/>;
			for each (var childCollectionName:String in collections) {
				childCollectionName = decodeURIComponent(childCollectionName);
				var childPath:String = collectionPath + "/" + childCollectionName;
				var childElement:XML = <collection id={childPath} name={childCollectionName}/>
				collectionElement.appendChild(childElement);
			}
			var sessionFilenames:Array = appendNonSessionEntries(documents, collectionElement);
			for each (var eventElement:XML in collectionElement.event) {
				var added:Array = appendSessionEntries(sessionFilenames, eventElement);
				for each (var sessionFilename:String in added) {
					var index:int = sessionFilenames.indexOf(sessionFilename);
					sessionFilenames.splice(index, 1);
				}
			}
			if (sessionFilenames.length > 0) {
				Alert.show("These session files do not have corresponding events: " + sessionFilenames);
			}
			return collectionElement;			
		}
		
		/**
		 * Returns array of session filenames.
		 */
		private static function appendNonSessionEntries(documents:Array, collectionElement:XML):Array {
			var result:Array = [];
			for each (var document:Object in documents) {
				var filename:String = decodeURIComponent(document.name);
				var eventId:String = IdUtils.getEventIdPrefix(filename);
				if (eventId != null) {
					var eventElement:XML = <event id={eventId} name={filename}/>;
					collectionElement.appendChild(eventElement);
					continue;
				}
				var sessionId:String = IdUtils.getSessionIdPrefix(filename);
				if (sessionId != null) {
					result.push(filename);
					continue;
				}
				// this is some other file type
				var otherId:String = collectionElement.@id.toString() + "/" + filename;
				var otherElement:XML = <other id={otherId} name={filename}/>;
				collectionElement.appendChild(otherElement);
			}
			return result;
		}
		
		private static function appendSessionEntries(sessionFilenames:Array, eventElement:XML):Array {
			var eventId:String = eventElement.@id;
			var result:Array = []; // these session filenames are added
			for (var i:int = 0; i < sessionFilenames.length; i++) {
				var sessionFilename:String = sessionFilenames[i];
				var sessionId:String = IdUtils.getSessionIdPrefix(sessionFilename);
				if (sessionId == null) {
					// this is not a session file
					continue;
				}
				var eventIdForSessionId:String = IdUtils.getEventId(sessionId);
				if (eventIdForSessionId == eventId) {
					var sessionElement:XML = <session id={sessionId} name={sessionFilename}/>;
					eventElement.appendChild(sessionElement);
					result.push(sessionFilename);
				}
			}
			return result;
		}

		public function retrieveXML(xmlPath:String, successFunction:Function, failureFunction:Function, ignoreWhitespace:Boolean = true):void {
			if (!this.loggedIn) {
				throw new Error("Tried to retrieve xml but not logged in");
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).retrieveXML(xmlPath, successFunction, failureFunction, ignoreWhitespace);
		}
		
		public function storeXML(xmlPath:String, xml:XML, successFunction:Function, failureFunction:Function):void {
			if (!this.loggedIn) {
				throw new Error("Tried to store collection but not logged in");
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).storeXML(xmlPath, xml, successFunction, failureFunction);
		}
		
		public function query(xQuery:String, args:Array, successFunc:Function, failureFunc:Function):void {
			if (!this.loggedIn) {
				throw new Error("Tried to execute xquery but not logged in");
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).query(xQuery, args, successFunc, failureFunc);			
		}
		
		public function executeStoredXQuery(xQueryFilename:String, params:Object, successFunc:Function, failureFunc:Function):void {
			if (!this.loggedIn) {
				throw new Error("Tried to execute stored xquery but not logged in");
			}
			new EXistRESTClient(remoteMgr.getRESTClient()).executeStoredXQuery(DatabaseConstants.XQUERY_COLLECTION_PATH + "/" + xQueryFilename, params, successFunc, failureFunc);
		}

		[Bindable]
		public function get isSuperUser():Boolean {
			return _isSuperUser;
		}
		
		public function set isSuperUser(value:Boolean):void {
			_isSuperUser = value;
		}

		private function checkForSuperUser():void {
			var thisObj:DatabaseManagerUsingEXist = this;
			query("xmldb:is-admin-user(xmldb:get-current-user())", [], function(xml:XML):void {
				var boolString:String = xml.*.text();
				thisObj.isSuperUser = boolString == "true";
			}, function(msg:String):void {
				Alert.show(msg, "Failed checking for super user");
			});
		}
	}
}