$root_folder = "C:\Users\stepi2299\SPENG"  # path to the desire location
function not-exist 
    {
        -not(Test-Path $args)
    }
# aliases created to cmdlets which checking if path exists
Set-Alias !exist not-exist -Option "Constant, AllScope"
Set-Alias exist Test-Path -Option "Constant, AllScope"
Function Get-EmptyDirectories($base_dir)
# function which return all empty Diectories (without any file) 
    { 
        Get-ChildItem -Directory -Recurse $base_dir | Where-Object { $_.GetFileSystemInfos().Count -eq 0 }
    }
Function Get-SizeOfDirectory($base_dir)
# function which return formetted messeage with size of directory
    {
        $tmp = Get-ChildItem $base_dir -force -Recurse | Measure-Object -property length -sum
	    "{0:N2}" -f ($tmp.sum / 1MB) + " MB"
    }
Function Get-AllFoldersFromDirectory($base_dir)
# function which return all folders (not files) from indicated path
    {
	    Get-ChildItem $base_dir -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object fullname
    }
Function Get-FilesWithSpecificExtension($base_dir)
# function which return all files with sopecific extension 
    {
        gci $base_dir -Recurse -Force -Include "*.cfg" |Sort Length
    }
if(exist $root_folder)
    {
Write "$root_folder is valid path"
$main_folder_name = Split-Path $root_folder -Leaf  # extracting name of lat folder in path
$Size = Get-SizeOfDirectory($root_folder)
"All files from $root_folder weight-- " + $Size
$col_items = Get-AllFoldersFromDirectory($root_folder)
$empty_directories = Get-EmptyDirectories($root_folder)
$announcement_about_empty_dir = "Empty directories are: "
ForEach ($i in $empty_directories)
# loop which adds to announcement about empty folders empty folder's names
    {
	$announcement_about_empty_dir += $i.Fullname + ", "
    }
$announcement_about_empty_dir
$base_depth = $root_folder.Split('\').count  # counting number of folders in main path
Write $main_folder_name
foreach ($i in $col_items)
#  loop which create tree view from every folder/catalog with its size
    {
        $local_depth = $i.Fullname.split('\').Count  # counting number of folders in specificpath
        $actual_depth = $local_depth - $base_depth - 1  #  calculating place in tree view (lesser depth means that that is parent folder 
        $sub_folder_items = (Get-ChildItem $i.FullName -file | Measure-Object -property length -sum)  # getting object with size of all child files belonging to specific folder
        $folder_name = Split-Path $i -Leaf
        $folder_sum = $sub_folder_items.sum
        $size_row =""
          # automaticly setting size displaying
        if($folder_sum -lt 1024)
        {
           $folder_size = "{0:N2}" -f $folder_sum
           $size_row = " B"
        }
        elseif(($folder_sum / 1kb) -lt 1024)
        {
           $folder_size = "{0:N2}" -f ($folder_sum/1kb)
           $size_row = " KB"
        }
        elseif(($folder_sum / 1Mb) -lt 1024)
        {
           $folder_size = "{0:N2}" -f ($folder_sum/1Mb)
           $size_row = " MB"
        }
        elseif(($folder_sum / 1Gb) -lt 1024)
        {
           $folder_size = "{0:N2}" -f ($folder_sum/1Gb)
           $size_row = " GB"
        }
        else
        {
           $folder_size = "NONE"
           $size_row = "###"
        }
        "|" + "---" * $actual_depth + $folder_name + " -- " + $folder_size + $size_row
    }
$config_folder = "C:\Users\stepi2299\Desktop\configs"  # path which will have copied filed
$cfg_files = Get-FilesWithSpecificExtension($root_folder)
$cfg_count = $cfg_files.Count  # counting all files with specific extension
# switch which in case of different count number files with specific extension do different things
switch($cfg_count)
{
1 
{
Write "Only one config file, it will be deleted"
Remove-Item -Path $cfg_files  # removing this one file
}
6
{
# coping all 6 files to another folder
New-Item -Path $config_folder -ItemType Directory -Force
ForEach($i in $cfg_files)
{
$destination_file = $config_folder +"\" + $i.name
Copy-Item -Path $i -Destination $destination_file -force
}
"There are $cfg_count config files in $root_folder succesfully copied into $config_folder"
}
default
{
Write "Something went wrong, do nothing"
}
}
}
elseif(!exist $root_folder)
{
Write "$root_folder does not exist"
}