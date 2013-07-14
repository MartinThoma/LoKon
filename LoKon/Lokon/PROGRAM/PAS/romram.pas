unit ROMRAM;
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
  pROM = ^tROM;
  tROM = object (tInOutItem)
    { Anzahl der Adress- und Daten-Bits. }
    NumAdr, NumData : Byte;
    Enable, { True - Enable-Eingang vorhanden. }
    IsRAM : Boolean; { False - ROM, True - RAM. }
    Time : Integer; { Zugriffszeit. }
    Mem : pByteArray; { Speicher. }
    InOutMem : pIntegerArray;
    constructor Init(
      xNumAdr, xNumData : Byte; xEnable, xIsRAM : Boolean; xTime : Integer);
    destructor Done; virtual;
    function GetMemSize : Longint;
    constructor Load(var S : tStream);
    function LoadInOut(var S : tStream) : Boolean; virtual;
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    procedure StoreInOut(var S : tStream); virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    procedure Reset; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetRegionInOut : hRgn; virtual;
    function GetRegionCon : hRgn; virtual;
    function GetControl : pElement;
    function GetROM : pElement;
    function NumAdr_ : Integer;
    function NumData_ : Integer;
    function NumInCon : Integer; virtual;
    function NumOutCon : Integer; virtual;
    procedure SetCon(Num : Integer; p : pItem; Num_ : Integer); virtual;
    function DelCon(Num : Integer) : Integer; virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : tPoint; virtual;
    function GetInOutCon(Num : Integer) : pCon; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure PaintInOut(PaintDC : hDC); virtual;
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
  end;

implementation

var
  ROMControl,
  EnROMControl,
  RAMControl,
  EnRAMControl : array [0..4] of pElement;
  ROM, RAM : array [1..4] of pElement;

{ ------ tROM ----------------------------------------------------------- }

constructor tROM.Init(
  xNumAdr, xNumData : Byte; xEnable, xIsRAM : Boolean; xTime : Integer);
begin
  inherited Init;
  NumAdr := xNumAdr;
  NumData := xNumData;
  Enable := xEnable;
  IsRAM := xIsRAM;
  Time := xTime;
  GetMem(InCon, NumInCon * SizeOf(tCon));
  FillChar(InCon^, NumInCon * SizeOf(tCon), $00);
  GetMem(OutCon, NumOutCon * SizeOf(tCon));
  FillChar(OutCon^, NumOutCon * SizeOf(tCon), $00);
  GetMem(Mem, GetMemSize);
  FillChar(Mem^, GetMemSize, $00);
  GetMem(InOutMem, NumInCon * SizeOf(Integer));
  FillChar(InOutMem^, NumInCon * SizeOf(Integer), $00);
end;

destructor tROM.Done;
var i : Integer;
begin
  for i := 0 to NumInCon-1 do
    InCon^[i].DelCon;
  for i := 0 to NumOutCon-1 do
    OutCon^[i].DelCon;
  FreeMem(InCon, NumInCon * SizeOf(tCon));
  FreeMem(OutCon, NumOutCon * SizeOf(tCon));
  FreeMem(Mem, GetMemSize);
  FreeMem(InOutMem, NumInCon * SizeOf(Integer));
end;

function tROM.GetMemSize : Longint;
begin
  GetMemSize := Word(1) shl NumAdr_;
end;

constructor tROM.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('ROM.Load 1');
{$endif}
  inherited Load(S);
  S.Read(
    NumAdr,
    SizeOf(NumAdr) + SizeOf(NumData) +
    SizeOf(Enable) + SizeOf(IsRAM));
  Time := S.ReadSmallInt;
  GetMem(Mem, GetMemSize);
  S.Read(Mem^, GetMemSize);
  GetMem(InCon, NumInCon * SizeOf(tCon));
  FillChar(InCon^, NumInCon * SizeOf(tCon), $00);
  GetMem(OutCon, NumOutCon * SizeOf(tCon));
  FillChar(OutCon^, NumOutCon * SizeOf(tCon), $00);
  GetMem(InOutMem, NumInCon * SizeOf(Integer));
  FillChar(InOutMem^, NumInCon * SizeOf(integer), $00);
  CalcItemRect;
{$ifdef debug}
  appendLog('ROM.Load 2');
{$endif}
end;

function tROM.LoadInOut(var S : tStream) : Boolean;
begin
  InOutMem := ReadInteger16Array(S, NumInCon);
  LoadInOut := True;
