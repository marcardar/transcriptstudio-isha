package org.ishafoundation.archives.transcript.util
{
	import mx.core.ByteArrayAsset;
	
	public class ApplicationUtils
	{
		[Embed(source="/../build.properties", mimeType="application/octet-stream")]
		private static const BuildPropertiesAsset:Class;
		

		public function ApplicationUtils()
		{
		}

		private static function getPropertyValue(key:String):String {
			var buildPropsAsset:ByteArrayAsset = new BuildPropertiesAsset();
			var str:String = buildPropsAsset.readUTFBytes(buildPropsAsset.length);
			var regExp:RegExp = new RegExp("^\\s*" + key + "\\s*\=\\s*(.+)\\s*$", "mig");
			var arr:Array = regExp.exec(str);
			return arr == null ? "Unknown" : arr[1];
		}

		public static function getApplicationName():String {
			return getPropertyValue("project.name");
		}

		public static function getApplicationCodename():String {
			return getPropertyValue("project.codename");
		}

		public static function getApplicationVersion():String {
			return getPropertyValue("project.version");
		}
	}
}