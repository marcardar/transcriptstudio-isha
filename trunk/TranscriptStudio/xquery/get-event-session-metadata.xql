xquery version "1.0";

declare option exist:serialize "media-type=text/xml method=xml indent=yes";

let $sessionIds := tokenize(request:get-parameter('sessionIds', ()), '\s*,\s*')
return
	if (empty($sessionIds)) then
		error(xs:QName('missing-argument-exception'), 'sessionIds not specified')
	else
let $sessions := collection('/db/ts4isha/data')/session[@id = $sessionIds]
let $eventIds := $sessions/@eventId
let $events := collection('/db/ts4isha/data')/event[@id = $eventIds]
return
	<idRefs>{
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
	)
	}</idRefs>
