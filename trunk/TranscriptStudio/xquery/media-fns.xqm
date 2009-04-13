xquery version "1.0";

module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns";

declare namespace util = "http://exist-db.org/xquery/util";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

import module namespace functx = "http://www.functx.com" at "functx.xqm";

(: adds all newMedia elements to the device element defined by the sessionId
   the device id is obtained by looking at the newMedia's parent id
   if the device element does not exist then it is created
   if the mediaElement id already exists then it is not added
   returns all mediaElements that were added
   
   Note/TODO - we could try and work out the session id by looking at the ancestors of each newMedia...
:)
declare function media-fns:import-media-elements($importMediaXMLs as element()*, $sessionId as xs:string, $deviceId as xs:string) as xs:string*
{
	let $sessionXML := utils:get-session($sessionId)
	return
		if (empty($sessionXML)) then
			concat('Unknown sessionId: ', $sessionId)
		else
			let $mediaMetadataXML := media-fns:get-media-metadata-element($sessionXML)
			let $deviceXML := media-fns:get-device-element($deviceId, $mediaMetadataXML)
			return
				for $importMediaXML in $importMediaXMLs
				return
					util:catch('java.lang.Exception', 
						concat(media-fns:import-media-element($importMediaXML, $deviceXML), ': Success'),
						concat($importMediaXML/@id, ': Fail')
						)
};

declare function media-fns:import-media-element($importMediaXML as element(), $deviceXML as element()) as xs:string
{
	let $domain := local-name($importMediaXML)
	return
		if (not($domain = $id-utils:media-domains)) then
			error((), concat('Invalid mediaXML tag name: ', $domain))
		else
			let $importMediaId := $importMediaXML/@id
			return 
				if (exists($importMediaId)) then
					(: check whether id already exists :)
					let $null :=
						if (id-utils:id-already-exists($domain, $importMediaId)) then
							let $existingMediaXML := $deviceXML/*[local-name(.) eq $domain and @id eq $importMediaId]
							let $newMediaXML :=
								(: check that it exists for this session-device :)
								if (empty($existingMediaXML)) then
									error(xs:QName('illegal-argument-exception'), concat('mediaId already used for different session-device: ', $importMediaId))
								else
									(: merge the existing and new together :)
									element {$domain}
										{$existingMediaXML/@*
										,$importMediaXML/@*[not(local-name(.) = $existingMediaXML/@*/local-name(.))]
										,$existingMediaXML/*
										,$importMediaXML/*
										}
							return
								update replace $existingMediaXML with $newMediaXML
						else
							update insert $importMediaXML into $deviceXML
					return xs:string($importMediaId)
				else
					let $eventId := $deviceXML/ancestor::session/@eventId
					let $eventTypeId := utils:get-event($eventId)/@type
					let $newId := media-fns:get-next-media-id($domain, $eventTypeId)
					let $newMediaXML := functx:add-attributes($importMediaXML, xs:QName('id'), $newId)
					let $null := update insert $newMediaXML into $deviceXML
					return $newId
};

declare function media-fns:get-device-element($deviceId as xs:string, $mediaMetadataElement as element()) as element()
{
	let $deviceElements := $mediaMetadataElement/device[@id = $deviceId]
	return
		if (exists($deviceElements)) then
			$deviceElements[1]
		else
			let $null := update insert <device xmlns='' id='{$deviceId}'/> into $mediaMetadataElement
			return
				$mediaMetadataElement/device[@id = $deviceId][1]
};

(: creates mediaMetadata element if it does not exist :)
declare function media-fns:get-media-metadata-element($sessionElement as element()) as element()
{
	let $mediaMetadataElements := $sessionElement/mediaMetadata
	return
		if (exists($mediaMetadataElements)) then
			$mediaMetadataElements[1]
		else
			let $null := 
				if (exists($sessionElement/*)) then
					update insert <mediaMetadata xmlns=''/> preceding $sessionElement/*[1]
				else
					update insert <mediaMetadata xmlns=''/> into $sessionElement
			return
				$sessionElement/mediaMetadata[1]
};

declare function media-fns:extract-integer($str as xs:string?) as xs:integer?
{
	util:catch('java.lang.Exception', xs:integer(replace($str, '\D', '')), ())
};

declare function media-fns:get-next-media-id($domain as xs:string, $eventType as xs:string) as xs:string
{
	let $nextMediaIdInteger := (media-fns:get-next-media-id-integer($domain, $eventType), 1)[1]
	return
		concat($eventType, '-', $nextMediaIdInteger)
};

declare function media-fns:get-next-media-id-integer($domain as xs:string, $eventType as xs:string) as xs:integer?
{
	let $prefix := concat($eventType, '-')
	let $maxIdInt := (id-utils:get-max-id-integer($domain, $prefix), 0)[1]
	let $startDigitalAttrName :=
		if ($domain eq 'audio') then
			'startDigitalAudioId'
		else if ($domain eq 'video') then
			'startDigitalVideoId'
		else if ($domain eq 'image') then
			'startDigitalImageId'
		else
			error((), concat('Unknown domain: ', $domain))
	let $minIdInt := utils:get-event-type($eventType)/media-fns:extract-integer(@*[local-name(.) = $startDigitalAttrName])
	let $nextIdInt := max(($maxIdInt + 1, $minIdInt))
	return
		$nextIdInt
};