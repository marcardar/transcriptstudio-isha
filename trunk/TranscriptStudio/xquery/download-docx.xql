xquery version "1.0";

import module namespace ts4isha='http://ishafoundation.org/ts4isha/xquery' at 'java:org.ishafoundation.ts4isha.xquery.modules.TranscriptStudioModule';
import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";

let $sessionPath := request:get-parameter("sessionPath", ())
let $doc := 
	if (exists($sessionPath)) then
		let $result := doc(fn:iri-to-uri($sessionPath))
		return
			if (not(exists($result))) then
				error((), 'Could not find document at path: {$sessionPath}')
			else
				$result
	else
		let $sessionId := request:get-parameter("sessionId", ())
		return
			if (exists($sessionId)) then
				let $result := collection('/db/ts4isha/data')/session[@id = $sessionId]
				return
					if (not(exists($result))) then
					    error((), 'Could not find document with id: {$sessionId}')
					else
						$result
			else
				error((), 'Neither sessionPath nor sessionId specified')
return 
	let $docxFilename := replace(util:document-name($doc), '.xml$', '.docx')
	let $sessionId := $doc/xs:string(@id)
	return
		if (not(exists($sessionId))) then
			error((), 'Could not find sessionId in doc')
		else
			let $eventId := search-fns:get-event-id($sessionId)
			return
				if (not(exists($eventId))) then
					error((), 'Could not find eventId for session: {$sessionId}')
				else
					let $event := collection('/db/ts4isha/data')/event[@id = $eventId]
					let $eventPath := concat(util:collection-name($event), '/', util:document-name($event))
					let $wordML := transform:transform($doc, doc('/db/ts4isha/xslt/session-wordml.xsl'), <parameters><param name='eventPath' value='{$eventPath}'/></parameters>)
					return
						response:stream-binary(ts4isha:create-docx($wordML), "application/zip", $docxFilename)
