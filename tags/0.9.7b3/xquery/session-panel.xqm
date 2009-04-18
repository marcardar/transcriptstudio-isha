xquery version "1.0";

module namespace session-panel = "http://www.ishafoundation.org/ts4isha/xquery/session-panel";

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare namespace request = "http://exist-db.org/xquery/request";

declare function session-panel:transformToXHTML($doc as element()) as element()
{
    utils:transform($doc, 'session-xhtml.xsl', ())
};

declare function session-panel:main() as element()*
{
	let $sessionId := request:get-parameter("id", ())	
	let $doc := $utils:dataCollection/session[@id = $sessionId]
	return
	(
		<center><h1>Isha Foundation Session</h1></center>
	,
		if (empty($doc)) then
		    if (exists($sessionId)) then
		        <error>Could not find document with id: {$sessionId}</error>
		    else 
			    <error>sessionId not specified</error>
		else
		    session-panel:transformToXHTML($doc)
	)
};
