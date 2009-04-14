package org.ishafoundation.archives.transcript.db
{
	public class DatabaseManagerUtils
	{
		public static function retrieveReferenceXML(xmlRetriever:XMLRetriever, successFunc:Function, failureFunc:Function):void {
			xmlRetriever.retrieveXML(successFunc, failureFunc, "reference", null, DatabaseConstants.REFERENCE_COLLECTION_PATH);
		} 
		
		public static function retrieveEventXML(id:String, xmlRetriever:XMLRetriever, successFunc:Function, failureFunc:Function):void {
			xmlRetriever.retrieveXML(successFunc, failureFunc, "event", id, DatabaseConstants.DATA_COLLECTION_PATH);
		} 
		
		public static function retrieveSessionXML(id:String, xmlRetriever:XMLRetriever, successFunc:Function, failureFunc:Function):void {
			xmlRetriever.retrieveXML(successFunc, failureFunc, "session", id, DatabaseConstants.DATA_COLLECTION_PATH);
		} 
		
		public static function storeEventXML(eventXML:XML, xmlStorer:XMLStorer, successFunc:Function, failureFunc:Function):void {
			xmlStorer.storeXML(eventXML, successFunc, failureFunc);
		}

		public static function storeSessionXML(sessionXML:XML, xmlStorer:XMLStorer, successFunc:Function, failureFunc:Function):void {
			xmlStorer.storeXML(sessionXML, successFunc, failureFunc);
		}
	}
}