end;

procedure tROM.Store(var S : tStream);
begin
  inherited Store(S);
  S.Write(
    NumAdr,
    SizeOf(NumAdr) + SizeOf(NumData) +
    SizeOf(Enable) + SizeOf(IsRAM) +
    SizeOf(Time));
  S.Write(Mem^, GetMemSize);
end;

procedure tROM.StoreText(var t : Text);
begin
  inherited StoreText(t);
  StoreInt(t, 'numAdr', NumAdr);
  StoreInt(t, 'numData', NumData);
  StoreBool(t, 'enable', Enable);
  StoreBool(t, 'isRAM', IsRAM);
  StoreInt(t, 'time', time);
(*  S.Write(Mem^, GetMemSize);*)
end;

procedure tROM.StoreInOut(var S : tStream);
begin
  S.Write(InOutMem^, NumInCon * SizeOf(Integer));
end;

function tROM.Copy : pItem;
var p : pROM;
begin
  p := New(pROM, Init(NumAdr, NumData, Enable, IsRAM, Time));
  Move(X, p^.X, SizeOf(X) + SizeOf(Y) + SizeOf(Direction));
  Move(Mem^, p^.Mem^, GetMemSize);
  p^.CalcItemRect;
  Copy := p;
end;

type
  tROMNameRec = record
    Adr, Data : Integer;
  end;

function tROM.Name : pChar;
var r : tROMNameRec;
begin
  with r
  do begin
    Adr := Integer(1) shl NumAdr_;
    Data := Integer(1) shl NumData_;
  end;
  if IsRAM
  then wvsprintf(@String0, LoadString1(1073), r)
  else wvsprintf(@String0, LoadString1(1072), r);
  Name := @String0;
end;

procedure tROM.Reset;
begin
  FillChar(InOutMem^, NumInCon * SizeOf(Integer), $00);
end;

function tROM.GetRegion_ : hRgn;
var Rgn, Rgn_ : hRgn;
begin
  Rgn := GetControl^.CalcRgn(Direction);
  Rgn_ := GetROM^.CalcRgn(Direction);
  CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
  DeleteObject(Rgn_);
  OffsetRgn(Rgn, X, Y);
  GetRegion_ := Rgn;
end;

function tROM.GetRegionInOut : hRgn;
var Rgn, Rgn_ : hRgn;
begin
  Rgn := GetControl^.CalcInOutRgn(Direction);
  Rgn_ := GetROM^.CalcInOutRgn(Direction);
  CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
  DeleteObject(Rgn_);
  OffsetRgn(Rgn, X, Y);
  GetRegionInOut := Rgn;
end;

function tROM.GetRegionCon : hRgn;
var
  i : Integer;
  Rgn, Rgn_ : hRgn;
begin
  Rgn := CreateEmptyRgn;
  for i := 0 to NumInCon-1
  do begin
    Rgn_ := InCon^[i].GetRegionCon;
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
  end;
  for i := 0 to NumOutCon-1
  do begin
    Rgn_ := OutCon^[i].GetRegionCon;
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
  end;
  GetRegionCon := Rgn;
end;

function tROM.NumAdr_ : Integer;
begin
  if NumAdr = 0
  then NumAdr_ := 3
  else NumAdr_ := NumAdr shl 1;
end;

function tROM.NumData_ : Integer;
begin
  NumData_ := NumData shl 1;
end;

function tROM.NumInCon : Integer;
var i : Integer;
begin
  i := NumAdr_;
  if Enable then inc(i);
  if IsRAM then inc(i, NumData_+1);
  NumInCon := i;
end;

function tROM.NumOutCon : Integer;
begin
  NumOutCon := NumData_;
end;

procedure tROM.SetCon(Num : Integer; p : pItem; Num_ : Integer);
begin
  if Num < 0
  then OutCon^[(-Num)-1].Init(p, Num_)
  else begin
    if Num >= $0100
    then begin
      Num := (Num-$0100) + NumAdr_;
      if IsRAM then inc(Num);
      if Enable then inc(Num);
    end;
    InCon^[Num-1].Init(p, Num_);
  end;
end;

function tROM.DelCon(Num : Integer) : Integer;
begin
  if Num < 0
  then OutCon^[(-Num)-1].Done
  else begin
    if Num >= $0100
    then begin
      Num := (Num-$0100) + NumAdr_;
      if IsRAM then inc(Num);
      if Enable then inc(Num);
    end;
    InCon^[Num-1].Done;
  end;
  DelCon := Num;
