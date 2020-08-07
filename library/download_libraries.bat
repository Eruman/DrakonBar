@Echo OFF
cd library

If "%1"=="" (
set dest=libraries.list
) else (
set dest=%1
)

FOR /F "skip=1 tokens=1,2 " %%i in (%dest%) do (
REM вызов подпрограммы для загрузки файлов
rem echo ... %%i .... %%j
mkdir %%j
set download=%%j
call :M1 %%i
)
REM Вывод результата
rem pause
exit

:M1
SetLocal EnableDelayedExpansion
Set Var=%1
Set Var=!Var:http://=!
Set Var=!Var:/=,!
Set Var=!Var:%%20=?!
Set Var=!Var: =?!
Call :LOOP !var!
Echo.Downloading: %1 to %~p0!FN!
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('%1','%~p0!download!\!FN!')
exit /b

:LOOP
If "%1"=="" GoTo :EOF
Set FN=%1
Set FN=!FN:?= !
Shift
GoTo :LOOP


