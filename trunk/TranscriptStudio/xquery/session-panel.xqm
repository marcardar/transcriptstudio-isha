xquery version "1.0";

module namespace session-panel = "http://www.ishafoundation.org/ts4isha/xquery/session-panel";

declare namespace request = "http://exist-db.org/xquery/request";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare function session-panel:transformToXHTML($doc as element()) as element()
{
    transform:transform($doc, doc('/db/ts4isha/xslt/session-xhtml.xsl'), ())
};

declare function session-panel:main() as element()*
{
	let $sessionId := request:get-parameter("id", ())	
	let $doc := collection('/db/ts4isha/data')/session[@id = $sessionId]
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
		    session-panel:transformToXHTML($doc)
	)
};
