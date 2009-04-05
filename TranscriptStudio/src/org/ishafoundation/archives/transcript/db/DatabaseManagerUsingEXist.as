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

package org.ishafoundation.archives.transcript.db
{
	import mx.controls.Alert;
	import mx.rpc.http.HTTPService;
	
	import name.carter.mark.flex.exist.EXistRESTClient;
	import name.carter.mark.flex.exist.EXistXMLRPCClient;
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.remote.ClientManager;
	
	import org.ishafoundation.archives.transcript.util.ApplicationUtils;
	import org.ishafoundation.archives.transcript.util.PreferencesSharedObject;
	
	public class DatabaseManagerUsingEXist implements DatabaseManager
	{
		[Bindable]
		public var user:User;
		
		private var remoteMgr:ClientManager;
		private var username:String;
		private var loggedIn:Boolean = false;
		
		public function DatabaseManagerUsingEXist(username:String, password:String) {
			trace("Using eXist URL: " + DatabaseConstants.EXIST_URL);
			this.remoteMgr = new ClientManager(DatabaseConstants.EXIST_URL, username, password);
			this.username = username;
		}

		public function login(successFunction:Function, failureFunction:Function):void {
			// we test the connection by reading the top level collection
			remoteMgr.testConnection(function(response:Object):void {
				loggedIn = true;
				// write db config to the shared object
				PreferencesSharedObject.writeDbURL(DatabaseConstants.EXIST_URL);
				PreferencesSharedObject.writeDbUsername(username);
				
				checkClientVersionAllowed(function():void {
					getUserGroupNames(function(groupNames:Array):void {
						user = new User(username, groupNames);
						successFunction();
					});
				}, failureFunction);
			},
			function(msg:String):void {
				loggedIn = false;
				failureFunction("Login failed because: " + msg);
			});
		}
		
		public function retrieveXML(successFunc:Function, failureFunc:Function, tagName:String = null, id:String = null, collectionPath:String = null):void {
			if (!this.loggedIn) {
				login(function():void {
					retrieveXML(successFunc, failureFunc, tagName, id, collectionPath);
				}, function(msg:String):void {
					failureFunc("Tried to retrieve XML but not connected to database");					
				});
				return;
			}
			var params:Object = {}
			if (tagName != null) {
				params.tagName = tagName;
			}
			if (id != null) {
				params.id = id;
			}
			if (collectionPath != null) {
				params.collectionPath = collectionPath;
			}
			executeStoredXQuery("retrieve-xml-doc.xql", params, function(returnVal:Object):void {
				var returnXML:XML = XMLUtils.convertToXML(returnVal, true);
				if (returnXML == null) {
					successFunc(null);
					return;
				}
				var items:XMLList;
				if (returnXML.localName() == "result") {
					items = returnXML.*;
				}
				else {
					items = new XMLList(returnXML);
				}
				switch (items.length()) {
					case 1:
						successFunc(items[0]);
						break;
					default:
						var msg:String = (items.length() == 0) ? "Could not find" : "More than one"; 
						msg += (tagName == null) ? "" : " " + tagName;
						msg += " xml doc";
						msg += (id == null) ? "" : " with id: " + id;
						if (items.length() > 0) {
							msg + ": ";
							msg += items.attribute('_document-uri').toXMLString();
						}
						failureFunc(msg);
						break;
				}
			}, failureFunc, HTTPService.RESULT_FORMAT_E4X);
		}
		
		public function storeXML(xml:XML, successFunc:Function, failureFunc:Function):void {
			if (!this.loggedIn) {
				login(function():void {
					storeXML(xml, successFunc, failureFunc);
				}, function(msg:String):void {
					failureFunc("Tried to store XML but not connected to database");					
				});
				return;
			}
			//new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).storeXML(xmlPath, xml, successFunction, failureFunction);
			var params:Object = {xmlStr:xml.toXMLString()};
			executeStoredXQuery("store-xml-doc.xql", params, function(id:String):void {
				trace("Successfully stored xml doc: " + id);
				successFunc(id);
			}, failureFunc);
		}
		
		public function query(xQuery:String, args:Array, successFunc:Function, failureFunc:Function):void {
			if (!this.loggedIn) {
				login(function():void {
					query(xQuery, args, successFunc, failureFunc);
				}, function(msg:String):void {
					failureFunc("Tried to execute query but not connected to database");					
				});
				return;
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).query(xQuery, args, successFunc, failureFunc);			
		}
		
		public function executeStoredXQuery(xQueryFilename:String, params:Object, successFunc:Function, failureFunc:Function, resultFormat:String = null):void {
			if (!this.loggedIn) {
				login(function():void {
					executeStoredXQuery(xQueryFilename, params, successFunc, failureFunc);
				}, function(msg:String):void {
					failureFunc("Tried to execute stored query but not connected to database");					
				});
				return;
			}
			new EXistRESTClient(remoteMgr.getRESTClient()).executeStoredXQuery(DatabaseConstants.XQUERY_COLLECTION_PATH + "/" + xQueryFilename, params, successFunc, failureFunc, resultFormat);
		}

		private function checkClientVersionAllowed(successFunc:Function, failureFunc:Function):void {
			var clientVersion:String = ApplicationUtils.getApplicationVersion();
			executeStoredXQuery("check-client-version.xql", {clientVersion:clientVersion}, function(minClientVersion:String):void {
				if (minClientVersion == "") {
					trace("Client version allowed: " + clientVersion);
					successFunc();
				}
				else {
					failureFunc("Client version '" + clientVersion + "' is out of date. Min version required: " + minClientVersion);  
				}
			}, failureFunc);
		}
		
		private function getUserGroupNames(successFunc:Function):void {
			var thisObj:DatabaseManagerUsingEXist = this;
			query("xmldb:get-user-groups(xmldb:get-current-user())", [], function(xml:XML):void {
				var arr:Array = []
				for each (var groupName:String in xml.*) {
					arr.push(groupName);
				}
				arr = Utils.condenseWhitespaceForArray(arr);
				successFunc(arr);
			}, function(msg:String):void {
				Alert.show(msg, "Failed getting user's group names");
				successFunc([]);
			});
		}
	}
}