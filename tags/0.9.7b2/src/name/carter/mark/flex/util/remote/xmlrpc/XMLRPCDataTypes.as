package name.carter.mark.flex.util.remote.xmlrpc
{
	internal class XMLRPCDataTypes {

		public static const STRING:String   = "string";
		public static const CDATA:String    = "cdata";
		public static const i4:String       = "i4";
		public static const INT:String      = "int";
		public static const BOOLEAN:String  = "boolean";
		public static const DOUBLE:String   = "double";
		public static const DATETIME:String = "dateTime.iso8601";
		public static const BASE64:String   = "base64";
		public static const STRUCT:String   = "struct";
		public static const ARRAY:String    = "array";
		
		private static const SIMPLE_TYPES:Array = [
											XMLRPCDataTypes.BASE64,
											XMLRPCDataTypes.INT,
											XMLRPCDataTypes.i4,
											XMLRPCDataTypes.STRING,
											XMLRPCDataTypes.CDATA,
											XMLRPCDataTypes.DOUBLE,
											XMLRPCDataTypes.DATETIME,
											XMLRPCDataTypes.BOOLEAN
										];
									
		internal static function isSimpleType(type:String):Boolean {
			return SIMPLE_TYPES.indexOf(type) >= 0;
		}
	
	}
}
