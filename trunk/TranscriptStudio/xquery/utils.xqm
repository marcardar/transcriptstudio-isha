xquery version "1.0";

module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils";

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

