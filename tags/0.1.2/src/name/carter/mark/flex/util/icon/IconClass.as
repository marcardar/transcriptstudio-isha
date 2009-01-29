package name.carter.mark.flex.util.icon
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.BitmapAsset;
	
	/*
	 * An icon descriptor function takes the parent (DisplayObjectContainer) of this bitmap asset and returns a IconDescriptor
	 *
	 */
	internal class IconClass extends BitmapAsset
	{
		// key is DisplayObjectContainer - some ancestor component of icon
		// value is Function - takes a DisplayObjectContainer (same as key or descendant of key) and returns an IconDescriptor
		private static var COMPONENT_TO_DESCRIPTOR_FUNC_MAP:Dictionary = new Dictionary(true);
		private static var COMPONENT_TO_INSTANCES_MAP:Dictionary = new Dictionary(true); // value is Array of BitmapAssets 
		
		private var ancestorComponentSpecifyingDescriptor:DisplayObjectContainer;
		
		public function IconClass() {
			addEventListener(Event.ADDED, function(evt:Event):void{displayIcon()}, false, 0, true);
			addEventListener(Event.REMOVED, function(evt:Event):void{deregisterIconClassInstance()}, false, 0, true);
		}
		
		internal static function registerIconDescriptorFunction(ancestorComponent:DisplayObjectContainer, iconDescriptorFunction:Function):void {
			var existingFunction:Function = COMPONENT_TO_DESCRIPTOR_FUNC_MAP[ancestorComponent];
			COMPONENT_TO_DESCRIPTOR_FUNC_MAP[ancestorComponent] = iconDescriptorFunction;
			if (existingFunction != null) {
				var instancesUsingComponentDescriptor:Array = COMPONENT_TO_INSTANCES_MAP[ancestorComponent] as Array;
				if (instancesUsingComponentDescriptor == null) {
					//trace("instancesUsingComponentDescriptor has never been used so no need to redraw: " + ancestorComponent);
				}
				else {
					//trace("Redrawing icons corresponding to ancestor: " + ancestorComponent);
					for each (var ic:IconClass in instancesUsingComponentDescriptor) {
						if (ic.parent != null) {
							ic.displayIcon();
						}
					}
				}
			}
		}
		
		private function displayIcon():void {
			//trace("Adding IconClass: " + this);
			if (parent == null) {
				throw new Error("IconClass instance does not have a parent: " + this);
			}
			var iconDescriptorFunction:Function = getIconDescriptorFunction(parent);
			if (iconDescriptorFunction == null) {
				throw new Error("Component uses Icon Utils but neither it nor an ancestor has been registered: " + parent);
			} 
			var iconDescriptor:IconDescriptor = iconDescriptorFunction(parent);
			if (iconDescriptor != null) {
				this.bitmapData = null; // make sure we clear what was there before
				IconSource.displayIcon(iconDescriptor, this);
			}
		}
		
		private function getIconDescriptorFunction(component:DisplayObjectContainer):Function {
			if (component == null) {
				return null;
			}
			var iconDescriptorFunction:Function = COMPONENT_TO_DESCRIPTOR_FUNC_MAP[component];
			if (iconDescriptorFunction == null) {
				return getIconDescriptorFunction(component.parent);
			}
			else {
				var instancesUsingComponentDescriptor:Array = COMPONENT_TO_INSTANCES_MAP[component] as Array;
				if (instancesUsingComponentDescriptor == null) {
					instancesUsingComponentDescriptor = new Array(this);
					COMPONENT_TO_INSTANCES_MAP[component] = instancesUsingComponentDescriptor;
				}
				else {
					if (instancesUsingComponentDescriptor.indexOf(this) < 0) { // TODO: is this check redundant?
						instancesUsingComponentDescriptor.push(this);
					}
				}
				this.ancestorComponentSpecifyingDescriptor = component;
				return iconDescriptorFunction;
			}
		}
		
		private function deregisterIconClassInstance():void {
			//trace("Removing IconClass: " + this);
			var instancesUsingComponentDescriptor:Array = COMPONENT_TO_INSTANCES_MAP[this.ancestorComponentSpecifyingDescriptor] as Array;
			var index:int = instancesUsingComponentDescriptor.indexOf(this);
			instancesUsingComponentDescriptor.splice(index, 1);
		}
	}
}