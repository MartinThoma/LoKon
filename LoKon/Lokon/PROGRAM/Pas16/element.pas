unit Element;
{$I define.inc}

interface

uses
  LK_Const, Messages,
  Objects,
  Strings,
  WinTypes, WinProcs,
  OWindows, ODialogs,
  OWinEx, ScrolOrg,
  Graphic,
  Paint,
  EleWinCh,
  Item,
  Impulse,
  EleFile;

type
  pChapEle = ^tChapEle;
  tChapEle = object (tObject)
    Nr : Integer;
    Name : pChar;
    constructor Init(xName : pChar);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure ChangeName(s : pChar);
  end;

type
  pInOutCol = ^tInOutCol;
  tInOutCol = object (tObject)
    p : pWindowsObject;
    b : Boolean;
    constructor Init(xp : pWindowsObject; xb : Boolean);
    destructor Done; virtual;
  end;

type
  pGraphicArray = ^tGraphicArray;
  tGraphicArray = array [0..$00ff] of tGraphic;

type
  pElement = ^tElement;
  tElement = object (tChapEle)
    Graphic, Region : tGraphic;
    NumIn, NumOut, NumState : Integer;
    Input, Output : pPointArray;
    StGrFlag : Shortint;
    StateGraphic : pGraphicArray;
    InitVal : pIntegerArray;
    constructor Init(xName : pChar);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    function Copy : pElement; virtual;
    { StateGraphic. }
    procedure FreeStateGraphic;
    procedure NewStateGraphic;
    { InOut-Funktionen. }
    function PosInOut(Num : Integer) : Longint;
    procedure SetPosInOut(Num : Integer; Pt : tPoint);
    function NumInOut(Pt : tPoint; p : pPointArray; Num : Integer) : Integer;
    procedure IncIO(InOut : Byte { 0-In, 1-Out, 2-State }; Inc : Integer);
    function GetInOutNr(A : tPoint) : Integer;
    procedure ChangeInOut(xParent : pWindowsObject); virtual;
    procedure DelInOut; virtual;
    procedure ChangeInit(xParent : pWindowsObject);
    procedure ChangeInOutPos(xParent : pWindowsObject);
    procedure SetNumInOut(xNumIn, xNumOut, xNumState : Integer); virtual;
    function MaxNumIn : Integer; virtual;
    function MaxNumOut : Integer; virtual;
    function MaxNumState : Integer; virtual;
    { Funktionen für EleItem. }
    function GetInOutMemSize : Integer; virtual;
    function GetInOutMem : Pointer; virtual;
    procedure FreeInOutMem(p : Pointer); virtual;
    procedure ClearInOutMem(p, Con : Pointer); virtual;
    function CopyInOutMem(p : Pointer) : Pointer;
    function LoadInOutMem(var S : tStream; var p : Pointer):Boolean; virtual;
    procedure StoreInOutMem(var S : tStream; p : Pointer); virtual;
    function GetState(p : Pointer; s : Integer) : Integer;
    procedure SetState(p : Pointer; s : Integer; i : Integer);
    { Ausgabe/Darstellung. }
    procedure ChangeGraphic(xParent : pWindowsObject);
    procedure ChangeRegion(xParent : pWindowsObject);
    function CalcInOutRgn(Direction : Shortint) : hRgn;
    procedure PaintInOut(PaintDC : HDC; Direction : Shortint);
    procedure NotPaint(PaintDC : HDC; Direction : Shortint);
    function CalcRgn(Direction : Shortint) : hRgn;
    procedure Paint(
      PaintDC : HDC; Direction : Shortint; InOutMem : Pointer);
    function OutImpulse(
      InOutMem : pIntegerArray; Con : pConArray;
      Impulses : pCollection) : Boolean; virtual;
    function SendImpulse(
      InOutMem : Pointer; Con : pConArray;
      Num, Impulse : Integer;
      Impulses : pCollection) : Boolean; virtual;
{$ifdef layele}
    procedure SimStart(
      InOutMem : Pointer; hLayWin : HWND; p : pItem ); virtual;
    procedure EleTick( InOutMem : Pointer ); virtual;
    function GetMenu( menu : hMenu ) : hMenu; virtual;
    procedure ShowMacro( p : Pointer ); virtual;
{$endif layele}
  end;

type
  pTabEle = ^tTabEle;
  tTabEle = object (tElement)
    Tabular : pByteArray;
    Time : pIntegerArray;
    constructor Init(xName : pChar);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure SetNumInOut(xNumIn, xNumOut, xNumState : Integer); virtual;
    function MaxNumIn : Integer; virtual;
    function MaxNumOut : Integer; virtual;
    function MaxNumState : Integer; virtual;
    function TabSize : Integer;
    procedure ChangeInOut(xParent : pWindowsObject); virtual;
    procedure DelInOut; virtual;
    function OutImpulse(
      InOutMem : pIntegerArray; Con : pConArray;
      Impulses : pCollection) : Boolean; virtual;
  end;

type
  pBoolEle = ^tBoolEle;
  tBoolEle = object (tElement)
    NumMerke : Integer;
    Bool : pChar;
    constructor Init(xName : pChar);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure ChangeInOut(xParent : pWindowsObject); virtual;
    procedure DelInOut; virtual;
    function OutImpulse(
      InOutMem : pIntegerArray; Con : pConArray;
      Impulses : pCollection) : Boolean; virtual;
    function Syntax(Window : hWnd) : Boolean;
  end;

{$ifdef layele}
type
  pMacroOutImpulse = ^tMacroOutImpulse;
  tMacroOutImpulse = record
    InMem,
    StateMem : pIntegerArray;
    Con : pConArray;
    Impulses : pCollection;
  end;

type
  pMacroEle = ^tMacroEle;
  tMacroEle = object (tElement)
    version : word;
    layout : pStream;
    constructor Init(xName : pChar);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure ChangeInOut(xParent : pWindowsObject); virtual;
    procedure DelInOut; virtual;
    function OutImpulse(
      InOutMem : pIntegerArray; Con : pConArray;
      Impulses : pCollection) : Boolean; virtual;
    function hMacroWindow( p : Pointer ) : HWND;
    procedure SethMacroWindow( p : Pointer; wnd : HWND );
    function GetInOutMemSize : Integer; virtual;
    procedure FreeInOutMem(p : Pointer); virtual;
    function GetInOutMem : Pointer; virtual;
    procedure ClearInOutMem(p, Con : Pointer); virtual;
    function LoadInOutMem(var S : tStream; var p : Pointer):Boolean; virtual;
    procedure StoreInOutMem(var S : tStream; p : Pointer); virtual;
    procedure SimStart(
      InOutMem : Pointer; hLayWin : HWND; p : pItem ); virtual;
    procedure IncVersion;
    procedure EleTick( InOutMem : Pointer ); virtual;
    function GetMenu( menu : hMenu ) : hMenu; virtual;
    procedure ShowMacro( p : Pointer ); virtual;
  end;
{$endif}

implementation

{ ------ tChapEle ------------------------------------------------------- }

constructor tChapEle.Init(xName : pChar);
begin
  Nr := -1; { -1 bedeutet : hat noch keine Nummer. }
  Name := StrNew(xName);
end;

destructor tChapEle.Done;
begin
  StrDispose(Name);
end;

constructor tChapEle.Load(var S : tStream);
begin
  S.Read(Nr, SizeOf(Nr));
  Name := S.StrRead;
end;

procedure tChapEle.Store(var S : tStream);
begin
  S.Write(Nr, SizeOf(Nr));
  S.StrWrite(Name);
end;

procedure tChapEle.ChangeName(s : pChar);
begin
  StrDispose(Name);
  Name := StrNew(s);
end;

{ ------ tInOutPaint ---------------------------------------------------- }

type
  pInOutPaint = ^tInOutPaint;
  tInOutPaint = object ( tEleWinChild )
    Element : pElement;
    constructor Init(xParent : pWindowsObject; xElement : pElement);
    destructor Done; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function GetClassName : pChar; virtual;
    procedure SetupWindow; virtual;
    procedure SetCursorOfState(xState : Integer); virtual;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure WMMouseMove(var Msg : tMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonDown(var Msg : tMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg : tMessage);
      virtual wm_First + wm_LButtonUp;
    procedure msZoomAll(var Msg : tMessage);
      virtual ms_ZoomAll;
    procedure msExport(var Msg : tMessage);
      virtual ms_Export;
    procedure cmHelpContext(var Msg : tMessage);
      virtual cm_First + cm_HelpContext;
  end;

constructor tInOutPaint.Init(
  xParent : pWindowsObject; xElement : pElement);
var s : pChar;
begin
  GetMem(s, StrLen(LoadString0(144)) + StrLen(xElement^.Name) +  1);
  StrCopy(s, LoadString0(144));
  StrCat(s, xElement^.Name);
  inherited Init(xParent, s);
  StrDispose(s);
  Attr.Style :=
    ws_Child or ws_Visible or ws_ClipSiblings or
    ws_SysMenu or ws_Border or
    ws_VScroll or ws_HScroll;
  Element := xElement;
  State := ls_None;
end;

destructor tInOutPaint.Done;
begin
  if NotClose then SendMessage(EleWinParent^.hWindow, ms_NotClose, 0, 0);
  inherited Done;
end;

procedure tInOutPaint.GetWindowClass(var AWndClass: TWndClass);
begin
  inherited GetWindowClass(aWndClass);
  {AWndClass.cbClsExtra		:= 0;
  AWndClass.cbWndExtra		:= 0;
  AWndClass.hInstance		:= HInstance;}
  AWndClass.hIcon		:= LoadIcon(hRes, 'INOUTICON');
  AWndClass.hCursor		:= 0;
  AWndClass.hbrBackground := GetStockObject(White_Brush);
  {AWndClass.lpszMenuName	:= nil;
  AWndClass.lpszClassName	:= GetClassName;
  AWndClass.style		:= cs_HRedraw or cs_VRedraw;
  AWndClass.lpfnWndProc   	:= @InitWndProc;}
end;

function tInOutPaint.GetClassName : pChar;
begin
  GetClassName := 'WLKINOUTWIN';
end;

procedure tInOutPaint.SetupWindow;
begin
  inherited SetupWindow;
  PostMessage(hWindow, wm_Command, cm_ZoomAll, 0);
end;

procedure tInOutPaint.SetCursorOfState(xState : Integer);
begin
  case xState of
    ls_MoveInOut : SetCursor(LoadCursor(hRes, 'IDC_MOVEACTITEM'));
  end;
  inherited SetCursorOfState(xState);
end;

procedure tInOutPaint.MDI_Menu(b : Boolean);
var
  Menu : hMenu;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if b
  then begin
    InsertMenu(Menu, 2 + MenuInc,
      mf_Enabled + mf_ByPosition + mf_Popup,
      LoadMenu(hRes, 'GRAPHVIEW'), LoadString0(128));
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomAll);
    SendMessage(hMainWin, ms_ChildMenuPos, +1, 0);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos1);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos5);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos10);
  end
  else begin
    DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
    RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomAll);
    SendMessage(hMainWin, ms_ChildMenuPos, Word(-1), 0);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos1);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos5);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos10);
  end;
  SetRedrawSpeedbar;
