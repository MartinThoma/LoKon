unit PLA;
{$I define.inc}

interface

uses
  LK_Const,
  WinTypes, WinProcs,
  Strings,
  Objects,
  OWindows,
  OWinEx,
  Impulse,
  Element,
  Item;

type
  pPLA = ^tPLA;
  tPLA = object (tInOutItem)
    NumIn, NumOut,
    NumLines : Integer;
    Time : Integer; { Zugriffszeit. }
    arrIn : pByteArray;
    arrOut : pBooleanArray;
    InMem : pIntegerArray;
    LineMem : pBooleanArray;
    constructor Init(
      xNumIn, xNumOut, xNumLines : Integer; xTime : Integer);
    destructor Done; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetRegionInOut : hRgn; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure PaintInOut(PaintDC : hDC); virtual;
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn_, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
    function NumInCon : Integer; virtual;
    function NumOutCon : Integer; virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : tPoint; virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    function GetMatrixNr( A : tPoint ) : Integer;
    procedure ToggleMatrix( A : tPoint );
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
    procedure DelInNodes; { Eingangsknoten löschen. }
    procedure DelOutNodes; { Ausgangsknoten löschen. }
  end;

implementation

var
  PLA_Name : pChar;

{ ------ tPLA ----------------------------------------------------------- }

constructor tPLA.Init(
  xNumIn, xNumOut, xNumLines : Integer; xTime : Integer);
begin
  inherited Init;
  NumIn := xNumIn;
  NumOut := xNumOut;
  NumLines := xNumLines;
  Time := xTime;
  GetMem(InCon, NumIn * SizeOf(tCon));
  FillChar(InCon^, NumIn * SizeOf(tCon), $00);
  GetMem(OutCon, NumOut * SizeOf(tCon));
  FillChar(OutCon^, NumOut * SizeOf(tCon), $00);
  GetMem( arrIn, NumIn * NumLines * SizeOf(byte) );
  FillChar(arrIn^, NumIn * NumLines * SizeOf(byte), 0 );
  GetMem( arrOut, NumOut * NumLines * SizeOf(boolean) );
  FillChar(arrOut^, NumOut * NumLines * SizeOf(boolean), 0 );
  GetMem(InMem, NumIn * SizeOf(Integer));
  FillChar(InMem^, NumIn * SizeOf(Integer), $00);
  GetMem(LineMem, NumLines * SizeOf(Boolean));
  FillChar(LineMem^, NumLines * SizeOf(Boolean), false);
end;

destructor tPLA.Done;
var
  i : Integer;
begin
  for i := 0 to NumIn-1 do
    InCon^[i].DelCon;
  for i := 0 to NumOut-1 do
    OutCon^[i].DelCon;
  FreeMem(InCon, NumIn * SizeOf(tCon));
  FreeMem(OutCon, NumOut * SizeOf(tCon));
  FreeMem( arrIn, NumIn * NumLines * SizeOf(byte) );
  FreeMem( arrOut, NumOut * NumLines * SizeOf(boolean) );
  FreeMem(InMem, NumIn * SizeOf(Integer));
  FreeMem(LineMem, NumLines * SizeOf(Boolean));
end;

constructor tPLA.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('PLA.Load 1');
{$endif}
  inherited Load(S);
  NumIn := S.ReadSmallInt;
  NumOut := S.ReadSmallInt;
  NumLines := S.ReadSmallInt;
  Time := S.ReadSmallInt;
  GetMem(InCon, NumIn * SizeOf(tCon));
  FillChar(InCon^, NumIn * SizeOf(tCon), $00);
  GetMem(OutCon, NumOut * SizeOf(tCon));
  FillChar(OutCon^, NumOut * SizeOf(tCon), $00);
  { PLA-Felder. }
  GetMem( arrIn, NumIn * NumLines * SizeOf(byte) );
  S.Read(arrIn^, NumIn * NumLines * SizeOf(byte) );
  GetMem( arrOut, NumOut * NumLines * SizeOf(boolean) );
  S.Read(arrOut^, NumOut * NumLines * SizeOf(boolean) );
  GetMem(InMem, NumIn * SizeOf(Integer));
  FillChar(InMem^, NumIn * SizeOf(Integer), $00);
  GetMem(LineMem, NumLines * SizeOf(Boolean));
  FillChar(LineMem^, NumLines * SizeOf(Boolean), false);
  CalcItemRect;
{$ifdef debug}
  appendLog('PLA.Load 2');
{$endif}
end;

