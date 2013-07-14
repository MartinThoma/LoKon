unit MainWin;
{$I define.inc}

interface

uses
  WINDOS,
  Objects, Strings,
  WinTypes, WinProcs,
  OWindows, ODialogs,
  OPrinter,
  {Win31,}
  CommDlg,
  LK_Const,
  OWinEx,
  Paint,
  Element,
  LayWin,
{$ifdef elewin}
  EleWin,
{$endif}
{$ifdef layele}
  MacroWin,
{$endif}
  EleFile, Switch;

const
  id_TickTimer = 1;

type
  pMainWindow = ^tMainWindow;
  tMainWindow = object (tMDIWindow)
    TickTime : Word;
    TickOn : Boolean;
    EleFiles : pCollection;
    IniFile : pChar;
    Pos : array [0..25] of Char;
    Info : tString;
    InfoRes : Integer;
    Printer : pPrinter;
    DragState : Integer; { Status. }
    DragInfo : Pointer; { Statusinformation. }
    bnum : Integer; { Anzahl der Knöpfe. }
    speedb : pIntegerArray; { Bitmap- bzw Kommandonummern der einzelnen Knöpfe. }
    activeb : pIntegerArray; { TRUE, falls Button aktiv. }
    updatesb : boolean;
    constructor Init;
    destructor Done; virtual;
    procedure LoadIni(FileName : pChar);
    procedure SetupWindow; virtual;
    procedure GetWindowClass(var aWndClass : tWndClass); virtual;
    function GetClassName : pChar; virtual;
    procedure WMCommand(var Msg : tMessage);
      virtual wm_First + wm_Command;
    procedure msGetEleFile(var Msg : tMessage);
      virtual ms_GetEleFile;
    procedure msChildMenuPos(var Msg : tMessage);
      virtual ms_ChildMenuPos;
    procedure msLoadFile(var Msg : tMessage);
      virtual ms_LoadFile;
    procedure NewWin(p : pWindowsObject);
    procedure msNewWin(var Msg : tMessage);
      virtual ms_NewWin;
    procedure cmCreateLayWin(var Msg : tMessage);
      virtual cm_First + cm_CreateLayWin;
{$ifdef elewin}
    procedure cmCreateEleWin(var Msg : tMessage);
      virtual cm_First + cm_CreateEleWin;
{$endif}
    procedure cmFileOpen(var Msg : tMessage);
      virtual cm_First + cm_FileOpen;
    procedure msSave(var Msg : tMessage);
      virtual ms_Save;
    procedure cmSave(var Msg : tMessage);
      virtual cm_First + cm_FileSave;
    procedure msSaveAs(var Msg : tMessage);
      virtual ms_SaveAs;
    procedure cmPrintDlg(var Msg : tMessage);
      virtual cm_First + cm_PrintDlg;
    procedure cmPrint(var Msg : tMessage);
      virtual cm_First + cm_Print;
    procedure cmEleFiles(var Msg : tMessage);
      virtual cm_First + cm_EleFiles;
    procedure ChangeIniFile( s : pChar );
    procedure cmLoadOpt(var Msg : tMessage);
      virtual cm_First + cm_LoadOpt;
    procedure cmSaveAsOpt(var Msg : tMessage);
      virtual cm_First + cm_SaveAsOpt;
    procedure cmSaveOpt(var Msg : tMessage);
      virtual cm_First + cm_SaveOpt;
    procedure SaveIni;
    procedure SaveAlwaysToINI;
    procedure cmMessageOn(var Msg : tMessage);
      virtual cm_First + cm_MessageOn;
    procedure cmCollision(var Msg : tMessage);
      virtual cm_First + cm_Collision;
    procedure cmTick(var Msg : tMessage);
      virtual cm_First + cm_Tick;
    procedure cmOptROff(var Msg : tMessage);
      virtual cm_First + cm_OptROff;
    procedure cmOptRBig(var Msg : tMessage);
      virtual cm_First + cm_OptRBig;
    procedure cmOptRSmall(var Msg : tMessage);
      virtual cm_First + cm_OptRSmall;
    procedure cmOptRFront(var Msg : tMessage);
      virtual cm_First + cm_OptRFront;
    procedure cmOptRBack(var Msg : tMessage);
      virtual cm_First + cm_OptRBack;
    procedure cmOptShowInOut(var Msg : tMessage);
      virtual cm_First + cm_OptShowInOut;
    procedure cmOptConBW(var Msg : tMessage);
      virtual cm_First + cm_OptConBW;
    procedure cmOptFont(var Msg : tMessage);
      virtual cm_First + cm_OptFont;
    procedure cmOptRasterPos(var Msg : tMessage);
      virtual cm_First + cm_OptRasterPos;
    procedure wmTimer(var Msg : tMessage);
      virtual wm_First + wm_Timer;
    procedure cmManuelTick(var Msg : tMessage);
      virtual cm_First + cm_ManuelTick;
    procedure msUpdateInfo(var Msg : tMessage);
      virtual ms_UpdateInfo;
    procedure msUpdatePos(var Msg : tMessage);
      virtual ms_UpdatePos;
    procedure msGetInfoStr(var Msg : tMessage);
      virtual ms_GetInfoStr;
    procedure WMGetMinMaxInfo(var Msg : tMessage);
      virtual WM_FIRST + WM_GETMINMAXINFO;
    procedure wmNCCalcSize(var Msg : tMessage);
      virtual wm_First + wm_NCCalcSize;
    procedure wmNCHitTest(var Msg : tMessage);
      virtual wm_First + wm_NCHitTest;
    procedure wmMouseMove(var Msg : tMessage);
      virtual wm_First + wm_MouseMove;
    procedure wmLButtonUp(var Msg : tMessage);
      virtual wm_First + wm_LButtonUp;
    procedure wmNCLButtonDown(var Msg : tMessage);
      virtual wm_First + wm_NCLButtonDown;
    procedure GetStatusRect(var R : tRect);
    procedure GetSpeedbarRect_(var R : tRect);
    procedure GetSpeedbarRect(var R : tRect);
    procedure msSpeedbar(var Msg : tMessage);
      virtual wm_First + ms_Speedbar;
    procedure InsertSpeedbutton(Num, Act : Integer);
    procedure DeleteSpeedbutton(Num : Integer);
    procedure InfoPaint;
    procedure PosPaint;
    procedure wmNCPaint(var Msg : tMessage);
      virtual wm_First + wm_NCPaint;
    procedure PaintSpeedbar;
    procedure cmAbout(var Msg : tMessage);
      virtual cm_First + cm_About;
    procedure cmHelpContents(var Msg : tMessage);
      virtual cm_First + cm_HelpContents;
    procedure cmHelpContext(var Msg : tMessage);
      virtual cm_First + cm_HelpContext;
    procedure cmHelpOnHelp(var Msg : tMessage);
      virtual cm_First + cm_HelpOnHelp;
    procedure cmHowToDo(var Msg : tMessage);
      virtual cm_First + cm_HowToDo;
{$ifdef test}
    procedure cmRegister(var Msg : tMessage);
      virtual cm_First + cm_Register;
{$endif}
    procedure msFileList(var Msg : tMessage);
      virtual ms_FileList;
    procedure AddFileList( s : pChar );
    procedure cmResetFileMenu(var Msg : tMessage);
      virtual cm_First + cm_ResetFileMenu;
    procedure msIsShown(var Msg : tMessage);
      virtual ms_IsShown;
{$ifdef layele}
    procedure msNewMacroIO(var Msg : tMessage);
      virtual ms_NewMacroIO;
{$endif}
{$ifdef osc}
    procedure cmShowAllOscWin(var Msg : tMessage);
      virtual cm_First + cm_ShowAllOscWin;
    procedure cmHideAllOscWin(var Msg : tMessage);
      virtual cm_First + cm_HideAllOscWin;
{$endif}
{$ifdef layele}
    procedure cmShowAllMacros(var Msg : tMessage);
      virtual cm_First + cm_ShowAllMacros;
    procedure cmHideAllMacros(var Msg : tMessage);
      virtual cm_First + cm_HideAllMacros;
{$endif}
    procedure LockSpeedbar;
    procedure UnlockSpeedbar;
    procedure cmZoomAllWin(var Msg : tMessage);
      virtual cm_First + cm_ZoomAllWin;
    procedure msLockSpeedbar( var Msg : tMessage );
      virtual ms_LockSpeedbar;
{$ifdef undo}
    procedure wmCompacting( var Msg : tMessage );
      virtual WM_FIRST + WM_COMPACTING;
    procedure cmOptUndo( var Msg : tMessage );
      virtual CM_FIRST + cm_OptUndo;
{$endif}
  end;

implementation

{ ------ tTickDlg ------------------------------------------------------- }

const
  id_TickNum = 100;
  id_TickScroll = 101;
  id_TickShow = 102;
  id_TickActive = 103;

type
  tNumOn = record
    Num : Word;
    On : Boolean;
  end;

type
  pTickDlg = ^tTickDlg;
  tTickDlg = object (tDialogEx)
    Poi : Pointer;
    TickNum : Word;
    TickOn : Boolean;
    constructor Init(xParent : pWindowsObject; xPoi : Pointer);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure wmTimer(var Msg : tMessage);
      virtual wm_First + wm_Timer;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure idTickActive(var Msg : tMessage);
      virtual id_First + id_TickActive;
    procedure idTickScroll(var Msg : tMessage);
      virtual id_First + id_TickScroll;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tTickDlg.Init(xParent : pWindowsObject; xPoi : Pointer);
begin
  inherited Init(xParent, 'TDLG');
  Poi := xPoi;
  with tNumOn(Poi^)
  do begin
    TickNum := Num;
    TickOn := On;
  end;
end;

destructor tTickDlg.Done;
begin
  KillTimer(hWindow, id_TickTimer);
  inherited Done;
end;

procedure tTickDlg.SetupWindow;
var Msg : tMessage;
begin
  inherited SetupWindow;
  SetDlgItemInt(hWindow, id_TickNum, TickNum, False);
  SetScrollRange(GetItemHandle(id_TickScroll),
    sb_Ctl, MinTickTime, MaxTickTime, False);
  SetScrollPos(
    GetItemHandle(id_TickScroll), sb_Ctl, Integer(TickNum), False);
  if SetTimer(hWindow, id_TickTimer, TickNum, nil) = 0
  then begin
    EnableWindow(GetItemHandle(id_TickNum), False);
    EnableWindow(GetItemHandle(id_TickScroll), False);
    EnableWindow(GetItemHandle(id_TickShow), False);
    EnableWindow(GetItemHandle(id_TickActive), False);
    ErrorMessage(39);
  end
  else begin
    TickOn := not TickOn;
    idTickActive(Msg);
  end;
end;

procedure tTickDlg.wmTimer(var Msg : tMessage);
begin
  CheckDlgButton(
    hWindow, id_TickShow,
    Word(not WordBool(IsDlgButtonChecked(hWindow, id_TickShow))));
