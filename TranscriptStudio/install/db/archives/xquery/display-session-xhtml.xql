xquery version "1.0";

declare namespace view-session-xhtml = "http://www.ishafoundation.org/archives/xquery/session-xhtml";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare function view-session-xhtml:transformToXHTML($doc as element(), $highlightId as xs:string?) as element()
{
    transform:transform($doc, doc('/db/archives/xslt/session-xhtml.xsl'), <parameters><param name="highlightId" value="{$highlightId}"/></parameters>)
};

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
    view-session-xhtml:transformToXHTML($doc, $highlightId)

