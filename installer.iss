[Setup]
AppName=up_police_hrms
AppVersion=1.0
DefaultDirName={pf}\up_police_hrms
DefaultGroupName=up_police_hrms
OutputDir=C:\Users\Rachit Chauhan\Desktop
OutputBaseFilename=up_police_hrms-Setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create Desktop Shortcut"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\up_police_hrms"; Filename: "{app}\up_police_hrms.exe"
Name: "{autodesktop}\up_police_hrms"; Filename: "{app}\up_police_hrms.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\up_police_hrms.exe"; Description: "Launch App"; Flags: nowait postinstall skipifsilent
