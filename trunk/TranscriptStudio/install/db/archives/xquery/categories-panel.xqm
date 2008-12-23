xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/archives/xquery/categories-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace search-fns = "http://www.ishafoundation.org/archives/xquery/search-fns" at "search-fns.xqm";

declare function categories-panel:main() as element()*
{	
	let $conceptId := request:get-parameter('conceptId', ())
	let $reference := collection('/db/archives')/reference
	let $categories := 
		if ($conceptId) then
			$reference/categories/category/tag[@type eq 'concept' and @value eq $conceptId]/..
		else
			$reference/categories/category
	return
	(
		<center><h1>Isha Foundation Markup Categories{
			if ($conceptId) then
			(
				<br/>
				,
				concat('(for concept: ', $conceptId, ')')
			)
			else ()
			}</h1></center>
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
			else
				<div>No categories for concept: {$conceptId}</div>
	)
};
