xquery version "1.0";

(: declare option exist:serialize "media-type=text/plain";  :)

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns" at "search-fns.xqm";

let $searchString := request:get-parameter('searchString', ())
let $markupType := request:get-parameter('markupType', ('all'))

let $reference := $utils:referenceCollection/reference
let $categories := 
	if ($markupType eq 'all') then 
		$reference/markupCategories/markupCategory
	else
		$reference/markupCategories/markupCategory/tag[@type eq "markupType"][1][@value eq $markupType]/..
return
	<result>
	{
		for $category in search-fns:filter-categories($categories, $searchString, $markupType)
		let $primaryMarkupType := $category/tag[@type eq "markupType"][1]/@value
		let $searchPriority := $reference//markupType[@id = $primaryMarkupType]/xs:integer(@searchOrder)
		order by $searchPriority
		return 
			$category
	}
	</result>
		
