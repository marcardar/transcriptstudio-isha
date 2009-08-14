xquery version "1.0";

module namespace ids-panel = "http://www.ishafoundation.org/ts4isha/xquery/ids-panel";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils" at "id-utils.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace util = "http://exist-db.org/xquery/util";

declare function ids-panel:main() as element()*
{
	<center><h2>Isha Foundation Media ID Lookup</h2></center>,
	let $domain := request:get-parameter('domain', ())
	let $eventType := request:get-parameter('eventType', ())
	let $number := request:get-parameter('number', ())
	let $action := request:get-parameter('action', ())
	let $uploadedFilename := request:get-uploaded-file-name("upload-media-metadata")
	let $domainExists := util:catch('java.lang.Exception', exists(media-fns:get-reserve-attr-name($domain)), false())
	let $eventTypeExists := exists(utils:get-event-type($eventType))
	return
	<div class="panel">
		<h3>Find max ID</h3>
		<form id="find-max-id-form" action="{request:get-uri()}">
			<input type="hidden" name="panel" value="ids"/>
			<input type="hidden" name="action" value="get-max"/>
			<table id="find-max-id-form-table" cellpadding="2"><tr>
				<td>Domain</td>
				<td><select name="domain">
					{
					for $thisDomain in $id-utils:media-domains
					return
						<option value="{$thisDomain}">
						{if ($domain = $thisDomain) then attribute selected {'selected'} else ()}
						{$thisDomain}
						</option>
					}
				</select></td>
				<td>with event type</td>
				<td><input type="text" name="eventType" size="5" value="{if (exists($eventType)) then $eventType else ()}"/></td>
				<td><input type="submit" value="Find"/></td> 
			</tr></table>
		</form>
		{if ($domainExists and $eventTypeExists and utils:is-current-user-in-group($domain)) then
			(<h3>Reserve IDs</h3>,
			<form id="reserve-ids-form" action="{request:get-uri()}" method="post">
				<input type="hidden" name="panel" value="ids"/>
				<input type="hidden" name="action" value="reserve"/>
				<input type="hidden" name="domain" value="{$domain}"/>
				<input type="hidden" name="eventType" value="{$eventType}"/>
				<table id="reserve-ids-form-table" cellpadding="2"><tr>
					<td>Reserve the next </td>
					<td><input type="text" name="number" size="5"/></td>
					<td>ids for domain '<b>{$domain}</b>' with event type '<b>{$eventType}</b>'</td>
					<td><input type="submit" value="Submit"/></td> 
				</tr></table>
			</form>)
		else ()}
		<hr/>
		{
		if (not($eventTypeExists)) then
			<p>event type not found: <b>{$eventType}</b></p>
		else if ($action = 'get-max') then
			ids-panel:process-id-lookup($domain, $eventType)
		else if ($action = 'reserve') then
			ids-panel:process-reserve-ids($domain, $eventType, $number)
		else ()
		}			
	</div>
};

declare function ids-panel:process-id-lookup($domain as xs:string, $eventType as xs:string?) as element()*
{
	if (not(exists($eventType)) or normalize-space($eventType) = '') then
		<span>Cannot specify blank event type</span>
	else
	(
		let $nextIdInteger := media-fns:get-next-media-id-integer($domain, $eventType)
		return
		(	
			<p>For domain '{<b>{$domain}</b>}' and event type '{<b>{$eventType}</b>}':</p>,
			<p>Next available id: <b>{$nextIdInteger}</b></p>,
			let $max-id-int-database := id-utils:get-max-id-integer($domain, concat($eventType, '-'))
			return
				if ($max-id-int-database > 0) then
					<p>Last id stored: <b>{$max-id-int-database}</b></p>
				else
					<p>No ids stored</p>
		)
	)
};

declare function ids-panel:process-reserve-ids($domain as xs:string, $eventType as xs:string, $number as xs:string) as element()*
{
	if (not(exists($number)) or normalize-space($number) = '') then
		<span>You must specify a number of ids to reserve</span>
	else if (not(matches($number, '[0-9]+'))) then
		<span>You must specify a positive integer number of ids to reserve</span>
	else if (not(xs:integer($number) > 0)) then
		<span>You must specify a positive integer number of ids to reserve</span>
	else 
		let $nextIdInteger := media-fns:get-next-media-id-integer($domain, $eventType)
		let $newReservedInteger := $nextIdInteger + xs:integer($number) - 1
		let $lastReservedAttrName := media-fns:get-reserve-attr-name($domain)
		let $reserveElement := $utils:referenceCollection/nextMediaIds//eventType[@idRef = $eventType]
		let $newReserveElement := element {node-name($reserveElement)} { $reserveElement/@*[not(local-name(.) = $lastReservedAttrName)], attribute {$lastReservedAttrName} {$newReservedInteger} }
		let $null := update replace $reserveElement with $newReserveElement
		return
			(<p>The following ids have been reserved:</p>,
			<ul>{
			for $i in $nextIdInteger to $newReservedInteger
			return
				<li list-style="none"><b>{$domain}-{$eventType}-{$i}</b></li>
			}</ul>)
};

