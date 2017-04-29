# PowerShell testing module
![Build status](https://roarwrecker.visualstudio.com/_apis/public/build/definitions/478c7626-165c-4048-90b9-687be51d1897/2/badge)

I have started the PowerShell testing project to create a collection of PowerShell test functions. This functions can be used to write Pester tests for your own PowerShell scripts. I have just started using Pester and, therfore, I hope the number of useful functions will increase in the future.

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

This project is licensed under the [MIT License](https://github.com/roarwrecker/testing/blob/master/LICENSE).
