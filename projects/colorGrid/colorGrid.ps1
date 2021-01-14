param(
	[Switch]$AddExtraBlackRow
)

Write-Host
for ($y = 0; $y -le 15; $y++)
{
	for ($x = 0; $x -le 15; $x++)
	{
		# Hexadecimalification
		$hexX = [convert]::ToString($x, 16)
		$hexY = [convert]::ToString($y, 16)
		
		Write-Host " $hexX$hexY " -ForegroundColor ([System.ConsoleColor]$x) -BackgroundColor ([System.ConsoleColor]$y) -NoNewline
	}
	Write-Host
}

if ($AddExtraBlackRow)
{
	$encodingChar = [char]27
	for ($z = 0; $z -le 15; $z++)
	{
		$hexZ = [convert]::ToString($z, 16)
		Write-Host "$encodingChar[48;2;0;0;0m $($hexZ)0 $encodingChar[0m" -ForegroundColor ([System.ConsoleColor]$z) -NoNewline
	}
	Write-Host
}

Write-Host
