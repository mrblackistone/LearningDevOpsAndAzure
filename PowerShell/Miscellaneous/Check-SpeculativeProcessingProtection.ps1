Install-Module SpeculationControl
$SaveExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module SpeculationControl
Get-SpeculationControlSettings
Set-ExecutionPolicy $SaveExecutionPolicy -Scope CurrentUser