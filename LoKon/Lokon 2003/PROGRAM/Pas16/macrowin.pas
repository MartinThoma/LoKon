unit MacroWin;
{$I define.inc}

{ Makros nur zusammen mit Oszilloskop m�glich! }

interface

uses
  Objects, Messages,
  WinTypes, WinProcs,
  Strings,
  OWindows, ODialogs,
  CommDlg,
  LK_Const,
  OWinEx,
  ScrolOrg,
  LayWin,
  Element,
  EleFile,
  Item,
  Impulse,
  Paint,
  EleWinCh;

type
  tIOSMacroItem = object ( tInOutItem )
    state : pIntegerArray;
    io : shortint; { true - Eing�nge, false - Ausg�nge }
    NumIO : Integer;
    constructor Init;
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreInOut(var S : tStream); virtual;
    function LoadInOut(var S : tStream) : Boolean; virtual;
    function Name : pChar; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetRegionInOut : hRgn; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure Paint2(PaintDC: hDC);
    procedure PaintInOut(PaintDC : hDC); virtual;
    function NumInCon : Integer; virtual;
    function NumOutCon : Integer; virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : Longint; virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
    procedure SetNumIO( xNumIO : integer; LayWin : pLayoutWindow );
    procedure IncNumIO( xInc : integer; LayWin : pLayoutWindow );
    procedure SendImpulse(
      NumIn_, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
  end;

  pOutMacroItem = ^tOutMacroItem;
  tOutMacroItem = object (tIOSMacroItem)
    hLayWin : HWND;
    OutCon2 : pConArray;
    constructor Init;
    constructor Load(var S : tStream);
    procedure SendImpulse(
      NumIn_, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
  end;

  pInMacroItem = ^tInMacroItem;
  tInMacroItem = object ( tIOSMacroItem )
    constructor Init;
    constructor Load(var S : tStream);
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    procedure Toggle( A : tPoint ); virtual;
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure OutImpulse(Impulses : pCollection); virtual;
    procedure SetImpulse( InOutMem : Pointer; Impulses : pCollection );
  end;

  pStateMacroItem = ^tStateMacroItem;
  tStateMacroItem = object ( tIOSMacroItem )
    hLayWin : HWND;
    StateMem : Pointer;
    MacroItem : pItem;
    constructor Init;
    constructor Load(var S : tStream);
    procedure SendImpulse(
      NumIn_, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
  end;

  pMacroWindow = ^tMacroWindow;
  tMacroWindow = object (tLayoutWindow)
    element : pMacroEle;
    InItem : pInMacroItem;
    OutItem : pOutMacroItem;
    StateItem : pStateMacroItem;
    MacroItem : pItem;
    hLayWin : HWND;
    constructor Init( xParent : pWindowsObject; xelement : pMacroEle );
    procedure SetupWindow; virtual;
    function CanClose : Boolean; virtual;
    procedure SaveChanges;
    function GetClassName: PChar; virtual;
    procedure IncIO( xInc : integer );
    procedure cmAddOneIO( var Msg : tMessage );
      virtual cm_First + cm_AddOneIO;
    procedure cmDelOneIO( var Msg : tMessage );
      virtual cm_First + cm_DelOneIO;
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    procedure msMacroOutImpulse( var Msg : tMessage );
      virtual ms_MacroOutImpulse;
    procedure msMacroSimReset( var Msg : tMessage );
      virtual ms_MacroSimReset;
    procedure msMacroSimStart( var Msg : tMessage );
      virtual ms_MacroSimStart;
    procedure msMacroSimStop( var Msg : tMessage );
      virtual ms_MacroSimStop;
    { Auf normalen Tick nur bei Element->Ein/Ausgabe reagieren. }
    procedure msTick(var Msg : tMessage);
      virtual ms_Tick;
    procedure msShowMacroWin(var Msg : tMessage);
      virtual ms_ShowMacroWin;
    procedure msHideMacroWin(var Msg : tMessage);
      virtual ms_HideMacroWin;
    procedure wmClose( var Msg : tMessage );
      virtual wm_First + wm_Close;
    procedure msStoreInOut(var Msg : tMessage);
      virtual ms_StoreInOut;
    procedure msLoadInOut(var Msg : tMessage);
      virtual ms_LoadInOut;
  end;

implementation

var
  InputItem_Name,
  OutputItem_Name,
  State_Name : pChar;

{ ------ tIOSMacroItem ------------------------------------------------- }

constructor tIOSMacroItem.Init;
begin
  tInOutItem.Init;
  io := 0;
  NumIO := 0;
  GetMem(OutCon, NumIO * SizeOf(tCon));
  FillChar(OutCon^, NumIO * SizeOf(tCon), $00);
  GetMem(state, NumIO * SizeOf(integer));
  FillChar(state^, NumIO * SizeOf(integer), $00);
  InCon := nil;
end;

destructor tIOSMacroItem.Done;
var
  i : Integer;
begin
  if io > 0
  then begin
    for i := 0 to NumIO-1 do
      InCon^[i].DelCon;
    FreeMem(InCon, NumIO * SizeOf(tCon));
  end
  else begin
    for i := 0 to NumIO-1 do
      OutCon^[i].DelCon;
    FreeMem(OutCon, NumIO * SizeOf(tCon));
  end;
  FreeMem(state, NumIO * SizeOf(integer));
end;

constructor tIOSMacroItem.Load(var S : tStream);
begin
  inherited Load(S);
  S.Read(
    NumIO,
    SizeOf(NumIO) );
  io := 0;
  GetMem(OutCon, NumIO * SizeOf(tCon));
  FillChar(OutCon^, NumIO * SizeOf(tCon), $00);

  GetMem(state, NumIO * SizeOf(integer));
  FillChar(state^, NumIO * SizeOf(integer), $00);

  InCon := nil;
  CalcItemRect;
end;

procedure tIOSMacroItem.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(
    NumIO,
    SizeOf(NumIO) );
end;

procedure tIOSMacroItem.StoreInOut(var S : tStream);
begin
  S.Write(
    state^,
    NumIO * SizeOf(integer));
end;

function tIOSMacroItem.LoadInOut(var S : tStream) : Boolean;
begin
  S.Read(
    state^,
    NumIO * SizeOf(integer));
  LoadInOut := true;
end;

function tIOSMacroItem.Name : pChar;
begin
  case io of
    1 : Name := InputItem_Name;
    0 : Name := OutputItem_Name;
   -1 : Name := State_Name;
  end;
end;

function tIOSMacroItem.GetRegion_ : hRgn;
var
  R : tRect;
  fz : integer;
begin
  if io > 0
  then fz := -1  { Eing�nge liegen links vom relativen Nullpunkt. }
  else fz := +1; { Ausg�nge liegen rechts vom relativen Nullpunkt. }
  with R
  do begin
    { Umrandung Rechteck. }
    GetPos( left, top, fz*15, ((-10)*NumIO)+6, Direction );
    GetPos( right, bottom, fz*5, 4, Direction );
    OffsetRect( R, X, Y );
    GetRegion_ := CreateRectRgn( left, top, right, bottom );
  end;
end;

function tIOSMacroItem.GetRegionInOut : hRgn;
var
  X1, Y1,
  X2, Y2,
  Y_,
  i : Integer;
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CreateEmptyRgn;
  Y_ := 0;
  for i := 0 to NumIO-1
  do begin
    GetPos(X1, Y1, -4, Y_-4, Direction);
    GetPos(X2, Y2, 4, Y_+4, Direction);
    Rgn_ := CreateEllipticRgn(X1, Y1, X2, Y2);
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
    dec( Y_, 10 );
  end;
  OffsetRgn( Rgn, X, Y );
  GetRegionInOut := Rgn;
end;

procedure tIOSMacroItem.Paint2(PaintDC : hDC);
var
  X1, Y1,
  X2, Y2,
  X_, Y_,
  i : integer;
  fz : integer;
begin
  if io > 0
  then fz := -1  { Eing�nge liegen links vom relativen Nullpunkt. }
  else fz := +1; { Ausg�nge liegen rechts vom relativen Nullpunkt. }
  SetWindowOrg(PaintDC, -X, -Y);
  SelectObject( PaintDC, GetStockObject( NULL_BRUSH ) );
  { Umrandung (Rechteck). }
  GetPos( X1, Y1, fz*15, ((-10)*NumIO)+6, Direction );
  GetPos( X2, Y2, fz*5, 4, Direction );
  Rectangle( PaintDC, X1, Y1, X2, Y2 );
  { Eing�nge / Ausg�nge }
  Y_ := 0;
  for i := 0 to NumIO-1
  do begin
    GetPos(X1, Y1, 0, Y_, Direction);
    GetPos(X2, Y2, fz*5, Y_, Direction);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
    dec ( Y_, 10 );
  end;
end;

procedure tIOSMacroItem.NotPaint(PaintDC : hDC);
procedure DoCon(Con : pConArray; Num : Integer);
var
  i : Integer;
begin
  for i := 0 to Num-1 do
    Con^[i].NotPaint(PaintDC);
end;
begin
  if io > 0
  then DoCon(InCon, NumIO)
  else DoCon(OutCon, NumIO);
  SelectObject(PaintDC, DrawPen);
  Paint2 ( PaintDC );
end;

procedure tIOSMacroItem.Paint(PaintDC : hDC);
var
  X1, Y1,
  X_, Y_ : integer;
  i : integer;
  Font : hFont;
begin
  case io of
    1 : begin
          SelectObject(PaintDC, InPen);
          X_ := -10;
        end;
    0 : begin
         SelectObject(PaintDC, OutPen);
         X_ := +8;
       end;
  -1 : begin
         SelectObject(PaintDC, StPen);
         X_ := +8;
       end;
  end;
  Paint2 ( PaintDC );
  SelectObject(PaintDC, DrawPen);
  Font := CreateFont(
    8, 0,
    -(900*Direction),
    -(900*Direction),
    400,
    0,
    0,
    0,
    ANSI_Charset, Font_Precis,
    0, Font_Quality, 1, FontName[0]);
  SelectObject(PaintDC, Font);
  { Beschriftung. }
  Y_ := -4;
  for i := 0 to NumIO-1
  do begin
    GetPos(X1, Y1, X_, Y_, Direction);
    if state^[i] = 0
    then pChar(@String0)^ := '0'
    else pChar(@String0)^ := '1';
    TextOut(PaintDC, X1, Y1, @String0, 1);
    dec ( Y_, 10 );
  end;
  DeleteObject(Font);
  if io > 0
  then begin
    Font := CreateFont(
      7, 0,
      900-(900*Direction),
      900-(900*Direction),
      400,
      0,
      0,
      0,
      ANSI_Charset, Font_Precis,
      0, Font_Quality, 1, FontName[3]);
    SelectObject(PaintDC, Font);
    Y_ := +3;
    for i := 0 to NumIO-1
    do begin
      { Schalter Zeichen. }
      GetPos(X1, Y1, -17, Y_, Direction);
      TextOut(PaintDC, X1, Y1, '�', 1);
      dec ( Y_, 10 );
    end;
    DeleteObject(Font);
  end;
end;

procedure tIOSMacroItem.PaintInOut(PaintDC : hDC);
var
  i : Integer;
  Font : hFont;
  fz : integer;
begin
  SetWindowOrg(PaintDC, -X, -Y);
  if io > 0
  then fz := -1  { Eing�nge liegen links vom relativen Nullpunkt. }
  else fz := +1; { Ausg�nge liegen rechts vom relativen Nullpunkt. }
  Font := SetInOutFont(PaintDC, Direction);
  for i := 1 to NumIO do
    DrawInOut(PaintDC, 0, -10*(i-1), Direction, -fz*i);
  DeleteObject(Font);
end;

function tIOSMacroItem.NumInCon : Integer;
begin
  if io > 0
  then NumInCon := NumIO
  else NumInCon := 0;
end;

function tIOSMacroItem.NumOutCon : Integer;
begin
  if io > 0
  then NumOutCon := 0
  else NumOutCon := NumIO;
end;

function tIOSMacroItem.GetInOutNr(A : tPoint) : Integer;
var
  B : tPoint;
  i : Integer;
begin
  GetInOutNr := 0;
  if io > 0
  then begin
    for i := 1 to NumIO
    do begin
      longint(B) := GetInOutPos(i);
      if EqualPt( A, B ) then GetInOutNr := i;
    end;
  end
  else begin
    for i := 1 to NumIO
    do begin
      longint(B) := GetInOutPos(-i);
      if EqualPt( A, B ) then GetInOutNr := -i;
    end;
  end;
end;

function tIOSMacroItem.GetInOutPos(Num : Integer) : Longint;
var
  A : Longint;
  fz : integer;
begin
  if io > 0
  then fz := -1  { Eing�nge liegen links vom relativen Nullpunkt. }
  else fz := +1; { Ausg�nge liegen rechts vom relativen Nullpunkt. }
  with tPoint(A)
  do begin
    Y := (fz*10*Num)+10;
    X := 0;
    GetPos(X, Y, X, Y, Direction);
  end;
  inc(tPoint(A).X, X);
  inc(tPoint(A).Y, Y);
  GetInOutPos := A;
end;

type
  pIOMacroItemDlg = ^tIOMacroItemDlg;
  tIOMacroItemDlg = object (tDialogSB)
    p : pInMacroItem;
    MacroWin : pMacroWindow;
    constructor Init(xParent : pWindowsObject; p_ : pInMacroItem);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tIOMacroItemDlg.Init(xParent : pWindowsObject; p_ : pInMacroItem);
begin
  inherited Init(xParent, 'IOMACROITEMDLG');
  p := p_;
end;

procedure tIOMacroItemDlg.SetupWindow;
var
  s : pChar;
begin
  inherited SetupWindow;
  s := p^.Name;
  SetWindowText( hWindow, s );
  GetWindowText( GetItemHandle(104), @String0, StringLen );
  wvsprintf ( @String1, @String0, s );
  SetWindowText( GetItemHandle(104), @String1 );
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), true);
    SetDlgItemInt(hWindow, 101, Word(Y), true);
    SetDlgItemInt(hWindow, 105, Word(NumIO), false);
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
  end;
end;

procedure tIOMacroItemDlg.OK(var Msg : tMessage);
var
  i : Integer;
  o, b : Boolean;
begin
  b := False;
  with p^
  do begin
    i := Integer(GetDlgItemInt(hWindow, 100, nil, True));
    if i <> X then b := True;
    X := i;
    i := Integer(GetDlgItemInt(hWindow, 101, nil, True));
    if i <> Y then b := True;
    Y := i;
    i := 0;
    while not WordBool(IsDlgButtonChecked(hWindow, 110+i)) do inc(i);
    if i <> Direction then b := True;
    Direction := i;
    i := Integer(GetDlgItemInt(hWindow, 105, nil, False));
    if ( i <> NumIO ) and ( i>=0 )
    then SetNumIO(i, pLayoutWindow(Parent));
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tIOSMacroItem.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pIOMacroItemDlg, Init(Window, @Self)));
end;

