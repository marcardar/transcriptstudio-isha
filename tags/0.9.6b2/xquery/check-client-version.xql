xquery version "1.0";

(: Tests whether the specified client version (e.g. "0.9.0b1") is allowed (otherwise out-of-date) :)
(: Returns empty string if allowed, otherwise returns min version required string :)

declare namespace check-client-version = "http://www.ishafoundation.org/ts4isha/xquery/check-client-version";

declare variable $check-client-version:minClientVersion := '0.9.5';

declare function check-client-version:compare-versions($ver1 as xs:string, $ver2 as xs:string) as xs:integer
{
	if ($ver1 = '') then
		if ($ver2 = '') then
			0
		else
			-1
	else
		if ($ver2 = '') then
			+1
		else
			let $nextComponent1 := xs:integer(if (contains($ver1, '.')) then substring-before($ver1, ".") else $ver1)
			let $nextComponent2 := xs:integer(if (contains($ver2, '.')) then substring-before($ver2, ".") else $ver2)
			return
				if ($nextComponent1 < $nextComponent2) then
					-1
				else if ($nextComponent1 > $nextComponent2) then
					+1
				else
					let $newVer1 := if (contains($ver1, '.')) then substring-after($ver1, '.') else ''
					let $newVer2 := if (contains($ver2, '.')) then substring-after($ver2, '.') else ''
					return check-client-version:compare-versions($newVer1, $newVer2)
};

let $clientVersion := request:get-parameter('clientVersion', ())
let $fullVersion := replace($clientVersion, '[a-zA-Z]+.*', '')
(: sometimes we want to disallow non-releases (like betas) :)
let $isRelease := $clientVersion = $fullVersion
let $cmp :=	check-client-version:compare-versions($fullVersion, $check-client-version:minClientVersion)
return
	if ($cmp >= 0) then 
		''
	else 
		$check-client-version:minClientVersion
