$tileDirectory = "$PSScriptRoot\tiles"
$boardDirectory = "$PSScriptRoot\boards"

function CreateImage($Text, $OriginalText)
{
	$filteredText = $Text.Substring(2)
	$textHash = "$($OriginalText.GetHashCode())_$($filteredText.GetHashCode())"
	$imageFileName = "$tileDirectory\$($textHash).png"
	
	if ((Test-Path $imageFileName))
	{
		return
	}
	
	$bgColor = "#eaebef"
	
	Write-Host "> $filteredText"
	
	magick `
		-background "$bgColor" `
		-fill "#000000" `
		-font "Arial" `
		-size "240x240" `
		-gravity "center" `
		caption:"$filteredText" `
		-bordercolor "$bgColor" `
		-border "4x4" `
		-bordercolor "#000000" `
		-border "1x1" `
		$imageFileName
}

function GetLineMutations($Text)
{
	$match = [regex]::Match($Text, "\[(.+?)\]")
	
	if ($match.Success)
	{
		$before = $Text.Substring(0, $match.Index)
		$after = $Text.Substring($match.Index + $match.Length)
		$mutations = $match.Groups[1].Value.Split("|")
		
		foreach ($mut in $mutations)
		{
			GetLineMutations -Text "$before$mut$after"
		}
	}
	else
	{
		return $Text
	}
}

mkdir $tileDirectory *> $null
mkdir $boardDirectory *> $null

$items = Get-Content ".\bingo.txt" | ? { $_ -match "^- " }

foreach ($item in $items)
{
	$itemMutations = GetLineMutations $item
	
	foreach ($mut in $itemMutations)
	{
		CreateImage -Text $mut -OriginalText $item
	}
}

$groupedTiles = Get-ChildItem $tileDirectory -File | % { [PSCustomObject]@{ File = $_ ; CommonName = $_.Name.Split("_")[0] } } | Group-Object -Property CommonName

$selectedTiles = ($groupedTiles | Get-Random -Count 25 | % { $_.Group | Get-Random }).File.FullName

$timestamp = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()
$boardFileName = "$boardDirectory\board_$($timestamp).png"

magick montage $selectedTiles -geometry "+0+0" "$boardFileName"
Invoke-Item $boardFileName