procedure tPLA.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(
    NumIn,
    SizeOf(NumIn) + SizeOf(NumOut) +
    SizeOf(NumLines) + SizeOf(Time));
  { PLA-Felder. }
  S.Write(arrIn^, NumIn * NumLines * SizeOf(byte) );
  S.Write(arrOut^, NumOut * NumLines * SizeOf(boolean) );
end;

procedure tPLA.StoreText(var t : Text);
begin
  writeln(t, 'PLA {');
  inherited StoreText(t);
  StoreInt(t, 'numIn', NumIn);
  StoreInt(t, 'numOut', NumOut);
  StoreInt(t, 'numLines', NumLines);
  StoreInt(t, 'time', Time);
(*  { PLA-Felder. }
  S.Write(arrIn^, NumIn * NumLines * SizeOf(byte) );
  S.Write(arrOut^, NumOut * NumLines * SizeOf(boolean) );*)
  writeln(t, '}');
end;

function tPLA.Copy : pItem;
var p : pPLA;
begin
  p := New( pPLA, Init( NumIn, NumOut, NumLines, Time ) );
  Move( X, p^.X, SizeOf(X) + SizeOf(Y) + SizeOf(Direction) );
  Move( arrIn^, p^.arrIn^, NumIn * NumLines * SizeOf(byte) );
  Move( arrOut^, p^.arrOut^, NumOut * NumLines * SizeOf(boolean) );
  p^.CalcItemRect;
  Copy := p;
end;

function tPLA.Name : pChar;
begin
  Name := PLA_Name;
end;

function tPLA.GetRegion_ : hRgn;
var
  R : tRect;
begin
  { Umrandung (Rechteck). }
  with R
  do begin
    GetPos( left, top, ((-10)*NumIn)+6, -4, Direction );
    GetPos( right, bottom, (10*NumOut)+14, ((-10)*NumLines)-6, Direction );
    OffsetRect( R, X, Y );
    GetRegion_ := CreateRectRgn( left, top, right, bottom );
  end;
end;

function tPLA.GetRegionInOut : hRgn;
function CalcInOut(X_, Num : Integer) : hRgn;
var
  X1, Y1,
  X2, Y2,
  i : Integer;
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CreateEmptyRgn;
  for i := 0 to Num-1
  do begin
    GetPos(X1, Y1, X_-4, -4, Direction);
    GetPos(X2, Y2, X_+4, +4, Direction);
    Rgn_ := CreateEllipticRgn(X1, Y1, X2, Y2);
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
    dec( X_, 10 );
  end;
  CalcInOut := Rgn;
end;
var
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CalcInOut( 0, NumIn );
  Rgn_ := CalcInOut( (10*NumOut)+10, NumOut );
  CombineRgn( Rgn, Rgn, Rgn_, RGN_OR );
  DeleteObject( Rgn_ );
  OffsetRgn( Rgn, X, Y );
  GetRegionInOut := Rgn;
end;

procedure tPLA.NotPaint(PaintDC : hDC);
procedure DoCon(Con : pConArray; Num : Integer);
var i : Integer;
begin
  for i := 0 to Num-1 do
    Con^[i].NotPaint(PaintDC);
end;
var
  X1, Y1,
  X2, Y2,
  ylength,
  i : integer;
begin
  DoCon(InCon, NumIn);
  DoCon(OutCon, NumOut);
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  { Umrandung (Rechteck). }
  GetPos( X1, Y1, ((-10)*NumIn)+6, -4, Direction );
  GetPos( X2, Y2, (10*NumOut)+14, ((-10)*NumLines)-6, Direction );
  Rectangle( PaintDC, X1, Y1, X2, Y2 );
  { Eingänge }
  ylength := ((-10)*NumLines)-2;
  for i := 0 to NumIn-1
  do begin
    GetPos(X1, Y1, (-10)*i, 0, Direction);
    GetPos(X2, Y2, (-10)*i, ylength, Direction);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
  end;
  { Ausgänge }
  for i := 2 to NumOut+1
  do begin
    GetPos(X1, Y1, 10*i, 0, Direction);
    GetPos(X2, Y2, 10*i, ylength, Direction);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
  end;
