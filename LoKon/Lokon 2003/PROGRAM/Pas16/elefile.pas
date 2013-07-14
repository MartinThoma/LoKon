unit EleFile;
{$I define.inc}

interface

uses
  Objects,
  Strings,
  WinTypes, WinProcs,
  OWindows,
  OWinEx,
  LK_Const,
  Item;

type
  pLay = ^tLay;
  tLay = object
    EleFiles,
    Layout : pCollection;
    procedure Init;
    procedure Done;
    procedure Clear;
    procedure Copy( xLay : pLay );
    procedure Paint(PaintDC : hDC; R : tRect);
    procedure Paint_(PaintDC : hDC; R : tRect);
    procedure PaintInOut(PaintDC : hDC);
    function GetElement(i : Longint) : Pointer;
    function GetID(Element : Pointer) : Longint;
    function Load(var S : tStream) : Boolean;
    procedure Store(var S : tStream);
    procedure StoreText(var t : Text);
    procedure LoadInOut(var S : tStream);
    procedure StoreInOut(var S : tStream);
    procedure DelUndo;
  end;

var
  ActLay : pLay;

function SetActLay(xActLay : pLay) : pLay;

type
  pEleFile = ^tEleFile;
  tEleFile = object (tObject)
    ElementList : pCollection;
    Name,
    FileName : pChar;
    Count : Integer;
    constructor Init(xName, xFileName : pChar);
    destructor Done; virtual;
    procedure WriteIni(IniFile : pChar; i:Integer);
    procedure StoreName(var S : tStream);
    function Copy : pEleFile;
    procedure ChangeName(s : pChar);
    procedure ChangeFile(s : pChar);
    function LoadEleFile : Boolean;
    procedure DecCount;
  end;

implementation

{ ------ tLay ----------------------------------------------------------- }

procedure tLay.Init;
begin
  EleFiles := New(pCollection, Init(5, 3));
  Layout := New(pCollection, Init(50, 50));
end;

procedure tLay.Done;
procedure DoDecCount(p : pEleFile); far;
begin
  p^.DecCount;
end;
begin
  Dispose(Layout, Done);
  EleFiles^.ForEach(@DoDecCount);
  EleFiles^.DeleteAll;
  Dispose(EleFiles, Done);
end;

procedure tLay.DelUndo;
procedure DoDecCount(p : pEleFile); far;
begin
  p^.DecCount;
end;
begin
  Layout^.FreeAll;
  EleFiles^.ForEach(@DoDecCount);
  EleFiles^.DeleteAll;
end;

procedure tLay.Clear;
procedure DoDecCount(p : pEleFile); far;
begin
  p^.DecCount;
end;
begin
  { Element-Dateien freigeben, }
  EleFiles^.ForEach(@DoDecCount);
  { aber die Collections NICHT löschen ! }
  EleFiles := New(pCollection, Init(1, 1));
  Layout := New(pCollection, Init(1, 1));
end;

procedure tLay.Copy( xLay : pLay );
begin
  { Vorhandene Collections löschen. }
  Dispose(Layout, Done);
  Dispose(EleFiles, Done);
  { Die Zeiger werden umgebogen. }
  EleFiles := xLay^.EleFiles;
  Layout := xLay^.Layout;
end;

procedure tLay.Paint(PaintDC : hDC; R : tRect);
procedure DoPaint(p : pItem); far;
begin
  if p^.Rect_in_Item(R)
  then p^.Paint(PaintDC);
end;
begin
  Layout^.ForEach(@DoPaint);
end;

procedure tLay.Paint_(PaintDC : hDC; R : tRect);
var Rgn : hRgn;
procedure DoPaint(p : pItem); far;
begin
  if p^.Rect_in_Item(R)
  then p^.Paint_(PaintDC)
end;
begin
  Layout^.ForEach(@DoPaint)
end;

procedure tLay.PaintInOut(PaintDC : hDC);
procedure DoPaintInOut(p : pItem); far;
begin
  p^.PaintInOut(PaintDC);
end;
begin
  Layout^.ForEach(@DoPaintInOut);
end;

type
  pChapEle = ^tChapEle;
  tChapEle = object (tObject)
    Nr : Integer;
  end;

