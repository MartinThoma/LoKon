unit LK_Const;
{$I define.inc}

interface

uses
  WinDos,
  Objects,
  Strings,
  Wintypes, WinProcs,
  OWindows, ODialogs,
  CommDlg;

{$R MAIN}

{$ifdef debug}
var
  debugLogFile : TEXT;

procedure appendLog(s : String);
{procedure appendLog(s : pChar);}
{$endif}

type
  tFontData = record
    Height, Width : Shortint;
    Direct : Integer;
    FontNr, FontFlag : Byte;
  end;

procedure StoreInt(var t : Text; name : String; val : longint);
procedure StoreInt_(var t : Text; val : longint);
procedure StoreByte(var t : Text; name : String; val : byte);
procedure StoreByte_(var t : Text; val : byte);
procedure StoreBool(var t : Text; name : String; val : boolean);
procedure StoreBool_(var t : Text; val : boolean);
procedure StorePoint_(var t : Text; val : tPoint);
procedure StoreFontData_(var t : Text; fontData : tFontData);

const
    riConnection = $1000;
    riConNode = $1001;
    riEleItem = $1002;
    riChapEle = $1003;
    riElement = $1004;
    riTabEle = $1005;
    riImpulse = $1006;
    riSwitch = $1007;
    riItemText = $100b;
    riItemBitmap = $100c;
    riTick = $100d;
    riPLA = $100e;
    riBoolEle = $1020;
    riMacroEle = $1021;
    riZero = $1024;
    riOne = $1025;
    riOscCon = $1030;
    riROM = $1055;
    riInMacroItem = $1060;
    riOutMacroItem = $1061;
    riStateMacroItem = $1062;

{$ifdef test}
const
  personlength = 60;
  person : array [0..personlength] of char = '';
  shareware : boolean = true;
  codel : integer = 0;
  codeh : integer = 0;
  expired : boolean = false;
var
  startdate : double;
  daystogo : integer;
{$endif}

const
  LoKon_Version_length = 20;
  LoKon_Version : array [0..LoKon_Version_length] of char = '';
  LoKon_Date_length = 10;
  LoKon_Date : array [0..LoKon_Date_length] of char = '';

const
  xRedrawSpeedbar : Boolean = true;

type
  pIntegerArray = ^tIntegerArray;
  tIntegerArray = array [0..$7ffe] of Integer;

  pPointArray = ^tPointArray;
  tPointArray = array [0..$3ffe] of tPoint;

  pBooleanArray = ^tBooleanArray;
  tBooleanArray = array [0..$fff0] of Boolean;

  pPointerArray = ^tPointerArray;
  tPointerArray = array [0..$3ffe] of Pointer;

  pCharArray = ^tCharArray;
  tCharArray = array [0..$fff0] of Char;

var
  hRes : tHandle;

const
  { Paint-Befehle. }
  ds_Type         = $00ff; { Befehlsmaske. }
  ds_Filled       = $0001; { Gef�llt-Maske. }
  ds_TypeF        = $00fe; { Befehlsmaske ohne F�llen. }
  ds_Move         = $0000;
  ds_MoveTo       = $0100;
  ds_Delete       = $0001;
  ds_Line         = $0002;
  ds_LineTo       = $0102;
  ds_Text         = $0003;
  ds_Polygon      = $0004;
  ds_PolygonF     = $0005;
  ds_PolyPoints   = $0104;
  ds_Rectangle    = $0006;
  ds_RectangleF   = $0007;
  ds_RectSize     = $0106;
  ds_Ellipse      = $0008;
  ds_EllipseF     = $0009;
  ds_EllipseSize  = $0108;
  ds_Chord        = $000a;
  ds_ChordF       = $000b;
  ds_ChordSize    = $010a;
  ds_ChordStart   = $020a;
  ds_ChordEnd     = $030a;
  ds_Block        = $000c;
  ds_Last         = $000d; { Noch f�r drei ds_-Konstanten Platz. }