end;

procedure tPLA.Paint(PaintDC : hDC);
var
  X1, Y1,
  X2, Y2,
  ylength,
  i, j, k : Integer;
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  SelectObject(PaintDC, DrawPen);
  { Umrandung (Rechteck). }
  GetPos( X1, Y1, ((-10)*NumIn)+6, -4, Direction );
  GetPos( X2, Y2, (10*NumOut)+14, ((-10)*NumLines)-6, Direction );
  SelectObject( PaintDC, GetStockObject( NULL_BRUSH ) );
  Rectangle( PaintDC, X1, Y1, X2, Y2 );
  { Eingänge }
  {GetPos(X1, Y1, ((-10)*NumIn)+8, -4, Direction);
  GetPos(X2, Y2, 8, ((-10)*NumLines)-4, Direction);
  RoundRect(PaintDC, X1, Y1, X2, Y2, 4, 4);}
  ylength := ((-10)*NumLines)-2;
  for i := 0 to NumIn-1
  do begin
    if ( InMem^[i] <> 0 )
    then SelectObject(PaintDC, OnPen)
    else SelectObject(PaintDC, OffPen);
    GetPos(X1, Y1, (-10)*i, 0, Direction);
    GetPos(X2, Y2, (-10)*i, ylength, Direction);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
    if ( InMem^[i] = 0 )
    then SelectObject(PaintDC, OnPen)
    else SelectObject(PaintDC, OffPen);
    GetPos(X1, Y1, ((-10)*i)+5, -6, Direction);
    GetPos(X2, Y2, ((-10)*i)+5, ylength, Direction);
    MoveTo(PaintDC, X2, Y2);
    LineTo(PaintDC, X1, Y1);
    GetPos(X2, Y2, (-10)*i, -6, Direction);
    LineTo(PaintDC, X2, Y2);
  end;
  SelectObject(PaintDC, DrawPen);
  { Ausgänge }
  {GetPos(X1, Y1, 18, -4, Direction);
  GetPos(X2, Y2, (10*NumOut)+12, ((-10)*NumLines)-4, Direction);
  RoundRect(PaintDC, X1, Y1, X2, Y2, 4, 4);}
  for i := 2 to NumOut+1
  do begin
    GetPos(X1, Y1, 10*i, 0, Direction);
    GetPos(X2, Y2, 10*i, ylength, Direction);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
  end;
  { Verbindungen }
  for i := 1 to NumLines
  do begin
    GetPos(X1, Y1, ((-10)*NumIn)+10, (-10)*i, Direction);
    GetPos(X2, Y2, (10*NumOut)+10, (-10)*i, Direction);
    if LineMem^[i-1]
    then SelectObject(PaintDC, OnPen)
    else SelectObject(PaintDC, OffPen);
    MoveTo(PaintDC, X1, Y1);
    LineTo(PaintDC, X2, Y2);
  end;
  SelectObject(PaintDC, DrawPen);
  { Knoten Eingang. }
  k := 0;
  for i := 0 to NumIn-1 do
    for j := 0 to NumLines-1
    do begin
      if (arrIn^[k] and 1)=1
      then begin
        X1 := -i*10;
        Y1 := (-j*10) - 10;
        GetPos(X1, Y1, X1, Y1, Direction);
        MoveTo(PaintDC, X1-2, Y1-2);
        LineTo(PaintDC, X1+2, Y1+2);
        MoveTo(PaintDC, X1-2, Y1+2);
        LineTo(PaintDC, X1+2, Y1-2);
      end;
      if (arrIn^[k] and 2)=2
      then begin
        X1 := (-i*10) + 5;
        Y1 := (-j*10) - 10;
        GetPos(X1, Y1, X1, Y1, Direction);
        MoveTo(PaintDC, X1-2, Y1-2);
        LineTo(PaintDC, X1+2, Y1+2);
        MoveTo(PaintDC, X1-2, Y1+2);
        LineTo(PaintDC, X1+2, Y1-2);
      end;
      inc(k);
    end;
  { Knoten Ausgang. }
  k := 0;
  for i := 0 to NumOut-1 do
    for j := 0 to NumLines-1
    do begin
      if arrOut^[k]
      then begin
        X1 := (i*10) + 20;
        Y1 := (-j*10) - 10;
        GetPos(X1, Y1, X1, Y1, Direction);
        MoveTo(PaintDC, X1-2, Y1-2);
        LineTo(PaintDC, X1+2, Y1+2);
        MoveTo(PaintDC, X1-2, Y1+2);
        LineTo(PaintDC, X1+2, Y1-2);
      end;
      inc(k);
    end;