function tLay.GetElement(i : Longint) : Pointer;
function DoIndex(p : pChapEle) : Boolean; far;
begin
  DoIndex := p^.Nr = LoWord(i);
end;
begin
  GetElement :=
    pEleFile(EleFiles^.At(HiWord(i)))^.ElementList^.FirstThat(@DoIndex);
end;

function tLay.GetID(Element : Pointer) : Longint;
{ Ermittelt Position des Elements in EleFiles:
    Lo  -  Position in EleWin
    Hi  -  Position von EleWin in EleFiles. }
var A : tPoint;
function DoIsFile(EleFile : pEleFile) : Boolean; far;
var i : Integer;
begin
  i := EleFile^.ElementList^.IndexOf(Element);
  if i >= 0
  then begin
    DoIsFile := True;
    A.X := pChapEle(EleFile^.ElementList^.At(i))^.Nr;
  end
  else
    DoIsFile := False;
  inc(A.Y);
end;
begin
  A.Y := -1;
  EleFiles^.FirstThat(@DoIsFile);
  GetID := Longint(A);
end;

function tLay.Load(var S : tStream) : Boolean;
var
  ActLay_ : pLay;
  EleFileName : pChar;
  p : pEleFile;
  i : Integer;
  Error : Boolean;
  s_ : pChar;
begin
{$ifdef debug}
  appendLog('tLay.Load 1');
{$endif}
  Error := False;
  S.Read(i, SizeOf(Integer));
  while (i > 0) and (not Error)
  do begin
    EleFileName := S.StrRead;
    p := pEleFile(SendMessage(
                    hMainWin, ms_GetEleFile, 2, Longint(EleFileName)));
    if p = nil
    then begin
      GetMem(s_, StrLen(LoadString0(10)) + StrLen(EleFileName) - 1 {+1-2});
      wvsprintf(s_, @String0, EleFileName);
      MessageBeep(mb_OK);
      MessageBox(
        hMainWin, s_, nil, mb_IconStop + mb_OK);
      StrDispose(s_);
      Error := True;
    end
    else begin
      if p^.LoadEleFile
      then begin
        EleFiles^.Insert(p);
      end
      else Error := True;
    end;
    dec(i);
  end;
  if not Error
  then begin
    ActLay_ := SetActLay(@Self);
    Layout^.Load(S);
    SetActLay(ActLay_);
    LoadInOut(S);
    Load := True;
  end
  else Load := False;
{$ifdef debug}
  appendLog('tLay.Load 2');
{$endif}
end;

procedure tLay.Store(var S : tStream);
procedure DoStoreName(p : pEleFile); far;
begin
  p^.StoreName(S);
end;
var
  ActLay_ : pLay;
begin
  S.Write(EleFiles^.Count, SizeOf(Integer));
  EleFiles^.ForEach(@DoStoreName);
  ActLay_ := SetActLay(@Self);
  Layout^.Store(S);
  StoreInOut(S);
  SetActLay(ActLay_);
end;

procedure tLay.StoreText(var t : Text);
(*procedure DoStoreName(p : pEleFile); far;
begin
  p^.StoreName(S);
end;*)
procedure DoStoreText(p : pItem); far;
begin
  writeln(t, StrPas(p^.Name)+' {');
  p^.StoreText(t);
  writeln(t, '}');
  writeln(t);
end;
var
  ActLay_ : pLay;
begin
(*  S.Write(EleFiles^.Count, SizeOf(Integer));
  EleFiles^.ForEach(@DoStoreName);*)
  ActLay_ := SetActLay(@Self);
  Layout^.ForEach(@DoStoreText);
(*  StoreInOut(S);*)
  SetActLay(ActLay_);
end;

procedure tLay.LoadInOut(var S : tStream);
var
  s1, s2 : pChar;
procedure DoLoadInOut(p : pItem); far;
begin
  if not p^.LoadInOut(S)
  then begin
    MessageBeep(mb_OK);
    s2 := p^.Name;
    GetMem(s1, StrLen(LoadString0(65)) + StrLen(s2) - 1 {+1-2});
    wvsprintf(s1, @String0, s2);
    MessageBox(hMainWin, s1, nil, mb_IconInformation or mb_OK);
    StrDispose(s1);
  end;
