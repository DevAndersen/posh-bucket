param (
    [string[]]$Directories,
    [string[]]$FileTypes = @("*.png","*.jpg","*.jpeg","*.jfif"),
    [string]$OutputDir = [System.IO.Path]::Combine($PSScriptRoot, "Wallpapers"),
	[string]$imageBaseDirectory = [System.IO.Path]::Combine($PSScriptRoot, "Images"),
    [string]$Regex,
    [int]$MinWidth = 1920,
    [int]$MinHeight = 1080,
    [switch]$IgnoreFormatIfLargeEnough = $false
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$correctFormat = ($MinWidth / $MinHeight)

Write-Progress -Activity "Scanning for images in $imageBaseDirectory" -Status "Please wait..." -Id 1

if (!$Directories)
{
	$list = ls $imageBaseDirectory -Include $FileTypes -Recurse
}
else
{
	for ($dirIndex = 0; $dirIndex -lt $Directories.Count; $dirIndex++)
	{
		$Directories[$dirIndex] = "$imageBaseDirectory$($Directories[$dirIndex])"
	}
	$list = ls $Directories -Include $FileTypes -Recurse
}

$list = $list | ? { $_.Fullname -match $Regex }

Write-Progress -Activity "Scanning for images in $imageBaseDirectory" -Status "Completed" -Id 1 -Completed

$fileCounter = 0

for ($i = 0; $i -lt $list.Count; $i++)
{
	$file = $list[$i]
	$filePath = $file.FullName
	$percent = [Math]::Floor(($i / $list.Count) * 100)
	
	Write-Progress -Activity "Finding and copying acceptable images... | $i/$($list.Count) | $percent% | $fileCounter images found" -Status "$filePath" -PercentComplete (($i/$($list.Count))*100) -Id 2
	
	try
	{
		$imageFileStream = [System.IO.File]::OpenRead($filePath)
		$image = [System.Drawing.Image]::FromStream($imageFileStream, $false, $false)
		if (($image.Width -ge $MinWidth) -and ($image.Height -ge $MinHeight))
		{
			if ($IgnoreFormatIfLargeEnough -or (($image.Width / $image.Height) -eq $correctFormat))
			{
				$outName = $file.Fullname.Replace([System.IO.Path]::GetFullPath("$imageBaseDirectory\"), "").Replace("\", "_")
				cp $filePath ([System.IO.Path]::Combine($OutputDir, $outName))
				$fileCounter++
			}
		}
	}
	catch
	{
		Write-Host "Error reading $filePath : $_" -ForegroundColor Red
	}
	finally
	{
		if ($imageFileStream)
		{
			$imageFileStream.Dispose()
		}
		if ($image)
		{
			$image.Dispose()
		}
	}
}

Write-Progress -Activity "Scanning images" -Status "Completed" -PercentComplete 100 -Id 2 -Completed

Write-Host "$fileCounter images copied."