end;

procedure tPLA.PaintInOut(PaintDC : hDC);
var
  B : tPoint;
  i : Integer;
  Font : hFont;
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  Font := SetInOutFont(PaintDC, Direction);
  for i := 1 to NumIn do
    DrawInOut(PaintDC, (-10*i)+10, 0, Direction, i);
  for i := 1 to NumOut do
    DrawInOut(PaintDC, (10*i)+10, 0, Direction, -i);
  DeleteObject(Font);
end;

procedure tPLA.GetInitImpulse(Impulses : pCollection);
var
  i : Integer;
  PaintCol : pCollection;
begin
  FillChar(InMem^, NumIn * SizeOf(Integer), $00);
  New( PaintCol, Init( 2, 1 ) );
  SendImpulse( 1, 0, PaintCol, Impulses );
  PaintCol^.DeleteAll;
  Dispose( PaintCol, Done );
(*  for i := 0 to NumOut-1 do
    Impulses^.Insert(
      New(pImpulse, Init(
        OutCon^[i].Con, OutCon^[i].Num, 0, 0)));*)
end;

procedure tPLA.SendImpulse(
  NumIn_, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
var
  i, j,
  b : Integer;
  m : Boolean;
begin
  if NumIn_ < 0
  then {Tilt(PaintDC, NumIn_)}
  else begin
    InMem^[NumIn_-1] := Impulse; { Impuls speichern. }
    { Zeilen berechnen. }
    for i := 0 to NumLines-1
    do begin
      m := true;
      for j := 0 to NumIn-1
      do begin
        b := arrIn^[ i + (j*NumLines) ];
        if ( (b and 1) = 1 )
        then m := m and (InMem^[j] <> 0);
        if ( (b and 2) = 2 )
        then m := m and (InMem^[j] = 0);
      end;
      LineMem^[i] := m;
    end;
    { Ausgabe berechnen. }
    for i := 0 to NumOut-1
    do begin
      m := false;
      for j := 0 to NumLines-1 do
        m := m or ( arrOut^[ j + (i*NumLines) ] and LineMem^[j] );
      Impulses^.Insert(
        New(pImpulse, Init(OutCon^[i].Con, OutCon^[i].Num, Integer(m), Time)));
    end;
    if PaintCol^.IndexOf(@Self)<0
    then PaintCol^.Insert(@Self);
  end;
end;

type
  pPLADlg = ^tPLADlg;
  tPLADlg = object (tDialogSB)
    p : pPLA;
    constructor Init(xParent : pWindowsObject; p_ : pPLA);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tPLADlg.Init(xParent : pWindowsObject; p_ : pPLA);
begin
  inherited Init(xParent, 'PLADLG');
  p := p_;
end;

procedure tPLADlg.SetupWindow;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), true);
    SetDlgItemInt(hWindow, 101, Word(Y), true);
    SetDlgItemInt(hWindow, 102, Word(NumIn), false);
    SetDlgItemInt(hWindow, 103, Word(NumOut), false);
    SetDlgItemInt(hWindow, 104, Word(NumLines), false);
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
    SetDlgItemInt(hWindow, 130, Time, False);
  end;
end;

