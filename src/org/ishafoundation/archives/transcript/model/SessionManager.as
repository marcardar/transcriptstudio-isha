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

package org.ishafoundation.archives.transcript.model
{
	import flash.events.EventDispatcher;
	
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.db.*;
	import org.ishafoundation.archives.transcript.fs.EventFile;
	import org.ishafoundation.archives.transcript.fs.SessionFile;
	
	public class SessionManager extends EventDispatcher
	{
		private var username:String;
		private var referenceMgr:ReferenceManager;
		private var xmlRetrieverStorer:XMLRetrieverStorer;		
		
		public function SessionManager(username:String, referenceMgr:ReferenceManager, xmlRetrieverStorer:XMLRetrieverStorer)
		{
			this.username = username;
			this.referenceMgr = referenceMgr;
			this.xmlRetrieverStorer = xmlRetrieverStorer;
		}
		
		public function createSession(sessionXML:XML, eventFile:EventFile):Session {
			var result:Session = new Session(sessionXML, username, eventFile, referenceMgr);
			result.unsavedChanges = true; // need to save all this stuff			
			return result;
		} 
		
		public function retrieveSession(sessionFile:SessionFile, externalSuccess:Function, externalFailure:Function):void {
			this.xmlRetrieverStorer.retrieveXML(sessionFile.path, function(sessionXML:XML):void {
				trace("Successfully retrieved session");
				var session:Session = new Session(sessionXML, username, sessionFile, referenceMgr);
				externalSuccess(session);
			}, function (msg:String):void {
				trace("Could not load session xml because: " + msg);
				externalFailure(msg);			
			});
		}
			
		public function storeTranscript(session:Session, externalSuccess:Function, externalFailure:Function):void {
			if (session.id == null) {
				throw new Error("Tried to store session but either the collection or transcript id was not set");
			}
			if (session.unsavedChanges) {
				setActionAttributes(session);
				xmlRetrieverStorer.storeXML(session.path, session.sessionXML, function():void {
					trace("Successfully saved transcript");
					if (session.sessionFile == null) {
						session.eventFile.refresh(function():void {
							var sessionFile:SessionFile = session.eventFile.getSessionFileById(session.id);
							if (sessionFile == null) {
								externalFailure("Could not find session file after saving: " + session.path);
								return;
							}
							session.sessionFile = sessionFile;
							session.unsavedChanges = false;
							externalSuccess();
						}, function(msg:String):void {
							externalFailure("Could not refresh filesystem: " + msg);
						});
					}
					else {
						session.unsavedChanges = false;
						externalSuccess();
					}
				}, externalFailure);
			}
			else {
				// nothing needed to be saved, so this was successful!
				externalSuccess();
			}				
		}
		
		private function setActionAttributes(session:Session):void {
			var date:Date = new Date();
			//setModifiedAttributesOnElement(session.sessionXML, date, username);
			setActionAttributesOnNode(session.transcript.mdoc, date);
		}
		
		private function setActionAttributesOnNode(node:MNode, date:Date, deep:Boolean = true):void {
			if (node is MContent) {
				// dont set action attributes on content elements
				return;
			}
			if (username == null) {
				throw new Error("Username has not been set");
			}
			if (XMLUtils.getAttributeValue(node.nodeElement, MNode.LAST_ACTION_ATTR_NAME) == null) {
				// this must be new because last action has not been set
				setModifiedAttributesOnElement(node.nodeElement, date, username);
			}
			else if (node.modified) { // only set modified if not setting created
				setModifiedAttributesOnElement(node.nodeElement, date, username);
			}
			if (deep) {
				for each (var child:MNode in node.childNodes) {
					setActionAttributesOnNode(child, date);
				}
			}
		} 

		public static function setModifiedAttributesOnElement(element:XML, modifiedDate:Date, modifiedBy:String):void {
			XMLUtils.setAttributeValue(element, MNode.LAST_ACTION_ATTR_NAME, MNode.MODIFIED_ACTION);
			XMLUtils.setAttributeAsDate(element, MNode.LAST_ACTION_AT_ATTR_NAME, modifiedDate, true);
			XMLUtils.setAttributeValue(element, MNode.LAST_ACTION_BY_ATTR_NAME, modifiedBy);
		}
	}
}