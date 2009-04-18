xquery version "1.0";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare option exist:serialize "media-type=application/xml";

let $eventType := request:get-parameter('type', ())
let $metadataXMLStr := request:get-parameter('metadataXML', ())
return
	if (empty($eventType) or $eventType eq '') then
		error(xs:QName('missing-argument-exception'), 'No type specified')
	else if (empty($metadataXMLStr)) then
		error(xs:QName('missing-argument-exception'), 'No metadataXML specified')
	else if (empty(utils:get-event-type($eventType))) then
		error(xs:QName('illegal-argument-exception'), concat('Unknown type: ', $eventType))
	else 
		let $collectionPath := concat($utils:dataCollectionPath, '/', $eventType)
		return
			if (not(xmldb:collection-exists($collectionPath))) then
				error(xs:QName('illegal-state-exception'), concat('Could not find event type collection: ', $collectionPath))
			else
				let $metadataXML := (util:parse($metadataXMLStr), <metadata/>)[1]
				let $newId := id-utils:generate-event-id($eventType)
				let $eventXML := <event id="{$newId}" type="{$eventType}">{$metadataXML}</event>
				let $documentURI :=	utils:build-event-path($eventXML)
				let $null := utils:store($documentURI, $eventXML)
				return
					$eventXML
