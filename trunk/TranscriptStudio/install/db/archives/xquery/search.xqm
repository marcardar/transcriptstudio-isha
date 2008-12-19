xquery version "1.0";

module namespace search = "http://www.ishafoundation.org/archives/xquery/search";

declare function search:main($searchString as xs:string) as element()*
{
	let $searchTerms := tokenize($searchString, ' ')
	let $tableRows := 
		for $markup in search:markups-for-all-concepts((collection('/db/archives/data')//superSegment, collection('/db/archives/data')//superContent), $searchTerms)
		return
			search:markup-as-table-row($markup)
	return
		(
			<p>Found {count($tableRows)} result(s) after searching {count(collection('/db/archives/data')/session/transcript)} transcripts.</p>
			,
			<table class="result-table">
				{$tableRows}
			</table>
		)
};

declare function search:markups-for-all-concepts($baseMarkups as element()*, $searchTerms as xs:string*) as element()*
{
	if (not(exists($searchTerms)) or not(exists($baseMarkups))) then
		$baseMarkups
	else
		let $searchTerm as xs:string := $searchTerms[1]
		let $newConcepts := remove($searchTerms, 1)
		let $expandedSearchTerm as xs:string* := search:expand-search-term($searchTerm)
		let $newBaseMarkups := search:markups-for-any-concept($baseMarkups, $expandedSearchTerm)
		return search:markups-for-all-concepts($newBaseMarkups, $newConcepts)
};

declare function search:expand-search-term($searchTerm as xs:string) as xs:string*
{
	(: expand by synonyms :)
	let $synonyms := distinct-values(($searchTerm,
			for $concept in collection('/db/archives')/reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef = $searchTerm]/../concept
			return string($concept/@idRef)
		))
	(: expand by concept hierarchy :) 
	let $result := search:get-super-concept-ids($synonyms, ())
	return
		$result
};

declare function search:get-super-concept-ids($unprocessedIds as xs:string*, $processedIds as xs:string*) as xs:string*
{
	let $newUnprocessedIds :=
		if (count($unprocessedIds) = 0) then
			()
		else
			for $unprocessedId in $unprocessedId
			return
				if (index-of($processedIds, $unprocessedId)) then
					()
				else
					(: have not processed this one before :)
					collection('/db/archives')/reference/conceptHierarchy/concept/concept[@idRef = $unprocessedId]/../@idRef
	return
		let $newProcessedIds := ($processedIds, $unprocessedIds)
		return
			if ($newUnprocessedIds) then
				search:get-super-concept-ids($newUnprocessedIds, $newProcessedIds)
			else
				distinct-values($newProcessedIds)
};

declare function search:markups-for-any-concept($baseMarkups as element()*, $concepts as xs:string*) as element()*
{
	let $markupCategories as element()*:= collection('/db/archives')/reference/categories/category/tag[@type = "concept" and exists(index-of($concepts, string(@value)))]/..
	(:
	let $null := error(QName("http://error.com", "myerror"), concat("Number of markupCategories: ", count($markupCategories)))
	:)
	let $result :=
		for $markup in $baseMarkups
		where $markup/tag[@type = "concept" and @value = $concepts] or (exists($markupCategories) and $markup/tag[@type = "markupCategory" and @value = $markupCategories/@id])
		return $markup
	return
		(:
			error(QName("http://error.com", "myerror"), concat("Number of markupCategories with concept (", $concept, "): ", count($markupCategories))
		:)
		(:error(QName("http://error.com", "myerror"), concat("Number of baseMarkups: ", count($baseMarkups))),:)
		$result
};

declare function search:markup-as-table-row($markup as element()) as element()
{
	let $session := $markup/ancestor::session
	let $markupTypeId := $markup/tag[@type = 'markupType']/@value
	let $markupType := collection('/db/archives')/reference/categoryTypes/categoryType[@id = $markupTypeId]
	let $categoryId := $markup/tag[@type = 'markupCategory']/@value
	let $markupCategory := collection('/db/archives')/reference/categories/category[@id = $categoryId]
	let $markupCategoryName := if (exists($markupCategory)) then
			concat(': ', $markupCategory/@name)
		else
			()
	let $eventId := substring-before($session/@id, "s")
	let $event := collection('/db/archives/data')/event[@id = $eventId]
	let $targetId := 
		if (local-name($markup) = "superSegment") then
			$markup/preceding::segment[1]/@id (: maybe faster to use $markup/preceding-sibling::*[1]//segment[last()]/@id :)
		else
			$markup/ancestor::segment/@id
	let $targetId := ($targetId, $markup/@id) [1]
	let $text :=
		if (local-name($markup) = "superSegment") then
			let $summary := string($markup/tag[@type = "summary"]/@value)
			return
				if ($summary) then
					string-join(("[summary]", $summary), " ")
				else
					search:markup-text($markup)
		else
			search:markup-text($markup)
	let $maxTextChars := 500
	return
		<tr><td class="result-td">
			<a class="result-anchor" href="view_session_xhtml.xql?sessionId={$session/@id}&amp;highlightId={$markup/@id}#{$targetId}">{string($markupType/@name)}{$markupCategoryName}</a>
			<br/>
			{
				concat(substring($text, 0, $maxTextChars), 
				if (string-length($text) > $maxTextChars) then "..." else ())
			}
			<br/>
			<span class="event">Event ({upper-case($event/@type)}): {(string($event/@startAt), " ", string($event/@name))} @ {string($event/@location)}</span>
		</td></tr>
};

declare function search:markup-text($markup as element()) as xs:string
{
	string-join($markup//content/text(), " ")
};

















