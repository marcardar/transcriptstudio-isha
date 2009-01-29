xquery version "1.0";

module namespace markup-category-fns = "http://www.ishafoundation.org/archives/xquery/markup-category-fns";

declare function markup-category-fns:edit($id as xs:string, $name as xs:string, $markupTypeIds as xs:string+, $conceptIds as xs:string*) as xs:boolean
{
	let $markupCategoriesElement := collection('/db/archives/reference')/reference/markupCategories
	let $existingElement := $markupCategoriesElement/markupCategory[@id eq $id]
	let $newElement :=
		<markupCategory id="{$id}" name="{$name}">
		{
			for $markupTypeId in $markupTypeIds
			return
				<tag type="markupType" value="{$markupTypeId}"/> 
		,
			for $conceptId in $conceptIds
			return
				<tag type="concept" value="{$conceptId}"/> 
		}
		</markupCategory>

	let $null :=
		if (exists($existingElement)) then
			update replace $existingElement with $newElement
		else
			update insert $newElement into $markupCategoriesElement
	return exists($existingElement)
};
