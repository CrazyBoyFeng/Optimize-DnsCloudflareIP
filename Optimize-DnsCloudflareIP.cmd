@Echo Off
Rem PS1 �ű�������
Rem PS1 �ļ�����ֱ������������Ҫ������
Rem ʹ�ò��� Minimized ��С��ģʽ����
Rem ʹ�ò��� Hidden ����ģʽ����
Rem ���������ᴫ�ݸ� PS1 �ű�
Title %~n0
CD /D "%~dp0"
SetLocal EnableDelayedExpansion
Set Path=%Path%;%SystemRoot%\system32\WindowsPowerShell\v1.0\
If /I "%1"=="Minimized" (
    Shift /1
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -WindowStyle Minimized -File %~dpn0.ps1 -ExitEnd %*
) Else If /I "%1"=="Hidden" (
    Shift /1
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -WindowStyle Hidden -File %~dpn0.ps1 -ExitEnd -ExitError %*
) Else (
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -File %~dpn0.ps1 %*
)
Set ExitCode=!ErrorLevel!
If Not /I "!ExitCode!"=="0" (
    Echo.
    Echo Exit Code: !ExitCode!
)
Exit !ExitCode!