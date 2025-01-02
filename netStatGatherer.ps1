$ProgressPreference = 'SilentlyContinue'

$domains = @("google.com", "jlstorage.jacksonlewis.net", "jacksonlewis.service-now.com", "workday.com", "outlook.office.com", "vault.netvoyage.com", "jlink.jacksonlewis.com/connect", "https://www.concursolutions.com/?entity=p00680eaeu")
$results = @()

# Get active network interface
try {
    $activeInterface = Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Sort-Object RouteMetric | Select-Object -First 1
    $interfaceDetail = Get-NetAdapter | Where-Object { $_.ifIndex -eq $activeInterface.ifIndex } | Select-Object -First 1
    $networkInterface = $interfaceDetail.Name
} catch {
    $networkInterface = "Unknown"
}

foreach ($domain in $domains) {
    # DNS resolution time
    $dnsStart = Get-Date
    try {
        Resolve-DnsName -Name $domain -ErrorAction Stop
        $dnsEnd = Get-Date
        $dnsTime = ($dnsEnd - $dnsStart).TotalMilliseconds
    } catch {
        $dnsTime = $null
    }

    # Ping the domain
    try {
        $pingResult = Test-Connection -ComputerName $domain -Count 100 -ErrorAction Stop

        $avgPing = ($pingResult.ResponseTime | Measure-Object -Average).Average
        $packetLoss = 100 - (($pingResult.Count / 100) * 100)
    } catch {
        $avgPing = $null
        $packetLoss = 100
    }

    # Measure web request response time (total time and TTFB)
    try {
        $requestStart = Get-Date
        $webRequest = Invoke-WebRequest -Uri "http://$domain" -TimeoutSec 10 -ErrorAction Stop
        $requestEnd = Get-Date

        $requestTime = ($requestEnd - $requestStart).TotalMilliseconds
        $ttfb = $webRequest.Headers["X-Request-Time"]
    } catch {
        $requestTime = $null
        $ttfb = $null
    }

    # Get traceroute hop count
    try {
        $traceResult = Test-NetConnection -ComputerName $domain -TraceRoute -ErrorAction Stop
        $hopCount = $traceResult.TraceRoute.Count
    } catch {
        $hopCount = $null
    }

    $results += [PSCustomObject]@{
        "Hostname"            = $env:COMPUTERNAME
        "NetworkInterface"    = $networkInterface
        "Domain"              = $domain
        "AveragePing_ms"      = $avgPing
        "PacketLoss_Percent"  = $packetLoss
        "WebRequest_ms"       = $requestTime
        "ServerResponseTime_ms" = $ttfb
        "DNSResolutionTime_ms"  = $dnsTime
        "HopCount"            = $hopCount
    }
}

# Ensure the directory exists
if (-not (Test-Path -Path "C:\jltools")) {
    New-Item -Path "C:\jltools" -ItemType Directory
}

# Save results to CSV with the computer's name included in the filename
$csvPath = "C:\jltools\NetworkData_$env:COMPUTERNAME.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Data saved to $csvPath"