end;

function tROM.GetControl : pElement;
begin
  if IsRAM
  then begin
    if Enable
    then GetControl := EnRAMControl[NumAdr]
    else GetControl := RAMControl[NumAdr];
  end
  else begin
    if Enable
    then GetControl := EnROMControl[NumAdr]
    else GetControl := ROMControl[NumAdr];
  end;
end;

function tROM.GetROM : pElement;
begin
  if IsRAM
  then GetROM := RAM[NumData]
  else GetROM := ROM[NumData];
end;

function tROM.GetInOutNr(A : tPoint) : Integer;
var i : Integer;
begin
  dec(A.X, X);
  dec(A.Y, Y);
  with A do
    GetPos(X, Y, X, Y, -Direction);
  i := GetControl^.GetInOutNr(A);
  if i = 0
  then begin
    i := GetROM^.GetInOutNr(A);
    if i > 0 then inc(i, $0100);
  end;
  GetInOutNr := i;
end;

function tROM.GetInOutPos(Num : Integer) : tPoint;
var
  A : tPoint;
begin
  if Num < 0
  then A := GetROM^.PosInOut(Num)
  else
    if Num >= $0100
    then A := GetROM^.PosInOut(Num-$0100)
    else A := GetControl^.PosInOut(Num);
  with A do GetPos(X, Y, X, Y, Direction);
  inc(A.X, X);
  inc(A.Y, Y);
  GetInOutPos := A;
end;

function tROM.GetInOutCon(Num : Integer) : pCon;
begin
  if Num=0
  then begin
    GetInOutCon := nil
  end
  else if Num < 0
  then begin
    if (-Num) <= NumOutCon
    then GetInOutCon := @OutCon^[(-Num)-1]
    else GetInOutCon := nil;
  end
  else begin
    if Num >= $0100
    then begin
      Num := (Num-$0100) + NumAdr_;
      if IsRAM then inc(Num);
      if Enable then inc(Num);
    end;
    if Num <= NumInCon
    then GetInOutCon := @InCon^[Num-1]
    else GetInOutCon := nil;
  end;
end;

procedure tROM.NotPaint(PaintDC : hDC);
procedure DoCon(Con : pConArray; Num : Integer);
var
  i : Integer;
begin
  for i := 0 to Num-1 do
    Con^[i].NotPaint(PaintDC);
end;
begin
  DoCon(InCon, NumInCon);
  DoCon(OutCon, NumOutCon);
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  GetROM^.NotPaint(PaintDC, Direction);
  GetControl^.NotPaint(PaintDC, Direction);
end;

procedure tROM.Paint(PaintDC : hDC);
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  GetROM^.Paint(PaintDC, Direction, nil);
  GetControl^.Paint(PaintDC, Direction, nil);
end;

procedure tROM.PaintInOut(PaintDC : hDC);
begin
  SetWindowOrgEx(PaintDC, -X, -Y, nil);
  GetROM^.PaintInOut(PaintDC, Direction);
  GetControl^.PaintInOut(PaintDC, Direction);
end;

procedure tROM.GetInitImpulse(Impulses : pCollection);
var
  i, k : Integer;
begin
  FillChar(InOutMem^, NumInCon * SizeOf(Integer), $00);
  k := Mem^[0];
  for i := 0 to NumData_-1 do
    Impulses^.Insert(
      New(pImpulse, Init(
        OutCon^[i].Con, OutCon^[i].Num, k and (Integer(1) shl i), 0)));
end;

procedure tROM.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
var
  i, ad : Integer;
  k : Byte;
begin
  if NumIn < 0
  then (*Tilt(PaintDC, NumIn)*)
  else begin
    if NumIn >= $0100
    then NumIn := (NumIn-$0100) + NumAdr_ + Ord(IsRAM) + Ord(Enable);
    InOutMem^[NumIn-1] := Impulse;
    if not(Enable) or (InOutMem^[NumAdr_+Ord(IsRAM)] <> 0)
    then begin
      ad := 0;
      for i := NumAdr_-1 downto 0
      do begin
        ad := ad shl 1;
        if InOutMem^[i] <> 0 then inc(ad);
      end;
      if IsRAM and (InOutMem^[NumAdr_] <> 0)
      then begin
        k := 0;
        for i := NumData_-1 downto 0
        do begin
          k := k shl 1;
          if InOutMem^[NumAdr_+Ord(Enable)+i+1] <> 0 then inc(k);
        end;
        Mem^[ad] := k;
      end;
      { Impulse senden. }
      for i := 0 to NumData_-1
      do begin
        if (Mem^[ad] and (Byte(1) shl i)) <> 0
        then k := 1
        else k := 0;
        Impulses^.Insert(
          New(pImpulse, Init(OutCon^[i].Con, OutCon^[i].Num, k, Time)));
      end;
    end;
  end;
