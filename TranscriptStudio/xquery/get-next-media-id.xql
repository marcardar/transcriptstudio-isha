xquery version "1.0";
 
declare namespace get-next-media-id = "http://www.ishafoundation.org/ts4isha/xquery/get-next-media-id";

declare option exist:serialize "media-type=text/plain";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
 
declare function get-next-media-id:extract-integer($str as xs:string?) as xs:integer?
{
	util:catch('java.lang.Exception', xs:integer(replace($str, '\D', '')), ())
};

let $domain := request:get-parameter("domain", ())
let $eventType := request:get-parameter("eventType", ())
return
	if (empty($domain)) then
		error(xs:QName('illegal-argument-exception'), 'no domain specified')
	else if (empty($eventType)) then
		error(xs:QName('illegal-argument-exception'), 'no eventType specified')
	else
		media-fns:get-next-media-id-integer($domain, $eventType)
		