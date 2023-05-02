$path_psm = ($env:PSModulePath.Split(";")[0])+"\Invoke-Pi-Hole\Invoke-Pi-Hole.psm1"
if (!(Test-Path $path_psm)) {
    New-Item $path_psm -ItemType File -Force
}
irm https://raw.githubusercontent.com/Lifailon/PS-Pi-Hole/rsa/Invoke-Pi-Hole/Invoke-Pi-Hole.psm1 | Out-File $path_psm -Force