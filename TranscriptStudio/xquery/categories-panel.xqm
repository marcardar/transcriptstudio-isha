xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare function categories-panel:main() as element()*
{	
	let $reference := $utils:referenceCollection/reference
	let $categoryConcepts := $reference/markupCategories/markupCategory/tag[@type eq 'concept']/string(@value)
	let $coreConcepts := $reference/coreConcepts/concept/string(@id)
	let $subtypeConcepts := $reference/coreConcepts/concept/subtype/string(@idRef)
	let $synonymConcepts := $reference/synonymGroups/synonymGroup/synonym/string(@idRef)
	let $additionalConcepts := $utils:dataCollection/session/transcript//(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	let $concepts := 
		for $concept in distinct-values(($categoryConcepts, $coreConcepts, $subtypeConcepts, $synonymConcepts, $additionalConcepts))
		order by $concept 
		return $concept

	let $categories := $reference/markupCategories/markupCategory

	return
	(
		<center><h2>Isha Foundation Markup Categories</h2></center>
		,
		<center>{
		for $startCharIndex in (0 to 25)
		let $startChar := codepoints-to-string($startCharIndex + 97)
		return
			<a href="#{$startChar}">{upper-case($startChar)}</a>
		}</center>
		,
		<br/>
		,
		for $concept in $concepts
		let $startChar := substring($concept, 1, 1)
		let $conceptMatchCategories := $categories/tag[@value = $concept and @type eq 'concept']/..
		let $nameMatchCategories := $categories[functx:contains-word(xs:string(@name), $concept)]
		let $filteredCategories := ($conceptMatchCategories, $nameMatchCategories)/.
		return
			<div id="{$startChar}">
				<b id="{$concept}">{$concept}:</b>
				{categories-panel:create-table($filteredCategories)}
			</div>
		,
			<br/>
	)
};


declare function categories-panel:create-table($categories as element()*) as element()*
{
	let $numCategories := count($categories)
	return
	(
		<small><i>{$numCategories} categor{if ($numCategories = 1) then 'y' else 'ies'}</i></small>
	,
		<small><i><a href="#top">(top)</a></i></small>
	,
		<br/>
	,
		if ($numCategories = 0) then
			<br/>		
		else
			<table cellspacing="0">			{
				let $numCategories := count($categories)
		(:let $data := $utils:dataCollection:)
				for $category in $categories
		(:let $markups := search-fns:markups-for-category(($data//superSegment, $data//superContent), $category/xs:string(@id)):)
		(:let $markupsCount := count($markups):)
				let $primaryMarkupType := $category/tag[@type eq "markupType"][1]/@value
				let $reference := $utils:referenceCollection/reference
				let $searchPriority := $reference//markupType[@id = $primaryMarkupType]/xs:integer(@searchOrder)
				order by $searchPriority
				return
				<tr>
					<td width="24"><img src="../assets/{$category/tag[@type='markupType'][1]/@value}.png" width="24" height="24"/></td>
					<td style="white-space: nowrap">
						<small>
							<a href="main.xql?panel=search&amp;search={$category/xs:string(@id)}&amp;defaultType=markup">{$category/xs:string(@name)}</a> <i>[{categories-panel:get-markup-category-concepts-links($category)}]</i>
						</small>
					</td>
				</tr>
			}
			</table>
		,
			<br/>
	)
};

declare function categories-panel:get-markup-category-concepts-links($markupCategory as element()) as element()*
{
	let $conceptNames := $markupCategory/tag[@type = 'concept']/xs:string(@value)
	for $conceptName in $conceptNames
	return
		<a class="concept-anchor" href="#{$conceptName}">{$conceptName}</a>
};

	
