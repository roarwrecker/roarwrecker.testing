﻿Import-Module pester -Force
Import-Module roarwrecker.testing -Force
Import-ModuleFromPath -Parent

$sut = 'Test-ModulePath'

Describe "'$sut' without module file" {

    $folder1 = New-Item -Path "$TestDrive\folder1" -ItemType Directory
    $folder2 = New-Item -Path "$TestDrive\folder2" -ItemType Directory
    $folder3 = New-Item -Path "$TestDrive\folder3" -ItemType Directory

    It "should return false for single folder" {
        & $sut -Path $folder1 | should be $false
    }

    It "should return false for multiple folders via pipeline input" {
        $result = ($folder1, $folder2, $folder3) | & $sut
    }
}

Describe "'$sut' with module file" {

    $folder1 = New-Item -Path "$TestDrive\module1" -ItemType Directory
    $folder2 = New-Item -Path "$TestDrive\module2" -ItemType Directory
    $folder3 = New-Item -Path "$TestDrive\module3" -ItemType Directory
    
    New-Item -Path "$TestDrive\module1\module1.psm1" -ItemType File
    New-Item -Path "$TestDrive\module2\module2.psm1" -ItemType File
    New-Item -Path "$TestDrive\module3\module3.psm1" -ItemType File

    It "should return true for single folder" {
        & $sut -Path $folder1 | should be $true
    }

    It "should return true for multiple folders via pipeline input" {
        $result = ($folder1, $folder2, $folder3) | & $sut
    }
}