const
  { Men�befehle. }
  cm_FileOpen     =   10;
  cm_FileSave     =   11;

  cm_FileList     =   12;
  cm_FileListEnd  =   19;
  FileListMax     = cm_FileListEnd - cm_FileList;
  FileListPos     =   12;

  cm_EditCut      =   20;
  cm_EditCopy     =   21;
  cm_EditPaste    =   22;
  cm_DeleteItem   =   25;
  cm_DelAllPt     =   26;
  cm_ItemDlg      =   28;
{$ifdef osc}
  cm_OscRecord    =   29;
{$endif}

{$ifdef undo}
  cm_Undo         =   40;
  cm_Redo         =   41;
{$endif}

  cm_CreateLayWin =  101;
{$ifdef elewin}
  cm_CreateEleWin =  102;
{$endif}
  cm_Print        =  106;
  cm_PrintDlg     =  107;
  cm_FileExport   =  110;
  cm_About        =  111;
{$ifdef test}
  cm_Register     =  112;
{$endif}

  cm_SimStart     =  150;
  cm_SimStop      =  151;
  cm_SimReset     =  152;

{$ifdef osc}
  cm_OscReset     =  153;
  cm_OscResetAll  =  154;
{$endif}

  cm_Gate         =  201;
  cm_ActItem      =  202;
  cm_ConNode      =  203;
  cm_Zero         =  204;
  cm_One          =  205;
  cm_Switch       =  206;
  cm_TickEle      =  207;
{$ifdef ROMRAM}
  cm_ROMRAM       =  208;
{$endif}
  cm_ItemText     =  209;
{$ifdef PLA}
  cm_PLA          =  210;
{$endif}
  cm_SwitchState  =  220;
  cm_TickState    =  221;
{$ifdef PLA}
  cm_PLADelIn     =  222;
  cm_PLADelOut    =  223;
  cm_PLADelAll    =  224;
{$endif}
{$ifdef layele}
  cm_AddOneIO     =  225;
  cm_DelOneIO     =  226;
{$endif}

  cm_Font         =  301;

  cm_Zoom90       =  554;
  cm_Zoom75       =  553;
  cm_Zoom50       =  552;
  cm_ZoomBox      =  555;
  cm_ZoomAll      =  556;
{$ifdef osc}
  cm_OscOptimalH  =  557;
{$endif}
  cm_ZoomAllWin   =  558;

  cm_RasterOff    =  307;
  cm_RasterBig    =  308;
  cm_RasterSmall  =  309;

  cm_RasterFront  =  325;
  cm_RasterBack   =  326;
  cm_ShowInOut    =  330;
  cm_Paint        =  332;

  cm_ToolFirst    =  340;
  cm_Move         = cm_ToolFirst +  $0000;
  cm_Delete       = cm_ToolFirst +  $0001;
  cm_Line         = cm_ToolFirst +  $0002;
  cm_Text         = cm_ToolFirst +  $0003;
  cm_Polygon      = cm_ToolFirst +  $0004;
  cm_PolygonF     = cm_ToolFirst +  $0005;
  cm_Rectangle    = cm_ToolFirst +  $0006;
  cm_RectangleF   = cm_ToolFirst +  $0007;
  cm_Ellipse      = cm_ToolFirst +  $0008;
  cm_EllipseF     = cm_ToolFirst +  $0009;
  cm_Chord        = cm_ToolFirst +  $000a;
  cm_ChordF       = cm_ToolFirst +  $000b;
  cm_ToolLast     = cm_ToolFirst + ds_Last;

  cm_EditImport   =  400;
  cm_ExportBMP    =  401;
  cm_ExportWMF    =  402;
  cm_EditAll      =  412;
  cm_EditDel      =  413;

