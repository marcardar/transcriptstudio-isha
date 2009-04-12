package org.ishafoundation.archives.transcript.db
{
	import mx.rpc.http.HTTPService;
	
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
		
		public static function createEvent(eventType:String, metadataXML:XML, xqueryExecutor:XQueryExecutor, successFunc:Function, failureFunc:Function):void {
			trace("Creating event of type: " + eventType);
			var params:Object = {type:eventType, metadataXML:metadataXML.toXMLString()};
			xqueryExecutor.executeStoredXQuery("create-event.xql", params, function(eventXML:XML):void {
				successFunc(eventXML); // this is just to document that the event XML is returned
			}, failureFunc, HTTPService.RESULT_FORMAT_E4X);
		}

		public static function updateEvent(eventId:String, metadataXML:XML, xqueryExecutor:XQueryExecutor, successFunc:Function, failureFunc:Function):void {
			trace("Updating event: " + eventId);
			var params:Object = {id:eventId, metadataXML:metadataXML.toXMLString()};
			xqueryExecutor.executeStoredXQuery("update-event.xql", params, function(msg:String):void {
				successFunc(msg); // this is just to document the type returned by the query
			}, failureFunc);
		}
		
		public static function createSession(eventId:String, metadataXML:XML, xqueryExecutor:XQueryExecutor, successFunc:Function, failureFunc:Function):void {
			trace("Creating session for event: " + eventId);
			var params:Object = {eventId:eventId, metadataXML:metadataXML.toXMLString()};
			xqueryExecutor.executeStoredXQuery("create-session.xql", params, function(sessionXML:XML):void {
				successFunc(sessionXML); // this is just to document that the session XML is returned
			}, failureFunc, HTTPService.RESULT_FORMAT_E4X);
		}

		public static function updateSession(sessionId:String, metadataXML:XML, mediaMetadataXML:XML, transcriptXML:XML, xqueryExecutor:XQueryExecutor, successFunc:Function, failureFunc:Function):void {
			trace("Updating session: " + sessionId);
			var params:Object = {id:sessionId}
			if (metadataXML != null) {
				params.metadataXML = metadataXML.toXMLString();
			}
			if (mediaMetadataXML != null) {
				params.mediaMetadataXML = mediaMetadataXML.toXMLString();
			}
			if (transcriptXML != null) {
				params.transcriptXML = transcriptXML.toXMLString();
			}
			xqueryExecutor.executeStoredXQuery("update-session.xql", params, function(msg:String):void {
				successFunc(msg); // this is just to document the type returned by the query
			}, failureFunc);
		}		
	}
}