xquery version "1.0";

module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
declare namespace util = "http://exist-db.org/xquery/util";

declare function id-utils:generate-event-id($eventType as xs:string) as xs:string
{
	let $maxValue := (max(collection('/db/ts4isha/data')/event/id-utils:get-event-integer-component(@id, $eventType)), 0)[1]
	return
		concat($eventType, $maxValue + 1)
};

(: If the id does not correspond to the specified eventType then return 0
   otherwise return the integer component of the id (i.e. the number after the type :)
declare function id-utils:get-event-integer-component($id as xs:string?, $eventType as xs:string) as xs:integer
{
	if (not(exists($id))) then
		0
	else
		let $extractedType := replace($id, '[^a-zA-Z]', '')
		return
			if ($extractedType != $eventType) then
				0
			else
				xs:integer(replace($id, '\D', ''))
};

declare function id-utils:generate-session-id($eventId as xs:string) as xs:string?
{
	let $sessionIdPrefix := concat($eventId, '-')
	let $maxValue := (max(collection('/db/ts4isha/data')/session[starts-with(@id, $sessionIdPrefix)]/id-utils:get-session-integer-component(@id)), 0)[1]
	return
		concat($sessionIdPrefix, $maxValue + 1)
};

declare function id-utils:get-session-integer-component($id as xs:string?) as xs:integer
{
	if (not(exists($id))) then
		0
	else
		let $localId := substring-after(@id, '-')
		return
			util:catch('java.lang.Exception', xs:integer($localId), 0) 
};