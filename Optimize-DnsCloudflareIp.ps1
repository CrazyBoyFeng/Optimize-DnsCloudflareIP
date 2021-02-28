Param([switch]$NoPause,[switch]$NoPauseError)
#����ȥ��Ϊ�ƽ�����̨����һ��A��¼��AAAA��¼��
$domain = "�����������������������"
$zone_id = "����ID������̨�ɲ飩"
$account = "�û��˻�"
$password = "�û�����"

Set-Location -Path $PSScriptRoot

function Error {
    Param ($Message,$Code)
    If ($Message) {
        Write-Error $Message -ErrorId $Code
    }
    If (!$NoPause -And !$NoPauseError) {
        Pause
    }
    Exit $Code
}

function Get-IP {
    Param($Domain)
    Write-Host "Domain name: $Domain"
    $ip = [System.Net.Dns]::GetHostAddresses($Domain)[0].IPAddressToString
    If (!$ip) {
        Error "Can not get the IP of $Domain" 1
    }
    Write-Host "Current IP: $ip"
    Return $ip
}

function Get-Token {
    Param($Account,$Password)
    #��¼
    $body = @"
{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "domain": {
                        "name": "$Account"//IAM�û������˺���
                    },
                    "name": "$Account",//IAM�û���
                    "password": "$Password"//IAM�û�����
                }
            }
        },
        "scope": {
            "domain": {
                "name": "$Account"//IAM�û������˺���
            }
        }
    }
}
"@
    Try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "https://iam.myhuaweicloud.com/v3/auth/tokens?nocatalog=true" -ContentType "application/json" -Method POST -Body $body
        $token = $response.Headers["X-Subject-Token"]
        If (!$token) {
            Error "Auth as $Account failed" 11
        }
        Write-Host "Auth as $Account successful"
        Return $token
    } Catch {
        Error "Auth: $_.Exception" 12
    }
}


function Get-Headers {
    Param($Account,$Password)
    If (!$headers) {
        $token = Get-Token $Account $Password
        $script:headers = @{"X-Auth-Token" = $token }
    }
    Return $headers
}

function Search-RecordsetId {
    Param($Headers,$Domain,$IP)
    #����ip��Ӧ�ļ�¼��id
    $response = Invoke-RestMethod -Uri "https://dns.myhuaweicloud.com/v2.1/recordsets?name=$Domain&records=$IP" -Headers $Headers
    $recordset_id = $response.recordsets[0].id
    If (!$recordset_id) {
        #��
        Error "No valid recordsets with $IP for $Domain. If it has been updated just now, please wait until it takes effect." 21
    }
    Return $recordset_id
}

function Test-IPv4 {
    Param ($IP)
    Copy-Item ip.txt ip.tmp
    Add-Content -Path ip.tmp -Value "`r`n$IP/32"
    &".\CloudflareST.exe" -tl 500 -sl 0.1 -p 0 -f ip.tmp
    Remove-Item ip.tmp
}

function Test-IPv6 {
    Param ($IP)
    Copy-Item ipv6.txt ip.tmp
    Add-Content -Path ip.tmp "`r`n$IP/128"
    &".\CloudflareST.exe" -p 0 -ipv6 -f ip.tmp
    Remove-Item ip.tmp
}

function Quit {
    If (!$NoPause) {
        Pause
    }
    Exit
}

function Get-Best {
    Param($IP)
    $best = (Import-CSV result.csv)[0].psobject.properties.value[0]
    If (!$best) {
        Error "Can not get the best Cloudflare IP" 31
    }
    Write-Host "Best Cloudflare IP: $best"
    If ("$IP" -Eq "$best") {
        Quit
    }
    Return $best
}

function Update-IP {
    Param($Headers,$ZoneId,$RecordsetId,$Best)
    $body = @"
{
    "records": ["$Best"]
}
"@
    try {
        $response = Invoke-RestMethod -Uri "https://dns.myhuaweicloud.com/v2.1/zones/$ZoneId/recordsets/$RecordsetId" -Headers $Headers -Method PUT -Body $body
        Write-Ouput $response | Out-File -FilePath recordset.txt
        Write-Host $response
    }
    catch {
        Error "Recordset: $_.Exception" 41
    }
    Quit
}

$ip = Get-IP $domain
Write-Host ""
$headers = Get-Headers $account $password
Write-Host ""
$recordset_id = Search-RecordsetId $headers $domain $ip
If ($ip.Contains(".")) {
    Test-IPv4 $ip
} ElseIf ($ip.Contains(":")) {
    Test-IPv6 $ip
}
Write-Host ""
$best = Get-Best $ip
Write-Host ""
Update-IP $headers $zone_id $recordset_id $best