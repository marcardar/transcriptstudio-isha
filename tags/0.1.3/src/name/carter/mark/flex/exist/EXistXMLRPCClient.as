package name.carter.mark.flex.exist
{
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import name.carter.mark.flex.util.Utils;
	import name.carter.mark.flex.util.remote.xmlrpc.MethodCall;
	import name.carter.mark.flex.util.remote.xmlrpc.XMLRPCClient;
	
	public class EXistXMLRPCClient
	{
		private var xmlRpcClient:XMLRPCClient;
		
		public function EXistXMLRPCClient(xmlRpcClient:XMLRPCClient)
		{
			this.xmlRpcClient = xmlRpcClient;
		}

		public function retrieveCollection(collectionPath:String, successFunction:Function, failureFunction:Function):void {
			var methodCall:MethodCall = new MethodCall("getCollectionDesc");
			methodCall.addParamAsString(collectionPath);
			xmlRpcClient.call(methodCall.xml, successFunction, failureFunction);
		}
		
		public function retrieveXML(xmlPath:String, successFunction:Function, failureFunction:Function, ignoreWhitespace:Boolean = true):void {
			var methodCall:MethodCall = new MethodCall("getDocumentAsString");
			methodCall.addParamAsString(Utils.encodePath(xmlPath));
			methodCall.addParamAsStruct({indent: "yes", encoding: "UTF-8"});
			xmlRpcClient.call(methodCall.xml, function(response:Object):void {
				var oldIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
				XML.ignoreWhitespace = ignoreWhitespace;
				var xml:XML = new XML(response);
				XML.ignoreWhitespace = oldIgnoreWhitespace;
				successFunction(xml);			
			}, function(msg:String):void {
				failureFunction("XML file could not be retrieved because: " + msg);			
			});
		}

		public function storeXML(xmlPath:String, xml:XML, successFunction:Function, failureFunction:Function):void {
			var methodCall:MethodCall = new MethodCall("parse");
			methodCall.addParamAsString(xml.toXMLString());
			methodCall.addParamAsString(Utils.encodePath(xmlPath));
			methodCall.addParamAsInt(1);
			xmlRpcClient.call(methodCall.xml, function(response:Object):void {
				successFunction();			
			}, function (msg:String):void {
				failureFunction("XML file could not be stored because: " + msg);
			});			
		}		

		public function query(xQuery:String, args:Array, successFunc:Function, failureFunc:Function):void {
			var enc:Base64Encoder = new Base64Encoder();
			enc.encode(xQuery);
			
			var struct:Object = new Object();
			struct.indent = "yes";
			struct.encoding = "UTF-8";
			if (args != null) {
				struct.variables = new Object();
				for (var i:int = 0; i < args.length; i++) {
					var arg:Object = args[i];
					if (arg != null) {
						struct.variables["arg" + i] = arg.toString();
					}
				}
			}

			var methodCall:MethodCall = new MethodCall("query"); 
			methodCall.addParamAsBase64(enc.drain());
			methodCall.addParamAsInt(int.MAX_VALUE);
			methodCall.addParamAsInt(1);
			methodCall.addParamAsStruct(struct);
			xmlRpcClient.call(methodCall.xml, function(response:Object):void {
				var oldIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
				XML.ignoreWhitespace = true;
				var dec:Base64Decoder = new Base64Decoder();
				dec.decode(response.toString());
				var xml:XML = new XML(dec.toByteArray());
				XML.ignoreWhitespace = oldIgnoreWhitespace;
				successFunc(xml);			
			}, function (msg:String):void {
				failureFunc("XQuery could not be executed because: " + msg);			
			});			
		}		
	}
}