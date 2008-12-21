xquery version "1.0";

module namespace session_xhtml = "http://ishafoundation.org/archives/xquery/session_xhtml";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare function session_xhtml:html($doc as element(), $highlightId as xs:string?) as element()
{
    transform:transform($doc, doc('/db/archives/xslt/session_xhtml.xsl'), <parameters><param name="highlightId" value="{$highlightId}"/></parameters>)
};
