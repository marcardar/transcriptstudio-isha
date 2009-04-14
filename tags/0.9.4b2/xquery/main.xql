xquery version "1.0";

declare namespace main = "http://www.ishafoundation.org/ts4isha/xquery/main";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";

declare variable $defaultPanel := "search";

(:declare option exist:serialize "method=xhtml doctype-public=-//W3C//DTD XHTML 1.1//EN doctype-system=http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd";:) 
declare option exist:serialize "media-type=text/html"; 

import module namespace login-panel = "http://www.ishafoundation.org/ts4isha/xquery/login-panel" at "login-panel.xqm";
import module namespace search-panel = "http://www.ishafoundation.org/ts4isha/xquery/search-panel" at "search-panel.xqm";
import module namespace event-panel = "http://www.ishafoundation.org/ts4isha/xquery/event-panel" at "event-panel.xqm";
import module namespace session-panel = "http://www.ishafoundation.org/ts4isha/xquery/session-panel" at "session-panel.xqm";
import module namespace all-concepts-panel = "http://www.ishafoundation.org/ts4isha/xquery/all-concepts-panel" at "all-concepts-panel.xqm";
import module namespace categories-panel = "http://www.ishafoundation.org/ts4isha/xquery/categories-panel" at "categories-panel.xqm";

(:
	Select the page to show. Every page is defined in its own module 
:)
declare function main:display-panel($panel) as element()*
{
	if ($panel eq "login") then
	(
		login-panel:main()
	)
	else if ($panel eq "search") then
	(
		search-panel:main()
	)
	else if ($panel eq "event") then
	(
		event-panel:main()
	)
	else if ($panel eq "session") then
	(
		session-panel:main()
	)
	else if ($panel eq "all-concepts") then
	(
		all-concepts-panel:main()
	)
	else if ($panel eq "categories") then
	(
		categories-panel:main()
	)
	else
	(
		error((), concat('Unrecognised panel: ', $panel))
	)
};

(: main entry point :)
let $panel := request:get-parameter("panel", $defaultPanel)
let $highlightId := if (request:exists()) then
		request:get-parameter('highlightId', ())
	else
		()
(: loginStatus will be empty iff logged in :)
let $loginStatus :=
	if (xdb:get-current-user() != "guest") then
	(
		(: already logged in :)
		(: are we logging out? - i.e. set permissions back to guest :)
		if ($panel eq 'login') then
		(
			let $null := xdb:login("/db", "guest", "guest")
			return
				'Successfully logged out'
		)
		else
		(
			(: we are already logged in and we are not the guest user :)
		)
	)
	else
	(
		if (request:get-parameter-names() = 'user') then
		(
			let $user := request:get-parameter("user", 'admin')
			return
				(: is this a login attempt? :)
				if (not($user)) then
				(
					'No user specified'
				)
				else if ($user eq "guest") then
				(
					(: prevent the guest user from accessing the admin webapp :)
					concat('Not allowed to log in as ', $user)
				)
				else if (not(xdb:exists-user($user))) then
				(
					concat('Unknown user: ', $user)
				)
				else
				(
					let $success := xdb:login("/db", $user, request:get-parameter("pass", ()))
					return
						if ($success) then
							()
						else 
							'Invalid password'
				)
		)
		else
		(
			(: not a login attempt :)
			'Login required'
		)
	)
return
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Isha Foundation Transcripts</title>
			<link type="text/css" href="main.css" rel="stylesheet"/>
			{if ($highlightId) then
	            <style type="text/css">
					{concat('#', $highlightId, '{background-color:wheat; padding: 0 5px 0 5px;}')}
				</style>
			else ()
			}
		</head>
		<body>
			<div class="content">
				{
					if ($loginStatus) then
					(
						<p>{if ($loginStatus = 'Login required') then () else $loginStatus}</p>
						,
						login-panel:main()
					)
					else
					(
						<table width="100%"><tr>
						{if (not($panel eq 'search')) then
							<td align="left"><a href="{session:encode-url(request:get-uri())}?panel=search">New search</a></td>
						else
							()
						}
						<td align="right"><a href="{session:encode-url(request:get-uri())}?panel=login">Logout <b>{xdb:get-current-user()}</b></a></td>
						</tr></table>
						,
						main:display-panel($panel)
					)
				}
			</div>
		</body>
	</html>
		