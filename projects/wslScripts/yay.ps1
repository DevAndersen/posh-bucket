# Runs yay (AUR helper).
param
(
    [string]$Arguments
)

if ([string]::IsNullOrWhiteSpace($Arguments))
{
    wsl yay
}
else
{
    wsl -e yay $Arguments
}
