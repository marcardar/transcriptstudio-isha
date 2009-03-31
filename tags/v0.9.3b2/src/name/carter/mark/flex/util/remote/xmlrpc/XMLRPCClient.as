package name.carter.mark.flex.util.remote.xmlrpc
{
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class XMLRPCClient {
		private var url:String;
		private var authHeader:URLRequestHeader;
			
		public function XMLRPCClient(dbURL:String, authHeader:URLRequestHeader = null) {
			this.url = dbURL + "/xmlrpc";
			this.authHeader = authHeader;
		}
		
		/**
		 * @param successFunc Takes the form successFunc(response:Object):void
		 * @param failureFunc Takes the form failureFunc(msg:String):void
		 */
		public function call(methodCallXML:XML, successFunc:Function, failureFunc:Function):void {
			var callStartTime:int = getTimer();

			trace("Calling XML-RPC method: " + condense(methodCallXML.toXMLString()));

			var httpService:HTTPService = new HTTPService();
			httpService.method = URLRequestMethod.POST;
			httpService.url = url;
			httpService.contentType = HTTPService.CONTENT_TYPE_XML;
			httpService.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			if (authHeader != null) {
				httpService.headers = new Object();
				httpService.headers[authHeader.name] = authHeader.value;
			}
			//httpService.requestTimeout = 5;

			httpService.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
				trace("XML-RPC took " + (getTimer() - callStartTime) + "ms");
				
				var responseXML:XML;
				try {
					responseXML = new XML(evt.result);
				}
				catch (e:TypeError) {
					failureFunc("Response from XML-RPC is not valid XML: " + evt.result);
					return;
				}
				var parser:ResponseParser = new ResponseParser();
				
				if (responseXML.fault.length() > 0)
				{
					var parsedFault:Object = parser.parse(responseXML.fault.value.*[0]);
					failureFunc(parsedFault.faultCode + ": " + parsedFault.faultString);
				}
				else if (responseXML.params.length() > 0)
				{
					var parsedResponse:Object = parser.parse(responseXML.params.param.value[0]);
					successFunc(parsedResponse);
					//successFunc(new XML("<result>" + evt.result + "</result>"));
				}
				else
				{
					failureFunc("Response to XML-RPC includes neither params nor fault");
				}
			});
			httpService.addEventListener(FaultEvent.FAULT, function (evt:FaultEvent):void {
				failureFunc("XML-RPC failed because: " + evt.fault.faultString);
			});

			httpService.send(methodCallXML);
		}
		
		private static function condense(xmlString:String):String {
			var regexp:RegExp = />([^<]{401,})</gs; // more than 200 chars from open to close tag
			var result:String = "";
			var index:int = 0;
			var arr:Array = regexp.exec(xmlString);
			while (arr != null) {
				result += xmlString.substring(index, arr.index + 1);
				result += "\n" + xmlString.substring(arr.index + 1, arr.index + 200);
				result += "\n...<skipped>...\n";
				result += xmlString.substring(regexp.lastIndex - 200, regexp.lastIndex - 1) + "\n";
				index = regexp.lastIndex - 1;
				arr = regexp.exec(xmlString);
			}
			// add the rest of the string
			return result += xmlString.substring(index);
		} 
	}
}