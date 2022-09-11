@echo off
rem ===========================================================================
rem.
rem Description:
rem   This tool is a batch file to restore all quarantined items 
rem   from the Quarantine folder of Microsoft Defender provided by a user.
rem   This tool requires administrator privileges to run.
rem.
rem Usage:
rem   Drop 3 folders (Entries, ResourceData, Resources) or a folder
rem   containing 3 folders onto the batch icon. The restoration folder
rem   is generated in the same folder as the batch file.
rem.
rem   NOTE: - Line endings must be CRLF (eol=CRLF).
rem         - Drag and drop does not work well if the file path
rem           contains commas (,), semicolon (;) or equal sign (=).
rem         - Microsoft Defender must be turned on.
rem.
rem Author:
rem   ikmt
rem.
rem Test environment:
rem   OS: windows 10 1809
rem       - Windows Defender turned on
rem       - No other Antivirus is installed
rem   OS: windows 10 1903
rem       - Windows Defender turned on
rem       - No other Antivirus is installed
rem.
rem Changelog:
rem   2022-09-10 ver1.1.1 : check local registry values
rem   2022-09-09 ver1.1.0 : changed the specification to restore local 
rem                         quarantined items if no arguments are specified
rem                       : modified code using subroutines
rem   2022-09-07 ver1.0.0 : release
rem.
rem ===========================================================================
rem Run as administrator
rem ===========================================================================
openfiles > nul 2>&1 
if not "%errorlevel%"=="0" (
	setlocal enabledelayedexpansion
	set arg_list=
	for %%i in (%*) do (
		rem Argument value with quotes removed
		set arg=%%~i
		rem Added !arg:"=! just in case (Remove the double quotes from the path)
		rem Enclose the path stored in a variable in escaped quotes
		set arg_list=!arg_list! \"!arg:"=!\"
	)
	echo Run as administrator
	powershell -command start-process cmd "'/c, \"%~f0\" !arg_list!'" -Verb runas
	endlocal
	exit
)


rem ===========================================================================
rem main process
rem ===========================================================================
rem Local required file and folder
rem # Quarantine
set quarantine_dir_path="%PROGRAMDATA%\Microsoft\Windows Defender\Quarantine"
rem # MpCmdRun.exe
rem Available in 1703 and earlier
set mpcmdrun_exe_path="%ProgramFiles%\Windows Defender\MpCmdRun.exe"
set mpcmdrun_name="MpCmdRun.exe"
rem Available since windows 10 1703
cd "%PROGRAMDATA%\Microsoft\Windows Defender\Platform"
for /r %%i in (*"%mpcmdrun_name:"=%") do (
	rem Multiple files may be found
	rem It will be overwritten each time
	set mpcmdrun_exe_path="%%~i"
)


rem Stores the path of a required folder given as an argument
set entries_dir_path=none
set resourcedata_dir_path=none
set resources_dir_path=none
rem Change current directory to script directory
cd /d %~dp0
rem argc is the number of arguments
set argc=0
for %%i in (%*) do (
	set /a argc=argc+1
)
rem Start message
call:logger START_SCRIPT "%~0"

rem Set enabledelayedexpansion to get errorlevel in if statement
setlocal enabledelayedexpansion
if %argc%==0 (
	rem If no argument, restore local quarantined items
	call:check_local_environment 
	if "!errorlevel!"=="0" call:restore_quarantine_item	
) else (
	rem If one or more arguments are specified,
	rem restore user-provided quarantined items
	call:check_argument %*
	if "!errorlevel!"=="0" call:check_local_environment
	if "!errorlevel!"=="0" call:copy_folder
	if "!errorlevel!"=="0" call:restore_quarantine_item
)
if "!errorlevel!"=="10" call:view_help
endlocal

rem End message
call:logger END_SCRIPT "%~0"
pause
exit


rem /* ************************************************************************
rem ** Subroutine:view_help
rem ** 0 argument:
rem ** Summary:
rem **   View help messages and cheat sheets.
rem ** ***********************************************************************/
:view_help
	call:logger ""
	call:logger " Usage:"
	call:logger ""
	call:logger "   Drop 3 folders (Entries, ResourceData, Resources)"
	call:logger "   or a folder containing 3 folders onto the batch icon."
	call:logger "   This tool requires administrator privileges to run."
	call:logger ""
	call:logger "   NOTE  - Line endings must be CRLF (eol=CRLF)."
	call:logger "         - Drag and drop does not work well if the file path"
	call:logger "           contains commas (,), semicolon (;) or equal sign (=)."
	call:logger "         - Microsoft Defender must be turned on."
	call:logger ""
	call:logger " Cheat sheet:"
	call:logger ""
	call:logger "   [Quarantine]"
	call:logger "     C:\ProgramData\Microsoft\Windows Defender\Quarantine"
	call:logger "       \Entries, \ResourceData, \Resources"
	call:logger ""
	call:logger "   [MpCmdRun.exe]"
	call:logger "     C:\Program Files\Windows Defender\MpCmdRun.exe"
	call:logger "       -Restore [-ListAll] [-Name <name>] [-All]"
	call:logger "                [-FilePath <filePath>] [-Path]"
	call:logger ""
	call:logger "   [Microsoft Defender event]"
	call:logger "     Open [Event Viewer]"
	call:logger "       > [Applications and Services Logs]"
	call:logger "         > [Microsoft]"
	call:logger "           > [Windows]"
	call:logger "             > [Windows Defender]"
	call:logger "               > Double-click on [Operational]"
	call:logger ""
	call:logger "     https://docs.microsoft.com"
	call:logger "       /en-us/microsoft-365/security/defender-endpoint"
	call:logger "         /troubleshoot-microsoft-defender-antivirus"
	call:logger ""

	exit /b 0


