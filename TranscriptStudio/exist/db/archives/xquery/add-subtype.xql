declare namespace add-subtype = "http://www.ishafoundation.org/archives/xquery/add-subtype";

import module namespace concept-fns = "http://www.ishafoundation.org/archives/xquery/concept-fns" at "concept-fns.xqm";

let $superConceptId := request:get-parameter("superConceptId", ())
let $subConceptId := request:get-parameter("subConceptId", ())
return
	concept-fns:add-subtype($superConceptId, $subConceptId)
