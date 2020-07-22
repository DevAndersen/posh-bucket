function global:EncodeB64([string]$String)
{
	return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
}

function global:DecodeB64([string]$Base64String)
{
	return [System.Text.Encoding]::UTF8.GetString(([Convert]::FromBase64String($Base64String)))
}

function global:InvokeB64([string]$Base64String)
{
	iex (DecodeB64 -Base64String $Base64String)
}
