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
	import org.ishafoundation.archives.transcript.model.ReferenceManager;
	import org.ishafoundation.archives.transcript.util.Utils;
	
	public class DatabaseManagerDemo
	{		
		[Embed("/../samples/reference.xml", mimeType="application/octet-stream")]
		private static const referenceXMLClass:Class;

		[Embed("/../samples/demo1.xml", mimeType="application/octet-stream")]
		private static const demo1XMLClass:Class;

		[Embed("/../samples/demo1_markups.xml", mimeType="application/octet-stream")]
		private static const demo1MarkupsXMLClass:Class;

		[Embed("/../samples/demo2.xml", mimeType="application/octet-stream")]
		private static const demo2XMLClass:Class;

		private var referenceXML:XML = Utils.getXML(referenceXMLClass);
		private var demo1XML:XML = Utils.getXML(demo1XMLClass);
		private var demo1MarkupsXML:XML = Utils.getXML(demo1MarkupsXMLClass);
		private var demo2XML:XML = Utils.getXML(demo2XMLClass);
		private var demo2MarkupsXML:XML = null;

		private var collectionHierarchyXML:XML =
			<collection path={DatabaseConstants.DATA_COLLECTION_PATH}>
				<collection path="/db/ts4isha/data/demo_collection" name="demo_collection">
					<transcript textPath="/db/ts4isha/data/demo_collection/demo1.xml" id="demo1" markupsExist="true"/>
					<transcript textPath="/db/ts4isha/data/demo_collection/demo2.xml" id="demo2" markupsExist="false"/>
				</collection>
			</collection>;

		public function DatabaseManagerDemo() {
		}

		public function retrieveCollection(collectionPath:String, successFunction:Function, failureFunction:Function):void {
			successFunction(null);
		}
		
		public function retrieveCollectionHierarchy(successFunction:Function, failureFunction:Function, includeEmptyCollections:Boolean):void {
			successFunction(this.collectionHierarchyXML.copy());
		}
		
		public function retrieveXML(xmlPath:String, successFunction:Function, failureFunction:Function, ignoreWhitespace:Boolean = true):void {
			//Alert.show("Fetching: " + xmlPath);
			if (xmlPath == ReferenceManager.REFERENCE_XML_PATH) {
				//Alert.show("Fetching reference: " + xmlPath);
				successFunction(this.referenceXML.copy());				
			}
			else if (xmlPath.indexOf("demo1.xml") > 0) {
				successFunction(this.demo1XML.copy());
			}
			else if (xmlPath.indexOf("demo1_markups.xml") > 0) {
				successFunction(this.demo1MarkupsXML.copy());
			}
			else if (xmlPath.indexOf("demo2.xml") > 0) {
				successFunction(this.demo2XML.copy());
			}
			else if (xmlPath.indexOf("demo2_markups.xml") > 0) {
				if (this.demo2MarkupsXML != null) {
					successFunction(this.demo2MarkupsXML.copy());
				}
				else {
					failureFunction("No markups for: " + xmlPath);
				}
			}
			else {
				throw new Error("Nothing known about path: " + xmlPath);
			}
		}
		
		public function storeXML(xmlPath:String, xml:XML, successFunction:Function, failureFunction:Function):void {
			if (xmlPath == ReferenceManager.REFERENCE_XML_PATH) {
				//Alert.show("Fetching reference: " + xmlPath);
				this.referenceXML = xml.copy();
				successFunction();				
			}
			else if (xmlPath.indexOf("demo1.xml") > 0) {
				this.demo1XML = xml.copy();
				successFunction();
			}
			else if (xmlPath.indexOf("demo1_markups.xml") > 0) {
				this.demo1MarkupsXML = xml.copy();
				successFunction();
			}
			else if (xmlPath.indexOf("demo2.xml") > 0) {
				this.demo2XML = xml.copy();
				successFunction();
			}
			else if (xmlPath.indexOf("demo2_markups.xml") > 0) {
				this.demo2MarkupsXML = xml.copy();
				var transcriptElement:XML = collectionHierarchyXML..transcript.(@id == "demo2")[0];
				transcriptElement.@markupsExist = "true";
				successFunction();
			}
			else {
				throw new Error("Nothing known about path: " + xmlPath);
			}
		}
		
	}
}