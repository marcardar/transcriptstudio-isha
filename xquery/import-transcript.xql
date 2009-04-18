xquery version "1.0";
 
declare option exist:serialize "media-type=text/xml";

import module namespace ts4isha='http://ishafoundation.org/ts4isha/xquery' at 'java:org.ishafoundation.ts4isha.xquery.modules.TranscriptStudioModule';
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

if (not(utils:is-current-user-admin())) then	
	error((xs:QName('access-control-exception')), 'Only admin user allowed to call this script')
else

let $transcriptName := request:get-parameter("transcriptName", ())
return
	if (empty($transcriptName)) then
		error(xs:QName('missing-argument-exception'), 'transcriptName not specified')
	else
		let $xmlStr := ts4isha:import-file-read($transcriptName)
		return
			util:parse($xmlStr)
