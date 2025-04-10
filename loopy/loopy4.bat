@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM.-- Version History --
REM         XX.XXX           YYYYMMDD Author Description
::==Originaly v09.14 for vugen12.02, now Loopy v0.1 remake
SET version=0.001-beta  &rem 20150722 erx    initial version, providing the framework
SET version=0.002-beta  &rem 20150723 erx    Added output parsing and persistant variables
SET version=0.003-beta  &rem 20150928 erx    Added view file list in CMD window
REM !! For a new version entry, copy the last entry down and modify Date, Author and Description
SET version=%version: =%

REM.-- Set the window title 
SET title=%~n0
TITLE %title%

set FilePersist=%~dpn0+.cmd&     rem --define the filename where persistent variables get stored
set		dataGroup_choice=,dev,qa,uat,prod1,prod2,
call:setPersist dataGroup=uat
set		loppyEditor_choice=,notepad,
call:setPersist loppyEditor=notepad
set		loopyList_choice=,scripts,
call:setPersist loopyList=scripts
set		fileOpen_choice=,output.txt,vuser_init.c,vuser_end.c,Action.c,
call:setPersist fileOpen=output.txt
set		loopySvr_choice=,r2512587a230,psin0p280,r2512587a230,r2513967a211,vsin2u859,
call:setPersist loopySvr=r2512587a230
::color 3F
::mode con:cols=60 lines=25
if "%VUGEN_PATH_REMOTE%"=="" set VUGEN_PATH_REMOTE=C:\Program Files (x86)\HP\LoadRunner

rem.--read the persistent variables from storage
call:restorePersistentVars "%FilePersist%"

::call %~n0.init.bat

:menuLOOP
cls
echo.
echo.= Menu =================================================
echo.
for /f "tokens=1,2,* delims=_ " %%A in ('"findstr /b /c:":init_" "%~f0""') do echo.  %%B  %%C
set action=
echo.&set /p action=Make a choice or hit ENTER to quit: ||(
    call:savePersistentVars "%FilePersist%"&   rem --save the persistent variables to the storage
    goto:eof
)

call:init_%action%
for /f "eol=; tokens=*" %%i in (%loopyList%) do (	call:loop_%action% "%%~fi" "%%~nxi" )
::%%~fi	fully qualified path name
::%%~nxi	to a file name and extension only
::PsExec help, use System account -s, don't load profile -e, set working directory -w, don't wait for process to terminate -d
goto:menuLOOP

::Sample format for loopyList file of scripts-
::E:\PE\Script\LR\Live\PageNavigation
::E:\PE\Script\LR\Live\Search_Script
::

:init_Change:

:init_0   The list file used         : '!loopyList!'
dir /d /b *.
set /p loopyList=Press enter to accept or type new name of file (current file "%loopyList%"): 
:loop_0
goto:eof

:init_1   Edit script list
start "edit list" %loppyEditor% "%loopyList%."
:loop_1
:loop_2
:loop_3
goto:eof

:init_2   View script list active lines
start "view list" cmd /k "type %loopyList%. | find /v /n ^";^" "
goto:eof

:init_3   The remote server          : '!loopySvr!'
set /p loopySvr=Please enter remote server to run in psin0p280, r2512587a230, r2513967a211, vsin2u859. (current "%loopySvr%")..: 
goto:eof

:init_
:init_Options:

:init_D   Swap the dat files         : '!dataGroup!'
set /p dataGroup=Please enter dat file group to work in "dev", "uat", or "int" (current "%dataGroup%")...: 
goto:eof
:loop_D
copy %~1\*.dat.%dataGroup% %~1\*.
goto:eof

:init_L   Locally run LR scripts
goto:eof
:loop_L
::psexec \\%COMPUTERNAME% -e cmd /c dir
::new	if /i "%action%"=="L" start "executing %~2 script" /min cmd /c "%VUGEN_PATH%bin\mmdrv.exe" -usr "%%~si\%~2.usr" -drv_log_file "%%~si\mdrv.log" -qt_result_dir "%%~si\result1" -out "%%~si\" 
::start "executing %~2 script" /min cmd /c "%VUGEN_PATH%bin\mmdrv.exe" -usr "%%~si\%~2.usr" -qt_result_dir "%%~si\result1"
::start "executing %~2 script" /min cmd /k "%VUGEN_PATH%bin\mmdrv.exe" -usr "%~1\%~2.usr" -qt_result_dir "%~1\result1"
"%VUGEN_PATH%bin\mmdrv.exe" -usr "%~1\%~2.usr" -qt_result_dir "%~1\result1"
pause
goto:eof

