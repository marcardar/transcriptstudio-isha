xquery version "1.0";
 
declare namespace import-media-element = "http://www.ishafoundation.org/ts4isha/xquery/import-media-element";

declare option exist:serialize "media-type=text/plain";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

if (not(utils:is-current-user-admin())) then	
	error((xs:QName('access-control-exception')), 'Only admin user allowed to call this script')
else

let $sessionId := request:get-parameter("sessionId", ())
let $deviceId := request:get-parameter("deviceId", ())
let $mediaXML := util:parse(request:get-parameter("mediaXML", ()))
return
	if (empty($sessionId)) then
		error((), 'No sessionId specified')
	else if (empty($deviceId)) then
		error((), 'No deviceId specified')
	else if (empty($mediaXML)) then
		error((), 'No mediaXML specified')
	else
		let $domain := local-name($mediaXML)
		return
			if (not($domain = $id-utils:media-domains)) then
				error((), concat('Invalid mediaXML tag name: ', $domain))
			else
				let $sessionXML := utils:get-session($sessionId)
				return
					if (empty($sessionXML)) then
						error((), concat('Unknown sessionId: ', $sessionId))
					else
						let $mediaMetadataXML := media-fns:get-media-metadata-element($sessionXML)
						let $deviceXML := media-fns:get-device-element($deviceId, $mediaMetadataXML)
						let $importedMediaId := $mediaXML/@id
						return 
							if (exists($importedMediaId)) then
								(: check whether id already exists :)
								let $null :=
									if (id-utils:id-already-exists($domain, $importedMediaId)) then
										let $existingMediaXML := $deviceXML/*[local-name(.) eq $domain and @id eq $importedMediaId]
										let $newMediaXML :=
											(: check that it exists for this session-device :)
											if (empty($existingMediaXML)) then
												error(xs:QName('illegal-argument-exception'), concat('mediaId already used for different session-device: ', $importedMediaId))
											else
												(: merge the existing and new together :)
												element {$domain}
													{$existingMediaXML/@*
													,$mediaXML/@*[not(local-name(.) = $existingMediaXML/@*/local-name(.))]
													,$existingMediaXML/*
													,$mediaXML/*
													}
										return
											update replace $existingMediaXML with $newMediaXML
									else
										update insert $mediaXML into $deviceXML
								return xs:string($importedMediaId)
							else
								let $eventTypeId := utils:get-event($sessionXML/@eventId)/@type
								let $newId := id-utils:generate-id($domain, concat($eventTypeId, '-'))
								let $newMediaXML := functx:add-attributes($mediaXML, xs:QName('id'), $newId)
								let $null := update insert $newMediaXML into $deviceXML
								return $newId
				