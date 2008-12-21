xquery version "1.0";

module namespace search = "http://www.ishafoundation.org/archives/xquery/search";

(: $defaultType is either "markup", "text" or "event" :)
declare function search:main($searchString as xs:string, $defaultType as xs:string) as element()*
{
	let $searchString :=
		if (contains($searchString, concat($defaultType, ':'))) then
			$searchString
		else
			concat($defaultType, ':', $searchString)
	let $eventSearchTerms := search:extract-sub-search-terms($searchString, 'event')
	let $markupSearchTerms := search:extract-sub-search-terms($searchString, 'markup')
	let $textSearchTerms := search:extract-sub-search-terms($searchString, 'text')
	return
		let $events := search:get-events(collection('/db/archives/data')/event, $eventSearchTerms)
		let $eventIds := trace($events/string(@id), 'eventIds:')
		let $transcripts := search:get-transcripts($eventIds)
		let $tableRows := 
			if (exists($markupSearchTerms)) then
				let $matchedMarkups := search:markup-search(($transcripts//superSegment, $transcripts//superContent), $markupSearchTerms)
				let $matchedMarkups := if (exists($textSearchTerms)) then search:text-search($matchedMarkups, $textSearchTerms) else $matchedMarkups
				return
					for $markup in $matchedMarkups
					order by $markup/tag[@type = 'markupCategory']/@value, number($markup/tag[@type eq 'rating']/@value)
					return
						search:markup-as-table-row($markup)
			else
				if (exists($textSearchTerms)) then
					for $segment in	search:text-search($transcripts/segment, $textSearchTerms)
					order by $segment/ancestor::session/@id descending
					return
						search:segment-as-table-row($segment)					
				else
					if (exists($eventSearchTerms)) then
						(: just searching events - so the results are transcripts :)
						for $transcript in $transcripts
						order by $transcript/../@id descending
						return
							search:transcript-as-table-row($transcript)
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

declare function search:get-transcripts($eventIds as xs:string*) as element()*
{
	collection('/db/archives/data')/session[search:get-event-id(@id) = $eventIds]/transcript 
};

(:
if $eventSearchTerms is empty then $baseTranscripts is returned
otherwise some subset of "baseTranscripts is returned
:)
declare function search:get-events($baseEvents as element()*, $eventSearchTerms as xs:string*) as element()*
{
	if (not(exists($eventSearchTerms))) then
		$baseEvents
	else
		let $searchTerm := $eventSearchTerms[1]
		let $newEventSearchTerms := remove($eventSearchTerms, 1)
		return
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
				search:get-events($newBaseEvents, $newEventSearchTerms)
};


declare function search:transcript-as-table-row($transcript as element()) as element()
{
	let $session := $transcript/..
	let $eventId := search:get-event-id($session/@id)
	let $event := collection('/db/archives/data')/event[@id = $eventId]
	return
		<tr><td class="result-td">
			<a class="result-anchor" href="view_session_xhtml.xql?sessionId={$session/@id}">Event ({upper-case($event/@type)}): {(string($event/@startAt), " ", string($event/@name))} @ {string($event/@location)}</a>
		</td></tr>
};

declare function search:markup-search($baseMarkups as element()*, $searchTerms as xs:string*) as element()*
{
	if (not(exists($searchTerms)) or not(exists($baseMarkups))) then
		$baseMarkups
	else
		let $searchTerm as xs:string := $searchTerms[1]
		let $newConcepts := remove($searchTerms, 1)
		let $expandedSearchTerm as xs:string* := search:expand-concept($searchTerm)
		let $newBaseMarkups := search:markups-for-any-concept($baseMarkups, $expandedSearchTerm)
		return search:markup-search($newBaseMarkups, $newConcepts)
};

declare function search:text-search($baseElements as element()*, $searchTerms as xs:string*) as element()*
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

declare function search:expand-concept($concept as xs:string) as xs:string*
{
	(: expand by synonyms :)
	let $synonyms := distinct-values(($concept,
			for $synonym in collection('/db/archives')/reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef = $concept]/../concept
			return string($synonym/@idRef)
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
			for $unprocessedId in $unprocessedIds
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
		where $markup/tag[@type = ('concept', 'markupType') and @value = $concepts] or (exists($markupCategories) and $markup/tag[@type = "markupCategory" and @value = $markupCategories/@id])
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
	let $eventId := search:get-event-id($session/@id)
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
					search:element-text($markup)
		else
			search:element-text($markup)
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

declare function search:segment-as-table-row($segment as element()) as element()
{
	let $session := $segment/ancestor::session
	let $eventId := search:get-event-id($session/@id)
	let $event := collection('/db/archives/data')/event[@id = $eventId]
	let $targetId := $segment/preceding::segment[1]/@id (: maybe faster to use $markup/preceding-sibling::*[1]//segment[last()]/@id :)
	let $targetId := ($targetId, $segment/@id) [1]
	let $text := search:element-text($segment)
	let $maxTextChars := 500
	return
		<tr><td class="result-td">
			<a class="result-anchor" href="view_session_xhtml.xql?sessionId={$session/@id}&amp;highlightId={$segment/@id}#{$targetId}">Event ({upper-case($event/@type)}): {(string($event/@startAt), " ", string($event/@name))} @ {string($event/@location)}</a>
			<br/>
			{
				concat(substring($text, 0, $maxTextChars), 
				if (string-length($text) > $maxTextChars) then "..." else ())
			}
		</td></tr>
};

declare function search:get-event-id($sessionId as xs:string) as xs:string
{
	substring-before($sessionId, "s")
};

declare function search:element-text($element as element()) as xs:string
{
	string-join($element//content/text(	), " ")
};

(: prefix is either "event", "markup" or "text" :)
declare function search:extract-sub-search-terms($searchString as xs:string, $prefix as xs:string) as xs:string*
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

declare function search:substring-before-match($arg as xs:string?, $regex as xs:string ) as xs:string {
	tokenize($arg, $regex)[1]
};

