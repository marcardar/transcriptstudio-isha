xquery version "1.0";

import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Isha Foundation - Configure Database</title>
	</head>
	<body>
	{
	if (utils:is-current-user-admin()) then
		let $dataCollectionPath := $utils:dataCollectionPath
		let $newCollectionPaths :=
			(: looks like there is a bug in eXist because this line does not work:
			for $eventType in $utils:referenceCollection/reference/eventTypes/eventType/@id
			   but this line does:
			:)
			for $eventType in collection($utils:referenceCollectionPath)//*[local-name(.) = 'eventType']/@id
			return
				if (xmldb:collection-exists(concat($dataCollectionPath, '/', $eventType))) then
					()
				else
					xmldb:create-collection($dataCollectionPath, $eventType)
		return
			if (exists($newCollectionPaths)) then
			(
				concat('Created ', count($newCollectionPaths), ' collection(s)', ':')
			,
				<p/>
			,
				for $newCollectionPath in $newCollectionPaths
				return
					($newCollectionPath, <br/>)
			)
			else
			(
				'No new collections created'
			)
	else
		error((), 'Only admin user allowed to create data collections')
	}
	</body>
</html>