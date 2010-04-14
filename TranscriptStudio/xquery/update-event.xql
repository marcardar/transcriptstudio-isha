xquery version "1.0";

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace util = "http://exist-db.org/xquery/util";
declare option exist:serialize "media-type=text/plain";

let $eventId := request:get-parameter('id', ())
let $metadataXMLStr := request:get-parameter('metadataXML', ())
return
	if (empty($eventId) or $eventId eq '') then
		error((), 'No id specified')
	else if (empty($metadataXMLStr)) then
		error((), 'No metadataXML specified')
	else
		let $eventXML := utils:get-event($eventId)
		return
			if (empty($eventXML)) then
				error((), concat('Unknown id: ', $eventId))		
			else
				let $metadataXML := (util:parse($metadataXMLStr), <metadata/>)[1]
				let $null := update replace $eventXML/metadata with $metadataXML/*
				return concat('Sucessfully updated event: ', $eventId)
				
