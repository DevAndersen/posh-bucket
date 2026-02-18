param
(
    [string]$Path
)

Get-ChildItem -Path $Path -Filter "*.cs" -Recurse | ForEach-Object { Get-Content -Path $_ } | Where-Object { $_ -match "^Using .+;" } | Group-Object | Sort-Object -Property Count -Descending | Format-Table -Property Count,Name -AutoSize