end;

procedure tTickDlg.OK(var Msg : tMessage);
begin
  with tNumOn(Poi^)
  do begin
    Num := TickNum;
    On := TickOn;
  end;
  inherited OK(Msg);
end;

procedure tTickDlg.idTickActive(var Msg : tMessage);
begin
  CheckDlgButton(
    hWindow, id_TickActive, Word(not TickOn));
  TickOn := not TickOn;
  if TickOn
  then begin
    EnableWindow(GetItemHandle(id_TickNum), True);
    EnableWindow(GetItemHandle(id_TickScroll), True);
    EnableWindow(GetItemHandle(id_TickShow), True);
    SetTimer(hWindow, id_TickTimer, TickNum, nil);
  end
  else begin
    EnableWindow(GetItemHandle(id_TickNum), False);
    EnableWindow(GetItemHandle(id_TickScroll), False);
    EnableWindow(GetItemHandle(id_TickShow), False);
    KillTimer(hWindow, id_TickTimer);
  end;
end;

procedure tTickDlg.idTickScroll(var Msg : tMessage);
var Pos : Integer;
begin
  if Msg.Message = wm_VScroll
  then begin
    Pos := GetScrollPos(Msg.lParamHi, sb_Ctl);
    case Msg.wParam of
      sb_LineUp : dec(Pos);
      sb_LineDown : inc(Pos);
      sb_PageUp : dec(Pos, 20);
      sb_PageDown : inc(Pos, 20);
      sb_ThumbTrack,
      sb_ThumbPosition : Pos := Msg.lParamLo;
    end;
    if Pos < MinTickTime then Pos := MinTickTime;
    if Pos > MaxTickTime then Pos := MaxTickTime;
    SetScrollPos(Msg.lParamHi, sb_Ctl, Pos, True);
    SetDlgItemInt(hWindow, id_TickNum, Word(Pos), False);
    TickNum := Pos;
    SetTimer(hWindow, id_TickTimer, TickNum, nil);
  end;
end;

procedure tTickDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 110);
end;

{ ------ tEleFilesDlg --------------------------------------------------- }

const
  id_NameList = 100;
  id_FileList = 101;
  id_ScrollBar = 102;
  id_NewEleFile = 200;
  id_ChangeName = 201;
  id_ChangeFile = 202;
  id_DeleteFile = 203;

type
  pEleFilesDlg = ^tEleFilesDlg;
  tEleFilesDlg = object (tDialogEx)
    EleFiles : pCollection;
    constructor Init(xParent : pWindowsObject);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure EnableChangeButtons(b : Boolean);
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure idNameList(var Msg : tMessage);
      virtual id_First + id_NameList;
    procedure idFileList(var Msg : tMessage);
      virtual id_First + id_FileList;
    procedure idScrollBar(var Msg : tMessage);
      virtual id_First + id_ScrollBar;
    procedure idNewEleFile(var Msg : tMessage);
      virtual id_First + id_NewEleFile;
    procedure idChangeName(var Msg : tMessage);
      virtual id_First + id_ChangeName;
    procedure idChangeFile(var Msg : tMessage);
      virtual id_First + id_ChangeFile;
    procedure idDeleteFile(var Msg : tMessage);
      virtual id_First + id_DeleteFile;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tEleFilesDlg.Init(xParent : pWindowsObject);
begin
  inherited Init(xParent, 'ELEFILESDLG');
  EleFiles := New(pCollection, Init(8, 4));
end;

destructor tEleFilesDlg.Done;
begin
  if EleFiles <> nil then Dispose(EleFiles, Done);
  inherited Done;
end;

procedure tEleFilesDlg.SetupWindow;
procedure DoCopy(p : pEleFile); far;
begin
  EleFiles^.Insert(p^.Copy);
  SendDlgItemMsg(id_NameList, lb_AddString, 0, Longint(p^.Name));
  SendDlgItemMsg(id_FileList, lb_AddString, 0, Longint(p^.FileName));
end;
begin
  inherited SetupWindow;
  SendDlgItemMsg(id_FileList, lb_SetHorizontalExtent, 1000, 0);
  pMainWindow(Parent)^.EleFiles^.ForEach(@DoCopy);
  SetScrollRange(
    GetItemHandle(id_ScrollBar), sb_Ctl, 0, EleFiles^.Count-1, False);
end;

procedure tEleFilesDlg.EnableChangeButtons(b : Boolean);
begin
  EnableWindow(GetItemHandle(id_ChangeName), b);
  EnableWindow(GetItemHandle(id_ChangeFile), b);
  EnableWindow(GetItemHandle(id_DeleteFile), b);
end;

procedure tEleFilesDlg.OK(var Msg : tMessage);
begin
  Dispose(pMainWindow(Parent)^.EleFiles, Done);
  pMainWindow(Parent)^.EleFiles := EleFiles;
  EleFiles := nil;
  inherited OK(Msg);
end;

procedure tEleFilesDlg.idNameList(var Msg : tMessage);
var i : Integer;
begin
  case Msg.lParamHi of
    lbn_SelChange :
      begin
        i := Integer(SendDlgItemMsg(id_NameList, lb_GetCurSel, 0, 0));
        SendDlgItemMsg(id_FileList, lb_SetCurSel, i, 0);
        SetScrollPos(GetItemHandle(id_ScrollBar), sb_Ctl, i, True);
        EnableChangeButtons(pEleFile(EleFiles^.At(i))^.Count = 0);
      end;
  end;
end;

procedure tEleFilesDlg.idFileList(var Msg : tMessage);
var i : Integer;
begin
  case Msg.lParamHi of
    lbn_SelChange :
      begin
        i := Integer(SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0));
        SendDlgItemMsg(id_NameList, lb_SetCurSel, i, 0);
        SetScrollPos(GetItemHandle(id_ScrollBar), sb_Ctl, i, True);
        EnableChangeButtons(pEleFile(EleFiles^.At(i))^.Count = 0);
      end;
  end;
end;

procedure tEleFilesDlg.idScrollBar(var Msg : tMessage);
var
  Pos, i : Integer;
begin
  if Msg.Message = wm_VScroll
  then begin
    Pos := GetScrollPos(Msg.lParamHi, sb_Ctl);
    case Msg.wParam of
      sb_LineUp : dec(Pos);
      sb_LineDown : inc(Pos);
      sb_PageUp : dec(Pos, 8);
      sb_PageDown : inc(Pos, 8);
      sb_ThumbPosition : Pos := Msg.lParamLo;
    end;
    i := SendDlgItemMsg(id_FileList, lb_GetCount, 0, 0);
    if Pos >= i then Pos := i - 1;
    if Pos < 0 then Pos := 0;
    SetScrollPos(Msg.lParamHi, sb_Ctl, Pos, True);
    SendDlgItemMsg(id_NameList, lb_SetCurSel, Pos, 0);
    SendDlgItemMsg(id_FileList, lb_SetCurSel, Pos, 0);
    SendDlgItemMsg(
      id_FileList, lb_SetTopIndex,
      SendDlgItemMsg(id_NameList, lb_GetTopIndex, 0, 0), 0);
  end;
end;

procedure tEleFilesDlg.idNewEleFile(var Msg : tMessage);
var Input : tInputStr;
begin
  Input[0] := #0;
  SendDlgItemMsg(
    id_NameList, lb_SetCurSel,
    SendDlgItemMsg(id_NameList, lb_AddString, 0, Longint(@Input)), 0);
  SendDlgItemMsg(
    id_FileList, lb_SetCurSel,
    SendDlgItemMsg(id_FileList, lb_AddString, 0, Longint(@Input)), 0);
  EnableChangeButtons(True);
  EleFiles^.Insert(New(pEleFile, Init(@Input, @Input)));
  idChangeFile(Msg);
  SetScrollRange(GetItemHandle(id_ScrollBar),
    sb_Ctl, 0, EleFiles^.Count-1, False);
  SetScrollPos(GetItemHandle(id_ScrollBar), sb_Ctl, EleFiles^.Count-1, True);
  SendDlgItemMsg(
    id_FileList, lb_SetTopIndex,
    SendDlgItemMsg(id_NameList, lb_GetTopIndex, 0, 0), 0);
  if Boolean(Msg.Result) then idChangeName(Msg);
  if not Boolean(Msg.Result) then idDeleteFile(Msg);
end;

procedure tEleFilesDlg.idChangeName(var Msg : tMessage);
var
  i : Integer;
  Input : tInputStr;
begin
  Msg.Result := Byte(True);
  i := SendDlgItemMsg(id_NameList, lb_GetCurSel, 0, 0);
  SendDlgItemMsg(id_NameList, lb_GetText, i, Longint(@Input));
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @Input, 49, InputStrLen))) = id_OK
  then begin
    SendDlgItemMsg(id_NameList, lb_DeleteString, i, 0);
    SendDlgItemMsg(id_NameList, lb_InsertString, i, Longint(@Input));
    SendDlgItemMsg(id_NameList, lb_SetCurSel, i, 0);
    pEleFile(EleFiles^.At(i))^.ChangeName(@Input);
  end
  else Msg.Result := Byte(False);
end;

procedure tEleFilesDlg.idChangeFile(var Msg : tMessage);
var
  i : Integer;
  DialogTitle, FileName : tFileName;
begin
  Msg.Result := Byte(True);
  with FileStruct
  do begin
    hWndOwner := hMainWin;
    LPstrFile := FileName;
    nMaxFile := MaxFileNameLen;
    LPStrTitle := LoadString0(0);
    lPStrFileTitle := DialogTitle;
    nMaxFileTitle := MaxFileNameLen;
    lPStrDefExt := 'ELE';
    nFilterIndex := ext_ELE;
    Flags := ofn_EnableTemplate or ofn_FileMustExist;
  end;
  FileName[0] := #0;
  if GetOpenFileName(FileStruct)
  then begin
    if FileStruct.nFilterIndex = ext_ELE
    then begin
      i := SendDlgItemMsg(id_NameList, lb_GetCurSel, 0, 0);
      SendDlgItemMsg(id_FileList, lb_DeleteString, i, 0);
      SendDlgItemMsg(id_FileList, lb_InsertString, i, Longint(@FileName));
      SendDlgItemMsg(id_FileList, lb_SetCurSel, i, 0);
      pEleFile(EleFiles^.At(i))^.ChangeFile(@FileName);
    end
    else begin
      ErrorMessage(1);
      Msg.Result := Byte(False);
    end;
  end
  else Msg.Result := Byte(False);
end;

procedure tEleFilesDlg.idDeleteFile(var Msg : tMessage);
var i : Integer;
begin
  i := SendDlgItemMsg(id_NameList, lb_GetCurSel, 0, 0);
  SendDlgItemMsg(id_NameList, lb_DeleteString, i, 0);
  SendDlgItemMsg(id_FileList, lb_DeleteString, i, 0);
  EnableChangeButtons(False);
  EleFiles^.AtFree(i);
  SetScrollRange(GetItemHandle(id_ScrollBar),
    sb_Ctl, 0, EleFiles^.Count-1, False);