rem /* ************************************************************************
rem ** Subroutine:check_local_environment
rem ** 0 argument:
rem ** Summary:
rem **   In your local environment, check if the necessary files exist 
rem **   and if Microsoft Defender is turned on.
rem ** ***********************************************************************/
:check_local_environment
	set return_code=0
	set exist_quarantine=false
	set exist_mpcmdrun=false

	if exist %quarantine_dir_path% set exist_quarantine=true
	if exist %mpcmdrun_exe_path% set exist_mpcmdrun=true
	call:logger CHK_LOCAL_ENV "%exist_quarantine:"=%,%quarantine_dir_path:"=%"
	call:logger CHK_LOCAL_ENV "%exist_mpcmdrun:"=%,%mpcmdrun_exe_path:"=%"

	set exist_file=true
	if "%exist_quarantine%"=="false" set exist_file=false
	if "%exist_mpcmdrun%"=="false" set exist_file=false
	if "%exist_file%"=="false" (
		call:logger E LocalEnvError "Required file does not exist"
		exit /b 10
	)

	rem If the following value is 1, it indicates that Microsoft Defender is turned off
	set regis_DisableAntiSpyware="HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender"
	set value_DisableAntiSpyware=none
	set state_DisableAntiSpyware=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_DisableAntiSpyware%" /v "DisableAntiSpyware" 2^> nul'
	) do (
		set value_DisableAntiSpyware=%%b
		if not "%value_DisableAntiSpyware%"=="none" set state_DisableAntiSpyware=false
	)
	rem Start value
	rem 0 = Boot (Not started)
	rem 1 = System
	rem 2 = Automatic
	rem 3 = Manual (Trigger Start)
	rem 4 = Disabled
	rem Microsoft Defender Boot Driver Service (WdBoot)
	set regis_WdBoot="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot"
	set value_WdBoot=none
	set state_WdBoot=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_WdBoot%" /v "Start" 2^> nul'
	) do (
		set value_WdBoot=%%b
		if "%value_WdBoot%"=="4" set state_WdBoot=false
	)
	rem Microsoft Defender Mini-Filter Driver Service (WdFilter)
	set regis_WdFilter="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter"
	set value_WdFilter=none
	set state_WdFilter=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_WdFilter%" /v "Start" 2^> nul'
	) do (
		set value_WdFilter=%%b
		if "%value_WdFilter%"=="4" set state_WdFilter=false
	)
	rem Microsoft Defender Network Inspection System Driver Service (WdNisDrv)
	set regis_WdNisDrv="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisDrv"
	set value_WdNisDrv=none
	set state_WdNisDrv=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_WdNisDrv%" /v "Start" 2^> nul'
	) do (
		set value_WdNisDrv=%%b
		if "%value_WdNisDrv%"=="4" set state_WdNisDrv=false
	)
	rem Microsoft Defender Network Inspection Service (WdNisSvc)
	set regis_WdNisSvc="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc"
	set value_WdNisSvc=none
	set state_WdNisSvc=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_WdNisSvc%" /v "Start" 2^> nul'
	) do (
		set value_WdNisSvc=%%b
		if "%value_WdNisSvc%"=="4" set state_WdNisSvc=false
	)
	rem Microsoft Defender Service (WinDefend)
	set regis_WinDefend="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend"
	set value_WinDefend=none
	set state_WinDefend=true
	for /f "tokens=2* skip=2" %%a in (
		'reg query "%regis_WinDefend%" /v "Start" 2^> nul'
	) do (
		set value_WinDefend=%%b
		if "%value_WinDefend%"=="4" set state_WinDefend=false
	)
	call:logger CHK_LOCAL_ENV "%state_DisableAntiSpyware%,%value_DisableAntiSpyware%,%regis_DisableAntiSpyware:"=%"
	call:logger CHK_LOCAL_ENV "%state_WdBoot%,%value_WdBoot%,%regis_WdBoot:"=%"
	call:logger CHK_LOCAL_ENV "%state_WdFilter%,%value_WdFilter%,%regis_WdFilter:"=%"
	call:logger CHK_LOCAL_ENV "%state_WdNisDrv%,%value_WdNisDrv%,%regis_WdNisDrv:"=%"
	call:logger CHK_LOCAL_ENV "%state_WdNisSvc%,%value_WdNisSvc%,%regis_WdNisSvc:"=%"
	call:logger CHK_LOCAL_ENV "%state_WinDefend%,%value_WinDefend%,%regis_WinDefend:"=%"

	if "%state_DisableAntiSpyware%"=="false" set exist_file=false
	if "%state_WdBoot%"=="false" set exist_file=false
	if "%state_WdFilter%"=="false" set exist_file=false
	if "%state_WdNisDrv%"=="false" set exist_file=false
	if "%state_WdNisSvc%"=="false" set exist_file=false
	if "%state_WinDefend%"=="false" set exist_file=false
	if "%exist_file%"=="false" (
		call:logger E LocalEnvError "Microsoft Defender Antivairus turned off"
		exit /b 10
	)

	exit /b 0


