#Requires -Modules Pester
. $PSScriptRoot\TestHelper.ps1

$module = 'testing'
$sut = 'Import-ModuleFromPath'

$path = Split-Path -Path $PSScriptRoot -Parent
Get-Module -Name $module -All | Remove-Module -Force
Import-Module $path -Force -ErrorAction Stop


Describe "'$sut' tests with valid module folder" {

    $modulePath = New-TestModule 'mymodule'

    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Import-Module -ModuleName $module -MockWith { }

    It "should not throw error" {
        { & $sut -Path $modulePath } | Should Throw
    }
    
    Context "With loaded module" {

        # Simulate module has already been loaded
        Mock -CommandName Get-Module -ModuleName $module -MockWith { 
            New-Object -TypeName PSModuleInfo -ArgumentList $false 
        }

        & $sut -Path $modulePath
        
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
        
        & $sut -Path $modulePath
        
        It "Remove-Module should not be called" {
            Assert-MockCalled -CommandName Remove-Module -Exactly 0 -ModuleName $module -Scope Context
        }

        It "Import-Module should be called" {
            Assert-MockCalled -CommandName Import-Module -Exactly 1 -ModuleName $module -Scope Context
        }
    }
}

Describe "'$sut' tests with no corresponding psm1 file" {
    
    # Only create folder without module file
    $modulePath = New-Item -Path "${TestDrive}\module" -ItemType Directory

    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Get-Module -ModuleName $module -MockWith { }

    It "should throw error" {
        { & $sut -Path $modulePath } | Should Throw
    }
}

Describe "'$sut' tests with invalid path" {
    
    $modulePath = "C:\path\does\not\exist"

    It "Should not exist the module" {
        $modulePath | Should not exist
    }

    It "should throw error" {
        { & $sut -Path $modulePath } | Should Throw
    }
}

<# 
    Idea of the following tests:
    When the SUT gets invoked without a Path parameter using the Parent switch,
    the Path gets determinded by analyzing the PSCallStack. To get a valid CallStack 
    the invocation of the SUT gets written into a *.ps1 file on the $TestDrive. 
    The created *.ps1 file will be used to call the SUT.
#>
Describe "'$sut' with Parent switch" {

    $modulePath = New-TestModule 'mymodule'
    # Create the file as it would be a pester tests file and write the file content into it
    $scriptPath = New-TestScript `
        -Path "${modulePath}\tests\Invoke-SutWithoutPath.Tests.ps1" `
        -Content "$sut -Parent"
    
    Mock -CommandName Remove-Module -ModuleName $module -MockWith { }
    Mock -CommandName Import-Module -ModuleName $module -MockWith { }
    Mock -CommandName Get-Module -ModuleName $module -MockWith { }

    It "Should exist the test script" {
        $scriptPath | Should exist
    }

    It "should identify the path when location is set" {
        # invoke the command from the created script
        & $scriptPath  
        Assert-MockCalled -CommandName Import-Module -Exactly 1 `
            -ModuleName $module -Scope It -ParameterFilter { $Name -eq $modulePath}
    }
}

Describe "'$sut' with real module structure" {

    $modulePath = New-TestModule 'mymodule'

    AfterEach {
        Get-Module 'mymodule' -All | Remove-Module
    }

    Context "Calling $sut from tests script using absolute path" {

        $scriptPath = New-TestScript -Path "${modulePath}\Some.Tests.ps1" `
            -Content "$sut $modulePath"

        It "should load module" {
            & $scriptPath
            Get-Module 'mymodule' -All | Should not BeNullOrEmpty
        }
    }
    
    Context "Calling $sut using relative path" {
        
        $currentLocation = Get-Location
        
        It "should load module when at correct location" {
            Set-Location -Path $modulePath
            & $sut ..\mymodule
            Get-Module 'mymodule' -All | Should not BeNullOrEmpty
        }

        It "should throw when at wrong location" {
            Set-Location -Path (Split-Path $modulePath -Parent)
            { & $sut ..\mymodule } | Should throw
        }

        Set-Location $currentLocation
    }

    Context "Calling $sut using '.' for Path parameter" {

        $currentLocation = Get-Location

        It "should load module" {
            Set-Location -Path $modulePath
            & $sut .
            Get-Module 'mymodule' -All | Should not BeNullOrEmpty
        }

        Set-Location $currentLocation
    }
}