Rem PS1 �ű�������
Rem PS1 �ļ�����ֱ�����У�������Ҫ�����������

@Echo Off
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"

If "%1"=="start" (
    Start /Min Cmd /C "%~dpnx0 NoPause"
    Exit
)

Set Path=%Path%;%SystemRoot%\system32\WindowsPowerShell\v1.0\
PowerShell -ExecutionPolicy Unrestricted -NoProfile -File %~dpn0.ps1
Set ExitCode=%ErrorLevel%
Echo.
If "%ExitCode%"=="0" (
    If Not "%1"=="NoPause" (
        Pause
    )
) Else (
    Echo Exit Code: %ExitCode%
    Echo.
    Pause
)
Exit %ExitCode%