end;

procedure tEleFilesDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, 'LOKON.HLP', HELP_CONTEXT, 400);
end;

{ ------ tMainWindow ---------------------------------------------------- }

const
  DR_NONE = 0;
  DR_SPEEDBUTTON = 1;

type
  pDRSpeedButton = ^tDRSpeedButton;
  tDRSpeedButton = record
    R : tRect;
    clicked : Boolean;
    idx : Integer;
  end;

const
  id_Info1 = 201;
  id_Info2 = 202;

constructor tMainWindow.Init;
var
  p : pWindowsObject;
begin
  tMDIWindow.Init(LoadString0(15), LoadMenu(hRes, 'MAINMENU'));
  ChildMenuPos := 3;
  TickTime := 500;
  TickOn := False;
  IniFile := nil;
  EleFiles := New(pCollection, Init(8, 4));
  Info[0] := #0;
  Pos[0] := #0;
  InfoRes := -1;
  Printer := New(pPrinter, Init);
  { Speedbar. }
  bnum := 0;
  updatesb := true;
  SpeedB := nil;
  ActiveB := nil;
end;

destructor tMainWindow.Done;
begin
{$ifdef test}
  if shareware
  then begin
    SendMessage(hWindow, wm_Command, cm_About, 0);
  end;
{$endif}
  SaveAlwaysToIni;
  KillTimer(hWindow, id_TickTimer);
  StrDispose(IniFile);
  inherited Done;
  Dispose(EleFiles, Done);
  Dispose(Printer, Done);
  { Speedbar. }
  FreeMem(SpeedB, bnum*SizeOf(Integer));
  FreeMem(ActiveB, bnum*SizeOf(Integer));
  WinHelp(hMainWin, 'LOKON.HLP', HELP_QUIT, 0);
end;

