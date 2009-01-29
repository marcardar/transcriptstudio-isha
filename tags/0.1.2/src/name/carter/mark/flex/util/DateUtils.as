package name.carter.mark.flex.util
{
	import mx.formatters.DateBase;
	
	import name.carter.mark.flex.util.Utils;
	
	public class DateUtils
	{
		public function DateUtils()
		{
		}

		/**
		 * See: http://safari.oreilly.com/0596004907/actscptckbk-CHP-10-SECT-7
		 */
		public static function parseNonStandardDateString(dateStr:String):Date {
		
			// Create local variables to hold the year, month, date of month, hour, minute, and
			// second. Assume that there are no milliseconds in the date string.
			var year:int, month:int, dayOfMonth:int, hour:int, minute:int, second:int;
			var re:RegExp;
			
			// includes either dd-MM-yy(yy) or dd/MM/yy(yy).
			re = /([0-9]{1,2})(?:\/|-)([0-9]{1,2}|[a-zA-Z]{3,})(?:\/|-)([0-9]{2,})/g;
			var match:Array = re.exec(dateStr);
			if (match != null) {
				// Extract the month number and day-of-month values from the date string.
				dayOfMonth = new int(match[1]);
				if (match[2].length <= 2) {
					month = new int(match[2]) - 1;					
				}
				else {
					// must be written out - e.g Apr or April
					var shortMonths:Array = Utils.arrayToLowerCase(DateBase.monthNamesShort);
					var monthStr:String = (match[2] as String).toLowerCase();
					var shortIndex:int = shortMonths.indexOf(monthStr);
					if (shortIndex >= 0) {
						month = shortIndex;
					}
					else {
						var longMonths:Array = Utils.arrayToLowerCase(DateBase.monthNamesLong);
						var longIndex:int = longMonths.indexOf(monthStr);
						if (longIndex >= 0) {
							month = longIndex;
						}
						else {
							// we cannot identify the month so return null
							return null;
						}
					}
				}
				
				// If the year value is two characters, then we must add the century to it. 
				if (match[3].length == 2) {
					var twoDigitYear:int = new int(match[3]);
					// Assumes that years less than 50 are in the 21st century
					year = (twoDigitYear < 50) ? twoDigitYear + 2000 : twoDigitYear + 1900;
				} else {
					// Extract the four-digit year
					year = new int(match[3]);
				}
				/*
				// Check whether the string includes a time value of the form of h(h):mm(:ss).
				re = new RegExp("[0-9]{1,2}:[0-9]{2}(:[0-9]{2,})?", "g");
				match = re.exec(dateStr);
				if (match != null) {
					// If the length is 4, the time is given as h:mm. If so, then the length of the
					// first part of the time (hours) is only one character. Otherwise, it is two
					// characters in length.
					var firstLength = 2;
					if (match[0].length == 4) {
						firstLength = 1;
					}
					
					// Extract the hour and minute parts from the date string. If the length of the
					// match is greater than five, assume that it includes seconds.
					hour = Number(dateStr.substr(match.index, firstLength));
					minute = Number(dateStr.substr(match.index + firstLength + 1, 2));
					if (match[0].length > 5) {
						second = Number(dateStr.substr(match.index + firstLength + 4, 2));
					}
				}
				*/
				// Return the new date.
				return new Date(year, month, dayOfMonth, hour, minute, second);
			}
			else {
				return null;
			}
		}

		public static function parseStandardDateString(dateStr:String):Date {
			if (dateStr == null) {
				return null;
			}
			dateStr = dateStr.replace(/-/g, "/");
			dateStr = dateStr.replace("T", " ");
			dateStr = dateStr.replace("Z", " GMT-0000");
			return new Date(Date.parse(dateStr));
		}
	}
}