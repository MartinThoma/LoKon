unit OWinEx;
{$I define.inc}

interface

uses
  LK_Const,

  Objects,
  Strings,
  WinTypes, WinProcs,
  {Win31,}
  OWindows, ODialogs;

type
  pRect_ = ^tRect_;
  tRect_ = record
    case Boolean of
      False : (Left, Top, Right, Bottom : Integer);
      True : (A, B : tPoint);
  end;

  p2Rect = ^t2Rect;
  t2Rect = record
    case Integer of
      1 : (Left, Top, Right, Bottom,
           Left2, Top2, Right2, Bottom2 : Integer);
      2 : (A, B, C, D : tPoint);
      3 : (R1, R2 : tRect);
  end;

type
  p2Ptr = ^t2Ptr;
  t2Ptr = record
    p, q : Pointer;
  end;

const
  InputStrLen = 200;

type
  tInputStr = array [0..InputStrLen] of Char;
  tInputStr1 = array [0..InputStrLen+1] of Char;

procedure SwapInteger(var I, J : Integer);

function CreateEmptyRgn : hRgn;
function CreateLineRgn(A, B : tPoint) : hRgn;
function CreateLineRgn_(X1, Y1, X2, Y2 : integer) : hRgn;
function CreateEllipticRgn(X1, Y1, X2, Y2 : Integer) : hRgn;
function CreateRectRgn(X1, Y1, X2, Y2 : Integer) : hRgn;
function CreateTextRgn(s : pChar; l : Integer; FontData : tFontData) : hRgn;

procedure UserMessage_(
  hWindow : tHandle; TextIdx, CaptionIdx : Integer; TextType : Word);

const
  ms_Store = 800;
  ms_Load = 801;

const
  MessageOn : Boolean = True;

type
  pWindowEx = ^tWindowEx;
  tWindowEx = object (TWindow)
    procedure UserMessage(TextIdx, CaptionIdx : Integer; TextType : Word);
    procedure ErrorMessage(TextIdx : Integer);
    procedure BeepMessage(TextIdx : Integer);
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    procedure msStore(var Msg : tMessage);
      virtual ms_Store;
    procedure msLoad(var Msg : tMessage);
      virtual ms_Load;
    procedure MDI_Act; virtual;
    procedure SetRedrawSpeedbar;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure wmMDIActivate(var Msg : tMessage);
      virtual wm_First + wm_MDIActivate;
    procedure msChildClose( var msg : tMessage );
      virtual ms_ChildClose;
    procedure msSetCaption( var Msg : tMessage );
      virtual ms_SetCaption;
{$ifdef osc}
    procedure msShowWindow( var Msg : tMessage );
      virtual ms_ShowWindow;
    procedure msHideWindow( var Msg : tMessage );
      virtual ms_HideWindow;
{$endif}
  end;

type
  pDialogEx = ^tDialogEx;
  tDialogEx = object (tDialog)
    procedure SetupWindow; virtual;
    function Create : Boolean; virtual;
    function Execute : Integer; virtual;
    procedure WMSysCommand(var Msg : tMessage);
      virtual WM_FIRST + WM_SYSCOMMAND;
    procedure WMCtlColor(var Msg : tMessage);
      virtual WM_FIRST + WM_CTLCOLOR;
    procedure IDHelp(var Msg : tMessage);
      virtual ID_FIRST + 50;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure UserMessage(TextIdx, CaptionIdx : Integer; TextType : Word);
    procedure ErrorMessage(TextIdx : Integer);
  end;

type
  pDialogSB = ^tDialogSB;
  tDialogSB = object (tDialogEx)
    procedure wmVScroll(var Msg : tMessage);
      virtual wm_First + wm_VScroll;
  end;

type
  pTextDlg = ^tTextDlg;
  tTextDlg = object (tDialogEx)
    Input, Text : pChar;
    InputLen : Integer;
    constructor Init(
      xParent : pWindowsObject;
      xInput : pChar; xTxtIdx, xInputLen : Integer);
    constructor Init2(
      xParent : pWindowsObject;
      xInput, xText : pChar; xInputLen : Integer);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

