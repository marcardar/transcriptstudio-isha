xquery version "1.0";

module namespace functx = "http://www.functx.com"; 
declare function functx:add-attributes 
  ( $elements as element()* ,
    $attrNames as xs:QName* ,
    $attrValues as xs:anyAtomicType* )  as element()? {
       
   for $element in $elements
   return element { node-name($element)}
                  { for $attrName at $seq in $attrNames
                    return if ($element/@*[node-name(.) = $attrName])
                           then ()
                           else attribute {$attrName}
                                          {$attrValues[$seq]},
                    $element/@*,
                    $element/node() }
};

declare function functx:remove-attributes($elements as element()*, $attrNames as xs:QName*) as element() {       
	for $element in $elements
	return element
		{node-name($element)}
		{
			$element/@*[not(node-name(.) = $attrNames)],
			$element/node()
		}
};
 
declare function functx:add-or-update-attributes($elements as element()*, $attrNames as xs:QName*, $attrValues as xs:anyAtomicType*) as element()? {
	for $element in $elements
	return element
		{node-name($element)}
		{
		for $attrName at $seq in $attrNames
		return attribute {$attrName}
		                 {$attrValues[$seq]},
			$element/@*[not(node-name(.) = $attrNames)],
			$element/node()
		}
};

declare function functx:remove-elements($elements as element()*, $names as xs:string*) as element()* 
{			 
	for $element in $elements
	return element
		{node-name($element)}
		{
			$element/@*,
			$element/*[not(local-name(.) = $names)]
		}
};

declare function functx:contains-word($string as xs:string?, $word as xs:string) as xs:boolean
{
	let $upString := upper-case($string)
	let $upWord := upper-case($word)
	return
		matches($upString, concat("^(.*\W)?", $upWord, "(\W.*)?$"))
};
