[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[String]$WriteString,
	
	[Parameter(Mandatory = $false)]
	[Char]$ColorSwitchChar = "@"
)

$pattern = "$ColorSwitchChar([0-9A-f])"
$splits = [Regex]::Split($WriteString, "$ColorSwitchChar[0-9A-f]")
$matches = [Regex]::Matches($WriteString, "$ColorSwitchChar([0-9A-f])")

$colorIndex = $null
0..$splits.Count | % {
	
	if ($colorIndex -eq $null)
	{
		Write-Host $splits[$_] -NoNewline
	}
	else
	{
		Write-Host $splits[$_] -ForegroundColor $colorIndex -NoNewline
	}
	
	if ($_ -lt $matches.Count)
	{
		$colorChar = $matches[$_].Groups[1].Value
		$colorIndex = [int]("0x$colorChar")
	}
}
