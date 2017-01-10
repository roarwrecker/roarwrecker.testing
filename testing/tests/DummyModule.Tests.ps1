#Requires -Modules Pester

$testingModule = Get-Item -Path "${PSScriptRoot}\..\..\testing"

Get-Module -Name testing -All | Remove-Module -Force
Import-Module $testingModule -Force -ErrorAction Stop

Import-ModuleFromPath -Path "${PSScriptRoot}\DummyModule"

Describe "Calling method from DummyModule when imported via Path parameter" {

    It "Should return Hello World" {
        Invoke-MyDummyFunctionForTheTest | Should be 'Hello World!'
    }
    
}