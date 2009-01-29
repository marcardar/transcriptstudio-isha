/**
* @author	Matt Shaw <xmlrpc@mattism.com>
* @url		http://sf.net/projects/xmlrpcflash
* 			http://www.osflash.org/doku.php?id=xmlrpcflash		
*
* @author   Daniel Mclaren (http://danielmclaren.net)
* @note     Updated to Actionscript 3.0	
*/
package name.carter.mark.flex.util.remote.xmlrpc
{
	import name.carter.mark.flex.util.DateUtils;
	
	internal class ResponseParser {
		
		private static const METHOD_RESPONSE_NODE:String = "methodResponse";
		private static const PARAMS_NODE:String = "params";
		private static const PARAM_NODE:String = "param";
		private static const VALUE_NODE:String = "value";
		private static const FAULT_NODE:String = "fault";
		private static const ARRAY_NODE:String = "array";
		
		private static const DATA_NODE:String = "data";
		private static const STRUCT_NODE:String = "struct";
		private static const MEMBER_NODE:String = "member";
		
		public function parse( xml:XML ):Object {
			if ( xml.toString().toLowerCase().indexOf('<html') >= 0 ){
				trace("WARNING: XML-RPC Response looks like an html page.");
				return xml.toString();
			}
			
			return this._parse( xml );
		}
		
		private function _parse( node:XML ):Object {		
			var data:Object;
			var i:int;
			
			if (node.nodeKind() == 'text') {
				return node.toString();
			}
			else if (node.nodeKind() == 'element') {
				
				if (
					node.name() == METHOD_RESPONSE_NODE || 
					node.name() == PARAMS_NODE		  ||				
					node.name() == VALUE_NODE 		  || 
					node.name() == PARAM_NODE 		  ||
					node.name() == FAULT_NODE 		  ||
					node.name() == ARRAY_NODE
					) {
					
					this.debug("_parse(): >> " + node.name());
					if (node.name() == VALUE_NODE && node.*.length() <= 0) return null;
					return this._parse( node.*[0] );
				}
				else if (node.name() == DATA_NODE) {
					this.debug("_parse(): >> Begin Array");
					data = new Array();
					for (i=0; i<node.children().length(); i++) {
						data.push( this._parse(node.children()[i]) );
						this.debug("_parse(): adding data to array: "+data[data.length-1]);
					}
					this.debug("_parse(): << End Array");
					return data;
				}
				else if (node.name() == STRUCT_NODE) {
					this.debug("_parse(): >> Begin Struct");
					data = new Object();
					for (i=0; i<node.children().length();i++) {
						var temp:Object = this._parse(node.children()[i]);
						data[temp.name]=temp.value;
						this.debug("_parse(): Struct item "+temp.name + ":" + temp.value);
					}
					this.debug("_parse(): << End Stuct");
					return data;
				}
				else if (node.name() == MEMBER_NODE) {
					/* 
					* The member tag is *special*. The returned
					* value is *always* a hash (or in Flash-speak,
					* it is always an Object).
					*/
					data = new Object();
					data.name = node.name[0].toString();
					data.value = this._parse(node.value[0]);
					
					return data;
				}
				else if (node.name() == "name") {
					return this._parse(node.*[0]);
				}
				else if (XMLRPCDataTypes.isSimpleType(node.name())) {
					return this.createSimpleType( node.name(), node.* );
				}
			}
			
			this.debug("Received an invalid Response.");
			return null;
		}
		
		private function createSimpleType( type:String, value:String ):Object {
			switch (type){
				case XMLRPCDataTypes.i4:	
				case XMLRPCDataTypes.INT:	
				case XMLRPCDataTypes.DOUBLE:						
					return new Number( value );
					break;
					
				case XMLRPCDataTypes.STRING:
					return new String( value );
					break;
				
				case XMLRPCDataTypes.DATETIME:
					return DateUtils.parseStandardDateString(value);
					break;
					
				case XMLRPCDataTypes.BASE64:
					return value;
					break;
					
				case XMLRPCDataTypes.CDATA:
					return value;
					break;
	
				case XMLRPCDataTypes.BOOLEAN:
					return value == "1" || value.toLowerCase() == "true";
					
			}
			
			return value;
		}
		
		private function debug(a:String):void {
			//trace(this._PRODUCT + " -> " + a);
		}
	}
}