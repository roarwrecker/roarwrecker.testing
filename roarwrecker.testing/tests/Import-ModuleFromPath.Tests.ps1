#Requires -Modules Pester

$module = 'roarwrecker.testing'
$sut = 'Import-ModuleFromPath'

$path = Split-Path -Path $PSScriptRoot -Parent
Get-Module -Name $module -All | Remove-Module -Force
Import-Module $path -Force -ErrorAction Stop


Describe "'$sut' tests with valid module folder" {

    # Create the module folder
    $moduleFolder = New-Item -Path "$TestDrive\module" -ItemType Directory
    # Create the corresponding module.psm1 file
    New-Item -Path "$moduleFolder\module.psm1" -ItemType File

    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Import-Module -ModuleName $module -MockWith { }

    It "should not throw error" {
        { & $sut -Path $moduleFolder } | Should Not Throw
    }
    
    Context "With loaded module" {

        # Simulate module has already been loaded
        Mock -CommandName Get-Module -ModuleName $module -MockWith { 
            New-Object -TypeName PSModuleInfo -ArgumentList $false 
        }

        & $sut -Path $moduleFolder
        
        It "Remove-Module should be called" {
            Assert-MockCalled -CommandName Remove-Module -Exactly 1 -ModuleName $module -Scope Context
        }

        It "Import-Module should be called" {           
            Assert-MockCalled -CommandName Import-Module -Exactly 1 -ModuleName $module -Scope Context
        }
    }

    Context "With module not loaded" {

        # Simulate no module has been loaded
        Mock -CommandName Get-Module -ModuleName $module -MockWith { }
        
        & $sut -Path $moduleFolder
        
        It "Remove-Module should not be called" {
            Assert-MockCalled -CommandName Remove-Module -Exactly 0 -ModuleName $module -Scope Context
        }

        It "Import-Module should be called" {
            Assert-MockCalled -CommandName Import-Module -Exactly 1 -ModuleName $module -Scope Context
        }
    }
}


Describe "'$sut' tests with no corresponding psm1 file" {
    
    # Create the module folder
    $moduleFolder = New-Item -Path "$TestDrive\module" -ItemType Directory

    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Get-Module -ModuleName $module -MockWith { }

    It "should throw error" {
        { & $sut -Path $moduleFolder } | Should Throw
    }
}

Describe "'$sut' tests with invalid path" {
    
    # Do not create the module folder
    $moduleFolder = "$TestDrive\module"

    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Import-Module -ModuleName $module -MockWith { }
    Mock -CommandName Get-Module -ModuleName $module -MockWith { }

    It "should throw error" {
        { & $sut -Path $moduleFolder } | Should Throw
    }
}

<# 
    Idea of the current tests:
    When the SUT gets invoked without a Path parameter the Path gets determinded by
    analyzing the PSCallStack. To get a valid CallStack the invocation of the SUT gets
    written into a *.ps1 file on the $TestDrive. The created *.ps1 file will be used 
    to call the SUT.
#>
Describe "'$sut' with no path parameter" {

    $moduleName = 'module'
    # Create the module folder
    $moduleFolder = New-Item -Path "$TestDrive\$moduleName" -ItemType Directory
    # Create tests folder where the test script will be written to.
    $testsFolder = New-Item -Path "$moduleFolder\tests" -ItemType Directory
    # Create the corresponding module.psm1 file
    New-Item -Path "$moduleFolder\$moduleName.psm1" -ItemType File

    # Create the file as it would be a pester tests file and write the file content into it
    $scriptPath = "$($testsFolder)\Invoke-SutWithoutPath.Tests.ps1"
    New-Item -Path $scriptPath -ItemType File
    # Content of test script: Contains the actual invocation of the SUT.
    Set-Content -Path $scriptPath -Value "$($sut) -Parent"
    
    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Import-Module -ModuleName $module -MockWith { }
    Mock -CommandName Get-Module -ModuleName $module -MockWith { }

    It "should identify the path when location is set" {
        # invoke the command from the created script
        & $scriptPath  
        Assert-MockCalled -CommandName Import-Module -Exactly 1 `
            -ModuleName $module -Scope It -ParameterFilter { $Name -eq $moduleFolder}
    }
}