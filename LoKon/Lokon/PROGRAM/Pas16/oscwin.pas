unit OscWin;
{$I define.inc}

interface

uses
  Objects, Messages,
  WinTypes, WinProcs,
  Strings,
  OWindows, ODialogs,
  CommDlg,
  LK_Const,
  OWinEx,
  ScrolOrg, Paint,
  Connect,
  Impulse,
  Graphic;

type
  pOscCon = ^tOscCon;
  tOscCon = object (tObject)
    con : pConnection;
    states : tGraphic;
    name : pChar;
    start : longint;
    val : integer; { Letzter gemessener Zustand.
                     Alle Zust�nde beziehen sich darauf. }
    constructor Init
      ( xcon : pConnection; xname : pChar; xstart : longint );
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure Paint(
      PaintDC : hDC; R : tRect;
      xTextOfs, yOfs, yInc, wPix, txtH : integer );
    procedure Tick(
      PaintDC : hDC; xOfs, yOfs, wPix, height : integer );
    procedure Rect(var R : tRect);
    procedure LayPaint( PaintDC : hDC; PaintInfo : pPaintStruct );
    procedure Reset( xstart : longint );
  end;

type
  pOscilloscopeWindow = ^tOscilloscopeWindow;
  tOscilloscopeWindow = object (tPaint)
    LayWin : pWindow;
    OscCon : pCollection;
    idx : integer;
    tick : longint;
    yInc, wPix, txtH : integer;
    constructor Init(
      aParent : pWindowsObject; name : pChar);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure GetWindowClass(var aWndClass : tWndClass); virtual;
    function GetClassName: PChar; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure msZoomAll(var Msg : tMessage);
      virtual ms_ZoomAll;
    procedure msOscAddCon( var Msg : tMessage );
      virtual ms_OscAddCon;
    procedure msOscDelCon( var Msg : tMessage );
      virtual ms_OscDelCon;
    procedure msOscIsRecCon( var Msg : tMessage );
      virtual ms_OscIsRecCon;
    procedure msChildClose( var msg : tMessage );
      virtual ms_ChildClose;
    function CanClose : boolean; virtual;
    procedure msTick( var msg : tMessage );
      virtual ms_Tick;
    procedure WMRButtonDown(var Msg : tMessage);
      virtual wm_First + wm_RButtonDown;
    procedure msOscLayPaint( var Msg : tMessage );
      virtual ms_OscLayPaint;
    procedure cmOscRename( var Msg : tMessage );
      virtual cm_First + cm_OscRename;
    procedure cmOscDelete( var Msg : tMessage );
      virtual cm_First + cm_OscDelete;
    procedure msSetCaption( var Msg : tMessage );
      virtual ms_SetCaption;
    procedure cmOscHeight( var Msg : tMessage );
      virtual cm_First + cm_OscHeight;
    procedure cmOscOptimalH( var Msg : tMessage );
      virtual cm_First + cm_OscOptimalH;
    procedure cmOscReset( var Msg : tMessage );
      virtual cm_First + cm_OscReset;
    procedure cmOscResetAll( var Msg : tMessage );
      virtual cm_First + cm_OscResetAll;
    procedure cmHelpContext(var Msg : tMessage);
      virtual cm_First + cm_HelpContext;
    procedure WMSysCommand(var Msg : tMessage);
      virtual WM_FIRST + WM_SYSCOMMAND;
    procedure cmHideOscWin(var Msg : tMessage);
      virtual cm_First + cm_HideOscWin;
    procedure cmShowCircuit(var Msg : tMessage);
      virtual cm_First + cm_ShowCircuit;
    procedure msShowOscWin(var Msg : tMessage);
      virtual ms_ShowOscWin;
    procedure msHideOscWin(var Msg : tMessage);
      virtual ms_HideOscWin;
    procedure wmClose( var Msg : tMessage );
      virtual wm_First + wm_Close;
{$ifdef undo}
    { Gesamtes Fenster l�schen, um aus Undo Puffer laden zu k�nnen. }
    procedure DelUndo; virtual;
{$endif}
  end;

var
  hOscLay : HWND;

implementation

