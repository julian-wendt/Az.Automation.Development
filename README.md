# Azure Automation Development Module

PowerShell module providing handy functions to develop Azure Automation Runbooks locally on your machine and maintain them in Azure.

## Installation and setup

To use this module, download and copy the project into one of your PS module directorys which can be found with `$env:PSModulePath -split ';'`. You can also copy the module into another directory but in this case Autoload may not work and the module must be imported with `Import-Module -Name 'your-location\Az.Automation.Development'.` Please note that all module files must be located in the directory **Az.Automation.Development**.

Most functions in this module require that global variables providing necessary information about your Azure environment have been set before they are fired the first time. To setup the global environment variables, run the command `Import-AutomationSettings`. This can be done in your PowerShell profile or somewhere else.

The function requires that a settings file is passed, which provides the required information like Tenant Id, Subscription Id, Automation Account Name and so on. An example file can be found in the root directory of the module.


```PowerShell
Import-AutomationSettings -Path "$PSScriptRoot\settings.json"
```
