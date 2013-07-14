unit ConNode;
{$I define.inc}

interface

uses
  Strings,
  LK_Const,
  Objects,
  WinTypes, WinProcs,
  OWindows,
  OWinEx,
  Item,
  Impulse;

type
  pConNode = ^tConNode;
  tConNode = object (tItem)
    X, Y : Integer;
    NumCon : Integer;
    Con : pConArray;
    constructor Init(xX, xY : Integer);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    procedure NewPos(Pos : tPosition); virtual;
    function Position : pPosition; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetRegionCon : hRgn; virtual;
    procedure DisposeCon; virtual;
    procedure DeleteCon(Layout : pCollection); virtual;
    procedure InsertCon(Layout : pCollection; PaintDC : hDC); virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : Longint; virtual;
    function GetInOutCon(Num : Integer) : pCon; virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    procedure SetCon(Num : Integer; p : pItem; Num_ : Integer); virtual;
    procedure SetCon_(Num : Integer; p : pItem; Num_ : Integer); virtual;
    function DelCon(xNum : Integer) : Integer; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function NumConReal : integer;
  end;

implementation

{ ------ tConNode ------------------------------------------------------- }

constructor tConNode.Init(xX, xY : Integer);
begin
  X := xX;
  Y := xY;
  NumCon := 0;
  Con := nil;
  CalcItemRect;
end;

destructor tConNode.Done;
var
  i : Integer;
begin
  for i := 0 to NumCon-1 do
    Con^[i].DelCon;
  FreeMem(Con, NumCon * SizeOf(tCon));
end;

constructor tConNode.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('ConNode.Load 1');
{$endif}
  S.Read(X, SizeOf(X) + SizeOf(Y));
  GetMem(Con, 0);
  NumCon := 0;
  CalcItemRect;
{$ifdef debug}
  appendLog('ConNode.Load 2');
{$endif}
end;

function tConNode.NumConReal : integer;
var
  i : integer;
  num : integer;
begin
  num := 0;
  for i := 0 to NumCon-1 do
    if Con^[i].Con <> nil
      then inc(num);
  NumConReal := num;
(*  NumConReal := NumCon;*)
end;


procedure tConNode.Store(var S : tStream);
begin
  S.Write(X, SizeOf(X) + SizeOf(Y));
end;

procedure tConNode.StoreText(var t : Text);
begin
  StoreInt(t, 'x', X);
  StoreInt(t, 'y', Y);
end;

function tConNode.Copy : pItem;
begin
  Copy := New(pConNode, Init(X, Y));
end;

function tConNode.Name : pChar;
begin
  Name := LoadString2(80);
end;

procedure tConNode.NewPos(Pos : tPosition);
begin
  pPoint(@X)^ := pPoint(@Pos)^;
  CalcItemRect;
end;

function tConNode.Position : pPosition;
begin
  Position := @X;
end;

function tConNode.GetRegion_ : hRgn;
begin
  GetRegion_ := CreateEllipticRgn(X-4, Y-4, X+4, Y+4);
end;

function tConNode.GetRegionCon : hRgn;
var
  i : Integer;
  Rgn, Rgn_ : hRgn;
  item : pItem;
begin
  Rgn := CreateEmptyRgn;
  for i := 0 to NumCon-1
  do begin
    item := Con^[i].Con;
    if (item <> nil)
    then begin
      Rgn_ := item^.GetRegion;
      CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
      DeleteObject(Rgn_);
    end;
  end;
  GetRegionCon := Rgn;
end;

procedure tConNode.DisposeCon;
var
  i : Integer;
begin
  { Funktioniert mit downto, mit to nicht. }
  for i := NumCon-1 downto 0 do
    Con^[i].Free;
end;

procedure tConNode.DeleteCon(Layout : pCollection);
var
  i : Integer;
begin
  for i := 0 to NumCon-1 do
    Con^[i].Delete(Layout);
end;

procedure tConNode.InsertCon(Layout : pCollection; PaintDC : hDC);
var
  i : Integer;
begin
  for i := 0 to NumCon-1 do
    Con^[i].Insert(Layout, PaintDC);
end;

function tConNode.GetInOutNr(A : tPoint) : Integer;
var
  nr : integer;
  i : integer;
