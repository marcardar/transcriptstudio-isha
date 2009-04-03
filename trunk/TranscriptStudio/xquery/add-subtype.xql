xquery version "1.0";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

let $superConceptId := request:get-parameter("superConceptId", ())
let $subConceptId := request:get-parameter("subConceptId", ())
return
	concept-fns:add-subtype($superConceptId, $subConceptId)
