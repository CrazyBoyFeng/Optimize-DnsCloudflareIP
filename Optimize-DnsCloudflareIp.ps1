#����ȥ��Ϊ�ƽ�����̨����һ��A��¼��AAAA��¼��
$domain = "�����������������������"
$zone_id = "����ID������̨�ɲ飩"
$account = "�û��˻�"
$password = "�û�����"

Set-Location -Path $PSScriptRoot

function Get-IP {
    "Domain name: $domain"
    $script:ip = [System.Net.Dns]::GetHostAddresses($domain)[0].IPAddressToString
    If (!$ip) {
        "Can not get the IP of $domain"
        Exit 1
    }
    "Current IP: $ip"
    If ($ip.Contains(".")) {
        Test-IPv4
    }
    ElseIf ($ip.Contains(":")) {
        Test-IPv6
    }
    Else {
        Exit 2
    }
    Get-Best
}

function Test-IPv4 {
    Search-RecordsetId
    Copy-Item ip.txt ip.tmp
    Add-Content -Path ip.tmp -Value "`r`n$ip/32"
    ""
    &".\CloudflareST.exe" -tl 500 -sl 0.1 -p 0 -f ip.tmp
    Remove-Item ip.tmp
}

function Test-IPv6 {
    Search-RecordsetId
    Copy-Item ipv6.txt ipv6.tmp
    Add-Content -Path ipv6.tmp "`r`n$ip/128"
    ""
    &".\CloudflareST.exe" -p 0 -ipv6 -f ipv6.tmp
    Remove-Item ipv6.tmp
}

function Get-Token {
    #��¼
    If ($headers) {
        #�ǿ�
        Return
    }
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
                        "name": "$account"//IAM�û������˺���
                    },
                    "name": "$account",//IAM�û���
                    "password": "$password"//IAM�û�����
                }
            }
        },
        "scope": {
            "domain": {
                "name": "$account"//IAM�û������˺���
            }
        }
    }
}
"@
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "https://iam.myhuaweicloud.com/v3/auth/tokens?nocatalog=true" -ContentType "application/json" -Method POST -Body $body
        $token = $response.Headers["X-Subject-Token"]
        If ($token) {
            $script:headers = @{"X-Auth-Token" = $token }
        }
    }
    catch {
        "`r`nAuth: $_.Exception"
        Exit 11
    }
    If ($headers) {
        "`r`nAuth as $account successful"
    }
    Else {
        "`r`nAuth as $account failed"
        Exit 12
    }
}

function Search-RecordsetId {
    #����ip��Ӧ�ļ�¼��id
    Get-Token
    $response = Invoke-RestMethod -Uri "https://dns.myhuaweicloud.com/v2.1/recordsets?name=$domain&records=$ip" -Headers $headers
    $script:recordset_id = $response.recordsets[0].id
    If (!$recordset_id) {
        #��
        "`r`nNo valid recordsets with $ip for $domain. If it has been updated just now, please wait until it takes effect."
        Exit 21
    }
}

function Get-Best {
    $script:best = (Import-CSV result.csv)[0].psobject.properties.value[0]
    If (!$best) {
        "`r`nCan not get the best Cloudflare IP"
        Exit 31
    }
    "`r`nBest Cloudflare IP: $best"
    If ("$ip" -eq "$best") {
        Exit
    }
    Update-IP
}

function Update-IP {
    Get-Token
    $body = @"
{
    "records": ["$best"]
}
"@
    try {
        $response = Invoke-RestMethod -Uri "https://dns.myhuaweicloud.com/v2.1/zones/$zone_id/recordsets/$recordset_id" -Headers $headers -Method PUT -Body $body
        $response | Out-File -FilePath recordset.txt
        $response
    }
    catch {
        "`r`nRecordset: $_.Exception"
        Exit 41
    }
}

Get-IP
Exit