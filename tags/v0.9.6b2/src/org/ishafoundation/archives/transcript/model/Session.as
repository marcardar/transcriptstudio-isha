package org.ishafoundation.archives.transcript.model
{
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	import name.carter.mark.flex.util.XMLUtils;
	
	public class Session
	{
		private static const SOURCE_ID_REG_EXP:RegExp = /^[a-z]+\d+/i;
		
		public var sessionXML:XML;
		public var eventProps:EventProperties;

		public var transcript:Transcript;
		
		private var referenceMgr:ReferenceManager;
		
		[Bindable]
		private var _unsavedChanges:Boolean;

		public function Session(sessionXML:XML, eventProps:EventProperties, referenceMgr:ReferenceManager)
		{
			if (sessionXML == null) {
				throw new ArgumentError("Passed a null sessionXML");
			}
			this.sessionXML = sessionXML;
			this.eventProps = eventProps;
			this.referenceMgr = referenceMgr;
			var transcriptXML:XML = sessionXML.transcript[0];
			if (transcriptXML != null) {
				this.transcript = new Transcript(transcriptXML, referenceMgr);
				ChangeWatcher.watch(this.transcript.mdoc, "modified", function(evt:PropertyChangeEvent):void {
					// only care about positive changes (because negative changes are driven from outside)
					if (new Boolean(evt.newValue)) {
						unsavedChanges = true;					
					}
				});
			}
			else {
				this.transcript = null;
			}
		}
		
		public function get props():SessionProperties {
			return new SessionProperties(sessionXML);
		}
		
		public function get path():String {
			var result:String = sessionXML.attribute("_document-uri");
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
			return sessionXML.@id;
		}
		
		public function set id(newValue:String):void {
			XMLUtils.setAttributeValue(sessionXML, SessionProperties.ID_ATTR_NAME, newValue);
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
			if (sessionXML.transcript.length() == 0) {
				if (sessionXML.devices.length() == 0) {
					sessionXML.insertChildAfter(null, <devices/>);
				}
				var devicesElement:XML = sessionXML.devices[0];
				for each (var deviceElement:XML in deviceElements) {
					devicesElement.appendChild(deviceElement);
				}
				sessionXML.appendChild(transcriptElement);
				transcript = new Transcript(transcriptElement, this.referenceMgr); 
			}
			else {
				throw new Error("Not yet supported");
			}
		}
	}
}