end;

procedure tInOutPaint.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  Element^.Graphic.Paint(PaintDC, 0);
  Element^.PaintInOut(PaintDC, 0);
end;

type
  pMoveInOutRec = ^tMoveInOutRec;
  tMoveInOutRec = record
    idx : Integer;
    OldPos : tPoint;
  end;

procedure tInOutPaint.WMMouseMove(var Msg : tMessage);
begin
  inherited wmMouseMove(Msg);
  if State=ls_MoveInOut then
    with Element^, pMoveInOutRec(Poi)^
    do begin
      if idx>0
      then with Input^[idx-1] do DrawInOut(DragDC, X, Y, 0, idx)
      else with Output^[-(idx+1)] do DrawInOut(DragDC, X, Y, 0, idx);
      Element^.SetPosInOut(idx, tPoint(Msg.lParam));
      if idx>0
      then with Input^[idx-1] do DrawInOut(DragDC, X, Y, 0, idx)
      else with Output^[-(idx+1)] do DrawInOut(DragDC, X, Y, 0, idx);
    end
  else begin
    if Element^.GetInOutNr(tPoint(Msg.lParam))<>0
    then SetCursorOfState(ls_MoveInOut)
    else SetCursorActState;
  end;
end;

procedure tInOutPaint.WMLButtonDown(var Msg : tMessage);
var
  i : Integer;
  s : array [0..1] of char;
  R : tRect_;
begin
  inherited wmLButtonDown(Msg);
  if State=ls_None
  then begin
    i := Element^.GetInOutNr(tPoint(Msg.lParam));
    if i <> 0
    then begin
      GetMem(Poi, SizeOf(tMoveInOutRec));
      with pMoveInOutRec(Poi)^
      do begin
        idx := i;
        if i>0
        then OldPos := Element^.Input^[i-1]
        else OldPos := Element^.Output^[-(i+1)];
      end;
      State := ls_MoveInOut;
      SetCursorActState;
      BeginDrag;
    end;
  end;
end;

procedure tInOutPaint.WMLButtonUp(var Msg : tMessage);
var R : tRect_;
begin
  inherited wmLButtonUp(Msg);
  if State=ls_MoveInOut
  then begin
    State := ls_None;
    with pMoveInOutRec(Poi)^
    do begin
      R.A := OldPos;
      R.B := R.A;
      InflateRect(tRect(R), +5, +5);
      pScrollerOrg(Scroller)^.ClientCoord(R.A);
      pScrollerOrg(Scroller)^.ClientCoord(R.B);
      InvalidateRect(hWindow, @R, True);
      UpdateWindow(hWindow);
      if idx>0
      then R.A := Element^.Input^[idx-1]
      else R.A := Element^.Output^[-(idx+1)];
      R.B := R.A;
      InflateRect(tRect(R), +5, +5);
      pScrollerOrg(Scroller)^.ClientCoord(R.A);
      pScrollerOrg(Scroller)^.ClientCoord(R.B);
      InvalidateRect(hWindow, @R, True);
    end;
    FreeMem(Poi, SizeOf(tMoveInOutRec));
    EndDrag;
  end;
end;

procedure tInOutPaint.msZoomAll(var Msg : tMessage);
var
  R : tRect;
  Rgn : hRgn;
  i : Integer;
begin
  Rgn := Element^.CalcRgn(0);
  GetRgnBox(Rgn, R);
  DeleteObject(Rgn);
  with Element^
  do begin
    for i:=0 to NumIn-1 do
      with Input^[i]
      do begin
        if X<R.left then R.left:=X;
        if X>R.right then R.right:=X;
        if Y<R.top then R.top:=Y;
        if Y>R.bottom then R.bottom:=Y;
      end;
    for i:=0 to NumOut-1 do
      with Output^[i]
      do begin
        if X<R.left then R.left:=X;
        if X>R.right then R.right:=X;
        if Y<R.top then R.top:=Y;
        if Y>R.bottom then R.bottom:=Y;
      end;
  end;
  if not IsRectEmpty(R)
  then begin
    InflateRect(R, 5, 5);
    pScrollerOrg(Scroller)^.SetRectZoom(R);
  end;
end;

procedure tInOutPaint.msExport(var Msg : tMessage);
var
  s : pChar;
begin
  inherited msExport(Msg);
  if not Boolean(Msg.Result)
  then begin
    GetMem(s, StrLen(LoadString0(82)) + 2 {+4-2});
    wvsprintf(s, @String0, extName[Msg.wParam]);
    MessageBox(hWindow, s, LoadString0(96), mb_IconStop or mb_OK);
    StrDispose(s);
  end;
end;

procedure tInOutPaint.cmHelpContext(var Msg : tMessage);
begin
  WinHelp(hWindow, HelpFileName, HELP_CONTEXT, 510);
end;

{ ------ tInOutDlg ------------------------------------------------------ }

type
  pInOutDlg = ^tInOutDlg;
  tInOutDlg = object (tDialogEx)
    EleName : pChar;
    EleWinParent : pWindowsObject; { EleWin und }
    Idx : Integer; { Pos in ElementList. }
    constructor Init(
      xEleName : pChar; xParent : pWindowsObject;
      xName : pChar; i : Integer);
  end;

constructor tInOutDlg.Init(
  xEleName : pChar; xParent : pWindowsObject;
  xName : pChar; i : Integer);
begin
  inherited Init(xParent, xName);
  EleName := xEleName;
  EleWinParent := xParent;
  Idx := i;
end;

{ ------ tTimeDlg ------------------------------------------------------- }

const
  id_One  = 100;
  id_Ten  = 101;

type
  pTimeDlg = ^tTimeDlg;
  tTimeDlg = object (tDialogEx)
    NumOut : Integer;
    Time : pIntegerArray;
    Time_ : Pointer;
    constructor Init(
      xParent : pWindowsObject; xTime_ : Pointer; xNumOut : Integer);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure Cancel(var Msg : tMessage);
      virtual id_First + id_Cancel;
    procedure TimeFill(v : Integer);
    procedure idTen(var Msg : tMessage);
      virtual id_First + id_Ten;
    procedure idOne(var Msg : tMessage);
      virtual id_First + id_One;
    procedure wmVScroll(var Msg : tMessage);
      virtual wm_First + wm_VScroll;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tTimeDlg.Init(
  xParent : pWindowsObject; xTime_ : Pointer; xNumOut : Integer);
begin
  inherited Init(xParent, 'TIMEDLG');
  Time_ := xTime_;
  NumOut := xNumOut;
  GetMem(Time, NumOut * SizeOf(Integer));
  Move(Pointer(Time_^)^, Time^, NumOut * SizeOf(Integer));
end;

procedure tTimeDlg.SetupWindow;
var i : Integer;
begin
  inherited SetupWindow;
  { Benötigte Elemente aktivieren. }
  for i := 0 to NumOut-1
  do begin
    EnableWindow(GetItemHandle(200+i), True);
    EnableWindow(GetItemHandle(210+i), True);
    EnableWindow(GetItemHandle(230+i), True);
    SetDlgItemInt(hWindow, 210+i, Time^[i], False);
  end;
end;

procedure tTimeDlg.OK(var Msg : tMessage);
begin
  inherited OK(Msg);
  FreeMem(Pointer(Time_^), NumOut * SizeOf(Integer));
  pIntegerArray(Time_^) := Time;
end;

procedure tTimeDlg.Cancel(var Msg : tMessage);
begin
  inherited Cancel(Msg);
  FreeMem(Time, NumOut * SizeOf(Integer));
end;

procedure tTimeDlg.TimeFill(v : Integer);
var i : Integer;
begin
  for i := 0 to NumOut-1
  do begin
    Time^[i] := v;
    SetDlgItemInt(hWindow, 210+i, v, False);
  end;
end;

procedure tTimeDlg.idTen(var Msg : tMessage);
begin
  TimeFill(10);
end;

procedure tTimeDlg.idOne(var Msg : tMessage);
begin
  TimeFill(1);
end;

procedure tTimeDlg.wmVScroll(var Msg : tMessage);
var id : Integer;
procedure ScrollTime(var Pos : Integer);
begin
  with Msg
  do begin
    case wParam of
      sb_LineUp : inc(Pos);
      sb_LineDown : dec(Pos);
      {sb_PageUp : dec(Pos, 5);
      sb_PageDown : inc(Pos, 5);
      sb_ThumbTrack,
      sb_ThumbPosition : Pos := Msg.lParamLo;}
    end;
    if Pos <= 0
    then begin
      MessageBeep(mb_OK);
      Pos := 1;
    end;
    if Pos > 999
    then begin
      MessageBeep(mb_OK);
      Pos := 999;
    end;
    {SetScrollPos(lParamHi, sb_Ctl, Pos, False);}
    SetDlgItemInt(hWindow, id-20, Pos, False);
  end;
end;
begin
  id := GetDlgCtrlId(Msg.lParamHi);
  case id of
    230..239 : ScrollTime(Time^[id-230]);
    else inherited wmVScroll(Msg);
  end;
end;

procedure tTimeDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 525);
end;

{ ------ tTabularDlg ---------------------------------------------------- }

const
  id_InOutList    =  100;
  id_ListDescript =  101;
  id_Time         =  102;
  id_TabZero      =  105;
  id_TabOne       =  106;

  id_NewIn        =  150;
  id_DelIn        =  151;
  id_NewOut       =  152;
  id_DelOut       =  153;
  id_NewState     =  154;
  id_DelState     =  155;

