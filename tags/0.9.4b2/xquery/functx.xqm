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

declare function functx:add-or-update-attributes($elements as element()*, $attrNames as xs:QName*, $attrValues as xs:anyAtomicType*) as element()? {
	for $element in $elements
	return element {node-name($element)}
	{
		for $attrName at $seq in $attrNames
		return attribute {$attrName}
		                 {$attrValues[$seq]},
			$element/@*[not(node-name(.) = $attrNames)],
			$element/node()
	}
};

declare function functx:remove-elements($elements as element()*, $names as xs:string*) as element()* {			 
	for $element in $elements
	return element
		{node-name($element)}
		{
			$element/@*,
			$element/*[not(local-name(.) = $names)]
		}
};