const key : array [$0000..$0007] of char =
  (#112, #134, #229, #063, #156, #054, #023, #177);

procedure tMainWindow.LoadIni(FileName : pChar);
var
  Msg : tMessage;
  Raster_ : Shortint;
  i, j : Integer;
  s : array [0..20] of char;
  alias, filen : tString;
{$ifdef test}
  w : tPoint;
  code,
  sum : longint;
{$endif}
function IsSameName(p : pEleFile) : Boolean; far;
begin
  IsSameName := StrIComp(p^.Name, @alias) = 0;
end;
begin
  IniFile := StrNew(FileName);
  GetPrivateProfileString(
    'VERSION', 'version', 'x.x',
    LoKon_Version, LoKon_Version_length+1, IniFile );
  GetPrivateProfileString(
    'VERSION', 'date', 'xx.xx.xxxx',
    LoKon_Date, LoKon_Date_length+1, IniFile );

  { Element-Aliases laden. }
  j:=Integer(GetPrivateProfileInt('ELEMENT-FILES', 'Number', 0, IniFile));
  for i:=1 to j
  do begin
    wvsprintf(@s, 'Alias%0i', i);
    GetPrivateProfileString('ELEMENT-FILES', @s, nil, @alias, StringLen, IniFile);
    wvsprintf(@s, 'File%0i', i);
    GetPrivateProfileString('ELEMENT-FILES', @s, nil, @filen, StringLen, IniFile);
    EleFiles^.Insert(New(pEleFile, Init(alias, filen)));
  end;

  { Element-Aliases nach Neuinstallation bzw. Update laden. }
  j:=Integer(GetPrivateProfileInt('SETUP_ELE-FILES', 'Number', 0, IniFile));
  for i:=1 to j
  do begin
    wvsprintf(@s, 'Alias%0i', i);
    GetPrivateProfileString('SETUP_ELE-FILES', @s, nil, @alias, StringLen, IniFile);
    if EleFiles^.FirstThat(@IsSameName)=nil
    then begin
      wvsprintf(@s, 'File%0i', i);
      GetPrivateProfileString('SETUP_ELE-FILES', @s, nil, @filen, StringLen, IniFile);
      EleFiles^.Insert(New(pEleFile, Init(alias, filen)));
    end;
  end;

  { Einstellungen laden. }
  GetPrivateProfileString('GENERAL', 'Messages', 'off', @s, 20, IniFile);
  MessageOn := StrIComp(@s, 'on') = 0;
  MessageOn := not MessageOn;
  cmMessageOn(Msg);
  GetPrivateProfileString('GENERAL', 'Collision', 'on', @s, 20, IniFile);
  xCollision := StrIComp(@s, 'on') = 0;
  xCollision := not xCollision;
  cmCollision(Msg);
  TickTime:=GetPrivateProfileInt('TIMER', 'Time', 100, IniFile);
  GetPrivateProfileString('TIMER', 'State', 'on', @s, 20, IniFile);
  TickOn := StrIComp(@s, 'on') = 0;
  if TickOn
  then begin
    SetTimer(hWindow, id_TickTimer, TickTime, nil);
    EnableMenuItem(Attr.Menu, cm_ManuelTick, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_ManuelTick);
  end
  else begin
    KillTimer(hWindow, id_TickTimer);
    EnableMenuItem(Attr.Menu, cm_ManuelTick, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_ManuelTick);
  end;
  DrawMenuBar(hWindow);
  Raster_ := shortint(GetPrivateProfileInt('RASTER', 'Type', 2, IniFile));
  SendMessage(hWindow, wm_Command, cm_OptROff + Raster_, 0);
  if xShowInOut
  then SendMessage(hWindow, wm_Command, cm_OptShowInOut, 0);
  GetPrivateProfileString('RASTER', 'Position', 'behind', @s, 20, IniFile);
  xRasterFront := StrIComp(@s, 'front') = 0;
  GetPrivateProfileString('GENERAL', 'ShowInOut', 'off', @s, 20, IniFile);
  xShowInOut := StrIComp(@s, 'on') = 0;
  GetPrivateProfileString('GENERAL', 'Connections', 'color', @s, 20, IniFile);
  xConBW := not StrIComp(@s, 'color') = 0;
{$ifdef undo}
  GetPrivateProfileString('GENERAL', 'Undo', 'true', @s, 20, IniFile);
  xUndo := not StrIComp(@s, 'false') = 0;
  cmOptUndo(Msg);
{$endif}
  if xRasterFront
  then SendMessage(hWindow, wm_Command, cm_OptRFront, 0);
  xShowInOut := not xShowInOut;
  SendMessage(hWindow, wm_Command, cm_OptShowInOut, 0);
  if xConBW
  then begin
    OnPen := OnPenBW;
    OffPen := OffPenBW;
  end
  else begin
    OnPen := OnPenCol;
    OffPen := OffPenCol;
  end;
  RasterPos := Integer(GetPrivateProfileInt('RASTER', 'Positioning', 10, IniFile));
  with FontDataOpt
  do begin
    Height := Shortint(GetPrivateProfileInt('FONT', 'Height', 10, IniFile));
    Width := Shortint(GetPrivateProfileInt('FONT', 'Width', 0, IniFile));
    Direct := Integer(GetPrivateProfileInt('FONT', 'Direction', 0, IniFile));
    FontNr := Byte(GetPrivateProfileInt('FONT', 'Number', 0, IniFile));
    FontFlag := Byte(GetPrivateProfileInt('FONT', 'Flag', 0, IniFile));
  end;

  { File-Menu }
  for i := 0 to FileListMax do
    DeleteMenu(Attr.Menu, cm_FileList+i, MF_BYCOMMAND);
  for i := FileListMax downto 0
  do begin
    wvsprintf(@alias, 'file%0i', i);
    GetPrivateProfileString(
      'FILE_MENU', @alias, '', @filen, StringLen, IniFile);
    if StrLen(filen) > 0
    then AddFileList(@filen);
  end;

{$ifdef test}
  { Registrierung }
  GetPrivateProfileString(
    'REG', 'name', 'SHAREWARE',
    @person, personlength, IniFile );
  if ( StrComp(person, 'SHAREWARE') = 0 ) or
     ( StrComp(person, '') = 0 )
  then begin
    shareware := true;
  end
  else begin
    with w
    do begin
      x := GetPrivateProfileInt( 'REG', 'codel', 0, IniFile );
      codel := x;
      y := GetPrivateProfileInt( 'REG', 'codeh', 0, IniFile );
      codeh := y;
    end;
    code := makelongint(w);
    i := 0;
    sum := 0;
    while person[i]<>#0
    do begin
      inc(sum, (byte(person[i]) xor byte(key[i and 7])));
      inc(i);
    end;
    sum := (longint(integer(sum)) shl 16) + integer(sum);
{$ifdef mini}
    sum := sum xor $def2a781;
{$endif}
{$ifdef small}
    sum := sum xor $a71bded2;
{$endif}
{$ifdef full}
    sum := sum xor $723a665c;
{$endif}
    if (i>8) and (sum = code)
    then begin
      shareware := false;
    end
    else begin
      WritePrivateProfileString( 'REG', 'name', nil, IniFile );
      WritePrivateProfileString( 'REG', 'codel', nil, IniFile );
      WritePrivateProfileString( 'REG', 'codeh', nil, IniFile );
      MessageBox(
        hWindow, LoadString0(32542), LoadString1(15),
        MB_ICONSTOP or MB_OK);
      shareware := true;
      PostMessage( hWindow, WM_CLOSE, 0, 0 );
    end;
  end;
{$endif}
end;

procedure tMainWindow.SetupWindow;
{$ifdef test}
var
  i : integer;
  s : pChar;
{$endif}
begin
  Randomize; { Für Shareware-Fenster. }
  inherited SetupWindow;
  SendMessage(hWindow, ms_UpdateInfo, 0, 0); { Bereit. }
  hMainWin := hWindow;
  GetCurDir(@String1, 0);
  StrCat(@String1, '\lokon.ini');

  { Speedbar buttons. }
  InsertSpeedbutton(cm_FileOpen, SBActive_);
  InsertSpeedbutton(cm_FileSave, 0);
  InsertSpeedbutton(cm_ManuelTick, 0);
  InsertSpeedbutton(24340, SBActive_); { Exit. }

  EleFiles^.FreeAll;
  LoadIni(@String1);
  ChangeIniFile(@String1);
  GetCurDir(@String2, 0);
  StrCat(@String2, '\setup.ini');
  if GetPrivateProfileInt('SETUP', 'setup', 0, @String2)<>0
  then begin
    LoadIni(@String2);
    WritePrivateProfileString('SETUP', 'setup', '0', @String2);
    ChangeIniFile(@String1);
    SaveIni;
  end;

  GetWindowText( hWindow, @String0, StringLen );
  strcat( @String0, LoKon_Version );
  SetWindowText( hWindow, @String0 );
  if TickOn then SetTimer(hWindow, id_TickTimer, TickTime, nil);
  { Dateien, die im Parameterstring angegeben sind, laden: }
  if StrLen(System.CmdLine) > 0
  then PostMessage ( hWindow, ms_LoadFile, 0, Longint(System.CmdLine) );

{$ifdef test}
  if shareware
  then begin
    AppendMenu(Attr.Menu, MF_POPUP, LoadMenu(hRes,'SHAREWARE'), '&Shareware');
    FileStruct.lpTemplateName := 'SHAREFILEDLG';
    SendMessage(hWindow, WM_COMMAND, CM_ABOUT, 0); { unbedingt Send wegen
      der Benutzung von @String0 und String1.  }
{$ifdef pleasetype}
    for i := 0 to 4 do
      String0[i] := char(random(10)+byte('0'));
    String0[5] := #0;
    s := StrNew(@String0);
    StrCopy( @String1, @String0 );
    wvsprintf( @String0, 'please type: %s', s );
    StrDispose(s);
    Application^.ExecDialog(
      New(pTextDlg, Init2(@Self, @String2, @String0, 6)));
    if StrIComp(@String2, @String1)<>0
    then PostMessage(HWindow, WM_CLOSE, 0, 0);
{$endif}
  end;
{$endif}
end;

procedure tMainWindow.GetWindowClass(var aWndClass : tWndClass);
begin
  inherited GetWindowClass(aWndClass);
  with aWndClass
  do begin
    hIcon := LoadIcon(hInstance, 'MAINICON');
    hBrBackground := CreateSolidBrush(GetSysColor(COLOR_APPWORKSPACE));
  end;
end;

function tMainWindow.GetClassName : pChar;
begin
  GetClassName:='LoKon V2.2 MainWin';
end;

procedure tMainWindow.WMCommand(var Msg : tMessage);
begin
  with Msg do
    if (wParam>=cm_ToolFirst) and (wParam<=cm_ToolLast) then
      SendMessage(
        LOWORD(SendMessage(ClientWnd^.hWindow, WM_MDIGETACTIVE, 0, 0)),
        ms_GraphicTool, wParam, 0)
    else if (wParam>=cm_FileList) and (wParam<=cm_FileListEnd)
    then PostMessage( hWindow, ms_FileList, wParam, lParam )
    else inherited WMCommand(Msg);
end;

procedure tMainWindow.msGetEleFile(var Msg : tMessage);
function IsSameName(p : pEleFile) : Boolean; far;
begin
  IsSameName := StrIComp(p^.Name, pChar(Msg.lParam)) = 0;
end;
begin
  case Msg.wParam of
    0 : Msg.Result := Longint(EleFiles);
    1 : Msg.Result := Longint(EleFiles^.At(Msg.lParam));
    2 : Msg.Result := Longint(EleFiles^.FirstThat(@IsSameName));
  end;
end;

procedure tMainWindow.msChildMenuPos(var Msg : tMessage);
begin
  inc(ChildMenuPos, Integer(Msg.wParam));
end;

procedure tMainWindow.msLoadFile(var Msg : tMessage);
var
{$ifdef decode}
  f, i, j : Integer;
  str : array [0..personlength] of char;
  str_, buf : pChar;
  b : Boolean;
{$endif}
  S : pStream;
  Cursor : hCursor;
  p : pWindowEx;
begin
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
{$ifdef decode}
  b := TRUE;
  f := _lopen(pChar(Msg.lParam), OF_READ);
  _lread(f, @str, 6);
  if StrLComp(@str, 'PERSON', 6) = 0
  then begin
    GetMem(buf, $1000);
    _lread(f, @str, personlength);
    for j:=0 to personlength-1 do
      str[j] := char(byte(str[j]) xor byte(perkey[j and $0007]));
{$ifndef master}
    if StrLComp(@str, @person_, personlength) = 0
    then begin
{$else}
    if StrLComp(@str, @person_, personlength) <> 0
    then begin
      str_ := @str;
      wvsprintf(@String1, LoadString0(32543), str_);
      MessageBox(hWindow, @String1, LoadString0(15), MB_ICONSTOP or MB_OK);
    end;
    b := True;
{$endif}
      S:=New(pGlobalStream, Init);
      i := $1000;
      while i=$1000
      do begin
        i:=_lread(f, buf, $1000);
        for j:=0 to i-1 do
          buf[j]:=char(byte(buf[j]) xor byte(str[j and $000f]));
        S^.Write(buf^, i);
      end;
      S^.Seek(0);
      _lclose(f);
{$ifndef master}
    end
    else begin
      str_ := @str;
      wvsprintf(@String1, LoadString0(32543), str_);
      MessageBox(hWindow, @String1, LoadString0(15), MB_ICONSTOP or MB_OK);
      b := FALSE;
    end;
{$endif}
    FreeMem(buf, $1000);
  end
  else S:=New(pDOSStream, Init(pChar(Msg.lParam), stOpenRead));
  _lclose(f);
  if b
  then begin
{$else}
  S:=New(pDOSStream, Init(pChar(Msg.lParam), stOpenRead));
{$endif}
  if S^.status = stOk
  then begin
    if Msg.wParam=0
    then Msg.wParam := GetFileType(pChar(Msg.lParam));
    case Msg.wParam of
      1 : p := New(pLayoutWindow, Init(@Self));
{$ifdef elewin}
      2 : p := New(pElementsWindow, Init(@Self));
{$endif}
      else p := nil;
    end;
    if p = nil
    then UserMessage_(hWindow, 8, -1, mb_IconStop + mb_OK)
    else begin
      LockSpeedbar;
      LockWindowUpdate(ClientWnd^.hWindow);
      NewWin(p);
      p^.Load(S^);
      SendMessage( p^.hWindow, ms_SetCaption, 0, Msg.lParam );
      AddFileList(pChar(Msg.lParam));
      LockWindowUpdate(0);
      UnlockSpeedbar;
    end;
    Dispose(S, Done);
    Msg.Result := Longint(p);
{$ifdef decode}
    end; {of if b}
{$endif}
    SetCursor(Cursor);
  end { S.status = stOk }
  else begin
    { Beim Öffnen der Datei trat ein Fehler auf. }
    UserMessage_( hWindow, 27, -1, MB_OK or mb_ICONSTOP );
    Dispose(S, Done);
  end;
end;

procedure tMainWindow.NewWin(p : pWindowsObject);
var
  b : Boolean;
begin
  b := SendMessage(ClientWnd^.hWindow, wm_MDIGetActive, 0, 0) > $0000ffff;
  Application^.MakeWindow(p);
  if b then SendMessage(ClientWnd^.hWindow, wm_MDIMaximize, p^.hWindow, 0);
end;

procedure tMainWindow.msNewWin(var Msg : tMessage);
begin
  NewWin(pWindowsObject(Msg.lParam));
end;

procedure tMainWindow.cmCreateLayWin(var Msg : tMessage);
begin
  NewWin(New(pLayoutWindow, Init(@Self)));
end;

{$ifdef elewin}
procedure tMainWindow.cmCreateEleWin(var Msg : tMessage);
begin
  NewWin(New(pElementsWindow, Init(@Self)));
end;
{$endif}

procedure tMainWindow.cmFileOpen(var Msg : tMessage);
var
  Cursor : hCursor;
  p : pWindowEx;
  S : tDosStream;
  DialogTitle, FileName : tFileName;
  s_, s__ : pChar;
begin
  { Info. }
  GetMem(s_, StrLen(LoadString1(1025)) + 4);
  StrCopy(s_, @String1);
  StrCat(s_, '...');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);

  with FileStruct
  do begin
    hWndOwner := hMainWin;
    LPstrFile := FileName;
    nMaxFile := MaxFileNameLen;
    LPStrTitle := LoadString0(32);
    lPStrFileTitle := DialogTitle;
    nMaxFileTitle := MaxFileNameLen;
    lPStrDefExt := 'CIR';
    nFilterIndex := ext_LAY;
    Flags := {ofn_ShowHelp or} ofn_EnableTemplate or ofn_FileMustExist;
    FileName[0] := #0;
    if GetOpenFileName(FileStruct)
    then begin
      { Info. }
      GetMem(s_, StrLen(LoadString1(1025)) + StrLen(lPStrFile) + 4);
      StrCopy(s_, @String1);
      StrCat(s_, '''');
      StrCat(s_, lPStrFile);
      StrCat(s_, '''.');
      SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
      StrDispose(s_);

      SendMessage(hWindow, ms_LoadFile, nFilterIndex, Longint(lPStrFile));
    end;
  end;
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.msSave(var Msg : tMessage);
var
{$ifdef encode}
  f, i, j : Integer;
  per_ : array [0..personlength] of char;
  buf : pChar;
  S : tGlobalStream;
{$else}
  S : tDOSStream;
{$endif}
  FileName : tFileName;
  Cursor : hCursor;
  s_ : pChar;
begin
{$ifdef test}
  if shareware
  then SendMessage(hMainWin, wm_Command, cm_About, 0);
{$endif}
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  GetWindowText(Msg.wParam, @FileName, MaxFileNameLen);

  { Info. }
  GetMem(s_, StrLen(LoadString1(1026)) + StrLen(FileName) + 4);
  StrCopy(s_, @String1);
  StrCat(s_, '''');
  StrCat(s_, @FileName);
  StrCat(s_, '''.');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);

{$ifdef encode}
  S.Init;
{$else}
  S.Init(@FileName, stCreate);
{$endif}
  SendMessage(Msg.wParam, ms_Store, 0, Longint(@S));
{$ifdef encode}
  f:=_lcreat(@FileName, 0);
  _lwrite(f, 'PERSON', 6);
  move(person_, per_, personlength);
  for j:=0 to personlength-1 do
    per_[j] := char(byte(per_[j]) xor byte(perkey[j and $0007]));
  _lwrite(f, @per_, personlength);
  GetMem(buf, $1000);
  S.Seek(0);
  while (S.GetPos+$1000)<S.GetSize
  do begin
    S.Read(buf[0], $1000);
    for j:=0 to $0fff do
      buf[j] := char(byte(buf[j]) xor byte(person_[j and $000f]));
    _lwrite(f, buf, $1000);
  end;
  i:=S.GetSize-S.GetPos;
  S.Read(buf[0], i);
  for j:=0 to i-1 do
    buf[j] := char(byte(buf[j]) xor byte(person_[j and $000f]));
  _lwrite(f, buf, i);
  FreeMem(buf, $1000);
  _lclose(f);
{$endif}
  S.Done;
  SetCursor(Cursor);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmSave(var Msg : tMessage);
begin
  SendMessage(
    hWindow, ms_Save,
    LoWord(SendMessage(ClientWnd^.hWindow, wm_MDIGetActive, 0, 0)), 0);
end;

procedure tMainWindow.msSaveAs(var Msg : tMessage);
{ wParam - Extension, lParam - Zeiger. }
var
  Cursor : hCursor;
  S : pStream;
  p : pWindowEx;
  DialogTitle, FileName : tFileName;
  s_ : pChar;
begin
  { Info. }
  if WordBool(Msg.wParam and ext_FileExport)
  then LoadString1(1039)
  else LoadString1(1026);
  GetMem(s_, StrLen(@String1) + 4);
  StrCopy(s_, @String1);
  StrCat(s_, '...');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);

  with FileStruct
  do begin
    hWndOwner := hMainWin;
    LPstrFile := FileName;
    nMaxFile := MaxFileNameLen;
    if WordBool(Msg.wParam and ext_FileExport)
    then LPStrTitle := LoadString0(41)
    else LPStrTitle := LoadString0(33);
    lPStrFileTitle := DialogTitle;
    nMaxFileTitle := MaxFileNameLen;
    nFilterIndex := Msg.wParam and ext_First;
    lPStrDefExt := extName[nFilterIndex];
    Flags := ofn_EnableTemplate or ofn_NoReadOnlyReturn or
             ofn_OverwritePrompt or ofn_HideReadOnly;
  end;
  FileName[0] := #0;
  with FileStruct do
    if GetSaveFileName(FileStruct)
    then begin
      Cursor := SetCursor(LoadCursor(0, idc_Wait));

      { Info. }
      if WordBool(Msg.wParam and ext_FileExport)
      then LoadString1(1039)
      else LoadString1(1026);
      GetMem(s_, StrLen(@String1) + StrLen(lPStrFile) + 4);
      StrCopy(s_, @String1);
      StrCat(s_, '''');
      StrCat(s_, lPStrFile);
      StrCat(s_, '''.');
      SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
      StrDispose(s_);

      if WordBool(Msg.wParam and ext_FileExport)
      then SendMessage(
             Msg.lParamLo, ms_Export, nFilterIndex, Longint(lPStrFile))
      else begin
        SendMessage(
          Msg.lParamLo, ms_SetCaption, 0, longint(lpStrFile) );
        SendMessage(hWindow, ms_Save, Msg.lParamLo, 0);
        AddFileList(lpStrFile);
      end;
      SetCursor(Cursor);
    end;
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmPrintDlg(var Msg : tMEssage);
begin
  Printer^.Setup(@Self);
end;

procedure tMainWindow.cmPrint(var Msg : tMessage);
var
  MDIActive : tHandle;
  s, s_ : pChar;
begin
  { Info. }
  GetMem(s, StrLen(LoadString1(1029)) + 4);
  StrCopy(s, @String1);
  StrCat(s, '...');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s));
  StrDispose(s);
  MDIActive := LoWord(SendMessage(ClientWnd^.hWindow, wm_MDIGetActive, 0, 0));
  GetMem(s_, GetWindowTextLength(MDIActive) + 1);
  GetWindowText(MDIActive, s_, $7fff);
  GetMem(s, StrLen(LoadString1(1029)) + StrLen(s_) + 4);
  StrCopy(s, @String1);
  StrCat(s,'''');
  StrCat(s, s_);
  StrCat(s, '''.');
  StrDispose(s_);
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s));
  StrDispose(s);
  SendMessage(MDIActive, ms_Print, 0, Longint(Printer));
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmEleFiles(var Msg : tMessage);
begin
  SendMessage(hWindow, ms_UpdateInfo, 1030, 0);
  Application^.ExecDialog(New(pEleFilesDlg, Init(@Self)));
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.ChangeIniFile( s : pChar );
var
  s_ : tString;
