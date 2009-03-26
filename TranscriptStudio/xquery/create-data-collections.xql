declare namespace create-data-collections = "http://www.ishafoundation.org/ts4isha/xquery/create-data-collections";

let $currentUser := xmldb:get-current-user()
return
	if (xmldb:is-admin-user($currentUser)) then
		let $dataCollectionPath := '/db/ts4isha/data'
		return
			for $eventType in collection('/db/ts4isha/reference')/reference/eventTypes/eventType/@id
			return
				if (xmldb:collection-exists(concat($dataCollectionPath, '/', $eventType))) then
					()
				else
					xmldb:create-collection($dataCollectionPath, $eventType)
	else
		error('Only admin user allowed to create data collections')