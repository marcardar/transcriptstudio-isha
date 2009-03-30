package name.carter.mark.flex.exist
{
	import mx.rpc.http.HTTPService;
	
	import name.carter.mark.flex.util.remote.rest.RESTClient;
	
	public class EXistRESTClient
	{
		private var restClient:RESTClient;
		
		public function EXistRESTClient(restClient:RESTClient)
		{
			this.restClient = restClient;
		}

		public function executeStoredXQuery(xQueryPath:String, params:Object, successFunc:Function, failureFunc:Function, resultFormat:String = null):void {
			restClient.call(xQueryPath, params, successFunc, failureFunc, resultFormat);
		}
	}
}