type
  pTabularDlg = ^tTabularDlg;
  tTabularDlg = object (tInOutDlg)
    Tab, TabOrg : pTabEle;
    constructor Init(
      xTab : pTabEle; xParent : pWindowsObject; i : Integer);
    constructor Init_(
      xName : pChar; xTab : pTabEle;
      xParent : pWindowsObject; i : Integer);
    procedure SetupWindow; virtual;
    procedure SetupDlg;
    procedure wmCommand(var Msg : tMessage);
      virtual wm_First + wm_Command;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure Cancel(var Msg : tMessage);
      virtual id_First + id_Cancel;
    procedure idTime(var Msg : tMessage);
      virtual id_First + id_Time;
    procedure idNewIn(var Msg : tMessage);
      virtual id_First + id_NewIn;
    procedure idDelIn(var Msg : tMessage);
      virtual id_First + id_DelIn;
    procedure idNewOut(var Msg : tMessage);
      virtual id_First + id_NewOut;
    procedure idDelOut(var Msg : tMessage);
      virtual id_First + id_DelOut;
    procedure idNewState(var Msg : tMessage);
      virtual id_First + id_NewState;
    procedure idDelState(var Msg : tMessage);
      virtual id_First + id_DelState;
    procedure idTabZero(var Msg : tMessage);
      virtual id_First + id_TabZero;
    procedure idTabOne(var Msg : tMessage);
      virtual id_First + id_TabOne;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tTabularDlg.Init(
  xTab : pTabEle; xParent : pWindowsObject; i : Integer);
begin
  Init_('TABULARDLG', xTab, xParent, i);
end;

constructor tTabularDlg.Init_(
  xName : pChar; xTab : pTabEle; xParent : pWindowsObject; i : Integer);
begin
  inherited Init(xTab^.Name, xParent, xName, i);
  TabOrg := xTab;
  Tab := pTabEle(TabOrg^.Copy);
end;

procedure tTabularDlg.SetupWindow;
var
  s : pChar;
  i : Integer;
begin
  inherited SetupWindow;

  { Caption. }
  i := GetWindowTextLength(hWindow);
  GetMem(s, i + StrLen(EleName) + 4);
  GetWindowText(hWindow, s, i+1);
  StrCat(s, ' - ');
  StrCat(s, EleName);
  SetWindowText(hWindow, s);
  StrDispose(s);

  { Schriftart mit fester Breite
    für die Tabelle setzen. }
  SendDlgItemMsg(id_ListDescript, wm_SetFont,
    GetStockObject(System_Fixed_Font), 0);
  SendDlgItemMsg(id_InOutList, wm_SetFont,
    GetStockObject(System_Fixed_Font), 0);

  SetupDlg;
end;

procedure tTabularDlg.SetupDlg;
var
  DC : HDC;
  i, j, k, m : Integer;
  s, s_ : pChar;
begin
  with Tab^
  do begin

    { z9..z0 e9..e0 - a9..a0 z9..z0 }
    k := (NumIn + NumOut + (2*NumState)) * 2;
    if NumState = 0
    then inc(k, 3)
    else inc(k, 5);

    { InOutText }
    GetMem(s, k);
    if NumState = 0
    then begin
      LoadString0(1057);
      StrLCopy(s, @String0[(10-NumIn)*2], NumIn*2);
    end
    else begin
      LoadString0(1056);
      StrLCopy(s, @String0[(10-NumState)*2], NumState*2);
      LoadString0(1057);
      StrLCat(
        s, @String0[(10-NumIn)*2], StrLen(s) + (NumIn*2));
    end;
    StrCat(s, '  ');
    LoadString0(1058);
    StrLCat(
      s, @String0[(10-NumOut)*2], StrLen(s) + (NumOut*2));
    if NumState > 0
    then begin
      LoadString0(1056);
      StrLCat(
        s, @String0[(10-NumState)*2], StrLen(s) + (NumState*2));
    end;
    SetWindowText(GetDlgItem(hWindow, id_ListDescript), s);
    StrDispose(s);

    { ListBox }
    SendDlgItemMsg(id_InOutList, lb_ResetContent, 0, 0);
    k := ( (NumIn + NumOut + (2*NumState)) * 2 ) + 3;
    GetMem(s, k);
    FillChar(s^, k-2, ' ');
    s[k-1] := #0;
    s[((NumState+NumIn)*2)+1] := '-';

    for i := 0 to (Word(1) shl (NumIn+NumState))-1
    do begin
      k := 1;
      { z9..z0e9..e0 }
      for j := NumState+NumIn-1 downto 0
      do begin
        if WordBool(i and (Word(1) shl j))
        then s[k] := '1'
        else s[k] := '0';
        inc(k, 2);
      end;
      inc(k, 2);
      { a9..a0 }
      for j := NumOut-1 downto 0
      do begin
        m := ((NumOut+NumState)*i) + j;
        if ByteBool(Tabular^[m shr 3] and (Word(1) shl (m and $07)))
        then s[k] := '1'
        else s[k] := '0';
        inc(k, 2);
      end;
      { z9..z0 }
      for j := NumState-1 downto 0
      do begin
        m := ((NumOut+NumState)*i) + NumOut+ j;
        if ByteBool(Tabular^[m shr 3] and (Word(1) shl (m and $07)))
        then s[k] := '1'
        else s[k] := '0';
        inc(k, 2);
      end;
      SendDlgItemMsg(
        id_InOutList, lb_AddString, 0, Longint(s));
    end;

    { CheckBoxes }
    for i := 0 to 9
    do begin
      SendDlgItemMsg(200+i, bm_SetCheck, 0, 0);
      EnableWindow(GetItemHandle(200+i), i<NumOut);
    end;
    for i := 0 to 9
    do begin
      SendDlgItemMsg(200+i, bm_SetCheck, 0, 0);
      EnableWindow(GetItemHandle(210+i), i<NumIn);
    end;
    for i := 0 to 9
    do begin
      EnableWindow(GetItemHandle(220+i), i<NumState);
      EnableWindow(GetItemHandle(230+i), i<NumState);
    end;

    { +/- Schalter }
    EnableWindow(GetItemHandle(id_NewState), NumState<MaxNumState);
    EnableWindow(GetItemHandle(id_DelState), NumState>0);
    EnableWindow(GetItemHandle(id_NewIn), NumIn<MaxNumIn);
    EnableWindow(GetItemHandle(id_DelIn), NumIn>0);
    EnableWindow(GetItemHandle(id_NewOut), NumOut<MaxNumOut);
    EnableWindow(GetItemHandle(id_DelOut), NumOut>0);
  end;

  if SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0) < 0
  then SendDlgItemMsg(id_InOutList, lb_SetCurSel, 0, 0);
  SendMessage(hWindow, wm_Command, id_InOutList, lbn_SelChange shl 16);
end;

procedure tTabularDlg.wmCommand(var Msg : tMessage);
procedure lbnSelChange;
var
  i, k, m : Integer;
begin
  with Tab^
  do begin
    k := SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0);
    for i := 0 to NumState-1 do
      SendDlgItemMsg(
        220+i, bm_SetCheck, k and (Word(1) shl (Tab^.NumIn+i)), 0);
    for i := 0 to Tab^.NumIn-1 do
      SendDlgItemMsg(
        210+i, bm_SetCheck, k and (Word(1) shl i), 0);
    k := k * (Tab^.NumOut+NumState);
    for i := 0 to Tab^.NumOut-1
    do begin
      m := k+i;
      if ByteBool(Tabular^[m shr 3] and (Byte(1) shl (m and $07)))
      then m := Word(True)
      else m := Word(False);
      SendDlgItemMsg(200+i, bm_SetCheck, m, 0);
    end;
    for i := 0 to NumState-1
    do begin
      m := k+Tab^.NumOut+i;
      if ByteBool(Tabular^[m shr 3] and (Byte(1) shl (m and $07)))
      then m := Word(True)
      else m := Word(False);
      SendDlgItemMsg(230+i, bm_SetCheck, m, 0);
    end;
  end;
end;
procedure idInOutList;
begin
  case Msg.lParamHi of
    lbn_SelChange : lbnSelChange;
  end;
end;
procedure idOut;
var
  s : pChar;
  i, j, k, l : Integer;
begin
  with Tab^
  do begin
    j := Msg.wParam - 200;
    i := SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0);
    k := (i * (Tab^.NumOut+NumState)) + j;
    Tabular^[k shr 3] := Tabular^[k shr 3] xor (Word(1) shl (k and $07));
    l := SendDlgItemMsg(id_InOutList, lb_GetTextLen, i, 0)+1;
    GetMem(s, l);
    SendDlgItemMsg(id_InOutList, lb_GetText, i, Longint(s));
    dec(l, ((NumState+j)*2)+2);
    if ByteBool(Tabular^[k shr 3] and (Word(1) shl (k and $07)))
    then s[l] := '1'
    else s[l] := '0';
  end;
  SendDlgItemMsg(id_InOutList, lb_DeleteString, i, 0);
  SendDlgItemMsg(id_InOutList, lb_InsertString, i, Longint(s));
  SendDlgItemMsg(id_InOutList, lb_SetCurSel, i, 0);
  StrDispose(s);
end;
procedure idIn;
begin
  SendDlgItemMsg(id_InOutList, lb_SetCurSel,
    SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0) xor
     (Word(1) shl (Msg.wParam-210)), 0);
  lbnSelChange;
end;
procedure idStIn;
begin
  SendDlgItemMsg(id_InOutList, lb_SetCurSel,
    SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0) xor
     (Word(1) shl (Tab^.NumIn+Msg.wParam-220)), 0);
  lbnSelChange;
end;
procedure idStOut;
var
  s : pChar;
  i, j, k, l : Integer;
begin
  with Tab^
  do begin
    j := Msg.wParam - 230;
    i := SendDlgItemMsg(id_InOutList, lb_GetCurSel, 0, 0);
    k := (i * (Tab^.NumOut+NumState)) + Tab^.NumOut + j;
    Tabular^[k shr 3] := Tabular^[k shr 3] xor (Word(1) shl (k and $07));
    l := SendDlgItemMsg(id_InOutList, lb_GetTextLen, i, 0)+1;
    GetMem(s, l);
    SendDlgItemMsg(id_InOutList, lb_GetText, i, Longint(s));
    dec(l, (j*SizeOf(Integer))+2);
    if ByteBool(Tabular^[k shr 3] and (Word(1) shl (k and $07)))
    then s[l] := '1'
    else s[l] := '0';
    SendDlgItemMsg(id_InOutList, lb_DeleteString, i, 0);
    SendDlgItemMsg(id_InOutList, lb_InsertString, i, Longint(s));
    SendDlgItemMsg(id_InOutList, lb_SetCurSel, i, 0);
    StrDispose(s);
  end;
end;
begin
  case Msg.wParam of
    id_InOutList : idInOutList;
    200..209 : idOut;
    210..219 : idIn;
    220..229 : idStIn;
    230..239 : idStOut;
    else inherited wmCommand(Msg);
  end;
end;

