xquery version "1.0";

module namespace all-concepts-panel = "http://www.ishafoundation.org/archives/xquery/all-concepts-panel";

declare function all-concepts-panel:main() as element()*
{	
	let $reference := collection('/db/archives')/reference
	let $referenceConcepts := ($reference/categories/category/tag[@type eq 'concept']/string(@value), $reference//concept/string(@idRef))
	let $additionalConcepts := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	return
	(
		<center><h1>Isha Foundation Markup Concepts</h1></center>
		,
		for $conceptId in distinct-values(($referenceConcepts, $additionalConcepts))
		order by $conceptId
		return
			<a class="concept-anchor" href="main.xql?panel=categories&amp;conceptId={$conceptId}">{$conceptId}</a>
	)
};
