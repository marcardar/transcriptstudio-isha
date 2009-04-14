xquery version "1.0";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare option exist:serialize "media-type=application/xml";

let $eventId := request:get-parameter('eventId', ())
let $metadataXMLStr := request:get-parameter('metadataXML', ())
return
	if (empty($eventId) or $eventId eq '') then
		error((), 'No eventId specified')
	else if (empty($metadataXMLStr)) then
		error((), 'No metadataXML specified')
	else if (empty(utils:get-event($eventId))) then
		error((), concat('Unknown eventId: ', $eventId))
	else
		let $metadataXML := (util:parse($metadataXMLStr), <metadata/>)[1]
		let $newId := id-utils:generate-session-id($eventId)
		let $sessionXML := <session id="{$newId}" eventId="{$eventId}">{$metadataXML}</session>
		let $documentURI :=	utils:build-session-path($sessionXML)
		let $null := utils:store($documentURI, $sessionXML)
		return
			$sessionXML
			