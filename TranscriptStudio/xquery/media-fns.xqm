xquery version "1.0";

module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns";

declare namespace util = "http://exist-db.org/xquery/util";

import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

(: adds all newMedia elements to the device element defined by the sessionId
   the device id is obtained by looking at the newMedia's parent id
   if the device element does not exist then it is created
   if the mediaElement id already exists then it is not added
   returns all mediaElements that were added
   
   Note/TODO - we could try and work out the session id by looking at the ancestors of each newMedia...
:)
declare function media-fns:append-media-elements($newMediaElements as element()*, $sessionId as xs:string) as xs:string*
{
	let $session := collection('/db/ts4isha/data')/session[@id = $sessionId]
	return
		if (not(exists($session))) then
			concat('No media elements imported for unknown session id: ', $sessionId)
		else
			let $mediaMetadataElement := media-fns:get-media-metadata-element($session)
			return
				for $newMedia in $newMediaElements
				let $deviceId := $newMedia/../@id
				return
					if (not(exists($deviceId))) then
						()
					else
						let $device := media-fns:get-device-element($deviceId, $mediaMetadataElement)
						return media-fns:append-media-element($newMedia, $device)
};

declare function media-fns:append-media-element($newMediaElement as element(), $deviceElement as element()) as xs:string
{
	let $tagName := local-name($newMediaElement)
	let $newId := $newMediaElement/xs:string(@id)
	let $detailPrefix := concat($tagName, ' [@id = ', $newId, '] - ')
	let $msg :=
		if (not($tagName = $id-utils:media-domains)) then
			concat('NOT IMPORTED because illegal tag name: ', $tagName)
		else
			let $existingMediaElements := collection('/db/ts4isha/data')//*[local-name(.) eq $tagName and @id = $newId]
			return
				if (exists($existingMediaElements)) then
					'NOT IMPORTED because already exists'
				else
					let $null := update insert $newMediaElement into $deviceElement
					return
						'IMPORTED'
	return
		concat($detailPrefix, $msg) 
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