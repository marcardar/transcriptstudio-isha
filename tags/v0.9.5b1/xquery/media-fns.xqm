xquery version "1.0";

module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns";

(: adds all newMedia elements to the device element defined by the sessionId
   the device id is obtained by looking at the newMedia's parent id
   if the device element does not exist then it is created
   if the mediaElement id already exists then it is not added
   returns all mediaElements that were added
   
   Note/TODO - we could try and work out the session id by looking at the ancestors of each newMedia...
:)
declare function media-fns:append-media-elements($newMediaElements as element()*, $sessionId as xs:string) as element()*
{
	let $session := collection('/db/ts4isha/data')/session[@id = $sessionId]
	return
		if (not(exists($session))) then
			error(concat('Could not find session id: ', $sessionId))
		else
			let $devicesElement := media-fns:get-devices-element($session)
			return
				for $newMedia in $newMediaElements
				let $deviceId := $newMedia/../@id
				return
					if (not(exists($deviceId))) then
						()
					else
						let $device := media-fns:get-device-element($deviceId, $devicesElement)
						return media-fns:append-media-element($newMedia, $device)
};



declare function media-fns:append-media-element($newMediaElement as element(), $deviceElement as element()) as element()?
{
	let $existingMediaElements := $deviceElement/media[@id = $newMediaElement/@id]
	return
		if (exists($existingMediaElements)) then
			()
		else
			let $null := update insert $newMediaElement into $deviceElement
			return
				$deviceElement/media[@id = $newMediaElement/@id][1]
};

declare function media-fns:get-device-element($deviceId as xs:string, $devicesElement as element()) as element()
{
	let $deviceElements := $devicesElement/device[@id = $deviceId]
	return
		if (exists($deviceElements)) then
			$deviceElements[1]
		else
			let $null := update insert <device xmlns='' id='{$deviceId}'/> into $devicesElement
			return
				$devicesElement/device[@id = $deviceId][1]
};

(: creates devices element if it does not exist :)
declare function media-fns:get-devices-element($sessionElement as element()) as element()
{
	let $devicesElements := $sessionElement/devices
	return
		if (exists($devicesElements)) then
			$devicesElements[1]
		else
			let $null := 
				if (exists($sessionElement/*)) then
					update insert <devices xmlns=''/> preceding $sessionElement/*[1]
				else
					update insert <devices xmlns=''/> into $sessionElement
			return
				$sessionElement/devices[1]
};