#require module pester

$module = 'roarwrecker.testing'
$sut = 'Update-ModuleTests'

# todo: once roarwrecker.testing is published on online repository, resolve the module from there and import it
Import-Module -Name "$PSScriptRoot\..\$module" -Force

Describe "'$sut' with invalid path" {    
    $modulePath = New-Item -Path "$TestDrive\module" -ItemType Directory

    It "should throw an error when psm file does not exist" {
        { & $sut -Path $modulePath } | should throw
    }

    It "should throw an error when path is invalid" {
        { & $sut -Path "$TestDrive\invalidPath" } | should throw
    }
}

Describe "'$sut' without any existing tests" {
    
    $firstScriptName = "firstScript"
    $secondScriptName = "secondScript"

    $modulePath = New-Item -Path "$TestDrive\module" -ItemType Directory
    New-Item -Path "$modulePath\module.psm1" -ItemType File
    New-Item -Path "$modulePath\$firstScriptName.ps1" -ItemType File
    New-Item -Path "$modulePath\$secondScriptName.ps1" -ItemType File

    & $sut -Path $modulePath

    It "should create a tests directory" -Skip {
        Test-Path -Path "$modulePath\tests" -PathType Container | should be $true
    }

    It "should create a test file for the first script" -Skip {
        Test-Path -Path "$modulePath\tests\$firstScriptName.Tests.ps1" -PathType Leaf `            | should be $true
    }

    It "should create a test file for the second script" -Skip {
        Test-Path -Path "$modulePath\tests\$secondScriptName.Tests.ps1" -PathType Leaf `            | should be $true
    }

}
