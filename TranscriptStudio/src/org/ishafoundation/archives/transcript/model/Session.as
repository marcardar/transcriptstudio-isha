package org.ishafoundation.archives.transcript.model
{
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	import org.ishafoundation.archives.transcript.fs.EventFile;
	import org.ishafoundation.archives.transcript.fs.File;
	import org.ishafoundation.archives.transcript.fs.SessionFile;
	
	public class Session
	{
		private static const SOURCE_ID_REG_EXP:RegExp = /^[a-z]+\d+/i;
		
		public var sessionXML:XML;

		private var sessionOrEventFile:File;
		public var transcript:Transcript;
		
		[Bindable]
		private var _unsavedChanges:Boolean;

		public function Session(sessionXML:XML, username:String, sessionOrEventFile:File, referenceMgr:ReferenceManager)
		{
			if (sessionXML == null) {
				throw new ArgumentError("Passed a null sessionXML");
			}
			if (sessionOrEventFile == null) {
				throw new ArgumentError("Passed a null sessionOrEventFile");
			}
			this.sessionXML = sessionXML;
			this.sessionOrEventFile = sessionOrEventFile;
			this.transcript = new Transcript(sessionXML.transcript[0], referenceMgr);
			ChangeWatcher.watch(this.transcript.mdoc, "modified", function(evt:PropertyChangeEvent):void {
				// only care about positive changes (because negative changes are driven from outside)
				if (new Boolean(evt.newValue)) {
					unsavedChanges = true;					
				}
			});
		}
		
		public function get props():SessionProperties {
			return new SessionProperties(sessionXML);
		}
		
		[Bindable]
		/**
		 * Returns null if this session does not currently exist in the database.
		 */	
		public function get sessionFile():SessionFile {
			if (sessionOrEventFile is SessionFile) {
				return sessionOrEventFile as SessionFile;
			}
			else {
				return null;
			}
		}
		
		public function set sessionFile(sessionFile:SessionFile):void {
			this.sessionOrEventFile = sessionFile;
		}
		
		public function get eventFile():EventFile {
			if (sessionOrEventFile is EventFile) {
				return sessionOrEventFile as EventFile;
			}
			else {
				return sessionFile.getEventFile();
			}
		}
		
		public function get path():String {
			var result:String;
			if (sessionFile == null) {
				var filename:String = id;
				if (props.subTitle != null) {
					filename += "_" + props.subTitle;
				}
				// replace spaces with underscores
				filename = filename.replace(/ /g, "-").toLowerCase();
				if (eventFile != null) {
					var underscoreIndex:int = eventFile.name.indexOf("_");
					if (underscoreIndex >= 0) {
						filename += eventFile.name.substring(underscoreIndex);
					}
				}
				else {
					filename += ".xml";
				}
				result = eventFile.collection.path + "/" + filename;
			}
			else {
				result = sessionFile.path;
			}
			return result;
		}
		
		/*private function generateFilename(eventProps:EventProperties):String {
			var filename:String = id + "_" + eventProps.type;
			if (eventProps.subTitle != null) {
				filename += "_" + eventProps.subTitle;
			}
			if (subTitle != null) {
				filename += "_" + subTitle;
			}
			if (eventProps.location != null) {
				filename += "_" + eventProps.location;
			}
			if (eventProps.venue != null) {
				filename += "_" + eventProps.venue;
			}
			filename += ".xml";
			// remove any spaces and make lower case
			filename = filename.replace(/ /g, "-").toLowerCase();
			return filename;
		}*/

		public static function testSourceId(str:String):Boolean {
			var match:Object = SOURCE_ID_REG_EXP.exec(str);
			if (match == null) {
				return false;
			}
			throw new Error("Not yet implemented");
		}
		
		public static function getSourceIdPrefix(str:String):String {
			var match:Array = SOURCE_ID_REG_EXP.exec(str);
			if (match == null) {
				return null;
			}
			return (match[0] as String).toLowerCase();
		}
		
		public function get id():String {
			return sessionXML.@id;
		}
		
		[Bindable]
		public function get unsavedChanges():Boolean {
			return _unsavedChanges;
		}
		
		public function set unsavedChanges(value:Boolean):void {
			_unsavedChanges = value;
			if (transcript.mdoc.modified != value) {
				transcript.mdoc.modified = value;
			}
		}
		
		public function saveChangesHandler():void {
			this.unsavedChanges = false;
			transcript.populateCommittedMarkupPropsMap();
		}
		
		public function reload(retrieveFunc:Function, externalSuccess:Function, externalFailure:Function):void {
			retrieveFunc(sessionFile, externalSuccess, externalFailure);
		}
		
	}
}