# When you need binding redirects in the VS repo updated to match
# assemblies that you build here, remove the "return" statement
# and update the hashtable below with the T4 macro you'll use for
# your libraries as defined in the src\ProductData\AssemblyVersions.tt file.

$nbgv = & "$PSScriptRoot\..\Get-nbgv.ps1"
[string]::join(',',(@{
    ('MicrosoftServiceHubFrameworkVersion') = & { (& $nbgv get-version --project "$PSScriptRoot\..\..\src\Microsoft.ServiceHub.Framework" --format json | ConvertFrom-Json).AssemblyVersion };
}.GetEnumerator() |% { "$($_.key)=$($_.value)" }))
