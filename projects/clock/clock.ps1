param(
	[System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White
)

#region Functions

function GetDateTimeString()
{
	$dateTime = Get-Date
	$seconds = $dateTime.Second.ToString().PadLeft(2, "0")
	$minutes = $dateTime.Minute.ToString().PadLeft(2, "0")
	$hours = $dateTime.Hour.ToString().PadLeft(2, "0")
	return "$hours`:$minutes`:$seconds"
}

function WriteTime()
{
	$dateTime = GetDateTimeString
	
	$lines = [string[]]::new($displayData.Length)

	foreach ($char in $dateTime.ToCharArray())
	{
		$displayIndex = switch($char)
		{
			":" { 10 }
			default { [convert]::ToInt32($char.ToString()) }
		}
		
		for ($lineIndex = 0; $lineIndex -lt $lines.Length; $lineIndex++)
		{
			$lines[$lineIndex] += $displayData[$lineIndex][$displayIndex] + " "
		}
	}
	
	[console]::CursorTop = ([console]::WindowHeight / 2) - ($lines.Length / 2)
	foreach ($line in $lines)
	{
		[console]::CursorLeft = ([Console]::WindowWidth / 2) - ($line.Length / 2)
		Write-Host $line -ForegroundColor $ForegroundColor
	}
}

#endregion

#region Main flow

[console]::OutputEncoding = [System.Text.Encoding]::UTF8

$consoleWidth = -1
$consoleHeight = -1

$displayData = 
	@("█████","  █  ","█████","█████","█   █","█████","█████","█████","█████","█████","     "),
	@("█   █","███  ","    █","    █","█   █","█    ","█    ","    █","█   █","█   █","  █  "),
	@("█   █","  █  ","█████","█████","█████","█████","█████","    █","█████","█████","     "),
	@("█   █","  █  ","█    ","    █","    █","    █","█   █","    █","█   █","    █","  █  "),
	@("█████","█████","█████","█████","    █","█████","█████","    █","█████","█████","     ")

while ($true)
{
	$w = [console]::WindowWidth
	$h = [console]::WindowHeight
	[console]::SetBufferSize($w,$h)
	if (($w -ne $consoleWidth) -or ($h -ne $consoleHeight))
	{
		clear
		[console]::CursorVisible = $false
		$consoleWidth = $w
		$consoleHeight = $h
	}
	WriteTime
	sleep 1
}

#endregion
