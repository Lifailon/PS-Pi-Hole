Function Invoke-Pi-Hole {
<#
.SYNOPSIS
Module for interacting with pi-hole using the REST API
Get Token (ssh): sudo cat /etc/pihole/setupVars.conf | grep WEBPASSWORD
Server and Token can be set in module parameters (line 28 and 29)
.DESCRIPTION
Example:
Invoke-Pi-Hole -Server 192.168.1.253 -Token 5af9bd44aebce0af6206fc8ad4c3750b6bf2dd38fa59bba84ea9570e16a05d0f
Invoke-Pi-Hole -Enable  # Enable Blocking
Invoke-Pi-Hole -Disable # Disable Blocking
Invoke-Pi-Hole -Stats   # Blocking work status
Invoke-Pi-Hole -TopClient
Invoke-Pi-Hole -TopPermittedDomains
Invoke-Pi-Hole -TopPermittedDomains -Count 100
Invoke-Pi-Hole -LastBlockedDomain
Invoke-Pi-Hole -ForwardServer # Upstream servers
Invoke-Pi-Hole -QueryTypes
Invoke-Pi-Hole -QueryLog
Invoke-Pi-Hole -Data     # Number of requests for every 10 minutes during the last 24 hours
Invoke-Pi-Hole -Versions # Current and Latest versions
Invoke-Pi-Hole -Releases # Current (last) version and date from the GitHub repository
Invoke-Pi-Hole -AdList   # Status Hosts List (StevenBlack)
.LINK
https://github.com/Lifailon/Invoke-Pi-Hole
#>
param(
    $Server = "192.168.11.253",
    $Token = "5af9bd44aebce0af6206fc8ad4c3750b6bf2dd38fa59bba84ea9570e16a05d0f",
    [switch]$Status,
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Stats,
    [switch]$TopClient,
    [switch]$TopPermittedDomains,
    $Count = 20,
    [switch]$LastBlockedDomain,
    [switch]$ForwardServer,
    [switch]$QueryTypes,
    [switch]$QueryLog,
    [switch]$Data,
    [switch]$Versions,
    [switch]$Releases,
    [switch]$AdList
)

if ($Status) {
    irm "http://$Server/admin/api.php?status&auth=$Token"
}

if ($Enable) {
    irm "http://$Server/admin/api.php?enable&auth=$Token"
}

if ($Disable) {
    irm "http://$Server/admin/api.php?disable&auth=$Token"
}

if ($Stats) {
    irm "http://$Server/admin/api.php?summary&auth=$Token"
}

if ($TopClient) {
    (irm "http://$Server/admin/api.php?getQuerySources&auth=$Token").top_sources # topClients=25
}

if ($TopPermittedDomains) {
    (irm "http://$Server/admin/api.php?topItems=$Count&auth=$Token").top_queries
}

if ($LastBlockedDomain) {
    irm "http://$Server/admin/api.php?recentBlocked&auth=$Token"
}

if ($ForwardServer) {
    (irm "http://$Server/admin/api.php?getForwardDestinations&auth=$Token").forward_destinations
}

if ($QueryTypes) {
    (irm "http://$Server/admin/api.php?getQueryTypes&auth=$Token").querytypes
}

if ($QueryLog) {
    $datas = (irm "http://$Server/admin/api.php?getAllQueries&auth=$Token").data
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    foreach ($d in $datas) {
        ### Convert Unix Time:
        $EpochTime = [DateTime]"1/1/1970"
        $TimeZone = Get-TimeZone
        $UTCTime = $EpochTime.AddSeconds($d[0])
        $Time = $UTCTime.AddMinutes($TimeZone.BaseUtcOffset.TotalMinutes)
        ### Replace Status:
        if ($d[4] -eq 1) {
            $Out_Status = "Blocked (gravity)"
        } elseif ($d[4] -eq 2) {
            $Out_Status = "ОК"
        } elseif ($d[4] -eq 3) {
            $Out_Status = "Cache"
        } elseif ($d[4] -eq 14) {
            $Out_Status = "OK (already forwarded)"
        } elseif ($d[4] -eq 16) {
            $Out_Status = "Blocked (special domain)"
        } else {
            $Out_Status = $d[4]
        }
        ### Replace Replay:
        if ($d[6] -eq 1) {
            $Out_Replay = "NODATA"
        } elseif ($d[6] -eq 2) {
            $Out_Replay = "NXDOMAIN"
        } elseif ($d[6] -eq 3) {
            $Out_Replay = "CNAME"
        } elseif ($d[6] -eq 4) {
            $Out_Replay = "IP"
        } elseif ($d[6] -eq 13) {
            $Out_Replay = "BLOB"
        } else {
            $Out_Replay = $d[6]
        }
        ### Creat Object:
        $Collections.Add([PSCustomObject]@{
            Time                = $Time;
            Type                = $d[1];
            IP_Client           = $d[3];
            Name_Destination    = $d[2];
            Status              = $Out_Status;
            Replay              = $Out_Replay;
            Time_ms             = $d[7];
            Forward_NS          = $d[10];
        })
    }
    $Collections
}

if ($Data) {
    (irm "http://$Server/admin/api.php?overTimeData10mins&auth=$Token").domains_over_time
}

if ($Versions) {
    irm "http://$Server/admin/api.php?versions&auth=$Token" | 
    select core_update,core_current,core_latest,core_branch,web_update,web_current,web_latest,web_branch,
    FTL_update,FTL_current,FTL_latest,FTL_branch
}

if ($Releases) {
    $Core = irm "https://api.github.com/repos/pi-hole/pi-hole/releases/latest"
    $Web  = irm "https://api.github.com/repos/pi-hole/AdminLTE/releases/latest"
    $FTL  = irm "https://api.github.com/repos/pi-hole/ftl/releases/latest"
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    $Collections.Add([PSCustomObject]@{
        Core_Version    = $Core.Name;
        Core_Prerelease = $Core.prerelease;
        Core_Created    = $Core.created_at;
        Web_Version     = $Web.Name;
        Web_Prerelease  = $Web.prerelease;
        Web_Created     = $Web.created_at;
        FTL_Version     = $FTL.Name;
        FTL_Prerelease  = $FTL.prerelease;
        FTL_Created     = $FTL.created_at
    })
    $Collections
}

if ($AdList) {
    $Info = ((irm "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts") -split "\n")[0..10]
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    $Collections.Add([PSCustomObject]@{
        Title   = ($info[0] -split ":\s")[-1];
        Date    = ($info[5] -split ":\s")[-1];
        Domains = ($info[6] -split ":\s")[-1];
        Link    = ($info[9] -split ":\s")[-1]
    })
    $Collections
}
}