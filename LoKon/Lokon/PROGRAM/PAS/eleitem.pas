unit EleItem;
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
  Item, Impulse,
  EleFile;

type
  pEleItem = ^tEleItem;
  tEleItem = object (tInOutItem)
    Element : pElement;
    InOutMem : Pointer;
    constructor Init(xElement : pElement);
    destructor Done; virtual;
    function Name : pChar; virtual;
    procedure Reset; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream); virtual;
    procedure StoreText(var t : Text); virtual;
    procedure StoreInOut(var S : tStream); virtual;
    function LoadInOut(var S : tStream) : Boolean; virtual;
    function Copy : pItem; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetRegionInOut : hRgn; virtual;
    function NumInCon : Integer; virtual;
    function NumOutCon : Integer; virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : tPoint; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure PaintInOut(PaintDC : hDC); virtual;
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure OutImpulse(Impulses : pCollection); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
{$ifdef layele}
    procedure SimStart( hLayWin : HWND ); virtual;
    procedure EleTick; virtual;
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
    procedure ShowMacro; virtual;
{$endif}
  end;

implementation

{ ------ tEleItem ------------------------------------------------------- }

constructor tEleItem.Init(xElement : pElement);
begin
  inherited Init;
  Element := xElement;
  InOutMem := xElement^.GetInOutMem;
  GetMem(InCon, Element^.NumIn * SizeOf(tCon));
  FillChar(InCon^, Element^.NumIn * SizeOf(tCon), $00);
  GetMem(OutCon, Element^.NumOut * SizeOf(tCon));
  FillChar(OutCon^, Element^.NumOut * SizeOf(tCon), $00);
  CalcItemRect;
end;

destructor tEleItem.Done;
procedure DoCon(Con : pConArray; Num : Integer);
var
  i : Integer;
begin
  for i := 0 to Num-1 do
    Con^[i].DelCon;
  FreeMem(Con, Num * SizeOf(tCon));
end;
begin
  DoCon(InCon, Element^.NumIn);
  DoCon(OutCon, Element^.NumOut);
  Element^.FreeInOutMem(InOutMem);
end;

constructor tEleItem.Load(var S : tStream);
var
  i : Longint;
begin
{$ifdef debug}
  appendLog('tEleItem.Laod 1');
{$endif}
  inherited Load(S);
  i := S.ReadInteger;
  Element := ActLay^.GetElement(i);
  GetMem(InCon, Element^.NumIn * SizeOf(tCon));
  FillChar(InCon^, Element^.NumIn * SizeOf(tCon), $00);
  GetMem(OutCon, Element^.NumOut * SizeOf(tCon));
  FillChar(OutCon^, Element^.NumOut * SizeOf(tCon), $00);
  InOutMem := nil;
  CalcItemRect;
{$ifdef debug}
  appendLog('tEleItem.Laod 2');
{$endif}
end;

procedure tEleItem.Store(var S : tStream);
var
  i : tPoint;
begin
  inherited Store(S);
  i := ActLay^.GetID(Element);
  S.Write(i, SizeOf(i));
end;

procedure tEleItem.StoreText(var t : Text);
var
  i : tPoint;
begin
  inherited StoreText(t);
  i := ActLay^.GetID(Element);
  StorePoint(t, 'elementID', i);
end;

procedure tEleItem.StoreInOut(var S : tStream);
begin
  Element^.StoreInOutMem(S, InOutMem);
end;

function tEleItem.LoadInOut(var S : tStream) : Boolean;
begin
  LoadInOut := Element^.LoadInOutMem(S, InOutMem);
end;

function tEleItem.Copy : pItem;
var
  p : pEleItem;
begin
  p := New(pEleItem, Init(Element));
  Move(X, p^.X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction));
  p^.CalcItemRect;
  Copy := p;
end;

function tEleItem.Name : pChar;
begin
  Name := Element^.Name;
end;

procedure tEleItem.Reset;
begin
  Element^.ClearInOutMem(InOutMem, InCon)
end;

function tEleItem.GetRegion_ : hRgn;
var
  Rgn : hRgn;
begin
  Rgn := Element^.CalcRgn(Direction);
  OffsetRgn(Rgn, X, Y);
  GetRegion_ := Rgn;
end;

function tEleItem.GetRegionInOut : hRgn;
var
  Rgn : hRgn;
begin
  Rgn := Element^.CalcInOutRgn(Direction);
  OffsetRgn(Rgn, X, Y);
  GetRegionInOut := Rgn;
end;

function tEleItem.GetInOutNr(A : tPoint) : Integer;
begin
  dec(A.X, X);
  dec(A.Y, Y);
  with A do GetPos(X, Y, X, Y, -Direction);
  GetInOutNr := Element^.GetInOutNr(A);
end;

function tEleItem.GetInOutPos(Num : Integer) : tPoint;
var
  A : tPoint;
