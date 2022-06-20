$search_directory = "C:/Users/stepi2299/Desktop"
$search_factor = "date"
$start_date = (get-date 2021-12-4)
$end_date = (get-date 2021-12-6)
$search_name = "config"
$min_size = 3MB
$max_size = 4MB
$parent_folder = Split-Path $search_directory -Leaf
Write "We search folder parent folder named: $parent_folder"
Function Get-FileWithDate($search_dir, $start, $end)
    {
        gci $search_dir -force -recurse -file | ? {($_.creationtime -lt $end) -and ($_.CreationTime -gt $start)}
    }
Function Get-FileWithName([string]$search_dir, [string]$name)
    {
        gci $search_dir -force -recurse -file -include *$name*
    }
Function Get-FileMinSize($search_dir, $min, $max)
    { 
        gci $search_dir -recurse -force -file | where {($_.Length -gt $min) -and ($_.Length -lt $max)}
    }
Function Get-Info($files)
    {
        $files | measure
    }
Function Get-Sizeautomatically($file_size)
    {
        if($file_size -lt 1024)
        {
           $file_size = "{0:N2}" -f $file_size
           $size_row = " B"
        }
        elseif(($file_size / 1kb) -lt 1024)
        {
           $file_size = "{0:N2}" -f ($file_size/1kb)
           $size_row = " KB"
        }
        elseif(($folder_sum / 1Mb) -lt 1024)
        {
           $file_size = "{0:N2}" -f ($file_size/1Mb)
           $size_row = " MB"
        }
        elseif(($file_size / 1Gb) -lt 1024)
        {
           $file_size = "{0:N2}" -f ($file_size/1Gb)
           $size_row = " GB"
        }
        else
        {
           $file_size = "NONE"
           $size_row = "###"
        }
        $file_size, $size_row
    }
Function Display-FilesInCorrectWay($files)
    {
    Write "--- File Name --- Containing Folder --- File Size --- File Creation Time"
        foreach($i in $files)
          {
              $file_size = $i.Length
              try
              {
                 $file_dir = Split-Path -Path $i
                 $containing_folder = Split-Path $file_dir -Leaf
              }
              catch 
              {
                 $containing_folder = $parent_folder
              }
              $file_name = $i.name
              $file_size, $file_row = Get-Sizeautomatically($file_size)
              $creation_time = $i.creationtime
              Write "--- $file_name --- $containing_folder --- $file_size $file_row --- $creation_time"
          }
    }
try
{
Write "We choose factor $search_factor from 'name', 'date', 'size'"
if($search_factor -eq "name")
{
  Write "searched name is '$search_name'"
  $files = Get-FileWithName $search_directory $search_name
}
elseif($search_factor -eq "size")
{
   Write "limits are: min size: $min_size, max size: $max_size"
   $files = Get-FileMinSize $search_directory $min_size $max_size
}
elseif($search_factor -eq "date")
{
   Write "limits are: min creation date: $start_date, max creation date: $end_date"
   $files = FileWithDate $search_directory $start_date $end_date
}
else
{
Write "You didn't give valid search factor (name, size or date)"
return
}
$files_info = Get-Info $files
$files_count = $files_info.count
Write "Found $files_count which fulfilled search condition, factor: $search_factor"
Display-FilesInCorrectWay($files)
}
catch
{
Write "some error has occurred"
}
finally
{
Write "All operations were done"
}