# About mpcmdrun-restore&#46;bat ( MpCmdRun.exe -restore )
This tool is a batch file to restore all quarantined items from the "Quarantine" folder of Microsoft Defender provided by a user.
You can also restore locally quarantined items.
&nbsp;  
### <span style="color:pink;font-weight:bold">&#9635;&nbsp;&nbsp;Important notice</span>
- This tool requires administrator privileges to run. (Required to run MpCmdRun.exe)  
**Automatically restart batch as administrator (-Verb runas).**  
**At that time, a User Account Control (UAC) warning screen will be displayed.**  
- **Dirty "Quarantine" folder of Microsoft Defender.**  
That's why I recommend using a virtual environment.
&nbsp;
### &#9635;&nbsp;&nbsp;Non-working environment
I don't think it works in all environments because it is affected by OS versions, other antivirus products and etc.
- <span style="color:pink;font-weight:bold">Microsoft Defender is turned off</span>
  - Other antivirus products are installed
  - Flare-vm is installed
- If the "Quarantine" folder has been changed from its default location, the code must be modified.
- <span style="color:pink;font-weight:bold">Scripts must have CRLF line endings (eol=CRLF).</span>
- Be careful with strings in file paths!  
<span style="color:pink;font-weight:bold">Drag and drop does not work well if the file path contains commas (,), semicolon (;) or equal sign (=).</span>
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
cd vtscan
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
