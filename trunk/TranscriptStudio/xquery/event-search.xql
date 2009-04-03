(: returns a new session id (not currently in use). e.g. 20090320-n1-1-1830 :)

declare namespace event-search = "http://www.ishafoundation.org/ts4isha/xquery/event-search";

(: declare function create-session-id:create-id($idPrefix as xs:string, $startId as xs:integer) as xs:string :)

(: type: e.g. "n", "other" (special code), "any" :)
let $eventType := request:get-parameter('eventType', ())
let $year := request:get-parameter('year', ())
let $yearType := request:get-parameter('yearType', 'on')
let $country := request:get-parameter('country', ())

let $result :=
	if (not(exists($eventType)) or $eventType = '[any]') then
		collection('/db/ts4isha/data')/event
	else
		collection('/db/ts4isha/data')/event[@type = $eventType]
let $result :=
	if (not(exists($year)) or $year = '[any]') then
		$result
	else if ($yearType = 'before') then
		$result[exists(@startAt) and substring(@startAt, 1, 4) < $year]
	else if ($yearType = 'after') then
		$result[exists(@startAt) and substring(@startAt, 1, 4) > $year]
	else
		$result[exists(@startAt) and starts-with(@startAt, $year)]
let $result :=
	if (not(exists($country)) or $country = '[any]') then
		$result
	else
		$result[@country = $country]
return
	<result> 
		{for $event in $result
		 order by xs:string($event/@id)
		 return
		 	$event
		}
	</result>