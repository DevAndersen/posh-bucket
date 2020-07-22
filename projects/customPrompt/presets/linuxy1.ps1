Reset-PromptOptions -SkipSaving

$PromptOptions.General.PathStyle = "&f7"
$PromptOptions.General.DriveStyle = '&f7$1:'
$PromptOptions.Clock.Enabled = $false
$PromptOptions.Identity.Enabled = $true
$PromptOptions.Identity.Text = '"&fa$(GetUsername)@$(GetHostName) "'
$PromptOptions.Git.GitIndicator = ""
$PromptOptions.Suffix.NormalUser = "&ff$"
$PromptOptions.Suffix.PrivilegedUser = "&ff#"

Write-Host "Reminder: If you want these changes to persist, use the command 'Save-PromptOptions'." -ForegroundColor Green
