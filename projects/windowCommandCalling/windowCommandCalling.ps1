<#
    .SYNOPSIS
        Window-based command invokation and return viewing.
	
	.DESCRIPTION
		Invoke a command from a form window, and view the result in a grid window and/or console.
		
		The returned value of the called command can, using the ResultAction parameter, be view in a grid window, returned to the console, or both.
		
		If the Name parameter is not specified, the user will be prompted to select one of the available commands. Note that this can take a few seconds to load.
		
		If the ResultAction parameter is set to "Console" or "WindowAndConsole", the result will be returned, and can be piped to another command.
		If the ResultAction parameter is set to "Window", the result will not be returned, but if the returned value of the invoked command is null, the message "No result was returned." will be written to the console.
#>
[CmdletBinding(DefaultParameterSetName = "ShowAllCommands")]
param(
	# The name of the command you want to call.
	[Parameter(Position = 0, Mandatory = $true, ParameterSetName = "NamedCommand")]
    [String]$Name,
	
	# Specify how the result of the command should be shown.
	[Parameter(Position = 1)]
	[ValidateSet("Window", "Console", "WindowAndConsole")]
    [String]$ResultAction = "Window"
)

$commandText = New-Object System.Collections.ArrayList

$commandText.Add("Show-Command") | Out-Null

if ($PSCmdlet.ParameterSetName -eq "NamedCommand")
{
	$commandText.Add("-Name `"$Name`"") | Out-Null
}

$commandText.Add("-ErrorPopup") | Out-Null
$commandText.Add("-PassThru") | Out-Null
$commandText.Add("| iex") | Out-Null

if (($ResultAction -eq "Window") -or ($ResultAction -eq "WindowAndConsole"))
{
	$commandText.Add("| Tee-Object -Variable outputVariable | Out-GridView ; `$outputVariable") | Out-Null
}

$result = iex ($commandText -join " ")

if (($ResultAction -eq "Window") -and ($result -eq $null))
{
	Write-Host "No result was returned."
}

if (($ResultAction -eq "Console") -or ($ResultAction -eq "WindowAndConsole"))
{
	return $result
}
