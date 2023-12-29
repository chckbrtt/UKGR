# UKG Ready Employee Document Upload Using a PowerShell module
## My Information:  Chuck Britt
##                  Mosaic HCM https://www.mosaichcm.com
##                  Title: IT Director
##                  UKG Community ID: chuck.britt26640
## Step 1)
### In Ready create a custom document type
  ![image](https://github.com/chckbrtt/UKGR/assets/117453000/56a10824-b9ab-45fb-8a1d-dd09b2a87d25)
* Take Note of the document type id in the URL. You will need this later
  ![image](https://github.com/chckbrtt/UKGR/assets/117453000/de05d5f9-dab3-4f97-846b-cec78c08729c)

## Step 2)
### Create a security group with document management permissions (Full Access Works Too)
![image](https://github.com/chckbrtt/UKGR/assets/117453000/43dbda6e-a7f1-42d5-9a2b-89ebc690a3fb)
![image](https://github.com/chckbrtt/UKGR/assets/117453000/a574aa72-6a5f-4a86-89a3-1551f7db32e1)

## Step 3)
### Get or Generate an API Key
![image](https://github.com/chckbrtt/UKGR/assets/117453000/907db871-ea94-4daf-9c42-c62e4f84057d)

## Step 4)
### Create or Use an existing service account. Place it in the new security group.
![image](https://github.com/chckbrtt/UKGR/assets/117453000/bc991f0b-cc94-444d-b086-11f9b59dc5a6)
## Step 5)
### Grant access the Employee Objects in Groups. *This step may be optional but I tend to allway implement this step.*
![image](https://github.com/chckbrtt/UKGR/assets/117453000/828b8df2-8a8c-4356-a02c-a07e4213c803)

## Step 6)
### Install PowerShell and set the execution policy. DO NOT INSTALL ANYTHING GREATER THAN 7.3.10
https://github.com/PowerShell/PowerShell/releases  

Windows 10\11 best release = https://github.com/PowerShell/PowerShell/releases/download/v7.3.10/PowerShell-7.3.10-win-x64.msi  

Once installed run this from the prompt: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`  
Just to be certain you are using the correct PowerShell Version, Run:`$psVersionTable`  

The result should look like:  
![Screenshot 2023-12-28 193606](https://github.com/chckbrtt/UKGR/assets/117453000/0d8aa0d1-f6c1-490f-9665-968b111c3237)  

## Step 7)
### Download and Install the module sourced from this Github Site
Download the 2 Files in the docupper folder
Place both files in the same folder (Very Important!)  
In PowerShell run: `import-module c:\path2\docupper.psd1`   
Validate that the module loaded properly by running: `get-module docupper`  
![image](https://github.com/chckbrtt/UKGR/assets/117453000/28513a7b-939d-4ff1-945c-712d0b8bfee1)


## Step 8)
### Collect these needed values

1. APIKey - Outlined in Step 3. The APIKey is used to Obtain your Bearer Auth Token
3. Company Shortname - Found in your tenant URL: https://secure2.saashr.com/ta/docdemo.home in this example the short name is docdemo. Also used to obtain your Auth Token.
4. Service Account username - Also used to obtain your Auth Token.
5. Service Account password - Also used to obtain your Auth Token.
6. POD Number - The number after secure in the url: https://secure?.saashr.com/ta/docdemo.home?
7. Document Type Display Name - Outlined in Step 1
8. Document Type ID - Outlined in Step 1

## Step 9)
### Run the Command from Powershell

`docupper -apikey '9ricn9ru6lpreo0rn0rk82brct8cr6yl' -companySN 'docdemo' -password 'somepassword' -username 'apiuser' -pod 2 -cid 33231772 -doctypeid 369275328 -doctypedisp EE`

> [!TIP]
> docupper: The term 'docupper' is not recognized as a name of a cmdlet, function, script file, or executable program.
> Check the spelling of the name, or if a path was included, verify that the path is correct and try again.  
  
If you receive this error Step 7 needs to be revisited
## Step 10)
### Using the Script
If all the parameters are accurate and all the permissions set are valid the script will return a list of your users:  
![Screenshot 2023-12-28 200638](https://github.com/chckbrtt/UKGR/assets/117453000/29dc387f-57a4-4a89-a83d-f3a66a778ec7)  
Once the Dynamic list if populated select a user by number. A File explorer window will appear asking you to select the folder containing the users documents.  
> [!TIP]  
> The File Explorer window will not show any files. It will only show folders. It will also have a message to select the folder for EE you picked from the list.    
> The screen will show a summary of the folder and other parameters you provided. The JSON metadata preview will also be shown.  
   
![Screenshot 2023-12-28 200919](https://github.com/chckbrtt/UKGR/assets/117453000/8e81c737-239b-40c9-a0a7-878edded59a5)  

## Step 11)
### The Process Explained

+ API Call -> Method = Post -> Headers = APIKEY -> Body = JSON 
```
{
  "credentials": {
    "username": "",
    "password": "",
    "company": ""
  }
}
```
+ API Response -> Token  
+ API Call -> Method = Get -> Employee Endpoint  
+ API Response -> Employee Roaster  
+ Script -> Build Dynamic Menu from EE Roster  
+ The Chosen user Account ID is stored and becomes the linked_id  
+ The Folder Selection creates a variable for path  
+ Script Loops throught the list of files and creates a JSON metadata form for each  
```
{
  "document_type": {
    "id": 369275328,
    "display_name": "EE"
  },
  "linked_id": 8625962290,
  "type": "HR_EMPLOYEE_DOCUMENT",
  "description": "Uploaded Automatically",
  "attributes": {
    "category": "EE files",
    "ex_info_3": "",
    "ex_info_1": "",
    "ex_info_2": "",
    "directory": "/"
  },
  "file_name": "testfile122723.docx"
}
```
+ API Call -> Method = Post -> URL = Metadata URL (../companies/{{cid}}/ids)  
+ API Call -> Method = Get -> URL = Previous Calls Repsone.Location (../companies/{{cid}}/ids/12345678)  
+ API Call -> Method = Post -> URL = Previous Calls Response._links.content_rw (../ta/fs?ticket=eyJhbGciOiJIUzUx..)  

# In Summary  
Feed the script API creds, get auth token  
Use the token to get a roster  
Select user and user folder containing documents to upload  
Each file is created in the system as an empty file (metadata only)  
The metadata creation builds unique file ids and unique access url for R RW   
Retrieve the RW url from the newly created metadata and API upload the file matching its already created metadata  
  
    
![image](https://github.com/chckbrtt/UKGR/assets/117453000/80987b62-7721-4f6d-9184-e94b9c037d62)
