param(
[Parameter()]
[String] $query = "type:ticket commenter:me updated>8hours"
)

$configDir = Split-Path -Parent $PROFILE

if (!(Test-Path $configDir)) {
    New-Item -Force -ItemType "directory" $configDir | Out-Null
}

$credFile = Join-Path $configDir zendesk_login.json

if (Test-Path $credFile) {
    $in = Get-Content -Path $credFile | ConvertFrom-Json
    $secure = ConvertTo-SecureString $in.Password -ErrorAction Stop
    $cred = New-Object -TypeName PSCredential $in.username,$secure
} else {
    $zduser = Read-Host 'Your Zendesk username'
    $cred = Get-Credential -UserName $zduser -Message 'Your Zendesk password'
    $secure = $cred | Select Username,@{Name="Password";Expression = { $_.password | ConvertFrom-SecureString }}
    $secure | ConvertTo-Json | Set-Content $CredFile
    echo "Zendesk credentials securely saved to $credFile"
}

$SearchUri = 'https://cargas.zendesk.com/api/v2/search.json'
$RequestBody = @{
    query = $query
}

$results = Invoke-RestMethod -Authentication Basic -Credential $cred -ContentType 'application/json' -Uri $SearchUri -Body $RequestBody

$results.results | select id, subject, updated_at
