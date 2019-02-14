# PowerShell script to build JwPlayer API v1 url
# Niels Illem
# 12 feb 2019
#
# Source Hash function: https://gallery.technet.microsoft.com/scriptcenter/Get-StringHash-aa843f71

Function Get-StringHash([String] $String,$HashName = "MD5")
{
    $StringBuilder = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
    [Void]$StringBuilder.Append($_.ToString("x2"))
    }
$StringBuilder.ToString()
}

$api_key = "********"          # your API key from your JWPlayer > Account page
$api_secret = "**************" # your API secret form your JWPlayer > Account page
$api_nonce = 21121872          # a random number containing 8 digits
$api_format = "json"           # choose json or xml
$result_limit = 1000           # Specifies maximum number of videos to return. Default is 50. Maximum result limit is 1000.
$result_offset = 0             # Specifies how many videos should be skipped at the beginning of the result set. Default is 0.

$api_timestamp=(New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date -Format F)).TotalSeconds

$myvar = "api_format=$api_format&api_key=$api_key&api_nonce=$api_nonce&api_timestamp=$api_timestamp&result_limit=$result_limit&result_offset=$result_offset$api_secret"

$api_signature = Get-StringHash $myvar "SHA1"

$uri = "https://api.jwplatform.com/v1/videos/list/?api_format=$api_format&api_key=$api_key&api_nonce=$api_nonce&api_timestamp=$api_timestamp&result_limit=$result_limit&result_offset=$result_offset&api_signature=$api_signature"

$data = Invoke-WebRequest $uri | ConvertFrom-Json

$result = @()
 
foreach ($item in $data.videos) {
    $PSObject = New-Object -TypeName PSObject
    $PSObject | Add-Member -Name 'title' -MemberType Noteproperty -Value $item.title
    $PSObject | Add-Member -Name 'key' -MemberType Noteproperty -Value $item.key
    
    $result += $PSObject
}

$result | export-csv -Path c:\temp\jwexport-$result_offset-$result_limit.csv -NoTypeInformation
