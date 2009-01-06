xquery version "1.0";

module namespace all-concepts-panel = "http://www.ishafoundation.org/archives/xquery/all-concepts-panel";

declare variable $all-concepts-panel:numColumns := 2;
declare variable $all-concepts-panel:columnWidth := 80;

declare function all-concepts-panel:main() as element()*
{	
	let $reference := collection('/db/archives/reference')/reference
	let $categoryConcepts := $reference/categories/category/tag[@type eq 'concept']/string(@value)
	let $otherReferenceConcepts := $reference//concept/string(@idRef)
	let $additionalConcepts := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
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
		<div style="font-size:small;">Note: italics denotes concept referenced by at least one category</div>
		,
		<br/>
		,
		let $concepts := 
			for $concept in distinct-values(($categoryConcepts, $otherReferenceConcepts, $additionalConcepts))
			order by $concept 
			return $concept
		return
			for $startCharIndex in (0 to 25)
			let $startChar := codepoints-to-string($startCharIndex + 97)
			let $filteredConcepts := all-concepts-panel:filter-concepts-for-start-char($startChar, $concepts)
			return
				(
					<b id="{$startChar}">{upper-case($startChar)}:</b>
				,
					all-concepts-panel:create-table($filteredConcepts, $categoryConcepts)
				)
	)
};

declare function all-concepts-panel:filter-concepts-for-start-char($startChar as xs:string, $concepts as xs:string*) as xs:string*
{
	for $concept in $concepts
	where substring($concept, 1, 1) = $startChar
	return $concept
};

declare function all-concepts-panel:create-table($concepts as xs:string*, $categoryConcepts as xs:string*) as element()*
{
	let $numConcepts := count($concepts)
	return
	(
		<small><i>{$numConcepts} concept{if ($numConcepts = 1) then () else 's'}</i></small>
	,
		if ($numConcepts = 0) then
			<br/>		
		else
			<table>
				{
				for $startIndex in (0 to count($concepts) - 1)[. mod $all-concepts-panel:numColumns = 0]
				return
					all-concepts-panel:create-table-row($startIndex + 1, $concepts, $categoryConcepts)
				}
			</table>
	)
};

declare function all-concepts-panel:create-table-row($startIndex as xs:integer, $concepts as xs:string*, $categoryConcepts as xs:string*) as element()
{
	<tr>
		{
		for $i in ($startIndex to min(($startIndex + $all-concepts-panel:numColumns - 1, count($concepts))))
		let $conceptId := $concepts[$i]
		return
		(
			<td width="{$all-concepts-panel:columnWidth}">
				{if ($conceptId = $categoryConcepts) then
					<a class="category-concept-anchor" href="main.xql?panel=categories&amp;conceptId={$conceptId}"><i>{$conceptId}</i></a>
				else
					<a class="concept-anchor" href="main.xql?panel=search&amp;search={$conceptId}&amp;defaultType=markup">{$conceptId}</a>
				}
			</td>
		,
			<td width="10"/>
		)	
		}
	</tr>
};