begin
  StrDispose(IniFile);
  IniFile := StrNew(s);
  StrCopy(@s_, LoadString0(21));
  StrCat(@s_, s);
  StrCat(@s_, LoadString0(22));
  ModifyMenu(
    Attr.Menu, cm_SaveOpt, mf_ByCommand + mf_Enabled,
    cm_SaveOpt, @s_);
end;

procedure tMainWindow.cmLoadOpt(var Msg : tMessage);
var
  Cursor : hCursor;
  S : tDosStream;
  DialogTitle, FileName : tFileName;
  s_ : pChar;
begin
  { Info. }
  GetMem(s_, StrLen(LoadString1(1027)) + 4);
  StrCopy(s_, @String1);
  StrCat(s_, '...');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);

  with FileStruct
  do begin
    hWndOwner := hMainWin;
    LPstrFile := FileName;
    nMaxFile := MaxFileNameLen;
    LPStrTitle := LoadString0(35);
    lPStrFileTitle := DialogTitle;
    nMaxFileTitle := MaxFileNameLen;
    lPStrDefExt := 'INI';
    nFilterIndex := ext_OPT;
    Flags := ofn_EnableTemplate or ofn_FileMustExist;
  end;
  FileName[0] := #0;
  if GetOpenFileName(FileStruct)
  then begin
    if FileStruct.nFilterIndex = ext_OPT
    then begin
      { Info. }
      GetMem(
        s_, StrLen(LoadString1(1027)) + StrLen(FileStruct.lPStrFile) + 4);
      StrCopy(s_, @String1);
      StrCat(s_, '''');
      StrCat(s_, FileStruct.lPStrFile);
      StrCat(s_, '''.');
      SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
      StrDispose(s_);
      Cursor := SetCursor(LoadCursor(0, idc_Wait));
      CloseChildren;
      EleFiles^.FreeAll;
      LoadIni(FileStruct.lPStrFile);
      ChangeIniFile(FileStruct.lPStrFile);
      SetCursor(Cursor);
    end
    else UserMessage_(hWindow, 36, -1, mb_IconStop + mb_OK);
  end;
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmSaveAsOpt(var Msg : tMessage);
var
  DialogTitle, FileName : tFileName;
  s_ : pChar;
begin
  { Info. }
  GetMem(s_, StrLen(LoadString1(1028)) + 4);
  StrCopy(s_, @String1);
  StrCat(s_, '...');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);
  with FileStruct
  do begin
    hWndOwner := hMainWin;
    LPstrFile := FileName;
    nMaxFile := MaxFileNameLen;
    LPStrTitle := LoadString0(37);
    lPStrFileTitle := DialogTitle;
    nMaxFileTitle := MaxFileNameLen;
    lPStrDefExt := 'INI';
    nFilterIndex := ext_OPT;
    Flags := ofn_EnableTemplate or ofn_NoReadOnlyReturn or
             ofn_OverwritePrompt or ofn_HideReadOnly;
  end;
  FileName[0] := #0;
  with FileStruct do
    if GetSaveFileName(FileStruct)
    then begin
      if nFilterIndex = ext_OPT
      then begin
        ChangeIniFile(lPStrFile);
        cmSaveOpt(Msg);
      end
      else UserMessage_(hWindow, 36, -1, mb_IconStop + mb_OK);
    end;
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmSaveOpt(var Msg : tMessage);
var
  Cursor : hCursor;
begin
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  SaveIni;
  SetCursor(Cursor);
end;

procedure tMainWindow.SaveIni;
var
  i : Integer;
  s : array [0..100] of char;
  s_ : pChar;
procedure DoWriteIni(p:pEleFile); far;
begin
  p^.WriteIni(IniFile, i);
  inc(i);