type
  pNrDlg = ^tNrDlg;
  tNrDlg = object (tDialogEx)
    Nr : ^Integer;
    TxtIdx : Integer;
    constructor Init(
      xParent : pWindowsObject; xNr : Pointer; xTxtIdx : Integer);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

type
  pBorderStatic = ^tBorderStatic;
  tBorderStatic = object (tStatic)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
  end;

const
  LB_SETCARETINDEX = WM_USER+31;
  LB_GETCARETINDEX = WM_USER+32;

type
  pListBox_ = ^tListBox_;
  tListBox_ = object (tListBox)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      X, Y, W, H: Integer);
  end;

type
  pListBox__ = ^tListBox__;
  tListBox__ = object (tListBox)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      X, Y, W, H: Integer);
  end;

type
  pGlobalStream = ^tGlobalStream;
  tGlobalStream = object (tStream)
    Pos,
    Size : Longint;
    Handle : tHandle;
    constructor Init;
    destructor Done; virtual;
    destructor Done_;
    function GetPos : Longint; virtual;
    function GetSize : Longint; virtual;
    procedure Read(var Buf; Count : DWord); virtual;
    procedure Seek(i : Longint); virtual;
    procedure Write(var Buf; Count : DWord); virtual;
  end;

function EqualPt(A, B : tPoint) : Boolean;
procedure RectPt(var R : tRect; Pt : tPoint);
procedure RectXY(var R : tRect; X, Y : Integer);

function AppendLayMenus(
  Menu : hMenu; RasterFront : Boolean ) : hMenu;

function MenuInc : Integer;

function GetFileType(s:pChar) : Integer;

implementation

{ ------ SwapInteger ---------------------------------------------------- }

procedure SwapInteger(var I, J : Integer);
var K : Integer;
begin
  K := I;
  I := J;
  J := K;
end;

{ ------ CreateEmptyRgn, CreateLineRgn, CreateEllipticRgn, --------------
  ------ CreateRectRgn -------------------------------------------------- }

function CreateEmptyRgn : hRgn;
begin
  CreateEmptyRgn := CreateRectRgn(0, 0, 0, 0);
end;

function CreateLineRgn(A, B : tPoint) : hRgn;
var
  Pt : array [0..5] of tPoint;
  dx, dy : Integer;
begin
{  Pt[0] := A;
  Pt[1] := A;
  Pt[2] := B;
  Pt[3] := B;
  Pt[0].X := Pt[0].X-5;
  Pt[1].X := Pt[1].X+5;
  Pt[0].Y := Pt[0].Y-5;
  Pt[1].Y := Pt[1].Y+5;
  Pt[2].X := Pt[2].X-5;
  Pt[3].X := Pt[3].X+5;
  Pt[2].Y := Pt[2].Y-5;
  Pt[3].Y := Pt[3].Y+5;
  CreateLineRgn := CreatePolygonRgn(Pt, 4, 0); }
{  if B.X > A.X
  then dx := 2
  else dx := -2;
  dec(Pt[1].X, dx);
  inc(Pt[4].X, dx);
  if B.Y > A.Y
  then dy := 2
  else dy := -2;
  dec(Pt[1].Y, dy);
  inc(Pt[4].Y, dy);
  dx := B.X - A.X;
  dy := B.Y - A.Y;
  if abs(dx) > abs(dy)
  then begin
    inc(Pt[2].Y, 2);
    inc(Pt[3].Y, 2);
    dec(Pt[0].Y, 2);
    dec(Pt[5].Y, 2);
  end
  else begin
    inc(Pt[2].X, 2);
    inc(Pt[3].X, 2);
    dec(Pt[0].X, 2);
    dec(Pt[5].X, 2);
  end;
  CreateLineRgn := CreatePolygonRgn(Pt, 6, 0);}
  CreateLineRgn := CreateRectRgn(A.X-1, A.Y-1, B.X+1, B.Y+1);
