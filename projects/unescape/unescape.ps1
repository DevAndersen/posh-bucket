param
(
    [Parameter(Mandatory, ValueFromPipeline = $true)]
    [string]$Text
)

return [Regex]::Unescape($text).Trim(' ', '"')
