unit ItemText;
{$I define.inc}

interface

uses
  Strings,
  Objects,
  WinTypes, WinProcs,
  OWindows,
  LK_Const,
  OWinEx,
  Paint,
  Item;

type
  pItemText = ^tItemText;
  tItemText = object (tItem)
    X, Y : Integer;
    FontData : tFontData;
    Text : pChar;
    constructor Init(xText : pChar; xFontData : tFontData);
    destructor Done; virtual;
    function Copy : pItem; virtual;
    function Name : pChar; virtual;
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var T : Text); virtual;
    procedure NewPos(Pos : tPosition); virtual;
    function Position : pPosition; virtual;
    procedure IncDirection; virtual;
    function GetRegion_ : hRgn; virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure ItemEdit(Window : pWindowsObject); virtual;
  end;

implementation

{ ------ tItemText ------------------------------------------------------ }

constructor tItemText.Init(xText : pChar; xFontData : tFontData);
begin
  X := 0;
  Y := 0;
  FontData := xFontData;
  Text := StrNew(xText);
(*  GetMem(Text, StrLen(xText) + 1);
  StrCopy(Text, xText);*)
  CalcItemRect;
end;

destructor tItemText.Done;
begin
  StrDispose(Text);
end;

function tItemText.Copy : pItem;
var
  p : pItem;
begin
  p := New(pItemText, Init(Text, FontData));
  Move(X, pItemText(p)^.X, SizeOf(X) + SizeOf(Y));
  p^.CalcItemRect;
  Copy := p;
end;

function tItemText.Name : pChar;
var
  sa : array [0..30] of char;
  s : pChar;
begin
  if StrLen(Text)>20
  then begin
    StrLCopy(sa, Text, 20);
    StrCat(sa, '...');
    s := @sa;
    wvsprintf(@String2, LoadString0(13), s);
    Name := @String2;
  end
  else begin
    wvsprintf(@String2, LoadString0(13), Text);
    Name := @String2;
  end;
end;

constructor tItemText.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('ItemText.Load 1');
{$endif}
  X := S.ReadSmallInt;
  Y := S.ReadSmallInt;
  S.Read(FontData, SizeOf(FontData));
{$ifdef debug}
  appendLog('ItemText.Load 1a');
{$endif}
  Text := S.StrRead;
{$ifdef debug}
  appendLog('ItemText.Load 1b');
{$endif}
  CalcItemRect;
{$ifdef debug}
  appendLog('ItemText.Load 2');
{$endif}
end;

procedure tItemText.Store(var S : tStream);
begin
  S.Write(X, SizeOf(X) + SizeOf(Y) + SizeOf(FontData));
  S.StrWrite(Text);
end;

procedure tItemText.StoreText(var t : Text);
begin
  StoreInt(t, 'x', X);
  StoreInt(t, 'y', Y);
  StoreFontData_(t, FontData);
end;

procedure tItemText.NewPos(Pos : tPosition);
begin
  Move(Pos, X, SizeOf(X)+SizeOf(Y)+SizeOf(FontData));
  CalcItemRect;
end;

function tItemText.Position : pPosition;
begin
  Position := @X;
  CalcItemRect;
end;

procedure tItemText.IncDirection;
begin
  with FontData
  do begin
    dec(Direct, 900);
    if Direct < 0 then inc(Direct, 3600);
  end;
  CalcItemRect;
end;

function tItemText.GetRegion_ : hRgn;
var
  Rgn : hRgn;
begin
{$ifdef debug}
  appendLog('ItemText.GetRegion_ 1');
  appendLog(StrPas(Text));
{$endif}
  Rgn := CreateTextRgn(Text, StrLen(Text), FontData);
{$ifdef debug}
  appendLog('ItemText.GetRegion_ 1a');
{$endif}
  OffsetRgn(Rgn, X, Y);
{$ifdef debug}
  appendLog('ItemText.GetRegion_ 1b');
{$endif}
  GetRegion_ := Rgn;
{$ifdef debug}
  appendLog('ItemText.GetRegion_ 2');
{$endif}
end;

function tItemText.GetState(A : tPoint; b : Integer) : Integer;
begin
  if (b and lm_Test) = lm_Test
  then GetState := ls_Test
  else
    case (b and lm_First) of
      lm_MouseMove,
      lm_LButton : GetState := ls_MoveActItem;
      lm_Connect : GetState := ls_ConnectionB;
    end;
end;

procedure tItemText.NotPaint(PaintDC: hDC);
begin
  SetWindowOrgEx(PaintDC, 0, 0, nil);
  CalcItemRect;
  with ItemRect do
    Rectangle(PaintDC, Left, Top, Right, Bottom);
end;

procedure tItemText.Paint(PaintDC: hDC);
var
  font, font_ : hFont;
begin
  SetWindowOrgEx(PaintDC, 0, 0, nil);
  with FontData do
    font := CreateFont(
      Height, Width,
      Direct, Direct,
      400 + 300 * (FontFlag and $01),
      FontFlag and $02,
      FontFlag and $04,
      FontFlag and $08,
      ANSI_Charset, Font_Precis,
      0, Font_Quality, 1, FontName[FontNr]);
  font_ := SelectObject(PaintDC, font);
  TextOut(PaintDC, X, Y, Text, StrLen(Text));
  SelectObject(PaintDC, font_);
  DeleteObject(font);
end;

type
  pItemTextDlg = ^tItemTextDlg;
  tItemTextDlg = object (tDialogSB)
    p : pItemText;
    fd : tFontData;
    constructor Init(xParent : pWindowsObject; xp : pItemText);
    procedure SetupWindow; virtual;
    procedure idFont(var Msg : tMessage);
      virtual id_First + 120;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tItemTextDlg.Init(xParent : pWindowsObject; xp : pItemText);
begin
  inherited Init(xParent, 'ITEMTEXTDLG');
  p := xp;
  fd := p^.FontData;
end;

procedure tItemTextDlg.SetupWindow;
begin
  inherited SetupWindow;
  with p^
  do begin
    SetDlgItemInt(hWindow, 100, Word(X), True);
    SetDlgItemInt(hWindow, 101, Word(Y), True);
    SetDlgItemText(hWindow, 102, Text);
  end;
end;

procedure tItemTextDlg.idFont(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pFontDialog, Init(@Self, @fd)));
end;

procedure tItemTextDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 840);
end;

procedure tItemTextDlg.OK(var Msg : tMessage);
var
  i : Integer;
  b : Boolean;
  s : pChar;
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
    i := GetWindowTextLength(GetItemHandle(102));
    GetMem(s, i+1);
    GetDlgItemText(hWindow, 102, s, i+1);
    if StrComp(s, Text) = 0
    then StrDispose(s)
    else begin
      StrDispose(Text);
      Text := s;
      b := true;
    end;
    if StrLComp(@fd, @FontData, SizeOf(tFontData)) <> 0 then b := True;
    FontData := fd;
  end;
  if b then
    p^.CalcItemRectCon;
  EndDlg(id_OK);
end;

procedure tItemText.ItemEdit(Window : pWindowsObject);
begin
  Application^.ExecDialog(New(pItemTextDlg, Init(Window, @Self)));
end;

{ ------ rItemText ------------------------------------------------------ }

const
  rItemText : TStreamRec = (
     ObjType : riItemText;
     VmtLink : Ofs(TypeOf(tItemText)^);
     Load  : @tItemText.Load;
     Store : @tItemText.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rItemText);
end.
