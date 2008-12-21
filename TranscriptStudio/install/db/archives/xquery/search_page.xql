import module namespace search = "http://www.ishafoundation.org/archives/xquery/search" at "search.xqm";

let $searchString := if (request:exists()) then
        normalize-space(request:get-parameter('search', ()))
    else
        ()
return
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>eXist Database Administration</title>
        <link type="text/css" href="main.css" rel="stylesheet"/>
    </head>
    <body>
        <table id="header">
        <tr><td><h2>Isha Foundation<br/>Transcript Search</h2></td>
        <td valign="bottom">
        <form id="search-form" action="{session:encode-url(request:get-uri())}">
            <table id="search-form-table"><tr>
                <td><input type="text" name="search" size="50" value="{$searchString}"/></td>
                <td><input type="submit" value="Transcript Search"/></td>
            </tr></table>
        </form>
        </td></tr>
        </table>
        <hr/>
        {if ($searchString) then
            search:main($searchString)
        else
            'Blank search string'
        }
    </body>
</html>
