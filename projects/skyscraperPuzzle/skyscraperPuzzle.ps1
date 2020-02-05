[CmdletBinding()]
param(
   [int][ValidateSet(2,3,4,5,6,7,8,9)]$Size = 5,
   [int]$Seed = (Get-Random)
)

$scaleX = 6
$scaleY = 4
$lengthX = ($Size + 2) * $scaleX + 1
$lengthY = ($Size + 2) * $scaleY + 1
$rand = [Random]::new($Seed)
$cursorStartX = [console]::CursorLeft
$cursorStartY = [console]::CursorTop
[int[,]]$script:baseGrid
[int[,]]$grid = [int[,]]::new($Size, $Size)
$outer = [int[]]::new($Size * 4)

$selectedX = 0
$selectedY = 0

function FillGrid()
{
	$script:baseGrid = [int[,]]::new($Size, $Size)
	for ($i = 1; $i -le $Size; $i++)
	{
		for ($j = 0; $j -lt $Size; $j++)
		{
			$failedHits = 0
			$keepLooking = $true
			
			while ($keepLooking)
			{
				$rowIndex = $rand.Next($Size)
				$columnIndex = $rand.Next($Size)
				
				$row = 0..$Size | % { $baseGrid[$rowIndex, $_] }
				$column = 0..$Size | % { $baseGrid[$_, $columnIndex] }
				
				if ($baseGrid[$rowIndex, $columnIndex] -eq 0 -and ($row -notcontains $i) -and ($column -notcontains $i))
				{
					$baseGrid[$rowIndex, $columnIndex] = $i
					$keepLooking = $false
				}
				else
				{
					$failedHits++
				}
				
				if ($failedHits -gt 200)
				{
					return $false
				}
			}
		}
	}
	return $true
}

function PrintLines()
{
	[console]::SetCursorPosition($cursorStartX, $cursorStartY)
	for ($y = 0; $y -lt $lengthY; $y++)
	{
		$line = ""
		for ($x = 0; $x -lt $lengthX; $x++)
		{
			$withinBounds = $x -in ($scaleX)..($lengthX - $scaleX - 1) -or $y -in ($scaleY)..($lengthY - $scaleY - 1)
			if (($y % $scaleY -eq 0) -and $withinBounds)
			{
				$line += "."
			}
			elseif (($x % $scaleX -eq 0) -and $withinBounds)
			{
				$line += "."
			}
			else
			{
				$line += " "
			}
		}
		Write-Host $line
	}
}

function PrintGrid()
{
	for ($x = 0; $x -lt $Size; $x++)
	{
		for ($y = 0; $y -lt $Size; $y++)
		{
			[console]::SetCursorPosition($cursorStartX + ($scaleX * ($x + 1.5)), $cursorStartY + ($scaleY * ($y + 1.5)))
			
			$isCurrentCellSelected = $selectedX -eq $x -and $selectedY -eq $y
			
			if ($isCurrentCellSelected)
			{
				$cellColor = "Green"
			}
			else
			{
				$cellColor = "Gray"
			}
			
			if ($grid[$x, $y] -eq 0)
			{
				if ($isCurrentCellSelected)
				{
					$currentChar = "_"
				}
				else
				{
					$currentChar = " "
				}
			}
			else
			{
				$currentChar = $grid[$x, $y]
			}
			Write-Host $currentChar -NoNewline -ForegroundColor $cellColor
		}
		Write-Host
	}
}

function GetArray($GridToCalculate, $Index)
{
	$array = [int[]]::new($Size)
	$side = [Math]::Floor($Index / $Size)
	$sideIndex = $Index % $Size
	
	for ($j = 0; $j -lt $Size; $j++)
	{
		$array[$j] = switch ($side)
		{
			0 { $GridToCalculate[$sideIndex, $j] }
			1 { $GridToCalculate[(($Size - 1) - $j), $sideIndex] }
			2 { $GridToCalculate[(($Size - 1) - $sideIndex), (($Size - 1) - $j)] }
			3 { $GridToCalculate[$j, (($Size - 1) - $sideIndex)] }
		}
	}
	return $array
}

function CalculateOuter($GridToCalculate)
{
	$calculatedOuter = [int[]]::new($Size * 4)
	for ($i = 0; $i -lt $outer.Count; $i++)
	{
		$array = GetArray -GridToCalculate $GridToCalculate -Index $i
		
		$seen = 0
		$biggest = 0
		for ($k = 0; $k -lt $Size; $k++)
		{
			$current = $array[$k]
			
			if ($current -gt $biggest)
			{
				$biggest = $current
				$seen++
			}
		}
		
		$calculatedOuter[$i] = $seen
	}
	return $calculatedOuter
}

