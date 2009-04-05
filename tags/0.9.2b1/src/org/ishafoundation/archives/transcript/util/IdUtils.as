package org.ishafoundation.archives.transcript.util
{
	public class IdUtils
	{
		private static const EVENT_ID_REG_EXP_STR:String = "((?:19|20)(?:[0-9][0-9x]|xx)|xxxx)((?:0[1-9x])|(?:1[0-2x])|xx)((?:0[1-9x])|(?:[12][0-9x])|(?:3[01x])|xx)-([a-z]+[0-9]+)";
		private static const SESSION_ID_REG_EXP_STR:String = EVENT_ID_REG_EXP_STR + "-((?:[0-9]+|x)-(?:[0-9]{4}|[0-9]{2}))";
		
		public static const EVENT_ID_EXACT_MATCH_REG_EXP:RegExp = createExactMatchRegExp(EVENT_ID_REG_EXP_STR);
		public static const EVENT_ID_PREFIX_REG_EXP:RegExp = createPrefixRegExp(EVENT_ID_REG_EXP_STR);
		public static const SESSION_ID_EXACT_MATCH_REG_EXP:RegExp = createExactMatchRegExp(SESSION_ID_REG_EXP_STR);
		public static const SESSION_ID_PREFIX_REG_EXP:RegExp = createPrefixRegExp(SESSION_ID_REG_EXP_STR);
		
		public function IdUtils()
		{
			throw new Error("This class is not supposed to be instantiated");
		}
		
		/**
		 * Uses the specified regExpString to return a regular expression which only matches if the start
		 * of the string matches the regular expression AND the next character is either:
		 * 1. end of string
		 * 2. non alphanumeric character.
		 * 
		 * This avoids us matching session ids when we are testing for event ids
		 */
		private static function createPrefixRegExp(regExpString:String):RegExp {
			var prefixRegExpString:String = "^(" + regExpString + ")[_\.].*$";
			return new RegExp(prefixRegExpString);
		}

		private static function createExactMatchRegExp(regExpString:String):RegExp {
			var prefixRegExpString:String = "^" + regExpString + "$";
			return new RegExp(prefixRegExpString);
		}

		public static function getEventId(sessionId:String, validate:Boolean = false):String {
			if (sessionId == null) { 
				return null;
			}
			if (validate && !isValidSessionId(sessionId)) {
				return null;
			}
			var cmps:Array = sessionId.split('-');
			if (cmps.length < 2) {
				throw new Error("Expected at least two components to valid session id: " + sessionId);
			}
			var result:String = cmps[0] + "-" + cmps[1];
			if (validate && !isValidEventId(result)) {
				throw new Error("Extracted event id is not valid even though the session id is valid: " + sessionId);
			}
			return result;
		}
		
		public static function isValidSessionId(id:String):Boolean {
			return SESSION_ID_EXACT_MATCH_REG_EXP.test(id);
		}
		
		public static function getSessionIdPrefix(str:String):String {
			var match:Array = SESSION_ID_PREFIX_REG_EXP.exec(str);
			if (match == null) {
				return null;
			}
			else {
				return match[1];
			}
		}

		public static function isValidEventId(id:String):Boolean {
			return EVENT_ID_EXACT_MATCH_REG_EXP.test(id);
		}

		public static function getEventIdPrefix(str:String):String {
			var match:Array = EVENT_ID_PREFIX_REG_EXP.exec(str);
			if (match == null) {
				return null;
			}
			else {
				return match[1];
			}
		}
	}
}