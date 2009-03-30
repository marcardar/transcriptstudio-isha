(:declare option exist:serialize "media-type=application/zip"; :)

import module namespace ts4isha='http://ishafoundation.org/ts4isha/xquery' at 'java:org.ishafoundation.ts4isha.xquery.modules.TranscriptStudioModule';
import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";

let $sessionPath := request:get-parameter("sessionPath", ())
let $sessionId := request:get-parameter("sessionId", ())

let $encodedSessionPath := fn:iri-to-uri($sessionPath)
let $doc := doc($encodedSessionPath)
let $doc := ($doc, collection('/db/ts4isha/data')/session[@id = $sessionId]) [1]
return 
	if (empty($doc)) then
	(
		if (exists($sessionPath)) then
			<error>Could not find document at path: {$sessionPath}</error>
		else if (exists($sessionId)) then
		    <error>Could not find document with id: {$sessionId}</error>
		else 
			<error>Neither sessionPath nor sessionId specified</error>
	)
	else
	(
		let $docxFilename := replace(util:document-name($doc), '.xml$', '.docx')
		let $eventId := search-fns:get-event-id($doc/@id)
		let $event := collection('/db/ts4isha/data')/event[@id = $eventId]
		let $eventPath := concat(util:collection-name($event), '/', util:document-name($event))
		let $wordML := transform:transform($doc, doc('/db/ts4isha/xslt/session-wordml.xsl'), <parameters><param name='eventPath' value='{$eventPath}'/></parameters>)
		return
			response:stream-binary(ts4isha:create-docx($wordML), "application/zip", $docxFilename)
	)