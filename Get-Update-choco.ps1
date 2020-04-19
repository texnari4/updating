Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
choco update -y firefox
$OS = Get-CimInstance -Class Win32_OperatingSystem