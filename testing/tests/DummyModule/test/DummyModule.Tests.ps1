#Requires -Modules Pester

$testingModule = Get-Item -Path "${PSScriptRoot}\..\..\..\..\testing"

Get-Module -Name testing -All | Remove-Module -Force
Import-Module $testingModule -Force -ErrorAction Stop

$dummyModule = 'DummyModule'

Describe "Calling method from $dummyModule when imported via Parent parameter" {

    <#
        This demonstrates the use case of the Parent parameter. Without the 
        Parent parameter the exact position of the module folder must be 
        specified. See below.
    #>
    Import-ModuleFromPath -Parent

    It "Should return Hello World" {
        Invoke-MyDummyFunctionForTheTest | Should Be 'Hello World!'
    }
    
}

Get-Module -Name $dummyModule -All | Remove-Module -Force

Describe "Calling method from $dummyModule using Path parameter" {

    It "should not exist a loaded $dummyModule" {
        Get-Module -Name $dummyModule | Should BeNullOrEmpty
    }

    <# 
        This invocation demonstrates the use case of the Parent parameter
        used above. Without the Parent parameter one has to specify the
        exact position of the module folder.
    #>
    Import-ModuleFromPath -Path "${PSScriptRoot}\..\..\${dummyModule}"
    
    It "Should return Hello World" {
        Invoke-MyDummyFunctionForTheTest | Should Be 'Hello World!'
    }
}