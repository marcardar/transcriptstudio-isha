<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Isha Foundation - Configure Database</title>
	</head>
	<body>
	{
let $currentUser := xmldb:get-current-user()
return
	if (xmldb:is-admin-user($currentUser)) then
		let $dataCollectionPath := '/db/ts4isha/data'
		let $newCollectionPaths :=
			(: looks like there is a bug in eXist because this line does not work:
			for $eventType in collection('/db/ts4isha/reference')/reference/eventTypes/eventType/@id
			   but this line does:
			:)
			for $eventType in collection('/db/ts4isha/reference')//*[local-name(.) = 'eventType']/@id
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
				for $newCollectionPath in $newCollectionPaths
				return
					concat($newCollectionPath, '')
			)
			else
			(
				'No new collections created'
			)
	else
		error('Only admin user allowed to create data collections')
}
	</body>
</html>