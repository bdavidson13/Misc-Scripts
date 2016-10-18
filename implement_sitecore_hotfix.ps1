#Take in Root directory of websites
param(
[string]$websites_root_directory
)
#Vars
$temp_folder = "c:\hotfix_temp"
$download_url = "https://dl.sitecore.net/hotfix/Sitecore%20Session%20Serialization%201.0.0%20rev.%20161011%20Hotfix%20128003-1%20NOT%20SC%20PACKAGE.zip"
$hotfix_zip = -join ($temp_folder,"\Sitecore Session Serialization 1.0.0 rev. 161011 Hotfix 128003-1 NOT SC PACKAGE.zip")
$sitecore_dll ="\bin\sitecore.client.dll"

#Create tempfolder
new-item $temp_folder -itemtype directory

#Download Zipfile 
$WebClient = New-Object System.Net.Webclient
$WebClient.DownloadFile($download_url, $hotfix_zip)


#Unzip files to temp folder
$shell = new-object -com shell.application
$zip = $shell.NameSpace($hotfix_zip)
foreach($item in $zip.items()){
	$shell.Namespace($temp_folder).copyhere($item)
} 

#Delete zip file
Remove-Item $hotfix_zip

#go through each folder in Root directory
$root = (Get-ChildItem $websites_root_directory -directory).fullname

Function needs_hotfix{
param($major_version, $minor_version)
	if($major_version -gt 7){
		return $true
	}
	if($major_version -eq 7 -and $minor_version -gt 4){
		return $true
	} 
	return $false
}
foreach($main_site_folder in $root){
	foreach($website_folder in (Get-ChildItem $main_site_folder -directory).fullname){
		if ([System.IO.File]::Exists((-join ($website_folder, $sitecore_dll )))){
			$major = (Get-Item (-join ($website_folder, $sitecore_dll ))).VersionInfo.FileMajorPart
			$minor = (Get-Item (-join ($website_folder, $sitecore_dll ))).VersionInfo.FileMinorPart
			if(needs_hotfix $major $minor){
				robocopy $temp_folder $website_folder /s 
			}
		}
	}
}

#CLEAN UP - delete temp folder
Remove-Item $temp_folder -recurse



