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

package org.ishafoundation.archives.transcript.model
{
	import flash.events.EventDispatcher;
	
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.project.mdoc.MContent;
	import name.carter.mark.flex.project.mdoc.MNode;
	import name.carter.mark.flex.util.XMLUtils;
	
	import org.ishafoundation.archives.transcript.db.*;
	
	public class SessionManager extends EventDispatcher
	{
		private var username:String;
		private var referenceMgr:ReferenceManager;
		private var xmlRetriever:XMLRetriever;
		private var xqueryExecutor:XQueryExecutor;
		
		public function SessionManager(username:String, referenceMgr:ReferenceManager, databaseMgr:DatabaseManager)
		{
			this.username = username;
			this.referenceMgr = referenceMgr;
			this.xmlRetriever = databaseMgr;
			this.xqueryExecutor = databaseMgr;
		}
		
		public function createSession(sessionXML:XML, eventProps:EventProperties, successFunc:Function, failureFunc:Function):void {
			DatabaseManagerUtils.createSession(eventProps.id, sessionXML.metadata[0], xqueryExecutor, function(sessionXML:XML):void {
				var result:Session = new Session(sessionXML, eventProps, referenceMgr);
				result.unsavedChanges = true; // need to save all this stuff
				successFunc(result);
			}, failureFunc);
		} 
		
		public function retrieveSession(sessionId:String, eventProps:EventProperties, externalSuccess:Function, externalFailure:Function):void {
			if (sessionId == null || StringUtil.trim(sessionId).length == 0) {
				throw new Error("Passed a blank sessionId");
			}
			DatabaseManagerUtils.retrieveSessionXML(sessionId, xmlRetriever, function(sessionXML:XML):void {
				trace("Successfully retrieved session");
				var session:Session = openSessionForEvent(sessionXML, eventProps);
				externalSuccess(session);		
			}, function (msg:String):void {
				trace("Could not load session xml because: " + msg);
				externalFailure(msg);			
			});
		}
		
		/**
		 * For when we already have the event props
		 */
		public function openSessionForEvent(sessionXML:XML, eventProps:EventProperties):Session {
			return new Session(sessionXML, eventProps, referenceMgr);
		}
			
		public function updateSessionInDatabase(session:Session, externalSuccess:Function, externalFailure:Function):void {
			if (session.id == null) {
				throw new Error("Tried to store session but either the collection or transcript id was not set");
			}
			setActionAttributes(session);
			DatabaseManagerUtils.updateSession(session.id, session.metadata.metadataElement, session.mediaMetadataElement, session.transcript.mdoc.nodeElement, xqueryExecutor, function(msg:String):void {
				trace("Successfully saved transcript: " + msg);
				session.unsavedChanges = false;
				externalSuccess();
			}, externalFailure);
		}
		
		private function setActionAttributes(session:Session):void {
			var date:Date = new Date();
			//setModifiedAttributesOnElement(session.sessionXML, date, username);
			if (session.transcript != null) {
				setActionAttributesOnNode(session.transcript.mdoc, date);
			}
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