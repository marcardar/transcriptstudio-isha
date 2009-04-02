import module namespace functx = "http://www.functx.com" at "functx.xqm";

let $eventId := request:get-parameter('eventId', ())
let $sessionElements := collection('/db/ts4isha/data')/session[@eventId = $eventId]
return
	<result>{
		for $resultItem  in functx:remove-elements($sessionElements, 'transcript')
		order by exists($resultItem/@startAt), $resultItem/@startAt, $resultItem/@id
		return
			$resultItem
	}</result>