function PrintOuter()
{
	for ($i = 0; $i -lt $outer.Count; $i++)
	{
		$side = [Math]::Floor($i / $Size)
		$index = $i % $Size
		
		$pos = switch ($side)
		{
			0 { (($cursorStartX + ($scaleX * ($index + 1.5))), ($cursorStartY + $scaleY * 0.5)) }
			1 { (($cursorStartX + $lengthX - ($scaleX * 0.5) - 1), ($cursorStartY + ($scaleY * (($index + 1) + 0.5)))) }
			2 { (($cursorStartX + ($lengthX - ($ScaleX * 1.5) - 1) - ($index * $ScaleX)), ($cursorStartY + $lengthY - ($scaleY * 0.5) - 1)) }
			3 { (($cursorStartX + ($scaleX * 0.5)), ($cursorStartY + $lengthY - ($scaleY * 1.5) - 1 - ($index * $scaleY))) }
		}
		
		[console]::SetCursorPosition($pos[0], $pos[1])
		Write-Host $outer[$i] -ForegroundColor Cyan
	}
}

function IsGridSolved()
{
	# Check if the grid has any empty values
	if ($grid -contains 0)
	{
		return $false
	}

	$calculatedOuter = CalculateOuter -GridToCalculate $grid
	
	# Check if all outers match
	for ($i = 0; $i -lt $outer.Count; $i++)
	{
		if ($calculatedOuter[$i] -ne $outer[$i])
		{
			return $false
		}
	}
	
	# Check for duplicate values in arrays
	for ($i = 0; $i -lt $Size * 4; $i++)
	{
		$array = GetArray -GridToCalculate $grid -Index $i
		
		if (($array | group | ? { $_.Count -ne 1 }) -ne $null)
		{
			return $false
		}
	}
	return $true
}

function HandleInput()
{
	$keyInput = [console]::ReadKey($true)
	$pressedKey = $keyInput.Key
	$keyChar = [char]($keyInput.KeyChar)
	
	$parsedKeyChar = $null
	
	if (([consolekey]::UpArrow, [consolekey]::W) -contains $pressedKey)
	{
		MoveSelection -X 0 -Y -1
	}
	elseif (([consolekey]::DownArrow, [consolekey]::S) -contains $pressedKey)
	{
		MoveSelection -X 0 -Y 1
	}
	elseif (([consolekey]::LeftArrow, [consolekey]::A)-contains $pressedKey)
	{
		MoveSelection -X -1 -Y 0
	}
	elseif (([consolekey]::RightArrow, [consolekey]::D) -contains $pressedKey)
	{
		MoveSelection -X 1 -Y 0
	}
	elseif ($pressedKey -eq [consolekey]::Home)
	{
		$script:grid = $script:baseGrid
	}
	elseif ([int]::TryParse($keyChar, [ref]$parsedKeyChar) -and (0..$Size) -contains $parsedKeyChar)
	{
		$grid[$selectedX, $selectedY] = $parsedKeyChar
	}
}

function MoveSelection($X, $Y)
{
	$range = 0..($Size - 1)
	$newX = $selectedX + $X
	$newY = $selectedY + $Y
	$newXInRange = $range -contains $newX
	$newYInRange = $range -contains $newY
	
	if ($newXInRange -and $newYInRange)
	{
		$script:selectedX = $newX
		$script:selectedY = $newY
	}
}

function MainFlow()
{
	[console]::CursorVisible = $false
	while (!(FillGrid))
	{
	}
	
	$outer = CalculateOuter -GridToCalculate $baseGrid
	
	PrintLines
	PrintOuter
	PrintGrid
	
	$timer = [System.Diagnostics.Stopwatch]::new()
	$timer.Start()
	while (!(IsGridSolved))
	{
		[console]::CursorTop = $cursorStartY + $lengthY
		HandleInput
		PrintOuter
		PrintGrid
	}
	$timer.Stop()
	
	[console]::CursorTop = $cursorStartY + $lengthY
	Write-Host "Congratulations, puzzle solved!" -ForegroundColor Green
	Write-Host "Time:  $($timer.Elapsed.ToString("hh\:mm\:ss\:fff"))"
	Write-Host
	[console]::CursorVisible = $true
}

MainFlow
