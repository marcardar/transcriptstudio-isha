package org.ishafoundation.archives.transcript.model
{
	import name.carter.mark.flex.project.mdoc.MTag;

	public class MTagImpl implements MTag
	{
		private var _type:String;
		private var _value:String;
		
		public function MTagImpl(type:String, value:String)
		{
			_type = type;
			_value = value;
		}

		public function get type():String
		{
			return _type;
		}
		
		public function get value():String
		{
			return _value;
		}
		
		public function remove():void
		{
			// do nothing
		}
		
	}
}