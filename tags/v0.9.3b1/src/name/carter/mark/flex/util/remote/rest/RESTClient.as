package name.carter.mark.flex.util.remote.rest
{
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.XMLUtils;
	
	public class RESTClient {
		
		private var restURL:String;
		private var authHeader:URLRequestHeader;
		
		public function RESTClient(dbURL:String, authHeader:URLRequestHeader = null)
		{
			this.restURL = dbURL + "/rest";
			this.authHeader = authHeader;
		}
		
		public function test(successFunc:Function, failureFunc:Function):void {
			call("/db", null, successFunc, failureFunc);
		}
		
		/**
		 * @param params name-value pairs for the request object
		 * @param successFunc Takes the form successFunc(response:Object):void
		 * @param failureFunc Takes the form failureFunc(msg:String):void
		 */
		public function call(path:String, params:Object, successFunc:Function, failureFunc:Function, resultFormat:String = null):void {
			var callStartTime:int = getTimer();

			var httpService:HTTPService = new HTTPService();
			httpService.method = URLRequestMethod.POST;
			httpService.url = restURL + path;
			if (authHeader != null) {
				httpService.headers = new Object();
				httpService.headers[authHeader.name] = authHeader.value;
			}
			if (resultFormat != null) {
				httpService.resultFormat = resultFormat;
			}
			//httpService.requestTimeout = 5;
			
			httpService.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
				if (evt.result.hasOwnProperty("error") && evt.result.error != null) {
					failureFunc("Failed because: " + evt.result.error);
					return;
				}
				trace("Executed REST service in " + (getTimer() - callStartTime) + "ms");
				successFunc(evt.result);
			});

			httpService.addEventListener(FaultEvent.FAULT, function (evt:FaultEvent):void {
				trace("Failed to execute REST service. Took " + (getTimer() - callStartTime) + "ms");
				var content:Object = evt.fault.content;
				var msg:String; 
				if (content == null) {
					msg = evt.fault.faultString;
				}
				else {
					try {
						var contentXML:XML = XMLUtils.convertToXML(content);
						if ((contentXML..title as XMLList).length() > 0) {
							msg = contentXML..title.toString();
						}
						else {
							msg = contentXML..message.toString();
						}
					}
					catch (e:Error) {
						// could not parse XML
						trace("Failed to parse XML fault content: " + content);
						msg = Utils.normalizeSpace(content.toString());
					}
				}
				failureFunc("REST service failed because: " + msg);
			});

			httpService.send(params);			
		}
	}
}