rem /* ************************************************************************
rem ** Subroutine:check_argument
rem ** 1 argument:%*
rem ** Summary:
rem **   If one or more arguments are specified, 
rem **   check if the required folders exist.
rem ** ***********************************************************************/
:check_argument
	setlocal enabledelayedexpansion
	set num=1
	for %%i in (%*) do (
		set zfill=00
		set seq_num=!zfill!!num!
		call:logger "ARG_POS,VALUE" "!seq_num:~-2!,%%~i"

		rem Get file and folder attributes
		set attr=%%~ai
		rem If it is a directory, go to the following process
		if "!attr:~0,1!"=="d" (
			rem Remove the double quotes from the path
			set dir_path=%%~i
			rem Extract directory name
			set dir_name=%%~ni
			if "!dir_name!"=="Entries" (
				set entries_dir_path=!dir_path!
			)
			if "!dir_name!"=="ResourceData" (
				set resourcedata_dir_path=!dir_path!
			)
			if "!dir_name!"=="Resources" (
				set resources_dir_path=!dir_path!
			)

			cd %%i
			for /r /d %%j in (*Entries,*ResourceData,*Resources) do (
				set dir_name=%%~nj
				if "!dir_name!"=="Entries" (
					set entries_dir_path=%%~j
				)
				if "!dir_name!"=="ResourceData" (
					set resourcedata_dir_path=%%~j
				)
				if "!dir_name!"=="Resources" (
					set resources_dir_path=%%~j
				)
			)
		)
		set /a num=!num!+1
	)
	rem Take the value of a variable out of the routine.
	endlocal & (
		set entries_dir_path=%entries_dir_path%
		set resourcedata_dir_path=%resourcedata_dir_path%
		set resources_dir_path=%resources_dir_path%
	)

	call:logger CHK_DROP_FOLDER "Required folder(Entries     )=%entries_dir_path:"=%"
	call:logger CHK_DROP_FOLDER "Required folder(ResourceData)=%resourcedata_dir_path:"=%"
	call:logger CHK_DROP_FOLDER "Required folder(Resources   )=%resources_dir_path:"=%"

	set return_code=0
	set exist_dirs=true
	if "%entries_dir_path%"=="none" set exist_dirs=false
	if "%resourcedata_dir_path%"=="none" set exist_dirs=false
	if "%resources_dir_path%"=="none" set exist_dirs=false
	if "%exist_dirs%"=="false" (
		call:logger E DropFolderError "Required folder does not exist"
		exit /b 10
	)

	exit /b 0