begin
  nr := -1;
  for i := 0 to NumCon-1 do
    if Con^[i].Con = nil then
      nr := i;
  if nr = -1
  then nr := NumCon;
  inc(nr);
  GetInOutNr := nr;
end;

function tConNode.GetInOutPos(Num : Integer) : Longint;
var
  A : tPoint;
begin
  A.X := X;
  A.Y := Y;
  GetInOutPos := Longint(A);
end;

function tConNode.GetInOutCon(Num : Integer) : pCon;
begin
  if (Num <= 0) or (Num > NumCon) or (Con^[Num-1].Con=nil)
  then GetInOutCon := nil
  else GetInOutCon := @(Con^[Num-1]);
end;

function tConNode.GetState(A : tPoint; b : Integer) : Integer;
begin
  if (b and lm_Test) = lm_Test
  then GetState := ls_Test
  else
    case (b and lm_First) of
      lm_MouseMove,
      lm_LButton :
        begin
          if ( abs(A.X-X) < 2 ) and
             ( abs(A.Y-Y) < 2 )
          then GetState := ls_MoveActItem
          else GetState := ls_Connection;
        end;
      lm_Connect : GetState := ls_Connection;
    end;
end;

procedure tConNode.SetCon(Num : Integer; p : pItem; Num_ : Integer);
var
  Con_ : pConArray;
begin
  if p = nil
  then DelCon(Num)
  else begin
    if Num > NumCon
    then SetCon_(Num, p, Num_)
    else Con^[Num-1].Init(p, Num_);
  end;
end;

procedure tConNode.SetCon_(Num : Integer; p : pItem; Num_ : Integer);
var
  Con_ : pConArray;
  NumConOld : integer;
  i : integer;
begin
  NumConOld := NumCon;
  if (Num>NumCon)
  then NumCon := Num;
  GetMem(Con_, NumCon * SizeOf(tCon));
  for i := 0 to NumCon-1 do
    Con_^[i].Done;
  if NumConOld > 0
  then begin
    Move(Con^, Con_^, NumConOld * SizeOf(tCon));
    FreeMem(Con, NumConOld * SizeOf(tCon));
  end;
  Con_^[Num-1].Init(p, Num_);
  p^.SetCon(Num_, @Self, Num);
  Con := Con_;
end;

function tConNode.DelCon(xNum : Integer) : Integer;
var
  Con_ : pConArray;
begin
  if (xNum > 0) and (xNum <= NumCon)
  then Con^[xNum-1].Done;
  DelCon := xNum;
end;

procedure tConNode.NotPaint(PaintDC: hDC);
var
  i : Integer;
begin
  for i := 0 to NumCon-1 do
    Con^[i].NotPaint(PaintDC);
  Paint(PaintDC);
end;

procedure tConNode.Paint(PaintDC: hDC);
begin
  SetWindowOrg(PaintDC, 0, 0);
  SelectObject(PaintDC, GetStockObject(Black_Brush));
  SelectObject(PaintDC, DrawPen);
  Ellipse(PaintDC, X-2, Y-2, X+2, Y+2);
end;

procedure tConNode.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
var
  i : Integer;
begin
  { Impulse senden. }
  for i := 0 to NumCon-1 do
    if i <> (NumIn-1) then
      with Con^[i] do
        if (Con<>nil) then
          Impulses^.Insert(
            New(pImpulse, Init(Con, Num, Impulse, 0)));
end;

type
  pConNodeDlg = ^tConNodeDlg;
  tConNodeDlg = object (tDialogSB)
    p : pConNode;
    constructor Init(xParent : pWindowsObject; xp : pConNode);
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tConNodeDlg.Init(xParent : pWindowsObject; xp : pConNode);
begin
  inherited Init(xParent, 'CONNODEDLG');
  p := xp;
end;

procedure tConNodeDlg.SetupWindow;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    SetDlgItemInt(hWindow, 102, NumConReal, False);
  end;
end;

procedure tConNodeDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 830);
end;

procedure tConNodeDlg.OK(var Msg : tMessage);
var
  i : Integer;
  b : Boolean;
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
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tConNode.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pConNodeDlg, Init(Window, @Self)));
end;

{ ------ rConNode ------------------------------------------------------- }

const
  rConNode : TStreamRec = (
     ObjType : riConNode;
     VmtLink : Ofs(TypeOf(tConNode)^);
     Load  : @tConNode.Load;
     Store : @tConNode.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rConNode);
end.