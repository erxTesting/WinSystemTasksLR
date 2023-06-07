::set logTaskManager=D:\inetpub\wwwroot\systemTasks\taskManager.log
set logTaskManager=D:\NFT\systemTasks\taskManager.log

echo %DATE% %TIME%>>%logTaskManager%
rem doSysReport.bat D:\inetpub\wwwroot\doSysReport.html
doSysReport.bat D:\NFT\systemTasks\doSysReport.html


set min=%time:~3,2%
if %min% GTR 30 echo %time% min GTR 30>>%logTaskManager%
pause
exit
rem EVENTCREATE /T INFORMATION /L APPLICATION /ID 100 /D "ERX taskManager did something"