function tIOSMacroItem.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
var
  i : integer;
  Menu : hMenu;
begin
  case io of
    1 : i := 7;
    0 : i := 8;
   -1 : i := 9;
  end;
  Menu := GetSubMenu( ItemMenu, i );
  if NumIO = 0
  then EnableMenuItem( Menu, cm_DelOneIO, MF_GRAYED + MF_BYCOMMAND );
  GetMenu := Menu;
end;

procedure tIOSMacroItem.SetNumIO( xNumIO : integer; LayWin : pLayoutWindow );
var
  pcon : pConArray;
  con : pConArray;
  state_ : pIntegerArray;
  i : integer;
begin
  LayWin^.DeleteItem(@Self);
  if io > 0
  then pcon := InCon
  else pcon := OutCon;
  GetMem( con, xNumIO * SizeOf(tCon) );
  FillChar( con^, xNumIO * SizeOf(tCon), $00 );
  GetMem( state_, xNumIO * SizeOf(integer) );
  FillChar( state_^, xNumIO * SizeOf(integer), $00 );
  if xNumIO > NumIO
  then begin
    Move ( pcon^, con^, NumIO * SizeOf(tCon) ); { Alte Verbindungen kopieren. }
    Move ( state^, state_^, NumIO * SizeOf(integer) ); { Alte Zust�nde kopieren. }
  end
  else begin
    Move ( pcon^, con^, xNumIO * SizeOf(tCon) ); { Alte Verbindungen kopieren. }
    Move ( state^, state_^, xNumIO * SizeOf(integer) ); { Alte Zust�nde kopieren. }
    for i := xNumIO to NumIO-1 { �berz�hlige Verbindungen l�schen. }
    do begin
    if pcon^[i].con <> nil
    then SendMessage( LayWin^.OscWin^.hWindow, ms_OscDelCon, 0, longint(pcon^[i].con) );
      pcon^[i].Free;
      pcon^[i].DelCon;
    end;
  end;
  FreeMem ( pcon, NumIO * SizeOf(tCon) );
  FreeMem ( state, NumIO * SizeOf(integer) );
  if io > 0
  then InCon := con
  else OutCon := con;
  state := state_;
  NumIO := xNumIO;
  CalcItemRect;
  LayWin^.InsertItem(@Self, LayWin^.DragDC);