procedure tTabularDlg.OK(var Msg : tMessage);
var GS : tGlobalStream;
begin
  TabOrg^.Done;
  GS.Init;
  Tab^.Store(GS);
  Dispose(Tab, Done);
  GS.Seek(0);
  TabOrg^.Load(GS);
  GS.Done;
  EndDlg(id_OK);
end;

procedure tTabularDlg.Cancel(var Msg : tMessage);
begin
  Dispose(Tab, Done);
  EndDlg(id_Cancel);
end;

procedure tTabularDlg.idTime(var Msg : tMessage);
begin
  with Tab^ do
    Application^.ExecDialog(New(pTimeDlg, Init(@Self, @Time, NumOut)));
end;

procedure tTabularDlg.idNewIn(var Msg : tMessage);
begin
  Tab^.IncIO(0, +1);
  SetupDlg;
end;

procedure tTabularDlg.idDelIn(var Msg : tMessage);
begin
  Tab^.IncIO(0, -1);
  SetupDlg;
end;

procedure tTabularDlg.idNewOut(var Msg : tMessage);
begin
  Tab^.IncIO(1, +1);
  SetupDlg;
end;

procedure tTabularDlg.idDelOut(var Msg : tMessage);
begin
  Tab^.IncIO(1, -1);
  SetupDlg;
end;

procedure tTabularDlg.idNewState(var Msg : tMessage);
begin
  Tab^.IncIO(2, +1);
  SetupDlg;
end;

procedure tTabularDlg.idDelState(var Msg : tMessage);
begin
  Tab^.IncIO(2, -1);
  SetupDlg;
end;

procedure tTabularDlg.idTabZero(var Msg : tMessage);
begin
  with Tab^ do FillChar(Tabular^, TabSize, $00);
  SetupDlg;
end;

procedure tTabularDlg.idTabOne(var Msg : tMessage);
begin
  with Tab^ do FillChar(Tabular^, TabSize, $ff);
  SetupDlg;
end;

procedure tTabularDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 521);
end;

{ ------ tInOutCol ------------------------------------------------------ }

constructor tInOutCol.Init(xp : pWindowsObject; xb : Boolean);
begin
  p := xp;
  b := xb;
end;

destructor tInOutCol.Done;
begin
  Dispose(p, Done);
end;

{ ------ tGrDlg --------------------------------------------------------- }

const
  id_RadioOn  = 100;
  id_RadioVal = 101;
  id_StateGr  = 102;
  id_BackGr   = 103;

type
  pGrDlg = ^tGrDlg;
  tGrDlg = object (tDialogEx)
    StGrFlag_ : Shortint;
    Element : pElement;
    constructor Init(xParent : pWindowsObject; xElement : pElement);
    procedure SetupWindow; virtual;
    procedure SetupDlg;
    procedure idRadioOn(var Msg : tMessage);
      virtual id_First + id_RadioOn;
    procedure idRadioVal(var Msg : tMessage);
      virtual id_First + id_RadioVal;
    procedure idStateGr(var Msg : tMessage);
      virtual id_First + id_StateGr;
    procedure idBackGr(var Msg : tMessage);
      virtual id_First + id_BackGr;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tGrDlg.Init(
  xParent : pWindowsObject; xElement : pElement);
begin
  inherited Init(xParent, 'GRDLG');
  StGrFlag_ := xElement^.StGrFlag;
  Element := xElement;
end;

procedure tGrDlg.SetupWindow;
begin
  inherited SetupWindow;
  SetupDlg;
end;

procedure tGrDlg.SetupDlg;
var i : Integer;
begin
  if StGrFlag_ = 0
  then begin
    for i := 0 to Element^.NumState-1
    do begin
      EnableWindow(GetItemHandle(220+i), True);
      EnableWindow(GetItemHandle(230+i), False);
      CheckDlgButton(hWindow, 230+i, 0);
    end;
    CheckDlgButton(hWindow, id_RadioOn, 1);
    CheckDlgButton(hWindow, 220, 1);
  end;
  if StGrFlag_ = 1
  then begin
    for i := 0 to Element^.NumState-1
    do begin
      EnableWindow(GetItemHandle(220+i), False);
      CheckDlgButton(hWindow, 220+i, 0);
      EnableWindow(GetItemHandle(230+i), True);
    end;
    CheckDlgButton(hWindow, id_RadioVal, 1);
  end;
end;

procedure tGrDlg.idRadioOn(var Msg : tMessage);
begin
  if not(StGrFlag_=0)
  then begin
    StGrFlag_ := 0;
    SetupDlg;
  end;
end;

procedure tGrDlg.idRadioVal(var Msg : tMessage);
begin
  if not(StGrFlag_=1)
  then begin
    StGrFlag_ := 1;
    SetupDlg;
  end;
end;

procedure tGrDlg.idStateGr(var Msg : tMessage);
var
  k, i : Integer;
begin
  if WordBool(IsDlgButtonChecked(hWindow, id_RadioOn))
  then StGrFlag_ := 0;
  if WordBool(IsDlgButtonChecked(hWindow, id_RadioVal))
  then StGrFlag_ := 1;
  if StGrFlag_ <> Element^.StGrFlag
  then begin
    Element^.FreeStateGraphic;
    Element^.StGrFlag := StGrFlag_;
    Element^.NewStateGraphic;
  end;
  { Grafik-Nummer. }
  case StGrFlag_ of
    0 :
      begin
        for i := 0 to Element^.NumState-1
        do begin
          if WordBool(IsDlgButtonChecked(hWindow, 220+i))
          then k := i;
        end;
      end;
    1 :
      begin
        k := 0;
        for i := Element^.NumState-1 downto 0
        do begin
          k := k shl 1;
          if WordBool(IsDlgButtonChecked(hWindow, 230+i))
          then inc(k);
        end;
      end;
  end;
  EndDlg($4000 or k);
end;

procedure tGrDlg.idBackGr(var Msg : tMessage);
begin
  EndDlg($5000);
end;

procedure tGrDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 600);
end;

{ ------ tElement ------------------------------------------------------- }

constructor tElement.Init(xName : pChar);
begin
  inherited Init(xName);
  Graphic.Init;
  Region.Init;
  NumIn := 0;
  NumOut := 0;
  NumState := 0;
  GetMem(Input, 0);
  GetMem(Output, 0);
  StGrFlag := 0;
  StateGraphic := nil;
  InitVal := nil;
end;

destructor tElement.Done;
begin
  Graphic.Done;
  Region.Done;
  FreeMem(Input, NumIn * SizeOf(tPoint));
  FreeMem(Output, NumOut * SizeOf(tPoint));
  FreeStateGraphic;
  FreeMem(InitVal, (NumIn+NumState) * SizeOf(Integer));
  inherited Done;
end;

constructor tElement.Load(var S : tStream);
var i : Integer;
begin
  inherited Load(S);
  Graphic.Load(S);
  Region.Load(S);
  S.Read(NumIn, SizeOf(NumIn) + SizeOf(NumOut) + SizeOf(NumState));
  GetMem(Input, NumIn * SizeOf(tPoint));
  S.Read(Input^, NumIn * SizeOf(tPoint));
  GetMem(Output, NumOut * SizeOf(tPoint));
  S.Read(Output^, NumOut * SizeOf(tPoint));
  if NumState > 0
  then begin
    S.Read(StGrFlag, SizeOf(StGrFlag));
    if StGrFlag = 0
    then begin
      GetMem(StateGraphic, NumState * SizeOf(tGraphic));
      for i := 0 to NumState-1 do
        StateGraphic^[i].Load(S);
    end
    else begin
      GetMem(StateGraphic, (Word(1) shl NumState) * SizeOf(tGraphic));
      for i := 0 to (Word(1) shl NumState)-1 do
        StateGraphic^[i].Load(S);
    end;
  end
  else StGrFlag := 0;
  GetMem(InitVal, (NumIn+NumState) * SizeOf(Integer));
  S.Read(InitVal^, (NumIn+NumState) * SizeOf(Integer));
end;

procedure tElement.Store(var S : tStream);
var i : Integer;
begin
  inherited Store(S);
  Graphic.Store(S);
  Region.Store(S);
  S.Write(NumIn, SizeOf(NumIn) + SizeOf(NumOut) + SizeOf(NumState));
  S.Write(Input^, NumIn * SizeOf(tPoint));
  S.Write(Output^, NumOut * SizeOf(tPoint));
  if NumState > 0
  then begin
    S.Write(StGrFlag, SizeOf(StGrFlag));
    if StGrFlag = 0
    then begin
      for i := 0 to NumState-1 do
        StateGraphic^[i].Store(S);
    end
    else begin
      for i := 0 to (Word(1) shl NumState)-1 do
        StateGraphic^[i].Store(S);
    end;
  end;
  S.Write(InitVal^, (NumIn+NumState) * SizeOf(Integer));
end;

function tElement.Copy : pElement;
var
  S : tGlobalStream;
  p : pElement;
begin
  S.Init;
  S.Put(@Self);
  S.Seek(0);
  p := pElement(S.Get);
  S.Done_;
  Copy:=p;
end;

procedure tElement.FreeStateGraphic;
var i : Integer;
begin
  if NumState > 0
  then begin
    if StGrFlag = 0
    then begin
      for i := 0 to NumState-1 do
        StateGraphic^[i].Done;
      FreeMem(StateGraphic, NumState * SizeOf(tGraphic));
    end
    else begin
      for i := 0 to (Word(1) shl NumState)-1 do
        StateGraphic^[i].Done;
      FreeMem(
        StateGraphic,
        (Word(1) shl NumState) * SizeOf(tGraphic));
    end;
  end;
end;

procedure tElement.NewStateGraphic;
var i : Integer;
begin
  if NumState > 0
  then begin
    if StGrFlag = 0
    then begin
      GetMem(StateGraphic, NumState * SizeOf(tGraphic));
      for i := 0 to NumState-1 do
        StateGraphic^[i].Init;
    end
    else begin
      GetMem(
        StateGraphic,
        (Word(1) shl NumState) * SizeOf(tGraphic));
      for i := 0 to (Word(1) shl NumState)-1 do
        StateGraphic^[i].Init;
    end;
  end
  else StateGraphic := nil;
end;

function tElement.PosInOut(Num : Integer) : Longint;
begin
  if Num > 0
  then PosInOut := Longint(Input^[Num-1])
  else PosInOut := Longint(Output^[(-Num)-1])
end;

procedure tElement.SetPosInOut(Num : Integer; Pt : tPoint);
begin
  if Num > 0
  then Input^[Num-1] := Pt
  else Output^[(-Num)-1] := Pt;
