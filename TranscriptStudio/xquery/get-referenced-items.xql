xquery version "1.0";

declare option exist:serialize "media-type=text/xml method=xml indent=yes";

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

let $sessionIds := tokenize(request:get-parameter('sessionIds', ()), '\s*,\s*')
let $deviceCodeIds := tokenize(request:get-parameter('deviceCodes', ()), '\s*,\s*')
return
	if (empty($sessionIds)) then
		error(xs:QName('missing-argument-exception'), 'sessionIds not specified')
	else
let $sessions := $utils:dataCollection/session[@id = $sessionIds]
let $eventIds := $sessions/@eventId
let $events := $utils:dataCollection/event[@id = $eventIds]
return
	<referencedItems>{
	(
		for $event in $events
		order by $event/@id
		return
			$event
	,
		for $session in $sessions
		order by $session/@id
		return
			<session>
			{$session/@*}
			{$session/metadata}
			</session>
	,
		for $eventTypeId in $events/@type
		order by $eventTypeId
		return
			$utils:referenceCollection/reference//eventType[@id = $eventTypeId]
	,
		for $deviceCodeId in $deviceCodeIds
		order by $deviceCodeId
		return
			$utils:referenceCollection/reference//deviceCode[@id = $deviceCodeIds]
	)
	}</referencedItems>