{ ------ tOscCon ------------------------------------------------------------ }

constructor tOscCon.Init
  ( xcon : pConnection; xname : pChar; xstart : longint );
begin
  con := xcon;
  name := StrNew( xname );
  start := xstart;
  states.Init;
  val := 2; { Zustand noch undefiniert. }
end;

destructor tOscCon.Done;
begin
  states.Done;
  Dispose( name );
end;

constructor tOscCon.Load(var S : tStream);
var
  i : Integer;
begin
  S.Read( i, SizeOf(i) );
  con := pConnection(SendMessage( hOscLay, ms_ItemIndex, 1, i ));
  states.Load(S);
  name := S.StrRead;
  S.Read( start, SizeOf(start)+SizeOf(val) );
end;

procedure tOscCon.Store(var S : tStream);
var
  i : Integer;
begin
  i := SendMessage( hOscLay, ms_ItemIndex, 0, longint(con) );
  S.Write( i, SizeOf(i) );
  states.Store(s);
  S.StrWrite( name );
  S.Write( start, SizeOf(start)+SizeOf(val) );
end;

procedure tOscCon.Paint(
  PaintDC : hDC; R : tRect; xTextOfs, yOfs, yInc, wPix, txtH : Integer );
var
  xofs,
  val_,
  i,
  height : integer;
begin
  height := yInc-txtH;
  xofs := start;
  TextOut( PaintDC, xTextOfs, yOfs-yInc, name, StrLen(name) );
  with states
  do begin
    for i := 0 to GraphicSize-1
    do inc(xofs,Graphic^[i]);
    val_ := val;
    MoveTo( PaintDC, xofs*wPix, yOfs-(height*val_) );
    for i := GraphicSize-1 downto 1
    do begin
      dec(xofs, Graphic^[i]);
      LineTo( PaintDC, xofs*wPix, yOfs-(height*val_) );
      if val_=0
      then val_ := 1
      else val_ := 0;
      LineTo( PaintDC, xofs*wPix, yOfs-(height*val_) );
    end;
    if GraphicSize > 0
    then begin
      dec(xofs, Graphic^[0]);
      LineTo( PaintDC, xofs*wPix, yOfs-(height*val_) );
    end;
  end;
end;

procedure tOscCon.Tick(
  PaintDC : hDC; xOfs, yOfs, wPix, height : integer );
var
  val_ : integer;
begin
  val_ := con^.on_;
  if val=2
  then begin
    val := val_;
    states.InsertInteger(1);
    MoveTo( PaintDC, (xofs-1)*wPix, yOfs-(height*val_) );
    LineTo( PaintDC, xofs*wPix, yOfs-(height*val_) );
  end
  else
    with states
    do begin
      if val_ = val
      then begin
        inc( Graphic^[GraphicSize-1] );
        MoveTo( PaintDC, xofs-1, yOfs-(height*val_) );
        LineTo( PaintDC, xofs, yOfs-(height*val_) );
      end
      else begin
        MoveTo( PaintDC, xofs-1, yOfs-(height*val) );
        LineTo( PaintDC, xofs-1, yOfs-(height*val_) );
        val := val_;
        InsertInteger(1);
        LineTo( PaintDC, xofs, yOfs-(height*val_) );
      end;
    end;
end;

procedure tOscCon.Rect( var R : tRect );
var
  xofs,
  i : integer;
begin
  xofs := start;
  with states do
    for i := 0 to GraphicSize-1
    do inc(xofs,Graphic^[i]);
  if xofs < 20 then xofs := 20;
  with R
  do begin
    right := xofs;
    left := 0;
  end;
end;

procedure tOscCon.LayPaint( PaintDC : hDC; PaintInfo : pPaintStruct );
var
  l : longint;
  A : tPoint;
begin
  l := con^.PosPoint;
  A := tPoint(l);
  TextOut( PaintDC, A.X, A.Y, name, strlen(name) );
end;

procedure tOScCon.Reset( xstart : longint );
begin
  states.Done;
  start := xstart;
  val := 2;
end;

{ ------ tOscilloscopeWindow -------------------------------------------------- }

