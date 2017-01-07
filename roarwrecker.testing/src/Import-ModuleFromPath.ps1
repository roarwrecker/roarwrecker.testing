﻿#Requires -Version 3.0

<#
.Synopsis
    Re-Imports a module from the given path.

.DESCRIPTION
    The function can be used in a Pester test script to load a module
    from the developer path by removing all already loaded modules 
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

    Reloads the module by analyzing the PSCallStack. The module folder must be 
    located in the parent folder. The Parent switch can be used when the tests 
    folder is located inside the module folder.
    
    c:\path\to\module
        |-- module.psm1 (or module.psd1)
        |-- tests
            |-- some.tests.ps1
    
    If the function "Import-ModuleFromPath -Parent" is beein used inside the 
    "some.tests.ps1"" Pester test, the import function resolves the module path
    "c:\path\to\module"
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
        $Parent
    )
    if ($PsCmdlet.ParameterSetName -eq 'ByParentSwitch')
    {
        # todo: error handling
        $Path = GetPathFromCallStack
        $Name = Split-Path -Path $Path -Leaf
        Write-Verbose "Identified module path from call stack: $($Path)"
    }
    else 
    {
        # Only the path has been specified. Resolve module name from path
        # todo: error handling
        $Name = (Get-Item $Path -ErrorAction Stop).Name
    }
    Write-Verbose -Message "Path to module: $Path"

    Get-Module -Name $Name -All | Remove-Module -Force
    Import-Module $path -Force -ErrorAction Stop
}

# todo: write tests
function GetPathFromCallStack
{
    $scriptRoot = (Get-PSCallStack)[2].GetFrameVariables().PSScriptRoot.Value
    Split-Path -Parent -Path $scriptRoot
}