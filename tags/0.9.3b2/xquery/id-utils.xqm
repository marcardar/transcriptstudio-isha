module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

(:
   $idPrefix is of the format: 20090320-n
   $startId is the lowest integer that goes on the end
   
   If the startId is already in use then we recurse using startId + 1
 :)
declare function id-utils:create-id-internal($idPrefix as xs:string, $startId as xs:integer, $minSuffixLength as xs:integer) as xs:string
{
	let $id := concat($idPrefix, utils:left-pad-string(xs:string($startId), $minSuffixLength))
	return
		if (exists(collection('/db/ts4isha/data')/*[@id = $id])) then
		(
			id-utils:create-id-internal($idPrefix, $startId + 1, $minSuffixLength)
		)
		else
		(
			$id
		)
};

declare function id-utils:create-event-id($event as element()) as xs:string
{
	let $eventDate := xs:string($event/@startAt)
	let $condensedDate :=
		if (exists($eventDate)) then
		(
			substring(replace($eventDate, '[^\d]', ''), 1, 8)
		) 
		else
			'00000000'
	(: event type: e.g. "n" :)
	let $eventType := xs:string($event/@type)
	return
		id-utils:create-id-internal(concat($condensedDate, '-', $eventType), 1, 1)
};

declare function id-utils:create-session-id($session as element()) as xs:string
{
	let $eventId := xs:string($session/@eventId)
	(: sessionTime: session start time e.g. "1830" (6:30pm), undefined means time unknown :)
	let $startAt := $session/@startAt
	let $sessionTime :=
		if (contains($startAt, 'T')) then
			let $cmps := tokenize(xs:string(xs:time(xs:dateTime($startAt))), ':')
			return xs:integer(string-join(($cmps[1], $cmps[2]), ''))
		else
			1
	let $eventDateObj := utils:date-string-to-date(utils:get-event($eventId)/@startAt)
	let $sessionDateObj := utils:date-string-to-date($session/@startAt) 
	return
		if (exists($eventDateObj) and exists($sessionDateObj)) then
		(
			let $days := days-from-duration($sessionDateObj - $eventDateObj)
			let $day := if ($days < 0) then '0' else $days + 1
			return
				id-utils:create-id-internal(concat($eventId, '-', $day, '-'), $sessionTime, 4)		
		)
		else
		(
			id-utils:create-id-internal(concat($eventId, '-0-'), $sessionTime, 4)		
		)
};
