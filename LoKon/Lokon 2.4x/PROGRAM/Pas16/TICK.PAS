unit Tick;
{$I define.inc}

interface

uses
  Strings,
  LK_Const,
  Objects,
  WinTypes, WinProcs,
  OWindows,
  OWinEx,
  Element,
  Impulse,
  Item;

type
  pTick = ^tTick;
  tTick = object (t1ConItem)
    Time : Word;
    constructor Init(xTime : Word);
    procedure Reset; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    procedure NotPaint(PaintDC : hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
  end;

var
  TickEle : pElement;

implementation

{ ------ tTick ----------------------------------------------------------- }

constructor tTick.Init(xTime : Word);
begin
  inherited Init;
  Time := xTime;
  CalcItemRect;
end;

procedure tTick.Reset;
begin
  on_ := False;
end;

constructor tTick.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('Tick.Load 1');
{$endif}
  inherited Load(S);
  S.Read(Time, SizeOf(Time));
  S.Read(on_, SizeOf(on_));
  Con.Done;
  CalcItemRect;
{$ifdef debug}
  appendLog('Tick.Load 2');
{$endif}
end;

procedure tTick.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(Time, SizeOf(Time));
  S.Write(on_, SizeOf(on_));
end;

procedure tTick.Storetext(var t : Text);
begin
  inherited StoreText(t);
  StoreInt(t, 'time', Time);
  StoreBool(t, 'on', on_);
end;

function tTick.Copy : pItem;
var p : pTick;
begin
  p := New(pTick, Init(Time));
  Move(X, p^.X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction));
  p^.CalcItemRect;
  Copy := p;
end;

function tTick.Name : pChar;
begin
  wvsprintf(@String1, LoadString0(28), Time);
  Name := @String1;
end;

function tTick.GetRegion_ : hRgn;
var Rgn : hRgn;
begin
  Rgn := TickEle^.CalcRgn(Direction);
  OffSetRgn(Rgn, X, Y);
  GetRegion_ := Rgn;
end;

function tTick.GetState(A : tPoint; b : Integer) : Integer;
begin
  if Boolean(b and lm_Test)
  then GetState := ls_Test
  else GetState := inherited GetState(A, b);
end;

procedure tTick.NotPaint(PaintDC : hDC);
begin
  Con.NotPaint(PaintDC);
  SetWindowOrg(PaintDC, -X, -Y);
  TickEle^.NotPaint(PaintDC, Direction);
end;

procedure tTick.Paint(PaintDC : hDC);
var s : array [0..4] of Char;
begin
  SetWindowOrg(PaintDC, -X, -Y);
  SelectObject(PaintDC, DrawPen);
  wvsprintf(@s, '%04i', Time);
  with TickEle^.Graphic
  do Move(s, Graphic^[GraphicSize-2], 4);
  TickEle^.Graphic.Paint(PaintDC, Direction);
end;

procedure tTick.GetInitImpulse(Impulses : pCollection);
begin
  { Ausgangsimpuls. }
  Impulses^.Insert(
    New(pImpulse, Init(Con.Con, Con.Num, Integer(on_), 0)));
  { Eigenimpuls f�r Takt. }
  Impulses^.Insert(
    New(pImpulse, Init(@Self, -1, Integer(on_), Time)));
end;

procedure tTick.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  if NumIn = -1
  then begin
    on_ := not Boolean(Impulse);
    { Ausgangsimpuls. }
    Impulses^.Insert(
      New(pImpulse, Init(Con.Con, Con.Num, Integer(on_), 0)));
    { Eigenimpuls f�r Takt. }
    Impulses^.Insert(
      New(pImpulse, Init(@Self, -1, Integer(on_), Time)));
  end;
  (*else Tilt(PaintDC, NumIn);*)
end;

type
  pTickDlg = ^tTickDlg;
  tTickDlg = object (tDialogSB)
    p : pTick;
    constructor Init(xParent : pWindowsObject; xp : pTick);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tTickDlg.Init(xParent : pWindowsObject; xp : pTick);
begin
  inherited Init(xParent, 'TICK_DLG');
  p := xp;
end;

procedure tTickDlg.SetupWindow;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    CheckDlgButton(hWindow, 102, Word(on_));
    SetDlgItemInt(hWindow, 103, Time, False);
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
  end;
end;

procedure tTickDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 860);
end;

procedure tTickDlg.OK(var Msg : tMessage);
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
    if WordBool(IsDlgButtonChecked(hWindow, 102))
    then o := True
    else o := False;
    if o <> on_ then b := True;
    on_ := o;
    Word(i) := GetDlgItemInt(hWindow, 103, nil, False);
    if Word(i) = 0 then Word(i) := 1;
    if Word(i) <> Time then b := True;
    Time := Word(i);
    i := 0;
    while not WordBool(IsDlgButtonChecked(hWindow, 110+i)) do inc(i);
    if i <> Direction then b := True;
    Direction := i;
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tTick.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pTickDlg, Init(Window, @Self)));
end;

function tTick.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
var Menu : hMenu;
begin
  Menu := GetSubMenu( ItemMenu, 4 );
  if on_ then
    CheckMenuItem(
      Menu,
      cm_TickState,
      MF_CHECKED);
  GetMenu := Menu;
end;

{ ------ tLoadTickEle ------------------------------------------------------ }

procedure LoadTickEle;
var
  Collection : pCollection;
begin
  Collection := getInternCollection;
  with Collection^
  do begin
    TickEle := pElement(At(4));
    DeleteAll;
  end;
  Dispose(Collection, Done);
end;

{ ------ rTick ---------------------------------------------------------- }

const
  rTick : TStreamRec = (
     ObjType : riTick;
     VmtLink : Ofs(TypeOf(tTick)^);
     Load  : @tTick.Load;
     Store : @tTick.Store
  );

begin
  { Taktgeber-Grafik laden. }
  LoadTickEle;
  { Registrierung. }
  RegisterType(rTick);
end.