end;

function CreateLineRgn_( X1, Y1, X2, Y2 : integer ) : hRgn;
var
  A, B : tPoint;
begin
  with A
  do begin
    X := X1;
    Y := Y1;
  end;
  with B
  do begin
    X := X2;
    Y := Y2;
  end;
  CreateLineRgn_ := CreateLineRgn( A, B );
end;

function CreateEllipticRgn(X1, Y1, X2, Y2 : Integer) : hRgn;
begin
  if X1 > X2 then SwapInteger(X1, X2);
  if Y1 > Y2 then SwapInteger(Y1, Y2);
  CreateEllipticRgn := WinProcs.CreateEllipticRgn(X1, Y1, X2+1, Y2+1);
end;

function CreateRectRgn(X1, Y1, X2, Y2 : Integer) : hRgn;
begin
  if X1 > X2 then SwapInteger(X1, X2);
  if Y1 > Y2 then SwapInteger(Y1, Y2);
  CreateRectRgn := WinProcs.CreateRectRgn(X1, Y1, X2, Y2);
end;

function CreateTextRgn(s : pChar; l : Integer; FontData : tFontData) : hRgn;
var
  font, font_ : hFont;
  A : array [0..3] of tPoint;
  PaintDC : hDC;
  i : Byte;
  z, w : Real;
  size : TSize;
begin
{$ifdef debug}
  appendLog('CreateTextRgn 1');
  wvsprintf(@String0, '%i', l);
  appendLog(StrPas(@String0));
{$endif}
  with FontData do
    font := CreateFont(
      Height, Width,
      0, 0,
      400 + 300 * (FontFlag and $01),
      FontFlag and $02,
      FontFlag and $04,
      FontFlag and $08,
      ANSI_Charset, 6 {Out_Raster_Precis},
      0, 1 {Draft_Quality}, 1, FontName[FontNr]);
  { Textausmaﬂe bestimmen. }
  PaintDC := GetDC(pWindow(Application^.MainWindow)^.hWindow);
  font_ := SelectObject(PaintDC, font);
{$ifdef debug}
  appendLog('CreateTextRgn 1a');
{$endif}
  GetTextExtentPoint(PaintDC, s, l, size);
  A[2].X := size.cx;
  A[2].Y := size.cy;
  inc(A[2].X);
  inc(A[2].Y);
  SelectObject(PaintDC, font_);
{$ifdef debug}
  appendLog('CreateTextRgn 1b');
{$endif}
  DeleteObject(font);
  ReleaseDC(pWindow(Application^.MainWindow)^.hWindow, PaintDC);
  { Region berechnen. }
  A[0].X := 0;
  A[0].Y := 0;
  A[1].X := A[2].X+1;
  A[1].Y := 0;
  A[3].X := 0;
  A[3].Y := A[2].Y+1;
  for i := 1 to 3 do
    with A[i]
    do begin
      z := sqrt( sqr(Longint(X)) + sqr(Longint(Y)) );
      if x = 0
      then w := (Pi/2) - (Fontdata.Direct*Pi/1800)
      else w := arctan(y/x) - (Fontdata.Direct*Pi/1800);
      X := trunc( cos(w) * z );
      Y := trunc( sin(w) * z );
    end;
  CreateTextRgn := CreatePolygonRgn(A, 4, 0);
{$ifdef debug}
  appendLog('CreateTextRgn 2');
{$endif}
end;

{ ------ UserMessage_ --------------------------------------------------- }

procedure UserMessage_(hWindow : tHandle; TextIdx, CaptionIdx : Integer;
  TextType : Word);
begin
  if CaptionIdx < 0 then MessageBeep(mb_OK);
  LoadString2(TextIdx);
  if CaptionIdx < 0
  then MessageBox(hWindow, @String2, nil, TextType)
  else MessageBox(hWindow, @String2, LoadString1(CaptionIdx), TextType);
end;

{ ------ tWinodwEx ------------------------------------------------------ }

