# PowerShell testing module
[![Build status](https://ci.appveyor.com/api/projects/status/x5sl8x1esgb9r3mi/branch/master?svg=true)](https://ci.appveyor.com/project/roarwrecker/roarwrecker-testing/branch/master)

I have started the PowerShell testing project to create a collection of PowerShell test functions. This functions can be used to write Pester tests for your own PowerShell scripts. I have just started using Pester and, therfore, I hope the number of useful functions will increase in the future.

### Build Status

The following list shows the build status for the testing module on different PowerShell build agents. The different agents execute the implemented Pester tests on a PowerShell with the specified version. This is a free service offered by [PowerShell.org](https://powershell.org/build-server/).

- [PowerShell V3 ![](https://build.powershell.org/app/rest/builds/buildType:RoarwreckerTesting_TestOnPowerShellV3/statusIcon)]
(https://build.powershell.org/viewType.html?buildTypeId=RoarwreckerTesting_TestOnPowerShellV3)

- [PowerShell V4 ![](https://build.powershell.org/app/rest/builds/buildType:RoarwreckerTesting_TestOnPowerShellV4/statusIcon)]
(https://build.powershell.org/viewType.html?buildTypeId=RoarwreckerTesting_TestOnPowerShellV4)

- [PowerShell V5 ![](https://build.powershell.org/app/rest/builds/buildType:RoarwreckerTesting_TestOnPowerShellV5/statusIcon)](https://build.powershell.org/viewType.html?buildTypeId=RoarwreckerTesting_TestOnPowerShellV5)

### Dependencies

The testing module has the following dependencies:
- [Pester](https://github.com/pester/Pester) for executing the tests written for the testing module

### Installation

You can clone the repository and add the [modules folder](https://github.com/roarwrecker/testing/tree/master/testing) to your PowerShell module path. Or you can install the module from the [PowerShell Gallery](https://www.powershellgallery.com/) using the following command:
```PowerShell
Install-Module -Name testing -Repository PSGallery
```

### Usage

Please check the PowerShell help written for all testing module functions.

### License

The PowerShell testing module is distributed under the [MIT license](https://github.com/roarwrecker/testing/blob/master/LICENSE).
