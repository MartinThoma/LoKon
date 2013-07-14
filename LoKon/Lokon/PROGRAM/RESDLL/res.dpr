library Res;

uses WinTypes, WinProcs;

{$S-}
{$R lokonres.RES}

var
  SaveExit: Pointer;
procedure LibExit; far;
begin
  if ExitCode = wep_System_Exit then
  begin
      { System shutdown in progress }
  end else
  begin
      { DLL is unloaded }
  end;
  ExitProc := SaveExit;
end;
begin
  { Durchführung der DLL-Initialisierung }
  SaveExit := ExitProc;     { Speichern des Zeigers auf die alte Terminierungsprozedur }
  ExitProc := @LibExit;     { Installation der Terminierungs-Prozedur LibExit }
end.