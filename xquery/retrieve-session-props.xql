xquery version "1.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";

let $eventId := request:get-parameter('eventId', ())
let $sessionMetadataElements :=
	if (not(exists($eventId))) then
		collection('/db/ts4isha/data')/session/metadata
	else
		collection('/db/ts4isha/data')/session[@eventId = $eventId]/metadata
return
	<result>{
		for $sessionMetadataElement in $sessionMetadataElements
		let $sessionId := $sessionMetadataElement/parent::*/@id
		let $resultItem := functx:add-attributes($sessionMetadataElement, xs:QName('_sessionId'), $sessionId)
		order by exists($resultItem/@startAt), $resultItem/@startAt, $sessionId
		return
			$resultItem
	}</result>