procedure tWindowEx.UserMessage(
  TextIdx, CaptionIdx : Integer; TextType : Word);
begin
  UserMessage_(hWindow, TextIdx, CaptionIdx, TextType);
end;

procedure tWindowEx.ErrorMessage(TextIdx : Integer);
begin
  UserMessage_(hWindow, TextIdx, -1, mb_IconStop + mb_OK);
end;

procedure tWindowEx.BeepMessage(TextIdx : Integer);
begin
  MessageBeep(mb_OK);
  if MessageOn then
    UserMessage_(hWindow, TextIdx, 96, mb_IconInformation + mb_OK);
end;

procedure tWindowEx.Load(var S : tStream);
begin
  Abstract;
end;

procedure tWindowEx.Store(var S : tStream);
begin
  Abstract;
end;

procedure tWindowEx.msStore(var Msg : tMessage);
begin
  Store(pStream(Msg.lParam)^);
  Msg.Result := Longint(@Self);
end;

procedure tWindowEx.msLoad(var Msg : tMessage);
begin
  Load(pStream(Msg.lParam)^);
  Msg.Result := Longint(@Self);
end;

procedure tWindowEx.MDI_Act;
begin
  SetRedrawSpeedbar;
end;

procedure tWindowEx.SetRedrawSpeedbar;
begin
  if GetFocus = hWindow
  then xRedrawSpeedbar := true;
end;

procedure tWindowEx.MDI_Menu(b : Boolean);
begin
  if b then MDI_Act;
end;

procedure tWindowEx.wmMDIActivate(var Msg : tMessage);
begin
  MDI_Menu(Boolean(Msg.wParam));
end;

procedure tWindowEx.msChildClose( var msg : tMessage );
begin
  SendMessage( hWindow, wm_Close, 0, 0 );
end;

procedure tWindowEx.msSetCaption( var Msg : tMessage );
begin
  SetCaption( pChar(Msg.lParam) );
end;

{$ifdef osc}
procedure tWindowEx.msShowWindow( var Msg : tMessage );
begin
  Show( SW_RESTORE );
  Focus;
end;

procedure tWindowEx.msHideWindow( var Msg : tMessage );
begin
  Show( SW_MINIMIZE );
  Show( SW_HIDE );
end;
{$endif}

{ ------ tDialogEx ------------------------------------------------------ }

procedure tDialogEx.SetupWindow;
var m : hMenu;
begin
  inherited SetupWindow;
  m := GetSystemMenu(hWindow, FALSE);
  AppendMenu(m, MF_SEPARATOR, 0, nil);
  AppendMenu(m, MF_ENABLED or MF_STRING, CM_HELPCONTENTS, LoadString0(44));
  AppendMenu(m, MF_ENABLED or MF_STRING, CM_HELPCONTEXT, LoadString0(45));
  AppendMenu(m, MF_ENABLED or MF_STRING, CM_HELPONHELP, LoadString0(46));
  AppendMenu(m, MF_ENABLED or MF_STRING, CM_HOWTODO, LoadString0(47));
end;

function tDialogEx.Create : Boolean;
{ Wie tDialog.Create, die Ressource wird aber aus hRes geladen. }
var hParent : hWnd;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := False;
    if Parent = nil
    then hParent := 0
    else hParent := Parent^.hWindow;
    hWindow :=
      CreateDialogParam(
        hRes, Attr.Name, hParent,
        Instance, Attr.Param);
    if hWindow = 0
    then Status := em_InvalidWindow;
  end;
  Create := Status = 0;
end;

function tDialogEx.Execute : Integer;
{ Wie tDialog.Execute, die Ressource wird aus hRes geladen. }
var
  hParent : hWnd;
  ReturnValue : Integer;
  OldKbHandler : pWindowsObject;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := True;
    if Parent = nil
    then hParent := 0
    else hParent := Parent^.hWindow;
    OldKbHandler := Application^.KBHandlerWnd;
    ReturnValue :=
      DialogBoxParam(
        hRes, Attr.Name, hParent,
        Instance, Attr.Param);
    Application^.KBHandlerWnd := OldKbHandler;
    { -1 if the function cannot create the dialog box }
    if ReturnValue = -1 then Status := em_InvalidWindow;
    hWindow := 0;
    Execute := ReturnValue;
  end
  else Execute := Status;