end;
begin
  { Info. }
  GetMem(s_, StrLen(LoadString0(1028)) + StrLen(IniFile) + 4);
  StrCopy(s_, @String0);
  StrCat(s_, '''');
  StrCat(s_, IniFile);
  StrCat(s_, '''.');
  SendMessage(hWindow, ms_UpdateInfo, 0, Longint(s_));
  StrDispose(s_);

  { Version. }
  WritePrivateProfileString('VERSION', 'version', LoKon_Version, IniFile );
  WritePrivateProfileString('VERSION', 'date', LoKon_Date, IniFile );
  { Element-Files abspeichern. }
  WritePrivateProfileString('ELEMENT-FILES', nil, nil, IniFile);
  i:=EleFiles^.Count;
  wvsprintf(@s, '%i', i);
  WritePrivateProfileString('ELEMENT-FILES', 'Number', s, IniFile);
  i:=1;
  EleFiles^.ForEach(@DoWriteIni);

  { Einstellungen speichern. }
  if MessageOn
  then WritePrivateProfileString('GENERAL', 'Messages', 'on', IniFile)
  else WritePrivateProfileString('GENERAL', 'Messages', 'off', IniFile);
  if xCollision
  then WritePrivateProfileString('GENERAL', 'Collision', 'on', IniFile)
  else WritePrivateProfileString('GENERAL', 'Collision', 'off', IniFile);
  wvsprintf(@s, '%u', TickTime);
  WritePrivateProfileString('TIMER', 'Time', s, IniFile);
  if TickOn
  then WritePrivateProfileString('TIMER', 'State', 'on', IniFile)
  else WritePrivateProfileString('TIMER', 'State', 'off', IniFile);
  i := xRaster;
  wvsprintf(@s, '%i', xRaster);
  WritePrivateProfileString('RASTER', 'Type', s, IniFile);
  if xRasterFront
  then WritePrivateProfileString('RASTER', 'Position', 'front', IniFile)
  else WritePrivateProfileString('RASTER', 'Position', 'back', IniFile);
  if xShowInOut
  then WritePrivateProfileString('GENERAL', 'ShowInOut', 'on', IniFile)
  else WritePrivateProfileString('GENERAL', 'ShowInOut', 'off', IniFile);
  if xConBW
  then WritePrivateProfileString('GENERAL', 'Connections', 'thick/thin', IniFile)
  else WritePrivateProfileString('GENERAL', 'Connections', 'color', IniFile);
{$ifdef undo}
  if xUndo
  then WritePrivateProfileString('GENERAL', 'Undo', 'true', IniFile)
  else WritePrivateProfileString('GENERAL', 'Undo', 'false', IniFile);
{$endif}
  wvsprintf(@s, '%i', RasterPos);
  WritePrivateProfileString('RASTER', 'Positioning', s, IniFile);
  with FontDataOpt
  do begin
    i:=Height;
    wvsprintf(@s, '%i', i);
    WritePrivateProfileString('FONT', 'Height', s, IniFile);
    i:=Width;
    wvsprintf(@s, '%i', i);
    WritePrivateProfileString('FONT', 'Width', s, IniFile);
    i:=Direct;
    wvsprintf(@s, '%i', i);
    WritePrivateProfileString('FONT', 'Direction', s, IniFile);
    i:=FontNr;
    wvsprintf(@s, '%i', i);
    WritePrivateProfileString('FONT', 'Number', s, IniFile);
    i:=FontFlag;
    wvsprintf(@s, '%i', i);
    WritePrivateProfileString('FONT', 'Flag', s, IniFile);
  end;

  WritePrivateProfileString('REG', 'name', @person, IniFile);
  wvsprintf(s, '%i', codel);
  WritePrivateProfileString('REG', 'codel', s, IniFile);
  wvsprintf(s, '%i', codeh);
  WritePrivateProfileString('REG', 'codeh', s, IniFile);

  SaveAlwaysToINI;

  { Info. }
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.SaveAlwaysToINI;
var
  i : integer;
  Menu_ : hMenu;
begin
  Menu_ := GetSubMenu( Attr.Menu, MenuInc );
  for i := 0 to FileListMax
  do begin
    GetMenuString(
      Menu_, FileListPos+i,
      @String1, StringLen, MF_BYPOSITION);
    wvsprintf(@String0, 'file%0i', i);
    WritePrivateProfileString('FILE_MENU', @String0, @String1, IniFile);
  end;
end;

procedure tMainWindow.cmMessageOn(var Msg : tMessage);
begin
  MessageOn := not MessageOn;
  if MessageOn
  then CheckMenuItem(Attr.Menu, cm_MessageOn, mf_ByCommand or mf_Checked)
  else CheckMenuItem(Attr.Menu, cm_MessageOn, mf_ByCommand or mf_UnChecked);
end;

procedure tMainWindow.cmCollision(var Msg : tMessage);
begin
  xCollision := not xCollision;
  if xCollision
  then CheckMenuItem(Attr.Menu, cm_Collision, mf_ByCommand or mf_Checked)
  else CheckMenuItem(Attr.Menu, cm_Collision, mf_ByCommand or mf_UnChecked);
end;

procedure tMainWindow.cmTick(var Msg : tMessage);
begin
  SendMessage(hWindow, ms_UpdateInfo, 1031, 0);
  KillTimer(hWindow, id_TickTimer);
  Application^.ExecDialog(New(pTickDlg, Init(@Self, @TickTime)));
  if TickOn
  then begin
    SetTimer(hWindow, id_TickTimer, TickTime, nil);
    EnableMenuItem(Attr.Menu, cm_ManuelTick, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_ManuelTick);
  end
  else begin
    EnableMenuItem(Attr.Menu, cm_ManuelTick, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_ManuelTick);
  end;
  DrawMenuBar(hWindow);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmOptROff(var Msg : tMessage);
begin
  CheckMenuItem(
    Attr.Menu, cm_OptROff + xRaster, mf_ByCommand or mf_Unchecked);
  xRaster := 0;
  CheckMenuItem(
    Attr.Menu, cm_OptROff, mf_ByCommand or mf_Checked);
end;

procedure tMainWindow.cmOptRBig(var Msg : tMessage);
begin
  CheckMenuItem(
    Attr.Menu, cm_OptROff + xRaster, mf_ByCommand or mf_Unchecked);
  xRaster := 1;
  CheckMenuItem(
    Attr.Menu, cm_OptRBig, mf_ByCommand or mf_Checked);
end;

procedure tMainWindow.cmOptRSmall(var Msg : tMessage);
begin
  CheckMenuItem(
    Attr.Menu, cm_OptROff + xRaster, mf_ByCommand or mf_Unchecked);
  xRaster := 2;
  CheckMenuItem(
    Attr.Menu, cm_OptRSmall, mf_ByCommand or mf_Checked);
end;

procedure tMainWindow.cmOptRFront(var Msg : tMessage);
begin
  xRasterFront := True;
  ModifyMenu(
    Attr.Menu, cm_OptRFront, mf_ByCommand,
    cm_OptRBack, LoadString0(18));
end;

procedure tMainWindow.cmOptRBack(var Msg : tMessage);
begin
  xRasterFront := False;
  ModifyMenu(
    Attr.Menu, cm_OptRBack, mf_ByCommand,
    cm_OptRFront, LoadString0(19));
end;

procedure tMainWindow.cmOptShowInOut(var Msg : tMessage);
begin
  xShowInOut := not xShowInOut;
  if xShowInOut
  then
    CheckMenuItem(Attr.Menu, cm_OptShowInOut, mf_ByCommand or mf_Checked)
  else
    CheckMenuItem(Attr.Menu, cm_OptShowInOut, mf_ByCommand or mf_Unchecked);
end;

procedure tMainWindow.cmOptConBW(var Msg : tMessage);
begin
  xConBW := not xConBW;
  if xConBW
  then
    CheckMenuItem(Attr.Menu, cm_OptConBW, mf_ByCommand or mf_Checked)
  else
    CheckMenuItem(Attr.Menu, cm_OptConBW, mf_ByCommand or mf_Unchecked);
  if xConBW
  then begin
    OnPen := OnPenBW;
    OffPen := OffPenBW;
  end
  else begin
    OnPen := OnPenCol;
    OffPen := OffPenCol;
  end;
end;

procedure tMainWindow.cmOptFont(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pFontDialog, Init(@Self, @FontDataOpt)));
end;

procedure tMainWindow.cmOptRasterPos(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pNrDlg, Init(@Self, @RasterPos, 14)));
  if RasterPos<=0 then RasterPos := 1;
end;

procedure tMainWindow.wmTimer(var Msg : tMessage);
procedure DoTick(p : pWindowsObject); far;
begin
  SendMessage(p^.hWindow, ms_Tick, 0, 0);
end;
begin
  ForEach(@DoTick);
end;

procedure tMainWindow.cmManuelTick(var Msg : tMessage);
begin
  wmTimer(Msg);
end;

procedure tMainWindow.msUpdateInfo(var Msg : tMessage);
{$ifdef showres}
var
  s : array [0..50] of char;
  w1, w2 : Word;
{$endif}
begin
{$ifdef showres}
  w1 := GetFreeSystemResources(1);
  w2 := GetFreeSystemResources(2);
  wvsprintf(@s, 'GDI: %u  USER: %u', w1);
  StrLCopy(@Info, @s, StringLen);
  InfoRes := -1;
  InfoPaint;
{$else}
  with Msg do
    if lParam = 0
    then begin
      { wParam ist nicht Stringnummer. }
      if wParam <> InfoRes
      then begin
        if wParam = 0
        then begin
          Pos[0] := #0;
          StrCopy(@Info, LoadString0(1024));
        end
        else StrCopy(@Info, LoadString0(wParam));
        InfoRes := wParam;
        InfoPaint;
      end;
    end
    else begin
      { lParam ist Stringzeiger }
      StrLCopy(@Info, pChar(lParam), StringLen);
      InfoRes := -1;
      InfoPaint;
    end;
{$endif}
end;

procedure tMainWindow.msUpdatePos(var Msg : tMessage);
begin
  wvsprintf(@Pos, ' ( %i, %i )', tPoint(Msg.lParam));
  PosPaint;
end;

procedure tMainWindow.msGetInfoStr(var Msg : tMessage);
begin
  Msg.Result := Longint(@Info);
end;

procedure tMainWindow.wmMouseMove(var Msg : tMessage);
var
  R, R_ : tRect;
  PaintDC, MemoryDC : hDC;
  bmp : hBitmap;
begin
  if DragState=DR_SPEEDBUTTON
  then begin
    ClientToScreen(hWindow, tPoint(Msg.lParam));
    GetWindowRect(hWindow, R);
    R_:=pDRSpeedButton(DragInfo)^.R;
    dec(R_.left, R.left);
    dec(R_.top, R.top);
    if PtInRect(pDRSpeedButton(DragInfo)^.R, tPoint(Msg.lParam))
    then begin
      if not pDRSpeedButton(DragInfo)^.clicked
      then begin
        PaintDC:=GetWindowDC(hWindow);
        MemoryDC:=CreateCompatibleDC(PaintDC);
        bmp:=LoadBitmap(hRes, 'SPEEDBAR_BUTTOND');
        SelectObject(MemoryDC, bmp);
        BitBlt(PaintDC, R_.left, R_.top, 24, 18, MemoryDC, 0, 0, SRCCOPY);
        bmp:=LoadBitmap(hRes, MAKEINTRESOURCE(speedb^[pDRSPEEDBUTTON(DragInfo)^.idx]));
        DeleteObject(SelectObject(MemoryDC, bmp));
        BitBlt(PaintDC, R_.left+2, R_.top+2, 21, 16, MemoryDC, 0, 0, SRCCOPY);
        DeleteDC(MemoryDC);
        DeleteObject(bmp);
        ReleaseDC(hWindow, PaintDC);
        pDRSPEEDBUTTON(DragInfo)^.clicked:=TRUE;
      end;
    end
    else begin
      if pDRSPEEDBUTTON(DragInfo)^.clicked
      then begin
        PaintDC:=GetWindowDC(hWindow);
        MemoryDC:=CreateCompatibleDC(PaintDC);
        bmp:=LoadBitmap(hRes, 'SPEEDBAR_BUTTON');
        SelectObject(MemoryDC, bmp);
        BitBlt(PaintDC, R_.left, R_.top, 24, 18, MemoryDC, 0, 0, SRCCOPY);
        bmp:=LoadBitmap(hRes, MAKEINTRESOURCE(speedb^[pDRSPEEDBUTTON(DragInfo)^.idx]));
        DeleteObject(SelectObject(MemoryDC, bmp));
        BitBlt(PaintDC, R_.left+1, R_.top+1, 21, 16, MemoryDC, 0, 0, SRCCOPY);
        DeleteDC(MemoryDC);
        DeleteObject(bmp);
        ReleaseDC(hWindow, PaintDC);
        pDRSPEEDBUTTON(DragInfo)^.clicked:=FALSE;
      end;
    end;
  end
  else DefWndProc(Msg);
end;

procedure tMainWindow.wmLButtonUp(var Msg : tMessage);
begin
  if DragState=DR_SPEEDBUTTON
  then begin
    pDRSPEEDBUTTON(DragInfo)^.clicked:=TRUE;
    SendMessage(hWindow, wm_MouseMove, 0, $ffffffff);
    ClientToScreen(hWindow, tPoint(Msg.lParam));
    if PtInRect(pDRSPEEDBUTTON(DragInfo)^.R, tPoint(Msg.lParam))
    then PostMessage(hWindow, wm_Command, speedb^[pDRSPEEDBUTTON(DragInfo)^.idx], $00020000);
    FreeMem(DragInfo, sizeof(tDRSpeedButton));
    ReleaseCapture;
    DragState:=DR_NONE;
  end
  else DefWndProc(Msg);
end;

procedure tMainWindow.wmNCLButtonDown(var Msg : tMessage);
var
  i, left : Integer;
  R_, R : tRect;
begin
  if Msg.wParam=HTSpeedbar
  then begin
    GetSpeedbarRect(R);
    GetWindowRect(hWindow, R_);
    OffsetRect(R, R_.left, R_.top);
    inc(R.left, 4);
    left := R.left;
    i:=0;
    while i<bnum
    do begin
      with tPoint(Msg.lParam) do
        if (x>=R.left) and (x<R.left+24) and (y>=R.top) and (y<R.top+19)
        then Break;
      if (speedb^[i] div 20)<>(speedb^[i+1] div 20)
      then inc(R.left, 8);
      inc(R.left, 24);
      if R.left>(R.right-24) { neue Zeile }
      then begin
        R.left := left;
        inc(R.top, 19);
      end;
      inc(i);
    end;
    if (i<bnum) and WordBool(activeb^[i] and SBActive_)
    then begin
      GetMem(DragInfo, SizeOf(tDRSpeedButton));
      R.right:=R.left+24;
      R.bottom:=R.top+18;
      pDRSPEEDBUTTON(DragInfo)^.R:=R;
      pDRSPEEDBUTTON(DragInfo)^.idx:=i;
      pDRSPEEDBUTTON(DragInfo)^.clicked:=False;
      DragState:=DR_SPEEDBUTTON;
      SetCapture(hWindow);
      ScreenToClient(hWindow, tPoint(Msg.lParam));
      SendMessage(hWindow, wm_MouseMove, 0, Msg.lParam);
    end;
  end
  else DefWndProc(Msg);
