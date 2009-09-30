xquery version "1.0";

module namespace all-concepts-panel = "http://www.ishafoundation.org/ts4isha/xquery/all-concepts-panel";

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare variable $all-concepts-panel:numColumns := 8;
declare variable $all-concepts-panel:minRows := 3;
declare variable $all-concepts-panel:columnWidth := 100;

declare function all-concepts-panel:main() as element()*
{	
	let $reference := $utils:referenceCollection/reference
	let $categoryConcepts := $reference/markupCategories/markupCategory/tag[@type eq 'concept']/string(@value)
	let $coreConcepts := $reference/coreConcepts/concept/string(@id)
	let $subtypeConcepts := $reference/coreConcepts/concept/subtype/string(@idRef)
	let $synonymConcepts := $reference/synonymGroups/synonymGroup/synonym/string(@idRef)
	let $additionalConcepts := $utils:dataCollection/session/transcript//(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	return
	(
		<center><h2>Isha Foundation Markup Concepts</h2></center>
		,
		<center>{
		for $startCharIndex in (0 to 25)
		let $startChar := codepoints-to-string($startCharIndex + 97)
		return
			<a href="#{$startChar}">{upper-case($startChar)}</a>
		}</center>
		,
		<br/>
		,
		let $concepts := 
			for $concept in distinct-values(($categoryConcepts, $coreConcepts, $subtypeConcepts, $synonymConcepts, $additionalConcepts))
			order by $concept 
			return $concept
		for $startCharIndex in (0 to 25)
		let $startChar := codepoints-to-string($startCharIndex + 97)
		let $filteredConcepts := all-concepts-panel:filter-concepts-for-start-char($startChar, $concepts)
		return
			(
				<b id="{$startChar}">{upper-case($startChar)}:</b>
			,
				all-concepts-panel:create-table($filteredConcepts)
			)
	)
};

declare function all-concepts-panel:filter-concepts-for-start-char($startChar as xs:string, $concepts as xs:string*) as xs:string*
{
	for $concept in $concepts
	where substring($concept, 1, 1) = $startChar
	return $concept
};

declare function all-concepts-panel:create-table($concepts as xs:string*) as element()*
{
	let $numConcepts := count($concepts)
	return
	(
		<small><i>{$numConcepts} concept{if ($numConcepts = 1) then () else 's'}</i></small>
	,
		if ($numConcepts = 0) then
			<br/>		
		else
			<table cellspacing="0">
				{
				let $numRows := max((xs:integer(ceiling(count($concepts) div $all-concepts-panel:numColumns)), min(($numConcepts, $all-concepts-panel:minRows))))
				for $rowIndex in (1 to $numRows)
				return
					all-concepts-panel:create-table-row($rowIndex, $numRows, $concepts)
				}
			</table>
	)
};

declare function all-concepts-panel:create-table-row($rowIndex as xs:integer, $numRows as xs:integer, $concepts as xs:string*) as element()
{
	<tr>
		{
		let $numConcepts := count($concepts)
		for $i in (0 to $numConcepts - 1)[. mod $numRows = $rowIndex - 1]
		let $conceptId := $concepts[$i + 1]
		return
		(
			<td width="{$all-concepts-panel:columnWidth}" style="white-space: nowrap; background:Moccasin;">
				<a class="concept-anchor" href="main.xql?panel=categories#{$conceptId}">{$conceptId}</a>
			</td>
		,
			(: for horizontal separation :)
			<td width="20"/>
		)	
		}
	</tr>
};
