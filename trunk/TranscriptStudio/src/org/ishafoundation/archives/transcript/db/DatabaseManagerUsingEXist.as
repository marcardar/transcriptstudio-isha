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
	import name.carter.mark.flex.util.XMLUtils;
	import name.carter.mark.flex.util.remote.ClientManager;
	
	import org.ishafoundation.archives.transcript.util.ApplicationUtils;
	import org.ishafoundation.archives.transcript.util.PreferencesSharedObject;
	
	public class DatabaseManagerUsingEXist implements DatabaseManager
	{
		private var remoteMgr:ClientManager;
		private var username:String;
		private var loggedIn:Boolean = false;
		private var _isSuperUser:Boolean = false;
		
		public function DatabaseManagerUsingEXist(username:String, password:String) {
			trace("Using eXist URL: " + DatabaseConstants.EXIST_URL);
			this.remoteMgr = new ClientManager(DatabaseConstants.EXIST_URL, username, password);
			this.username = username;
		}

		public function testConnection(successFunction:Function, failureFunction:Function):void {
			// we test the connection by reading the top level collection
			remoteMgr.testConnection(function(response:Object):void {
				loggedIn = true;
				// write db config to the shared object
				PreferencesSharedObject.writeDbURL(DatabaseConstants.EXIST_URL);
				PreferencesSharedObject.writeDbUsername(username);
				
				checkClientVersionAllowed(function():void {
					checkForSuperUser(successFunction);
				}, failureFunction);
			},
			function(msg:String):void {
				loggedIn = false;
				failureFunction("Login failed because: " + msg);
			});
		}
		
		public function retrieveXML(successFunc:Function, failureFunc:Function, tagName:String, id:String= null, collectionPath:String = null):void {
			if (!this.loggedIn) {
				throw new Error("Tried to retrieve xml but not logged in");
			}
			var params:Object = {tagName:tagName}
			if (id != null) {
				params.id = id;
			}
			if (collectionPath != null) {
				params.collectionPath = collectionPath;
			}
			executeStoredXQuery("retrieve-xml-doc.xql", params, function(returnVal:Object):void {
				var returnXML:XML = XMLUtils.convertToXML(returnVal, true);
				if (returnXML.localName() == tagName) {
					// just one element returned - perfect
					trace("Single result returned when retrieving xml doc");
					successFunc(returnXML);
				}
				else {
					trace("Multiple results returned when retrieving xml doc");
					var results:XMLList = returnXML.*;
					switch (results.length()) {
						case 1:
							successFunc(results[0]);
							break;
						default:
							var msg:String = (results.length() == 0) ? "Could not find" : "More than one"; 
							msg += (tagName == null) ? "" : " " + tagName;
							msg += " xml doc";
							msg += (id == null) ? "" : " with id: " + id;
							msg + ": ";
							msg += results.attribute('_document-uri').toXMLString();
							failureFunc(msg);
							break;
					}
				}
			}, failureFunc, HTTPService.RESULT_FORMAT_E4X);
		}
		
		public function storeXML(xml:XML, successFunc:Function, failureFunc:Function):void {
			if (!this.loggedIn) {
				throw new Error("Tried to store XML but not logged in");
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
				throw new Error("Tried to execute xquery but not logged in");
			}
			new EXistXMLRPCClient(remoteMgr.getXMLRPCClient()).query(xQuery, args, successFunc, failureFunc);			
		}
		
		public function executeStoredXQuery(xQueryFilename:String, params:Object, successFunc:Function, failureFunc:Function, resultFormat:String = null):void {
			if (!this.loggedIn) {
				throw new Error("Tried to execute stored xquery but not logged in");
			}
			new EXistRESTClient(remoteMgr.getRESTClient()).executeStoredXQuery(DatabaseConstants.XQUERY_COLLECTION_PATH + "/" + xQueryFilename, params, successFunc, failureFunc, resultFormat);
		}

		[Bindable]
		public function get isSuperUser():Boolean {
			return _isSuperUser;
		}
		
		public function set isSuperUser(value:Boolean):void {
			_isSuperUser = value;
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
		
		private function checkForSuperUser(successFunc:Function):void {
			var thisObj:DatabaseManagerUsingEXist = this;
			query("xmldb:is-admin-user(xmldb:get-current-user())", [], function(xml:XML):void {
				var boolString:String = xml.*.text();
				thisObj.isSuperUser = boolString == "true";
				successFunc();
			}, function(msg:String):void {
				Alert.show(msg, "Failed checking for super user");
			});
		}
	}
}