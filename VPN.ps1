Function GeoLocate
{
Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         $IP,
         [Parameter(Mandatory=$true, Position=1)]
         $CPCountry
    )
Start-Sleep -s 2 # Do not go lower or you get rate limited.
$request = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP" # Send Geolocate request
$IPCountry = $request.Country
Write-Host "$IP geolocated to $IPCountry." -ForegroundColor Cyan
if ($IPCountry -ne "United Kingdom" -and $IPCountry.length -gt 1) # Logic checking.
{
Write-Host "$IP has geolocated to outside of the UK, logging into CSV report."-ForegroundColor Red
$date = Get-Date
Add-Content $savepath "$date - $IP logged in to $JustUser and geolocated to $IPCountry - CheckPoint reported this as $CPCountry." # Save to log file.
}
}

$path = 'C:\sho\VPNAuthLog.csv' # Run the "VPN Access" report in CP SmartConsole and then go to Archive and download the Excel file. Then open and save as CSV. Change this path.
$savepath = 'C:\sho\IPOutsideUK.txt' # Path that final report is saved to.
$csv = Import-Csv $path| select Action,'Source','Source Country','User' |where {$_.Action -eq "Log in"} # Import CSV, it ignores the date in the CSV. Only imports lines marked as Log In.
    foreach ($line in $csv)
    {
         $line.ToString()
         $linecopy = $line
         $linecopycountry = $line
         $Country = $line -replace ".*try="
         $JustCountry = $Country -replace "}" # Grab Country from logs.
         $NewString = $linecopy -replace ".*IP=" # Formatting & extracting IP addresses from logs.
         $NewIPString = $NewString -replace "; Source Cou.+"
         $JustIPAddress = $NewIPString -replace ".*Source="
         $JustUser = $linecopycountry -replace ".*; User=+"

 <# If you're reading this, I'm so sorry for this if statement. #> 
 if ($JustIPAddress.StartsWith("10.") -or $JustIPAddress.StartsWith("172.16.") -or $JustIPAddress.StartsWith("172.17.") -or $JustIPAddress.StartsWith("172.18.") -or $JustIPAddress.StartsWith("172.19.") -or $JustIPAddress.StartsWith("172.20.") -or $JustIPAddress.StartsWith("172.21.") -or $JustIPAddress.StartsWith("172.22.") -or $JustIPAddress.StartsWith("172.23.") -or $JustIPAddress.StartsWith("172.24.") -or $JustIPAddress.StartsWith("172.25.") -or $JustIPAddress.StartsWith("172.26.") -or $JustIPAddress.StartsWith("172.27.") -or $JustIPAddress.StartsWith("172.28.") -or $JustIPAddress.StartsWith("172.29.") -or $JustIPAddress.StartsWith("172.30.") -or $JustIPAddress.StartsWith("172.31.") -or $JustIPAddress.StartsWith("172.32.") -or $JustIPAddress.StartsWith("192.168."))
                {
                Write-Host "$JustIPAddress is private or invalid and as such is not being checked." -ForegroundColor Red
                }
                    elseif ($JustIPAddress[0] -match "[a-z,A-Z]" -or $JustIPAddress[0] -match "0" -or $JustIPAddress.Length -gt 20)
                    {
                    Write-Host "$JustIPAddress is a hostname, extracting to IP." -ForegroundColor Yellow
                    $HostNameExtract = $JustIPAddress -replace ".* \(" -replace "\)"
                    Write-Host "$HostNameExtract extracted from $JustIPAddress, sending for GeoLocation." -ForegroundColor Green
                    GeoLocate $HostNameExtract $JustCountry # Geolocate.
                    }

                  
                     else
                    {
                    write-host "$JustIPAddress is public, sending for Geolocation." -ForegroundColor Green
                    GeoLocate $JustIPAddress $JustCountry # Geolocate.
                    }
                  }    
                  Write-Host "All IP's checked. Report is stored at $savepath"

