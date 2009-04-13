xquery version "1.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";

let $sessionIds := tokenize(request:get-parameter('sessionIds', ()), '\s*,\s*')
let $sessions := collection('/db/ts4isha/data')/session[@id = $sessionIds]
let $eventIds := $sessions/@eventId
let $events := collection('/db/ts4isha/data')/event[@id = $eventIds]
return
	<events>{
		for $event in $events
		let $eventId := $event/@id
		return
			<event>
			{$event/@*}
			{$event/metadata}
			{
				for $session in $sessions[@eventId eq $eventId]
				return
					<session>
					{$session/@*}
					{$session/metadata}
					</session>
			}
			</event>
	}</events>