:init_M   Locally run LR scripts
SET ITER=2
goto:eof
:loop_M
echo "%VUGEN_PATH%bin\mdrv.exe" -usr "%~1\%~2.usr" -host %loopySvr% -loop %ITER%
"%VUGEN_PATH%bin\mdrv.exe" -usr "%~1\%~2.usr" -host %loopySvr% -loop %ITER%
::mdrv -usr "C:\Source\ERX\Google\Google.usr" -host psin0p280 -loop 2 -out c:\Temp\lrtest
:: -qt_result_dir "%~1\result1"
pause
goto:eof


:init_R   Remotely run LR scripts    : requires PsExec.exe
if /i "%ERX_PASS%"=="" set /p ERX_PASS=Enter your password for remote %USERDOMAIN%\%USERNAME%: 
cls
goto:eof
:loop_R
psexec \\%loopySvr% -u %USERDOMAIN%\%USERNAME% -p %ERX_PASS% -e -w "%VUGEN_PATH_REMOTE%" -d "%VUGEN_PATH_REMOTE%\bin\mmdrv.exe" -usr "%~1\%~2.usr"  -qt_result_dir "%~1\result1"
::	if /i "%action%"=="R" psexec \\%loopySvr% -u %USERDOMAIN%\%USERNAME% -p %ERX_PASS% -e -w "%VUGEN_PATH_REMOTE%" -d "%VUGEN_PATH_REMOTE%\bin\mmdrv.exe" -usr "%~1\%~2.usr"
::new	if /i "%action%"=="R" psexec \\%loopySvr% -u %USERDOMAIN%\%USERNAME% -p %ERX_PASS% -e -w "%VUGEN_PATH_REMOTE%" -d "%VUGEN_PATH_REMOTE%\bin\mmdrv.exe" -usr "%~1\%~2.usr" -drv_log_file "%~1\mdrv.log" -qt_result_dir "%~1\result1" -out "%~1\" 
goto:eof

:init_V   View the LR result1 report : requires QTReport.exe
goto:eof
:loop_V
start "view %~2 result1" cmd /c "%VUGEN_PATH%bin\QTReport.exe" %~1\result1\Results.qtp
goto:eof

:init_E   Edit the VuGen scripts
goto:eof
:loop_E
start "edit %~2 script" /min "%~1\%~2.usr"
goto:eof

:init_O   File name to open          : '!fileOpen!'
::cls
echo Enter the file name to open for all scripts & echo Examples- output.txt, vuser_init.c, vuser_end.c, Action.c, etc.
set /p fileOpen=(current "%fileOpen%"): 
goto:eof
:loop_O
start "open file(s) %fileOpen%" /min cmd /c "%~1\%fileOpen%"
goto:eof

