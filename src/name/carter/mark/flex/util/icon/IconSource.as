package name.carter.mark.flex.util.icon
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	internal class IconSource extends EventDispatcher
	{
		private static var ICON_SOURCES:Dictionary = new Dictionary(false); // key is icon path (String) (eg "./assets/topic.png"), value is IconSource
		private static var SHOW_SECURITY_ERROR_MESSAGE:Boolean = true;
		
		private var path:String;
		internal var embeddedIcon:BitmapAsset;
		internal var available:Boolean = false;
		internal var unavailable:Boolean = false;
		private var loader:Loader;
		
		internal static function getInstance(path:String):IconSource {
			var result:IconSource = ICON_SOURCES[path];
			if (result == null) {
				// first time we know about this icon
				result = new IconSource(path);
				ICON_SOURCES[path] = result;
				if (path == null) {
					// this is the IconSource related to compile-time icons
					result.unavailable = true;
				}
				else {
					result.initLoader();
				}
			}
			return result;
		}
		
		internal static function displayIcon(iconDescriptor:IconDescriptor, bitmap:Bitmap):void {
			var iconSource:IconSource = getInstance(iconDescriptor.path);
			iconSource.setBitmapData(bitmap, iconDescriptor.width, iconDescriptor.height, iconDescriptor.defaultIconClass);
		}
		
		public function IconSource(path:String) {
			this.path = path;
		}
		
		internal function callRelevantFunctionOnCompletion(successFunction:Function, failureFunction:Function):void {
			var completed:Boolean = callRelevantFunctionNow(successFunction, failureFunction);
			if (!completed) {
				// its still being processed
				addEventListener(Event.COMPLETE, function(event:Event):void {
					var completed:Boolean = callRelevantFunctionNow(successFunction, failureFunction);
					if (!completed) {
						throw new Error("Icon source loading complete but flag not set!");
					}
				});
			}
		}
		
		/* returns true iff icon source loading is complete */
		private function callRelevantFunctionNow(successFunction:Function, failureFunction:Function):Boolean {
			if (available) {
				if (successFunction != null) {
					successFunction(path);
				}
				return true;
			}
			else if (unavailable) {
				if (failureFunction != null) {
					failureFunction(path);
				}
				return true;
			}
			else {
				return false;
			}
		}

		/* safer to not do initialization in the constructor */
		private function initLoader():void {
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				dispatchIconProcessedEvent(false);
			});
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
				try {
					// try drawing it straight away so that we can find out ASAP if there is a security problem
					drawIcon(loader, new BitmapData(1, 1, true, 0x00FFFFFF));
					// this is when we know that the icon was found AND there were no security issues
					dispatchIconProcessedEvent(true);
				}
				catch (e:SecurityError) {
					// could not read the icon because of security/sandbox restrictions - so just use default
					dispatchIconProcessedEvent(false);
					if (!SHOW_SECURITY_ERROR_MESSAGE) {
						SHOW_SECURITY_ERROR_MESSAGE = false;
						Alert.show("At least one icon could not be retrieved because of a security error: " + path, "Security Error");
					}
				}
			});
			this.loader.load(new URLRequest(this.path), new LoaderContext(true));
		}
		
		private function dispatchIconProcessedEvent(success:Boolean):void {
			if (available || unavailable) {
				throw new Error("Tried to dispatch ICON_PROCESSED event more than once");
			}
			available = success;
			unavailable = !success;
			dispatchEvent(new Event(Event.COMPLETE));			
		}
		
		private function setBitmapData(bitmap:Bitmap, width:int, height:int, defaultIconClass:Class):void {
			if (width == 0 || height == 0) {
				return;
			}
			if (embeddedIcon != null) {
				// use the embedded icon if its there
				drawIconUsingSource(embeddedIcon, bitmap, width, height);
			}
			else if (available) {
				drawIconUsingSource(loader, bitmap, width, height);
			}
			else if (unavailable) {
				if (defaultIconClass == null) {
					return;
				}
				drawIconUsingSource(new defaultIconClass(), bitmap, width, height);
			}
			else {
				// while we are waiting - at least have an empty space (if possible)
				if (width > 0 && height > 0) {
					createBitmapData(bitmap, width, height);
				}
				addEventListener(Event.COMPLETE, function(event:Event):void {
					setBitmapData(bitmap, width, height, defaultIconClass);
				});
			}
		}
		
		private static function drawIconUsingSource(source:DisplayObject, bitmap:Bitmap, width:int, height:int):void {
			if (width < 0) {
				width = source.width;
			}
			if (height < 0) {
				height = source.height;
			}
			createBitmapData(bitmap, width, height);
			drawIcon(source, bitmap.bitmapData);
		}
		
		private static function createBitmapData(bitmap:Bitmap, width:int, height:int):void {
			if (bitmap.bitmapData != null) {
				return;
			}
			bitmap.bitmapData = new BitmapData(width, height, true, 0x00FFFFFF);
			if (bitmap.parent is UIComponent) {
				var component:UIComponent = bitmap.parent as UIComponent;
				component.invalidateSize();
			}			
		}
			
		private static function drawIcon(source:DisplayObject, bitmapData:BitmapData):void {
			bitmapData.draw(source, new Matrix(bitmapData.width/source.width, 0, 0, bitmapData.height/source.height, 0, 0));
		}		
	}
}