procedure tPLADlg.OK(var Msg : tMessage);
var
  i : Integer;
  o, b : Boolean;
  translated : Bool;
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
    Time := GetDlgItemInt(hWindow, 130, translated, False);
    if Time <= 0 then Time := 1;
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tPLA.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pPLADlg, Init(Window, @Self)));
end;

function tPLA.NumInCon : Integer;
begin
  NumInCon := NumIn;
end;

function tPLA.NumOutCon : Integer;
begin
  NumOutCon := NumOut;
end;

function tPLA.GetInOutNr(A : tPoint) : Integer;
var
  B : tPoint;
  i : Integer;
begin
  GetInOutNr := 0;
  for i := 1 to NumIn
  do begin
    B := GetInOutPos(i);
    if EqualPt( A, B ) then GetInOutNr := i;
  end;
  for i := 1 to NumOut
  do begin
    B := GetInOutPos(-i);
    if EqualPt( A, B ) then GetInOutNr := -i;
  end;
end;

function tPLA.GetInOutPos(Num : Integer) : tPoint;
var
  A : tPoint;
begin
  with A
  do begin
    Y := 0;
    X := (-10*Num)+10;
    GetPos(X, Y, X, Y, Direction);
  end;
  inc(A.X, X);
  inc(A.Y, Y);
  GetInOutPos := A;
end;

function tPLA.GetState(A : tPoint; b : Integer) : Integer;
begin
  if (b and lm_Test) = lm_Test
  then GetState := inherited GetState( A, b )
  else
    case (b and lm_First) of
      lm_MouseMove,
      lm_LButton :
          if GetMatrixNr(A) = 0
          then GetState := inherited GetState( A, b )
          else GetState := ls_PLAMatrix;
      else
        GetState := inherited GetState( A, b );
    end;
end;

function tPLA.GetMatrixNr( A : tPoint ) : Integer;
var
  i : Integer;
begin
  dec(A.X, X);
  dec(A.Y, Y);
  with A
  do begin
    GetPos(X, Y, X, Y, -Direction);
    if ( ( ((-Y)+2) mod 10 ) <= 4 ) and
       ( Y < 0 ) and ( Y > -( (10*NumLines) + 15 ) )
    then begin
      if ( X < 7 ) and ( X > -( NumIn * 10 ) )
      then begin
        i :=
            ( (((-Y)+2) div 10) * 2 )
          + ( ((-X+7) div 10) * 2 * NumLines ) - 1;
        if ((-X+7) mod 10) <= 5
        then i := i + 1;
        GetMatrixNr := i;
      end
      else
        if ( X > 15 ) and ( X < (NumOut*10)+25 ) and
           ( ( (X+2) mod 10 ) <= 4 )
        then GetMatrixNr :=
               - ( (((-Y)+2) div 10) )
               - ( ((X-18) div 10) * NumLines )
        else GetMatrixNr := 0;
    end
    else GetMatrixNr := 0;
  end;
end;

procedure tPLA.ToggleMatrix( A : tPoint );
var
  i :Integer;
begin
  i := GetMatrixNr(A);
  if i > 0
  then begin
    dec(i);
    arrIn^[i div 2] := arrIn^[i div 2] xor ( (i mod 2) + 1)
  end
  else
    if i < 0
    then begin
      i := (-i) - 1;
      arrOut^[i] := not arrOut^[i];
    end;
end;

function tPLA.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
begin
  GetMenu := GetSubMenu( ItemMenu, 6 );
end;

procedure tPLA.DelInNodes;
begin
  FillChar(arrIn^, NumIn * NumLines * SizeOf(byte), 0 );
end;

procedure tPLA.DelOutNodes;
begin
  FillChar(arrOut^, NumOut * NumLines * SizeOf(boolean), 0 );
end;

{ ------ rPLA ----------------------------------------------------------- }

const
  rPLA : TStreamRec = (
     ObjType : riPLA;
     VmtLink : Ofs(TypeOf(tPLA)^);
     Load  : @tPLA.Load;
     Store : @tPLA.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rPLA);
  PLA_Name := StrNew(LoadString0(31));
end.
