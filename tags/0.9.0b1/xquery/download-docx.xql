(:declare option exist:serialize "media-type=application/zip"; :)

import module namespace transcriptstudio='http://ishafoundation.org/xquery/archives/transcript' at 'java:org.ishafoundation.archives.transcript.xquery.modules.TranscriptStudioModule';
import module namespace search-fns = "http://www.ishafoundation.org/archives/xquery/search-fns" at "search-fns.xqm";

let $sessionPath := request:get-parameter("sessionPath", ())
let $sessionId := request:get-parameter("sessionId", ())

let $encodedSessionPath := fn:iri-to-uri($sessionPath)
let $doc := doc($encodedSessionPath)
let $doc := ($doc, collection('/db/archives/data')/session[@id = $sessionId]) [1]
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
		let $event := collection('/db/archives/data')/event[@id = $eventId]
		let $eventPath := concat(util:collection-name($event), '/', util:document-name($event))
		let $wordML := transform:transform($doc, doc('/db/archives/xslt/export-msword.xsl'), <parameters><param name='eventPath' value='{$eventPath}'/></parameters>)
		return
			response:stream-binary(transcriptstudio:create-docx($wordML), "application/zip", $docxFilename)
	)