import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

(: Counts the number of times the concept appears in all documents (but not reference) :)

let $conceptId := request:get-parameter("conceptId", ())
return
	if (exists($conceptId)) then
		concept-fns:count-concept-instances($conceptId)
	else
		0
