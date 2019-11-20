function InterpretString($Str)
{	
	return iex "`"$Str`""
}

$script:response = "Who is there?"

$txtContent = cat .\message.txt
$txtContentInterpreted = InterpretString -Str $txtContent
Write-Host $txtContentInterpreted -ForegroundColor Cyan

$jsonContent = cat .\message.json
$jsonContentSafe = $jsonContent.Replace("`"", "```"")
$jsonContentInterpreted = InterpretString -Str $jsonContentSafe
$jsonContentInterpreted | ConvertFrom-Json | fl