end;

const
  id_List     = 100;
  id_Descript = 101;
  id_Zero     = 105;
  id_One      = 106;

type
  pMemoryDlg = ^tMemoryDlg;
  tMemoryDlg = object (tDialogEx)
    ROM : pROM;
    p : pByteArray;
    constructor Init(xParent : pWindowsObject; xROM : pROM);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure SetupDlg;
    procedure wmCommand(var Msg : tMessage);
      virtual wm_First + wm_Command;
    procedure idZero(var Msg : tMessage);
      virtual id_First + id_Zero;
    procedure idOne(var Msg : tMessage);
      virtual id_First + id_One;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tMemoryDlg.Init(xParent : pWindowsObject; xROM : pROM);
begin
  inherited Init(xParent, 'MEMORYDLG');
  ROM := xROM;
  with ROM^
  do begin
    GetMem(p, GetMemSize);
    Move(Mem^, p^, GetMemSize);
  end;
end;

destructor tMemoryDlg.Done;
begin
  FreeMem(p, ROM^.GetMemSize);
  inherited Done;
end;

procedure tMemoryDlg.SetupWindow;
var i : Integer;
begin
  inherited SetupWindow;
  { Schriftart mit fester Breite für die Tabelle setzen. }
  SendDlgItemMsg(id_List, wm_SetFont,
    GetStockObject(System_Fixed_Font), 0);
  SendDlgItemMsg(id_Descript, wm_SetFont,
    GetStockObject(System_Fixed_Font), 0);
  { Beschriftung. }
  String0[0] := #0;
  StrCopy(@String1, '76543210');
  with Rom^
  do begin
    StrCopy(@String0, ' ');
    StrCat(@String0, @(String1[8-NumAdr_]));
    StrCat(@String0, ' :');
    StrCat(@String0, @(String1[8-NumData_]));
    SetDlgItemText(hWindow, id_Descript, @String0);
    { Adressbits/Datenbits }
    for i := 0 to NumAdr_-1 do
      EnableWindow(GetItemHandle(200+i), True);
    for i := 0 to NumData_-1 do
      EnableWindow(GetItemHandle(300+i), True);
  end;
  SetupDlg;
end;

procedure tMemoryDlg.SetupDlg;
var
  i, j : Integer;
begin
  SendDlgItemMsg(id_List, lb_ResetContent, 0, 0);
  with ROM^
  do begin
    { Speicher }
    String0[0] := '[';
    String0[NumAdr_+1] := ']';
    String0[NumAdr_+2] := ':';
    String0[NumAdr_+NumData_+3] := #0;
    for i := 0 to ROM^.GetMemSize-1
    do begin
      for j := 0 to NumAdr_-1 do
        if (i and (1 shl j)) <> 0
        then String0[NumAdr_-j] := '1'
        else String0[NumAdr_-j] := '0';
      for j := 0 to NumData_-1 do
        if (p^[i] and (Byte(1) shl j)) <> 0
        then String0[NumAdr_+NumData_-j+2] := '1'
        else String0[NumAdr_+NumData_-j+2] := '0';
      SendDlgItemMsg(id_List, lb_AddString, 0, Longint(@String0));
    end;
  end;
  { Auswahl. }
  if SendDlgItemMsg(id_List, lb_GetCurSel, 0, 0) < 0
  then SendDlgItemMsg(id_List, lb_SetCurSel, 0, 0);
  SendMessage(hWindow, wm_Command, id_List, lbn_SelChange shl 16);
end;

procedure tMemoryDlg.wmCommand(var Msg : tMessage);
procedure lbnSelChange;
var
  i, k, m : Integer;
begin
  k := SendDlgItemMsg(id_List, lb_GetCurSel, 0, 0);
  with ROM^
  do begin
    for i := 0 to NumAdr_-1 do
      CheckDlgButton(hWindow, 200+i, k and (Integer(1) shl i));
    for i := 0 to NumData_-1 do
      CheckDlgButton(hWindow, 300+i, p^[k] and (Byte(1) shl i));
  end;
