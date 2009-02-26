package org.ishafoundation.archives.transcript.components.studio.media
{
	public interface MediaPlayerController
	{
		/** load the relevant media */
		function load(sourceId:String, streamId:String, start:int = -1, end:int = -1, loadedHandler:Function):void;

		/** Unloads any currently loaded media */
		function unload():void ;
		
		/** play the loaded media from the start position (or 0 if not defined) until the end position (or end of media if not defined) */
		function play():void;
		
		function isPlaying():Boolean;
		
		/** returns the current position in seconds (rounded down). Negative value means playing not yet started */
		function getTimecode():int;

		/** changes the play position back by a number of seconds specified by the length */
		function nudgeBack(secs:int):void;		
		
		/** changes the play position forward by a number of seconds specified by the length */
		function nudgeForward(secs:int):void;		
	}
}