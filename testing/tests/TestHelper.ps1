function New-TestModule
{
    Param([string] $Name)

    # The actual module folder
    $moduleFolder = New-Item -Path "${TestDrive}\${Name}" -ItemType Directory
    # The corresponding module.psm1 file
    New-Item -Path "${moduleFolder}\${Name}.psm1" -ItemType File | Out-Null

    Write-Output $moduleFolder
}

function New-TestScript
{
    Param([string] $Path, [string] $Content)

    $scriptPath = New-Item -Path $Path -ItemType File -Force
    Set-Content -Path $scriptPath -Value $Content

    Write-Output $scriptPath
}