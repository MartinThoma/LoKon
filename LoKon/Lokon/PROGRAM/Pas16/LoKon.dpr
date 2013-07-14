program LoKon;

{ Logische Schaltungen unter der Windows-Oberfläche kreieren. }

{ Programmiert
  Version 1.0  vom  22. Februar 1994
    (und 1.1)  bis  11. November 1994
               in  500h
               von Heiko Roth
  Version 1.5  vom  15. November 1994
               bis   5. April 1995
               in  200h
               von   Heiko Roth
  Verison 1.6  vom  27. November 1995
               bis   2. April 1996
               in  115h
  Version 1.7  vom  25. April 1996
               bis   7. Juni 1996
               in   30h

  Version 1.8  in   25h

  Version 2.0  vom   9. September 1996
               bis  26. September 1996
               in   13h

  Version 2.x  in  164h

  Version 2.4  vom   1. März 1999
               bis  19. März 1999
               in   60h

   Gesamt      in  1110h                  }

{ Compiler-Direktiven:
    dir      - wechselt in festgelegtes Verzeichnis,
               nur während der Entwicklung verwenden!
    test     - Sharware-Version mit Personalisierung
    showres  - zeigt freie Resourcen in Prozent an
    osc      - Oszilloskop
    elewin   - Editieren von Element-Dateien
    ROMRAM   - mit ROM und RAM
    PLA      - mit PLA
    layele   - Makro
    full     - voll ausgebaut
    small    - Abgespeckte Version (Funktioniert noch nicht!)
    mini     - ganz klein
    pleasetype-Please Type Zuffalszahl bei Start in Shareware
    undo     - Undo/Redo Funktionalität
    debug    - Debugdatei erzeugen
}

uses
  WinTypes,
  WinProcs,
  OWindows,
  Bitmap in 'BITMAP.PAS',
  Connect in 'CONNECT.PAS',
  ConNode in 'CONNODE.PAS',
  EleFile in 'ELEFILE.PAS',
  EleItem in 'ELEITEM.PAS',
  Element in 'ELEMENT.PAS',
  EleWin in 'ELEWIN.PAS',
  Elewinch in 'ELEWINCH.PAS',
  Graphic in 'GRAPHIC.PAS',
  Impulse in 'IMPULSE.PAS',
  Item in 'ITEM.PAS',
  ItemText in 'ITEMTEXT.PAS',
  LayWin in 'LAYWIN.PAS',
  LK_Const in 'LK_CONST.PAS',
  MacroWin in 'MACROWIN.PAS',
  MainWin in 'MAINWIN.PAS',
  OscWin in 'OSCWIN.PAS',
  OWinEx in 'OWINEX.PAS',
  Paint in 'PAINT.PAS',
  PLA in 'PLA.PAS',
  ROMRAM in 'ROMRAM.PAS',
  ScrolOrg in 'SCROLORG.PAS',
  Switch in 'SWITCH.PAS',
  Tick in 'TICK.PAS',
  ZeroOne in 'ZEROONE.PAS';

{ ------ tLoKonApp ------------------------------------------------------ }

type
  pLoKonApp = ^tLoKonApp;
  tLoKonApp = object (tApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
    function IdleAction: Boolean; virtual;
  end;

procedure tLoKonApp.InitMainWindow;
begin
  MainWindow := New(pMainWindow, Init);
end;

procedure tLoKonApp.InitInstance;
begin
  inherited InitInstance;
  HAccTable := LoadAccelerators(hRes, 'MAINACC');
end;

function tLoKonApp.IdleAction: Boolean;
begin
  if xRedrawSpeedbar
  then begin
    DrawMenubar(hMainWin);
    xRedrawSpeedbar := false;
  end;
  IdleAction := true;
end;

{ ------ LoKon ---------------------------------------------------------- }

begin
{$ifdef debug}
  Assign(debugLogFile, 'c:\lokon\log.txt');
  Rewrite(debugLogFile);
  writeln(debugLogFile, 'LoKon debug session');
  writeln(debugLogFile, 'lokon@rothsoft.de');
{  Close(debugLogFile);}
{$endif}

  { Initialisierung }
  DrawPen := CreatePen(ps_Solid, 1, co_black);
  RasterPen := CreatePen(ps_Solid, 1, co_gray);
  InPen := CreatePen(ps_Solid, 1, co_red);
  OutPen := CreatePen(ps_Solid, 1, co_green);
  ConPtPen := CreatePen(ps_Solid, 1, co_green);
  OnPenCol := CreatePen(ps_Solid, 1, co_red);
  OffPenCol := CreatePen(ps_Solid, 1, co_black);
  OnPenBW := CreatePen(ps_Solid, 3, co_black);
  OffPenBW := CreatePen(ps_Solid, 1, co_black);
  DelPen := CreatePen(ps_Solid, 3, co_white);
{$ifdef layele}
  StPen := CreatePen(ps_Solid, 1, co_red);
{$endif}
  OnPen := OnPenCol;
  OffPen := OffPenCol;
  TiltPen := CreatePen(ps_Solid, 1, co_red);
  BkBrush := CreateSolidBrush( GetSysColor( COLOR_BTNFACE ) );
{$ifdef osc}
  OscTextColor := RGB(63,63,63);
  OscPen := CreatePen( ps_Solid, 1, co_black );
  OscTextCol2 := RGB(0, 0, 0);
{$endif}

  { ClipBoardFormate registrieren. }
  cf_Layout := RegisterClipboardFormat('LoKon: Layout');
  cf_Element := RegisterClipboardFormat('LoKon: Element');
  cf_Graphic := RegisterClipboardFormat('LoKon: Graphic');

  { Programm }
  Application := New(pLoKonApp, Init('LoKon V2.2'));
  Application^.Run;
  Dispose(Application, Done);

  { LOKONRES.DLL freigeben. }
  FreeLibrary(hRes);

  { Deinitialisierung }
  DeleteObject(DrawPen);
  DeleteObject(RasterPen);
  DeleteObject(InPen);
  DeleteObject(OutPen);
  DeleteObject(ConPtPen);
  DeleteObject(OnPenCol);
  DeleteObject(OffPenCol);
  DeleteObject(OnPenBW);
  DeleteObject(OffPenBW);
  DeleteObject(DelPen);
  DeleteObject(TiltPen);
  DeleteObject(BkBrush);
{$ifdef layele}
  DeleteObject(StPen);
{$endif}
{$ifdef osc}
  DeleteObject(OscPen);
{$endif}

  { Switch.Pas }
  Dispose(SwitchOn, Done);
  Dispose(SwitchOff, Done);
end.
