package org.ishafoundation.archives.transcript.components.generic
{
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	/**
	 * Convenience class for displaying unsaved changes popup and calling the appropriate functions
	 */
	public class UnhandledChangesPopUpManager
	{
		public static var DISPLAYED_NOW:Boolean = false;
		
		public function UnhandledChangesPopUpManager()
		{
		}
		
		/**
		 * syncSaveChangesFunction()
		 * nextFunction()
		 * 
		 * if unsavedChanges is false, then simply nextFunction() is called.
		 */
		public static function displayIfNecessaryUsingSyncFunc(unsavedChanges:Boolean, syncSaveChangesFunc:Function, nextFunction:Function):Boolean {
			if (DISPLAYED_NOW) {
				trace("Not displaying Alert because already displayed");
				return false;
			}
			if (unsavedChanges) {
				// check whether the users wants to save
				DISPLAYED_NOW = true;
				Alert.show("Do you want to commit changes?", "Uncommitted Changes", Alert.YES | Alert.NO | Alert.CANCEL, null, function (event:CloseEvent):void {
					DISPLAYED_NOW = false;
					if (event.detail==Alert.YES) {
						syncSaveChangesFunc();
						nextFunction();
					}				
					else if (event.detail==Alert.NO) {
						nextFunction();
					}
					else if (event.detail==Alert.CANCEL) {
						// do nothing
					}
					else {
						throw new Error("Unexpected event type: " + event);
					}
				});
			}
			else {
				nextFunction();
			}
			return true;
		}
		
		/**
		 * asyncSaveChangesFunction(nextFunction(), saveChangesFailureFunction(String))
		 * 
		 * if unsavedChanges is false, then simply nextFunction() is called.
		 */
		public static function displayIfNecessaryUsingAsyncFunc(unsavedChanges:Boolean, asyncSaveChangesFunction:Function, saveChangesFailureFunction:Function, nextFunction:Function):void {
			if (unsavedChanges) {
				// check whether the users wants to save
				Alert.show("Do you want to save changes?", "Unsaved Changes", Alert.YES | Alert.NO | Alert.CANCEL, null, function (event:CloseEvent):void {
					if (event.detail==Alert.YES) {
						asyncSaveChangesFunction(nextFunction, saveChangesFailureFunction);
					}				
					else if (event.detail==Alert.NO) {
						nextFunction();
					}
					else if (event.detail==Alert.CANCEL) {
						// do nothing
					}
					else {
						throw new Error("Unexpected event type: " + event);
					}
				});
			}
			else {
				nextFunction();
			}				
		}
	}
}