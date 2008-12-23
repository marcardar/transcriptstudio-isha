xquery version "1.0";

module namespace search-panel = "http://www.ishafoundation.org/archives/xquery/search-panel";

import module namespace search-fns = "http://www.ishafoundation.org/archives/xquery/search-fns" at "search-fns.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

declare function search-panel:main() as element()*
{
	let $defaultTypeValues := ('markup', 'text', 'event') 
	let $defaultTypeNames := ('Markups', 'Text', 'Events')
	let $notSearchingNow := 'notsearchingnow' 
	let $searchString := if (request:exists()) then
			normalize-space(request:get-parameter('search', $notSearchingNow))
		else
			()
	let $defaultType := if (request:exists()) then
			normalize-space(request:get-parameter('defaultType', ('markup')))
		else
			()
	return
	(
		<center><h2>Isha Foundation Transcript &amp; Event Search</h2></center>
	,
		<div class="panel">
			<center>
			<table id="header">
				<tr><td valign="bottom">
				<form id="search-form" action="{session:encode-url(request:get-uri())}">
					<input type="hidden" name="panel" value="search"/>
					<table id="search-form-table"><tr>
						<td><input type="text" name="search" size="50" value="{if (not($searchString = $notSearchingNow)) then $searchString else ()}"/></td>
						<td><select name="defaultType">
							{
							for $i in (1 to 3)
							let $thisValue := $defaultTypeValues[$i]
							let $thisName := $defaultTypeNames[$i]
							return
								if ($defaultType = $thisValue) then
									<option value="{$thisValue}" selected="selected">{$thisName}</option>
								else
									<option value="{$thisValue}">{$thisName}</option>
								
							}
						</select></td>
						<td><input type="submit" value="Search"/></td> 
					</tr></table>
				</form>
				</td></tr>
			</table>
			</center>
			{
			if (request:get-parameter('search', 'notsearchingnow') = 'notsearchingnow') then
				()
			else
				(<hr/>,
				if ($searchString) then
					search-fns:main($searchString, $defaultType)
				else
					'Blank search string'
				)
			}
			<hr/>
			Additional info: <a href="main.xql?panel=concepts">concepts</a>, <a href="main.xql?panel=categories">categories</a>
		</div>
	)
};
