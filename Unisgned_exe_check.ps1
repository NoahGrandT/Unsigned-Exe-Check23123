# Unsigned Exe Check by Noah
# Version: v1.2
# Last Updated: 2025-02-16

function Unzip {
    param(
        [string]$zipFilePath,
        [string]$destinationPath
    )
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $destinationPath)
}

New-Item -Path "C:\Temp\" -ItemType Directory -Force | Out-Null 
Clear
$drives = Get-Volume | Where-Object { $_.DriveLetter -match "^[A-Z]$" } | Select-Object DriveLetter, FileSystemLabel, @{Name="Size (GB)";Expression={"{0:N2}" -f ($_.Size / 1GB)}}

Write-Host "Available Drives:`n"
$drives | ForEach-Object { Write-Host "`t$($_.DriveLetter):\  -  $($_.FileSystemLabel) ($($_."Size (GB)") GB)" }
Write-Host "`texit -  Exit the Script`n"

$selectedDrive = Read-Host "Enter the drive letter you want to scan (e.g., C, D, E)"

if ($selectedDrive -match "^[A-Z]$" -and ($drives.DriveLetter -contains $selectedDrive)) {
    $scanPath = "$selectedDrive`:\"
} elseif ($selectedDrive -eq "exit" -or $selectedDrive -eq "Exit" -or $selectedDrive -eq "EXIT") {
	Write-Host "`n`n`tUser chose to exit." -ForegroundColor red
	Write-Host "`n`n`tClosing Script in " -NoNewline 
	Write-Host "2 " -NoNewLine -ForegroundColor Magenta
	Write-Host "Seconds`n`n`n" -NoNewline
	Start-Sleep 2
	Clear
	exit
} else {
	Write-Host "`n`n`tUser didn't pick a correct answer." -ForegroundColor red
	Write-Host "`n`n`tRestarting Script in " -NoNewline 
	Write-Host "2 " -NoNewLine -ForegroundColor Magenta
	Write-Host "Seconds`n`n`n" -NoNewline
	Start-Sleep 2
	Clear-Host
	& "C:\Temp\Unsigned_exe_check.ps1"
}

# Liste initialisieren
$unsignedFiles = @()


Get-ChildItem -Path $scanPath -Filter *.exe -Recurse -Force -ErrorAction SilentlyContinue |  
    ForEach-Object { 
        try {
            if ($sig.Status -ne 'Valid') {
                $fileSizeMB = [math]::round($_.Length / 1MB, 2)
                $unsignedFiles += [PSCustomObject]@{
                    "File Path" = $_.DirectoryName
                    "Name of the suspicious File" = $_.Name
                    "Last Write Time" = $_.LastWriteTime
                }
            }
        } 
        catch {
            Write-Host "Error processing file: $($_.Name)"
        }
    }


$groupedFiles = $unsignedFiles | Group-Object -Property "File Path"


if ($groupedFiles.Count -gt 0) {
    $groupedFiles | ForEach-Object {
        $folder = $_.Name
        $fileCount = $_.Count
        Write-Host "`n`nFound $fileCount unsigned files in '$folder'." -ForegroundColor red
		
		$_.Group | Format-Table -AutoSize
	$openFolderques = Read-Host "Do you want to open any folder? (Y/N)"
 	if ($openFolderques -eq "Y" -or $openFolderques -eq "y") {
        if ($fileCount -gt 2) {
            $openFolder = Read-Host "Do you want to open the folder '$folder' with $fileCount suspicious files? (Y/N)"
            if ($openFolder -eq 'Y' -or $openFolder -eq 'y') {
                Write-Host "User chose yes." -ForegroundColor green
				
				Write-Host "`n`n`tOpening folder and showing results in " -NoNewline 
				Write-Host "2 " -NoNewLine -ForegroundColor Magenta
				Write-Host "Seconds`n`n`n" -NoNewline
				Start-Sleep 2
				Start-Process explorer.exe $folder
            } elseif ($openFolder -eq 'N' -or $openFolder -eq 'n') {
				Write-Host "`n`n`tUser aborted and chose No. Restart Script if needed." -ForegroundColor red
    				Write-Host "`n`n`tContinueing script in " -NoNewline -ForegroundColor green
				Write-Host "2 " -NoNewLine -ForegroundColor Magenta
				Write-Host "Seconds`n`n`n" -NoNewline -ForegroundColor green
				Start-Sleep 2
			} else {
				Write-Host "`n`n`tUser didn't pick a correct answer." -ForegroundColor red
				Write-Host "`n`n`tRestarting Script in " -NoNewline 
				Write-Host "2 " -NoNewLine -ForegroundColor Magenta
				Write-Host "Seconds`n`n`n" -NoNewline
				Start-Sleep 2
				Clear-Host
				& "C:\Temp\Unsigned_exe_check.ps1"
			}
        }
	} elseif ($openFolderques -eq "N" -or $openFolderques -eq "n") {
 		Write-Host "`n`n`tUser chose No." -ForegroundColor red
   		Write-Host "`n`n`tContinueing Script in " -NoNewline 
		Write-Host "2 " -NoNewLine -ForegroundColor Magenta
		Write-Host "Seconds`n`n`n" -NoNewline
		Start-Sleep 2
   	} else {
		Write-Host "`n`n`tUser didn't pick a correct answer." -ForegroundColor red
		Write-Host "`n`n`tRestarting Script in " -NoNewline 
		Write-Host "2 " -NoNewLine -ForegroundColor Magenta
		Write-Host "Seconds`n`n`n" -NoNewline
		Start-Sleep 2
		Clear-Host
		& "C:\Temp\Unsigned_exe_check.ps1"
        }
    }
} else {
    Write-Host "No unsigned files found." -ForegroundColor green
	Write-Host "`n`n`tClosing Script in " -NoNewline 
	Write-Host "2 " -NoNewLine -ForegroundColor Magenta
	Write-Host "Seconds`n`n`n" -NoNewline
	Start-Sleep 2
	Clear
	exit
}


