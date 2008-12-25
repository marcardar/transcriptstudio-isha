xquery version "1.0";

module namespace search-fns = "http://www.ishafoundation.org/archives/xquery/search-fns";

declare variable $search-fns:maxTextChars := 560;

(: $defaultType is either "markup", "text" or "event" :)
declare function search-fns:main($searchString as xs:string, $defaultType as xs:string) as element()*
{
	let $searchString :=
		if (contains($searchString, concat($defaultType, ':'))) then
			$searchString
		else
			concat($defaultType, ':', $searchString)
	let $eventSearchTerms := search-fns:extract-sub-search-terms($searchString, 'event')
	let $markupSearchTerms := search-fns:extract-sub-search-terms($searchString, 'markup')
	let $textSearchTerms := search-fns:extract-sub-search-terms($searchString, 'text')
	return
		let $events := search-fns:get-events(collection('/db/archives/data')/event, $eventSearchTerms)
		let $eventIds := trace($events/string(@id), 'eventIds:')
		let $transcripts := search-fns:get-transcripts($eventIds)
		let $tableRows := 
			if (exists($markupSearchTerms)) then
				let $matchedMarkups := search-fns:markup-search(($transcripts//superSegment, $transcripts//superContent), $markupSearchTerms)
				let $matchedMarkups := if (exists($textSearchTerms)) then search-fns:text-search($matchedMarkups, $textSearchTerms) else $matchedMarkups
				return
					for $markup in $matchedMarkups
					order by $markup/tag[@type = 'markupCategory']/@value, number($markup/tag[@type eq 'rating']/@value)
					return
						search-fns:markup-as-table-row($markup)
			else
				if (exists($textSearchTerms)) then
					for $segment in	search-fns:text-search($transcripts//segment, $textSearchTerms)
					order by $segment/ancestor::session/@id descending
					return
						search-fns:segment-as-table-row($segment)					
				else
					if (exists($eventSearchTerms)) then
						(: just searching events - so the results are transcripts :)
						for $transcript in $transcripts
						order by $transcript/../@id descending
						return
							search-fns:transcript-as-table-row($transcript)
					else
						(<p>No meaningful terms in search string</p>)
		return
			let $numRows := count(trace($tableRows, 'table rows'))
			let $afterSearching := concat('after searching ', count(collection('/db/archives/data')/session/transcript), ' transcripts.')
			return
				if ($numRows = 0) then
					(: No results :)
					(<p>Nothing found {$afterSearching}</p>)
				else
					if ($numRows = 1 and local-name($tableRows[1]) = 'p') then
						(: This is a message not a table row :)
						$tableRows
					else
						(: normal results :)
						(
							<p>Found {$numRows} result(s) {$afterSearching}</p>
							,
							<table class="result-table">
								{$tableRows}
							</table>
						)
};

declare function search-fns:get-transcripts($eventIds as xs:string*) as element()*
{
	collection('/db/archives/data')/session[search-fns:get-event-id(@id) = $eventIds]/transcript 
};

(:
if $eventSearchTerms is empty then $baseTranscripts is returned
otherwise some subset of "baseTranscripts is returned
:)
declare function search-fns:get-events($baseEvents as element()*, $eventSearchTerms as xs:string*) as element()*
{
	if (not(exists($eventSearchTerms))) then
		$baseEvents
	else
		let $searchTerm := $eventSearchTerms[1]
		let $newEventSearchTerms := remove($eventSearchTerms, 1)
		let $newBaseEvents :=
			if (matches($searchTerm, '^[A-Z]{1,2}$')) then
				(: this is an event type :)
				$baseEvents[@type = lower-case($searchTerm)]
			else
				if (matches($searchTerm, '^[0-9]{4}$')) then
					(: this is an event year :)
					$baseEvents[starts-with(@startAt, $searchTerm)]
				else 
					(: it could be anything :)
					$baseEvents[matches(@*, $searchTerm, 'i')]
		return
			search-fns:get-events($newBaseEvents, $newEventSearchTerms)
};

declare function search-fns:get-session-title($session as element()) as xs:string
{
	let $eventId := search-fns:get-event-id($session/@id)
	let $event := collection('/db/archives/data')/event[@id = $eventId]
	let $sources := concat(' (', string-join($session/source/upper-case(@id), ', '), ')')
	return
		concat(search-fns:get-event-title($event), $sources)
};

declare function search-fns:get-event-title($event as element()) as xs:string
{
	concat('Event (', upper-case($event/@type), '): ', $event/@startAt, " ", $event/@name, ' @ ', $event/@location)
};

declare function search-fns:markup-search($baseMarkups as element()*, $searchTerms as xs:string*) as element()*
{
	if (not(exists($searchTerms)) or not(exists($baseMarkups))) then
		$baseMarkups
	else
		let $searchTerm as xs:string := $searchTerms[1]
		let $newConcepts := remove($searchTerms, 1)
		let $newBaseMarkups :=
			if (search-fns:is-category-id($searchTerm)) then
				search-fns:markups-for-category($baseMarkups, $searchTerm)
			else
				let $expandedSearchTerm as xs:string* := search-fns:expand-concept($searchTerm)
				return
					search-fns:markups-for-any-concept($baseMarkups, $expandedSearchTerm)
		return search-fns:markup-search($newBaseMarkups, $newConcepts)
};

declare function search-fns:is-category-id($categoryId as xs:string) as xs:boolean
{
	exists(collection('/db/archives')/reference/categories/category[@id = $categoryId])
};

declare function search-fns:text-search($baseElements as element()*, $searchTerms as xs:string*) as element()*
{
	if (not(exists($searchTerms)) or not(exists($baseElements))) then
		$baseElements
	else
		let $firstSearchTerm := $searchTerms[1]
		return
			let $nearValue as xs:integer :=
				if (matches($firstSearchTerm, '^[0-9]{1,3}$')) then
					xs:integer($firstSearchTerm)
				else
					-1
			return
				let $searchTerms := if ($nearValue >= 0) then remove($searchTerms, 1) else $searchTerms	
				let $stringOfKeywords := string-join($searchTerms, ' ')
				return
					if ($nearValue < 0) then
						(: no value was specified so do an exact match :)
						$baseElements[near(., $stringOfKeywords, 1)]
					else
						let $reverseStringOfKeywords := string-join(reverse($searchTerms), ' ')
						return
							$baseElements[near(., $stringOfKeywords, $nearValue) or near(., $reverseStringOfKeywords, $nearValue)]
};

declare function search-fns:expand-concept($concept as xs:string) as xs:string*
{
	(: expand by synonyms :)
	let $synonyms := distinct-values(($concept,
			for $synonym in collection('/db/archives')/reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef = $concept]/../concept
			return string($synonym/@idRef)
		))
	(: expand by concept hierarchy :) 
	let $result := search-fns:get-sub-concept-ids($synonyms, ())
	return
		$result
};

declare function search-fns:get-sub-concept-ids($unprocessedIds as xs:string*, $processedIds as xs:string*) as xs:string*
{
	let $newUnprocessedIds :=
		if (count($unprocessedIds) = 0) then
			()
		else
			for $unprocessedId in $unprocessedIds
			return
				if (index-of($processedIds, $unprocessedId)) then
					()
				else
					(: have not processed this one before :)
					collection('/db/archives')/reference/conceptHierarchy/concept[@idRef = $unprocessedId]/concept/@idRef
	return
		let $newProcessedIds := ($processedIds, $unprocessedIds)
		return
			if ($newUnprocessedIds) then
				search-fns:get-sub-concept-ids($newUnprocessedIds, $newProcessedIds)
			else
				distinct-values($newProcessedIds)
};

declare function search-fns:markups-for-any-concept($baseMarkups as element()*, $concepts as xs:string*) as element()*
{
	let $markupCategories as element()*:= collection('/db/archives')/reference/categories/category/tag[@type = "concept" and exists(index-of($concepts, string(@value)))]/..
	(:
	let $null := error(QName("http://error.com", "myerror"), concat("Number of markupCategories: ", count($markupCategories)))
	:)
	let $result :=
		for $markup in $baseMarkups
		where $markup/tag[@type = ('concept', 'markupType') and @value = $concepts] or (exists($markupCategories) and $markup/tag[@type = "markupCategory" and @value = $markupCategories/@id])
		return $markup
	return
		(:
			error(QName("http://error.com", "myerror"), concat("Number of markupCategories with concept (", $concept, "): ", count($markupCategories))
		:)
		(:error(QName("http://error.com", "myerror"), concat("Number of baseMarkups: ", count($baseMarkups))),:)
		$result
};

declare function search-fns:markups-for-category($baseMarkups as element()*, $categoryId as xs:string*) as element()*
{
	for $markup in $baseMarkups/tag[@type = 'markupCategory' and @value = $categoryId]/..
	return $markup
};

declare function search-fns:markup-as-table-row($markup as element()) as element()
{
	let $session := $markup/ancestor::session
	let $markupTypeId := $markup/tag[@type = 'markupType']/@value
	let $markupType := collection('/db/archives')/reference/categoryTypes/categoryType[@id = $markupTypeId]
	let $categoryId := $markup/tag[@type = 'markupCategory']/@value
	let $markupCategory := collection('/db/archives')/reference/categories/category[@id = $categoryId]
	let $markupCategoryName := if (exists($markupCategory)) then
			concat(': ', $markupCategory/@name, search-fns:get-markup-category-concepts-string($markupCategory))
		else
			()
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
					search-fns:element-text($markup)
		else
			search-fns:element-text($markup)
	return
		<table class="single-result">
			<tr>
				<td><img src="../assets/{$markup/tag[@type='markupType']/@value}.png" width="24" height="24"/></td>
				<td class="result-header" width="100%">
					{search-fns:get-result-header($session, $markup/@id, $targetId, concat($markupType/@name, $markupCategoryName, search-fns:get-additional-concepts-string($markup)))}
				</td>
			</tr>
			<tr>
				<td class="result-body" colspan="2">
					{substring($text, 0, $search-fns:maxTextChars)} 
					{if (string-length($text) > $search-fns:maxTextChars) then '...' else ()}
				</td>
			</tr>
			<tr>
				<td class="result-footer" colspan="2">
					{concat(search-fns:get-session-title($session), ' [', $session/@id, ']')}
				</td>
			</tr>
		</table>
};

declare function search-fns:get-markup-category-concepts-string($markupCategory as element()) as xs:string
{
	let $conceptNames := $markupCategory/tag[@type = 'concept']/@value
	return
		if (exists($conceptNames)) then
			concat(' [', string-join($conceptNames, ' '), ']')
		else
			''
};

declare function search-fns:get-additional-concepts-string($markup as element()) as xs:string
{
	let $conceptNames := $markup/tag[@type = 'concept']/@value
	return
		if (exists($conceptNames)) then
			concat(' +[', string-join($conceptNames, ', '), ']')
		else
			''
};

declare function search-fns:segment-as-table-row($segment as element()) as element()
{
	let $session := $segment/ancestor::session
	let $targetId := $segment/preceding::segment[1]/@id (: maybe faster to use $markup/preceding-sibling::*[1]//segment[last()]/@id :)
	let $targetId := ($targetId, $segment/@id) [1]
	let $text := search-fns:element-text($segment)
	return
		<div class="single-result">
			<div class="result-header">
				{search-fns:get-result-header($session, $segment/@id, $targetId, search-fns:get-session-title($session))}
			</div>
			<div class="result-body">
			{
				concat(substring($text, 0, $search-fns:maxTextChars), 
				if (string-length($text) > $search-fns:maxTextChars) then "..." else ())
			}
			</div>
			<div class="result-footer">
				{string($session/@id)}
			</div>
		</div>
};

declare function search-fns:transcript-as-table-row($transcript as element()) as element()
{
	let $session := $transcript/..
	return
		<div class="single-result">
			<div class="result-header">
				{search-fns:get-result-header($session, (), (), search-fns:get-session-title($session))}
			</div>
			<div class="result-footer">
				{string($session/@id)}
			</div>
		</div>
};

declare function search-fns:get-result-header($session as element(), $highlightId as xs:string?, $targetId as xs:string?, $text as xs:string) as element()
{
	let $highlightParam := if ($highlightId) then concat('&amp;highlightId=', $highlightId) else ''
	let $targetParam := if ($targetId) then concat('#', $targetId) else ''
	return
		<a class="result-header" href="main.xql?panel=session&amp;id={$session/@id}{$highlightParam}{$targetParam}">{$text}</a>
};

declare function search-fns:get-event-id($sessionId as xs:string) as xs:string
{
	substring-before($sessionId, "s")
};

declare function search-fns:element-text($element as element()) as xs:string
{
	string-join($element//content/text(	), " ")
};

(: prefix is either "event", "markup" or "text" :)
declare function search-fns:extract-sub-search-terms($searchString as xs:string, $prefix as xs:string) as xs:string*
{
	let $afterPrefix := substring-after($searchString, concat($prefix, ':'))
	let $subSearchTerms :=
		if (contains($afterPrefix, ':')) then 
			let $tokens := tokenize(substring-before($afterPrefix, ':'), ' ')
			return
				(: the last token will have the prefix like "text" - so remove it :)
				remove($tokens, count($tokens))
		else
			tokenize($afterPrefix, ' ')
	return
		let $normalizedTerms :=
			for $term in $subSearchTerms
			return
				let $normalizedTerm := normalize-space($term)
				return
					if ($normalizedTerm) then $normalizedTerm else ()
		return
			trace($normalizedTerms, concat($prefix, ' search terms')) 
};

declare function search-fns:substring-before-match($arg as xs:string?, $regex as xs:string ) as xs:string {
	tokenize($arg, $regex)[1]
};