constructor tOscilloscopeWindow.Init(
  aParent : pWindowsObject; name : pChar);
begin
  StrCopy( @String1, name );
  LoadString0(3);
  StrCat( @String1, @String0 );
  inherited Init(aParent, @String1 );
  Attr.Style :=
    Attr.Style or
    WS_VSCROLL or WS_HSCROLL or
    WS_ICONIC;
  OscCon := New( pCollection, Init( 20, 20 ) );
  tick := 0;
  yInc := 16;
  txtH := 5;
  wPix := 1;
  Raster := 1;
  RasterIncX := wPix;
  RasterIncY := yInc;
  RasterMulX := 5;
  RasterMulY := 1;
  crossX := 0;
  crossY := 2;
  State := ls_None;
end;

destructor tOscilloscopeWindow.Done;
begin
  Dispose( OscCon, Done );
  inherited Done;
end;

procedure tOscilloscopeWindow.SetupWindow;
var
  menu : hMenu;
begin
  inherited SetupWindow;
  menu := GetSystemMenu( hWindow, false );
  AppendMenu( menu, MF_SEPARATOR, 0, nil );
  { Schaltung }
  LoadString0(58);
  AppendMenu(
    menu,
    MF_STRING + MF_ENABLED + MF_UNCHECKED,
    CM_SHOWCIRCUIT, @String0 );
  { Schaltung }
  LoadString0(57);
  AppendMenu(
    menu,
    MF_STRING + MF_ENABLED + MF_UNCHECKED,
    CM_HIDEOSCWIN, @String0 );
end;

procedure tOscilloscopeWindow.Load(var S : tStream);
var
  version : byte;
  hOscLay_ :HWND;
begin
  S.Read( version, SizeOf(version) );
  if (S.status = stOK) and ((version and 1) = 1)
  then begin
    inherited Load(S);
    S.Read( tick, SizeOf(tick)+SizeOf(yInc)+SizeOf(wPix)+SizeOf(txtH) );
    hOscLay_ := hOscLay;
    hOscLay := LayWin^.hWindow;
    OscCon^.Load(S);
    hOscLay := hOscLay_;
    idx := 0;
    RasterIncX := wPix;
    RasterIncY := yInc;
  end;
end;

procedure tOscilloscopeWindow.Store(var S : tStream);
var
  version : byte;
  hOscLay_ : HWND;
begin
  version := 1;
  S.Write( version, SizeOf(version) );
  inherited Store(S);
  S.Write( tick, SizeOf(tick)+SizeOf(yInc)+SizeOf(wPix)+SizeOf(txtH) );
  hOscLay_ := hOscLay;
  hOscLay := LayWin^.hWindow;
  OscCon^.Store(S);
  hOscLay := hOscLay_;
  MDI_Act;
end;

procedure tOscilloscopeWindow.GetWindowClass(var aWndClass : tWndClass);
begin
  inherited GetWindowClass(aWndClass);
  with aWndClass
  do begin
    (*Style :=
      Style or
      CS_NOCLOSE;*)
    hIcon := LoadIcon(hRes, 'OSCICON');
  end;
end;

function tOscilloscopeWindow.GetClassName: PChar;
begin
  GetClassName := 'LK_OscWin';
end;

procedure tOscilloscopeWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  yOfs : integer;
procedure DoPaint( con : pOscCon ); far;
begin
  con^.Paint(
    PaintDC, PaintInfo.rcPaint,
    pScrollerOrg(Scroller)^.XPos,
    yOfs, yInc, wPix, txtH );
  inc ( yOfs, yInc );
end;
var
  font : hFont;
begin
  yOfs := 0;
  Font := CreateFont(
    txtH, 0,
    0, 0,
    400,
    0, 0, 0,
    ANSI_Charset, Font_Precis,
    0, Font_Quality, 1, 'Arial');
  SelectObject(PaintDC, OscPen);
  SetTextColor(PaintDC, OscTextCol2);
  SelectObject(PaintDC, Font);
  OscCon^.ForEach( @DoPaint );
  DeleteObject(font);
end;

