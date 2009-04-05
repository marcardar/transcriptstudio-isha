package org.ishafoundation.archives.transcript.util
{
	import flash.net.SharedObject;
	
	public class PreferencesSharedObject
	{
		private static const DB_URL_KEY:String = "dbURL";
		private static const DB_USERNAME_KEY:String = "dbUsername";
		private static const MEDIA_SERVER_URL_KEY:String = "mediaServerURL";
		
		public function PreferencesSharedObject()
		{
			throw new Error("This class should not be instantiated");
		}
		
		private	static function getSharedObject():SharedObject {
			return SharedObject.getLocal("preferences");
		}

		public static function writeDbURL(url:String):void {
			var PREFS_SO:SharedObject = getSharedObject();
			PREFS_SO.data[DB_URL_KEY] = url;
			PREFS_SO.flush();			
		}

		public static function writeDbUsername(username:String):void {
			var PREFS_SO:SharedObject = getSharedObject();
			PREFS_SO.data[DB_USERNAME_KEY] = username;
			PREFS_SO.flush();			
		}

		public static function writeMediaServerURL(url:String):void {
			var PREFS_SO:SharedObject = getSharedObject();
			PREFS_SO.data[MEDIA_SERVER_URL_KEY] = url;
			PREFS_SO.flush();			
		}

		public static function readDbURL(defaultValue:String = null):String {
			return readValue(DB_URL_KEY, defaultValue);
		}

		public static function readDbUsername(defaultValue:String = null):String {
			return readValue(DB_USERNAME_KEY, defaultValue);
		}
		
		public static function readMediaServerURL(defaultValue:String = null):String {
			return readValue(MEDIA_SERVER_URL_KEY, defaultValue);
		}		
		
		private static function readValue(key:String, defaultValue:String):String {
			var PREFS_SO:SharedObject = getSharedObject();
			if (PREFS_SO.data.hasOwnProperty(key)) {
				return PREFS_SO.data[key];
			}
			else {
				return defaultValue;
			}			
		}
	}
}