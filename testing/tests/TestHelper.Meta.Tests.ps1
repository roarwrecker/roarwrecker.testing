#Requires -Modules Pester
$sut = 'TestHelper'

. "${PSScriptRoot}\${sut}.ps1"

Describe "'New-TestModule' tests" {
  
    $path = New-TestModule 'mymodule'

    AfterAll {
        Get-Module 'mymodule' -All | Remove-Module -Force
    }

    It "should exist the module folder" {
        $path | Should exist
    }

    It "should contain the module name in the path" {
        Split-Path -Path $path -Leaf | Should be 'mymodule'
    }

    It "should be possible to import the test module" {
        { Import-Module $path } | Should not throw
    }
}

Describe "'New-TestScript' tests" {
  
    $sampleText = 'Hello World'
    $path = New-TestScript -Path "${TestDrive}\mytest.ps1" -Content @"
Write-Output "${sampleText}!"
"@

    It "should exist the module folder" {
        $path | Should exist
    }

    It "should contain the specified content" {
        Get-Content -Path $path | Should be "Write-Output `"Hello World!`""
    }

    It "should be evaluated correctly when calling the script" {
        & $path | Should be "Hello World!"
    }
}