{$ifdef elewin}
  cm_NewTabEle    =  480;
  cm_NewBoolEle   =  481;
{$ifdef layele}
  cm_NewMacroEle  =  482;
  cm_ShowMacro    =  483;
{$endif}
  cm_NewChap      =  488;
  cm_RenameEle    =  501;
  cm_DelEle       =  502;
  cm_ChangeNr     =  504;
  cm_EleGraphic   =  510;
  cm_EleRegion    =  511;
  cm_GrInOut      =  512;
  cm_EleInOut     =  513;
  cm_EleInit      =  514;
  cm_DelEleInOut  =  515;
{$ifdef layele}
  cm_UpdateEle    =  516;
{$endif}
{$endif}

  cm_EleFiles     =  601;
  cm_LoadOpt      =  602;
  cm_SaveAsOpt    =  603;
  cm_SaveOpt      =  604;
  cm_MessageOn    =  606;
  cm_Tick         =  607;
  cm_Collision    =  608;
  cm_OptUndo      =  609;
  cm_OptROff      =  611;
  cm_OptRBig      =  612;
  cm_OptRSmall    =  613;
  cm_OptRFront    =  614;
  cm_OptRBack     =  615;
  cm_OptShowInOut =  616;
  cm_OptConBW     =  617;
  cm_ResetFileMenu=  618;
  cm_OptFont      =  620;
  cm_OptRasterPos =  621;

  cm_Pos1         =  560;
  cm_Pos5         =  561;
  cm_Pos10        =  562;

  cm_HelpContents =  701;
  cm_HelpContext  =  702;
  cm_HelpOnHelp   =  703;
  CM_HOWTODO      =  704;

  cm_ManuelTick   =  720;

{$ifdef osc}
  cm_OscRename    =  730;
  cm_OscDelete    =  731;
  cm_OscHeight    =  732;
  cm_ShowOscWin   =  735;
  cm_HideOscWin   =  736;
  cm_ShowCircuit  =  737;
  cm_ShowAllOscWin=  738;
  cm_HideAllOscWin=  739;
{$endif}

{$ifdef layele}
  cm_ShowAllMacros=  740;
  cm_HideAllMacros=  741;
{$endif}

  { Hilfe. }
  cs_Index        = $0001;
  cs_EleWin       = $0002;
  cs_LayWin       = $0003;
  cs_Handling     = $0004;
  cs_Info         = $0005;

  { 800-899 in OWinEx benutzt.}

const
  ms_GraphicTool  =  900;

  ms_Position     =  901;

  ms_GetEleFile   =  902;
  ms_LoadFile     =  903;

  ms_ChildMenuPos =  904;

  ms_FileList     =  905;

  ms_SetZoom      =  907;

  ms_DelInsItem   =  910;

  ms_EleWin       =  911;
  ms_IsShown      =  912;

  ms_GetContext   =  914;

  ms_Tick         =  915;

  ms_NewWin       =  916;

  ms_UpdateInfo   =  917;
  ms_UpdatePos    =  918;
  ms_GetInfoStr   =  919;

  ms_Save         =  920;
  ms_SaveAs       =  921;
  ms_Export       =  922;

  ms_Print        =  923;

  ms_NotClose     =  924;

  ms_Speedbar     =  930;

  ms_EndDrag      =  940;

{$ifdef osc}
  ms_OscAddCon    =  950;
  ms_OscIsRecCon  =  951;
  ms_OscDelCon    =  952;
  ms_OscLayPaint  =  953;
  ms_SetupOscWin  =  954;
{$endif}

  ms_ItemIndex    =  955;

  ms_ChildClose   =  960;
  ms_SetCaption   =  961;

{$ifdef layele}
  ms_MacroInOut   =  962;
  ms_NewMacroIO   =  963;
  ms_MacroOutImpulse=964;
  ms_MacroSimReset=  965;
  ms_MacroSimStart=  966;
  ms_MacroSimStop =  967;
  ms_MacroImpulse =  968;
  ms_MacroPaint   =  969;
{$endif}

{$ifdef osc}
  ms_ShowWindow   =  970;
  ms_HideWindow   =  971;
  ms_ShowOscWin   =  972;
  ms_HideOscWin   =  973;
{$endif}

{$ifdef layele}
  ms_ShowMacroWin =  974;
  ms_HideMacroWin =  975;
{$endif}

  ms_ZoomAll      =  976;

  ms_LockSpeedbar =  977;

