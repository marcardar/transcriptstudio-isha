package org.ishafoundation.archives.transcript.model
{
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	public class Session
	{
		private static const SOURCE_ID_REG_EXP:RegExp = /^[a-z]+\d+/i;
		
		public var sessionId:String;
		public var eventMetadata:EventMetadata;

		/** The 3 main components of a session */
		public var metadata:SessionMetadata;
		public var mediaMetadataElement:XML;
		private var _transcript:Transcript;
		
		private var referenceMgr:ReferenceManager;
		
		[Bindable]
		private var _unsavedChanges:Boolean;

		public function Session(sessionXML:XML, eventMetadata:EventMetadata, referenceMgr:ReferenceManager)
		{
			if (sessionXML == null) {
				throw new ArgumentError("Passed a null sessionXML");
			}
			this.sessionId = sessionXML.@id;
			this.eventMetadata = eventMetadata;
			var sessionId:String;
			if (sessionXML.hasOwnProperty("@id")) {
				sessionId = sessionXML.@id;
			}
			else {
				sessionId = null;
			}
			this.metadata = new SessionMetadata(sessionXML.metadata[0], eventMetadata.id, sessionId);
			this.mediaMetadataElement = sessionXML.mediaMetadata[0];
			var transcriptXML:XML = sessionXML.transcript[0];
			if (transcriptXML != null) {
				this.transcript = new Transcript(transcriptXML, referenceMgr);
			}
			else {
				this.transcript = null;
			}
			this.referenceMgr = referenceMgr;
		}
		
		public function set transcript(newValue:Transcript):void {
			this._transcript = newValue;
			if (newValue == null) {
				return;
			}
			ChangeWatcher.watch(newValue.mdoc, "modified", function(evt:PropertyChangeEvent):void {
				// only care about positive changes (because negative changes are driven from outside)
				if (new Boolean(evt.newValue)) {
					unsavedChanges = true;
				}
			});
		}
		
		public function get transcript():Transcript {
			return _transcript;
		}
		
		public function get sessionXML():XML {
			var result:XML = <session id={sessionId} eventId={eventMetadata.id}/>;
			result.appendChild(metadata.metadataElement);
			if (mediaMetadataElement != null) {
				result.appendChild(mediaMetadataElement);
			}
			if (transcript != null) {
				result.appendChild(transcript.mdoc.nodeElement);
			}
			return result;
		}
		
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
			return sessionId;
		}
		
		[Bindable]
		public function get unsavedChanges():Boolean {
			return _unsavedChanges;
		}
		
		public function set unsavedChanges(value:Boolean):void {
			_unsavedChanges = value;
			if (transcript != null && transcript.mdoc.modified != value) {
				transcript.mdoc.modified = value;
			}
		}
		
		public function saveChangesHandler():void {
			transcript.populateCommittedMarkupPropsMap();
		}
		
		public function appendTranscript(transcriptElement:XML, deviceElements:XMLList):void {
			if (transcript == null) {
				if (this.mediaMetadataElement == null) {
					mediaMetadataElement = <mediaMetadata/>;
				}
				for each (var deviceElement:XML in deviceElements) {
					mediaMetadataElement.appendChild(deviceElement);
				}
				transcript = new Transcript(transcriptElement, this.referenceMgr); 
			}
			else {
				throw new Error("Not yet supported");
			}
		}
	}
}