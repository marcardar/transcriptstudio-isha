(: Export session to the export collection :)

(: let $null := xmldb:login("/db", "admin", "1") :) 
let $sessionPath := '' (:request:get-parameter("sessionPath", ()):)
let $sessionId := 'y2004m04d20e01s01' (:request:get-parameter("sessionId", ()):)

let $encodedSessionPath := fn:iri-to-uri($sessionPath)
let $doc := doc($encodedSessionPath)
let $doc := ($doc, collection('/db/archives/data')/session[@id = $sessionId]) [1]
return if (empty($doc)) then
if (exists($sessionPath)) then
	<error>Could not find document at path: {$sessionPath}</error>
else if (exists($sessionId)) then
    <error>Could not find document with id: {$sessionId}</error>
else 
	<error>Neither sessionPath nor sessionId specified</error>
else
let $exportFilename := concat('msword ', $doc/session/@id, ' ', $doc/session/@name, '.xml')
let $encodedExportFilename := fn:iri-to-uri($exportFilename)
let $export := transform:transform($doc, doc('/db/archives/xslt/export_xhtml.xsl'), ())
(: let $retStore := xmldb:store('/db/archives/export', $encodedExportFilename, $export) :) 
return $export