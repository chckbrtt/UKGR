function docupper{


        [cmdletBinding(DefaultParameterSetName = 'Compatibility', SupportsShouldProcess)]
        param(

    [Parameter(Mandatory)]
    [object] $apikey,
    [Parameter(Mandatory)]
    [object] $companySN,
    [Parameter(Mandatory)]
    [object] $password,
    [Parameter(Mandatory)]
    [object] $username,
    [Parameter(Mandatory)]
    [int] $pod,
    [Parameter(Mandatory)]
    [int] $doctypeid,
    [Parameter(Mandatory)]
    [object] $doctypedisp,
    [Parameter()]
    [object] $doctype = 'HR_EMPLOYEE_DOCUMENT',
    [Parameter(Mandatory)]
    [int] $cid
   
)    
$authurl = "https://secure$pod.saashr.com/ta/rest/v1/login"
$usersurl = "https://secure$pod.saashr.com/ta/rest/v2/companies/$cid/employees"
$createmetaURL = "https://secure2.saashr.com/ta/rest/v2/companies/$cid/ids"

    ######## TOKEN HEADER CREATION

    $theader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $theader.Add("api-key", $apikey)
    $theader.Add("Content-Type", "application/json")

    $GetTokenBody = @{
    "credentials"= @{
        "username"=$username
        "password"=$password
        "company" =$companySN
    }
    }
    $tokenBody = $GetTokenBody | ConvertTo-Json

    $t = (Invoke-RestMethod $authurl -Method 'POST' -Headers $theader -Body $tokenbody).token

    if ($t){
        write-host "UKG Ready Token Obtained: $t" -ForegroundColor Green
        write-host "Obtaining a list of users from your tenant.." -ForegroundColor Yellow
        write-host "Using Endpoint: "$usersurl -ForegroundColor Cyan
        
            ######### POST HEADER CREATION
    $pheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $pheaders.Add("Authentication", "Bearer $t")
    $pheaders.Add("Content-Type", "application/json")
    $pheaders.Add("Content-Length", 0)
    $pheaders.Add("Accept", "*/*")
            ######### Get HEADER CREATION
    $Gheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Gheaders.Add("authentication", "Bearer $t")
    $Gheaders.Add("Content-Type", "Application/json")

        get-users -userurl $usersurl -gheaders $Gheaders
    }else{
        return Write-host "UKG Ready Token retrieval failed" -ForegroundColor Red
        exit
    }
    }
    Function get-users {

        [cmdletBinding(DefaultParameterSetName = 'Compatibility', SupportsShouldProcess)]
        param(
    [Parameter(Mandatory)]
    [object] $userurl,
    [Parameter(Mandatory)]
    [object] $gheaders
            )  

       try {
        $users = (Invoke-RestMethod $usersurl -Method 'GET' -Headers $Gheaders).employees
       } 

        catch {
            return  $_.Exception
            exit

        }

if ($users){
        write-host "Users Identified: "$users.count -ForegroundColor Green
        build-menu -users $users
}else{
        return write-host "Failed to obtain user list, please check your permissions" -ForegroundColor Red
}
    }

