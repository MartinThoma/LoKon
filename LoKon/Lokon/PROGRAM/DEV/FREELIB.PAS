uses
  Objects,
  Strings,
  Wintypes, WinProcs,
  OWindows, ODialogs,
  CommDlg;
var
  hRes : tHandle;
begin
  hRes := LoadLibrary('LOKONRES.DLL');
  FreeLibrary(hRes);
  FreeLibrary(hRes);
  FreeLibrary(hRes);
end.