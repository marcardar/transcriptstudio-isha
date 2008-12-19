package name.carter.mark.flex.util.remote.xmlrpc
{
	import mx.utils.Base64Encoder;
	
	public class MethodCall
	{
		public var xml:XML;
		
		public function MethodCall(methodName:String){
			this.xml = <methodCall/>;
			
			var methodNameElement:XML = <methodName>{methodName}</methodName>;
			this.xml.appendChild(methodNameElement);
			
			var paramsElement:XML = <params/>;			
			this.xml.appendChild(paramsElement);
		}
		
		private function get paramsElement():XML {
			return xml.params[0];
		}
		
		private function addParam(value:Object, type:String = null):void {
			var paramElement:XML = <param/>;
			var valueElement:XML = createValueElement(value, type);
			paramElement.appendChild(valueElement);
			
			paramsElement.appendChild(paramElement);
		}
		
		public function addParamAsString(value:String):void {
			addParam(value, XMLRPCDataTypes.STRING);
		}
		
		public function addParamAsBase64(value:String):void {
			addParam(value, XMLRPCDataTypes.BASE64);			
		}

		public function addParamAsInt(value:int):void {
			addParam(value, XMLRPCDataTypes.INT);			
		}

		public function addParamAsStruct(value:Object):void {
			addParam(value, XMLRPCDataTypes.STRUCT);			
		}

		private static function createValueElement(value:Object, type:String = null):XML {
			// if the type is null then try to work it out from the value
			if (type == null) {
				if (value is String) {
					type = XMLRPCDataTypes.STRING;
				}
				else if (value is Array) {
					type = XMLRPCDataTypes.ARRAY;
				}
				else if (value is Base64Encoder) {
					type = XMLRPCDataTypes.BASE64;
					value = (value as Base64Encoder).drain();
				}
				else if (value is Boolean) {
					type = XMLRPCDataTypes.BOOLEAN;
				}
				else if (value is int) {
					type = XMLRPCDataTypes.INT;
				}
				else if (value is Number) {
					type = XMLRPCDataTypes.DOUBLE;
				}
				else if (value is Date) {
					type = XMLRPCDataTypes.DATETIME;
				}
				else {
					type = XMLRPCDataTypes.STRUCT;
				}
			}

			var result:XML = <value/>;
			var typeElement:XML;

			if (type == XMLRPCDataTypes.CDATA) {
				type = XMLRPCDataTypes.STRING;
				value = '<![CDATA[' + value + ']]>';  
			}

			// Handle Explicit Simple Objects
			if (XMLRPCDataTypes.isSimpleType(type)) {
				typeElement = <{type}>{value}</{type}>;
				result.appendChild(typeElement);
			}
			// Handle Array Objects
			else if (type == XMLRPCDataTypes.ARRAY) {
				typeElement = <array />;
				var dataElement:XML = <data/>;
				for each (var arrValue:Object in (value as Array)) {
					dataElement.appendChild(createValueElement(arrValue));
				}
				typeElement.appendChild(dataElement);
				result.appendChild(typeElement);
			}
			// Handle Struct Objects
			else if (type == XMLRPCDataTypes.STRUCT) {
				typeElement = <struct/>;
				for (var structPropName:String in value) {
					var memberElement:XML = <member/>;

					// add name node
					memberElement.appendChild(<name>{structPropName}</name>);

					// add value node
					var valueElement:XML = createValueElement(value[structPropName]);
					memberElement.appendChild(valueElement);

					typeElement.appendChild(memberElement);
				}
				result.appendChild(typeElement);
			}
			else {
				throw new Error("Unknown param type: " + type);
			}
			
			return result;
		}

		public function toString():String {
			return xml.toString();
		}
	}
}