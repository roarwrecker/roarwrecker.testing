#Requires -Version 3.0

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
    Import-ModuleFromPath -Parent -Name Module

    Reloads the module by analyzing the PSCallStack. The module folder must be 
    located in the parent folder where the invocation of Import-ModulePath took 
    place.
#>
function Import-ModuleFromPath{
    [CmdletBinding()]
    Param (
        # The path to the module folder.
        [Parameter(
            ParameterSetName='ByPath',
            Mandatory
        )]
        [string]
        $Path,

        # Indicates that the module should be loaded from the parent folder of the current 
        # invocation scope. 
        [Parameter(
            ParameterSetName='ByParentSwitch',
            Mandatory
        )]
        [switch]
        $Parent,

        # The name of the module located in the parent folder.
        [Parameter(
            ParameterSetName='ByParentSwitch',
            Mandatory
        )]
        [string]
        $Name
    )
    if ($PsCmdlet.ParameterSetName -eq 'ByParentSwitch')
    {
        # Only the module name has been specified. Resolve path from call stack.
        # todo: error handling
        $Path = "$(GetPathFromCallStack)\$Name"
        Write-Verbose "Identified module path from call stack: $($Path)"
    }
    else 
    {
        # Only the path has been specified. Resolve module name from path
        # todo: error handling
        $Name = (Get-Item $Path -ErrorAction Stop).Name
    }
    Write-Verbose -Message "Path to module: $Path"

    Get-Module -Name $Name | Remove-Module -Force
    Import-Module $path -Force -ErrorAction Stop
}

# todo: write tests
function GetPathFromCallStack
{
    $scriptRoot = (Get-PSCallStack)[2].GetFrameVariables().PSScriptRoot.Value
    Split-Path -Parent -Path $scriptRoot
}