end;

procedure tMainWindow.WMGetMinMaxInfo(var Msg : tMessage);
begin
  DefWndProc(Msg);
  with tMinMaxInfo(Pointer(Msg.lParam)^).ptMinTrackSize
  do begin
    x := 260;
    y := 200;
  end;
end;

procedure tMainWindow.wmNCCalcSize(var Msg : tMessage);
var
  R, R_ : tRect;
  cx, cy,
  cm : Integer;
begin
  { Die Meldung zunächst von Windows bearbeiten lassen. }
  DefWndProc(Msg);
  if not IsIconic(hWindow)
  then begin
    R_ := pRect(Msg.lParam)^;
    GetSpeedbarRect_(R_);
    inc(pRect(Msg.lParam)^.Top, R_.bottom-R_.top); { Speedbar. }
    dec(pRect(Msg.lParam)^.Bottom, GetSystemMetrics(15{sm_cyMenu})); {Status.}
  end;
end;

procedure tMainWindow.wmNCHitTest(var Msg : tMessage);
var
  WndR, R : tRect;
begin
  GetWindowRect(hWindow, WndR);
  GetStatusRect(R);
  R.left := R.left + WndR.left;
  R.right := R.right + WndR.left;
  R.top := R.top + WndR.top;
  R.bottom := R.bottom + WndR.top;
  if (PtInRect(R, MAKEPOINT(Msg.lParam)))
  then Msg.Result := HTStatus
  else begin
    GetSpeedbarRect(R);
    OffsetRect(R, WndR.left, WndR.top);
    if (PtInRect(R, MAKEPOINT(Msg.lParam)))
    then Msg.Result := HTSpeedbar
    else DefWndProc(Msg);
  end;
end;

procedure tMainWindow.GetStatusRect(var R : tRect);
var
  cx, cy, cm,
  W, H : Integer;
begin
  GetWindowRect(hWindow, R);
  cx:=GetSystemMetrics(SM_CXFRAME);
  cy:=GetSystemMetrics(SM_CYFRAME);
  cm:=GetSystemMetrics(SM_CYMENU);
  W:=R.right-R.left;
  H:=R.bottom-R.top;
  R.left:=cx;
  R.top:=H-cy-cm;
  R.right:=W-cx;
  R.bottom:=H-cy;
end;

procedure tMainWindow.GetSpeedbarRect_(var R : tRect);
var
  i,
  left, l_ : Integer;
begin
  R.bottom:=R.top+19;
  l_ := R.left;
  inc(l_, 4);
  left := l_;
  for i:=0 to bnum-1
  do begin
    if (speedb^[i] div 20) <> (speedb^[i+1] div 20)
    then inc(l_, 8);
    inc(l_, 24);
    if (l_>(R.right-24)) and (i<bnum-1) { neue Zeile }
    then begin
      l_ := left;
      inc(R.bottom, 19);
    end;
  end;
end;

procedure tMainWindow.GetSpeedbarRect(var R : tRect);
begin
  GetWindowRect(hWindow, R);
  OffsetRect(R, -R.left, -R.top);
  DefWindowProc ( hWindow, WM_NCCALCSIZE, 0, Longint(@R) );
  GetSpeedBarRect_(R);
end;

procedure tMainWindow.msSpeedbar(var Msg : tMessage);
var i : Integer;
begin
  with Msg do
    case wParam of
      SBInsert : InsertSpeedbutton(lParamLo, lParamHi);
      SBDelete : DeleteSpeedbutton(lParamLo);
      SBActivate :
        begin
          i:=0;
          while (speedb^[i]<>lParamLo) and (i<bnum) do inc(i);
          if i<bnum then activeb^[i] := lParamHi;
        end;
      SBGrayed :
        begin
          i:=0;
          while (speedb^[i]<lParamLo) and (i<bnum) do inc(i);
          while (speedb^[i]<=lParamHi) and (i<bnum)
          do begin
            activeb^[i] := activeb^[i] and (not SBActive_);
            inc(i);
          end;
        end;
      SBEnabled :
        begin
          i:=0;
          while (speedb^[i]<lParamLo) and (i<bnum) do inc(i);
          while (speedb^[i]<=lParamHi) and (i<bnum)
          do begin
            activeb^[i] := activeb^[i] or SBActive_;
            inc(i);
          end;
        end;
    end;
end;

procedure tMainWindow.InsertSpeedbutton(Num, Act : Integer);
var
  i : Integer;
  newb, newa : pIntegerArray;
begin
  GetMem(newb, (bnum+1)*sizeof(Integer));
  GetMem(newa, (bnum+1)*sizeof(Integer));
  i:=0;
  while (i<bnum) and (speedb^[i]<num) do inc(i);
  move(speedb^, newb^, i*sizeof(Integer));
  move(activeb^, newa^, i*sizeof(Integer));
  newb^[i]:=num;
  newa^[i]:=act;
  move(speedb^[i], newb^[i+1], (bnum-i)*sizeof(Integer));
  move(activeb^[i], newa^[i+1], (bnum-i)*sizeof(Integer));
  FreeMem(speedb, bnum*SizeOf(Integer));
  FreeMem(activeb, bnum*SizeOf(Integer));
  speedb:=newb;
  activeb:=newa;
  inc(bnum);
end;

procedure tMainWindow.DeleteSpeedbutton(Num : Integer);
var
  i : Integer;
  newb, newa : pIntegerArray;
begin
  i:=0;
  while (speedb^[i]<>num) and (i<bnum) do inc(i);
  if i<bnum
  then begin
    GetMem(newb, (bnum-1)*sizeof(Integer));
    GetMem(newa, (bnum-1)*sizeof(Integer));
    move(speedb^, newb^, i*sizeof(Integer));
    move(activeb^, newa^, i*sizeof(Integer));
    move(speedb^[i+1], newb^[i], (bnum-i-1)*sizeof(Integer));
    move(activeb^[i+1], newa^[i], (bnum-i-1)*sizeof(Integer));
    FreeMem(speedb, bnum*SizeOf(Integer));
    FreeMem(activeb, bnum*SizeOf(Integer));
    speedb:=newb;
    activeb:=newa;
    dec(bnum);
  end;
end;

procedure tMainWindow.InfoPaint;
var
  R : tRect;
  W, H,
  cx, cy,
  cm : Integer;
  PaintDC : hDC;
begin
  { Info darstellen. }
  GetWindowRect(hWindow, R);
  with R
  do begin
    W := Right - Left;
    H := Bottom - Top;
  end;
  PaintDC := GetWindowDC(hWindow);
  SelectObject(PaintDC, GetStockObject(LTGRAY_BRUSH));
  cx := GetSystemMetrics(32{sm_cxFrame});
  cy := GetSystemMetrics(33{sm_cyFrame});
  cm := GetSystemMetrics(15{sm_cyMenu});
  SetRect(R, cx, H - (cy+cm), W - cx - 120, H - cy);
  with R
  do begin
    Rectangle(PaintDC, Left, Top, Right, Bottom);
    InflateRect(R, -1, -1);
    SetBKColor(PaintDC, GetSysColor(COLOR_SCROLLBAR));
    ExtTextOut(
      PaintDC, Left, Top, eto_Clipped, @R,
      @Info, StrLen(@Info), nil);
  end;
  ReleaseDC(hWindow, PaintDC);
end;

procedure tMainWindow.PosPaint;
var
  R : tRect;
  W, H,
  cx, cy,
  cm : Integer;
  PaintDC : hDC;
begin
  { Pos darstellen. }
  GetWindowRect(hWindow, R);
  with R
  do begin
    W := Right - Left;
    H := Bottom - Top;
  end;
  PaintDC := GetWindowDC(hWindow);
  SelectObject(PaintDC, GetStockObject(LTGRAY_BRUSH));
  cx := GetSystemMetrics(32{sm_cxFrame});
  cy := GetSystemMetrics(33{sm_cyFrame});
  cm := GetSystemMetrics(15{sm_cyMenu});
  SetRect(R, W-cx-120, H - (cy+cm), W - cx, H - cy);
  with R
  do begin
    Rectangle(PaintDC, Left, Top, Right, Bottom);
    InflateRect(R, -1, -1);
    SetBKColor(PaintDC, GetSysColor(COLOR_SCROLLBAR));
    ExtTextOut(
      PaintDC, Left, Top, eto_Clipped, @R,
      @Pos, StrLen(@Pos), nil);
  end;
  ReleaseDC(hWindow, PaintDC);
end;

procedure tMainWindow.wmNCPaint(var Msg : tMessage);
begin
  DefWndProc(Msg);
  if not IsIconic(hWindow)
  then begin
    PaintSpeedbar;
    InfoPaint;
    PosPaint;
  end;
end;

procedure tMainWindow.PaintSpeedbar;
var
  i : Integer;
  R : tRect;
  left : Integer;
  PaintDC,
  backDC,
  grayedDC,
  MemoryDC : hDC;
  backbmp,
  downbmp,
  grayedbmp,
  bmp : hBitmap;
