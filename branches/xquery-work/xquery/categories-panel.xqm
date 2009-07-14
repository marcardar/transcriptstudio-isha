xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare function categories-panel:main() as element()*
{	
	let $conceptId := request:get-parameter('conceptId', ())
	let $reference := $utils:referenceCollection/reference
	let $definedCategories := 
		if ($conceptId) then
			$reference/markupCategories/markupCategory/tag[@type eq 'concept' and @value eq $conceptId]/..
		else
			()
	let $additionalConceptElements := $utils:dataCollection/session/transcript//(superSegment|superContent)/tag[@type eq 'concept' and @value eq $conceptId]
	let $associatedCategoryRefs :=
		if ($conceptId) then
			$additionalConceptElements/../tag[@type eq 'markupCategory']
		else
			()
	return
	(
		<center><h2>Isha Foundation Markup Categories
			{
				if ($conceptId) then
				(
					<br/>
					,
					'(for concept: '
					,
					<a href="main.xql?panel=search&amp;search={$conceptId}&amp;defaultType=markup">{$conceptId}</a>
					,
					')'
				)
				else
					()
			}
		</h2></center>
	,
		let $mainCategoryDisplay :=
			if (exists($definedCategories)) then
			(
				<h3>Main categories</h3>,
				for $category in $definedCategories
				order by lower-case($category/@name)
				return
					<div class="category">
						<span>
							<a class="category-anchor" href="main.xql?panel=search&amp;search=markup:{$category/@id}">{concat($category/@name, search-fns:get-markup-category-concepts-string($category))}</a>
						</span>
					</div>
				,
					<br/>
			)
			else
				()
		return
		(
			$mainCategoryDisplay
		)
	,
		let $contextCategoryDisplay :=
			if (exists($associatedCategoryRefs)) then
			(
				<h3>Context related categories</h3>,
				for $categoryRef in $associatedCategoryRefs
				let $category := $reference/markupCategories/markupCategory[@id eq $categoryRef/string(@value)]
				order by lower-case($category/@name)
				return
					<div class="category">
						<span>
							<a class="category-anchor" href="main.xql?panel=search&amp;search=markup:{$category/@id} {$conceptId}">{concat($category/@name, search-fns:get-markup-category-concepts-string($category), ' +[', $conceptId, ']')}</a>
						</span>
					</div>
			)
			else
				()
		return
			$contextCategoryDisplay
	,
		let $allCategoryDisplay :=
			if (not(exists($conceptId))) then
			(
				<h3>All categories</h3>,
				for $category in $reference/markupCategories/markupCategory
				order by lower-case($category/@name)
				return
					<div class="category">
						<span>
							<a class="category-anchor" href="main.xql?panel=search&amp;search=markup:{$category/@id}">{concat($category/@name, search-fns:get-markup-category-concepts-string($category))}</a>
						</span>
					</div>
			)
			else
				()
		return
			$allCategoryDisplay
	)
};
