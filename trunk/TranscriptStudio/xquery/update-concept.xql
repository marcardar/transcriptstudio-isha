declare namespace update-concept = "http://www.ishafoundation.org/ts4isha/xquery/update-concept";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

let $oldConceptId := request:get-parameter("oldConceptId", '')
let $newConceptId := request:get-parameter("newConceptId", '')

return
	if ($oldConceptId eq '') then
	(
		(: no $oldConceptId specified :)
		if ($newConceptId eq '') then
			(: no args specified so nothing to do :)
			0
		else
		(
			(: only the $newConceptId specified so this mean we are adding a new concept :)
			concept-fns:add($newConceptId)
		)
	)
	else if ($newConceptId eq '') then
	(
		(: no $newConceptId specified so remove the $oldConceptId :)
		concept-fns:remove($oldConceptId)
	)
	else
	(
		(: both args specified so rename $oldConceptId to $newConceptId :)
		concept-fns:rename($oldConceptId, $newConceptId)
	)
