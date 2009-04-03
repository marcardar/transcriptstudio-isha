xquery version "1.0";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

let $conceptId := request:get-parameter("conceptId", ())
return
	if (exists($conceptId)) then
		concept-fns:remove-synonym($conceptId)
	else
		()