{$ifdef layele}
  ms_StoreInOut   =  978;
  ms_LoadInOut    =  979;
{$endif}

{$ifdef undo}
  ms_FreeUndo     =  980;
{$endif}

const
  { EleWin-Botschaften. }
  ew_Destroy      = Word(-1);
  ew_EleWinStored = Word(-2);
  ew_NotClose     = Word(-3);

const
  di_DeleteItem   =    1;
  di_InsertItem   =    2;

const
  { Mausaktionen. }
  ls_first        = ds_Last + 1; { Alle ls_xxx NACH den ds_xxx Konstanten ! }
  ls_None         = ls_First +   0; { Keine Aktion. }
  ls_MoveActItem  = ls_First +   1; { ActItem bewegen. }
  ls_MoveActItemB = ls_First +   2; { ActItem bewegen. Linke Maustaste
                                      ist gedr�ckt. }
  ls_MoveActItemC = ls_First +   3; { Ein Element der Schaltung wird ber�hrt. }
  ls_ZoomBox      = ls_First +   4; { ZoomBox: Startpunkt. }
  ls_ZoomBoxB     = ls_First +   5; { ZoomBox: Gr��e. }
  ls_Connection   = ls_First +   6; { Verbinden. }
  ls_ConnectionB  = ls_First +   7; { Keine Verbindung m�glich,
                                      da kein Ein-/Ausgang. }
  ls_ConnectionC  = ls_First +   8; { Keine Verbindung m�glich,
                                      da kein Ein-/Ausgang. }
  ls_ConnectionPt = ls_First +   9; { Punkt auf Verbindung setzen. }
  ls_ConPtMove    = ls_First +  10; { Punkt auf Verbindung bewegen. }
{$ifdef PLA}
  ls_PLAMatrix    = ls_First +  11; { Matrixknoten im PLA �ndern. }
{$endif}
  ls_DeleteConPt  = ls_First +  12; { Punkt auf Verbindung l�schen. }
  ls_DelAllConPt  = ls_First +  13; { Alle Punkte auf Verbindung l�schen. }
  ls_ConMove      = ls_First +  14; { Verbindung anders setzen. }
  ls_ConNode      = ls_First +  15; { Verbindungsknoten. }
  ls_ToggleSwitch = ls_First +  16; { Schalter umschalten. }
  ls_Test         = ls_First +  17; { None-Modus im Test-Modus. }
  ls_MoveInOut    = ls_First +  18; { F�r tInOutPaint. }
  ls_EditSize     = ls_First +  19; { Edit-Bereich festlegen. }
  ls_EditMove     = ls_First +  20; { Edit-Elemente bewegen. }
  ls_EditMoveB    = ls_First +  21; { Edit-Elemente bewegen bei Paste. }

const
  { Werte f�r GetState. }
  lm_MouseMove    =    0;
  lm_LButton      =    1;
  lm_RButton      =    2;
  lm_Connect      =    3;
  lm_First        =  $07;
  lm_Test         =    8;

const
  { HitStatus - Konstanten. }
  HTStatus   = $1000;
  HTSpeedbar = $1001;

const
  { Speedbar }
  SBInsert   = 0;
  SBDelete   = 1;
  SBActivate = 2;
  SBGrayed   = 3;
  SBEnabled  = 4;
  SBActive_  = $0001;
  SBDown_    = $0002;
  SBActive   = $00010000;
  SBDown     = $00020000;

var
  { Clipboard-Formate. }
  cf_Layout,
  cf_Element,
  cf_Graphic : Word;

const
  { Inkrement f�r ms_UpdateInfo. }
  inc_State = 176;

const
  { File-Extension beim Speichern bzw. Export. }
  ext_LAY  =  1;
  ext_ELE  =  2;
  ext_OPT  =  3;
  ext_GRC  =  4;
  ext_WMF  =  5;
  ext_BMP  =  6;
  ext_First = $07;
  ext_FileExport = $40;

