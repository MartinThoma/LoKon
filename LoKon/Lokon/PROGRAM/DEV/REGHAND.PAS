program RegHand;

{ Adresse des personal  Eintrags in .EXE-Datei finden. }

uses
  Objects,
  Strings,
  WinTypes, WinProcs,
  OWindows, ODialogs;

{$R REGHAND.RES}

type
  pPersonalDlg = ^tPersonalDlg;
  tPersonalDlg = object (tDialog)
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure Mini(var Msg : tMessage);
      virtual id_First + 50;
    procedure Small(var Msg : tMessage);
      virtual id_First + 60;
  end;

const
  key : array [$0000..$0007] of char =
  (#112, #134, #229, #063, #156, #054, #023, #177);
  personlength = 60;

procedure tPersonalDlg.OK(var Msg : tMessage);
var
  i : Integer;
  person : array [0..personlength] of char;
  sum : longint;
  code : tPoint;
begin
  GetDlgItemText( hWindow, 101, @person, personlength );
  i := 0;
  sum := 0;
  while person[i]<>#0
  do begin
    inc(sum, (byte(person[i]) xor byte(key[i and 7])));
    inc(i);
  end;
  sum := (longint(integer(sum)) shl 16) + integer(sum);
  sum := sum xor $723a665c;
  code := tPoint(sum);
  with code
  do begin
    SetDlgItemInt(hWindow, 102, x, FALSE);
    SetDlgItemInt(hWindow, 103, y, FALSE);
  end;
end;

procedure tPersonalDlg.Mini(var Msg : tMessage);
var
  i : Integer;
  person : array [0..personlength] of char;
  sum : longint;
  code : tPoint;
begin
  GetDlgItemText( hWindow, 101, @person, personlength );
  i := 0;
  sum := 0;
  while person[i]<>#0
  do begin
    inc(sum, (byte(person[i]) xor byte(key[i and 7])));
    inc(i);
  end;
  sum := (longint(integer(sum)) shl 16) + integer(sum);
  sum := sum xor $def2a781;
  code := tPoint(sum);
  with code
  do begin
    SetDlgItemInt(hWindow, 102, x, FALSE);
    SetDlgItemInt(hWindow, 103, y, FALSE);
  end;
end;

procedure tPersonalDlg.Small(var Msg : tMessage);
var
  i : Integer;
  person : array [0..personlength] of char;
  sum : longint;
  code : tPoint;
begin
  GetDlgItemText( hWindow, 101, @person, personlength );
  i := 0;
  sum := 0;
  while person[i]<>#0
  do begin
    inc(sum, (byte(person[i]) xor byte(key[i and 7])));
    inc(i);
  end;
  sum := (longint(integer(sum)) shl 16) + integer(sum);
  sum := sum xor $a71bded2;
  code := tPoint(sum);
  with code
  do begin
    SetDlgItemInt(hWindow, 102, x, FALSE);
    SetDlgItemInt(hWindow, 103, y, FALSE);
  end;
end;

type
  pPersonalWin = ^tPersonalWin;
  tPersonalWin = object (tWindow)
    procedure GetWindowClass(var aWndClass : tWndClass); virtual;
    function GetClassName : pChar; virtual;
    procedure SetupWindow; virtual;
  end;

procedure tPersonalWin.GetWindowClass(var aWndClass : tWndClass);
begin
  inherited GetWindowClass(aWndClass);
  aWndClass.hIcon:=LoadIcon(hInstance, 'MAINICON');
end;

function tPersonalWin.GetClassName : pChar;
begin
  GetClassName:='LoKon V2.0 PERSONAL';
end;

procedure tPersonalWin.SetupWindow;
begin
  inherited SetupWindow;
  Application^.ExecDialog(New(pPersonalDlg, Init(@Self, 'REGISTRATION')));
  PostMessage(hWindow, wm_Destroy, 0, 0);
end;

type
  pPersonalApp = ^tPersonalApp;
  tPersonalApp = object (tApplication)
    procedure InitMainWindow; virtual;
  end;

procedure tPersonalApp.InitMainWindow;
var s : pChar;
begin
  GetMem(s, 101);
  LoadString(hInstance, 0, s, 100);
  MainWindow := New(pPersonalWin, Init(nil, s));
  FreeMem(s, 101);
end;

var App : tPersonalApp;
begin
  Randomize;
  with App
  do begin
    Init('LoKon V2.0 PER');
    Run;
    Done;
  end;
end.