package org.ishafoundation.archives.transcript.media
{
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	
	public class MediaStream
	{
		public var mediaURL:String;
		private var mediaConnection:MediaConnection;
		
		private var ns:NetStream;
		[Bindable]
		public var duration:Number = -1;
		
		public var statusFunc:Function;
		public var failureFunc:Function;
		
		public function MediaStream(mediaURL:String, mediaConnection:MediaConnection, statusFunc:Function, failureFunc:Function)
		{
			this.mediaURL = mediaURL;
			this.mediaConnection = mediaConnection;
			this.statusFunc = statusFunc;
			this.failureFunc = failureFunc;
		}
		
		public function get time():Number {
			if (this.ns == null) {
				return -1;
			}
			else {
				return this.ns.time;
			}
		}
		
		/**
		 * connectionURL - for example: rtmp://localhost/ts4isha
		 */		 
		public function open():void
		{
			if (this.ns != null) {
				close();
			}
			if (!mediaConnection.isConnected()) {
				throw new Error("Tried to open stream but not connected");
			}
			this.ns = new NetStream(this.mediaConnection._nc);
			this.ns.addEventListener(NetStatusEvent.NET_STATUS, function netStatusHandler(event:NetStatusEvent):void {
				switch (event.info.code) {
					case "NetStream.Play.StreamNotFound":
						// do the same as for "Failed" (i.e. no break)
						// unfortunately if the media does not exist then this event is not fired.
					case "NetStream.Play.Failed":
						close();
						if (failureFunc != null) {
							failureFunc(event.info.description);
						}
						break;
					case "NetStream.Play.Start":
						// do the default (i.e. no break)
					default:
						if (statusFunc != null) {
							statusFunc(event.info.code + ": " + event.info.description);
						}
				}
			});
			this.ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, function asyncErrorHandler(event:AsyncErrorEvent): void {
				trace(event.toString());
				close();
				if (failureFunc != null) {
					failureFunc(event.toString());
				}
			});
			this.ns.client = this;
		}
		
		public function isOpen():Boolean {
			if (!mediaConnection.isConnected()) {
				return false;
			}
			return ns != null;
		}

		public function play(video:Video = null, start:int = -1, end:int = -1):void {
			if (!mediaConnection.isConnected()) {
				throw new Error("Not connected to media server");
			}
			if (!isOpen()) {
				open();
			}
			if (video != null) {
				video.attachNetStream(ns);
			}
			if (start < 0) {
				// ignore start and end
				ns.play(this.mediaURL);
			}
			else if (end < start) {
				// no relevant end value - so just play to finish
				ns.play(this.mediaURL, start);
			}
			else if (end == start) {
				// no duration so dont play anything
				this.ns.seek(0);
			}
			else {
				start = Math.max(start, 0);
				end = Math.max(end, 0);
				ns.play(this.mediaURL, start, end - start);
			}
		}
		
		public function seek(time:Number):void {
			trace("Seeking to time: " + time);
			this.ns.seek(time);
		}

		public function pause():void {
			trace("Pausing at: " + this.ns.time);
			this.ns.pause();
		}
		
		public function resume():void {
			trace("Resuming at: " + this.ns.time);
			this.ns.resume();
		}
		
		public function close():void {
			if (this.ns == null) {
				return;
			}
			trace("Closing stream");
			this.ns.close();
			this.ns = null;
			this.duration = -1;
			//this.statusFunc = null;
			//this.failureFunc = null;
		}

		public function onMetaData(info:Object):void {
			trace("metadata: duration=" + info.duration);
			this.duration = info.duration;
		}
		public function onCuePoint(info:Object):void {
			trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		public function onPlayStatus(info:Object):void {
			trace("playstatus: code=" + info.code + " bytes=" + info.bytes);
			if (info.code == "NetStream.Play.Complete") {
				if (this.statusFunc != null) {
					this.statusFunc("NetStream.Play.Complete");
				}
			}
		}
	}
}