const
  extName : array [1..6] of pChar =
    ('LAY', 'ELE', 'INI', 'GRC', 'WMF', 'BMP');

const
  { Konstanten f�r Gr��en und L�ngen. }
  MaxFileNameLen  =  100;
  MaxEleNameLen   =   30;
  StringLen       =  200;
  MaxFontVal      =   60;
  MaxPolyPoints   =  100;
  MinTickTime     =    1;
  MaxTickTime     = 2000;

const
  Font_Precis = 3 {OUT_STROKE_PRECIS};
  Font_Quality = 1 {Draft_Quality};

const
  FontName : array [0..4] of pChar =
    ('Arial', 'Courier New', 'Times New Roman',
     'Symbol', 'Wingdings');

type
  pPosition = ^tPosition;
  tPosition = record
    X, Y : Integer;
    case Boolean of
      False : (Direction : Shortint);
      True : (FontData : tFontData);
  end;

const
  FontDataOpt : tFontData =
    ( Height:7; Width:0;
      Direct:0;
      FontNr:0;
      FontFlag:0 );

const
  xRaster : Shortint = 0; { cm_OptROff, cm_OptRBig, cm_OptRSmall. }
  xRasterFront : Boolean = False; { cm_OptRFront, cm_OptRBack. }
  xShowInOut : Boolean = False; { cm_OptShowInOut. }
  xShowOsc : Boolean = True; { cm_OptShowOsc. }
  xConBW : Boolean = False; { Leitungen dick/d�nn. }
{$ifdef undo}
  xUndo : Boolean = False; { Undo an/aus. }
{$endif}
  RasterPos : Integer = 1; { auf Raster positionieren. }
  xCollision : Boolean = TRUE; { Kollisionsabfrage bei Verschieben
                                 in der Schaltung }

var
  FileStruct : tOpenFileName;

var
  DrawPen,
  RasterPen,
  InPen, OutPen,
  ConPtPen,
  OnPen, OffPen,
  OnPenCol, OffPenCol,
  OnPenBW, OffPenBW,
  DelPen,
{$ifdef layele}
  StPen,
{$endif}
  TiltPen,
  OscPen : hPen;
  OscTextColor,
  OscTextCol2 : tColorRef;
  BkBrush : hBrush;

const
  { Die verwendeten Farben. }
  co_white = $00ffffff;
  co_black = $00000000;
  co_gray  = $00808080;
  co_red   = $000000ff;
  co_green = $00008000;
  co_num = 5; { Anzahl der verwendeten Farben. }

var
  hMainWin : tHandle;

type
  tFileName = array [0..MaxFileNameLen] of Char;
  tEleName = array [0..MaxEleNameLen] of Char;
  tString = array [0..StringLen] of Char;

var
  String0, String1, String2 : tString;

PROCEDURE GetPos(
  VAR Xp, Yp : INTEGER; Xr, Yr : INTEGER; Direction : Shortint);

procedure SwapInteger(var X, Y : Integer);

function LongMin(A, B: LongInt): LongInt;
function LongMax(A, B: LongInt): LongInt;

function SetInOutFont(PaintDC : hDC; Direction : Shortint) : hFont;
procedure DrawInOut(
  PaintDC : hDC; X, Y : Integer;
  Direction : Shortint; Num : Integer);

function LoadString0(Idx : Integer) : pChar;
function LoadString1(Idx : Integer) : pChar;
function LoadString2(Idx : Integer) : pChar;

function getInternCollection : pCollection;

var
  Language : array[0..3] of char;
  HelpFileName : pChar;

implementation

procedure StoreInt(var t : Text; name : String; val : longint);
begin
  write(t, '  ' + name + ' ');
  StoreInt_(t, val);
  writeln(t);
end;

procedure StoreInt_(var t : Text; val : longint);
var
  s : array [0..30] of char;
begin
  wvsprintf(@s, '%li', val);
  write(t, StrPas(s));
end;

