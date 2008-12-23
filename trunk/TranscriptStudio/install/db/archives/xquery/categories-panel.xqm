xquery version "1.0";

module namespace categories-panel = "http://www.ishafoundation.org/archives/xquery/categories-panel";

import module namespace search-fns = "http://www.ishafoundation.org/archives/xquery/search-fns" at "search-fns.xqm";

declare function categories-panel:main() as element()*
{	
	(
		<center><h1>Isha Foundation Markup Categories</h1></center>
		,
		for $category in collection('/db/archives')/reference/categories/category
		order by lower-case($category/@name)
		return
			<div class="category">
				<span>{concat($category/@name, search-fns:get-markup-category-concepts-string($category))}</span>
			</div>
	)
};
