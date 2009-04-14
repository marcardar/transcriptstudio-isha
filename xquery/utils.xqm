xquery version "1.0";

module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare function utils:is-current-user-admin() as xs:boolean?
{
	let $currentUser := xmldb:get-current-user()
	return
		xmldb:is-admin-user($currentUser)
};

declare function utils:get-event($eventId as xs:string) as element()
{
	collection('/db/ts4isha/data')/event[@id = $eventId]
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