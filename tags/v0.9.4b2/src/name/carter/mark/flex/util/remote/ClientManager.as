package name.carter.mark.flex.util.remote
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import mx.controls.Alert;
	import mx.utils.Base64Encoder;
	
	import name.carter.mark.flex.util.remote.rest.RESTClient;
	import name.carter.mark.flex.util.remote.xmlrpc.XMLRPCClient;
	
	public class ClientManager
	{
		private var dbURL:String;
		private var authHeader:URLRequestHeader;
		
		public function ClientManager(dbURL:String, username:String = null, password:String = null)
		{
			this.dbURL = dbURL;
			if (username != null) {
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.encode(username + ":" + password);
				var credentials:String = encoder.drain();
				this.authHeader = new URLRequestHeader("Authorization", "Basic " + credentials);
			}			
		}

		public function getXMLRPCClient():XMLRPCClient {
			return new XMLRPCClient(dbURL, authHeader);
		} 
		
		public function getRESTClient():RESTClient {
			return new RESTClient(dbURL, authHeader);
		}

		public function testConnection(successFunc:Function, failureFunc:Function):void {
			getRESTClient().call("", null, successFunc, failureFunc);
		}

		/**
		 * Simply calls the URL
		 */
		public static function testConnectionToURL(url:String, successFunc:Function, failureFunc:Function):void {
			try {
				var request:URLRequest = new URLRequest(url);
				var response:URLLoader = new URLLoader();
				response.addEventListener(Event.COMPLETE, successFunc);
            	response.addEventListener(IOErrorEvent.IO_ERROR, failureFunc);
            	response.addEventListener(SecurityErrorEvent.SECURITY_ERROR, failureFunc);
				response.load(request);
			}
			catch (e:SecurityError) {
				Alert.show("Wasnt expecting an error to be thrown here");
				failureFunc(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
			}
		}		
	}
}