end;

function tElement.NumInOut(Pt : tPoint; p : pPointArray;
  Num : Integer) : Integer;
var i : Integer;
begin
  NumInOut := -1;
  for i := 0 to Num-1 do
    if EqualPt(p^[i], Pt) then NumInOut := i;
end;

procedure tElement.IncIO(InOut : Byte; Inc : Integer);
begin
  case InOut of
    0 : SetNumInOut(NumIn+Inc, NumOut, NumState);
    1 : SetNumInOut(NumIn, NumOut+Inc, NumState);
    2 : SetNumInOut(NumIn, NumOut, NumState+Inc);
  end;
end;

function tElement.MaxNumIn : Integer;
begin
  MaxNumIn := 30; { Wegen der DLGs }
end;

function tElement.MaxNumOut : Integer;
begin
  MaxNumOut := 30; { Wegen der DLGs }
end;

function tElement.MaxNumState : Integer;
begin
  MaxNumState := 30; { Wegen der DLGs }
end;

procedure tElement.ChangeInOut(xParent : pWindowsObject);
begin
  Abstract;
end;

procedure tElement.DelInOut;
begin
  Abstract;
end;

type
  pInitDlg = ^tInitDlg;
  tInitDlg = object (tDialogEx)
    Ele : pElement;
    constructor Init(xParent : pWindowsObject; xEle : pElement);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tInitDlg.Init(xParent : pWindowsObject; xEle : pElement);
begin
  with xEle^ do
    if (NumIn>10) or (NumState>10)
    then inherited Init(xParent, 'INIT2DLG')
    else inherited Init(xParent, 'INITDLG');
  Ele := xEle;
end;

procedure tInitDlg.SetupWindow;
var i : Integer;
begin
  inherited SetupWindow;
  with Ele^
  do begin
    for i := 0 to NumIn-1
    do begin
      EnableWindow(GetItemHandle(200+i), True);
      CheckDlgButton(hWindow, 200+i, Word(InitVal^[i]));
    end;
    for i := 0 to NumState-1
    do begin
      EnableWindow(GetItemHandle(300+i), True);
      CheckDlgButton(hWindow, 300+i, Word(InitVal^[NumIn+i]));
    end;
  end;
end;

procedure tInitDlg.OK(var Msg : tMessage);
var i : Integer;
begin
  with Ele^
  do begin
    for i := 0 to NumIn-1 do
      InitVal^[i] := Integer(IsDlgButtonChecked(hWindow, 200+i));
    for i := 0 to NumState-1 do
      InitVal^[NumIn+i] := Integer(IsDlgButtonChecked(hWindow, 300+i));
  end;
  SendMessage(Parent^.hWindow, ms_NotClose, 0, 0);
  EndDlg(id_OK);
end;

procedure tElement.ChangeInit(xParent : pWindowsObject);
begin
  Application^.ExecDialog(New(pInitDlg, Init(xParent, @Self)));
end;

procedure tElement.ChangeInOutPos(xParent : pWindowsObject);
begin
  SendMessage(
    hMainWin, ms_NewWin, 0,
    Longint(New(pInOutPaint, Init(xParent, @Self))));
end;

procedure tElement.ChangeGraphic(xParent : pWindowsObject);
var s : pChar;
procedure ChangeBg;
begin
  GetMem(s, StrLen(LoadString0(50)) + StrLen(Name) - 1{+1-2});
  wvsprintf(s, @String0, Name);
  Graphic.ChangeGraphic(s, xParent, nil, Nr);
  StrDispose(s);
end;
procedure StateGr(k : Integer);
var
  p : array [0..3] of Integer;
  s : pChar;
begin
  pChar((@p)^) := Name;
  p[2] := k;
  p[3] := 0;
  GetMem(s, StrLen(LoadString0(53)) + StrLen(Name) - 3{+1-6+2});
  wvsprintf(s, @String0, p);
  StateGraphic^[k].ChangeGraphic(s, xParent, @Graphic, Nr);
  StrDispose(s);
end;
var
  k : Integer;
begin
  if NumState = 0
  then ChangeBg
  else begin
    k := Application^.ExecDialog(New(pGrDlg, Init(xParent, @Self)));
    case k of
      $4000..$4fff : StateGr(k and $3fff);
      $5000 : ChangeBg;
    end;
  end;
end;

procedure tElement.ChangeRegion(xParent : pWindowsObject);
var
  s : pChar;
begin
  GetMem(s, StrLen(LoadString0(54)) + StrLen(Name) - 1{+1-2});
  wvsprintf(s, @String0, Name);
  Region.ChangeRegion(s, xParent, @Graphic, Nr);
  StrDispose(s);
end;

function tElement.GetInOutNr(A : tPoint) : Integer;
var
  i : Integer;
begin
  i := NumInOut(A, Input, NumIn);
  if i >= 0
  then GetInOutNr := i + 1
  else begin
    i := NumInOut(A, Output, NumOut);
    if i >= 0
    then GetInOutNr := -(i + 1)
    else GetInOutNr := 0;
  end;
end;

procedure tElement.SetNumInOut(xNumIn, xNumOut, xNumState : Integer);
var
  q : pPointArray;
  p : pIntegerArray;
  i : Integer;
begin
  if xNumIn <> NumIn
  then begin
    GetMem(q, xNumIn*SizeOf(tPoint));
    if xNumIn < NumIn
    then Move(Input^, q^, xNumIn*SizeOf(tPoint))
    else begin
      Move(Input^, q^, NumIn*SizeOf(Pointer));
      FillChar(q^[NumIn], (xNumIn-NumIn)*SizeOf(tPoint), $00);
    end;
    FreeMem(Input, NumIn*SizeOf(tPoint));
    Input := q;
  end;
  if xNumOut <> NumOut
  then begin
    GetMem(q, xNumOut*SizeOf(tPoint));
    if xNumOut < NumOut
    then Move(Output^, q^, xNumOut*SizeOf(tPoint))
    else begin
      Move(Output^, q^, NumOut*SizeOf(Pointer));
      FillChar(q^[NumOut], (xNumOut-NumOut)*SizeOf(tPoint), $00);
    end;
    FreeMem(Output, NumOut*SizeOf(tPoint));
    Output := q;
  end;
  if (xNumIn <> NumIn) or (xNumState <> NumState)
  then begin
    i := xNumIn + xNumState;
    GetMem(p, i*SizeOf(Integer));
    if i < (NumIn+NumState)
    then Move(InitVal^, p^, i*SizeOf(Integer))
    else begin
      Move(InitVal^, p^, (NumIn+NumState)*SizeOf(Integer));
      FillChar(p^[NumIn+NumState], (i-NumIn-NumState)*SizeOf(Integer), 0);
    end;
    FreeMem(InitVal, (NumIn+NumState) * SizeOf(Integer));
    InitVal := p;
  end;
  NumIn := xNumIn;
  NumOut := xNumOut;
  if NumState <> xNumState
  then begin
    FreeStateGraphic;
    NumState := xNumState;
    NewStateGraphic;
  end;
end;

function tElement.GetInOutMemSize : Integer;
begin
  GetInOutMemSize := (NumIn+NumState) * SizeOf(Integer);
end;

function tElement.GetInOutMem : Pointer;
var
  p : Pointer;
begin
  { Eingangs- und Zustandsimpulse merken. }
  GetMem(p, GetInOutMemSize);
  ClearInOutMem(p, nil);
  GetInOutMem := p;
end;

procedure tElement.FreeInOutMem(p : Pointer);
begin
  FreeMem(p, GetInOutMemSize);
end;

procedure tElement.ClearInOutMem(p, Con : Pointer);
var
  i : Integer;
begin
                  { NICHT GetInOutMemSize wegen tMacroEle }
  Move(InitVal^, p^, (NumIn+NumState) * SizeOf(Integer));
  if Con <> nil then
    for i := 0 to NumIn-1 do
      if pConArray(Con)^[i].Con <> nil
      then pIntegerArray(p)^[i] := 0;
end;

function tElement.CopyInOutMem(p : Pointer) : Pointer;
var
  p_ : Pointer;
begin
  p_ := GetInOutMem;
  Move(p^, p_^, GetInOutMemSize);
  CopyInOutMem := p_;
end;

function tElement.LoadInOutMem(var S : tStream; var p : Pointer) : Boolean;
var
  i : Integer;
  p_ : Pointer;
begin
  S.Read(i, SizeOf(Integer));
  if i = GetInOutMemSize
  then begin
    GetMem(p, i);
    S.Read(p^, i);
    LoadInOutMem := True;
  end
  else begin
    GetMem(p_, i);
    S.Read(p_^, i);
    FreeMem(p_, i);
    GetMem(p, GetInOutMemSize);
    ClearInOutMem(p, nil);
    LoadInOutMem := False;
  end;
end;

procedure tElement.StoreInOutMem(var S : tStream; p : Pointer);
var
  i : Integer;
begin
  i := GetInOutMemSize;
  S.Write(i, SizeOf(Integer));
  S.Write(p^, i);
end;

function tElement.GetState(p : Pointer; s : Integer) : Integer;
begin
  GetState := pIntegerArray(p)^[NumIn+s];
end;

procedure tElement.SetState(p : Pointer; s : Integer; i : Integer);
begin
  pIntegerArray(p)^[NumIn+s] := i;
end;

procedure tElement.PaintInOut(PaintDC : HDC; Direction : Shortint);
var
  Font : hFont;
  i : Integer;
begin
  Font := SetInOutFont(PaintDC, Direction);
  for i := 0 to NumIn-1 do
    with Input^[i] do
      DrawInOut(PaintDC, X, Y, Direction, i+1);
  for i := 0 to NumOut-1 do
    with Output^[i] do
      DrawInOut(PaintDC, X, Y, Direction, -(i+1));
  DeleteObject(Font);
end;

procedure tElement.NotPaint(PaintDC : HDC; Direction : Shortint);
begin
  SelectObject(PaintDC, DrawPen);
  Region.Paint_(PaintDC, Direction);
end;

procedure tElement.Paint(
  PaintDC : HDC; Direction : Shortint; InOutMem : Pointer);
var k, i : Integer;
begin
  SelectObject(PaintDC, DrawPen);
  Graphic.Paint(PaintDC, Direction);
  if StGrFlag = 0
  then begin
    for i := 0 to NumState-1 do
      if WordBool(pIntegerArray(InOutMem)^[NumIn+i])
      then StateGraphic^[i].Paint(PaintDC, Direction);
  end
  else begin
    k := 0;
    for i := NumState-1 downto 0
    do begin
      k := k shl 1;
      if WordBool(pIntegerArray(InOutMem)^[NumIn+i])
      then inc(k);
    end;
    StateGraphic^[k].Paint(PaintDC, Direction);
  end;
