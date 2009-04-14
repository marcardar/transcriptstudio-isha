xquery version "1.0";

import module namespace markup-category-fns = "http://www.ishafoundation.org/ts4isha/xquery/markup-category-fns" at "markup-category-fns.xqm";

let $id := request:get-parameter("id", ())
let $name := request:get-parameter("name", ())
let $markupTypeIds := tokenize(request:get-parameter("markupTypeIds", ''), '\s')
let $conceptIds := tokenize(request:get-parameter("conceptIds", ''), '\s')
return
	markup-category-fns:edit($id, $name, $markupTypeIds, $conceptIds)
