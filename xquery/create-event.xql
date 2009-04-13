xquery version "1.0";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare option exist:serialize "media-type=application/xml";

let $eventType := request:get-parameter('type', ())
let $metadataXMLStr := request:get-parameter('metadataXML', ())
return
	if (empty($eventType) or $eventType eq '') then
		error((), 'No type specified')
	else if (empty($metadataXMLStr)) then
		error((), 'No metadataXML specified')
	else if (empty(utils:get-event-type($eventType))) then
		error((), concat('Unknown type: ', $eventType))
	else
		let $metadataXML := (util:parse($metadataXMLStr), <metadata/>)[1]
		let $newId := id-utils:generate-event-id($eventType)
		let $eventXML := <event id="{$newId}" type="{$eventType}">{$metadataXML}</event>
		let $documentURI :=	utils:build-event-path($eventXML)
		let $null := utils:store($documentURI, $eventXML)
		return
			$eventXML