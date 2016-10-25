Import-Module Pester -Force

$sut = 'Import-ModuleFromPath'

$module = (Get-Item $PSScriptRoot).Parent
$path = $module.FullName

if (-not (Test-Path $path))
{
    throw "Path to module does not exist: '$path'."
}

# check if module file exists, otherwise the path must be wrong
if (($path | Get-ChildItem -Filter '*.psm1' | Measure).Count -le 0)
{
    throw "Could not find a *.psm1 file on path '$path'"
}

# If already loaded remove and load module from dev path
Get-Module $module | Remove-Module -Force
Import-Module $path


Describe "'$sut' tests with valid module folder" {

    # Create the module folder
    $moduleFolder = New-Item -Path "$TestDrive\module" -ItemType Directory
    # Create the corresponding module.psm1 file
    $psModuleFile = New-Item -Path "$moduleFolder\module.psm1" -ItemType File

    Mock Remove-Module { } -ModuleName $module
    Mock Import-Module { } -ModuleName $module

    It "should not throw error" {
        { & $sut -Path $moduleFolder } | Should Not Throw
    }
    
    Context "With loaded module" {

        # Simulate module has already been loaded
        Mock Get-Module { New-Object -TypeName PSModuleInfo -ArgumentList $false } -ModuleName $module

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
        Mock Get-Module { } -ModuleName $module
        
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

    Mock Remove-Module { } -ModuleName $module
    Mock Import-Module { } -ModuleName $module
    Mock Get-Module { } -ModuleName $module

    It "should throw error" {
        { & $sut -Path $moduleFolder } | Should Throw "Could not find the 'module.psm1'"
    }
}

Describe "'$sut' tests with invalid path" {
    
    # Do not create the module folder
    $moduleFolder = "$TestDrive\module"

    Mock Remove-Module { } -ModuleName $module
    Mock Import-Module { } -ModuleName $module
    Mock Get-Module { } -ModuleName $module

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

    # Create the module folder
    $moduleFolder = New-Item -Path "$TestDrive\module" -ItemType Directory
    # Create tests folder where the script which will be invoked will be created to
    $testsFolder = New-Item -Path "$($moduleFolder)\tests" -ItemType Directory
    # Create the corresponding module.psm1 file
    $psModuleFile = New-Item -Path "$moduleFolder\module.psm1" -ItemType File

    # Create the file and write the file content into it
    $scriptPath = "$($testsFolder)\Invoke-SutWithoutPath.ps1"
    New-Item -Path $scriptPath -ItemType File
    Set-Content -Path $scriptPath -Value "& $($sut) -Parent"
    
    Mock Remove-Module { } -ModuleName $module
    Mock Import-Module { } -ModuleName $module
    Mock Get-Module { } -ModuleName $module

    It "should identify the path when location is set" {
        # invoke the command from the created script
        & $scriptPath  
        Assert-MockCalled -CommandName Import-Module -Exactly 1 `            -ModuleName $module -Scope It -ParameterFilter { $Name -eq $moduleFolder}
    }
}