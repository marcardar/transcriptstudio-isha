(:declare option exist:serialize "media-type=application/zip"; :)

import module namespace transcriptstudio='http://ishafoundation.org/xquery/archives/transcript' at 'java:org.ishafoundation.archives.transcript.xquery.modules.TranscriptStudioModule';

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
		let $wordML := transform:transform($doc, doc('/db/archives/xslt/export-msword.xsl'), <parameters><param name='eventPath' value='{$sessionPath}'/></parameters>)
		return
			response:stream-binary(transcriptstudio:create-docx($wordML), "application/zip", $docxFilename)
	)