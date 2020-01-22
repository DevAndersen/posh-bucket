$lineOpen = (0..4 | % { "     " }) -join "."
$lineClosed = (0..28 | % { "." }) -join ""

$dimX = 5
$dimY = 5

$currentX = 4
$currentY = 4

$validX = 0..($dimX - 1)
$validY = 0..($dimY - 1)

[int[,]]$grid = [int[,]]::new($dimX, $dimY)
[int[,]]$solvedGrid = [int[,]]::new($dimX, $dimY)

function FillGrid($InputGrid)
{
	for ($y = 0; $y -lt $dimY; $y++)
	{	
		for ($x = 0; $x -lt $dimX; $x++)
		{
			if (($x -ne $dimX - 1) -or ($y -ne $dimY - 1))
			{
				$InputGrid[$x, $y] = ($y * 5) + $x + 1
			}
		}
	}
}

function PrintLines()
{
	[console]::SetCursorPosition(0, 0)
	for ($i = 0; $i -lt (3 * 5) + 4; $i++)
	{
		if ($i % 4 -eq 3)
		{
			Write-Host $lineClosed
		}
		else
		{
			Write-Host $lineOpen
		}
	}
}

function PrintGrid()
{
	[console]::SetCursorPosition(0, 0)
	for ($y = 0; $y -lt $dimY; $y++)
	{	
		for ($x = 0; $x -lt $dimX; $x++)
		{
			$number = $grid[$x, $y]
			
			[console]::SetCursorPosition($x * 6 + 2, $y * 4 + 1)
			if ($grid[$x, $y] -ne 0)
			{
				Write-Host $number.ToString().PadRight(2, " ")
			}
			else
			{
				Write-Host "  "
			}
		}
	}
}

function GetInput()
{
	$input = [console]::ReadKey().Key
	
	if ($input -eq [consolekey]::UpArrow)
	{
		return 0,-1
	}
	elseif ($input -eq [consolekey]::DownArrow)
	{
		return 0,1
	}
	elseif ($input -eq [consolekey]::LeftArrow)
	{
		return -1,0
	}
	elseif ($input -eq [consolekey]::RightArrow)
	{
		return 1,0
	}
	else
	{
		return 0,0
	}
}

function MoveTile($MoveX, $MoveY)
{
	$newX = $currentX + $MoveX
	$newY = $currentY + $MoveY
	
	$isMoveXValid = (($MoveX -ne 0) -and ($validX -contains $newX))
	$isMoveYValid = (($MoveY -ne 0) -and ($validY -contains $newY))
	$isMoveValid = $isMoveXValid -or $isMoveYValid
	
	
	if ($isMoveValid)
	{
		$tmp = $grid[$currentX, $currentY]
		$grid[$currentX, $currentY] = $grid[$newX, $newY]
		$grid[$newX, $newY] = $tmp
		
		$script:currentX = $newX
		$script:currentY = $newY
	}
}

function IsGridSolved()
{
	for ($y = 0; $y -lt $dimY; $y++)
	{	
		for ($x = 0; $x -lt $dimX; $x++)
		{
			if ($grid[$x, $y] -ne $solvedGrid[$x, $y])
			{
				return $false
			}
		}
	}
	return $true
}

function ShuffleGrid()
{
	$validMoves = ((0,1),(0,-1),(1,0),(-1,0))
	
	0..400 | % {
		$move = Get-Random $validMoves
		MoveTile -MoveX $move[0] -MoveY $move[1]
	}
}

FillGrid -InputGrid $grid
FillGrid -InputGrid $solvedGrid

ShuffleGrid

PrintLines
PrintGrid

$timer = [System.Diagnostics.Stopwatch]::new()
$timer.Start()

while (!(IsGridSolved))
{
	$input = GetInput
	MoveTile -MoveX $input[0] -MoveY $input[1]
	PrintGrid
}

$timer.Stop()


Write-Host "Congratulations, puzzle solved!"
Write-Host "Your time: $($timer.Elapsed.ToString("hh\:mm\:ss\.fff"))"
