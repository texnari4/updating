function Get-Firefox-Update {
    

    # Establish the common parameters
    $path = $env:temp
    $OS = Get-WmiObject -Class Win32_OperatingSystem
    $OS.Caption 
    $OS.OSArchitecture
    $language = Get-WinSystemLocale 
    Write-Host -ForegroundColor Blue Current system is $OS.Caption $OS.OSArchitecture $language
    
    # Check architecture
    If ([IntPtr]::Size -eq 8) {
        $empty_line | Out-String
        "Running in a 64-bit subsystem" | Out-String
        $64 = $true
        $bit_number = "64"
        $registry_paths = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
        $empty_line | Out-String
    }
    Else {
        $empty_line | Out-String
        "Running in a 32-bit subsystem" | Out-String
        $64 = $false
        $bit_number = "32"
        $registry_paths = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
        $empty_line | Out-String
    } # Else

    ## Get installed version
    $registry_paths_selection = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Firefox*" ) -and ($_.Publisher -like "Mozilla*" ) }
    if ($registry_paths_selection -ne $null) {
        Write-Host -ForegroundColor Green $registry_paths_selection.DisplayName installed make some process for Update

        # Set language packet
        if ($language.Name -contains 'ru') {
            Write-Host System language is russian
            $locale = 'ru'
        
        }
        else {
            Write-Host System language is english
            $locale = 'en-GB'
        }

        ## Download versions table
        $baseline_url = "https://product-details.mozilla.org/1.0/firefox_versions.json"
        $baseline_file = "$path\firefox_current_versions.json"
        try {
            $download_baseline = New-Object System.Net.WebClient
            $download_baseline.DownloadFile($baseline_url, $baseline_file) 
            Write-Host  -ForegroundColor Green  $baseline_file was downloaded
        }
        catch [System.Net.WebException] {
            Write-Warning "Failed to access $baseline_url"
        }

        ## Verify version with latest version
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $latest = $serializer.DeserializeObject((Get-Content -Path $baseline_file) -join "`n")
        $latest.LATEST_FIREFOX_VERSION

        ## Installation
        if ($latest.LATEST_FIREFOX_VERSION -gt $registry_paths_selection.DisplayVersion) {


            ## Genegate download link
            $os = '&os=win' + $bit_number
            $lang = '&lang=' + $locale
            $download_url = [string]'https://download.mozilla.org/?product=firefox-latest' + $os + $lang
            Write-Host -ForegroundColor Blue Download link prepared  $download_url

            ## Start Downloading
            Write-Host  -ForegroundColor Green Start downloading Firefox $latest.LATEST_FIREFOX_VERSION
            $download_file = "Firefox_Setup.exe"
            $firefox_save_location = "$path\$download_file"
            $download_firefox = New-Object System.Net.WebClient
            $download_firefox.DownloadFile($download_url, $firefox_save_location)
            Write-Host -ForegroundColor Yellow "File downloaded to $firefox_save_location"


            ## Check firefox is downloaded?
            If ((Test-Path $firefox_save_location) -eq $true) {
                $firefox_is_downloaded = $true
            }
            Else {
                $firefox_is_downloaded = $false
            }

            ## install firefox
            Write-Host  -ForegroundColor Green Start installing Firefox $latest.LATEST_FIREFOX_VERSION
            If ($firefox_is_downloaded -eq $true) {
                Write-Verbose "Make install Firefox"
                Start-Process -FilePath $firefox_save_location -Verb runAs -ArgumentList '/s', '/v"/qn"' -Verbose
                Start-Sleep -s 5
            }
            Else {
                Write-Warning Firefox is not installed, something went wrong
            } # Else

        }
        else {
            Write-Warning Firefox is latest version nothing to do
        }
    }
    else {
        Write-Warning Nothing to do - Firerfox is not installed
    }

    Write-Host -ForegroundColor Green Firefox version $latest.LATEST_FIREFOX_VERSION installed    
    Write-Host "Done"
}

Get-Firefox-Update -Verbose