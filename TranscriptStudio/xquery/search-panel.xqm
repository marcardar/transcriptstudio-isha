xquery version "1.0";

module namespace search-panel = "http://www.ishafoundation.org/ts4isha/xquery/search-panel";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

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
				<form id="search-form">
					<input type="hidden" name="panel" value="search"/>
					<table id="search-form-table" cellpadding="2"><tr>
						<td>Search</td>
						<td><select name="defaultType">
							{
							for $i in (1 to 3)
							let $thisValue := $defaultTypeValues[$i]
							let $thisName := $defaultTypeNames[$i]
							return
								<option value="{$thisValue}">
								{if ($defaultType = $thisValue) then attribute selected {'selected'} else ()}
								{$thisName}
								</option>
							}
						</select></td>
						<td>for</td>
						<td><input type="text" name="search" size="50" value="{if (not($searchString = $notSearchingNow)) then $searchString else ()}"/></td>
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
				(
					<hr/>
				,
					if ($searchString) then
						search-fns:main($searchString, $defaultType)
					else
						'Blank search string'
				)
			}
			<hr/>
			<div class="additional-info">
				Additional info: <a href="main.xql?panel=all-concepts">concepts</a>, <a href="main.xql?panel=categories">categories</a>
			</div>
			{
				if (utils:is-current-user-admin()) then
					<div class="additional-info">
						Admin: <a href="main.xql?panel=admin">ts4isha</a>, <a href="../../../../admin/admin.xql">eXist db</a>
					</div>
				else
					()
			}
			<div class="additional-info">
				Utilities: <a href="main.xql?panel=ids">id lookup</a>
			</div>
			<br/>
		</div>
	)
};
