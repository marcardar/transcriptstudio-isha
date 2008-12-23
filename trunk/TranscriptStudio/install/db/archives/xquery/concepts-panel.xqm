xquery version "1.0";

module namespace concepts-panel = "http://www.ishafoundation.org/archives/xquery/concepts-panel";

declare function concepts-panel:main() as element()*
{	
	let $reference := collection('/db/archives')/reference
	let $referenceConcepts := ($reference/categories/category/tag[@type eq 'concept']/string(@value), $reference//concept/string(@idRef))
	let $additionalConcepts := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	return
	(
		<center><h1>Isha Foundation Markup Concepts</h1></center>
		,
		for $concept in distinct-values(($referenceConcepts, $additionalConcepts))
		order by $concept
		return
			<a class="concept-anchor" href="main.xql?panel=search&amp;search={$concept}&amp;defaultType=markup">{$concept}</a>
	)
};
