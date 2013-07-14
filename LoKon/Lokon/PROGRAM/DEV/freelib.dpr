program Freelib;

uses
  Objects,
  Strings,
  Wintypes, WinProcs,
  OWindows, ODialogs,
  CommDlg;
var
  hRes : tHandle;
begin
  hRes := LoadLibrary('res_de.DLL');
  FreeLibrary(hRes);
  FreeLibrary(hRes);
  FreeLibrary(hRes);
  hRes := LoadLibrary('res_en.DLL');
  FreeLibrary(hRes);
  FreeLibrary(hRes);
  FreeLibrary(hRes);
end.
