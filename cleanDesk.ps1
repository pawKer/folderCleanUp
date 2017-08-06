cls
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

#Hardcoded file types categories
#First element represents the name of the folder they will be moved to
$imgFileTypes = "Images", ".png", ".jpg", ".jpeg", ".gif", ".ico"
$pdfFileTypes = "Pdfs", ".pdf"
$musicFileTypes = "Music", ".mp3", ".wav"
$torrentFileTypes = "Torrents", ".torrent"
$setupFileTypes = "Executables", ".exe", ".msi"
$archiveFileTypes = "Archives", ".zip", ".rar", ".gzip", ".iso"
$documentsFileTypes = "Documents", ".doc", ".docx", ".ppt", ".pptx", ".txt"

#Create object for pop-ups
$wshell = New-Object -ComObject Wscript.shell

#Get path to be cleaned from user input in an VisualBasic InputBox
#The input 'cur' cleans the current folder
#Invalid input paths will exit
$inputPath = [Microsoft.VisualBasic.Interaction]::InputBox("What path do you want to clean? Type 'cur' for current directory ", "Cleanify")

#If no path inputed, exit
if($inputPath -eq "")
{
  Exit
}
#If input is cur, reset inputPath to empty string and continue
elseif($inputPath -eq "cur")
{
  
  $curDir = pwd
  
  echo "Cleaning current directory..."
  
  $wshell.Popup("You are about to clean $curDir", 0, "Cleanify", 0x1)
  
  $inputPath = ""
}
else
{
  #For something else, we check that it is a valid path first
  #If it is, we go on we de clean, else we exit
  if(Test-Path $inputPath)
  {
    echo "Cleaning $inputPath ..."
    $wshell.Popup("You are about to clean $inputPath", 0, "Cleanify", 0x1)
  }
  else
  {
    $wshell.Popup("Not a valid path. Try again !", 0, "Cleanify", 0x1)
    Exit
  }
}

#Change to the directory to be cleaned, will be the same directory if 'cur' is inputed
cd $inputPath

#Function that copies all the files that have extensions that match the given types 
#then removes from the original folder(if copied succesfuly) 
#Takes as argument an array of file types - first element must be 
#the name of the folder to be created
function CleanByFileTypes($fileTypes)
{
  echo "Cleaning $($fileTypes[0])..."
  

  #Testing whether there are any files that match the category first
  #so we don't create folders if there are no files of that type
  $noFiles = 0

  #This iterates through all the files in the current folder
  ls |
  ForEach-Object{
    $extension = $_.Extension

    if($fileTypes.Contains($extension.ToLower()))
    {
      $noFiles = 1
    }
  }

  #If there are files that match the category, and folder not already created
  #we make a new one
  if(-Not (Test-Path $fileTypes[0]) -and $noFiles)
  {
    echo "Folder does not exist yet"
    echo "Making new folder..."
    mkdir $fileTypes[0]
  }
  if(-Not $noFiles)
  {
    echo "No files match the provided file types"
    return
  }

  ls |
  ForEach-Object{

    #Get the extension of the current file
    $extension = $_.Extension


    if($fileTypes.Contains($extension.ToLower()))
    {
      echo "Moving file " $_.FullName
      
      #Copy the file to the appropriate folder(first element of the array 
      #given as argument)
      cp -v $_.FullName $fileTypes[0]
      
      #If the file is copied in the new folder, then it is safe to
      #remove it from its original location
      if(Test-Path ".\$($fileTypes[0])\$_")
      {
        #Removes the current file
        rm -v $_
      }
      else
      {
        echo "File not copied properly, try again !"
      }

      
    }#if


  }#For-Each

  echo "Succesfuly cleaned $($fileTypes[0]) !"

}#function CleanByFileTypes

#Call the function for the different file categories
CleanByFileTypes $imgFileTypes
CleanByFileTypes $pdfFileTypes
CleanByFileTypes $musicFileTypes
CleanByFileTypes $torrentFileTypes
CleanByFileTypes $setupFileTypes
CleanByFileTypes $archiveFileTypes
CleanByFileTypes $documentsFileTypes

$wshell.Popup("Clean completed", 0, "Done", 0x1)

pause
