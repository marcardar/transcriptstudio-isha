package org.ishafoundation.archives.transcript.components.studio.media
{
	import com.jeroenwijering.player.Player;
	
	public class MediaPlayerControllerImpl implements MediaPlayerController
	{
		private var playerObject:Player;
		
		public function MediaPlayerControllerImpl(playerObject:Object)
		{
			this.playerObject = playerObject;
		}

		/** load the relevant media */
		public function load(sourceId:String, streamId:String, start:int = -1, end:int = -1, loadedHandler:Function):void {
			
		}

		/** Unloads any currently loaded media */
		public function unload():void {
			
		}
		
		/** play the loaded media from the start position (or 0 if not defined) until the end position (or end of media if not defined) */
		public function play():void {
			
		}
		
		public function isPlaying():Boolean {
			
		}
		
		/** returns the current position in seconds (rounded down). Negative value means playing not yet started */
		public function getTimecode():int {
			
		}

		/** changes the play position back by a number of seconds specified by the length */
		public function nudgeBack(secs:int):void {
			
		}		
		
		/** changes the play position forward by a number of seconds specified by the length */
		public function nudgeForward(secs:int):void {
			
		}
	}
}