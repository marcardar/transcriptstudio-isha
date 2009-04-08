xquery version "1.0";

module namespace admin-panel = "http://www.ishafoundation.org/ts4isha/xquery/admin-panel";

import module namespace media-fns = "http://www.ishafoundation.org/ts4isha/xquery/media-fns" at "media-fns.xqm";
import module namespace utils = "http://www.ishafoundation.org/ts4isha/xquery/utils" at "utils.xqm";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace session = "http://exist-db.org/xquery/session";
declare namespace xdb = "http://exist-db.org/xquery/xmldb";
declare namespace util = "http://exist-db.org/xquery/util";

declare function admin-panel:main() as element()*
{
if (utils:is-current-user-admin()) then	
	(
		<center><h2>Isha Foundation Transcript Administration</h2></center>
	,
		<div class="panel">
			<h3>Configure Database</h3>
			Click <a href="configure-database.xql">here</a> to add the event collections
			<h3>Upload Media Metadata</h3>
			<table id="header">
				<tr><td valign="bottom">
				<form id="upload-media-metadata-form" method="POST"  enctype="multipart/form-data">
					<input type="hidden" name="panel" value="admin"/>
					<table id="upload-media-metadata-form-table" cellpadding="2"><tr>
						<td><input type="submit" value="Upload"/></td> 
                        <td>
                            <input type="file" size="30" name="upload-media-metadata"/>
                        </td>
					</tr></table>
				</form>
				</td></tr>
			</table>
			{
			let $uploadedFilename := request:get-uploaded-file-name("upload-media-metadata")
			return
				if (not(exists($uploadedFilename))) then
					()
				else if (not(exists($uploadedFilename)) or $uploadedFilename = '') then
					'No file specified'
				else
					let $uploadedFile := request:get-uploaded-file("upload-media-metadata")
					let $tempColl := xdb:create-collection('/db/ts4isha', 'temp')
					let $tempFile := concat(util:uuid(), '.xml')
					let $tempPath := xdb:store($tempColl, $tempFile, $uploadedFile)
					let $doc := doc($tempPath)
					let $rootElementName := local-name($doc/*[1])
					let $result :=
						if ($rootElementName != 'mediaMetadata') then
							concat('Incorrect root element name: ', $rootElementName)
						else
							let $newMediaDetails :=
								for $device in $doc//device
								let $sessionId := $device/ancestor-or-self::*[exists(@sessionId)]/xs:string(@sessionId)
								let $importedMediaIds := $device/media
								let $appendedMediaIds := media-fns:append-media-elements($importedMediaIds, $sessionId)/xs:string(@id)
								return
								(
									<h3>Session ID: {$sessionId}, Device ID: {$device/xs:string(@id)}</h3>
								,
									if (not(exists($appendedMediaIds))) then
										<p>Nothing imported</p>
									else
										<p>{
										for $appendedMediaId in $appendedMediaIds
										return
											($appendedMediaId, <br/>)
										}</p>
								)
							return
								$newMediaDetails
					let $null := xdb:remove($tempColl, $tempFile)
					return
						$result
			}
		</div>
	)
else
	error('Only admin user allowed to use admin panel')
};
