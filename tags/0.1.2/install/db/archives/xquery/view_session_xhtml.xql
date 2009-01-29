xquery version "1.0";

import module namespace session_xhtml = "http://ishafoundation.org/archives/xquery/session_xhtml" at "xmldb:exist:///db/archives/xquery/session_xhtml.xqm";

let $sessionId := if (request:exists()) then
        request:get-parameter("sessionId", ())
    else
        'y2004m04d20e01s01'
let $highlightId := if (request:exists()) then
        request:get-parameter("highlightId", ())
    else
        'o1'

let $doc := collection('/db/archives/data')/session[@id = $sessionId]

return if (empty($doc)) then
    if (exists($sessionId)) then
        <error>Could not find document with id: {$sessionId}</error>
    else 
	    <error>sessionId not specified</error>
else
    session_xhtml:html($doc, $highlightId)
