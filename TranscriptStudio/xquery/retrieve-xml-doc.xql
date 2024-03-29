xquery version "1.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

let $collectionPath := request:get-parameter('collectionPath', $utils:ts4ishaCollectionPath)
let $id := request:get-parameter('id', ())
let $tagName := request:get-parameter('tagName', ())
let $topElements :=
	if (not(exists($id))) then
		if (not(exists($tagName))) then
			collection($collectionPath)/*
		else
			collection($collectionPath)/*[local-name(.) = $tagName]
	else
		if (not(exists($tagName))) then
			collection($collectionPath)/*[@id = $id]
		else
			collection($collectionPath)/*[local-name(.) = $tagName and @id = $id]
return
	<result>{
		for $topElement in $topElements
		return utils:add-attributes($topElement, '_document-uri', document-uri(root($topElement)))
	}</result>