$username = "stepi299"
$password = "19"
$ftp = "192.168.0.183"
$subfolder = "/"
$resource_path = "C:\Users\stepi2299\Desktop"
$file_name = "upload_file.txt"
$file_content = "I am new text file"
Function Upload-File
# Funkcja odpowiedzialna za uploadowanie pliku na FTP serwer
{
    param
    (
        [string]$username,
        [string]$password,
        [string]$file_path,
        [string]$file_name,
        [string]$ftp
    )
    $file = $file_path + "/" + $file_name
    $ftp_file = $ftp + "/" + $file_name
    $ftpuri = "ftp://" + $username + ":" + $password + "@" + $ftp_file
    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri($ftpuri)
    $webclient.UploadFile($uri, $file)
}
Function Get-ListFilesInFTPFolder
# Funkcja zwracająca listę plikow znajdujacych sie na serwerze FTP
{
    param
    (
       [string]$ftp,
       [string]$subfolder,
       [string]$username,
       [string]$password
   ) 
    $ftpuri = "ftp://" + $ftp + $subfolder
    $uri=[system.URI] $ftpuri
    $ftprequest=[system.net.ftpwebrequest]::Create($uri)
    $ftprequest.Credentials=New-Object System.Net.NetworkCredential($username,$password)
    $ftprequest.Method=[system.net.WebRequestMethods+ftp]::ListDirectory
    $response=$ftprequest.GetResponse()
    $strm=$response.GetResponseStream()
    $reader=New-Object System.IO.StreamReader($strm,'UTF-8')
    $list=$reader.ReadToEnd()
    $lines=$list.Split("`n")
    return $lines
}
Function Delete-File
# Funkcja odpowiedzialna za usuniecie pliku z serwera FTP
{  
    param
    (
        [string]$Source,
        [string]$UserName,
        [string]$Password
    ) 
    $ftprequest = [System.Net.FtpWebRequest]::create($Source)
    $ftprequest.Credentials =  New-Object System.Net.NetworkCredential($UserName,$Password)
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $ftprequest.GetResponse()
    "File deleted."
}
Function Download-File
# Funkcja odpowiedzialna za ściągnięcie z serwera pliku o podanej nazwie i zapisanie go na komputerze
{
    param
    (
        [string]$username,
        [string]$password,
        [string]$file_path,
        [string]$file_name,
        [string]$ftp
    )
    $dest_file = $file_path + "/" + "2" + $file_name
    $ftp_file = $ftp + "/" + $file_name
    $ftpuri = "ftp://" + $username+ ":" + $password + "@" + $ftp_file
    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri($ftpuri)
    $webclient.DownloadFile($uri, $dest_file)
}
$lines = Get-ListFilesInFTPFolder $ftp $subfolder $username $password
"All files in FTP server"
$lines
$lines_count = $lines.count - 1
if($lines_count -gt 0)
# sprawdzenie ile aktualnie znajduje sie plikow na  serwerze
# w przypadku znalezienia jakis plikow zostana one usuniete
{
    "There already are $lines_count files on the FTP Server, they must be deleted"
    foreach($file in $lines)
    {
        if($file.Length -gt 0)
        {
            $file_to_delete_path = "ftp://" + $ftp + "/" + $file
            Delete-File $file_to_delete_path $username $password
        }
    }
    "Succesfully deleted $lines_count files"
}
$lines = Get-ListFilesInFTPFolder $ftp $subfolder $username $password
$lines_count = $lines.count - 1
if ($lines_count -eq 0)
# sprawdzenie czy po usunieciu plikow serwer jest pusty
{
    $full_file_path = $resource_path + "/" + $file_name
    if(!(Test-Path $full_file_path))
    {
        # jesli nie istnieje podana sciezka tworzymy plik i wypelniamy go napisem
        New-Item -Path $full_file_path -ItemType File
    }
    $file_content > $full_file_path
    Upload-File $username $password $resource_path $file_name $ftp
    $lines = Get-ListFilesInFTPFolder $ftp $subfolder $username $password
    $lines_count = $lines.count - 1
    if($lines_count -eq 1)
    {
        Download-File $username $password $resource_path $file_name $ftp
        $full_file_path = $resource_path + "/" + "2" + $file_name
        $read_content = Get-Content -Path $full_file_path
        if ($read_content -eq $file_content)
        {
            "Everything went fine, contents of created file and downloaded file are the same"
            return
        }
        else
        {
            "Something went wrong, downloaded file has diffenent content from created"
            return
        }
    }
    else
    {
        "Invalid file uploading"
        return
    }
}
else
{
    "There is problem with deleting files, still $lines_count files in ftp server"
    return
}