procedure StoreByte(var t : Text; name : String; val : byte);
begin
  write(t, '  ' + name + ' ');
  StoreByte_(t, val);
  writeln(t);
end;

procedure StoreByte_(var t : Text; val : byte);
var
  s : array [0..30] of char;
  u : integer;
begin
  u := val;
  wvsprintf(@s, '%u', u);
  write(t, StrPas(s));
end;

procedure StoreBool(var t : Text; name : String; val : boolean);
begin
  write(t, '  ' + name + ' ');
  StoreBool_(t, val);
  writeln(t);
end;

procedure StoreBool_(var t : Text; val : boolean);
begin
  if val
  then write(t, 'true')
  else write(t, 'false');
end;

procedure StorePoint_(var t : Text; val : tPoint);
begin
  StoreInt_(t, val.X);
  write(t, ' ');
  StoreInt_(t, val.Y);
end;

procedure StoreFontData_(var t : Text; fontData : tFontData);
begin
  with fontData
  do begin
    StoreInt(t, 'h', Height);
    StoreInt(t, 'w', Width);
    StoreInt(t, 'd', Direct);
    StoreByte(t, 'fontNr', FontNr);
    StoreByte(t, 'fontFlag', FontFlag);
  end;
end;

{ ------ GetPos --------------------------------------------------------- }

PROCEDURE GetPos(
  VAR Xp, Yp : INTEGER; Xr, Yr : INTEGER; Direction : Shortint);
BEGIN
  CASE Direction and $03 OF
    0 : BEGIN  Xp := +Xr; Yp := +Yr  END;
    1 : BEGIN  Xp := -Yr; Yp := +Xr  END;
    2 : BEGIN  Xp := -Xr; Yp := -Yr  END;
    3 : BEGIN  Xp := +Yr; Yp := -Xr  END;
  END;
END;

{ ------ SwapInteger ---------------------------------------------------- }

procedure SwapInteger(var X, Y : Integer);
var Z : Integer;
begin
  Z := X;
  X := Y;
  Y := Z;
end;

{ ------ LongMin, LongMax ----------------------------------------------- }

function LongMin(A, B: LongInt): LongInt;
begin
  if A < B then LongMin := A else LongMin := B;
end;

function LongMax(A, B: LongInt): LongInt;
begin
  if A > B then LongMax := A else LongMax := B;
end;

{ ------ LongMin, LongMax ----------------------------------------------- }

function SetInOutFont(PaintDC : hDC; Direction : Shortint) : hFont;
var Font : hFont;
begin
  Font := CreateFont(3, 0, 900*Direction, 0, fw_Normal,
    0, 0, 0, ANSI_Charset, Font_Precis,
    0, Font_Quality, 1, 'Arial');
  SelectObject(PaintDC, Font);
  SetInOutFont := Font;
end;

procedure DrawInOut(
  PaintDC : hDC; X, Y : Integer;
  Direction : Shortint; Num : Integer);
var
  s : String[3];
  s_ : pChar;
  X_, Y_ : Integer;
begin
  GetMem(s_, 4);
  if Num > 0
  then begin
    SelectObject(PaintDC, InPen);
    GetPos(X_, Y_, X-4, Y, Direction); { *- }
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y, Direction); { -* }
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X-2, Y-2, Direction); { -*\ }
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y, Direction); { -\* }
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X-2, Y+2, Direction); { -*> }
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y-2, Direction); { ->*| }
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y+2, Direction); { ->|* }
    LineTo(PaintDC, X_, Y_);
    Str((Num-1):3, s);
    StrPCopy(s_, s);
    GetPos(X_, Y_, X-5, Y+1, Direction);
    if GetROP2(PaintDC)<>R2_NOT
    then TextOut(PaintDC, X_, Y_, s_, 3);
  end
  else begin
    SelectObject(PaintDC, OutPen);
    GetPos(X_, Y_, X, Y-2, Direction);
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y+2, Direction);
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X, Y, Direction);
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X+4, Y, Direction);
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X+2, Y-2, Direction);
    LineTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X+4, Y, Direction);
    MoveTo(PaintDC, X_, Y_);
    GetPos(X_, Y_, X+2, Y+2, Direction);
    LineTo(PaintDC, X_, Y_);
    Str(((-Num)-1):3, s);
    StrPCopy(s_, s);
    GetPos(X_, Y_, X-1, Y+1, Direction);
    if GetROP2(PaintDC)<>R2_NOT
    then TextOut(PaintDC, X_, Y_, s_, 3);
  end;
  FreeMem(s_, 4);
