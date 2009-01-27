xquery version "1.0";

module namespace concept-fns = "http://www.ishafoundation.org/archives/xquery/concept-fns";

declare function concept-fns:count-concept-instances($conceptId as xs:string) as xs:integer
{
	count(collection('/db/archives/data')/session/transcript//tag[@type eq 'concept' and @value=$conceptId])
};

declare function concept-fns:get-all-concepts() as xs:string*
{
	let $reference := collection('/db/archives/reference')/reference
	let $categoryConcepts := $reference/categories/category/tag[@type eq 'concept']/string(@value)
	let $otherReferenceConcepts := $reference//concept/string(@idRef)
	let $additionalConcepts := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept']/string(@value)
	return
		for $concept in distinct-values(($categoryConcepts, $otherReferenceConcepts, $additionalConcepts))
		order by $concept 
		return $concept
};

declare function concept-fns:add-synonyms($conceptIds as xs:string*) as xs:boolean
{
	if (count($conceptIds) < 2) then
		false()
	else
		let $synonymsElement := collection('/db/archives/reference')/reference/synonyms
		let $existingGroups := $synonymsElement/synonym/concept[@idRef = $conceptIds]/..
		return
			let $targetGroup :=
				if (count($existingGroups) = 0) then
				(
					let $newGroup := <synonym/>
					let $null := update insert $newGroup into $synonymsElement
					(: cannot return $newGroup because "update" cannot handle elements that have been constructed in memory - so grab what we just persisted instead :)
					return $synonymsElement/synonym[last()]
				)
				else if (count($existingGroups) = 1) then
				(
					$existingGroups[1]
				)
				else
				(
					let $null :=
					(
						update insert $existingGroups[position() > 1]/concept into $existingGroups[1]
						,
						update delete $existingGroups[position() > 1]
					)
					return $existingGroups[1]
				)
			let $newGroupMembers :=
				for $conceptId in $conceptIds
				where not(exists($targetGroup/concept[@idRef eq $conceptId]))
				return
					element { 'concept' }
					{ attribute {'idRef'} {$conceptId} }
			let $null :=
				if (exists($newGroupMembers)) then
					update insert $newGroupMembers into $targetGroup
				else
					()
			return true()
};

declare function concept-fns:remove-synonym($conceptId as xs:string) as xs:boolean
{
	let $synonym := collection('/db/archives/reference')/reference/synonyms/synonym/concept[@idRef eq $conceptId]
	return
		if (exists($synonym)) then
			let $null :=
				if (count($synonym/../concept) <= 2) then
					(: deleting this synonym will leave this group meaningless so remove whole group :)
					update delete $synonym/..
				else
					update delete $synonym
			return true()
		else
			false()
};

declare function concept-fns:add-subtype($superConceptId as xs:string, $subConceptId as xs:string) as xs:boolean
{
	let $conceptsElement := collection('/db/archives/reference')/reference/concepts
	let $superConcept := $conceptsElement/concept[@idRef eq $superConceptId]
	return
		if (exists($superConcept)) then
			if (exists($superConcept/concept[@idRef eq $subConceptId])) then
				(: this relationship already exists :)
				false()
			else
				let $subConcept :=
					element { 'concept' }
					{ attribute {'idRef'} {$subConceptId} }
				let $null :=
					update insert $subConcept into $superConcept
				return true()
		else
			(: super concept does not exist so create new one :)
			let $subConcept :=
				element { 'concept' }
				{ attribute {'idRef'} {$subConceptId} }
			let $superConcept :=
				element { 'concept' }
				{ (attribute {'idRef'} {$superConceptId}, $subConcept) }
			let $null :=
				update insert $superConcept into $conceptsElement
			return true()
};

(: removes the sub concept from the super concept - but does not remove the super concept (even if there are no other sub concepts) :)
declare function concept-fns:remove-subtype($superConceptId as xs:string, $subConceptId as xs:string) as xs:boolean
{
	let $conceptsElement := collection('/db/archives/reference')/reference/concepts
	return concept-fns:delete-internal($conceptsElement/concept[@idRef eq $superConceptId]/concept[@idRef eq $subConceptId]) > 0
};

(: Returns the number of concepts added (0 or 1 depending on whether the concept already exists or not) :)
declare function concept-fns:add($conceptId as xs:string) as xs:integer
{
	let $reference := collection('/db/archives/reference')/reference
	return
		if (exists($reference/concepts/concept[@idRef eq $conceptId])) then
			(: this concept is already at the top level in the hierarchy so do nothing :)
			0
		else 
			let $newConcept := 
				element { 'concept' }
				{ attribute {'idRef'} {$conceptId} }
			let $null := update insert $newConcept into $reference/concepts
			return 1
};

(: Returns the number of concepts deleted :)
declare function concept-fns:rename($conceptId as xs:string, $newConceptId) as xs:integer
{	
	let $reference := collection('/db/archives/reference')/reference
	let $renameValues :=
		(
		concept-fns:rename-category-concept($conceptId, $newConceptId, $reference/categories)
		,
		concept-fns:rename-super-concept($conceptId, $newConceptId, $reference/concepts)
		,
		concept-fns:rename-sub-concept($conceptId, $newConceptId, $reference/concepts)
		,
		concept-fns:rename-synonym-concept($conceptId, $newConceptId, $reference/synonyms)
		,
		concept-fns:rename-additional-concept($conceptId, $newConceptId, collection('/db/archives/data'))
		)
	return sum($renameValues)
};

declare function concept-fns:rename-category-concept($conceptId as xs:string, $newConceptId as xs:string, $categories as element()) as xs:integer
{
	let $categoryTags := $categories/category/tag[@type eq 'concept' and @value eq $conceptId]
	let $null :=
		for $categoryTag in $categoryTags
		return
			if (exists($categoryTag/../tag[@type eq 'concept' and @value eq $newConceptId])) then
				(: The new concept id is already a tag of the category so just delete it :)
				update delete $categoryTag
			else
				update value $categoryTag/@value with $newConceptId
	return count($categoryTags)
};

declare function concept-fns:rename-super-concept($oldConceptId as xs:string, $newConceptId as xs:string, $conceptsElement as element()) as xs:integer
{
	if ($oldConceptId eq $newConceptId) then
		0
	else
		let $oldConcept := $conceptsElement/concept[@idRef eq $oldConceptId]
		return
			if (not(exists($oldConcept))) then
				0
			else
				let $newConcept := $conceptsElement/concept[@idRef eq $newConceptId]
				let $null :=
					if (not(exists($newConcept))) then
						(: only need to rename old value to new value - no danger of merge :)
						update value $oldConcept/@idRef with $newConceptId
					else
						(: append the old subconcepts to the new concept's children :)
						(
							for $oldSubConcept in $oldConcept/concept
							where not(exists($newConcept/concept[@idRef eq $oldSubConcept/string(@idRef)]))
							return
								(: old concept's sub concept is not a sub concept for the new concept name - so insert it :)
								update insert $oldSubConcept into $newConcept
						,
							update delete $oldConcept
						)
				return 1
};

(: its fine for a concept to have multiple super concepts :)
declare function concept-fns:rename-sub-concept($oldConceptId as xs:string, $newConceptId as xs:string, $conceptsElement as element()) as xs:integer
{
	let $oldConcepts := $conceptsElement/concept/concept[@idRef eq $oldConceptId]
	let $null :=
		for $oldConcept in $oldConcepts
		return
			if (exists($oldConcept/../concept[@idRef eq $newConceptId])) then
				(: super content already has concept we are renaming to :)
				update delete $oldConcept
			else
				(: we can safely rename :)
				update value $oldConcept/@idRef with $newConceptId
	return count($oldConcepts)
};

(: a synonym can appear in at most ONE group :)
declare function concept-fns:rename-synonym-concept($oldConceptId as xs:string, $newConceptId as xs:string, $synonymsElement as element()) as xs:integer
{
	let $oldConcept := $synonymsElement/synonym/concept[@idRef eq $oldConceptId]
	return
		if (not(exists($oldConcept))) then
			0
		else
			let $newConcept := $synonymsElement/synonym/concept[@idRef eq $newConceptId]
			let $null :=
				if (not(exists($newConcept))) then
					(: only need to rename old value to new value - no danger of new concept appearing twice :)
					update value $oldConcept/@idRef with $newConceptId
				else
					(: need to be careful because renaming to something that is already a synonym :)
					if (exists($oldConcept/../concept[@idRef eq $newConceptId])) then 
						(: already in the same synonym group so just delete old one :)
						update delete $oldConcept
					else
						(: different synonym groups so append old synonyms to new synonyms :)
						let $oldSynonymGroup := $oldConcept/..
						let $newSynonymGroup := $newConcept/..
						return
						(
							for $oldSynonym in $oldSynonymGroup/concept[@idRef != $oldConcept/@idRef]
							where not(exists($newSynonymGroup/concept[@idRef = $oldSynonym/@idRef]))
							return
								(: old concept's sub concept is not a sub concept for the new concept name - so insert it :)
								update insert $oldSynonym into $newSynonymGroup
						,
							update delete $oldSynonymGroup
						)
			return 1
};

declare function concept-fns:rename-additional-concept($oldConceptId as xs:string, $newConceptId, $dataCollection) as xs:integer
{
	let $additionalTags := $dataCollection/session/transcript/(superSegment|superContent)/tag[@type eq 'concept' and @value eq $oldConceptId]
	let $null :=
		for $additionalTag in $additionalTags
		return
			if (exists($additionalTag/../tag[@type eq 'concept' and @value eq $newConceptId])) then
				(: The new concept id is already a tag of the category so just delete it :)
				update delete $additionalTag
			else
				update value $additionalTag/@value with $newConceptId
	return count($additionalTags)
};

declare function concept-fns:remove($conceptId as xs:string) as xs:integer
{	
	let $reference := collection('/db/archives/reference')/reference
	let $deleteValues :=
		(
		concept-fns:delete-internal($reference/categories/category/tag[@type eq 'concept' and @value eq $conceptId])
		,
		concept-fns:delete-internal($reference/concepts/concept[@idRef eq $conceptId])
		,
		(: its ok to leave a parent concept with no children because this is what we do if we simply want to "document" a concept :)
		concept-fns:delete-internal($reference/concepts/concept/concept[@idRef eq $conceptId])
		,
		for $synonymConcept in $reference/synonyms/synonym/concept[@idRef eq $conceptId]
		return
			if (count($synonymConcept/../*) <= 2) then
				(: deleting this concept will leave at most one other concept - which is not enough for a group :) 
				concept-fns:delete-internal($synonymConcept/..)
			else
				concept-fns:delete-internal($synonymConcept)
		,
		concept-fns:delete-internal(collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept' and @value eq $conceptId])
		)
	return sum($deleteValues)
};

declare function concept-fns:delete-internal($nodes as element()*) as xs:integer
{
	let $null := update delete $nodes
	return count($nodes)
};
