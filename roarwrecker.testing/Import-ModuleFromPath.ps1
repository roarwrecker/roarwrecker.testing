<#
.Synopsis
    Re-Imports a module from the given path.

.DESCRIPTION
    The function can be used in a Pester test script to load a module
    from the developer path by removing an already loaded module 
    with the same name.

.EXAMPLE
    Import-ModuleFromPath .
   
    Reloads the module from the current location

.EXAMPLE
    Import-ModuleFromPath ..\roarwrecker.network

    Reloads the module from the relative path

.EXAMPLE
    Import-ModuleFromPath C:\dev\powershell\modules\roarwrecker.network

    Reloads the module from the absolute path

.EXAMPLE
    Import-ModuleFromPath -Parent

    Reloads the module by analyzing the PSCallStack. The module folder must be the parent
    folder where the invocation took place.
#>
function Import-ModuleFromPath
{
    [CmdletBinding()]
    Param
    (
        # The path to the module folder which should get loaded.
        [Parameter(ParameterSetName='ByPath',
            Mandatory)]
        [ValidateScript({Test-Path $_ -PathType ‘Container’})]
        [string]
        $Path,

        [Parameter(ParameterSetName='ByParentSwitch',
            Mandatory)]
        [switch]
        $Parent
    )
    
    switch($PsCmdlet.ParameterSetName)
    {
        'ByParentSwitch' { 

            $Path = GetPathFromCallStack
            Write-Verbose "Identified module path from call stack: $($Path)"
        }
    }
    $Folder = Get-Item -Path $Path

    Write-Verbose -Message "Path to module: $Folder"

    # check if $Folder points to a module
    if (!(Test-ModulePath -Path $Folder))
    {
        throw "Could not find the '$($Folder.Name).psm1' file on path '$Folder'"
    }

    $loadedModule = Get-Module -Name ($Folder.Name)
    if (($loadedModule | Measure).Count -gt 0)
    {
        Remove-Module -Name $loadedModule
    }

    Import-Module -Name $Folder
}

# todo: write tests
function GetPathFromCallStack
{
    $scriptRoot = (Get-PSCallStack)[2].GetFrameVariables().PSScriptRoot.Value
    
    return Split-Path -Parent -Path $scriptRoot
}