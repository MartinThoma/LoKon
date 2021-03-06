unit ZeroOne;
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
  Item,
  Switch;

type
  pZero = ^tZero;
  tZero = object (tSwitch)
    constructor Init;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    procedure NotPaint(PaintDC : hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
  end;

type
  pOne = ^tOne;
  tOne = object (tZero)
    constructor Init;
    constructor Load(var S : tStream);
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
  end;

type
  pZeroDlg = ^tZeroDlg;
  tZeroDlg = object (tSwitchDlg)
    procedure SetupWindow; virtual;
  end;

implementation

{ ------ Grafiken f�r Feste_Null und Feste_Eins ------------------------- }

var
  Gr_Zero,
  Gr_One : pElement;

{ ------ tZero ---------------------------------------------------------- }

var ZeroName : pChar;

constructor tZero.Init;
begin
  inherited Init;
  on_ := False;
  Con.Done;
  CalcItemRect;
end;

constructor tZero.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('Zero.Load 1');
{$endif}
  tDirectionItem.Load(S);
  on_ := False;
  Con.Done;
  CalcItemRect;
{$ifdef debug}
  appendLog('Zero.Load 2');
{$endif}
end;

procedure tZero.Store(var S : tStream);
begin
  tDirectionItem.Store(S);
end;

procedure tZero.StoreText(var t : Text);
begin
  tDirectionItem.StoreText(t);
end;

function tZero.Copy : pItem;
var p : pZero;
begin
  p := New(pZero, Init);
  Move(X, p^.X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction));
  p^.CalcItemRect;
  Copy := p;
end;

function tZero.Name : pChar;
begin
  Name := ZeroName;
end;

procedure tZero.NotPaint(PaintDC : hDC);
begin
  Con.NotPaint(PaintDC);
  SetWindowOrg(PaintDC, -X, -Y);
  if on_
  then Gr_One^.NotPaint(PaintDC, Direction)
  else Gr_Zero^.NotPaint(PaintDC, Direction);
end;

procedure tZero.Paint(PaintDC : hDC);
begin
  SetWindowOrg(PaintDC, -X, -Y);
  SelectObject(PaintDC, DrawPen);
  if on_
  then Gr_One^.Graphic.Paint(PaintDC, Direction)
  else Gr_Zero^.Graphic.Paint(PaintDC, Direction);
end;

function tZero.GetState(A : tPoint; b : Integer) : Integer;
begin
  GetState := tDirectionItem.GetState(A, b);
end;

procedure tZeroDlg.SetupWindow;
begin
  inherited SetupWindow;
  EnableWindow(GetItemHandle(102), False);
end;

procedure tZero.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(
    New(pZeroDlg, Init(Window, @Self, Name)));
end;

function tZero.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
var Menu : hMenu;
begin
  Menu := inherited GetMenu( ItemMenu, window );
  EnableMenuItem(
    Menu,
    cm_SwitchState,
    MF_GRAYED);
  GetMenu := Menu;
end;

{ ------ tOne ----------------------------------------------------------- }

var OneName : pChar;

constructor tOne.Init;
begin
  inherited Init;
  on_ := True;
  Con.Done;
  CalcItemRect;
end;

constructor tOne.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('One.Load 1');
{$endif}
  inherited Load(S);
  on_ := True;
  Con.Done;
  CalcItemRect;
{$ifdef debug}
  appendLog('One.Load 2');
{$endif}
end;

function tOne.Copy : pItem;
var p : pOne;
begin
  p := New(pOne, Init);
  Move(X, p^.X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction));
  p^.CalcItemRect;
  Copy := p;
end;

function tOne.Name : pChar;
begin
  Name := OneName;
end;

{ ------ tLoadZeroOne ------------------------------------------------------ }

procedure LoadZeroOne;
var
  Collection : pCollection;
begin
  Collection := getInternCollection;
  with Collection^
  do begin
    Gr_Zero := pElement(At(2));
    Gr_One := pElement(At(3));
    DeleteAll;
  end;
  Dispose(Collection, Done);
end;

{ ------ rZero ---------------------------------------------------------- }

const
  rZero : TStreamRec = (
     ObjType : riZero;
     VmtLink : Ofs(TypeOf(tZero)^);
     Load  : @tZero.Load;
     Store : @tZero.Store
  );

{ ------ rOne ----------------------------------------------------------- }

const
  rOne : TStreamRec = (
     ObjType : riOne;
     VmtLink : Ofs(TypeOf(tOne)^);
     Load  : @tOne.Load;
     Store : @tOne.Store
  );

begin
  { Grafiken f�r Feste_Null und Feste_Eins laden. }
  LoadZeroOne;

  ZeroName := StrNew(LoadString0(160));
  OneName := StrNew(LoadString0(161));

  { Registrierung. }
  RegisterType(rZero);
  RegisterType(rOne);
end.