end;

function tElement.CalcRgn(Direction : Shortint) : hRgn;
begin
  CalcRgn := Region.CalcRgn(Direction);
end;

function tElement.CalcInOutRgn(Direction : Shortint) : hRgn;
function CalcInOut(InOut : pPointArray; Num : Integer) : hRgn;
var
  X1, Y1,
  X2, Y2,
  i : Integer;
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CreateEmptyRgn;
  for i := 0 to Num-1
  do begin
    with InOut^[i]
    do begin
      GetPos(X1, Y1, X-4, Y-4, Direction);
      GetPos(X2, Y2, X+4, Y+4, Direction);
    end;
    Rgn_ := CreateEllipticRgn(X1, Y1, X2, Y2);
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
  end;
  CalcInOut := Rgn;
end;
var
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CalcInOut(Input, NumIn);
  Rgn_ := CalcInOut(Output, NumOut);
  CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
  DeleteObject(Rgn_);
  CalcInOutRgn := Rgn;
end;

function tElement.OutImpulse(
  InOutMem : pIntegerArray; Con : pConArray;
  Impulses : pCollection) : Boolean;
begin
  Abstract;
end;

function tElement.SendImpulse(
  InOutMem : Pointer; Con : pConArray;
  Num, Impulse : Integer;
  Impulses : pCollection) : Boolean;
begin
  pIntegerArray(InOutMem)^[Num-1] := Impulse;
  SendImpulse := OutImpulse(InOutMem, Con, Impulses);
end;

{$ifdef layele}

procedure tElement.SimStart(
  InOutMem : Pointer; hLayWin : HWND; p : pItem );
begin
end;

procedure tElement.EleTick;
begin
end;

function tElement.GetMenu( menu : hMenu ) : hMenu;
begin
  GetMenu := menu;
end;

procedure tElement.ShowMacro( p : Pointer );
begin
end;

{$endif layele}

{ ------ tTabEle ------------------------------------------------------- }

constructor tTabEle.Init(xName : pChar);
begin
  inherited Init(xName);
  GetMem(Tabular, 0);
  GetMem(Time, 0);
end;

destructor tTabEle.Done;
begin
  FreeMem(Tabular, TabSize);
  FreeMem(Time, NumOut * SizeOf(Integer));
  inherited Done;
end;

constructor tTabEle.Load(var S : tStream);
var
  p : Pointer;
  i : Integer;
begin
  inherited Load(S);
  GetMem(Tabular, TabSize);
  S.Read(Tabular^, TabSize);
  GetMem(Time, NumOut * SizeOf(Integer));
  S.Read(Time^, NumOut * SizeOf(Integer));
end;

procedure tTabEle.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(Tabular^, TabSize);
  S.Write(Time^, NumOut * SizeOf(Integer));
end;

procedure tTabEle.SetNumInOut(xNumIn, xNumOut, xNumState : Integer);
var
  p : Pointer;
  i : Integer;
  b : Boolean;
begin
  { Zeiten. }
  GetMem(p, xNumOut * SizeOf(Integer));
  for i := 0 to xNumOut-1 do
    pIntegerArray(p)^[i] := $0001;
  if NumOut <= xNumOut
  then Move(Time^[0], pIntegerArray(p)^[0], NumOut * SizeOf(Integer))
  else Move(Time^[0], pIntegerArray(p)^[0], xNumOut * SizeOf(Integer));
  FreeMem(Time, NumOut * SizeOf(Integer));
  Time := pIntegerArray(p);
  { Werte setzen. }
  b := (NumIn <> xNumIn) or (NumOut <> xNumOut) or (NumState <> xNumState);
  if b then FreeMem(Tabular, TabSize);
  inherited SetNumInOut(xNumIn, xNumOut, xNumState);
  if b
  then begin
    GetMem(Tabular, TabSize);
    FillChar(Tabular^, TabSize, $00);
  end;
end;

function tTabEle.MaxNumIn : Integer;
begin
  MaxNumIn := 10; { Wegen TabularDlg. }
end;

function tTabEle.MaxNumOut : Integer;
begin
  MaxNumOut := 10; { Wegen TabularDlg. }
end;

function tTabEle.MaxNumState : Integer;
begin
  MaxNumState := 10; { Wegen TabularDlg. }
end;

function tTabEle.TabSize : Integer;
begin
  TabSize:=(((NumOut+NumState) * (Word(1) shl (NumIn+NumState))) + 7) shr 3;
end;

procedure tTabEle.ChangeInOut(xParent : pWindowsObject);
begin
  Application^.ExecDialog(New(pTabularDlg, Init(@Self, xParent, Nr)));
end;

procedure tTabEle.DelInOut;
begin
  FillChar( Tabular^, TabSize, $00 );
end;

function tTabEle.OutImpulse(
  InOutMem : pIntegerArray; Con : pConArray;
  Impulses : pCollection) : Boolean;
var
  i, k, ad : Integer;
  b : Boolean;
begin
  b := False;
  { Adresse in Tabelle berechnen. }
  ad := 0;
  for i := NumState+NumIn-1 downto 0
  do begin
    ad := ad shl 1;
    if pIntegerArray(InOutMem)^[i] <> 0
    then inc(ad);
  end;

  { Impulse senden. }
  ad := ad * (NumOut+NumState);
  for i := 0 to NumOut-1
  do begin
    k := ad+i;
    if ByteBool(Tabular^[k shr 3] and (Integer(1) shl (k and $07)))
    then k := 1
    else k := 0;
    Impulses^.Insert(
      New(pImpulse, Init(Con^[i].Con, Con^[i].Num, k, Time^[i])));
  end;
  { Zustände neu setzen. }
  for i := 0 to NumState-1
  do begin
    k := ad+i+NumOut;
    if ByteBool(Tabular^[k shr 3] and (Integer(1) shl (k and $07)))
    then k := 1
    else k := 0;
    if pIntegerArray(InOutMem)^[NumIn+i] <> k then b := True;
    pIntegerArray(InOutMem)^[NumIn+i] := k;
  end;
  OutImpulse := b;
end;

{ ------ tBoolDlg ------------------------------------------------------ }

const
  id_Bool      =  100;
  id_Syntax    =  101;
  id_NumIn     =  110;
  id_NumOut    =  111;
  id_NumState  =  112;
  id_NumMerke  =  113;

type
  pBoolDlg = ^tBoolDlg;
  tBoolDlg = object (tInOutDlg)
    Bool : pBoolEle;
    constructor Init(
      xBool : pBoolEle; xParent : pWindowsObject; i : Integer);
    procedure SetupWindow; virtual;
    procedure wmVScroll(var Msg : tMessage);
      virtual wm_First + wm_VScroll;
    procedure idSyntax(var Msg : tMessage);
      virtual id_First + id_Syntax;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tBoolDlg.Init(
  xBool : pBoolEle; xParent : pWindowsObject; i : Integer);
begin
  inherited Init(xBool^.Name, xParent, 'BOOLDLG', i);
  Bool := xBool;
end;

procedure tBoolDlg.SetupWindow;
begin
  inherited SetupWindow;
  SendDlgItemMsg(id_Bool, wm_SetFont, GetStockObject(System_Fixed_Font), 0);
  SetDlgItemInt(hWindow, id_NumIn, Word(Bool^.NumIn), TRUE);
  SetDlgItemInt(hWindow, id_NumOut, Word(Bool^.NumOut), TRUE);
  SetDlgItemInt(hWindow, id_NumState, Word(Bool^.NumState), TRUE);
  SetDlgItemInt(hWindow, id_NumMerke, Word(Bool^.NumMerke), TRUE);
  SetDlgItemText(hWindow, id_Bool, Bool^.Bool);
end;

procedure tBoolDlg.wmVScroll(var Msg : tMessage);
var id : Word;
begin
  with Msg
  do begin
    id := GetDlgCtrlId(Msg.lParamHi) - 100;
    if (id>=id_NumIn) and (id<=id_NumMerke)
    then begin
      lParamLo := GetDlgItemInt(hWindow, id, nil, True);
      case wParam of
        sb_LineUp : inc(Integer(lParamLo));
        sb_LineDown : dec(Integer(lParamLo));
        sb_PageUp : inc(Integer(lParamLo), 5);
        sb_PageDown : dec(Integer(lParamLo), 5);
      end;
      if Integer(lParamLo)<0 then lParamLo:=0;
      SetScrollPos(lParamHi, sb_Ctl, Integer(lParamLo), True);
      SetDlgItemInt(hWindow, id, lParamLo, True);
    end
    else DefWndProc(Msg);
  end;
end;

procedure tBoolDlg.idSyntax(var Msg : tMessage);
var
  GS : tGlobalStream;
  l : Integer;
  s : pChar;
begin
  with Bool^
  do begin
    GS.Init;
    Store(GS);
    GS.Seek(0);
    SetNumInOut(
      Integer(GetDlgItemInt(hWindow, id_NumIn, nil, TRUE)),
      Integer(GetDlgItemInt(hWindow, id_NumOut, nil, TRUE)),
      Integer(GetDlgItemInt(hWindow, id_NumState, nil, TRUE)) );
    NumMerke := Integer(GetDlgItemInt(hWindow, id_NumMerke, nil, TRUE));
    StrDispose(Bool);
    l := GetWindowTextLength(GetItemHandle(id_Bool));
    GetMem(s, l+1);
    GetWindowText(GetItemHandle(id_Bool), s, l+1);
    Bool := s;
    Syntax(hWindow);
    Done;
    Load(GS);
    GS.Done;
  end;
end;

procedure tBoolDlg.OK(var Msg : tMessage);
var
  l : Integer;
  s : pChar;
  b : Boolean;
  GS : tGlobalStream;
begin
  with Bool^
  do begin
    GS.Init;
    Store(GS);
    GS.Seek(0);
    SetNumInOut(
      Integer(GetDlgItemInt(hWindow, id_NumIn, nil, TRUE)),
      Integer(GetDlgItemInt(hWindow, id_NumOut, nil, TRUE)),
      Integer(GetDlgItemInt(hWindow, id_NumState, nil, TRUE)) );
    NumMerke := Integer(GetDlgItemInt(hWindow, id_NumMerke, nil, TRUE));
    StrDispose(Bool);
    l := GetWindowTextLength(GetItemHandle(id_Bool));
    GetMem(s, l+1);
    GetWindowText(GetItemHandle(id_Bool), s, l+1);
    Bool := s;
    b := Syntax(hWindow);
  end;
  if  b  or
     (MessageBox(
        hWindow, LoadString0($2ffd), LoadString1($2ffc),
        MB_YESNO or MB_ICONQUESTION) = ID_YES)
  then EndDlg(id_OK)
  else begin
    Bool^.Done;
    Bool^.Load(GS);
  end;
  GS.Done;
