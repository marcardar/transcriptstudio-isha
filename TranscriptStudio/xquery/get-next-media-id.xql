xquery version "1.0";
 
declare namespace get-next-media-id = "http://www.ishafoundation.org/ts4isha/xquery/get-next-media-id";

declare option exist:serialize "media-type=text/plain";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
 
declare function get-next-media-id:extract-integer($str as xs:string?) as xs:integer?
{
	util:catch('java.lang.Exception', xs:integer(replace($str, '\D', '')), ())
};

let $domain := request:get-parameter("domain", ())
let $prefix := request:get-parameter("prefix", ())
return
	if (empty($domain)) then
		'ERROR - no domain specified'
	else if (empty($prefix)) then
		'ERROR - no prefix specified'
	else
		let $maxIdInt := (id-utils:get-max-id-integer($domain, $prefix), 0)[1]
		let $startDigitalAttrName :=
			if ($domain eq 'audio') then
				'startDigitalAudioId'
			else if ($domain eq 'video') then
				'startDigitalVideoId'
			else if ($domain eq 'image') then
				'startDigitalImageId'
			else
				error(concat('Unknown domain: ', $domain))
		let $minIdInt := collection('/db/ts4isha/reference')/reference//eventType/get-next-media-id:extract-integer(@*[local-name(.) = $startDigitalAttrName])
		let $nextIdInt := max(($maxIdInt + 1, $minIdInt))
		return
			$nextIdInt
		

		