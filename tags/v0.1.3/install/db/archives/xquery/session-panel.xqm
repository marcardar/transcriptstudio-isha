xquery version "1.0";

module namespace session-panel = "http://www.ishafoundation.org/archives/xquery/session-panel";

declare namespace request = "http://exist-db.org/xquery/request";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare function session-panel:transformToXHTML($doc as element(), $highlightId as xs:string?) as element()
{
    transform:transform($doc, doc('/db/archives/xslt/session-xhtml.xsl'), ())
};

declare function session-panel:main() as element()*
{
	let $sessionId := if (request:exists()) then
	        request:get-parameter("id", ())
	    else
	        'y2004m04d20e01s01'
	let $highlightId := if (request:exists()) then
	        request:get-parameter("highlightId", ())
	    else
	        'o1'
	
	let $doc := collection('/db/archives/data')/session[@id = $sessionId]
	
	return
	(
		<center><h1>Isha Foundation Transcript</h1></center>
	,
		if (empty($doc)) then
		    if (exists($sessionId)) then
		        <error>Could not find document with id: {$sessionId}</error>
		    else 
			    <error>sessionId not specified</error>
		else
		    session-panel:transformToXHTML($doc, $highlightId)
	)
};
