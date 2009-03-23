declare namespace get-all-concepts = "http://www.ishafoundation.org/ts4isha/xquery/get-all-concepts";

import module namespace concept-fns = "http://www.ishafoundation.org/ts4isha/xquery/concept-fns" at "concept-fns.xqm";

normalize-space(string-join(concept-fns:get-all-concepts(), ' '))
