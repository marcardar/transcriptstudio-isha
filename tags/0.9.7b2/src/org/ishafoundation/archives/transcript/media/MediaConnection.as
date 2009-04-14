package org.ishafoundation.archives.transcript.media
{
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	
	import org.ishafoundation.archives.transcript.util.PreferencesSharedObject;
	
	public class MediaConnection
	{
		internal var _nc:NetConnection;	
		[Bindable]	
		public var mediaStream:MediaStream;
		
		/** connection in progress? */
		private var connecting:Boolean = false;
		
		public function MediaConnection()
		{
		}
		
		/**
		 * Don't connect if already connected
		 * 
		 * return true iff already connected
		 */
		public function connect(successFunc:Function, failureFunc:Function):Boolean {
			if (this.connecting) {
				throw new Error("Already attempting to connect");
			}
			if (this._nc != null) {
				if (this._nc.connected) {
					// already connected
					successFunc();
					return true;
				}
				else {
					// discard old connection anyway
					close();
				}
			}
			this._nc = new NetConnection();
			this._nc.client = this;
			this._nc.addEventListener(NetStatusEvent.NET_STATUS, function netStatusHandler(event:NetStatusEvent):void {
				connecting = false;
				switch (event.info.code) {
					case "NetConnection.Connect.Success":
						trace("Successfully connected: " + event.info.description);
						// write db config to the shared object
						PreferencesSharedObject.writeMediaServerURL(MediaConstants.MEDIA_SERVER_URL);
						successFunc();
						break;
					case "NetConnection.Connect.Failed":
						trace("Could not connect");
						close();
						failureFunc(event.info.code);
						break;
					default:
						trace(event.info.code + ": " + event.toString());
				}
			});
			this._nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function securityErrorHandler(event:SecurityErrorEvent):void {
				connecting = false;
				trace("SecurityErrorEvent: " + event);
				close();
				failureFunc(event.text);
			});
			this.connecting = true;
			this._nc.connect(MediaConstants.MEDIA_SERVER_URL);
			return false;
		}
		
		public function isConnecting():Boolean {
			return this.connecting;
		}
		
		public function isConnected():Boolean {
			return this._nc != null && this._nc.connected && !isConnecting();
		}
		
		public function play(mediaURL:String, video:Video, statusFunc:Function, failureFunc:Function, start:int = -1, end:int = -1):void {
			if (!isConnected()) {
				throw new Error("Not connected to media server");
			}
			if (mediaStream != null) {
				if (mediaStream.isOpen() && mediaStream.mediaURL == mediaURL) {
					// great, we can reuse the existing mediaStream
					mediaStream.statusFunc = statusFunc;
					mediaStream.failureFunc = failureFunc;
				}
				else {
					mediaStream.close();
					mediaStream = null;
				}
			}
			if (mediaStream == null) {
				mediaStream = new MediaStream(mediaURL, this, statusFunc, failureFunc);
			}
			mediaStream.play(video, start, end);
		}
			
		public function close():void {
			if (this.mediaStream != null) {
				this.mediaStream.close();
				this.mediaStream = null;
			}
			if (this._nc != null) {
				trace("Closing connection");
				this._nc.close();
			}
		}
		
		public function onBWDone():void{
			trace("onBWDone");
		}
	}
}