procedure tOscilloscopeWindow.MDI_Menu(b : Boolean);
var
  Menu : hMenu;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if b
  then begin
    InsertMenu(Menu, 2 + MenuInc,
      mf_Enabled + mf_ByPosition + mf_Popup,
      LoadMenu(hRes, 'OSCVIEW'), LoadString0(17));
    { Speedbar. }
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomAll);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_OscOptimalH);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_OscResetAll);
  end
  else begin
    DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
    RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomAll);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_OscOptimalH);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_OscResetAll);
  end;
  inherited MDI_Menu(b);
end;

procedure tOscilloscopeWindow.msOscAddCon( var Msg : tMessage );
function IsOscRec( con : pOscCon ) : boolean; far;
begin
  IsOscRec := ( con^.con = pConnection(Msg.lParam) );
end;
var
  i : integer;
  ocon : pOscCon;
begin
  ocon := pOscCon( OscCon^.FirstThat( @IsOscRec ) );
  if (ocon <> nil)
  then begin
    OscCon^.Free( ocon );
  end
  else begin
    i := OscCon^.Count;
    LoadString0(2);
    wvsprintf( @String1, @String0, i );
    OscCon^.Insert( New( pOscCon, Init(
      pConnection(Msg.lParam),
      @String1,
      tick ) ) );
  end;
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.msOscDelCon( var Msg : tMessage );
function IsOscRec( con : pOscCon ) : boolean; far;
begin
  IsOscRec := ( con^.con = pConnection(Msg.lParam) );
end;
var
  ocon : pOscCon;
begin
  ocon := pOscCon( OscCon^.FirstThat( @IsOscRec ) );
  if ocon <> nil
  then begin
    OscCon^.Free(ocon);
    InvalidateRect( hWindow, nil, true );
    UpdateWindow( hWindow );
  end;
end;

procedure tOscilloscopeWindow.msOscIsRecCon( var Msg : tMessage );
function IsOscRec( con : pOscCon ) : boolean; far;
begin
  IsOscRec := ( con^.con = pConnection(Msg.lParam) );
end;
begin
  Msg.Result := Longint( OscCon^.FirstThat( @IsOscRec ) <> nil );
end;

procedure tOscilloscopeWindow.msChildClose( var msg : tMessage );
begin
  { Nicht schlie�en ! }
end;

function tOscilloscopeWindow.CanClose : boolean;
begin
  CanClose := true;
end;

procedure tOscilloscopeWindow.msTick( var msg : tMessage );
var
  yofs,
  height : integer;
procedure DoTick( OscCon : pOscCon ); far;
begin
  OscCon^.Tick( DragDC, tick, yofs, wPix, height );
  inc( yOfs, yInc );
end;
begin
  if msg.wParam = 1
  then begin
    height := yInc - txtH;
    inc(tick);
    yOfs := 0;
    DragDC := GetDC(hWindow);
    pScrollerOrg(Scroller)^.BeginZoom(DragDC);
    OscCon^.ForEach( @DoTick );
    pScrollerOrg(Scroller)^.ScrollBy(1,0);
    ReleaseDC(hWindow, DragDC);
  end;
end;

procedure tOscilloscopeWindow.msZoomAll(var Msg : tMessage);
var
  R, R_ : tRect;
procedure DoUnionRect(OscCon : pOscCon); far;
begin
  OscCon^.Rect(R_);
  with R_
  do begin
    left := left * wPix;
    right := right * wPix;
    top := 0;
    bottom := 1;
  end;
  UnionRect(R, R, R_);
end;
begin
  SetRectEmpty(R);
  OscCon^.ForEach(@DoUnionRect);
  if not IsRectEmpty(R)
  then begin
    InflateRect(R, 5, 1);
    pScrollerOrg(Scroller)^.SetRectZoom(R);
    cmOscOptimalH(Msg);
    InflateRect(R, -5, -1);
    with R
    do begin
      top := -yInc;
      bottom := yInc*(OscCon^.Count-1);
    end;
    InflateRect(R, 5, 5);
    pScrollerOrg(Scroller)^.SetRectZoom(R);
    UpdateWindow(hWindow);
  end;
end;