end;

procedure tDialogEx.WMSysCommand(var Msg : tMessage);
begin
  case Msg.wParam of
    CM_HELPCONTENTS : WinHelp(hWindow, 'LOKON.HLP', HELP_CONTENTS, 0);
    CM_HELPCONTEXT : PostMessage(hWindow, WM_COMMAND, CM_HELPCONTEXT, 0);
    CM_HELPONHELP : WinHelp(hWindow, 'LOKON.HLP', HELP_HELPONHELP, cs_Info);
    CM_HOWTODO : WinHelp(hWindow, 'LOKON.HLP', HELP_CONTEXT, 900);
  else
    DefWndProc(Msg);
  end;
end;

procedure tDialogEx.WMCtlColor(var Msg : tMessage);
begin
  case Msg.lParamHi of
    CTLCOLOR_EDIT,
    CTLCOLOR_LISTBOX : begin end;
    else begin
      SetTextColor( Msg.wParam, GetSysColor(COLOR_BTNTEXT) );
      SetBkColor( Msg.wParam, GetSysColor( COLOR_BTNFACE ) );
      Msg.Result := BkBrush;
    end;
  end;
end;

procedure tDialogEx.IDHelp(var Msg : tMessage);
begin
  SendMessage(hWindow, WM_COMMAND, CM_HELPCONTEXT, 0);
end;

procedure tDialogEx.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTENTS, 0);
end;

procedure tDialogEx.UserMessage(
  TextIdx, CaptionIdx : Integer; TextType : Word);
begin
  UserMessage_(hWindow, TextIdx, CaptionIdx, TextType);
end;

procedure tDialogEx.ErrorMessage(TextIdx : Integer);
begin
  UserMessage_(hWindow, TextIdx, -1, mb_IconStop + mb_OK);
end;

{ ------ tDialogSB ------------------------------------------------------ }

procedure tDialogSB.wmVScroll(var Msg : tMessage);
var
  id : Word;
  translated : Bool;
begin
  with Msg
  do begin
    id := GetDlgCtrlId(Msg.lParamHi) - 100;
    lParamLo := GetDlgItemInt(hWindow, id, translated, True);
    case wParam of
      sb_LineUp : inc(lParamLo);
      sb_LineDown : dec(lParamLo);
      sb_PageUp : inc(lParamLo, 5);
      sb_PageDown : dec(lParamLo, 5);
    end;
    SetScrollPos(lParamHi, sb_Ctl, Integer(lParamLo), True);
    SetDlgItemInt(hWindow, id, lParamLo, True);
  end;
end;

{ ------ tTextDlg ------------------------------------------------------- }

constructor tTextDlg.Init(
  xParent : pWindowsObject;
  xInput : pChar; xTxtIdx, xInputLen : Integer);
begin
  inherited Init(xParent, 'TEXTDLG');
  Input := xInput;
  InputLen := xInputLen;
  LoadString0(xTxtIdx);
  Text := StrNew(@String0);
end;

constructor tTextDlg.Init2(
  xParent : pWindowsObject;
  xInput, xText : pChar; xInputLen : Integer);
begin
  inherited Init(xParent, 'TEXTDLG');
  Input := xInput;
  InputLen := xInputLen;
  Text := StrNew(xText);
end;

procedure tTextDlg.SetupWindow;
begin
  inherited SetupWindow;
  SetWindowText(hWindow, Text);
  SetWindowText(GetItemHandle(1000), Input);
end;

procedure tTextDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 107);
end;

procedure tTextDlg.OK(var Msg : tMessage);
begin
  GetDlgItemText(hWindow, 1000, Input, InputLen);
  if StrLen(Input) > 0
  then EndDialog(hWindow, id_OK)
  else EndDialog(hWindow, id_Cancel);
