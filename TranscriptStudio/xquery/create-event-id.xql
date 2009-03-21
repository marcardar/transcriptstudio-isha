(: returns a new event id (not currently in use). e.g. 20090320-n1 :)

declare namespace create-event-id = "http://www.ishafoundation.org/archives/xquery/create-event-id";

(:
   $idPrefix is of the format: 20090320-n
   $startId is the lowest integer that goes on the end
   
   If the startId is already in use then we recurse using startId + 1
 :)
declare function create-event-id:create-id($idPrefix as xs:string, $startId as xs:integer) as xs:string
{
	let $id := concat($idPrefix, $startId)
	return
		if (exists(collection('/db/archives/data')/event[@id = $id])) then
		(
			create-event-id:create-id($idPrefix, $startId + 1)
		)
		else
		(
			$id
		)
};

(: event start date: e.g. "2009-03-20" or null :)
let $eventDate := request:get-parameter('eventDate', ())
let $condensedDate :=
	if (exists($eventDate)) then
	(
		let $simplifiedDate := replace($eventDate, '[^\dx]', '')
		return
			if (string-length($simplifiedDate) < 8) then
			(
				'xxxxxxxx'
			)
			else
			(
				substring($simplifiedDate, 1, 8)
			)
	) 
	else
		'xxxxxxxx'
(: event type: e.g. "n" :)
let $eventType := request:get-parameter('eventType', 'x')
return
	create-event-id:create-id(concat($condensedDate, '-', $eventType), 1)