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
	public class DatabaseConstants
	{
		public static var EXIST_URL:String = "http://127.0.0.1:8080/exist";
		public static const ARCHIVES_COLLECTION_PATH:String = "/db/archives";
		public static const REFERENCE_COLLECTION_PATH:String = ARCHIVES_COLLECTION_PATH + "/reference";
		public static const DATA_COLLECTION_PATH:String = ARCHIVES_COLLECTION_PATH + "/data";
		public static const XQUERY_COLLECTION_PATH:String = ARCHIVES_COLLECTION_PATH + "/xquery";
		public static const XSLT_COLLECTION_PATH:String = ARCHIVES_COLLECTION_PATH + "/xslt";
	}
}