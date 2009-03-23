(: returns a new session id (not currently in use). e.g. 20090320-n1-1-1830 :)

declare namespace create-session-id = "http://www.ishafoundation.org/ts4isha/xquery/create-session-id";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

(:
   $idPrefix is of the format: 20090320-n
   $startId is the lowest integer that goes on the end
   
   If the startId is already in use then we recurse using startId + 1
 :)
declare function create-session-id:create-id($idPrefix as xs:string, $startId as xs:integer) as xs:string
{
	let $id := concat($idPrefix, utils:left-pad-string(string($startId), 4))
	return
		if (exists(collection('/db/ts4isha/data')/session[@id = $id])) then
		(
			create-session-id:create-id($idPrefix, $startId + 1)
		)
		else
		(
			$id
		)
};

(: eventId: e.g. "20090320-y1", "00000000-n14" :)
let $eventId := request:get-parameter('eventId', ())
return
if (not(exists($eventId))) then
()
else
(
	(: sessionDate: e.g. "20090320" (first day of event "20090320-y1"), "20090000" (only year known), undefined means unknown :)
	let $sessionDate := request:get-parameter('sessionDate', ())
	(: sessionTime: session start time e.g. "1830" (6:30pm), undefined means time unknown :)
	let $sessionTime := max((xs:integer(request:get-parameter('sessionTime', '0001')), 1))

	let $eventDateObj := utils:date-string-to-date(collection('/db/ts4isha/data')/event[@id = $eventId]/@startAt[1])
	let $sessionDateObj := utils:date-string-to-date($sessionDate) 
	return
		if (exists($eventDateObj) and exists($sessionDateObj)) then
		(
			let $days := days-from-duration($sessionDateObj - $eventDateObj)
			let $day := if ($days < 0) then '0' else $days + 1
			return
				create-session-id:create-id(concat($eventId, '-', $day, '-'), $sessionTime)		
		)
		else
		(
			create-session-id:create-id(concat($eventId, '-0-'), $sessionTime)		
		)
)