declare namespace add-synonyms = "http://www.ishafoundation.org/ts4isha/xquery/add-synonyms";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

let $conceptIds := tokenize(request:get-parameter("conceptIds", ''), '\s')
return
	concept-fns:add-synonyms($conceptIds)