end;

procedure tIOSMacroItem.IncNumIO( xInc : integer; LayWin : pLayoutWindow );
begin
  SetNumIO( NumIO + xInc, LayWin );
end;

procedure tIOSMacroItem.SendImpulse(
  NumIn_, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  { F�r OutMacroItem und StateMacroItem geschrieben. }
  if NumIn_ > 0
  then {Tilt(PaintDC, NumIn_)}
  else begin
    state^[-NumIn_-1] := Impulse;
    if PaintCol^.IndexOf(@Self)<0
    then PaintCol^.Insert(@Self);
  end;
end;

{ ------ tOutMacroItem ------------------------------------------------- }

constructor tOutMacroItem.Init;
begin
  inherited Init;
  hLayWin := 0;
  OutCon2 := nil;
end;

constructor tOutMacroItem.Load(var S : tStream);
begin
  inherited Load(S);
  hLayWin := 0;
  OutCon2 := nil;
end;

procedure tOutMacroItem.SendImpulse(
  NumIn_, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
var
  i : integer;
begin
  inherited SendImpulse( NumIn_, Impulse, PaintCol, Impulses );
  if (hLayWin<>0)
  then begin
    i := (-NumIn_) - 1;
    SendMessage(
      hLayWin,
      ms_MacroImpulse,
      0,
      longint(New(pImpulse, Init(OutCon2^[i].Con, OutCon2^[i].Num, state^[i], 0))) );
    end;
end;

{ ------ tInMacroItem -------------------------------------------------- }

constructor tInMacroItem.Init;
begin
  tInOutItem.Init;
  io := 1;
  NumIO := 0;
  GetMem(InCon, NumIO * SizeOf(tCon));
  FillChar(InCon^, NumIO * SizeOf(tCon), $00);
  GetMem(state, NumIO * SizeOf(Integer));
  FillChar(state^, NumIO * SizeOf(Integer), $00);
  OutCon := nil;
end;

constructor tInMacroItem.Load(var S : tStream);
begin
  tInOutItem.Load(S);
  S.Read(
    NumIO,
    SizeOf(NumIO) );
  io := 1;
  GetMem(InCon, NumIO * SizeOf(tCon));
  FillChar(InCon^, NumIO * SizeOf(tCon), $00);

  GetMem(state, NumIO * SizeOf(integer));
  FillChar(state^, NumIO * SizeOf(integer), $00);

  OutCon := nil;
  CalcItemRect;
end;

function tInMacroItem.GetState(A : tPoint; b : Integer) : Integer;
begin
  if Boolean(b and lm_Test)
  then begin
    case (b and lm_First) of
      lm_MouseMove,
      lm_lButton : GetState := ls_ToggleSwitch;
      else GetState := ls_Test;
    end;
  end
  else GetState := inherited GetState(A, b);
end;

procedure tInMacroItem.Toggle( A : tPoint );
var
  i : integer;
begin
  dec(A.X, X);
  dec(A.Y, Y);
  with A do GetPos(X, Y, X, Y, -Direction);
  i := (A.Y-3) div -10;
  state^[i] := integer(not boolean(state^[i]))
end;

procedure tInMacroItem.GetInitImpulse(Impulses : pCollection);
var
  i : integer;
  con : pConArray;
begin
  if io > 0
  then con := InCon
  else con := OutCon;
  for i := 0 to NumIO-1
  do Impulses^.Insert(
       New(pImpulse, Init(Con^[i].Con, Con^[i].Num, state^[i], 0)));
end;

procedure tInMacroItem.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  (*if NumIn = 1 then Tilt(PaintDC, NumIn);*)
end;

procedure tInMacroItem.OutImpulse(Impulses : pCollection);
begin
  GetInitImpulse(Impulses);
end;

procedure tInMacroItem.SetImpulse( InOutMem : Pointer; Impulses : pCollection );
begin
  Move( InOutMem^, state^, NumIO * sizeof(integer) );
  OutImpulse(Impulses);
end;

{ ------ tStateMacroItem ----------------------------------------------- }

constructor tStateMacroItem.Init;
begin
  inherited Init;
  hLayWin := 0;
  io := -1;
end;

constructor tStateMacroItem.Load(var S : tStream);
begin
  inherited Load(S);
  hLayWin := 0;
  io := -1;
end;

procedure tStateMacroItem.SendImpulse(
  NumIn_, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  inherited SendImpulse( NumIn_, Impulse, PaintCol, Impulses );
  if (hLayWin <> 0)
  then begin
    Move( state^, StateMem^, NumIO * sizeof(integer) );
    SendMessage(
      hLayWin,
      ms_MacroPaint,
      0,
      longint(MacroItem) );
  end;
end;

{ ------ tMacroWindow -------------------------------------------------- }

constructor tMacroWindow.Init(
  xParent : pWindowsObject; xelement : pMacroEle );
begin
  inherited Init ( xParent );
  Attr.Style :=
    Attr.Style or
    WS_ICONIC;
  element := xelement;
  hLayWin := 0;
  MacroItem := nil;
end;

procedure tMacroWindow.SetupWindow;
var
  PaintDC : hDC;
begin
  inherited SetupWindow;
  SetCaption ( element^.Name );
  if element^.layout <> nil
  then begin
    element^.layout^.Seek(0);
    Load ( element^.layout^ );
  end
  else begin
    PaintDC := GetDC(hWindow);
    pScrollerOrg(Scroller)^.BeginZoom(PaintDC);

    InItem := New(pInMacroItem, Init);
    InItem^.IncPos ( -10, 0 );
    InsertItem ( InItem, PaintDC );

    OutItem := New(pOutMacroItem, Init);
    OutItem^.IncPos ( +10, 0 );
    InsertItem ( OutItem, PaintDC );

    StateItem := New(pStateMacroItem, Init);
    StateItem^.IncPos ( 0, 10 );
    InsertItem ( StateItem, PaintDC );

    ReleaseDC(hWindow, PaintDC);
  end;
end;

function tMacroWindow.CanClose : Boolean;
var
  s, s_ : pChar;
  i : Integer;
begin
  if NotClose
  then begin
    GetWindowText(hWindow, @String1, StringLen);
    GetMem(s, StrLen(LoadString0(84)) + StrLen(@String1) - 1 {+1-2});
    s_ := @String1;
    wvsprintf(s, @String0, s_);
    case MessageBox(
           hWindow, s, LoadString0(96),
           mb_IconQuestion or mb_YesNoCancel)
    of
      id_Yes :
        begin
          SaveChanges;
          CanClose := True;
        end;
      id_No : CanClose := True;
      else CanClose := False;
    end;
    StrDispose(s);
  end
  else CanClose := True;
end;

procedure tMacroWindow.SaveChanges;
begin
  element^.SetNumInOut( InItem^.NumIO, OutItem^.NumIO, StateItem^.NumIO );
  { Alte Speicherung der Schaltung l�schen. }
  if element^.layout <> nil
  then Dispose ( element^.layout, Done );
  { Schaltung in Element speichern. }
  SendMessage( hMainWin, ms_LockSpeedbar, Word(true), 0 );
  element^.layout := New ( pMemoryStream, Init ( 0, 1 ) );
  Store ( element^.layout^ );
  SendMessage( hMainWin, ms_LockSpeedbar, Word(false), 0 );
  { Versionsnummer erh�hen }
  element^.IncVersion;
end;

function tMacroWindow.GetClassName: PChar;
begin
  GetClassName := 'LK_MacroWin';
end;

procedure tMacroWindow.IncIO( xInc : integer );
var
  ActLay_ : pLay;
begin
  ActLay_ := SetActLay(@Lay);
  InvalidateItem(ActItem);
  pOutMacroItem(ActItem)^.IncNumIO(xInc, @Self);
  InvalidateItem(ActItem);
  SetActLay(ActLay_);
  SetNotClose;
end;

procedure tMacroWindow.cmAddOneIO( var Msg : tMessage );
begin
  IncIO(+1);
end;

procedure tMacroWindow.cmDelOneIO( var Msg : tMessage );
begin
  IncIO(-1);
end;

type
  tIOSidx = record
    InIdx,
    OutIdx,
    StateIdx : integer;
  end;

procedure tMacroWindow.Load(var S : tStream);
var
  ios : tIOSidx;
begin
  inherited Load(S);
  S.Read ( ios, SizeOf(ios) );
  with ios
  do begin
    InItem := Lay.Layout^.At(InIdx);
    OutItem := Lay.Layout^.At(OutIdx);
    StateItem := Lay.Layout^.At(StateIdx);
  end;
end;

procedure tMacroWindow.Store(var S : tStream);
var
  ios : tIOSidx;
begin
  inherited Store(S);
  with ios
  do begin
    InIdx := Lay.Layout^.IndexOf(InItem);
    OutIdx := Lay.Layout^.IndexOf(OutItem);
    StateIdx := Lay.Layout^.IndexOf(StateItem);
  end;
  S.Write ( ios, SizeOf(ios) );
end;

procedure tMacroWindow.msMacroOutImpulse( var Msg : tMessage );
begin
  with pMacroOutImpulse(Msg.lParam)^
  do begin
    InItem^.SetImpulse(InMem, Self.Impulses);
    InvalidateItem(InItem);
    StateItem^.StateMem := StateMem;
    StateItem^.hLayWin := hLayWin;
    OutItem^.hLayWin := hLayWin;
    OutItem^.OutCon2 := Con;
  end;
  StateItem^.MacroItem := MacroItem;
end;

procedure tMacroWindow.msMacroSimReset( var Msg : tMessage );
begin
  cmSimReset(Msg);
end;

procedure tMacroWindow.msMacroSimStart( var Msg : tMessage );
begin
  hLayWin := Msg.wParam;
  MacroItem := pItem(Msg.lParam);
  cmSimStart(Msg);
end;

procedure tMacroWindow.msMacroSimStop( var Msg : tMessage );
begin
  hLayWin := 0;
  MacroItem := nil;
  cmSimStop(Msg);
end;

procedure tMacroWindow.msTick(var Msg : tMessage);
begin
  { Auf normalen Tick nur bei Element->Ein/Ausgabe reagieren. }
  if WordBool(Msg.wParam) or (element<>nil)
  then inherited msTick(Msg);
end;

procedure tMacroWindow.msShowMacroWin(var Msg : tMessage);
begin
  SendMessage( hWindow, ms_ShowWindow, 0, 0 );
end;

procedure tMacroWindow.msHideMacroWin(var Msg : tMessage);
begin
  SendMessage( hWindow, ms_HideWindow, 0, 0 );
end;

procedure tMacroWindow.wmClose( var Msg : tMessage );
begin
  if boolean(Msg.wParam) or (hLayWin=0)
  then inherited wmClose(Msg)
  else msHideWindow(Msg);
end;

procedure tMacroWindow.msStoreInOut(var Msg : tMessage);
var
  ActLay_ : pLay;
begin
  Lay.StoreInOut(pStream(Msg.lParam)^);
  ActLay_ := SetActLay(@Lay);
  Impulses^.Store(pStream(Msg.lParam)^);
  ActLay_ := SetActLay(@Lay);
  SetActLay(ActLay_);
  tPaint.Store(pStream(Msg.lParam)^);
  pStream(Msg.lParam)^.Write(
    ShowInOut, SizeOf(ShowInOut) + SizeOf(TestInit));
  NameEx := True;
  NotClose := False;
  OscWin^.Store(pStream(Msg.lParam)^);
end;

procedure tMacroWindow.msLoadInOut(var Msg : tMessage);
var
  ActLay_ : pLay;
begin
  Lay.LoadInOut(pStream(Msg.lParam)^);
  ActLay_ := SetActLay(@Lay);
  Impulses^.Load(pStream(Msg.lParam)^);
  SetActLay(ActLay_);
  tPaint.Load(pStream(Msg.lParam)^);
  pStream(Msg.lParam)^.Read(
    ShowInOut, SizeOf(ShowInOut) + SizeOf(TestInit));
  TestOn := false;
  NameEx := True;
  OscWin^.Load(pStream(Msg.lParam)^);
end;

{ ------ rInMacroItem --------------------------------------------------- }

const
  rInMacroItem : TStreamRec = (
     ObjType : riInMacroItem;
     VmtLink : Ofs(TypeOf(tInMacroItem)^);
     Load  : @tInMacroItem.Load;
     Store : @tInMacroItem.Store
  );

{ ------ rOutMacroItem -------------------------------------------------- }

const
  rOutMacroItem : TStreamRec = (
     ObjType : riOutMacroItem;
     VmtLink : Ofs(TypeOf(tOutMacroItem)^);
     Load  : @tOutMacroItem.Load;
     Store : @tOutMacroItem.Store
  );

{ ------ rStateMacroItem ------------------------------------------------ }

const
  rStateMacroItem : TStreamRec = (
     ObjType : riStateMacroItem;
     VmtLink : Ofs(TypeOf(tStateMacroItem)^);
     Load  : @tStateMacroItem.Load;
     Store : @tStateMacroItem.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rInMacroItem);
  RegisterType(rOutMacroItem);
  RegisterType(rStateMacroItem);
  InputItem_Name := StrNew(LoadString0(11));
  OutputItem_Name := StrNew(LoadString0(34));
  State_Name := StrNew(LoadString0(55));
end.