end;

function LoadString0(Idx : Integer) : pChar;
begin
  LoadString(hRes, Idx, @String0, StringLen);
  LoadString0 := @String0;
end;

function LoadString1(Idx : Integer) : pChar;
begin
  LoadString(hRes, Idx, @String1, StringLen);
  LoadString1 := @String1;
end;

function LoadString2(Idx : Integer) : pChar;
begin
  LoadString(hRes, Idx, @String2, StringLen);
  LoadString2 := @String2;
end;

{$ifdef debug}
{procedure appendLog(s:pChar);}
procedure appendLog(s:String);
begin
{  MessageBox(0, s, 'Hallo', 0);}
{  Assign(debugLogFile, 'c:\lokon\log.txt');
  Append(debugLogFile);}
  writeln(debugLogFile, s);
  Flush(debugLogFile);
{  close(debugLogFile);}
end;
{$endif}

function getInternCollection : pCollection;
var
  S : tDosStream;
  Collection : pCollection;
begin
  Collection := New(pCollection, Init(20, 10));
  GetCurDir(@String1, 0);
  StrCat(StrCat(StrCat(@String1, '\ele_'), Language), '\intern.ele');
  S.Init(@String1, stOpenRead);
  Collection^.Load(S);
  S.Done;
  result := Collection;
end;

{ ------ Ressource-DLL einbinden und Initialisierung -------------------- }
{ ------ FileStruct, Registrierung -------------------------------------- }

procedure KreuzNachNull( s : pChar );
var
  i : Integer;
begin
  for i := 0 to StrLen(s) do
    if pCharArray(s)^[i] = '#'
    then pCharArray(s)^[i] := #0
end;


begin
{$ifdef dir}
  ChDir('d:\lokon');
{$endif}
  GetCurDir(@String1, 0);
  StrCat(@String1, '\lang.ini');
  GetPrivateProfileString(
    'LANGUAGE', 'lang', 'xx',
    Language, 3, @String1 );
  if (StrComp(Language, 'xx')=0)
  then begin
    GetProfileString('Intl', 'sLanguage', 'ENG', @String2, 4);
    Language[0] := #0;
    if (StrIComp(@String2, 'DEU')=0)
    then StrCat(Language, 'de')
    else StrCat(Language, 'en');
    WritePrivateProfileString(
      'LANGUAGE', 'lang', Language, @String1 );
  end;

  { Ressource-DLL. }
  GetCurDir(@String1, 0);
  StrCat(StrCat(StrCat(@String1, '\res_'), Language), '.dll');
  hRes := LoadLibrary(@String1);
  { HelpFileName. }
  GetCurDir(@String1, 0);
  StrCat(StrCat(StrCat(@String1, '\doc_'), Language), '\lokon.hlp');
  HelpFileName := StrNew(@String1);

  { FileStruct. }
  with FileStruct
  do begin
    lStructSize := SizeOf(tOpenFileName);
    hWndOwner := 0;
    LoadString0(12000);
    GetMem( lPStrFilter, StrLen(@String0)+1 );
    System.Move( String0, lPStrFilter^, StrLen(@String0)+1 );
    KreuzNachNull(lPStrFilter);
    lPStrCustomFilter := nil;
    nMaxCustFilter := 0;
    lPStrInitialDir := '';
    lPStrDefExt := 'CIR';
    nFilterIndex := 1;
    lpTemplateName := 'FILEDLG';
  end;
  FileStruct.hInstance := hRes;

  { Registrierung. }
  RegisterObjects;
end.
