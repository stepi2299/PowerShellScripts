$path_to_scripts = "C:\Users\stepi2299\Desktop\studia\sem7\systemy_operacyjne\Proj4\"
$bash_file_name = "bash_file.sh"
$powershell_file_name = "from_bash_to_ps"

# hashtablica z odpowiednikami wyrażeń używanych w bashu i powershellu
$operators_translation = @{
    "==" = "-eq"
    "!=" = "-ne"
    ">" = "-gt"
    ">=" = "-ge"
    "<" = "-lt"
    "<=" = "-le"
    "&&" = "-and"
    "||" = "-or"
    "touch" = "New-Item"
    "True" = $true
    "False" = $false
    "then" = "{"
    "fi" = "}"
    "else" = "} else {"
    "done" = "}"
}
Function Checking-Extension
# funkcja do sprawdzenia czy podany plik bashowy jest w dobrym rozszerzeniu
{
    param(
        [string]$bash_name
    )
    $last = Split-Path $bash_name -Leaf
    $ext = $last.split('.')[1]
    if($ext -eq "sh")
    {
        return $true
    }
    else
    {
        return $ext
    }
}
Function Operators-Translate
# funkcja szukająca wszystkich wyrażen wystepujacych w hashtablicy i zamianiajace je na ich powershellowe odpowiedniki
{
    param(
        [string]$line
    )
    ForEach($key_word in $operators_translation.GetEnumerator())
    {
        $line = $line.replace($key_word.Name, $key_word.Value)
    }
    return $line
}
Function If_Translate
# funkcja dokonujaca koniecznych zmian w wyrazeniu if, aby dzialalo poprawnie w powershellu
{
    param(
        [string]$line
    )
    $line = $line.replace('[', '(')
    $line = $line.replace(']', ')')
    $line = $line.replace('elif', '} elseif')
    return $line
}
Function For_Translate
# funkcja dokonujaca koniecznych zmian w wyrazeniu for, aby dzialalo poprawnie w powershellu
{
    param(
        [string]$line
    )
    $do_in_for_line = $false
    $words = $line.split()
    foreach($word in $words)
    {
        $word = $word.trim()
        if($word -eq "do"){
            $do_in_for_line = $true
            break
        }
    }
    if($do_in_for_line -eq $true)
    {
        $line = $line.replace('do', ') {')
    }
    else
    {
        $line = $line + ")"
    }
    $line = $line.replace('for ', 'foreach($')
    return $line
}
Function Variables_Creation
# funkcja dodająca znak $ przed każdą nowo tworzona zmienną
{
    param(
        [string]$line
    )
    $line = $line.trim()
    if($line.Contains('=') -eq $true)
    {
        $words = $line.split('=')
        $first = $words[0].trim()
        if($first.Contains('$') -eq $false -and $first.Split().Length -eq 1)
        {
            $line = "$" + $line
        }
    }
    return $line
}
Function Craete_File
# funkcja do stworzenia (jesli nie ma juz na dysku) pliku o podanej nazwie i rozszerzeniu ps1 oraz wyczyszczenia go
{
    param(
        [string]$path_destination
    )
    $path_exist = Test-Path $path_destination
    if ($path_exist -eq $false)
    {
        New-Item -Path $path_destination -ItemType File
        Write "File have not existed earlier, created now"
    }
    Clear-Content -Path $path_destination 
}
$good_extension = Checking-Extension $bash_file_name
if($good_extension -ne $true)
{
    Write "Wrong extension of the bash file!!! It must be 'sh', actual: $good_extension"
    return
} 
$bash_file = $path_to_scripts + $bash_file_name
$ps_file = $path_to_scripts + $powershell_file_name + ".ps1"
# pobranie zawartości ze skryptu bashowskiego
$bash_file_content = Get-Content -Path $bash_file

$row = 0
Craete_File $ps_file

# główny pipeline przetwarzania
foreach($line in $bash_file_content)
{
    if($line.Contains("#!/bin/bash") -eq $true)
    {
        continue
    }
    $line = $line.trim()
    if ($line.StartsWith('for') -eq $true)
    {
        $line = For_Translate $line
    }
    $line = Operators-Translate $line
    $line = $line.replace('do', '{')
    $line = Variables_Creation $line
    if ($line.StartsWith('if') -eq $true -or $line.StartsWith('elif') -eq $true)
    {
        $line = If_Translate $line
    }
    $line >> $ps_file
    $row++
}