end;
procedure idData;
var
  i, j : Integer;
begin
  j := Msg.wParam - 300;
  i := SendDlgItemMsg(id_List, lb_GetCurSel, 0, 0);
  p^[i] := p^[i] xor (Byte(1) shl j);
  SendDlgItemMsg(id_List, lb_GetText, i, Longint(@String0));
  with ROM^ do
    if (p^[i] and (Byte(1) shl j)) <> 0
    then String0[NumAdr_+NumData_-j+2] := '1'
    else String0[NumAdr_+NumData_-j+2] := '0';
  SendDlgItemMsg(id_List, lb_DeleteString, i, 0);
  SendDlgItemMsg(id_List, lb_InsertString, i, Longint(@String0));
  SendDlgItemMsg(id_List, lb_SetCurSel, i, 0);
end;
procedure idAdr;
begin
  SendDlgItemMsg(id_List, lb_SetCurSel,
    SendDlgItemMsg(id_List, lb_GetCurSel, 0, 0) xor
    (Word(1) shl (Msg.wParam-200)), 0);
  lbnSelChange;
end;
begin
  case Msg.wParam of
    id_List :
      if Msg.lParamHi = lbn_SelChange
      then lbnSelChange;
    200..207 : idAdr;
    300..307 : idData;
    else inherited wmCommand(Msg);
  end;
end;

procedure tMemoryDlg.idZero(var Msg : tMessage);
begin
  FillChar(p^, ROM^.GetMemSize, $00);
  SetupDlg;
end;

procedure tMemoryDlg.idOne(var Msg : tMessage);
begin
  FillChar(p^, ROM^.GetMemSize, $ff);
  SetupDlg;
end;

procedure tMemoryDlg.OK(var Msg : tMessage);
begin
  Move(p^, ROM^.Mem^, ROM^.GetMemSize);
  EndDlg(id_OK);
end;

type
  pROMDlg = ^tROMDlg;
  tROMDlg = object (tDialogSB)
    p : pROM;
    constructor Init(xParent : pWindowsObject; xp : pROM);
    procedure SetupWindow; virtual;
    procedure idMemory(var Msg : tMessage);
      virtual id_First + 108;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tROMDlg.Init(xParent : pWindowsObject; xp : pROM);
begin
  inherited Init(xParent, 'ROMDLG');
  p := xp;
end;

procedure tROMDlg.SetupWindow;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    SetDlgItemInt(hWindow, 102, Word(NumAdr_), False);
    SetDlgItemInt(hWindow, 103, Word(NumData_), False);
    CheckDlgButton(hWindow, 104, Word(Enable));
    if IsRAM
    then CheckDlgButton(hWindow, 106, Word(True))
    else CheckDlgButton(hWindow, 105, Word(True));
    CheckDlgButton(hWindow, 110+(Direction and $03), Word(True));
    SetDlgItemInt(hWindow, 130, Time, False);
  end;
end;

procedure tROMDlg.idMemory(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pMemoryDlg, Init(@Self, p)));
end;

procedure tROMDlg.OK(var Msg : tMessage);
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

procedure tROM.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pROMDlg, Init(Window, @Self)));
end;

{ ------ LoadROMRAM ----------------------------------------------------- }

procedure LoadROMRAM;
var
  S : tDosStream;
  Collection : pCollection;
  i : Integer;
begin
  Collection := New(pCollection, Init(20, 10));
  S.Init('INTERN.ELE', stOpenRead);
  Collection^.Load(S);
  S.Done;
  with Collection^
  do begin
    for i := 0 to 4
    do begin
      ROMControl[i] := pElement(At(i+5));
      EnROMControl[i] := pElement(At(i+10));
      RAMControl[i] := pElement(At(i+15));
      EnRAMControl[i] := pElement(At(i+20));
    end;
    for i := 1 to 4
    do begin
      ROM[i] := pElement(At(i+24));
      RAM[i] := pElement(At(i+28));
    end;
    DeleteAll;
  end;
  Dispose(Collection, Done);
end;

{ ------ rROM ----------------------------------------------------------- }

const
  rROM : TStreamRec = (
     ObjType : riROM;
     VmtLink : Ofs(TypeOf(tROM)^);
     Load  : @tROM.Load;
     Store : @tROM.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  LoadROMRAM;
  RegisterType(rROM);
end.
