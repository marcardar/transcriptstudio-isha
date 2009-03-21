xquery version "1.0";

module namespace event-panel = "http://www.ishafoundation.org/ts4isha/xquery/event-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace util = "http://exist-db.org/xquery/util";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare function event-panel:transformToXHTML($event as element()) as element()
{
    transform:transform($event, doc('/db/ts4isha/xslt/event-xhtml.xsl'), ())
};

declare function event-panel:main() as element()*
{
	let $eventId := request:get-parameter("id", ())	
	let $event := collection('/db/ts4isha/data')//event[@id = $eventId]
	return
	(
		<center><h1>Isha Foundation Event: {$eventId}</h1></center>
	,
		if (empty($event)) then
		    if (exists($eventId)) then
		        <error>Could not find event with id: {$eventId}</error>
		    else 
			    <error>event id not specified</error>
		else
		(
			event-panel:transformToXHTML($event)
		,
			let $sessions := xcollection(util:collection-name($event))/session[starts-with(@id, string-join($eventId, '-'))]
			return
				if (exists($sessions)) then
				(
					<h2>Media IDs</h2>
				,
					<p>{event-panel:get-media-ids-csv-for-sessions($sessions)}</p>
				,
					<h2>Sessions ({count($sessions)})</h2>
				,
					<ol>
					{for $session in $sessions
					order by $session/@id
					return
						<li>
							<a href="main.xql?panel=session&amp;id={$session/@id}">Session: {$session/string(@subTitle)} {concat(' ', $session/string(@startAt))} [{event-panel:get-media-ids-csv-for-sessions($session)}]: {$session/string(@id)}</a>
							<br/>{$session/string(@comment)}<p/>							
						</li>
					}				
					</ol>
				)
				else
				(
					<h2>No Sessions</h2>
				)
		)
	)
};

declare function event-panel:get-media-ids-csv-for-sessions($sessions as element()*) as xs:string*
{
	upper-case(string-join(event-panel:get-media-ids-for-sessions($sessions), ', '))
};

declare function event-panel:get-media-ids-for-sessions($sessions as element()*) as xs:string*
{
	let $mediaIds := distinct-values($sessions/devices/device/media/string(@id))
	for $mediaId in $mediaIds
	order by $mediaId
	return $mediaId
};