$csvScriptContent = @"



`$unsignedFiles = @()


Get-ChildItem -Path $scanPath -Filter *.exe -Recurse -Force -ErrorAction SilentlyContinue |  
    ForEach-Object { 
        try {
            if (`$sig.Status -ne 'Valid') {
                `$fileSizeMB = [math]::round(`$_.Length / 1MB, 2)
                `$unsignedFiles += [PSCustomObject]@{
                    "File Path (Ordner)" = `$_.DirectoryName
                    "Name" = `$_.Name
                    "File Size (MB)" = `$fileSizeMB
                    "Last Write Time" = `$_.LastWriteTime
                }
            }
        } 
        catch {
            Write-Host "Error processing file: `$(`$_.Name)"
        }
    }


if (`$unsignedFiles.Count -gt 0) {
    `$unsignedFiles | Export-Csv -Path "C:\Temp\UnsignedExecutables.csv" -Delimiter "," -Encoding UTF8 -NoTypeInformation
    Write-Host "CSV export successful. The file is located at C:\Temp\UnsignedExecutables.csv"

    `$downloadTE = Read-Host "Do you want to download the Timeline explorer? (Y/N)"
    if (`$downloadTE -eq "Y" -or `$downloadTE -eq "y") {
        Write-Host "`n`nDownloading Timeline Explorer..." -ForegroundColor green
        (New-Object System.Net.WebClient).DownloadFile("https://download.mikestammer.com/net6/TimelineExplorer.zip", "C:\temp\TimelineExplorer.zip")
        Unzip -zipFilePath "C:\temp\TimelineExplorer.zip" -destinationPath "C:\temp\TimelineExplorer"
        Write-Host "Timeline Explorer downloaded and extracted successfully." -ForegroundColor green
        Write-Host "Contoniueing in " -NoNewline
        Write-Host "5 " -NoNewline -ForegroundColor magenta
        Write-Host "Seconds." -NoNewline
        Start-Sleep 5
    } elseif (`$downloadTE -eq "N" -or `$downloadTE -eq "n") {
        Write-Host "`n`n`tContinueing Script in " -NoNewline
        Write-Host "2 " -NoNewline -ForegroundColor magenta
        Write-Host "Seconds." -NoNewline
        Start-Sleep 2
    } else {
        Write-Host "`n`n`tThis wasn't a correct answer. Restarting script in " -NoNewline
        Write-Host "2 " -NoNewline -ForegroundColor magenta
        Write-Host "Seconds" -NoNewline
    }

    Write-Host "`n`n`tClosing Script in " -NoNewline 
    Write-Host "2 " -NoNewLine -ForegroundColor Magenta
    Write-Host "Seconds`n`n`n" -NoNewline
    Start-Sleep 2
    Clear
    exit
} else {
    Write-Host "No unsigned files found."
    Write-Host "`n`n`tClosing Script in " -NoNewline 
    Write-Host "2 " -NoNewLine -ForegroundColor Magenta
    Write-Host "Seconds`n`n`n" -NoNewline
    Start-Sleep 2
    Clear
    exit
}
"@


$csvScriptPath = "C:\Temp\csv_export.ps1"
$csvScriptContent | Set-Content -Path $csvScriptPath
Write-Host "'csv_export.ps1' has been created at $csvScriptPath."


$executeScript = Read-Host "Do you want to extract the list as .csv? (Y/N)"
if ($executeScript -eq 'Y' -or $executeScript -eq 'y') {
    Clear-Host
    & $csvScriptPath
} elseif ($executeScript -eq 'N' -or $executeScript -eq 'n') {
    Write-Host "`n`n`tUser aborted and chose No. Restart script if needed." -ForegroundColor red
    Write-Host "`n`n`tClosing Script in " -NoNewline 
    Write-Host "2 " -NoNewLine -ForegroundColor Magenta
    Write-Host "Seconds`n`n`n" -NoNewline
    Start-Sleep 2
    Clear
    exit
} else {
	Write-Host "`n`n`tUser didn't pick a correct answer." -ForegroundColor red
	Write-Host "`n`n`tRestarting Script in " -NoNewline 
	Write-Host "2 " -NoNewLine -ForegroundColor Magenta
	Write-Host "Seconds`n`n`n" -NoNewline
	Start-Sleep 2
	Clear-Host
	& "C:\Temp\Unsigned_exe_check.ps1"
}