end;

{ ------ tNrDlg --------------------------------------------------------- }

constructor tNrDlg.Init(
  xParent : pWindowsObject; xNr : Pointer; xTxtIdx : Integer);
begin
  inherited Init(xParent, 'NRDLG');
  Nr := xNr;
  TxtIdx := xTxtIdx;
end;

procedure tNrDlg.SetupWindow;
begin
  inherited SetupWindow;
  SetWindowText(hWindow, LoadString0(TxtIdx));
  SetDlgItemInt(hWindow, 100, Nr^, True);
end;

procedure tNrDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 107);
end;

procedure tNrDlg.OK(var Msg : tMessage);
var
  translated : Bool;
begin
  Nr^ := GetDlgItemInt(hWindow, 100, translated, True);
  inherited OK(Msg);
end;

{ ------ tBorderStatic -------------------------------------------------- }

constructor tBorderStatic.Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
begin
  inherited Init(AParent, AnId, ATitle, X, Y, W, H, ATextLen);
  Attr.Style := Attr.Style + ws_Border;
end;

{ ------ tListBox_ ------------------------------------------------------ }

constructor tListBox_.Init(AParent: PWindowsObject; AnId: Integer;
  X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, nil, X, Y, W, H);
  Attr.Style :=
    Attr.Style or
    { lbs_Standard without lbs_Sort }
    (lbs_Notify + ws_VScroll + ws_Border) or
    $00001000 { lbs_DisableNoScroll };
end;

{ ------ tListBox__ ----------------------------------------------------- }

constructor tListBox__.Init(AParent: PWindowsObject; AnId: Integer;
  X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, nil, X, Y, W, H);
  Attr.Style :=
    Attr.Style or
    { lbs_Standard without lbs_Sort }
    lbs_NoIntegralHeight or lbs_Notify or
    lbs_ExtendedSel or
    ws_VScroll or ws_Border or
    $00001000 { lbs_DisableNoScroll };
end;

{ ------ tGlobalStream -------------------------------------------------- }

constructor tGlobalStream.Init;
begin
  inherited Init;
  Pos := 0;
  Size := 0;
  Handle := GlobalAlloc(GHND, 1);
end;

destructor tGlobalStream.Done;
begin
  GlobalFree(Handle);
  inherited Done;
end;

destructor tGlobalStream.Done_;
begin
  inherited Done; { Der Handle wird nicht freigegeben. }
end;

function tGlobalStream.GetPos : Longint;
begin
  GetPos := Pos;
end;

function tGlobalStream.GetSize : Longint;
begin
  GetSize := Size;
end;

procedure tGlobalStream.Read(var Buf; Count : DWord);
var
  numRead : DWord;
begin
  ReadProcessMemory(Handle, nil, pChar(@Buf)+Pos, Count, numRead);
  inc(Pos, Count);
end;

procedure tGlobalStream.Seek(i : Longint);
begin
  Pos := i;
end;

procedure tGlobalStream.Write(var Buf; Count : DWord);
var
  numWrite : DWord;
begin
  if Size < Pos+Count
  then begin
    Size := Pos + Count;
    Handle := GlobalRealloc(Handle, Size, GHND);
  end;
  WriteProcessMemory(Handle, nil, pChar(@Buf)+Pos, Count, numWrite);
  inc(Pos, Count);
end;

{ ------ EqualPt, RectPt, RectXY ---------------------------------------- }

function EqualPt(A, B : tPoint) : Boolean;
begin
  EqualPt := (abs(A.X - B.X) < 4) and (abs(A.Y - B.Y) < 4);
end;

procedure RectPt(var R : tRect; Pt : tPoint);
begin
  with tRect_(R)
  do begin
    A := Pt;
    B := Pt;
  end;
end;

procedure RectXY(var R : tRect; X, Y : Integer);
begin
  with tRect_(R)
  do begin
    Left := X;
    Top := Y;
    B := A;
  end;
