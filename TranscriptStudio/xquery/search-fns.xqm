xquery version "1.0";

module namespace search-fns = "http://www.ishafoundation.org/ts4isha/xquery/search-fns";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $search-fns:maxResults := 500;
declare variable $search-fns:maxTextChars := 550;

(: $defaultType is either "markup", "text" or "event" :)
declare function search-fns:main($searchString as xs:string, $defaultType as xs:string, $groupResults as xs:string, $markupUuid as xs:string) as element()*
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
		let $events := search-fns:get-events($utils:dataCollection/event, $eventSearchTerms)
		let $eventIds := $events/string(@id)
		let $transcripts := search-fns:get-transcripts($eventIds)
		let $tableRows := 
			if (exists($markupSearchTerms)) then
				let $matchedMarkups := search-fns:markup-search(($transcripts//superSegment, $transcripts//superContent), $markupSearchTerms)
				let $matchedMarkups := if (exists($textSearchTerms)) then search-fns:text-search($matchedMarkups, $textSearchTerms) else $matchedMarkups
				let $markupClassRepresentatives := search-fns:generate-markup-class-representatives($matchedMarkups)
				return 
					if ($groupResults eq 'true') then
						for $markupClassRepresentative in $markupClassRepresentatives
						return
							search-fns:markup-as-table-row($markupClassRepresentative, $searchString, $groupResults)
					else if (exists($markupUuid)) then
						let $markup := search-fns:markup-search($matchedMarkups, $markupUuid)
						for $classMarkup in search-fns:generate-markup-class($markup, $matchedMarkups)
						return
							search-fns:markup-as-table-row($classMarkup, $searchString, $groupResults)
					else
						()
			else
				if (exists($textSearchTerms)) then
					for $segment in	search-fns:text-search($transcripts//segment, $textSearchTerms)
					order by $segment/ancestor::session/@id descending
					return
						search-fns:segment-as-table-row($segment)					
				else
					if (exists($eventSearchTerms)) then
						(: just searching events - so the results are events :)
						for $event in $events
						order by $event/@id descending
						return
							search-fns:event-as-table-row($event)
					else
						(<p>No meaningful terms in search string</p>)
		return
			let $numRows := count(trace($tableRows, 'table rows'))
			let $afterSearching := concat('after searching ', count($utils:dataCollection/session/transcript), ' transcripts.')
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
							<p>Found {$numRows} result(s) {$afterSearching}{
							if ($numRows > $search-fns:maxResults) then concat(' [Displaying first ', $search-fns:maxResults, ' results only]') else ''}
							</p>
							,
							$tableRows[position() <= $search-fns:maxResults]
						)
};

declare function search-fns:generate-markup-class-representatives($matchedMarkups as element()*) as element()*
{
	let $categoryMarkups := $matchedMarkups/tag[@type = "markupCategory"]/../.
	let $conceptMarkups := ($matchedMarkups except $categoryMarkups)/tag[@type = "concept"]/../.
	let $typeMarkups := $matchedMarkups except ($categoryMarkups, $conceptMarkups)

	let $categoryIds := distinct-values($categoryMarkups/tag[@type = "markupCategory"]/@value)
	let $conceptLists := distinct-values(
		for $markup in $conceptMarkups 
		return 
			search-fns:get-additional-concepts-list($markup)
	)
	let $types := distinct-values($typeMarkups/tag[@type = "markupType"]/@value)

	let $categoryMarkupsClassRepresentatives :=
		for $categoryId in $categoryIds
		let $usedMarkupTypes := distinct-values($categoryMarkups/tag[@value = $categoryId][@type = "markupCategory"]/../tag[@type = "markupType"]/string(@value))
		return
			for $markupType in $usedMarkupTypes
			let $classMarkups := $categoryMarkups/tag[@value = $categoryId][@type = "markupCategory"]/../tag[@value = $markupType][@type = "markupType"]/../.
			let $classCount := count($classMarkups)
			return
				functx:add-attributes($classMarkups[1], (xs:QName('sessionId'), xs:QName('classType'), xs:QName('classCount')), ($classMarkups[1]/ancestor::session/@id, 'category', $classCount))
				
	let $conceptMarkupsClassRepresentatives :=
		for $conceptList in $conceptLists
		let $usedMarkupTypes := distinct-values($conceptMarkups[search-fns:get-additional-concepts-list(.) eq $conceptList]/tag[@type = "markupType"]/string(@value))
		return
			for $markupType in $usedMarkupTypes
			let $classMarkups := $conceptMarkups[search-fns:get-additional-concepts-list(.) eq $conceptList]/tag[@value = $markupType][@type = "markupType"]/../.
			let $classCount := count($classMarkups)
			return
				functx:add-attributes($classMarkups[1], (xs:QName('sessionId'), xs:QName('classType'), xs:QName('classCount')), ($classMarkups[1]/ancestor::session/@id, 'concept', $classCount))
							
	let $typeMarkupsClassRepresentatives :=
		for $type in $types
		let $classMarkups := $typeMarkups/tag[@value = $type][@type = "markupType"]/../.
		let $classCount := count($classMarkups)
		return
			functx:add-attributes($classMarkups[1], (xs:QName('sessionId'), xs:QName('classType'), xs:QName('classCount')), ($classMarkups[1]/ancestor::session/@id, 'type', $classCount))

	for $markupsClassRepresentatives in ($categoryMarkupsClassRepresentatives, $conceptMarkupsClassRepresentatives, $typeMarkupsClassRepresentatives)
	let $markupType := $markupsClassRepresentatives/tag[@type = "markupType"]/@value
	let $searchPriority := $utils:referenceCollection//markupType[@id = $markupType]/xs:integer(@searchOrder)
	order by $searchPriority
	return
		$markupsClassRepresentatives
};

declare function search-fns:generate-markup-class($markup as element(), $baseMarkups as element()*) as element()*
{
	let $categoryMarkups := $baseMarkups/tag[@type = "markupCategory"]/../.
	let $conceptMarkups := ($baseMarkups except $categoryMarkups)/tag[@type = "concept"]/../.
	let $typeMarkups := $baseMarkups except ($categoryMarkups, $conceptMarkups)

	let $classType := 
		if (exists(index-of($categoryMarkups, $markup))) then 'category'
		else if (exists(index-of($conceptMarkups, $markup))) then 'concept'
		else if (exists(index-of($typeMarkups, $markup))) then 'type'
		else ()

	let $categoryId := $markup/tag[@type = 'markupCategory']/xs:string(@value)
	let $conceptList := search-fns:get-additional-concepts-list($markup)
	let $type := $markup/tag[@type = "markupType"]/xs:string(@value)

	
	return
		if ($classType eq 'category') then 
			$categoryMarkups/tag[@value eq $categoryId][@type eq 'markupCategory']/../tag[@value = $type][@type = "markupType"]/../.
		else if ($classType eq 'concept') then 
			$conceptMarkups[search-fns:get-additional-concepts-list(.) eq $conceptList]/tag[@value = $type][@type = "markupType"]/../.
		else if ($classType eq 'type') then 
			$typeMarkups/tag[@value = $type][@type = "markupType"]/../.
		else
			()
};

declare function search-fns:get-transcripts($eventIds as xs:string*) as element()*
{
	$utils:dataCollection/session[@eventId = $eventIds]/transcript 
};

declare function search-fns:get-sessions-for-event-ids($eventIds as xs:string*) as element()*
{
	$utils:dataCollection/session[@eventId = $eventIds]
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
			if (matches($searchTerm, '^[a-z]{1,2}$', 'i')) then
				(: this is an event type :)
				$baseEvents[@type = lower-case($searchTerm)]
			else
				if (matches($searchTerm, '^[0-9]{4}$')) then
					(: this is an event year :)
					$baseEvents[starts-with(metadata/@startAt, $searchTerm)]
				else 
					if (matches($searchTerm, '^[a-z]{1,2}-\d+$', 'i')) then
						(: this is an id (could be event, session or media etc) - but lets assume media id :)
						let $sessions := search-fns:get-sessions-for-event-ids($baseEvents/xs:string(@id))
						return search-fns:get-events-for-session-ids($sessions[.//device/*/@id = lower-case($searchTerm)]/@id)
					else 
						(: it could be anything :)
						$baseEvents[matches(metadata/@*, $searchTerm, 'i')]
		return
			search-fns:get-events($newBaseEvents, $newEventSearchTerms)
};

declare function search-fns:get-session-title($session as element()) as xs:string
{
	let $eventId := $session/@eventId
	let $event := $utils:dataCollection/event[@id = $eventId]
	(: let $sources := concat(' (', string-join($session//device/media/upper-case(@id), ', '), ')') :)
	return
		search-fns:get-event-title($event)
};

declare function search-fns:get-event-title($event as element()) as xs:string
{
	let $metadata := $event/metadata[1]
	return
		concat('Event (', $event/@type, '): ', string-join(($metadata/@startAt, $metadata/@subTitle, concat('@ ', $event/metadata/@location)), ' '))
};

declare function search-fns:markup-search($baseMarkups as element()*, $searchTerms as xs:string*) as element()*
{
	if (not(exists($searchTerms)) or not(exists($baseMarkups))) then
		$baseMarkups
	else
		let $searchTerm as xs:string := $searchTerms[1]
		let $newTerms := remove($searchTerms, 1)
		let $newBaseMarkups :=
			if (search-fns:is-markup-uuid($searchTerm)) then
				search-fns:markup-for-uuid($baseMarkups, $searchTerm)
			else if (search-fns:is-category-id($searchTerm)) then
				search-fns:markups-for-category($baseMarkups, $searchTerm)
			else
				let $expandedSearchTerm as xs:string* := search-fns:expand-concept($searchTerm)
				return
					functx:distinct-nodes((search-fns:markups-for-any-concept($baseMarkups, $expandedSearchTerm), search-fns:markups-for-category-name-match($baseMarkups, $searchTerm), search-fns:markups-for-concept-name-match($baseMarkups, $searchTerm)))
		return search-fns:markup-search($newBaseMarkups, $newTerms)
};

declare function search-fns:is-markup-uuid($searchTerm as xs:string) as xs:boolean
{
	let $markups := ($utils:dataCollection//superSegment, $utils:dataCollection//superContent)
	let $sessionId := substring-before($searchTerm, '#')
	let $markupId := substring-after($searchTerm, '#')
	return
		if ($sessionId eq '' or $markupId eq '') 
			then false()
		else if (exists($markups[ancestor::session/@id eq $sessionId][@id eq $markupId]))
			then true()
		else
			()
};

declare function search-fns:is-category-id($searchTerm as xs:string) as xs:boolean
{
	exists($utils:referenceCollection//markupCategory[@id = $searchTerm])
};

declare function search-fns:is-in-category-name($searchTerm as xs:string) as xs:boolean
{
	exists($utils:referenceCollection//markupCategory[functx:contains-word(xs:string(@name), $searchTerm)])
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
			for $synonym in $utils:referenceCollection//synonym[@idRef = $concept]/../synonym
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
					$utils:referenceCollection//concept[@id = $unprocessedId]/subtype/@idRef
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
	let $markupCategories as element()*:= 
		$utils:referenceCollection//markupCategory/tag[@value = $concepts][@type = "concept"]/..
	(:
	let $null := error(QName("http://error.com", "myerror"), concat("Number of markupCategories: ", count($markupCategories)))
	:)
	let $result :=
		($baseMarkups/tag[@value = $concepts][@type = ('concept', 'markupType')]/..,
		 $baseMarkups/tag[@value = $markupCategories/@id][@type = "markupCategory"]/..)
	return
		(:
			error(QName("http://error.com", "myerror"), concat("Number of markupCategories with concept (", $concept, "): ", count($markupCategories))
		:)
		(:error(QName("http://error.com", "myerror"), concat("Number of baseMarkups: ", count($baseMarkups))),:)
		$result
};

declare function search-fns:markups-for-category($baseMarkups as element()*, $categoryId as xs:string*) as element()*
{
	for $markup in $baseMarkups/tag[@value = $categoryId][@type = 'markupCategory']/..
	return $markup
};

declare function search-fns:markups-for-category-name-match($baseMarkups as element()*, $searchTerm as xs:string*) as element()*
{
	let $categoryIds := $utils:referenceCollection//markupCategory[search-fns:matches-start-of-word(xs:string(@name), $searchTerm)]/@id
	for $markup in $baseMarkups/tag[@value = $categoryIds][@type = 'markupCategory']/..
	return $markup
};

declare function search-fns:markups-for-concept-name-match($baseMarkups as element()*, $searchTerm as xs:string*) as element()*
{
	let $categories := $utils:referenceCollection//markupCategory
	let $categoryConcepts := $categories/tag[@type eq "concept"] 
	let $partialConceptMatchCategoryIds := $categoryConcepts[search-fns:matches-start-of-word(xs:string(@value), $searchTerm)]/../@id
	for $markup in $baseMarkups/tag[@value = $partialConceptMatchCategoryIds][@type = 'markupCategory']/..
	return $markup
};

declare function search-fns:markup-for-uuid($baseMarkups as element()*, $markupUuid as xs:string) as element()
{
	let $sessionId := substring-before($markupUuid, '#')
	let $markupId := substring-after($markupUuid, '#')
	return
		$baseMarkups[ancestor::session/@id eq $sessionId][@id eq $markupId]
};

declare function search-fns:markup-as-table-row($markup as element(), $prevSearchString as xs:string, $groupResults as xs:string) as element()
{
	let $count := 
		if ($groupResults eq 'true') then 
			$markup/@classCount
		else
			1
	let $markup := 
		if ($groupResults eq 'true') then 
			$utils:dataCollection//(superSegment | superContent)[ancestor::session/@id eq $markup/@sessionId][@id = $markup/@id]
		else
			$markup
	let $session := $markup/ancestor::session
	let $markupTypeId := $markup/tag[@type = 'markupType']/@value
	let $markupType := $utils:referenceCollection/reference/markupTypes/markupType[@id = $markupTypeId]
	let $additionalConceptsList := search-fns:get-additional-concepts-list($markup)
	let $categoryId := $markup/tag[@type = 'markupCategory']/@value
	let $markupCategory := $utils:referenceCollection/reference/markupCategories/markupCategory[@id = $categoryId]
	let $markupCategoryName := if (exists($markupCategory)) then
			concat(': ', $markupCategory/@name)
		else
			()
	let $markupCategoryConcepts := if (exists($markupCategory)) then
			search-fns:get-markup-category-concepts-links($markupCategory)
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
			if (exists($markup/summary)) then
				string-join(("[summary]", $markup/summary), " ")
			else
				search-fns:element-text($markup)
		else
			search-fns:element-text($markup)
	let $searchString := 
		if (exists($categoryId)) then concat($markupTypeId, ' ', $categoryId)
		else
			(if (not($additionalConceptsList eq '')) then concat($markupTypeId, ' ', $additionalConceptsList)
				else ()
			)
	return
		<table class="single-result">
			<tr>
				<td width="24"><img src="../assets/{$markup/tag[@type='markupType']/@value}.png" width="24" height="24"/></td>
				<td><div class="result-header">
					{search-fns:get-result-header($session, $markup/@id, $targetId, concat($markupType/@name, $markupCategoryName))}  
				</div></td>
			</tr>
			<tr>
				<td width="24"/>
				<td><div class="result-subheader">
					{($markupCategoryConcepts, search-fns:get-additional-concepts-links($markup))}
				</div></td>
			</tr>
			<tr>
				<td width="24"/>
				<td colspan="2"><div class="result-body">
					{substring($text, 0, $search-fns:maxTextChars)} 
					{if (string-length($text) > $search-fns:maxTextChars) then '...' else ()}
					{search-fns:get-node-uuid-text($session/@id, $markup/@id)}
				</div></td>
			</tr>
			<tr>
				<td width="24"/>
				<td colspan="2"><div class="result-footer">
					{concat(search-fns:get-session-title($session), ' (', $session/@id, ')')}
					{search-fns:get-html-word-links($session/@id)}
				</div></td>
			</tr>
			{	
				if ($count > 1) then (
				<tr>
					<td width="24"/>
					<td colspan="2"><div class="result-footer">
						<a href="main.xql?panel=search&amp;search={$prevSearchString}&amp;defaultType=markup&amp;markupUuid={concat($session/xs:string(@id), '%23', $markup/xs:string(@id))}&amp;groupResults=false">{concat('All ', xs:string($count), ' results')}</a>
					</div></td>
				</tr>
				)
				else 
				()
			}
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

declare function search-fns:get-markup-category-concepts-links($markupCategory as element()) as element()*
{
	let $concepts := $markupCategory/tag[@type = 'concept']
	return
		if (exists($concepts)) then
			<span><i>[
				{for $value in $concepts
				return
					<a href="main.xql?panel=search&amp;search={$value/string(@value)}&amp;defaultType=markup">{$value/string(@value)}</a>
				}
			] </i></span>
		else
			<span> </span>
};

declare function search-fns:get-additional-concepts-string($markup as element()) as xs:string
{
	let $conceptNames := $markup/tag[@type = 'concept']/@value
	return
		if (exists($conceptNames)) then
			concat(' +[', string-join($conceptNames, ' '), ']')
		else
			''
};

declare function search-fns:get-additional-concepts-list($markup as element()) as xs:string
{
	string-join($markup/tag[@type = 'concept']/string(@value), ' ')
};

declare function search-fns:get-additional-concepts-links($markup as element()) as element()*
{
	let $concepts := $markup/tag[@type = 'concept']
	return
		if (exists($concepts)) then
			<span><i> +[
				{for $value in $concepts
				return
					<a href="main.xql?panel=search&amp;search={$value/string(@value)}&amp;defaultType=markup">{$value/string(@value)}</a>
				}
			]</i></span>
		else
			<span/>
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
				if (string-length($text) > $search-fns:maxTextChars) then "..." else ()),
				search-fns:get-node-uuid-text($session/@id, $segment/@id)
			}
			</div>
			<div class="result-footer">
				{string($session/@id)}
				{search-fns:get-html-word-links($session/@id)}
			</div>
		</div>
};

(: returns something like " (a-12-3#m13)" :)
declare function search-fns:get-node-uuid-text($sessionId as xs:string, $nodeId as xs:string) as element()
{
	<i><b>{concat(' (', $sessionId, '#', $nodeId, ')')}</b></i>
};

declare function search-fns:event-as-table-row($event as element()) as element()
{
	<div class="single-result">
		<div class="result-header">
			{search-fns:get-result-header-for-event($event, search-fns:get-event-title($event))}
		</div>
		<div class="result-footer">
			{string($event/@id)}
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

declare function search-fns:get-result-header-for-event($event as element(), $text as xs:string) as element()
{
	<a class="result-header" href="main.xql?panel=event&amp;id={$event/@id}">{$text}</a>
};

declare function search-fns:get-html-word-links($sessionId as xs:string) as element()
{
	<span class="htmlWordLinks">
	[
	<a href="main.xql?panel=session&amp;id={$sessionId}">HTML</a>
	|
	<a href="download-docx.xql?sessionId={$sessionId}">Word</a>
	]
	</span>
};

declare function search-fns:get-event-id($sessionId as xs:string) as xs:string?
{
	let $result := $utils:dataCollection/session[@id = $sessionId]/xs:string(@eventId)
	return
		if (normalize-space($result) = '') then
			()
		else
			$result
};

declare function search-fns:get-events-for-session-ids($sessionIds as xs:string*) as element()*
{
	for $sessionId in $sessionIds
	let $eventId := search-fns:get-event-id($sessionId)
	return
		$utils:dataCollection/event[@id = $eventId] 
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

declare function search-fns:filter-categories($categories as element()*, $searchTerms as xs:string*, $markupType as xs:string) as element()*
{
	if (not(exists($searchTerms))) then
		$categories
	else
		let $markupType :=
			if (not(exists($markupType))) then 'all'
			else $markupType
		let $searchTerm as xs:string := $searchTerms[1]
		let $expandedSearchTerm as xs:string* := search-fns:expand-concept($searchTerm)
		let $newTerms := remove($searchTerms, 1)
		let $expandedCategories := $categories/tag[@value = $expandedSearchTerm][@type = "concept"]/..
		let $partialNameMatchCategories := $categories[search-fns:matches-start-of-word(xs:string(@name), $searchTerm)]
		let $categoryConcepts := $utils:referenceCollection//markupCategory/tag[@type eq "concept"] 
		let $partialConceptMatchCategories := ($categories intersect $categoryConcepts[search-fns:matches-start-of-word(xs:string(@value), $searchTerm)]/..)
		let $newCategories := $utils:referenceCollection/
			functx:distinct-nodes(($expandedCategories, $partialNameMatchCategories, $partialConceptMatchCategories))
		return
			search-fns:filter-categories($newCategories, $newTerms, $markupType)	
};

declare function search-fns:matches-start-of-word($string as xs:string?, $term as xs:string) as xs:boolean
{
	let $upString := upper-case($string)
	let $upTerm := upper-case($term)
	return
		if (string-length($term) < 3) then
			false()
		else
			matches($upString, concat("^(.*\W)?", $upTerm, ".*"))
};

declare function search-fns:name-contains-concept($string as xs:string, $concept as xs:string) as xs:boolean
{
	let $concept-no-hyphens := replace($concept, "-", " ")
	return
		if (contains($string, $concept-no-hyphens)) then
			true()
		else
			false()
};
