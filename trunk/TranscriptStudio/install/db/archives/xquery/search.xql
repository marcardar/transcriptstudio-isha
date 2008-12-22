xquery version "1.0";
(: $Id: admin.xql 6739 2007-10-19 14:24:20Z deliriumsky $ :)
(:
	Main module of the database administration interface.
:)

declare namespace search = "http://www.ishafoundation.org/archives/xquery/search";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";

import module namespace search-panel = "http://www.ishafoundation.org/archives/xquery/search-panel" at "search-panel.xqm";

(:
	Select the page to show. Every page is defined in its own module 
:)
declare function search:panel() as element()
{
	let $panel := request:get-parameter("panel", "status") return
		if($panel eq "search") then
		(
			search-panel:main()
		)
		else
		(
			search-panel:main()
		)
};

(:~  
	Display the login form.
:)
declare function search:display-login-form() as element()
{
	<div class="panel">
		<form action="{session:encode-url(request:get-uri())}" method="post">
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
};

(: main entry point :)
let $isLoggedIn :=  if(xdb:get-current-user() eq "guest")then
	(
		(: is this a login attempt? :)
		if(request:get-parameter("user", ()) and not(empty(request:get-parameter("pass", ()))))then
		(
			if(request:get-parameter("user", ()) eq "guest")then
			(
				(: prevent the guest user from accessing the admin webapp :)
				false()
			)
			else
			(
				(: try and log the user in :)
				xdb:login("/db", request:get-parameter("user", ()), request:get-parameter("pass", ()))
			)
		)
		else
		(
			(: prevent the guest user from accessing the admin webapp :)
			false()
		)
	)
	else
	(
		(: if we are already logged in, are we logging out - i.e. set permissions back to guest :)
		if(request:get-parameter("logout",()))then
		(
			let $null := xdb:login("/db", "guest", "guest") return
				false()
		)
		else
		(
			 (: we are already logged in and we are not the guest user :)
			true()
		)
	)
return

	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Isha Foundation Transcript Search</title>
			<link type="text/css" href="main.css" rel="stylesheet"/>
		</head>
		<body>
			<!-- div class="header">
				{admin:info-header()}
				<img src="logo.jpg"/>
			</div-->
			
			<div class="content">
				{
					if($isLoggedIn)then
						<p align="right"><a href="{session:encode-url(request:get-uri())}?logout=yes">Logout <b>{xdb:get-current-user()}</b></a></p>
					else
						()
					,
					<center><h2>Isha Foundation Transcript Search</h2></center>
					,
					if($isLoggedIn)then
					(
						search:panel()
					)
					else
					(
						search:display-login-form()
					)
				}
			</div>
		</body>
	</html>