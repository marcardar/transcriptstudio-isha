xquery version "1.0";

module namespace all-concepts-panel = "http://www.ishafoundation.org/archives/xquery/all-concepts-panel";

declare function all-concepts-panel:main() as element()*
{	
	let $reference := collection('/db/archives')/reference
	let $categoryConcepts := $reference/categories/category/tag[@type eq 'concept']/string(@value)
	let $otherReferenceConcepts := $reference//concept/string(@idRef)
	let $additionalConcepts := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	return
	(
		<center><h2>Isha Foundation Markup Concepts</h2></center>
		,
		<div style="font-size:small;">Note: italics denotes concept referenced by at least one category</div>
		,
		<br/>
		,
		for $conceptId in distinct-values(($categoryConcepts, $otherReferenceConcepts, $additionalConcepts))
		order by $conceptId
		return
			if ($conceptId = $categoryConcepts) then
				<a class="category-concept-anchor" href="main.xql?panel=categories&amp;conceptId={$conceptId}"><i>{$conceptId}</i></a>
			else
				<a class="concept-anchor" href="main.xql?panel=search&amp;search={$conceptId}&amp;defaultType=markup">{$conceptId}</a>
	)
};
