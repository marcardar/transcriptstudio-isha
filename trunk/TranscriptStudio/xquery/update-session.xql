xquery version "1.0";

declare namespace update-session = "http://www.ishafoundation.org/ts4isha/xquery/update-session";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare option exist:serialize "media-type=text/plain";

declare function update-session:process-child-element($sessionXML as element(), $newChildXML as element()?, $tagName as xs:string) as xs:string?
{
	if (exists($newChildXML)) then
		let $newChildXMLTagName := local-name($newChildXML)
		let $null :=
			if ($newChildXMLTagName eq $tagName) then
				utils:set-child-element($sessionXML, $newChildXML)
			else
				error((), concat('Invalid root element name: ', $newChildXMLTagName))
		return
			$tagName
	else
		()
};

let $sessionId := request:get-parameter('id', ())
return
	if (empty($sessionId)) then
		error((), 'No id specified')
	else
		let $metadataXML := util:parse(request:get-parameter('metadataXML', ()))
		let $mediaMetadataXML := util:parse(request:get-parameter('mediaMetadataXML', ()))
		let $transcriptXML := util:parse(request:get-parameter('transcriptXML', ()))
		return
			if (empty(($metadataXML, $mediaMetadataXML, $transcriptXML))) then
				concat('Nothing to update for session: ', $sessionId)
			else
				let $sessionXML := utils:get-session($sessionId)
				return
					if (empty($sessionXML)) then
						error((), concat('Unknown id: ', $sessionId))
					else
						(
							'Updated '
						,
						string-join(
						(
							update-session:process-child-element($sessionXML, $metadataXML/*, 'metadata')
						,
							update-session:process-child-element($sessionXML, $mediaMetadataXML/*, 'mediaMetadata')
						,
							update-session:process-child-element($sessionXML, $transcriptXML/*, 'transcript')
						), ', ')
						,
							' for session id: ', $sessionId)	
