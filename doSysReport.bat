::@echo off
::v.0.01
::Removed Disconected user from the LG template output list 
::v.0.02
::Added for loop to allow for future parallel processing

:start
set outTemp=%TEMP%\NFTLRToolssystems.txt

call:header
echo --------------------------------------Controllers------------------------------------ >> %outTemp%
for /F "eol=; tokens=1,2* delims= " %%i in (ctrlList) do call:ctrlTemplate %%i %%j
echo --------------------------------Load Generators-------------------------------------- >> %outTemp%
for /F "eol=; tokens=1,2* delims= " %%i in (lgList) do call:lgTemplate %%i %%j
call:footer
copy /y %outTemp% %1
goto:eof

:header
::echo ^<head^>^<meta http-equiv="refresh" content="30"^>^</head^>^<body bgcolor="#E5E4E2"^>^<font color="#0020C2"^>^<plaintext^>Updated:  %date% %time% > %outTemp%
echo ^<head^>^</head^>^<body bgcolor="#E5E4E2"^>^<font color="#0020C2"^>^<plaintext^>Updated:  %date% %time% > %outTemp%
goto:eof

:footer
echo %date% %time% >> %outTemp%
goto:eof

:ctrlTemplate
echo Controller - %1 %~2 >> %outTemp%
query user /server:%1 | FIND /V "  Disc     " >> %outTemp% 2>&1
echo LoadRunner Controler(s) running >> %outTemp%
query process /server:%1 Wlrun.exe 2>NUL >> %outTemp%
::query process /server:%1 Wlrun.exe 2>NUL | FIND /C "wlrun" >> %outTemp% 2>&1
echo ------------------------------------------------------------------------------------- >> %outTemp%
goto:eof

:lgTemplate
echo LG - %1 %~2 >> %outTemp%
query user /server:%1 | FIND /V "  Disc     " >> %outTemp% 2>&1
echo LoadRunner Agent(s) running >> %outTemp%
query process /server:%1 magentproc.exe 2>NUL >> %outTemp%
::query process /server:%1 magentproc.exe 2>NUL | FIND /C "magentproc" >> %outTemp% 2>&1
echo LoadRunner generator process(s) >> %outTemp%
::query process /server:%1 mmdrv.exe 2>NUL | FIND /C "mmdrv" >> %outTemp% 2>&1
query process /server:%1 mmdrv.exe 2>NUL >> %outTemp%
echo ------------------------------------------------------------------------------------- >> %outTemp%
goto:eof

:wait
::expects a numeric value to wait ~ in minutes
PING 1.1.1.1 -n %1 -w 60000 >NUL
goto:eof
