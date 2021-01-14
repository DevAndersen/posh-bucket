Write-Host
for ($y = 0; $y -le 15; $y++)
{
	for ($x = 0; $x -le 15; $x++)
	{
		# Hexadecimalification
		$sX = [convert]::ToString($x, 16)
		$sy = [convert]::ToString($y, 16)
		
		Write-Host " $sX$sY " -ForegroundColor ([System.ConsoleColor]$x) -BackgroundColor ([System.ConsoleColor]$y) -NoNewline
	}
	Write-Host
}
Write-Host
