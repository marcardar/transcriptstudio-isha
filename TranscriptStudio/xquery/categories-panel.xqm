xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare function categories-panel:main() as element()*
{	
	let $concept := request:get-parameter('concept', ())
	let $reference := $utils:referenceCollection/reference
	let $categories := $reference/markupCategories/markupCategory
	return
	(
		<center><h2>Isha Foundation Markup Categories</h2></center>
		,
		<br/>
		,
		categories-panel:display-categories-for-concept($concept)
	)
};

declare function categories-panel:display-categories-for-concept($concept as xs:string)
{
	let $reference := $utils:referenceCollection/reference
	let $data := $utils:dataCollection
	let $categories := $reference/markupCategories/markupCategory
	let $conceptMatchCategories := $categories/tag[@value = $concept and @type eq 'concept']/.. 
	let $nameMatchCategories := $categories[search-fns:name-contains-concept(xs:string(@name), $concept)]
	let $filteredCategories := ($conceptMatchCategories, $nameMatchCategories)/.
	let $numCategories := count($filteredCategories)
	return
	(
		<b id="{$concept}">{$concept}:</b>
	,	
		<small><i>{$numCategories} categor{if ($numCategories = 1) then 'y' else 'ies'}</i></small>
	,
		<a href="main.xql?panel=search&amp;search=%2B{$concept}">[+]</a>
	,
		<br/>
	,
		<table cellspacing="0">		{
			for $category in $filteredCategories
			let $markups := search-fns:markups-for-category(($data//superSegment, $data//superContent), $category/xs:string(@id))
			let $markupsCount := count($markups)
			let $primaryMarkupType := $category/tag[@type eq "markupType"][1]/@value
			let $searchPriority := $reference//markupType[@id = $primaryMarkupType]/xs:integer(@searchOrder)
			order by $searchPriority
			return
			<tr>
				<td width="24"><img src="../assets/{$category/tag[@type='markupType'][1]/@value}.png" width="24" height="24"/></td>
				<td style="white-space: nowrap">
					<small>
						<a href="main.xql?panel=search&amp;search={$category/xs:string(@id)}&amp;defaultType=markup&amp;groupResults=false">{$category/xs:string(@name)}</a> ({$markupsCount}) <i>[{categories-panel:get-markup-category-concepts-links($category)}]</i>
					</small>
				</td>
			</tr>
		}
		</table>
	)
};


declare function categories-panel:get-markup-category-concepts-links($markupCategory as element()) as element()*
{
	let $conceptNames := $markupCategory/tag[@type = 'concept']/xs:string(@value)
	for $conceptName in $conceptNames
	return
		<a class="concept-anchor" href="main.xql?panel=categories&amp;concept={$conceptName}">{$conceptName}</a>
};

	
