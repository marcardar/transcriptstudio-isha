xquery version "1.0";

module namespace concept-fns = "http://www.ishafoundation.org/archives/xquery/concept-fns";

declare function concept-fns:get-all-concepts-ordered() as xs:string*
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

declare function concept-fns:add-synonym($conceptId1 as xs:string, $conceptId2 as xs:string) as xs:boolean
{
	true
};

declare function concept-fns:remove-synonym($conceptId1 as xs:string, $conceptId2 as xs:string) as xs:boolean
{
	true
};

(: Returns the number of concepts deleted :)
declare function concept-fns:add($conceptId as xs:string) as xs:integer
{
	let $reference := collection('/db/archives/reference')/reference
	return
		if (exists($reference/conceptHierarchy/concept[@idRef eq $conceptId])) then
			(: this concept is already at the top level in the hierarchy so do nothing :)
			0
		else 
			let $newConcept := 
				element { 'concept' }
				{ attribute {'idRef'} {$conceptId} }
			let $null := update insert $newConcept into $reference/conceptHierarchy
			return 1
};

(: Returns the number of concepts deleted :)
declare function concept-fns:rename($conceptId as xs:string, $newConceptId) as xs:integer
{	
	let $reference := collection('/db/archives/reference')/reference
	let $renameValues :=
		(
		concept-fns:rename-category-concept($conceptId, $newConceptId, $reference)
		,
		concept-fns:rename-super-concept($conceptId, $newConceptId, $reference)
		,
		concept-fns:rename-sub-concept($conceptId, $newConceptId, $reference)
		,
		concept-fns:rename-synonym-concept($conceptId, $newConceptId, $reference)
		,
		concept-fns:rename-additional-concept($conceptId, $newConceptId)
		)
	return sum($renameValues)
};

declare function concept-fns:rename-category-concept($conceptId as xs:string, $newConceptId as xs:string, $reference as element()) as xs:integer
{
	let $categoryTags := $reference/categories/category/tag[@type eq 'concept' and @value eq $conceptId]
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

declare function concept-fns:rename-super-concept($conceptId as xs:string, $newConceptId as xs:string, $reference as element()) as xs:integer
{
	let $oldConcept := $reference/conceptHierarchy/concept[@idRef eq $conceptId]
	return
		if (not(exists($oldConcept))) then
			0
		else
			let $newConcept := $reference/conceptHierarchy/concept[@idRef eq $newConceptId]
			let $null :=
				if (not(exists($newConcept))) then
					(: only need to rename old value to new value - no danger of merge :)
					update value $oldConcept/@idRef with $newConceptId
				else
					(: merge the old with the new :)
					let $mergedSubConceptIds := distinct-values($reference/conceptHierarchy/concept[@idRef = ($conceptId, $newConceptId)]/*/string(@idRef))
					let $mergedConcept :=
						element { 'concept' }
							{
							attribute {'idRef'} {$newConceptId},
							for $mergedSubConceptId in $mergedSubConceptIds 
							return
								if ($mergedSubConceptId != '') then
									element { 'concept' }
									{ attribute {'idRef'} {$mergedSubConceptId} }
								else
									()
							}
					return
						(
							update delete $oldConcept
						,
							update replace $newConcept with $mergedConcept
						)
			return 1
};

(: its fine for a concept to have multiple super concepts :)
declare function concept-fns:rename-sub-concept($conceptId as xs:string, $newConceptId as xs:string, $reference as element()) as xs:integer
{
	let $oldConcepts := $reference/conceptHierarchy/concept/concept[@idRef eq $conceptId]
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
declare function concept-fns:rename-synonym-concept($conceptId as xs:string, $newConceptId as xs:string, $reference as element()) as xs:integer
{
	let $oldConcept := $reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef eq $conceptId]
	return
		if (not(exists($oldConcept))) then
			0
		else
			let $newConcept := $reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef eq $newConceptId]
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
						(: merge the two synonym groups :)
						let $mergedSynonymConceptIds := distinct-values(($oldConcept|$newConcept)/../*[not(@idRef eq $conceptId)]/string(@idRef))
						let $mergedSynonymGroup :=
							element { 'conceptSynonymGroup' }
								{
								for $mergedSynonymConceptId in $mergedSynonymConceptIds 
								return
									element { 'concept' }
									{ attribute {'idRef'} {$mergedSynonymConceptId} }
								}
						return
							(
								update delete $oldConcept/..
							,
								update replace $newConcept/.. with $mergedSynonymGroup
							)
			return 1
};

declare function concept-fns:rename-additional-concept($conceptId as xs:string, $newConceptId) as xs:integer
{
	let $additionalTags := collection('/db/archives/data')/session/transcript/(superSegment|superContent)/tag[@type eq 'concept' and @value eq $conceptId]
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
		concept-fns:delete-internal($reference/conceptHierarchy/concept[@idRef eq $conceptId])
		,
		(: its ok to leave a parent concept with no children because this is what we do if we simply want to "document" a concept :)
		concept-fns:delete-internal($reference/conceptHierarchy/concept/concept[@idRef eq $conceptId])
		,
		for $synonymConcept in $reference/conceptSynonymGroups/conceptSynonymGroup/concept[@idRef eq $conceptId]
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