end;

procedure tBoolDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 522);
end;

{ ------ tBoolEle ------------------------------------------------------ }

constructor tBoolEle.Init(xName : pChar);
begin
  inherited Init(xName);
  NumMerke := 0;
  Bool := StrNew('');
end;

destructor tBoolEle.Done;
begin
  StrDispose(Bool);
  inherited Done;
end;

constructor tBoolEle.Load(var S : tStream);
begin
  inherited Load(S);
  S.Read(NumMerke, SizeOf(NumMerke));
  Bool := S.StrRead;
end;

procedure tBoolEle.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(NumMerke, SizeOf(NumMerke));
  S.StrWrite(Bool);
end;

procedure tBoolEle.ChangeInOut(xParent : pWindowsObject);
begin
  Application^.ExecDialog(New(pBoolDlg, Init(@Self, xParent, Nr)));
end;

procedure tBoolEle.DelInOut;
begin
  StrDispose(Bool);
  Bool := StrNew('');
end;

type
  wvs_SyntaxRec = record
    Zeile : Integer;
    s : pChar;
  end;

const
  ER_NONE     = $0000;
  ER_INPUT    = $0001;
  ER_OUTPUT   = $0002;
  ER_STATE    = $0003;
  ER_MERKE    = $0004;
  ER_MASK     = $fff8;
  REG_MASK    = $0007;
  ER_HEXNUM   = $3008;
  ER_REGISTER = $3010;
  ER_REGNUM   = $3018;
  ER_SET      = $3020;
  ER_SYNTAX   = $3028;

function tBoolEle.Syntax(Window : hWnd) : Boolean;
var correct : Integer;
function GetHex(c : char) : word;
begin
  case c of
    '0'..'9' : GetHex := Ord(c) - 48;
    'a'..'f' : GetHex := Ord(c) - 87;
    'A'..'F' : GetHex := Ord(c) - 55;
    else begin
      GetHex := 0;
      correct := ER_HEXNUM;
    end;
  end;
end;

FUNCTION GetBitNr(VAR i : INTEGER) : Integer;
{ Holt aus den nächsten zwei Zeichen von Bool die Bitnummer eines Reg. }
BEGIN
  GetBitNr := (GetHex(Bool[i]) shl 4) + GetHex(Bool[i+1]);
  inc(i,2);
END;

PROCEDURE Wert(VAR i : INTEGER; VAR Num : Integer);
BEGIN
  Num := GetBitNr(i);
  CASE Bool[i] OF
    'e','E', 'i','I':
      if Num >= NumIn then correct := ER_REGNUM or ER_INPUT;
    'z','Z', 's','S':
      if Num >= NumState then correct := ER_REGNUM or ER_STATE;
    'm','M':
      if Num >= NumMerke then correct := ER_REGNUM or ER_MERKE;
    'a','A', 'o','O': correct := ER_REGISTER or ER_OUTPUT;
    else correct := ER_REGISTER;
  END;
  inc(i);
END;

var
  Zeile,
  i: INTEGER;
  Num: Integer;
  Output_Set,
  State_Set : pBooleanArray;
  wvs : wvs_SyntaxRec;
