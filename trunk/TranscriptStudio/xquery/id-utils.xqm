xquery version "1.0";

module namespace id-utils = "http://www.ishafoundation.org/ts4isha/xquery/id-utils";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";
declare namespace util = "http://exist-db.org/xquery/util";

declare variable $id-utils:media-domains := ('audio', 'video', 'image');
declare variable $id-utils:all-domains := ($id-utils:media-domains, "device", 'event', 'session');

declare function id-utils:id-already-exists($tagName as xs:string?, $id as xs:string) as xs:boolean
{
	exists(collection('/db/ts4isha/data')//*[(empty($tagName) or local-name(.) eq $tagName) and @id eq $id])
};

declare function id-utils:generate-event-id($eventType as xs:string) as xs:string
{
	id-utils:generate-id('event', concat($eventType, '-'))
};

declare function id-utils:generate-session-id($eventId as xs:string) as xs:string?
{
	id-utils:generate-id('session', concat($eventId, '-'))
};

declare function id-utils:generate-id($tagName as xs:string, $prefix as xs:string) as xs:string
{
	id-utils:get-max-id($tagName, $prefix, 1)
};

declare function id-utils:get-max-id($tagName as xs:string, $prefix as xs:string, $valueToAdd as xs:integer?) as xs:string
{
	let $valueToAdd := ($valueToAdd, 0)[1]
	let $maxValue := (id-utils:get-max-id-integer($tagName, $prefix), 0)[1]
	return
		concat($prefix, $maxValue + $valueToAdd)
};

declare function id-utils:get-max-id-integer($tagName as xs:string, $prefix as xs:string) as xs:integer?
{
	max(collection('/db/ts4isha/data')//*[local-name(.) eq $tagName]/id-utils:get-id-integer-component(@id, $prefix))
};

(:
   If the id does not start with the specified prefix then return 0
   otherwise return the integer component of the id (i.e. the number after the prefix
:)
declare function id-utils:get-id-integer-component($id as xs:string?, $prefix as xs:string) as xs:integer?
{
	if (not(exists($id))) then
		()
	else if (not(starts-with($id, $prefix))) then
		()
	else
		let $afterPrefix := substring($id, string-length($prefix) + 1)
		let $afterNumber := replace($afterPrefix, '\d+', '')
		let $number := substring($afterPrefix, 1, string-length($afterPrefix) - string-length($afterNumber))
		return
			util:catch('java.lang.Exception', xs:integer($number), -1) 
};
