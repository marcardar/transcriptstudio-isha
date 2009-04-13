xquery version "1.0";
 
declare option exist:serialize "media-type=text/plain";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";

let $domain := request:get-parameter("domain", ())
let $eventType := request:get-parameter("eventType", ())
return
	if (empty($domain)) then
		error(xs:QName('illegal-argument-exception'), 'no domain specified')
	else if (empty($eventType)) then
		error(xs:QName('illegal-argument-exception'), 'no eventType specified')
	else
		media-fns:get-next-media-id-integer($domain, $eventType)
		