$list = [System.Collections.ArrayList]::new()

Write-Host "Press any key to hog 1 GB of RAM"
Write-Host "To free hogged RAM, close the PowerShell window/process"

while ($true)
{
	Write-Host "Press any key to hog 1 GB of RAM (currently hogging $($list.Count) GB)"
	[System.Console]::ReadKey($true) | Out-Null
	$data = [byte[]]::new(1000000000)
	$list.Add($data) | Out-Null
	[array]::Fill[byte]($data, 2)
}
