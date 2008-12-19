xquery version "1.0";

module namespace search = "http://www.ishafoundation.org/archives/xquery/search";

declare function search:main($searchString as xs:string) as element()
{
	let $searchTerms := tokenize($searchString, ' ')
	let $null := trace($searchTerms, "Search terms: ")
	let $tableRows := 
		for $markup in search:markupsForConcept((collection('/db/archives/data')//superSegment, collection('/db/archives/data')//superContent), $searchTerms[1])
		return
			search:markupAsTableRow($markup)
	return
		if (exists($tableRows)) then
			<table class="result-table">
				{$tableRows}
			</table>
		else 
			<p>Nothing found</p>
};

declare function search:markupsForConcept($baseMarkups as element()*, $concept as xs:string) as element()*
{
	let $markupCategories as element()*:= collection('/db/archives')/reference/categories/category/tag[@type = "concept" and @value = $concept]/..
	let $null := trace(count($markupCategories), "Number of markupCategories: ")
	return
		for $markup in $baseMarkups
		where $markup/tag[@type = "concept" and @value = $concept] or (exists($markupCategories) and $markup/tag[@type = "markupCategory" and @value = $markupCategories])
		return $markup
};

declare function search:toString($elements as element()*) as xs:string
{
	concat(for $element in $elements
	return local-name($element), ", ")
};

declare function search:markupAsTableRow($markup as element()) as element()
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
					search:markupText($markup)
		else
			search:markupText($markup)
	let $maxTextChars := 500
	return
		<tr><td class="result-td">
		<a class="result-anchor" href="view_session_xhtml.xql?sessionId={$session/@id}&amp;highlightId={$markup/@id}#{$targetId}">{string($markupType/@name)}{$markupCategoryName}</a>
		<br/>
		{
			(substring($text, 0, $maxTextChars), 
			if (string-length($text) > $maxTextChars) then "..." else ())
		}
		<br/>
		<span class="event">Event ({upper-case($event/@type)}): {(string($event/@startAt), " ", string($event/@name))} @ {string($event/@location)}</span>
		</td></tr>
};

declare function search:markupText($markup as element()) as xs:string
{
	string-join($markup//content/text(), " ")
};

















