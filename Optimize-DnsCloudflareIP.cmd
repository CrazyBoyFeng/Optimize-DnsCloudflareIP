@Echo Off
Rem PS1 �ű�������
Rem PS1 �ļ�����ֱ������������Ҫ������
Rem ʹ�ò��� Minimized ��С��ģʽ����
Rem ʹ�ò��� Hidden ����ģʽ����
Rem ���������ᴫ�ݸ� PS1 �ű�
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"
Set Path=!Path!;!SystemRoot!\System32\WindowsPowerShell\v1.0\
If /I "%1"=="Minimized" (
    Shift /1
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -WindowStyle Minimized -File "%~dpn0.ps1" %*
    Set ExitCode=!ErrorLevel!
    If Not "!ExitCode!"=="0" (
        Echo.
        Echo Exit Code: !ExitCode! 1>&2
        Echo.
        Pause
    )
) Else If /I "%1"=="Hidden" (
    Shift /1
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -WindowStyle Hidden -File "%~dpn0.ps1" %* > %~dpn0.Out
    Set ExitCode=!ErrorLevel!
    If Not "!ExitCode!"=="0" (
        Echo.
        Echo Exit Code: !ExitCode! 1>&2
    )
) Else (
    PowerShell -ExecutionPolicy Unrestricted -NoProfile -File "%~dpn0.ps1" %*
    Set ExitCode=!ErrorLevel!
    Echo.
    Pause
)
Exit !ExitCode!