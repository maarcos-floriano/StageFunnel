Get-ChildItem -Path . -Filter *.cls | ForEach-Object {
    $metaFile = "$($_.BaseName).cls-meta.xml"
    if (-not (Test-Path $metaFile)) {
        @"
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>
    <status>Active</status>
</ApexClass>
"@ | Out-File -Encoding UTF8 $metaFile
        Write-Host "Criado: $metaFile"
    }
}