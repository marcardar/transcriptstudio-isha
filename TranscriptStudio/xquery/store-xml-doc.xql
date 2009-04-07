xquery version "1.0";

declare namespace store-xml-doc = "http://www.ishafoundation.org/ts4isha/xquery/store-xml-doc";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare function store-xml-doc:build-event-path($event as element()) as xs:string
{
	let $collectionName := concat('/db/ts4isha/data', '/', $event/@type)
	let $docName := string-join(($event/@id, store-xml-doc:build-event-full-name($event)), '_')
	return concat($collectionName, '/', $docName, '.xml')
};

declare function store-xml-doc:build-event-full-name($event as element()) as xs:string?
{
	let $fullName := lower-case(string-join(($event/@subTitle, $event/@location, $event/@venue), '_'))
	let $fullName := utils:make-filename-friendly($fullName)
	return
		if (string-length($fullName) > 0) then
			$fullName
		else
			()
};

declare function store-xml-doc:build-session-path($session as element()) as xs:string
{
	let $event := collection('/db/ts4isha/data')/event[@id = $session/@eventId]
	let $collectionName := util:collection-name($event)
	let $docName := string-join(($session/@id, store-xml-doc:build-session-full-name($session, $event)), '_')
	return concat($collectionName, '/', $docName, '.xml')
};

declare function store-xml-doc:build-session-full-name($session as element(), $event as element()?) as xs:string?
{
	let $event :=
		if (not(exists($event))) then
			collection('/db/ts4isha/data')/event[@id = $session/@eventId]
		else
			$event
	let $fullName :=
		lower-case(string-join( 
			(
				store-xml-doc:build-event-full-name($event)
				,
				let $eventDate := utils:date-string-to-date($event/@startAt)
				let $sessionDate := utils:date-string-to-date($session/@startAt)
				let $daysDiff := utils:days-diff($eventDate, $sessionDate)
				return
					if (exists($daysDiff) and $daysDiff >= 0) then
						concat('day-', $daysDiff + 1)
					else
						()
				,
				$session/@subTitle
			)
			,
			'_'
		))
	let $fullName := utils:make-filename-friendly($fullName)
	return
		if (exists($fullName) and string-length($fullName) > 0) then
			$fullName
		else
			()
};

let $xmlStr := request:get-parameter('xmlStr', ())
return
	if (not(exists($xmlStr))) then
		()
	else
		let $xml := util:parse($xmlStr)
		let $isEventXML := 
			if (local-name($xml) = 'event') then
				true()
			else if (local-name($xml) = 'session') then
				false()
			else
				error(concat("xml element not supported for id creation: ", $xml))
		let $xml :=
				if (not(exists($xml/@id))) then
					let $newId :=
						if ($isEventXML) then
							id-utils:generate-event-id($xml/@type)
						else
							id-utils:generate-session-id($xml/@eventId)
					return functx:add-attributes($xml, xs:QName('id'), $newId)
				else
					$xml
		let $id := xs:string($xml/@id)
		let $existingXML :=
			if ($isEventXML) then
				collection('/db/ts4isha/data')/event[@id = $id]
			else 
				collection('/db/ts4isha/data')/session[@id = $id]
		let $documentURI :=
			if (exists($existingXML)) then
			(
				document-uri(root($existingXML))
			)
			else
			(
				if ($isEventXML) then
					store-xml-doc:build-event-path($xml)
				else
					store-xml-doc:build-session-path($xml)
			)
		let $null := utils:store($documentURI, $xml)
		return
			$id
