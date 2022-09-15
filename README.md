# About mpcmdrun-restore&#46;bat ( MpCmdRun.exe -restore )
This tool is a batch file to restore all quarantined items from the "Quarantine" folder of Microsoft Defender provided by a user.
You can also restore locally quarantined items.
&nbsp;  
### **&#9635;&nbsp;&nbsp;Important notice**
- This tool requires administrator privileges to run. (Required to run MpCmdRun.exe)  
**Automatically restart batch as administrator (-Verb runas).**  
**At that time, a User Account Control (UAC) warning screen will be displayed.**  
- **Dirty "Quarantine" folder of Microsoft Defender.**  
That's why I recommend using a virtual environment.
&nbsp;
### &#9635;&nbsp;&nbsp;Non-working environment
I don't think it works in all environments because it is affected by OS versions, other antivirus products and etc.
- **Microsoft Defender is turned off**
  - Other antivirus products are installed
  - Flare-vm is installed
- If the "Quarantine" folder has been changed from its default location, the code must be modified.
- **Scripts must have CRLF line endings (eol=CRLF).**
- Be careful with strings in file paths!  
**Drag and drop does not work well if the file path contains commas (,), semicolon (;) or equal sign (=).**
This is because if a command line argument contains a comma, semicolon or equal sign, it will be treated as whitespace.
To work around this issue, you must enclose the path in double quotes and run it from the command line.
&nbsp;
### &#9635;&nbsp;&nbsp;Supported environments ( Test environments )
- OS: windows 10 1809  
  - Windows Defender turned on
  - No other Antivirus is installed
- OS: windows 10 1903  
  - Windows Defender turned on
  - No other Antivirus is installed
