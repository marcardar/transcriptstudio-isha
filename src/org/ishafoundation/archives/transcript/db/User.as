package org.ishafoundation.archives.transcript.db
{
	public class User
	{
		public static const DBA_GROUP_NAME:String = "dba";
		public static const TEXT_GROUP_NAME:String = "text";
		public static const MARKUP_GROUP_NAME:String = "markup";
		
		private var _username:String;
		private var _groupNames:Array;
		
		public function User(username:String, groupNames:Array)
		{
			this._username = username;
			this._groupNames = groupNames;
		}
		
		public function get username():String {
			return _username;
		}

		public function get groupNames():Array {
			return _groupNames;
		}

		private function isMemberOf(groupName:String):Boolean {
			return this.groupNames.indexOf(groupName) >= 0;			
		}

		public function isDbaUser():Boolean {
			return isMemberOf(DBA_GROUP_NAME);
		}
		
		public function isTextUser():Boolean {
			return isMemberOf(TEXT_GROUP_NAME);
		}
		
		public function isMarkupUser():Boolean {
			return isMemberOf(MARKUP_GROUP_NAME);
		}
	}
}