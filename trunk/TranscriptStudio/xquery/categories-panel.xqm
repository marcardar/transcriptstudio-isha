xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";

declare function categories-panel:main() as element()*
{	
	let $conceptId := request:get-parameter('conceptId', ())
	let $reference := collection('/db/ts4isha/reference')/reference
	let $categories := 
		if ($conceptId) then
			$reference/markupCategories/markupCategory/tag[@type eq 'concept' and @value eq $conceptId]/..
		else
			$reference/markupCategories/markupCategory
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
		if (exists($categories)) then
			for $category in $categories
			order by lower-case($category/@name)
			return
				<div class="category">
					<span>
						<a class="category-anchor" href="main.xql?panel=search&amp;search=markup:{$category/@id}">{concat($category/@name, search-fns:get-markup-category-concepts-string($category))}</a>
					</span>
				</div>
		else if ($conceptId) then
			<div>No categories for concept: {$conceptId}</div>
		else
			<div>No categories defined!</div>
	)
};
