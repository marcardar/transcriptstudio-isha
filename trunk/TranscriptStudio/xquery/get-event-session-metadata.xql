xquery version "1.0";

let $sessionIds := tokenize(request:get-parameter('sessionIds', ()), '\s*,\s*')
return
	if (empty($sessionIds)) then
		error(xs:QName('missing-argument-exception'), 'sessionIds not specified')
	else
let $sessions := collection('/db/ts4isha/data')/session[@id = $sessionIds]
let $eventIds := $sessions/@eventId
let $events := collection('/db/ts4isha/data')/event[@id = $eventIds]
return
	<events>{
		for $event in $events
		let $eventId := $event/@id
		order by $eventId
		return
			<event>
			{$event/@*}
			{$event/metadata}
			{
				for $session in $sessions[@eventId eq $eventId]
				order by $session/@id
				return
					<session>
					{$session/@*[local-name(.) != 'eventId']}
					{$session/metadata}
					</session>
			}
			</event>
	}</events>