begin
  A := Element^.PosInOut(Num);
  with tPoint(A) do GetPos(X, Y, X, Y, Direction);
  inc(A.X, X);
  inc(A.Y, Y);
  GetInOutPos := A;
end;

procedure tEleItem.NotPaint(PaintDC : hDC);
procedure DoCon(Con : pConArray; Num : Integer);
var
  i : Integer;
begin
  for i := 0 to Num-1 do
    Con^[i].NotPaint(PaintDC);
end;
begin
  DoCon(InCon, Element^.NumIn);
  DoCon(OutCon, Element^.NumOut);
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  Element^.NotPaint(PaintDC, Direction);
end;

procedure tEleItem.Paint(PaintDC : hDC);
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  Element^.Paint(PaintDC, Direction, InOutMem);
end;

procedure tEleItem.PaintInOut(PaintDC : hDC);
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  Element^.PaintInOut(PaintDC, Direction);
end;

procedure tEleItem.GetInitImpulse(Impulses : pCollection);
begin
  Element^.ClearInOutMem(InOutMem, InCon);
  Element^.OutImpulse(InOutMem, OutCon, Impulses);
end;

procedure tEleItem.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
var
  Rgn : hRgn;
begin
  if NumIn < 0
  then (*Tilt(PaintDC, NumIn);*)
  else begin
    if Element^.SendImpulse(
         InOutMem, OutCon, NumIn, Impulse, Impulses)
    then
      if PaintCol^.IndexOf(@Self)<0 then PaintCol^.Insert(@Self);
  end;
end;

procedure tEleItem.OutImpulse(Impulses : pCollection);
begin
  Element^.OutImpulse(InOutMem, OutCon, Impulses);
end;

type
  pEleItemDlg = ^tEleItemDlg;
  tEleItemDlg = object (tDialogSB)
    p : pEleItem;
    constructor Init(xParent : pWindowsObject; xp : pEleItem);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tEleItemDlg.Init(xParent : pWindowsObject; xp : pEleItem);
begin
  with xp^.Element^ do
    if NumState = 0 then inherited Init(xParent, 'ELEITEMDLG')
    else if NumState <= 10 then inherited Init(xParent, 'ELEITEM1DLG')
    else inherited Init(xParent, 'ELEITEM2DLG');
  p := xp;
end;

procedure tEleItemDlg.SetupWindow;
var
  i : Integer;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    SetDlgItemText(hWindow, 102, Name);
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
    for i := 0 to Element^.NumState-1
    do begin
      EnableWindow(GetItemHandle(300+i), True);
      if Element^.GetState(InOutMem, i)<>0
      then CheckDlgButton(hWindow, 300+i, Word(True));
    end;
  end;
end;

procedure tEleItemDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 810);
end;

procedure tEleItemDlg.OK(var Msg : tMessage);
var
  i : Integer;
  b, bc : Boolean;
  translated : Windows.Bool;
begin
  b := False;
  with p^
  do begin
    i := Integer(GetDlgItemInt(hWindow, 100, translated, True));
    if i <> X then b := True;
    X := i;
    i := Integer(GetDlgItemInt(hWindow, 101, translated, True));
    if i <> Y then b := True;
    Y := i;
    i := 0;
    while not WordBool(IsDlgButtonChecked(hWindow, 110+i)) do inc(i);
    if i <> Direction then b := True;
    Direction := i;
    for i := 0 to Element^.NumState-1
    do begin
      bc := WordBool(IsDlgButtonChecked(hWindow, 300+i));
      if Integer(bc) <> Element^.GetState(InOutMem, i)
      then begin
        Element^.SetState(InOutMem, i, Integer(bc));
        b := TRUE;
      end;
    end;
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tEleItem.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pEleItemDlg, Init(Window, @Self)))
end;

function tEleItem.NumInCon : Integer;
begin
  NumInCon := Element^.NumIn;
end;

function tEleItem.NumOutCon : Integer;
begin
  NumOutCon := Element^.NumOut;
end;

{$ifdef layele}

procedure tEleItem.SimStart( hLayWin : HWND );
begin
  Element^.SimStart( InOutMem, hLayWin, @Self );
end;

procedure tEleItem.EleTick;
begin
  Element^.EleTick( InOutMem );
end;

function tEleItem.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
var
  menu : hMenu;
begin
  menu := inherited GetMenu( ItemMenu, window );
  menu := element^.GetMenu( menu );
  GetMenu := menu;
end;

procedure tEleItem.ShowMacro;
begin
  element^.ShowMacro( InOutMem );
end;

{$endif}

{ ------ rEleItem ------------------------------------------------------- }

const
  rEleItem : TStreamRec = (
     ObjType : riEleItem;
     VmtLink : Ofs(TypeOf(tEleItem)^);
     Load  : @tEleItem.Load;
     Store : @tEleItem.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rEleItem);
end.