&nbsp;  
&nbsp;  
## Installation and Configuration
### 1.&nbsp;&nbsp;Clone this repository
Change the current directory to the location where you want to install and run the following command:
```
git clone https://github.com/1kmt/mpcmdrun-restore.git
cd mpcmdrun-restore
```
If "git clone" fails, you can download it as ZIP. Click "Download ZIP" from the "Code" dropdown.
&nbsp;  
### 2.&nbsp;&nbsp;Check line endings ( eol=CRLF )
Line endings must be CRLF (eol=CRLF).
Please convert with an editor if necessary.
&nbsp;  
### 3.&nbsp;&nbsp;Make sure that Microsoft Defender is turned on
If you have another antivirus product installed, you should uninstall it.
&nbsp;  
&nbsp;    
## Usage
### &#9635;&nbsp;&nbsp;Restore user-provided quarantined items
1. Bring in quarantined items ("Entries", "ResourceData", "Resources" folder) from outside.
1. Drop 3 folders ("Entries", "ResourceData", "Resources") or a folder ("Quarantine", or etc) containing 3 folders onto the batch icon.  
You can also specify it on the command line.
1. The restoration folder is created in the same folder as the batch file.
&nbsp;  
### &#9635;&nbsp;&nbsp;Restore local quarantined items
If no arguments, restore local quarantined items.
1. Double-click on batch file.
1. The restoration folder is created in the same folder as the batch file.
&nbsp;  
### &#9635;&nbsp;&nbsp;For working examples of command line output
- Drop folder onto the batch icon.
```
2022/09/11-16:13:51.46[I] [START_SCRIPT   ]"C:\Users\aaa\Desktop\mpcmdrun-restore.bat
2022/09/11-16:13:51.49[I] [ARG_POS,VALUE  ]"01,C:\Users\aaa\Desktop\Quarantine
2022/09/11-16:13:51.49[I] [CHK_DROP_FOLDER]"Required folder(Entries     )=C:\Users\aaa\Desktop\Quarantine\Entries
2022/09/11-16:13:51.49[I] [CHK_DROP_FOLDER]"Required folder(ResourceData)=C:\Users\aaa\Desktop\Quarantine\ResourceData
2022/09/11-16:13:51.49[I] [CHK_DROP_FOLDER]"Required folder(Resources   )=C:\Users\aaa\Desktop\Quarantine\Resources
2022/09/11-16:13:51.52[I] [CHK_LOCAL_ENV  ]"true,C:\ProgramData\Microsoft\Windows Defender\Quarantine
2022/09/11-16:13:51.52[I] [CHK_LOCAL_ENV  ]"true,C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.2207.7-0\X86\MpCmdRun.exe
2022/09/11-16:13:51.75[I] [CHK_LOCAL_ENV  ]"true,none,HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender
2022/09/11-16:13:51.77[I] [CHK_LOCAL_ENV  ]"true,0x0,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot
2022/09/11-16:13:51.78[I] [CHK_LOCAL_ENV  ]"true,0x0,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter
2022/09/11-16:13:51.78[I] [CHK_LOCAL_ENV  ]"true,0x3,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisDrv
2022/09/11-16:13:51.78[I] [CHK_LOCAL_ENV  ]"true,0x3,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc
2022/09/11-16:13:51.78[I] [CHK_LOCAL_ENV  ]"true,0x2,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend
2022/09/11-16:13:51.87[I] [COPY_STATUS,DST]"0,C:\ProgramData\Microsoft\Windows Defender\Quarantine\Entries
2022/09/11-16:13:51.87[I] [COPY_STATUS,DST]"0,C:\ProgramData\Microsoft\Windows Defender\Quarantine\ResourceData
2022/09/11-16:13:51.87[I] [COPY_STATUS,DST]"0,C:\ProgramData\Microsoft\Windows Defender\Quarantine\Resources
2022/09/11-16:13:51.90[I] [RUN_MPCMDRUN   ]"List all the quarantined items


The following items are quarantined:

ThreatName = Virus:DOS/EICAR_Test_File
      file:C:\Users\aaa\Desktop\eicar.txt quarantined at 2022/09/11 6:24:51 (UTC)


2022/09/11-16:13:51.96[I] [STATUS,COMMAND ]"0,C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.2207.7-0\X86\MpCmdRun.exe -Restore -ListAll
2022/09/11-16:13:51.96[I] [STATUS,COMMAND ]"0,mkdir C:\Users\aaa\Desktop\restore_20220911_16.13.51.96
2022/09/11-16:13:51.96[I] [RUN_MPCMDRUN   ]"Restores all the quarantined items


Restoring the following quarantined items to C:\Users\aaa\Desktop\restore_20220911_16.13.51.96:

ThreatName = Virus:DOS/EICAR_Test_File
   file:C:\Users\aaa\Desktop\eicar.txt quarantined at 2022/09/11 6:24:51 (UTC) was restored


2022/09/11-16:13:52.05[I] [STATUS,COMMAND ]"0,C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.2207.7-0\X86\MpCmdRun.exe -Restore -All -Path C:\Users\aaa\Desktop\restore_20220911_16.13.51.96
2022/09/11-16:13:52.05[I] [END_SCRIPT     ]"C:\Users\aaa\Desktop\mpcmdrun-restore.bat
```
- Double-click on batch file.
```
2022/09/11-15:58:43.63[I] [CHK_LOCAL_ENV  ]"true,none,HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender
2022/09/11-15:58:43.63[I] [CHK_LOCAL_ENV  ]"true,0x0,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot
2022/09/11-15:58:43.63[I] [CHK_LOCAL_ENV  ]"true,0x0,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter
2022/09/11-15:58:43.63[I] [CHK_LOCAL_ENV  ]"true,0x3,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisDrv
2022/09/11-15:58:43.63[I] [CHK_LOCAL_ENV  ]"true,0x3,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc
2022/09/11-15:58:43.66[I] [CHK_LOCAL_ENV  ]"true,0x2,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend
2022/09/11-15:58:43.66[I] [RUN_MPCMDRUN   ]"List all the quarantined items


The following items are quarantined:

ThreatName = Virus:DOS/EICAR_Test_File
      file:C:\Users\aaa\Desktop\eicar.txt quarantined at 2022/09/11 6:24:51 (UTC)


2022/09/11-15:58:43.75[I] [STATUS,COMMAND ]"0,C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.2207.7-0\X86\MpCmdRun.exe -Restore -ListAll
2022/09/11-15:58:43.76[I] [STATUS,COMMAND ]"0,mkdir C:\Users\aaa\Desktop\restore_20220911_15.58.43.75
2022/09/11-15:58:43.76[I] [RUN_MPCMDRUN   ]"Restores all the quarantined items


Restoring the following quarantined items to C:\Users\aaa\Desktop\restore_20220911_15.58.43.75:

ThreatName = Virus:DOS/EICAR_Test_File
   file:C:\Users\aaa\Desktop\eicar.txt quarantined at 2022/09/11 6:24:51 (UTC) was restored


2022/09/11-15:58:43.82[I] [STATUS,COMMAND ]"0,C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.2207.7-0\X86\MpCmdRun.exe -Restore -All -Path C:\Users\aaa\Desktop\restore_20220911_15.58.43.75
2022/09/11-15:58:43.82[I] [END_SCRIPT     ]"C:\Users\aaa\Desktop\mpcmdrun-restore.bat
```
&nbsp;  
&nbsp;    
## Appendix
### &#9635;&nbsp;&nbsp;Microsoft Defender registry keys
- If the following value is 1, it indicates that Microsoft Defender is turned off
  - reg delete "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender" /f
<br /><br />
- Microsoft Defender Boot Driver Service (WdBoot)
  - reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t "REG_DWORD" /d "0" /f
- Microsoft Defender Mini-Filter Driver Service (WdFilter)
  - reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t "REG_DWORD" /d "0" /f
- Microsoft Defender Network Inspection System Driver Service (WdNisDrv)
  - reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\WdNisDrv" /v "Start" /t "REG_DWORD" /d "3" /f
- Microsoft Defender Network Inspection Service (WdNisSvc)
  - reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\WdNisSvc" /v "Start" /t "REG_DWORD" /d "3" /f
- Microsoft Defender Service (WinDefend)
  - reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\WinDefend" /v "Start" /t "REG_DWORD" /d "2" /f
### &#9635;&nbsp;&nbsp;Microsoft Defender tasks
- Windows Defender Cache Maintenance
  - schtasks /change /tn "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /enable
- Windows Defender Cleanup
  - schtasks /change /tn "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /enable
- Windows Defender Scheduled Scan
  - schtasks /change /tn "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /enable
- Windows Defender Verification
  - schtasks /change /tn "Microsoft\Windows\Windows Defender\Windows Defender Verification" /enable