rem /* ************************************************************************
rem ** Subroutine:copy_folder
rem ** 0 argument:
rem ** Summary:
rem **   Copy the required folders ("Entries","ResourceData","Resources")
rem **   to the specified location.
rem ** ***********************************************************************/
:copy_folder
	rem Extract folder name
	for %%i in (%entries_dir_path%) do set basename=\%%~ni
	rem Remove the double quotes from the path
	set dest_entries_dir_path=%quarantine_dir_path:"=%%basename%
	rem Run copy command, output message redirect to nul
	rem cyclic copy: /exclude:%quarantine_dir_path%
	rem If you add "/exclude:%quarantine_dir_path%", the xcopy command may return code 4
	xcopy "%entries_dir_path%" "%dest_entries_dir_path%" /s /e /h /i /q /r /y > nul 2>&1
	rem Exit codes for xcopy
	rem  0: Files were copied without error
	rem  1: No files were found to copy
	rem  2: The user pressed CTRL+C to terminate xcopy
	rem  4: Initialization error occurred
	rem  5: Disk write error occurred
	set status_entries=%errorlevel%

	for %%i in (%resourcedata_dir_path%) do set basename=\%%~ni
	set dest_resourcedata_dir_path=%quarantine_dir_path:"=%%basename%
	xcopy "%resourcedata_dir_path%" "%dest_resourcedata_dir_path%" /s /e /h /i /q /r /y > nul 2>&1
	set status_resourcedata=%errorlevel%

	for %%i in (%resources_dir_path%) do set basename=\%%~ni
	set dest_resources_dir_path=%quarantine_dir_path:"=%%basename%
	xcopy "%resources_dir_path%" "%dest_resources_dir_path%" /s /e /h /i /q /r /y > nul 2>&1
	set status_resources=%errorlevel%

	call:logger "COPY_STATUS,DST" "%status_entries:"=%,%dest_entries_dir_path:"=%"
	call:logger "COPY_STATUS,DST" "%status_resourcedata:"=%,%dest_resourcedata_dir_path:"=%"
	call:logger "COPY_STATUS,DST" "%status_resources:"=%,%dest_resources_dir_path:"=%"

	set return_code=0
	set status=true
	if not "%status_entries%"=="0" set status=false
	if not "%status_resourcedata%"=="0" set status=false
	if not "%status_resources%"=="0" set status=false
	if "%status%"=="false" (
		call:logger E CommandError "XCOPY command failed to copy"
		exit /b 10
	)

	exit /b 0


rem /* ************************************************************************
rem ** Subroutine:restore_quarantine_item
rem ** 0 argument:
rem ** Summary:
rem **   Restore quarantined items using MpCmdRun.exe.
rem **   Requires administrator privileges to run.
rem ** ***********************************************************************/
:restore_quarantine_item
	rem List all items that were quarantined
	set mpcmdrun_cmd=%mpcmdrun_exe_path% -Restore -ListAll
	call:logger RUN_MPCMDRUN "List all the quarantined items"
	call:logger
	call:logger
	%mpcmdrun_cmd%
	set status_mpcmdrun=%errorlevel%
	call:logger
	call:logger
	call:logger "STATUS,COMMAND" "%status_mpcmdrun:"=%,%mpcmdrun_cmd:"=%"
	if not "%status_mpcmdrun%"=="0" (
		call:logger E CommandError "Microsoft Defender may be turned off"
		exit /b 10
	)

	rem Create restore folder
	rem NOTE:The %time% is displayed in 2 digits with a space
	set date_format=%date:/=%
	set date_format=%date_format: =%
	set time_format=%time::=.%
	set time_format=%time_format: =%
	set restore_path="%~dp0restore_%date_format%_%time_format%"
	set mkdir_cmd=mkdir %restore_path%
	%mkdir_cmd% > nul 2>&1
	set status_md=%errorlevel%
	call:logger "STATUS,COMMAND" "%status_md:"=%,%mkdir_cmd:"=%"
	if not "%status_md%"=="0" (
		call:logger E CommandError "MD command failed to create output directory"
		exit /b 10
	)

	rem Restores all the quarantined items
	set mpcmdrun_cmd=%mpcmdrun_exe_path% -Restore -All -Path %restore_path%
	call:logger RUN_MPCMDRUN "Restores all the quarantined items"
	call:logger
	call:logger
	%mpcmdrun_cmd%
	set status_mpcmdrun=%errorlevel%
	call:logger
	call:logger
	call:logger "STATUS,COMMAND" "%status_mpcmdrun:"=%,%mpcmdrun_cmd:"=%"
	if not "%status_mpcmdrun%"=="0" (
		call:logger E CommandError "Failed to restore quarantined items"
		exit /b 10
	)

	exit /b 0


rem /* ************************************************************************
rem ** Subroutine:logger
rem ** 0 argument:
rem ** 1 argument:msg
rem ** 2 argument:cat msg
rem ** 3 argument:severity cat msg
rem ** Summary:
rem **   Output to the command prompt.
rem **   If no argument, print a newline.
rem ** ***********************************************************************/
:logger
	setlocal enabledelayedexpansion
	set argcount=0
	for %%i in (%*) do (
		set /a argcount=argcount+1
	)

	if "%argcount%"=="1" (
		set severity=I
		set cat=HELP_MESSAGE            '
		set msg=%1
	) else (
		if "%argcount%"=="2" (
			set severity=I
			set cat=%1                 '
			set msg=%2
		) else (
			if "%argcount%"=="3" (
				set severity=%1
				set cat=%2                 '
				set msg=%3
			)
		)
	)

	if "%argcount%"=="0" (
		echo.
	) else (
		set cat=!cat:"=!
		echo %date%-%time%[%severity:~0,1%] [!cat:~0,15!]%msg:~0,-1%
	)
	endlocal

	exit /b