begin
  GetMem(Output_Set, NumOut*SizeOf(Boolean));
  FillChar(Output_Set^, NumOut*SizeOf(Boolean), $00);
  GetMem(State_Set, NumState*SizeOf(Boolean));
  FillChar(State_Set^, NumState*SizeOf(Boolean), $00);
  correct := ER_NONE;
  Zeile := 1;
  i := 0; { Position in Bool }
  WHILE (i < StrLen(Bool)) and (correct=ER_NONE)
  DO BEGIN
    CASE Bool[i] OF
      #13 :
        begin
          inc(i);
          inc(Zeile);
        end;
      'w', 'W', 't', 'T',
      'f', 'F' : inc(i);
      '0'..'9' :
        begin
          Wert(i, Num);
        end;
      '-', '!': Inc(i);
      '+', '|',
      '*', '&',
      'x', 'X', '^',
      '§',
      '@',
      '>',
      '<',
      '~':
        begin
          Inc(i);
          Wert(i, Num);
        end;
      '=':
        BEGIN { Zuordnung }
          Inc(i);
          Wert(i, Num);
          if correct = (ER_REGISTER or ER_OUTPUT) then correct := ER_NONE;
          case Bool[i-1] of
            'a','A', 'o','O':
              begin
                if Num >= NumOut
                then correct := ER_REGNUM or ER_OUTPUT
                else if Output_Set^[Num]
                then correct := ER_SET or ER_OUTPUT
                else Output_Set^[Num] := TRUE;
              end;
            'e','E', 'i','I': correct := ER_REGISTER or ER_INPUT;
            'z','Z', 's','S':
              begin
                if Num >= NumState
                then correct := ER_REGNUM or ER_STATE
                else if State_Set^[Num]
                then correct := ER_SET or ER_STATE
                else State_Set^[Num] := TRUE;
              end;
            'm','M':
              begin
                if Num >= NumMerke then correct := ER_REGNUM or ER_MERKE
              end;
            else correct := ER_REGISTER;
          end;
        END;
      '/':
        repeat inc(i); until (i=StrLen(Bool)) or (Bool[i]=#13);
      ' ', #10 : inc(i);
      else begin
        inc(i);
        correct := ER_SYNTAX;
      end;
    END;
  END;
  FreeMem(Output_Set, NumOut*SizeOf(Boolean));
  FreeMem(State_Set, NumState*SizeOf(Boolean));
  if correct <> ER_NONE
  then begin
    wvs.Zeile := Zeile;
    wvs.s := @String2;
    Num := i;
    while (Bool[Num]<>#13) and (Num<StrLen(Bool)) do inc(Num);
    StrLCopy(@String2, @Bool[i], Num-i);
    wvsprintf(@String1, LoadString0($2ffe), wvs);
    MessageBox(
      Window, LoadString0(correct), @String1,
      MB_OK or MB_ICONSTOP);
    Syntax := FALSE;
  end
  else begin
    wvsprintf(@String1, LoadString0($2fff), Zeile);
    MessageBox(
      Window, LoadString0($3000), @String1,
      MB_OK or MB_ICONINFORMATION);
    Syntax := TRUE;
  end;
end;

function tBoolEle.OutImpulse(
  InOutMem : pIntegerArray; Con : pConArray;
  Impulses : pCollection) : Boolean;
var
  Merke : pBooleanArray;
  State_Time,
  Merke_Time : pIntegerArray;
  Time : Integer;
function GetHex(c : char) : word;
begin
  case c of
    '0'..'9' : GetHex := Ord(c) - 48;
    'a'..'f' : GetHex := Ord(c) - 87;
    'A'..'F' : GetHex := Ord(c) - 55;
    else GetHex := 0;
  end;
end;

FUNCTION GetBitNr(VAR i : INTEGER) : Integer;
{ Holt aus den nächsten zwei Zeichen von Bool die Bitnummer eines Reg. }
BEGIN
  GetBitNr := (GetHex(Bool[i]) shl 4) + GetHex(Bool[i+1]);
  inc(i,2);
END;

PROCEDURE Wert(VAR i : INTEGER; VAR akt : BOOLEAN; VAR Num : Integer);
BEGIN
  Num := GetBitNr(i);
  CASE Bool[i] OF
    'e', 'i': akt := pIntegerArray(InOutMem)^[Num] <> 0; { Eingang }
    'E', 'I': akt := pIntegerArray(InOutMem)^[Num] = 0; { Eingang }
    'z', 's':
      begin
        akt := pIntegerArray(InOutMem)^[NumIn+Num] <> 0; { Zustand }
        if Time < State_Time^[Num] then Time := State_Time^[Num];
      end;
    'Z', 'S':
      begin
        akt := pIntegerArray(InOutMem)^[NumIn+Num] = 0; { Zustand }
        if Time < State_Time^[Num] then Time := State_Time^[Num];
      end;
    'm':
      begin
        akt := Merke^[Num]; { Zwischenergebnisse, ersetzt Klammern }
        if Time < Merke_Time^[Num] then Time := Merke_Time^[Num];
      end;
    'M':
      begin
        akt := not Merke^[Num]; { Zwischenergebnisse, ersetzt Klammern }
        if Time < Merke_Time^[Num] then Time := Merke_Time^[Num];
      end;
  END;
  inc(i);
END;

var
  i: INTEGER;
  akt, akt2: BOOLEAN;
  Num: Integer;
begin
  OutImpulse := FALSE;
  GetMem(State_Time, NumState*SizeOf(Integer));
  FillChar(State_Time^, NumState*SizeOf(Integer), $00);
  GetMem(Merke_Time, NumMerke*SizeOf(Integer));
  FillChar(Merke_Time^, NumMerke*SizeOf(Integer), $00);
  GetMem(Merke, NumMerke*SizeOf(Boolean));
  Time := 0;
  i := 0; { Position in Bool }
  WHILE i < StrLen(Bool)
  DO BEGIN
    CASE Bool[i] OF
      #13:
        begin
          inc(i);
          Time := 0;
        end;
      'w', 'W', 't', 'T' :
        begin
          akt := TRUE;
          inc(i);
        end;
      'f', 'F' :
        begin
          akt := FALSE;
          inc(i);
        end;
      '0'..'9' : Wert(i, akt, Num);
      '+', '|':
        BEGIN { Inklusives ODER }
          Inc(i);
          Wert(i, akt2, Num);
          akt:= akt OR akt2;
          inc(Time);
        END;
      '*', '&':
        BEGIN { logisches UND }
          Inc(i);
          Wert(i, akt2, Num);
          akt:= akt AND akt2;
          inc(Time);
        END;
      '-', '!':
        BEGIN { NEGation }
          Inc(i);
          akt:= NOT akt;
          inc(Time);
        END;
      'x', 'X', '^':
        begin { Exklusives Oder XOR }
          Inc(i);
          Wert(i, akt2, Num);
          akt := akt xor akt2;
          inc(Time);
        end;
      '§':
        begin { logisches Nicht Und NAND }
          Inc(i);
          Wert(i, akt2, Num);
          akt := not(akt and akt2);
          inc(Time);
        end;
      '@':
        begin { logisches Nicht Oder NOR }
          Inc(i);
          Wert(i, akt2, Num);
          akt := not(akt or akt2);
          inc(Time);
        end;
      '>':
        begin { Implikation a -> b }
          Inc(i);
          Wert(i, akt2, Num);
          akt := not(akt) or akt2;
          inc(Time);
        end;
      '<':
        begin { Implikation a <- b }
          Inc(i);
          Wert(i, akt2, Num);
          akt := not(akt2) or akt;
          inc(Time);
        end;
      '~':
        begin { Äquivalenz a <=> b }
          Inc(i);
          Wert(i, akt2, Num);
          akt := (not(akt2) and not(akt)) or (akt and akt2);
          inc(Time);
        end;
      '=':
        BEGIN { Zuordnung }
          Inc(i);
          Wert(i, akt2, Num);
          case Bool[i-1] of
            'a','A', 'o','O':
              Impulses^.Insert(
                New(pImpulse, Init(Con^[Num].Con, Con^[Num].Num, Integer(akt), Time)));
            'z','Z', 's','S':
              begin
                if pIntegerArray(InOutMem)^[NumIn+Num] <> Integer(akt)
                then OutImpulse:=TRUE;
                pIntegerArray(InOutMem)^[NumIn+Num]:=Integer(akt); {Zustand}
                State_Time^[Num] := Time;
              end;
            'm','M':
              begin
                Merke^[Num] := akt; { Zwischenergebnisse, ersetzt Klammern }
                Merke_Time^[Num] := Time;
              end;
          end;
        END;
      '/':
        repeat inc(i); until (i=StrLen(Bool)) or (Bool[i]=#13);
      else inc(i);
    END;
  END;
  FreeMem(Merke, NumMerke * SizeOf(Boolean));
  FreeMem(State_Time, NumState*SizeOf(Integer));
  FreeMem(Merke_Time, NumMerke*SizeOf(Integer));
end;

{$ifdef layele}
{ ------ tMacroEle ----------------------------------------------------- }

constructor tMacroEle.Init(xName : pChar);
begin
  inherited Init(xName);
  layout := nil;
  version := 0;
end;

destructor tMacroEle.Done;
begin
  if layout <> nil
  then Dispose ( layout, Done );
  inherited Done;
end;

constructor tMacroEle.Load(var S : tStream);
var
  i : longint;
begin
  inherited Load(S);
  S.Read( version, sizeof(version) );
  S.Read ( i, sizeof(i) );
  if i > 0
  then begin
    layout := New ( pGlobalStream, Init );
    layout^.Seek(0);
    layout^.CopyFrom ( S, i );
  end
  else layout := nil;
end;

procedure tMacroEle.Store(var S : tStream);
var
  i : longint;
begin
  inherited Store(S);
  S.Write( version, sizeof(version) );
  if layout <> nil
  then begin
    i := layout^.GetSize;
    S.Write ( i, sizeof(i) );
    layout^.Seek(0);
    S.CopyFrom ( layout^, i );
  end
  else begin
    i := 0;
    S.Write ( i, sizeof(i) );
  end;
end;

procedure tMacroEle.ChangeInOut(xParent : pWindowsObject);
begin
  SendMessage( xParent^.hWindow, ms_MacroInOut, 0, longint(@self) );
end;

procedure tMacroEle.DelInOut;
begin
  if layout <> nil
  then begin
    Dispose ( layout, Done );
    layout := nil;
  end;
end;

function tMacroEle.OutImpulse(
  InOutMem : pIntegerArray; Con : pConArray;
  Impulses : pCollection) : Boolean;
var
  MacroOutImpulse : tMacroOutImpulse;
begin
  MacroOutImpulse.InMem := InOutMem;
  MacroOutImpulse.StateMem := @(InOutMem^[NumIn]);
  MacroOutImpulse.Con := Con;
  MacroOutImpulse.Impulses := Impulses;
  SendMessage( { Unbedingt SendMessage, da lokale Variable benutzt. }
    hMacroWindow(InOutMem),
    ms_MacroOutImpulse, 0,
    longint(@MacroOutImpulse) );
  OutImpulse := false; { Nicht neu zeichnen. }
end;

function tMacroEle.hMacroWindow( p : Pointer ) : HWND;
begin
  hMacroWindow := HWND(pIntegerArray(p)^[NumIn+NumState]);
end;

procedure tMacroEle.SethMacroWindow( p : Pointer; wnd : HWND );
begin
  pIntegerArray(p)^[NumIn+NumState] := integer(wnd);
end;

function tMacroEle.GetInOutMemSize : Integer;
begin
  GetInOutMemSize :=
    ( (NumIn+NumState) * SizeOf(Integer) )+
    SizeOf(HWND);
end;

procedure tMacroEle.FreeInOutMem(p : Pointer);
var
  wnd : HWND;
begin
  wnd := hMacroWindow(p);
  if wnd <> 0
  then SendMessage( wnd, WM_CLOSE, Word(true), 0 );
  FreeMem(p, GetInOutMemSize);
end;

procedure tMacroEle.ClearInOutMem(p, Con : Pointer);
var
  wnd : HWND;
  i : Integer;
begin
  wnd := hMacroWindow(p);
  SendMessage( wnd, ms_MacroSimReset, 0, 0 );
                  { NICHT GetInOutMemSize wegen tMacroEle }
  Move(InitVal^, p^, (NumIn+NumState) * SizeOf(Integer));
  if Con <> nil then
    for i := 0 to NumIn-1 do
      if pConArray(Con)^[i].Con <> nil
      then pIntegerArray(p)^[i] := 0;
end;

function tMacroEle.GetInOutMem : Pointer;
var
  p : Pointer;
begin
  { Eingangs- und Zustandsimpulse merken. }
  GetMem(p, GetInOutMemSize);
  ClearInOutMem(p, nil);
  { In Element gespeicherte Schaltung laden. }
  SethMacroWindow(
    p,
    integer(SendMessage(hMainWin, ms_NewMacroIO, 0, longint(@Self))));
  GetInOutMem := p;
end;

function tMacroEle.LoadInOutMem(var S : tStream; var p : Pointer) : Boolean;
var
  i : Integer;
  l : longint;
  version_ : word;
  hMacroWin_ : HWND;
begin
  S.Read(i, SizeOf(Integer));
  if i = GetInOutMemSize
  then begin
    if p=nil
    then begin
      GetMem(p, i);
      hMacroWin_ :=
        integer(SendMessage(hMainWin, ms_NewMacroIO, 0, longint(@Self)));
    end
    else hMacroWin_ := hMacroWindow(p);
    S.Read(p^, i);
    { Versionsänderung abfragen. }
    S.Read( version_, sizeof(version_) );
    S.Read( l, sizeof(l) );
    SethMacroWindow(
      p,
      hMacroWin_);
    if version = version_
    then begin
      { In Element gespeicherte Schaltung laden. }
      SendMessage( hMacroWindow(p), ms_LoadInOut, 0, longint(@S) );
    end
    else begin
      MessageBeep(0);
      S.Seek( S.GetPos+l );
    end;
    LoadInOutMem := True;
  end
  else begin
    S.Seek( S.GetPos+i );
    GetMem(p, GetInOutMemSize);
    ClearInOutMem(p, nil);
    LoadInOutMem := False;
  end;
end;

procedure tMacroEle.StoreInOutMem(var S : tStream; p : Pointer);
var
  pos1, pos2, l : longint;
begin
  inherited StoreInOutMem( S, p );
  { Versionsänderung abspeichern. }
  S.Write( version, sizeof(version) );
  pos1 := S.GetPos;
  S.Write( l, sizeof(l) );
  SendMessage( hMacroWindow(p), ms_StoreInOut, 0, longint(@S) );
  pos2 := S.GetPos;
  l := pos2 - pos1 - sizeof(l);
  S.Seek(pos1);
  S.Write( l, sizeof(l) );
  S.Seek(pos2);
end;

procedure tMacroEle.SimStart(
  InOutMem : Pointer; hLayWin : HWND; p : pItem );
begin
  SendMessage( hMacroWindow(InOutMem), ms_MacroSimStart, hLayWin, longint(p) );
end;

procedure tMacroEle.EleTick( InOutMem : Pointer );
begin
  SendMessage( hMacroWindow(InOutMem), ms_Tick, integer(true), 0 );
end;

procedure tMacroEle.IncVersion;
begin
  inc(version);
  if version = 2*maxint
  then version := 0;
end;

function tMacroEle.GetMenu( menu : hMenu ) : hMenu;
begin
  LoadString0(59);
  AppendMenu( menu, MF_SEPARATOR, 0, nil );
  AppendMenu(
    menu,
    MF_STRING,
    cm_ShowMacro, @String0 );
  GetMenu := menu;
end;

procedure tMacroEle.ShowMacro( p : Pointer );
begin
  SendMessage( hMacroWindow( p ), ms_ShowWindow, 0, 0 );
end;

{$endif} { layele }

{ ------ rChapter ------------------------------------------------------- }

const
  rChapEle : TStreamRec = (
     ObjType : riChapEle;
     VmtLink : Ofs(TypeOf(tChapEle)^);
     Load  : @tChapEle.Load;
     Store : @tChapEle.Store
  );

{ ------ rElement ------------------------------------------------------- }

const
  rElement : TStreamRec = (
     ObjType : riElement;
     VmtLink : Ofs(TypeOf(tElement)^);
     Load  : @tElement.Load;
     Store : @tElement.Store
  );

{ ------ rTabEle -------------------------------------------------------- }

const
  rTabEle : TStreamRec = (
     ObjType : riTabEle;
     VmtLink : Ofs(TypeOf(tTabEle)^);
     Load  : @tTabEle.Load;
     Store : @tTabEle.Store
  );

{ ------ rBoolEle ------------------------------------------------------- }

const
  rBoolEle : TStreamRec = (
     ObjType : riBoolEle;
     VmtLink : Ofs(TypeOf(tBoolEle)^);
     Load  : @tBoolEle.Load;
     Store : @tBoolEle.Store
  );

{$ifdef layele}
{ ------ rMacroEle ------------------------------------------------------ }

const
  rMacroEle : TStreamRec = (
     ObjType : riMacroEle;
     VmtLink : Ofs(TypeOf(tMacroEle)^);
     Load  : @tMacroEle.Load;
     Store : @tMacroEle.Store
  );
{$endif}

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rChapEle);
  RegisterType(rElement);
  RegisterType(rTabEle);
  RegisterType(rBoolEle);
{$ifdef layele}
  RegisterType(rMacroEle);
{$endif}
end.