end;

function AppendLayMenus(
  Menu : hMenu; RasterFront : Boolean ) : hMenu;
var
  MainMenu : hMenu;
  s : array [0..127] of char;
begin
  MainMenu := GetMenu(Application^.MainWindow^.hWindow);
  AppendMenu( Menu, MF_SEPARATOR, 0, nil );
  AppendMenu(
    Menu,
    mf_Enabled + mf_Popup,
    LoadMenu(hRes, 'SIMMENU'), LoadString0(23));
  AppendMenu(
    Menu,
    mf_Enabled + mf_Popup,
    LoadMenu(hRes, 'GATEMENU'), LoadString0(16));
{$ifdef mini}
  if GetMenuState( MainMenu, cm_Gate, MF_BYCOMMAND ) = mf_Grayed
  then begin
    EnableMenuItem(Menu, cm_Gate, mf_Grayed);
    EnableMenuItem(Menu, cm_ActItem, mf_Grayed);
    EnableMenuItem(Menu, cm_ConNode, mf_Grayed);
    EnableMenuItem(Menu, cm_Zero, mf_Grayed);
    EnableMenuItem(Menu, cm_One, mf_Grayed);
    EnableMenuItem(Menu, cm_Switch, mf_Grayed);
    EnableMenuItem(Menu, cm_TickEle, mf_Grayed);
    EnableMenuItem(Menu, cm_ItemText, mf_Grayed);
  end;
{$endif}
  AppendMenu(
    Menu,
    mf_Enabled + mf_Popup,
    LoadMenu(hRes, 'LAYVIEW'), LoadString0(17));
  { Simulation. }
  EnableMenuItem(
    Menu,
    cm_SimStart,
    GetMenuState( MainMenu, cm_SimStart, MF_BYCOMMAND ) );
  EnableMenuItem(
    Menu,
    cm_SimStop,
    GetMenuState( MainMenu, cm_SimStop, MF_BYCOMMAND ) );
  EnableMenuItem(
    Menu,
    cm_SimReset,
    GetMenuState( MainMenu, cm_SimReset, MF_BYCOMMAND ) );
  { Raster. }
  if RasterFront
  then begin
    ModifyMenu(
      Menu,
      cm_RasterFront, mf_ByCommand,
      cm_RasterBack, LoadString0(18));
  end;
  CheckMenuItem(
    Menu,
    cm_RasterOff,
    GetMenuState( MainMenu, cm_RasterOff, MF_BYCOMMAND ) );
  CheckMenuItem(
    Menu,
    cm_RasterBig,
    GetMenuState( MainMenu, cm_RasterBig, MF_BYCOMMAND ) );
  CheckMenuItem(
    Menu,
    cm_RasterSmall,
    GetMenuState( MainMenu, cm_RasterSmall, MF_BYCOMMAND ) );
  { Ein-/Ausg‰nge anzeigen. }
  CheckMenuItem(
    Menu,
    cm_ShowInOut,
    GetMenuState( MainMenu, cm_ShowInOut, MF_BYCOMMAND ) );
  { Element. }
  GetMenuString(
    MainMenu,
    cm_ActItem,
    @s, 127,
    MF_BYCOMMAND);
  ModifyMenu(
    Menu,
    cm_ActItem,
    GetMenuState(
      MainMenu,
      cm_ActItem,
      MF_BYCOMMAND),
    cm_ActItem,
    @s );
  AppendLayMenus := Menu;
end;

function MenuInc : Integer;
begin
  if SendMessage(
       pMDIWindow(Application^.MainWindow)^.ClientWnd^.hWindow,
       wm_MDIGetActive, 0, 0)
     >= $00010000
  then MenuInc := 1
  else MenuInc := 0;
end;

function GetFileType(s:pChar) : Integer;
begin
  if StrPos(s,'LAY') <> nil
  then GetFileType := 1
  else if StrPos(s,'ELE') <> nil
  then GetFileType := 2
  else GetFileType := 0;
end;

end.
