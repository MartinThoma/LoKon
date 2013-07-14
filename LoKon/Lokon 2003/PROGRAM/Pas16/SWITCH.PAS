unit Switch;
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
  pSwitch = ^tSwitch;
  tSwitch = object (t1ConItem)
    constructor Init;
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
    procedure OutImpulse(Impulses : pCollection); virtual;
    procedure Toggle( A : tPoint ); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
  end;

var
  SwitchOn, SwitchOff : pElement;

type
  pSwitchDlg = ^tSwitchDlg;
  tSwitchDlg = object (tDialogSB)
    Name : pChar;
    p : pSwitch;
    constructor Init(
      xParent : pWindowsObject; xp : pSwitch; xName : pChar);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

implementation

{ ------ tSwitch --------------------------------------------------------- }

var SwitchName : pChar;

constructor tSwitch.Init;
begin
  inherited Init;
  CalcItemRect;
end;

constructor tSwitch.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('Switch.Load 1');
{$endif}
  inherited Load(S);
  S.Read(on_, SizeOf(on_));
  Con.Done;
  CalcItemRect;
{$ifdef debug}
  appendLog('Switch.Load 2');
{$endif}
end;

procedure tSwitch.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(on_, SizeOf(on_));
end;

procedure tSwitch.StoreText(var t : Text);
begin
  inherited StoreText(t);
  StoreBool(t, 'on', on_);
end;

function tSwitch.Copy : pItem;
var p : pSwitch;
begin
  p := New(pSwitch, Init);
  Move(X, p^.X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction)+SizeOf(on_));
  p^.CalcItemRect;
  Copy := p;
end;

function tSwitch.Name : pChar;
begin
  Name := SwitchName;
end;

function tSwitch.GetRegion_ : hRgn;
var Rgn : hRgn;
begin
  if on_
  then Rgn := SwitchOn^.CalcRgn(Direction)
  else Rgn := SwitchOff^.CalcRgn(Direction);
  OffSetRgn(Rgn, X, Y);
  GetRegion_ := Rgn;
end;

function tSwitch.GetState(A : tPoint; b : Integer) : Integer;
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

procedure tSwitch.NotPaint(PaintDC : hDC);
begin
  Con.NotPaint(PaintDC);
  SetWindowOrg(PaintDC, -X, -Y);
  if on_
  then SwitchOn^.NotPaint(PaintDC, Direction)
  else SwitchOff^.NotPaint(PaintDC, Direction);
end;

procedure tSwitch.Paint(PaintDC : hDC);
begin
  SetWindowOrg(PaintDC, -X, -Y);
  SelectObject(PaintDC, DrawPen);
  if on_
  then SwitchOn^.Graphic.Paint(PaintDC, Direction)
  else SwitchOff^.Graphic.Paint(PaintDC, Direction);
end;

procedure tSwitch.GetInitImpulse(Impulses : pCollection);
begin
  { Ein Schalter sendet bei der Initialisierung einen Impuls. }
  Impulses^.Insert(
    New(pImpulse, Init(Con.Con, Con.Num, Integer(on_), 0)));
end;

procedure tSwitch.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  (*if NumIn = 1 then Tilt(PaintDC, NumIn);*)
end;

procedure tSwitch.OutImpulse(Impulses : pCollection);
begin
  Impulses^.Insert(
    New(pImpulse, Init(Con.Con, Con.Num, Integer(on_), 0)));
end;

procedure tSwitch.Toggle( A : tPoint );
begin
  on_ := not on_;
end;

constructor tSwitchDlg.Init(
  xParent : pWindowsObject; xp : pSwitch; xName : pChar);
begin
  inherited Init(xParent, 'SWITCHDLG');
  Name := xName;
  p := xp;
end;

procedure tSwitchDlg.SetupWindow;
begin
  inherited SetupWindow;
  SetWindowText(hWindow, Name);
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    CheckDlgButton(hWindow, 102, Word(on_));
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
  end;
end;

procedure tSwitchDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 820);
end;

procedure tSwitchDlg.OK(var Msg : tMessage);
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
    i := 0;
    while not WordBool(IsDlgButtonChecked(hWindow, 110+i)) do inc(i);
    if i <> Direction then b := True;
    Direction := i;
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tSwitch.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pSwitchDlg, Init(Window, @Self, Name)));
end;

{ ------ tLoadSwitches ----------------------------------------------------- }

procedure LoadSwitches;
var
  Collection : pCollection;
begin
  Collection := getInternCollection;
  with Collection^
  do begin
    SwitchOff := pElement(At(0));
    SwitchOn := pElement(At(1));
    DeleteAll;
  end;
  Dispose(Collection, Done);
end;

function tSwitch.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
var
  Menu : hMenu;
begin
  Menu := GetSubMenu( ItemMenu, 3 );
  if on_ then
    CheckMenuItem(
      Menu,
      cm_SwitchState,
      MF_CHECKED);
  GetMenu := Menu;
end;

{ ------ rSwitch -------------------------------------------------------- }

const
  rSwitch : TStreamRec = (
     ObjType : riSwitch;
     VmtLink : Ofs(TypeOf(tSwitch)^);
     Load  : @tSwitch.Load;
     Store : @tSwitch.Store
  );

begin
  { Schalter-Grafiken laden. }
  LoadSwitches;

  SwitchName := StrNew(LoadString0(25));

  { Registrierung. }
  RegisterType(rSwitch);
end.