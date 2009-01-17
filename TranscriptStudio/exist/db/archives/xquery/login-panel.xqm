xquery version "1.0";

module namespace login-panel = "http://www.ishafoundation.org/archives/xquery/login-panel";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare function login-panel:transformToXHTML($doc as element(), $highlightId as xs:string?) as element()
{
    transform:transform($doc, doc('/db/archives/xslt/session-xhtml.xsl'), ())
};

declare function login-panel:main() as element()*
{
	let $queryString := request:get-query-string()
	let $queryString := 
		if ($queryString) then
			if (not(contains($queryString, 'panel=login'))) then 
				concat('?', $queryString) 
			else
				'?panel=search'
		else
			'?panel=search'
			
	return
	(
		<center><h2>Isha Foundation Transcripts</h2></center>
	,
		<div class="panel">
			<form action="{session:encode-url(request:get-uri())}{$queryString}" method="post">
				<table class="login" cellpadding="5">
					<tr>
						<th colspan="2" align="left">Please Login</th>
					</tr>
					<tr>
						<td align="left">Username:</td>
						<td><input name="user" type="text" size="20"/></td>
					</tr>
					<tr>
						<td align="left">Password:</td>
						<td><input name="pass" type="password" size="20"/></td>
					</tr>
					<tr>
						<td colspan="2" align="left"><input type="submit"/></td>
					</tr>
				</table>
			</form>
		</div>
	)
};