procedure tOscilloscopeWindow.WMRButtonDown(var Msg : tMessage);
var
  OscWinMenu,
  MainMenu,
  Menu : hMenu;
  CrsrPos : tPoint;
  s : pChar;
begin
  inherited WMRButtonDown(Msg);
  idx := (tPoint(Msg.lParam).Y+yInc) div yInc;
  OscWinMenu := LoadMenu( hRes, 'OSCWINMENU' );
  Menu := GetSubMenu(OscWinMenu, 0);
  if ( tPoint(Msg.lParam).Y>=-yInc ) and
     ( idx >= 0 ) and ( idx < OscCon^.Count )
  then begin
    s := pOscCon(OscCon^.At(idx))^.name;
    InsertMenu(
      Menu, 0,
      MF_BYPOSITION or MF_GRAYED,
      0, s );
  end
  else begin
    EnableMenuItem( Menu, cm_OscReset, MF_GRAYED );
    EnableMenuItem( Menu, cm_OscRename, MF_GRAYED );
    EnableMenuItem( Menu, cm_OscDelete, MF_GRAYED );
    EnableMenuItem( Menu, cm_OscHeight, MF_GRAYED );
  end;
  GetCursorPos(CrsrPos);
  { Raster. }
  MainMenu := GetMenu(Application^.MainWindow^.hWindow);
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
  TrackPopupMenu(
    Menu, 2,
    CrsrPos.X, CrsrPos.Y, 0,
    Application^.MainWindow^.hWindow, nil );
  DestroyMenu(Menu);
  DestroyMenu(OscWinMenu);
end;

procedure tOscilloscopeWindow.msOscLayPaint( var Msg : tMessage );
procedure DoLayPaint( OscCon : pOscCon ); far;
begin
  OscCon^.LayPaint( Msg.wParam, pPaintStruct(Msg.lParam) );
end;
begin
  OscCon^.ForEach( @DoLayPaint );
end;

procedure tOscilloscopeWindow.cmOscRename( var Msg : tMessage );
var s : pChar;
begin
  s := pOscCon(OscCon^.At(idx))^.name;
  Application^.ExecDialog(
    New(pTextDlg, Init(@Self, s, 7, StringLen)));
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.cmOscDelete( var Msg : tMessage );
begin
  OscCon^.AtFree(idx);
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.msSetCaption( var Msg : tMessage );
begin
  StrCopy( @String1, pChar(Msg.lParam) );
  LoadString0(3);
  StrCat( @String1, @String0 );
  SetCaption(@String1);
end;

type
  iOscHeightDlg = record
    height, width,
    txtH : integer
  end;
  pOscHeightDlg = ^tOscHeightDlg;
  tOscHeightDlg = object (tDialogSB)
    Input : Pointer;
    opt : integer;
    constructor Init(
      xParent : pWindowsObject; xInput : Pointer; xopt : integer);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure Optimal( var Msg : tMessage );
      virtual id_First + 1000;
  end;

constructor tOscHeightDlg.Init(
  xParent : pWindowsObject; xInput : Pointer; xopt : integer);
begin
  inherited Init( xParent, 'OSCHEIGHTDLG' );
  Input := xInput;
  opt := xopt;
end;

procedure tOscHeightDlg.SetupWindow;
var
  v : iOscHeightDlg;
begin
  inherited SetupWindow;
  v := iOscHeightDlg(Input^);
  with v
  do begin
    dec(height, txtH);
    SetDlgItemInt( hWindow, 100, Word(height), false );
    SetDlgItemInt( hWindow, 101, Word(width), false );
    SetDlgItemInt( hWindow, 102, Word(txtH), false );
  end;
end;

procedure tOscHeightDlg.OK(var Msg : tMessage);
var
  v : iOscHeightDlg;
begin
  with v
  do begin
    Word(height) := GetDlgItemInt( hWindow, 100, nil, false );
    Word(width) := GetDlgItemInt( hWindow, 101, nil, false );
    Word(txtH) := GetDlgItemInt( hWindow, 102, nil, false );
    inc(height, txtH);
    iOscHeightDlg(Input^) := v;
  end;
  inherited OK(Msg);
end;

