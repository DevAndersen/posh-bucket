$length = (cat .\before.txt -Encoding Byte).Length
$buffer = [byte[]]::new($length)
[System.Random]::new().NextBytes($buffer)
$buffer | Set-Content ".\after.txt" -Encoding Byte -Force