Function build-menu {
    [cmdletBinding(DefaultParameterSetName = 'Compatibility', SupportsShouldProcess)]
    param(
[Parameter(Mandatory)]
[object] $users

        )

foreach ($user in $users)
    {
    '{0} - {1}' -f ($users.IndexOf($user) + 1), $user.username.toupper() + ' '+'('+ $user.id +')'
    }

$Choice = ''
while ([string]::IsNullOrEmpty($Choice))
    {
    Write-Host
    $Choice = Read-Host 'Please choose an item by number '
    if ($Choice -notin 1..$users.Count)
        {
        [console]::Beep(1000, 300)
        Write-Warning ''
        Write-Warning ('    Your choice [ {0} ] is not valid.' -f $Choice)
        Write-Warning ('        The valid choices are 1 thru {0}.' -f $users.Count)
        Write-Warning '        Please try again ...'
        pause

        $Choice = ''
        }
    }

''
'You chose {0}' -f $users.username[$Choice - 1]
$Choiceid = $users.id[$Choice - 1]
$Choiceuname = $users.username[$Choice - 1]
write-host "Please select the folder containing the EE's documnets..file explorer might be hiding behind this window" -ForegroundColor Yellow
get-folders

}
Function get-folders($initialDirectory="") {
write-host "------------------------------------------------------------------------------------------------------"
write-host "In Get-Folders Function "-ForegroundColor Blue
write-host "Account ID "$choiceid -ForegroundColor Blue
write-host "Account Username "$choiceuname -ForegroundColor Blue
write-host "------------------------------------------------------------------------------------------------------"

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder for EE: $choiceuname"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    
upload-docs -folder $folder -Choiceid $Choiceid -doctype $doctype -doctypedisp $doctypedisp -doctypeid $doctypeid

}
function upload-docs {



    [cmdletBinding(DefaultParameterSetName = 'Compatibility', SupportsShouldProcess)]
    param(
[Parameter(Mandatory)]
[object] $folder,
[Parameter(Mandatory)]
[object] $Choiceid,
[Parameter()]
[object] $doctype,
[Parameter()]
[object] $doctypeid,
[Parameter()]
[object] $doctypedisp
        )

        write-host "------------------------------------------------------------------------------------------------------"
        write-host "In upload-docs Function "-ForegroundColor Blue
        write-host "Account ID "$choiceid -ForegroundColor Blue
        write-host "Account Username "$choiceuname -ForegroundColor Blue
        write-host "Account Folder "$folder -ForegroundColor Blue
        write-host "Account Doctype "$doctype -ForegroundColor Blue
        write-host "Account DoctypeID "$doctypeid -ForegroundColor Blue
        write-host "Account DoctypeDisp "$doctypedisp -ForegroundColor Blue
        write-host "Post Headers Auth "$pheaders.Authentication -ForegroundColor Blue
        write-host "------------------------------------------------------------------------------------------------------"



$filelist = Get-ChildItem $folder

$upstatusresults = @()
foreach ($file in $filelist){
        $accountid = $Choiceid
        $docdescrip = "File for $choiceid"
    $filemetadata = @{
        type = $doctype
        file_name = $file.name
        document_type = @{
            id = $doctypeid
            display_name = $doctypedisp
        }
        linked_id = $Choiceid
        description = "Uploaded Automatically"
        attributes = @{
            category = "EE files"
            ex_info_1 = ""
            ex_info_2 = ""
            ex_info_3 = ""
            directory = "/"
        }
    
    }
    $body = $filemetadata | ConvertTo-Json
write-host "Metadata body: "
write-host $body
sleep -Seconds 5
    write-host "Building file Metadata via API endpoint " -ForegroundColor Yellow
    try {
        Invoke-RestMethod $createmetaURL -method POST -Headers $gheaders -body $body -ResponseHeadersVariable response
    }
    catch {
        $_.Exception
    }



Write-host "The results of creating file metadata for: "$file.name -ForegroundColor Yellow
$metaurl1 = $response.location

if ($metaurl1){write-host "Success" -ForegroundColor Green}Else{
    Write-host "Failure" -ForegroundColor Red
    exit
}
Write-host "Metadata URL with ID Obtained: "$metaurl1 -ForegroundColor Green


Write-host "Fetching the Final document URL for upload"
try {
    $metaurl2 = Invoke-RestMethod "$metaurl1" -Method get -Headers $gheaders -ResponseHeadersVariable response2 
}
catch {
    $_.Exception

}

$uploadURL = $metaurl2._links.content_rw
write-host "Metatdata Upload URL with Token: "$uploadurl -ForegroundColor Magenta

$form = @{
    upload_content = Get-Item -Path $file
}

write-host "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-##-#-#-#" -ForegroundColor DarkMagenta
write-host $form -ForegroundColor yellow
try {
   
    write-host "Uploading File.." -ForegroundColor Yellow
    Invoke-RestMethod "$uploadurl" -Method POST -Headers $pheaders -form $form -ResponseHeadersVariable scv #-ContentType 'multipart/form-data'
    write-host $file.name.ToUpper() -ForegroundColor Yellow -NoNewline
    write-host " uploaded to " -ForegroundColor Green -NoNewline
    write-host $companysn.ToUpper()-ForegroundColor Yellow -NoNewline
    write-host  " for EE: " -ForegroundColor Green -NoNewline
    write-host $choiceuname.toupper() -ForegroundColor Yellow -NoNewline
    write-host  " successfully!" -ForegroundColor Green
    write-host "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-##-#-#-#" -ForegroundColor DarkMagenta
}
catch {
    $_.Exception

    
}

    
    

}

}    