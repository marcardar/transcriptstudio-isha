package name.carter.mark.flex.util.icon
{
	import flash.display.DisplayObjectContainer;
	
	import mx.core.IDataRenderer;
	
	/**
	 * Provides functionality to display icons loaded at runtime in components designed to display
	 * embedded (compile-time) icons.
	 * 
	 */
	public class IconUtils
	{		
		public static function getIconClass(ancestorComponent:DisplayObjectContainer, iconPath:String, iconWidth:int = -1, iconHeight:int = -1, defaultIconClass:Class = null):Class {
			if (ancestorComponent == null) {
				// this can often happen while components are being initialised
				return null;
			}
			if (iconPath == null) {
				throw new Error("Passed a null iconPath");
			}
			var iconDescriptor:IconDescriptor = new IconDescriptor(iconPath, iconWidth, iconHeight, defaultIconClass); 
			var iconDescriptorFunction:Function = function(parent:DisplayObjectContainer):IconDescriptor {
				return iconDescriptor;
			};
			IconClass.registerIconDescriptorFunction(ancestorComponent, iconDescriptorFunction);
			return IconClass;
		}

		public static function getIconClassUsingEmbeddedClass(ancestorComponent:DisplayObjectContainer, embeddedIconClass:Class, iconWidth:int = -1, iconHeight:int = -1):Class {
			if (ancestorComponent == null) {
				// this can often happen while components are being initialised
				return null;
			}
			if (embeddedIconClass == null) {
				throw new Error("Passed a null embeddedIconClass");
			}
			var iconDescriptor:IconDescriptor = new IconDescriptor(null, iconWidth, iconHeight, embeddedIconClass); 
			var iconDescriptorFunction:Function = function(parent:DisplayObjectContainer):IconDescriptor {
				return iconDescriptor;
			};
			IconClass.registerIconDescriptorFunction(ancestorComponent, iconDescriptorFunction);
			return IconClass;
		}

		public static function getIconFunctionForDataRenderer(ancestorComponent:DisplayObjectContainer, iconPathFunction:Function, iconWidth:int = -1, iconHeight:int = -1, defaultIconClass:Class = null):Function {
			if (ancestorComponent == null) {
				// this can often happen while components are being initialised
				return null;
			}
			if (iconPathFunction == null) {
				throw new Error("Passed a null iconPathFunction");
			}
			var iconDescriptorFunction:Function = function(parent:DisplayObjectContainer):IconDescriptor {
				if (!(parent is IDataRenderer)) {
					return null;
				}
				var dr:IDataRenderer = parent as IDataRenderer;
				var iconPath:String = iconPathFunction(dr.data);
				var result:IconDescriptor;
				if (iconPath == null) {
					result = null;
				}
				else {
					result = new IconDescriptor(iconPath, iconWidth, iconHeight, defaultIconClass);
				}
				return result;
			};
			IconClass.registerIconDescriptorFunction(ancestorComponent, iconDescriptorFunction);
			return function(item:Object):Class {
				return IconClass;
			};
		}
		
		public static function getIconFunctionForDataRendererUsingSimpleIconFunction(ancestorComponent:DisplayObjectContainer, iconFunction:Function, iconWidth:int = -1, iconHeight:int = -1):Function {
			if (ancestorComponent == null) {
				// this can often happen while components are being initialised
				return null;
			}
			if (iconFunction == null) {
				throw new Error("Passed a null iconPathFunction");
			}
			var iconDescriptorFunction:Function = function(parent:DisplayObjectContainer):IconDescriptor {
				if (!(parent is IDataRenderer)) {
					return null;
				}
				var dr:IDataRenderer = parent as IDataRenderer;
				var embeddedIconClass:Class = iconFunction(dr.data);
				var result:IconDescriptor;
				if (embeddedIconClass == null) {
					result = null;
				}
				else {
					result = new IconDescriptor(null, iconWidth, iconHeight, embeddedIconClass);
				}
				return result;
			};
			IconClass.registerIconDescriptorFunction(ancestorComponent, iconDescriptorFunction);
			return function(item:Object):Class {
				return IconClass;
			};
		}
		
		/**
		 * Preload the icon so it is more readily displayable.
		 * 
		 * Both specified functions take a single String parameter - which is the icon path.
		 * 
		 * Note - one of the specified functions may be called (in the same thread) before this function returns
		 * 
		 * @param iconPath The URL for the icon
		 * @param successFunction The function to be called when the icon is successfully loaded. If it is already loaded, then it is called immediately (before this function returns). 
		 * @param failureFunction The function to be called when the icon has failed to load. If it is already loaded, then it is called immediately (before this function returns) 
		 */
		public static function preloadIcon(iconPath:String, successFunction:Function = null, failureFunction:Function = null):void {
			var iconSource:IconSource = IconSource.getInstance(iconPath);
			if (successFunction != null || failureFunction != null) {
				iconSource.callRelevantFunctionOnCompletion(successFunction, failureFunction);
			}
		}
		
		/**
		 * Specify the embedded icon to override runtime icon loading for this iconPath
		 * 
		 * Note - an attempt will still be made to load so that we can accurately report the availability of the icon.
		 *        This is useful for icon paths used in TextArea html. 
		 */		
		public static function overrideIcon(iconPath:String, embeddedIconClass:Class):void {
			var iconSource:IconSource = IconSource.getInstance(iconPath);
			if (embeddedIconClass != null) {
				iconSource.embeddedIcon = new embeddedIconClass();
			}
		}
		
		public static function isKnownToBeUnavailable(iconPath:String):Boolean {
			return IconSource.getInstance(iconPath).unavailable;
		}

		private static function isKnownToBeAvailable(iconPath:String):Boolean {
			return IconSource.getInstance(iconPath).available;
		}

		/**
		 * Returns the corresponding html <img/> element.
		 * 
		 * If the specified iconPath is known to be available then its path is used.
		 * Otherwise, if the defaultIconPath is known to be available, then its path is used
		 * Otherwise, null is returned.
		 */
		public static function createImgElement(iconPath:String, iconWidth:int = -1, iconHeight:int = -1, defaultIconPath:String = null):XML {
			if (!isKnownToBeAvailable(iconPath)) {
				if (defaultIconPath == null || !isKnownToBeAvailable(defaultIconPath)) {
					// couldnt even load the default - probably security problems
					// so don't show icon at all
					return null;
				}
				else {
					iconPath = defaultIconPath;
				}
			}
			var result:XML = <img src={iconPath}/>;
			if (iconWidth >= 0) {
				result.@width = iconWidth;
			}
			if (iconHeight >= 0) {
				result.@height = iconHeight;
			}
			return result;
		}
	}
}