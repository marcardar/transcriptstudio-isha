package org.ishafoundation.archives.transcript.components.studio.text
{
	import mx.containers.TitleWindow;
	
	public class AbstractEditDialog extends TitleWindow 
	{
		public function set texts(newValue:Array):void {
			throw new Error("This should be overridden");
		}

		public function get texts():Array {
			throw new Error("This should be overridden");
		}
	}
}