procedure tOscHeightDlg.Optimal( var Msg : tMessage );
var
  txtH,
  height : integer;
begin
  Word(txtH) := GetDlgItemInt( hWindow, 102, nil, false );
  height := opt - txtH;
  SetDlgItemInt( hWindow, 100, Word(height), false );
end;

procedure tOscilloscopeWindow.cmOscHeight( var Msg : tMessage );
var
  R : tRect_;
  h, opt : integer;
begin
  GetClientRect(hWindow, tRect(R));
  with R
  do begin
    pScrollerOrg(Scroller)^.ZoomCoord(A);
    pScrollerOrg(Scroller)^.ZoomCoord(B);
    h := bottom-top-1;
  end;
  opt := h div OscCon^.Count;
  if Application^.ExecDialog(
       New(pOscHeightDlg, Init(@Self, @yInc, opt))) = id_ok
  then begin
    RasterIncX := wPix;
    RasterIncY := yInc;
    InvalidateRect( hWindow, nil, true );
    UpdateWindow( hWindow );
  end;
end;

procedure tOscilloscopeWindow.cmOscOptimalH( var Msg : tMessage );
var
  R : tRect_;
  h : integer;
begin
  GetClientRect(hWindow, tRect(R));
  with R
  do begin
    pScrollerOrg(Scroller)^.ZoomCoord(A);
    pScrollerOrg(Scroller)^.ZoomCoord(B);
    h := bottom-top-1;
  end;
  yInc := h div OscCon^.Count;
  RasterIncY := yInc;
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.cmOscReset( var Msg : tMessage );
begin
  pOscCon(OscCon^.At(idx))^.Reset(tick);
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.cmOscResetAll( var Msg : tMessage );
procedure DoReset( osccon : pOscCon ); far;
begin
  osccon^.Reset(tick);
end;
begin
  tick := 0;
  OscCon^.ForEach(@DoReset);
  InvalidateRect( hWindow, nil, true );
  UpdateWindow( hWindow );
end;

procedure tOscilloscopeWindow.cmHelpContext(var Msg : tMessage);
begin
  WinHelp(hWindow, HelpFileName, HELP_CONTEXT, 1010);
end;

procedure tOscilloscopeWindow.WMSysCommand(var Msg : tMessage);
begin
  case Msg.wParam of
    cm_HideOscWin : cmHideOscWin(Msg);
    cm_ShowCircuit : cmShowCircuit(Msg);
  else
    inherited WMSysCommand(Msg);
  end;
end;

procedure tOscilloscopeWindow.cmHideOscWin(var Msg : tMessage);
begin
  SendMessage( hWindow, ms_HideWindow, 0, 0 );
end;

procedure tOscilloscopeWindow.cmShowCircuit(var Msg : tMessage);
begin
  SendMessage( LayWin^.hWindow, ms_ShowWindow, 0, 0 );
end;

procedure tOscilloscopeWindow.msShowOscWin(var Msg : tMessage);
begin
  if IsWindowVisible(LayWin^.hWindow) then msShowWindow(Msg);
end;

procedure tOscilloscopeWindow.msHideOscWin(var Msg : tMessage);
begin
  msHideWindow(Msg);
end;

procedure tOscilloscopeWindow.wmClose( var Msg : tMessage );
begin
  if boolean(Msg.wParam)
  then inherited wmClose(Msg)
  else msHideWindow(Msg);
end;

{$ifdef undo}
procedure tOscilloscopeWindow.DelUndo;
begin
  OscCon^.FreeAll;

  tick := 0;
  yInc := 16;
  txtH := 5;
  wPix := 1;
  Raster := 1;
  RasterIncX := wPix;
  RasterIncY := yInc;
  RasterMulX := 5;
  RasterMulY := 1;
  crossX := 0;
  crossY := 2;
  State := ls_None;
end;
{$endif}

{ ------ rOscCon -------------------------------------------------------- }

const
  rOscCon : TStreamRec = (
     ObjType : riOscCon;
     VmtLink : Ofs(TypeOf(tOscCon)^);
     Load  : @tOscCon.Load;
     Store : @tOscCon.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rOscCon);
end.