:init_P   Parse output.txt
goto:eof
:loop_P
::start "open file(s) output.txt" cmd /k 
echo = %~2 = = = = = = = = = =	>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "Virtual User Script started at : ">>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "Run-Time Settings file: ">>%TEMP%\%~2.txt
echo.Line Count>>%TEMP%\%~2.txt
type "%~1\output.txt" | find /v /c "&*fake&*">>%TEMP%\%~2.txt
echo.Iteration Count>>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i /c "Starting iteration ">>%TEMP%\%~2.txt
echo.Error Count>>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i /c "): Error ">>%TEMP%\%~2.txt
echo.Warning Count>>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i /c "): Warning">>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i /n "Starting iteration ">>%TEMP%\%~2.txt
echo = Error and Warning Details ============================	>>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "): Error ">>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "): Warning">>%TEMP%\%~2.txt
echo = Parameter Details ====================================	>>%TEMP%\%~2.txt
::type "%~1\output.txt" | find /i "' with parameter delimiters is not a parameter.">>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "): Notify: Saving Parameter "" = "".">>%TEMP%\%~2.txt
type "%~1\output.txt" | find /i "): Notify: Saving Parameter "" = """".">>%TEMP%\%~2.txt
echo ========================================================	>>%TEMP%\%~2.txt

%TEMP%\%~2.txt

goto:eof

:Notes
Add to batch file to prep Live scripts:
Add remote server list-view/edit/select
Add script list-view/edit/select
Add init for prefered tools path and executable for example "editor"
multi tiered menu maybe external key/description
*first tier
**Execute (local, remote, remote server)
**View/Edit (output.txt, *.usr, Action.c, *.c, *.dat, *.h other)
**Scripts (edit, edit list)
**Results (result1, parse output.txt files)

EXAMPLE_Loopy_LIST
;	This is the script list for Eric Berg
;	To construct a list use the command: type nul>usrFiles.txt&for /F "tokens=*" %A in ('dir /s/b *.usr') do @echo %~dpA>>usrFiles.txt
;	To trim the \ off the end and add a ; to the beginning use notepad++ using search "\\\r\n" replace "\r\n;"

.USR file areas of interest
[General]
DefaultCfg=default.cfg
ParameterFile=AribaHomeTab2.prm
LastModifyVer=11.52.0.0
[Actions]
vuser_init=vuser_init.c
Action=Action.c
vuser_end=vuser_end.c
[CfgFiles]
Default Profile=default.cfg
[ExtraFiles]
globals.h=


:Current features
 view/edit list
 change dat files
 change the remote server (current "%vugenSvr%")
 remotely run the scripts (PsExec.exe required)
 present script list
 update script list
 locally run the scripts
 view the result1 report
 edit the script files
 open file(s)
 
 
::-----------------------------------------------------------
:: helper functions follow below here
::-----------------------------------------------------------


:setPersist -- to be called to initialize persistent variables
::          -- %*: set command arguments
set %*
goto:eof


:getPersistentVars -- returns a comma separated list of persistent variables
::                 -- %~1: reference to return variable 
SETLOCAL
set retlist=
set parse=findstr /i /c:"call:setPersist" "%~f0%"^|find /v "ButNotThisLine"
for /f "tokens=2 delims== " %%a in ('"%parse%"') do (set retlist=!retlist!%%a,)
( ENDLOCAL & REM RETURN VALUES
    IF "%~1" NEQ "" SET %~1=%retlist%
)
goto:eof


:savePersistentVars -- Save values of persistent variables into a file
::                  -- %~1: file name
SETLOCAL
echo.>"%~1"
call :getPersistentVars persvars
for %%a in (%persvars%) do (echo.SET %%a=!%%a!>>"%~1")
goto:eof


:restorePersistentVars -- Restore the values of the persistent variables
::                     -- %~1: batch file name to restore from
if exist "%FilePersist%" call "%FilePersist%"
goto:eof


:getNextInList -- return next value in list
::             -- %~1 - in/out ref to current value, returns new value
::             -- %~2 - in     choice list, must start with delimiter which must not be '@'
SETLOCAL
set lst=%~2&             rem.-- get the choice list
if "%lst:~0,1%" NEQ "%lst:~-1%" echo.ERROR Choice list must start and end with the delimiter&GOTO:EOF
set dlm=%lst:~-1%&       rem.-- extract the delimiter used
set old=!%~1!&           rem.-- get the current value
set fst=&for /f "delims=%dlm%" %%a in ("%lst%") do set fst=%%a&rem.--get the first entry
                         rem.-- replace the current value with a @, append the first value
set lll=!lst:%dlm%%old%%dlm%=%dlm%@%dlm%!%fst%%dlm%
                         rem.-- get the string after the @
for /f "tokens=2 delims=@" %%a in ("%lll%") do set lll=%%a
                         rem.-- extract the next value
for /f "delims=%dlm%" %%a in ("%lll%") do set new=%%a
( ENDLOCAL & REM RETURN VALUES
    IF "%~1" NEQ "" (SET %~1=%new%) ELSE (echo.%new%)
)
goto:eof


:initProgress -- initialize an internal progress counter and display the progress in percent
::            -- %~1: in  - progress counter maximum, equal to 100 percent
::            -- %~2: in  - title string formatter, default is '[P] completed.'
set /a ProgressCnt=-1
set /a ProgressMax=%~1
set ProgressFormat=%~2
if "%ProgressFormat%"=="" set ProgressFormat=[PPPP]
set ProgressFormat=!ProgressFormat:[PPPP]=[P] completed.!
call :doProgress
goto:eof


:doProgress -- display the next progress tick
set /a ProgressCnt+=1
SETLOCAL
set /a per=100*ProgressCnt/ProgressMax
set per=!per!%%
title %ProgressFormat:[P]=!per!%
goto:eof


:sleep -- waits some seconds before returning
::     -- %~1 - in, number of seconds to wait
FOR /l %%a in (%~1,-1,1) do (ping -n 2 -w 1 127.0.0.1>NUL)
goto:eof
