xquery version "1.0";

module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace util = "http://exist-db.org/xquery/util";

declare function utils:is-current-user-admin() as xs:boolean?
{
	let $currentUser := xmldb:get-current-user()
	return
		xmldb:is-admin-user($currentUser)
};

declare function utils:get-event($eventId as xs:string) as element()?
{
	collection('/db/ts4isha/data')/event[@id = $eventId]
};

declare function utils:get-session($sessionId as xs:string) as element()?
{
	collection('/db/ts4isha/data')/session[@id = $sessionId]
};

declare function utils:get-event-type($eventTypeId as xs:string) as element()?
{
	collection('/db/ts4isha/reference')/reference//eventType[@id = $eventTypeId]
};

declare function utils:set-child-element($existingParentElement as element(), $newChildElement as element()) as element()?
{
	let $childTagName := local-name($newChildElement)
	let $existingChildElement := $existingParentElement/*[local-name(.) eq $childTagName]
	return
		if (empty($existingChildElement)) then
			let $null := update insert $newChildElement into $existingParentElement 
			return ()
		else if (exactly-one($existingChildElement)) then
			let $null := update replace $existingChildElement with $newChildElement
			return $existingChildElement
		else
			error((), concat('More the one child element named: ', $childTagName))
};

declare function utils:store($documentURI as xs:string, $xml as element()) as xs:string
{
	let $xml := utils:remove-attributes($xml, '_document-uri')
	let $docName := tokenize($documentURI, '/')[last()]
	let $collectionName := substring-before($documentURI, concat('/', $docName))
	return
		xmldb:store($collectionName, $docName, $xml)
};

(: modified because there seems to be a bug in eXist usign the QName - https://sourceforge.net/tracker/index.php?func=detail&aid=1992594&group_id=17691&atid=117691 :)
declare function utils:add-attributes($elements as element()*, $attrNames as xs:string*, $attrValues as xs:anyAtomicType*) as element()? {
	for $element in $elements
	return element { node-name($element)}
	{
		for $attrName at $seq in $attrNames
		return if ($element/@*[local-name(.) = $attrNames])
		       then ()
		       else attribute {$attrName}
		                      {$attrValues[$seq]},
		$element/@*,
		$element/node()
	}
};

declare function utils:remove-attributes ($elements as element()*, $attrNames as xs:string*) as element() {
	for $element in $elements
	return element
		{node-name($element)}
		{$element/@*[not(local-name(.) = $attrNames)],
		$element/node() }
};
 
declare function utils:is-valid-date-string($dateString as xs:string?) as xs:boolean
{
	if (not(exists($dateString))) then
		false()
	else
	(
		let $dateString := replace($dateString, '[^\d]', '')
		return
			if (string-length($dateString) < 8) then
				false()
			else
				let $year := xs:integer(substring($dateString, 1, 4))
				let $month := xs:integer(substring($dateString, 5, 2))
				let $day := xs:integer(substring($dateString, 7, 2))
				return
					$year >= 1 and $month >= 1 and $month <= 12 and $day >= 1 and $day <= 31 
	)		
};

(:
	$dateString can be in various formats but must be in order (year(4), month(2), date(2)) with no digits in between
	            e.g. '20090320', '2009/03/20', '2009-03-20T18:30:00'
:)
declare function utils:date-string-to-date($dateString as xs:string?) as xs:date?
{
	if (not(utils:is-valid-date-string($dateString))) then
	()
	else
	(
		(: make sure it doesnt have separators (but keep the 'x' which represents unknown) :)
		let $dateString := replace($dateString, '[^\d]', '')
		let $standardDateString :=
			concat(substring($dateString, 1, 4), '-', 
			       substring($dateString, 5, 2), '-',
			       substring($dateString, 7, 2))
		return
			xs:date($standardDateString)
	)
};

declare function utils:left-pad-string($stringToPad as xs:string, $minLength as xs:integer) as xs:string
{
	let $numExtra := $minLength - string-length($stringToPad)
	return
		if ($numExtra > 0) then
		(
			string-join((for $i in (1 to $numExtra) return '0', $stringToPad), '')
		)
		else
		(
			$stringToPad
		)
};

(: if either (or both) args are empty then empty sequence is returned :)
declare function utils:days-diff($date1 as xs:date?, $date2 as xs:date?) as xs:integer?
{
	if (count(($date1, $date2)) < 2) then
		()
	else
		let $days := days-from-duration($date2 - $date1)
		return $days
};

declare function utils:make-filename-friendly($rawFilename as xs:string) as xs:string
{
	replace(replace($rawFilename, '\s+', '-'), '[^a-z0-9\-_]', '')
};

declare function utils:build-event-path($event as element()) as xs:string
{
	let $collectionName := concat('/db/ts4isha/data', '/', $event/@type)
	let $docName := string-join(($event/@id, utils:build-event-full-name($event)), '_')
	return concat($collectionName, '/', $docName, '.xml')
};

declare function utils:build-event-full-name($event as element()) as xs:string?
{
	let $fullName := lower-case(string-join(($event/metadata/@startAt, $event/metadata/@subTitle, $event/metadata/@location, $event/metadata/@venue), '_'))
	let $fullName := utils:make-filename-friendly($fullName)
	return
		if (string-length($fullName) > 0) then
			$fullName
		else
			()
};

declare function utils:build-session-path($sessionXML as element()) as xs:string
{
	let $eventXML := utils:get-event($sessionXML/@eventId)
	let $collectionName := util:collection-name($eventXML)
	let $docName := string-join(($sessionXML/@id, utils:build-session-full-name($sessionXML, $eventXML)), '_')
	return concat($collectionName, '/', $docName, '.xml')
};

declare function utils:build-session-full-name($sessionXML as element(), $eventXML as element()) as xs:string?
{
	let $metadataXML := $sessionXML/metadata[1]
	let $fullName :=
		lower-case(string-join( 
			(
				utils:build-event-full-name($eventXML)
				,
				let $eventDate := utils:date-string-to-date($eventXML/metadata/@startAt)
				let $sessionDate := utils:date-string-to-date($metadataXML/@startAt)
				let $daysDiff := utils:days-diff($eventDate, $sessionDate)
				return
					if (exists($daysDiff) and $daysDiff >= 0) then
						concat('day-', $daysDiff + 1)
					else
						()
				,
				$metadataXML/@subTitle
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

