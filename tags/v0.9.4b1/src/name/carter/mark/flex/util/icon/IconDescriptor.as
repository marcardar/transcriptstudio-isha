package name.carter.mark.flex.util.icon
{
	internal class IconDescriptor
	{
		internal var path:String;
		internal var width:int;
		internal var height:int;
		internal var defaultIconClass:Class;
		
		public function IconDescriptor(path:String, width:int = -1, height:int = -1, defaultIconClass:Class = null) {
			this.path = path;
			this.width = width;
			this.height = height;
			this.defaultIconClass = defaultIconClass;
		}

	}
}