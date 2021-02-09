Rem ����������ֱ��д�� Batch ������ģ�������� CMD ��֧�� 2 KB ���ϵı�����Ҳ���Դ��� JSON �� CSV ���ݣ�����ֻ��д�� PowerShell �ű���
@Echo off
Echo ����ȥ��Ϊ�ƽ�����̨����һ������·������A��¼��AAAA��¼��
Set domain=�������
Set zone_id=����ID����̨�ɲ�
Set account=�û��˻�
Set password=�û�����

SetLocal EnableDelayedExpansion
Call :GetIP
Pause

:GetIP
    Echo Domain name: %domain%
    For /f "Skip=1 Tokens=2 Delims=[" %%a In ('Ping %domain% -n 1') Do (
	    For /f "Tokens=1 Delims=]" %%b In ("%%a") Do (
		    Set ip=%%b
	    )
    )
    If "%ip%"=="" (
        Echo Can not get the IP of %domain%
        Exit -B -1
    )
    Echo Current IP: %ip%
    If "%ip%" NEq "%ip:.=%" (
        Call :TestIPv4
    ) Else If "%ip%" NEq "%ip::=%" (
        Call :TestIPv6
    ) Else (
        Exit -B -1
    )
    Call :GetBest
Goto :EOF

:TestIPv4
    Echo ���� IPv4
    Call :SearchRecordsetId
    Copy -Y ip.txt ip.tmp
    Echo.>>ip.tmp
    Echo %ip%/32>>ip.tmp
    Echo.
    CloudflareST.exe -sl 0.1 -p 0 -f ip.tmp
    Echo.
    Del -F -Q ip.tmp
Goto :EOF

:TestIPv6
    Echo ���� IPv6
    Call :SearchRecordsetId
    Copy -Y ipv6.txt ip.tmp
    Echo.>>ip.tmp
    Echo %ip%/128>>ip.tmp
    Echo.
    CloudflareST.exe -p 0 -ipv6 -f ip.tmp
    Echo.
    Del -F -Q ip.tmp
Goto :EOF

:SearchRecordsetId
    echo ���� IP ��Ӧ�ļ�¼�� ID
    Call :GetToken
    Rem TODO
Goto :EOF

:GetBest
Goto :EOF

:UpdateIP
Goto :EOF

:GetToken
    Echo ��¼
    If Defined headers Goto :EOF
    Set body={\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"name\":\"%account%\"},\"name\":\"%account%\",\"password\":\"%password%\"}}},\"scope\":{\"domain\":{\"name\":\"%account%\"}}}}
    curl -iks -X POST -H "Content-Type=application/json;charset=utf8" -d "%body%" https://iam.myhuaweicloud.com/v3/auth/tokens?nocatalog=true -o NUL -D - > headers.txt
    type headers.txt | find "X-Subject-Token: " > header.txt
    findstr "X-Subject-Token" headers.txt > header.txt
    set /p header= < header.txt
    Rem TODO
Goto :EOF