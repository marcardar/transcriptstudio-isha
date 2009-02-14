package org.ishafoundation.archives.transcript.db
{
	public interface XQueryExecutor
	{
		function query(xQuery:String, args:Array, successFunc:Function, failureFunc:Function):void;
		function executeStoredXQuery(xQueryFilename:String, params:Object, externalSuccessFunction:Function, externalFailureFunction:Function):void;
	}
}