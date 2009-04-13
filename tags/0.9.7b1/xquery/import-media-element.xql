xquery version "1.0";
 
declare option exist:serialize "media-type=text/plain";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

if (not(utils:is-current-user-admin())) then	
	error((xs:QName('access-control-exception')), 'Only admin user allowed to call this script')
else

let $sessionId := request:get-parameter("sessionId", ())
let $deviceId := request:get-parameter("deviceId", ())
let $mediaXML := util:parse(request:get-parameter("mediaXML", ()))
return
	if (empty($sessionId)) then
		error(xs:QName('missing-argument-exception'), 'No sessionId specified')
	else if (empty($deviceId)) then
		error(xs:QName('missing-argument-exception'), 'No deviceId specified')
	else if (empty($mediaXML)) then
		error(xs:QName('missing-argument-exception'), 'No mediaXML specified')
	else
		let $sessionXML := utils:get-session($sessionId)
		return
			if (empty($sessionXML)) then
				error((), concat('Unknown sessionId: ', $sessionId))
			else
				let $mediaMetadataXML := media-fns:get-media-metadata-element($sessionXML)
				let $deviceXML := media-fns:get-device-element($deviceId, $mediaMetadataXML)
				return
					media-fns:import-media-element($mediaXML, $deviceXML)
