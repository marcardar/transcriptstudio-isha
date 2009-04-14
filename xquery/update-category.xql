xquery version "1.0";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

let $categoryId := request:get-parameter("categoryId", '')
return
	concept-fns:remove-category($categoryId)