end;
var
  ActLay_ : pLay;
begin
{$ifdef debug}
  appendLog('tLay.LoadInOut 1');
{$endif}
  ActLay_ := SetActLay(@Self);
  Layout^.ForEach(@DoLoadInOut);
  SetActLay(ActLay_);
{$ifdef debug}
  appendLog('tLay.LoadInOut 2');
{$endif}
end;

procedure tLay.StoreInOut(var S : tStream);
procedure DoStoreInOut(p : pItem); far;
begin
  p^.StoreInOut(S);
end;
var
  ActLay_ : pLay;
begin
  ActLay_ := SetActLay(@Self);
  Layout^.ForEach(@DoStoreInOut);
  SetActLay(ActLay_);
end;

{ ------ SetActLay ------------------------------------------------------ }

function SetActLay(xActLay : pLay) : pLay;
begin
  SetActLay := ActLay;
  ActLay := xActLay;
end;

{ ------ tEleFile ------------------------------------------------------- }

constructor tEleFile.Init(xName, xFileName : pChar);
begin
  Name := StrNew(xName);
  FileName := StrNew(xFileName);
  ElementList := nil;
  Count := 0;
end;

destructor tEleFile.Done;
begin
  StrDispose(Name);
  StrDispose(FileName);
end;

procedure tEleFile.WriteIni(IniFile : pChar; i:Integer);
var
  s : array [0..50] of char;
begin
  wvsprintf(@s, 'Alias%0i', i);
  WritePrivateProfileString('ELEMENT-FILES', s, Name, IniFile);
  wvsprintf(@s, 'File%0i', i);
  WritePrivateProfileString('ELEMENT-FILES', s, FileName, IniFile);
end;

procedure tEleFile.StoreName(var S : tStream);
begin
  S.StrWrite(Name);
end;

function tEleFile.Copy : pEleFile;
var p : pEleFile;
begin
  p := New(pEleFile, Init(Name, FileName));
  p^.ElementList := ElementList;
  p^.Count := Count;
  Copy := p;
end;

procedure tEleFile.ChangeName(s : pChar);
begin
  StrDispose(Name);
  Name := StrNew(s);
end;

procedure tEleFile.ChangeFile(s : pChar);
begin
  { Nur möglich, wenn ElementList = nil. }
  StrDispose(FileName);
  FileName := StrNew(s);
end;

function tEleFile.LoadEleFile : Boolean;
var
  Cursor : hCursor;
  S : tDosStream;
  s_, s__ : pChar;
begin
{$ifdef debug}
  appendLog('tEleFile.LaodEleFile 1');
{$endif}
  LoadEleFile := True;
  if Count = 0
  then begin
    { Info. }
    s__ := StrNew(pChar(SendMessage(hMainWin, ms_GetInfoStr, 0, 0)));
    GetMem(s_, StrLen(LoadString0(1025)) + StrLen(FileName) + 4);
    StrCopy(s_, @String0);
    StrCat(s_, '''');
    StrCat(s_, FileName);
    StrCat(s_, '''.');
    SendMessage(hMainWin, ms_UpdateInfo, 0, Longint(s_));
    StrDispose(s_);

    S.Init(FileName, stOpenRead);
    if S.Status = stOK
    then begin
      Cursor := SetCursor(LoadCursor(0, idc_Wait));
      ElementList := New(pCollection, Init(20, 10));
      ElementList^.Load(S);
      S.Done;
      SetCursor(Cursor);
    end
    else begin
      S.Done;
      GetMem(s_, StrLen(LoadString0(12)) + StrLen(FileName) - 1 {+1-2});
      wvsprintf(s_, @String0, FileName);
      MessageBox(hMainWin, s_, nil, mb_OK or mb_IconStop);
      StrDispose(s_);
      LoadEleFile := False;
      dec(Count);
    end;
    { Info. }
    SendMessage(hMainWin, ms_UpdateInfo, 0, Longint(s__));
    StrDispose(s__);
  end;
  inc(Count);
{$ifdef debug}
  appendLog('tEleFile.LaodEleFile 2');
{$endif}
end;

procedure tEleFile.DecCount;
begin
  dec(Count);
  if Count = 0 then
    Dispose(ElementList, Done);
end;

end.