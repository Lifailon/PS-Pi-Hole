# PS-Pi-Hole
Module for interacting with pi-hole using the REST API

## 🚀 Install
Download and run the script **[Deploy-Invoke-Pi-Hole.ps1](https://github.com/Lifailon/PS-Pi-Hole/blob/rsa/Deploy-Invoke-Pi-Hole.ps1)** \
Server and Token can be set in module parameters (**line 28 and 29**) \
Get Token: `sudo cat /etc/pihole/setupVars.conf | grep PASSWORD`

## 🔑 Keys
- ✅ `Invoke-Pi-Hole -Server 192.168.1.253 -Token 5af9bd44aebce0af6206fc8ad4c3750b6bf2dd38fa59bba84ea9570e16a05d0f`
- ✅ `Invoke-Pi-Hole -Enable` Enable Blocking
- ✅ `Invoke-Pi-Hole -Disable` Disable Blocking
- ✅ `Invoke-Pi-Hole -Stats` Blocking work status
- ✅ `Invoke-Pi-Hole -TopClient`
- ✅ `Invoke-Pi-Hole -TopPermittedDomains`
- ✅ `Invoke-Pi-Hole -TopPermittedDomains -Count 100`
- ✅ `Invoke-Pi-Hole -LastBlockedDomain`
- ✅ `Invoke-Pi-Hole -ForwardServer` Upstream servers
- ✅ `Invoke-Pi-Hole -QueryTypes`
- ✅ `Invoke-Pi-Hole -QueryLog`
- ✅ `Invoke-Pi-Hole -Data` Number of requests for every 10 minutes during the last 24 hours
- ✅ `Invoke-Pi-Hole -Versions` Current and Latest versions
- ✅ `Invoke-Pi-Hole -Releases` Current (last) version and date from the GitHub repository
- ✅ `Invoke-Pi-Hole -AdList` Status Hosts List (StevenBlack)

## 🎉 Examples
