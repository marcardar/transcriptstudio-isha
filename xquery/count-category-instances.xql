xquery version "1.0";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

(: Counts the number of times the concept appears in all documents (but not reference) :)

let $categoryId := request:get-parameter("categoryId", ())
return
	if (exists($categoryId)) then
		concept-fns:count-category-instances($categoryId)
	else
		0
