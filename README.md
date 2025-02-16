# Unsigned Exe Checker
This powershell script checks a drive for unisgned exe files. Open PowerShell as Administrator and paste the code at the bottom.

### Useful program when using the script:
- [Timeline Explorer](https://download.mikestammer.com/net6/TimelineExplorer.zip)

### How to use script
To use the script copy following command in to powershell:

```powershell
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null 
Set-Location "C:\temp"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NoahGrandT/Unsigned-Exe-Check23123/refs/heads/main/Unisgned_exe_check.ps1" -OutFile "Unsigned_exe_check.ps1"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
Add-MpPreference -ExclusionPath 'C:\Temp' | Out-Null; .\Unsigned_exe_check.ps1
```