begin
  if updatesb
  then begin
    PaintDC := GetWindowDC(hWindow);
    GetSpeedbarRect(R);
    SelectObject ( PaintDC, GetStockObject(LTGRAY_BRUSH) );
    left := R.top + 19;
    while left <= R.bottom
    do begin
      Rectangle ( PaintDC, R.left-1, left-20, R.right+1, left );
      inc(left, 19);
    end;
    backDC := CreateCompatibleDC(PaintDC);
    backbmp := LoadBitmap (hRes, 'SPEEDBAR_BUTTON');
    downbmp := LoadBitmap (hRes, 'SPEEDBAR_BUTTOND');
    grayedbmp := LoadBitmap (hRes, 'SPEEDBAR_GRAYED');
    grayedDC := CreateCompatibleDC (PaintDC);
    SelectObject ( grayedDC, grayedbmp );
    MemoryDC := CreateCompatibleDC (PaintDC);
    inc(R.left, 4);
    left := R.left;
    for i:=0 to bnum-1
    do begin
      if WordBool(activeb^[i] and SBDown_)
      then SelectObject ( backDC, downbmp )
      else SelectObject ( backDC, backbmp );
      BitBlt ( PaintDC, R.left, R.top, 24, 18, backDC, 0, 0, SRCCOPY );
      bmp := LoadBitmap (hRes, MAKEINTRESOURCE(speedb^[i]));
      DeleteObject(SelectObject ( MemoryDC, bmp ));
      if WordBool(activeb^[i] and SBDown_)
      then BitBlt ( PaintDC, R.left+2, R.top+2, 21, 16, MemoryDC, 0, 0, SRCCOPY )
      else BitBlt ( PaintDC, R.left+1, R.top+1, 21, 16, MemoryDC, 0, 0, SRCCOPY );
      if (activeb^[i] and SBActive_)=0
      then BitBlt(PaintDC, R.left+1, R.top+1, 21, 16, grayedDC, 0, 0, SRCINVERT);
      if (speedb^[i] div 20) <> (speedb^[i+1] div 20)
      then inc(R.left, 8);
      inc(R.left, 24);
      if R.left>(R.right-24) { neue Zeile }
      then begin
        R.left := left;
        inc(R.top, 19);
      end;
    end;
    DeleteDC (MemoryDC);
    DeleteObject(bmp);
    DeleteDC (grayedDC);
    DeleteObject (grayedbmp);
    DeleteDC (backDC);
    DeleteObject (backbmp);
    DeleteObject (downbmp);
    ReleaseDC (hWindow, PaintDC);
  end;
end;

type
  pAboutDlg = ^tAboutDlg;
  tAboutDlg = object (tDialogEx)
    procedure SetupWindow; virtual;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;
  tAboutWVS = record
    s1, s2 : Pointer;
  end;


procedure tAboutDlg.SetupWindow;
var
  ItemHandle : hWnd;
  AboutWVS : tAboutWVS;
begin
  inherited SetupWindow;
{$ifdef test}
  SetDlgItemText(hWindow, 100, @person);
{$endif}
  GetWindowText( hWindow, @String0, StringLen );
  SetWindowText( hWindow, strcat( @String0, LoKon_Version ) );
  ItemHandle := GetItemHandle( 199 );
  GetWindowText( ItemHandle, @String0, StringLen );
  with AboutWVS
  do begin
    s1 := @LoKon_Version;
    s2 := @LoKon_Date;
  end;
  wvsprintf( @String1, @String0, AboutWVS );
  SetWindowText( ItemHandle, @String1 );
end;

procedure tAboutDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hWindow, 'LOKON.HLP', HELP_CONTEXT, 103);
end;

procedure tMainWindow.cmAbout(var Msg : tMessage);
begin
{$ifdef test}
  if shareware
  then Application^.ExecDialog(New(pDialogEx, Init(@Self, 'SHAREDLG')));
{$endif}
  Application^.ExecDialog(New(pAboutDlg, Init(@Self, 'ABOUTDLG')));
end;

procedure tMainWindow.cmHelpContents(var Msg : tMessage);
begin
  SendMessage(hWindow, ms_UpdateInfo, 1032, 0);
  WinHelp(hWindow, 'LOKON.HLP', HELP_CONTENTS, 0);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmHelpContext(var Msg : tMessage);
var w : Word;
begin
  SendMessage(hWindow, ms_UpdateInfo, 1032, 0);
  w := LOWORD(SendMessage(ClientWnd^.hWindow, WM_MDIGETACTIVE, 0, 0));
  if w <> 0
  then SendMessage (w, WM_COMMAND, CM_HELPCONTEXT, 0)
  else WinHelp(hWindow, 'LOKON.HLP', HELP_CONTEXT, 103);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmHelpOnHelp(var Msg : tMessage);
begin
  SendMessage(hWindow, ms_UpdateInfo, 1032, 0);
  WinHelp(hWindow, 'LOKON.HLP', HELP_HELPONHELP, cs_Info);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

procedure tMainWindow.cmHowToDo(var Msg : tMessage);
begin
  SendMessage(hWindow, ms_UpdateInfo, 1032, 0);
  WinHelp(hWindow, 'LOKON.HLP', HELP_CONTEXT, 900);
  SendMessage(hWindow, ms_UpdateInfo, 0, 0);
end;

{$ifdef test}
type
  pRegisterDlg = ^tRegisterDlg;
  tRegisterDlg = object (tDialogEx)
    IniFile : pChar;
    constructor Init(xParent : pWindowsObject; xIniFile : pChar);
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tRegisterDlg.Init(xParent : pWindowsObject; xIniFile : pChar);
begin
  inherited Init( xParent, 'REGISTRATION' );
  IniFile := xIniFile;
end;

procedure tRegisterDlg.OK(var Msg : tMessage);
var
  code : tPoint;
  translated : Bool;
begin
  GetDlgItemText(hWindow, 101, @person, personlength);
  WritePrivateProfileString('REG', 'name', @person, IniFile );
  with code
  do begin
    x := GetDlgItemInt(hWindow, 102, translated, false);
    y := GetDlgItemInt(hWindow, 103, translated, false);
    wvsprintf( @String0, '%i', x );
    WritePrivateProfileString( 'REG', 'codel', @String0, IniFile );
    wvsprintf( @String0, '%i', y );
    WritePrivateProfileString( 'REG', 'codeh', @String0, IniFile );
  end;
  EndDlg(id_OK);
end;

procedure tMainWindow.cmRegister(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pRegisterDlg, Init(@Self, IniFile)));
end;

procedure tMainWindow.msFileList( var Msg : tMessage );
var
  s : tString;
begin
  GetMenuString(Attr.Menu, Msg.wParam, @s, StringLen, MF_BYCOMMAND);
  SendMessage(hWindow, ms_LoadFile, 0, longint(@s));
end;

procedure tMainWindow.AddFileList( s : pChar );
var
  s_ : tString;
  i : integer;
  Menu_ : hMenu;
  b : Boolean;
begin
  if GetFileType(s) > 0
  then begin
    b := true;
    Menu_ := GetSubMenu(Attr.Menu, MenuInc);
    { Falls Eintrag schon vorhanden, }
    for i := 0 to FileListMax
    do begin
      GetMenuString(
        Menu_, cm_FileList + i,
        @s_, StringLen, MF_BYCOMMAND );
      if StrComp( s, @s_ ) = 0
      then begin
        { diesen an erste Stelle setzen. }
        DeleteMenu( Menu_, cm_FileList+i, MF_BYCOMMAND );
        InsertMenu(
          Menu_, FileListPos, MF_BYPOSITION,
          cm_FileList+i, s);
        b := false;
      end;
    end;
    if b
    then begin
      { Freie cm_ID suchen. }
      i := 0;
      while GetMenuString(
        Menu_, cm_FileList+i, @s_,
        StringLen, MF_BYCOMMAND ) > 0
      do inc(i);
      { Falls zu viele Einträge, den letzten löschen. }
      if i > FileListMax
      then begin
        i := GetMenuItemID(Menu_, FileListPos+FileListMax)-cm_FileList;
        DeleteMenu( Menu_, FileListPos+FileListMax, MF_BYPOSITION );
      end;
      InsertMenu(
        Menu_, FileListPos, MF_BYPOSITION,
        cm_FileList+i, s);
    end;
  end;
end;

procedure tMainWindow.cmResetFileMenu(var Msg : tMessage);
var
  i : integer;
begin
    for i := 0 to FileListMax
    do DeleteMenu( Attr.Menu, cm_FileList+i, MF_BYCOMMAND );
end;

procedure tMainWindow.msIsShown(var Msg : tMessage);
function IsShown(p : pWindow) : Boolean; far;
begin
  IsShown :=
    SendMessage(p^.hWindow, ms_IsShown, Msg.wParam, Msg.lParam) <> Longint(nil);
end;
begin
  Msg.Result := longint( FirstThat(@IsShown) );
end;

{$endif}

{$ifdef layele}
procedure tMainWindow.msNewMacroIO(var Msg : tMessage);
{ In Msg.lParam steht der Zeiger auf das Makro Element. }
var
  p : pWindow;
begin
  p := New( pMacroWindow, Init( @Self, pMacroEle(Msg.lParam) ) );
  SendMessage( hMainWin, ms_NewWin, 0, longint(p) );
  ShowWindow( p^.hWindow, SW_HIDE );
  Msg.Result := p^.hWindow;
end;
{$endif}

{$ifdef osc}
procedure tMainWindow.cmShowAllOscWin(var Msg : tMessage);
procedure DoShowOscWin( p : pWindow ); far;
begin
  SendMessage( p^.hWindow, ms_ShowOscWin, 0, 0 );
end;
begin
  ForEach(@DoShowOscWin);
end;

procedure tMainWindow.cmHideAllOscWin(var Msg : tMessage);
procedure DoHideOscWin( p : pWindow ); far;
begin
  SendMessage( p^.hWindow, ms_HideOscWin, 0, 0 );
end;
begin
  ForEach(@DoHideOscWin);
end;
{$endif}

{$ifdef layele}
procedure tMainWindow.cmShowAllMacros(var Msg : tMessage);
procedure DoShowMacroWin( p : pWindow ); far;
begin
  SendMessage( p^.hWindow, ms_ShowMacroWin, 0, 0 );
end;
begin
  ForEach(@DoShowMacroWin);
end;

procedure tMainWindow.cmHideAllMacros(var Msg : tMessage);
procedure DoHideMacroWin( p : pWindow ); far;
begin
  SendMessage( p^.hWindow, ms_HideMacroWin, 0, 0 );
end;
begin
  ForEach(@DoHideMacroWin);
end;
{$endif}

procedure tMainWindow.LockSpeedbar;
begin
  updatesb := false;
end;

procedure tMainWindow.UnlockSpeedbar;
begin
  updatesb := true;
  PaintSpeedbar;
end;

procedure tMainWindow.cmZoomAllWin(var Msg : tMessage);
procedure DoZoomAll( p : pWindow ); far;
begin
  if IsWindowVIsible(p^.hWindow) then
    SendMessage( p^.hWindow, ms_ZoomAll, 0, 0 );
end;
begin
  ForEach( @DoZoomAll );
end;

procedure tMainWindow.msLockSpeedbar( var Msg : tMessage );
begin
  if boolean(Msg.wParam)
  then LockSpeedbar
  else UnlockSpeedbar;
end;

{$ifdef undo}
procedure tMainWindow.wmCompacting( var Msg : tMessage );
procedure DoFreeUndo( p : pWindow ); far;
begin
  SendMessage( p^.hWindow, ms_FreeUndo, 0, 0 );
end;
begin
  ForEach( @DoFreeUndo );
end;

procedure tMainWindow.cmOptUndo( var Msg : tMessage );
begin
  xUndo := not xUndo;
  if xUndo
  then CheckMenuItem(Attr.Menu, cm_OptUndo, mf_ByCommand or mf_Checked)
  else CheckMenuItem(Attr.Menu, cm_OptUndo, mf_ByCommand or mf_UnChecked);
  SendMessage( hWindow, WM_Compacting, 0, 0 );
end;
{$endif}

end.
