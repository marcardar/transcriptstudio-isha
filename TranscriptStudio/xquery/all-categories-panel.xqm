xquery version "1.0";

module namespace all-categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/all-categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace ngram = "http://exist-db.org/xquery/ngram";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare function all-categories-panel:main() as element()*
{	
	let $categories-cached := session:get-attribute("categories-cached")
	return
		if (exists($categories-cached)) then
			$categories-cached
		else
			(
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

				let $categoriesHtml :=
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
					let $concept-no-hyphens := replace($concept, "-", " ")
					let $startChar := substring($concept, 1, 1)
					let $conceptMatchCategories := $categories/tag[@value = $concept and @type eq 'concept']/.. 
					let $ngramNameMatchCategories := ngram:contains($categories/@name, $concept-no-hyphens)/..
					let $nameMatchCategories := $ngramNameMatchCategories[search-fns:name-contains-concept(xs:string(@name), $concept-no-hyphens)]
					let $filteredCategories := ($conceptMatchCategories, $nameMatchCategories)/.
					return
						<div id="{$startChar}">
							<b id="{$concept}"><a href="main.xql?panel=categories&amp;concept={$concept}">{$concept}:</a></b>
							{all-categories-panel:create-table($concept, $filteredCategories)}
						</div>
					,
						<br/>
				)
				return
				(
					session:set-attribute("categories-cached", $categoriesHtml),
					$categoriesHtml
				)
			)
	
};


declare function all-categories-panel:create-table($concept as xs:string, $categories as element()*) as element()*
{
	let $numCategories := count($categories)
	return
	(
		<small><i>{$numCategories} categor{if ($numCategories = 1) then 'y' else 'ies'}</i></small>
	,
		<a href="main.xql?panel=search&amp;search=%2B{$concept}">[+]</a>
	,
		<small><i><a href="#top">(top)</a></i></small>
	,
		<br/>
	,
		if ($numCategories = 0) then
			<br/>		
		else
			<table cellspacing="0">
			{
				let $numCategories := count($categories)
				for $category in $categories
				let $primaryMarkupType := $category/tag[@type eq "markupType"][1]/@value
				let $reference := $utils:referenceCollection/reference
				let $searchPriority := $reference//markupType[@id = $primaryMarkupType]/xs:integer(@searchOrder)
				order by $searchPriority
				return
				<tr>
					<td width="24"><img src="../assets/{$category/tag[@type='markupType'][1]/@value}.png" width="24" height="24"/></td>
					<td style="white-space: nowrap">
						<small>
							<a href="main.xql?panel=search&amp;search={$category/xs:string(@id)}&amp;defaultType=markup&amp;groupResults=false">{$category/xs:string(@name)}</a> <i>[{all-categories-panel:get-markup-category-concepts-links($category)}]</i>
						</small>
					</td>
				</tr>
			}
			</table>
		,
			<br/>
	)
};

declare function all-categories-panel:get-markup-category-concepts-links($markupCategory as element()) as element()*
{
	let $conceptNames := $markupCategory/tag[@type = 'concept']/xs:string(@value)
	for $conceptName in $conceptNames
	return
		<a class="concept-anchor" href="#{$conceptName}">{$conceptName}</a>
};
