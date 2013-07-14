unit EleWin;
{$I define.inc}

interface

uses
  Strings, Messages,
  Objects,
  WinTypes, WinProcs,
  OWindows, ODialogs,
  LK_Const,
  OWinEx,
  Paint,
  LayWin,
{$ifdef layele}
  MacroWin,
{$endif}
  Element;

const
  id_ListBox      =  100;

type
  pElementsWindow = ^tElementsWindow;
  tElementsWindow = object (tWindowEx)
    ElementList : pCollection;
    NotClose,
    NameEx : Boolean;
    IdxCaret : Integer;
    constructor Init(aParent : pWindowsObject);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var aWndClass : tWndClass); virtual;
    function CanClose : Boolean; virtual;
    procedure MDI_Act; virtual;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure msNotClose(var Msg : tMessage);
      virtual ms_NotClose;
    procedure SetElement(i : Integer);
    procedure SetEleNr(p : pChapEle);
    procedure AtInsertEle_(i : Integer; xElement : pChapEle);
    procedure AtInsertEle(i : Integer; xElement : pChapEle);
    procedure InsertElement(xElement : pChapEle);
    procedure AtDeleteEle_(i : Integer);
    procedure AtFreeEle_(i : Integer);
    procedure AtFreeEle(i : Integer);
    procedure wmSize(var Msg : tMessage);
      virtual wm_First + wm_Size;
    procedure wmCommand(var Msg : tMessage);
      virtual wm_First + wm_Command;
    procedure cmNewTabEle(var Msg : tMessage);
      virtual cm_First + cm_NewTabEle;
    procedure cmNewBoolEle(var Msg : tMessage);
      virtual cm_First + cm_NewBoolEle;
{$ifdef layele}
    procedure cmNewMacroEle(var Msg : tMessage);
      virtual cm_First + cm_NewMacroEle;
{$endif}
    procedure cmRenameEle(var Msg : tMessage);
      virtual cm_First + cm_RenameEle;
    procedure cmDelEle(var Msg : tMessage);
      virtual cm_First + cm_DelEle;
    procedure cmChangeNr(var Msg : tMessage);
      virtual cm_First + cm_ChangeNr;
    procedure cmNewChap(var Msg : tMessage);
      virtual cm_First + cm_NewChap;
    procedure cmEleGraphic(var Msg : tMessage);
      virtual cm_First + cm_EleGraphic;
    procedure cmEleRegion(var Msg : tMessage);
      virtual cm_First + cm_EleRegion;
    procedure cmEleInOut(var Msg : tMessage);
      virtual cm_First + cm_EleInOut;
    procedure cmDelEleInOut(var Msg : tMessage);
      virtual cm_First + cm_DelEleInOut;
    procedure cmEleInit(var Msg : tMessage);
      virtual cm_First + cm_EleInit;
    procedure cmGrInOut(var Msg : tMessage);
      virtual cm_First + cm_GrInOut;
    procedure msGetContext(var Msg : tMessage);
      virtual ms_GetContext;
    procedure cmFileSaveAs(var Msg : tMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure cmEditCopy(var Msg : tMessage);
      virtual cm_First + cm_EditCopy;
    procedure cmEditDelete(var Msg : tMessage);
      virtual cm_First + cm_EditDelete;
    procedure cmEditCut(var Msg : tMessage);
      virtual cm_First + cm_EditCut;
    procedure cmEditPaste(var Msg : tMessage);
      virtual cm_First + cm_EditPaste;
    procedure cmHelpContext(var Msg : tMessage);
      virtual cm_First + cm_HelpContext;
{$ifdef layele}
    procedure msMacroInOut(var Msg : tMessage);
      virtual ms_MacroInOut;
    procedure cmUpdateEle(var Msg : tMessage);
      virtual cm_First + cm_UpdateEle;
{$endif}
  end;

implementation

{ ------ tElementsWindow ------------------------------------------------ }

constructor tElementsWindow.Init(aParent : pWindowsObject);
var p : pWindowsObject;
begin
  inherited Init(aParent, LoadString0(6));
  p := New(pListBox__, Init(@Self, id_ListBox, 0, 0, 99, 99));
  ElementList := New(pCollection, Init(20, 20));
  NotClose := False;
  NameEx := False;
  IdxCaret := 0;
end;

destructor tElementsWindow.Done;
procedure DoDestroy(p : pWindowsObject); far;
begin
  SendMessage(p^.hWindow, ms_EleWin, ew_Destroy, Longint(@Self));
end;
begin
  { Zu EleWin gehörende Fenster zerstören. }
  (Application^.MainWindow)^.ForEach(@DoDestroy);
  { Den Rest zerstören. }
  Dispose(ElementList, Done);
  inherited Done;
end;

procedure tElementsWindow.SetupWindow;
begin
  inherited SetupWindow;
  SendDlgItemMessage(
    hWindow, id_ListBox, lb_InsertString, 0, Longint(LoadString0(117)));
  SendDlgItemMessage(hWindow, id_ListBox, lb_SetCaretIndex, IdxCaret, 0);
end;

procedure tElementsWindow.Load(var S : tStream);
procedure DoListBox(p : pElement); far;
begin
  InsertElement(p);
end;
var EleColl : tCollection;
begin
  with EleColl
  do begin
    Load(S);
    ForEach(@DoListBox);
    DeleteAll;
    Done;
  end;
  S.Read(IdxCaret, SizeOf(IdxCaret));
  SetElement(IdxCaret);
  NameEx := True;
  NotClose := False;
  MDI_Act;
end;

procedure tElementsWindow.Store(var S : tStream);
procedure DoNotClose(p : pWindowsObject); far;
begin
  SendMessage(p^.hWindow, ms_EleWin, ew_EleWinStored, Longint(@Self));
end;
begin
{$ifdef test}
  if not expired
  then begin
{$endif}
  ElementList^.Store(S); { Wichtig : Zuerst die Collection speichern ! }
  S.Write(IdxCaret, SizeOf(IdxCaret));
  NotClose := False;
  Application^.MainWindow^.ForEach(@DoNotClose);
  NameEx := True;
  MDI_Act;
{$ifdef test}
  end
  else begin
  SendMessage(hMainWin, wm_Command, cm_About, 0);
  end;
{$endif}
end;

procedure tElementsWindow.GetWindowClass(var aWndClass : tWndClass);
begin
  inherited GetWindowClass(aWndClass);
  with aWndClass
  do begin
    Style := Style or $08{cs_DblClk};
    hIcon := LoadIcon(hRes, 'ELEICON');
  end;
end;

function tElementsWindow.GetClassName: PChar;
begin
  GetClassName := 'LK_EleWin';
end;

function tElementsWindow.CanClose : Boolean;
function DoNotClose(p : pWindowsObject) : Boolean; far;
begin
  if LongBool(SendMessage(
       p^.hWindow, ms_EleWin, ew_NotClose, Longint(@Self)))
  then DoNotClose := True
  else DoNotClose := False;
end;
var
  s, s_ : pChar;
  i : Integer;
begin
  if NotClose or
     (Application^.MainWindow^.FirstThat(@DoNotClose) <> nil)
  then begin
    i := GetWindowTextLength(hWindow);
    GetMem(s_, i+1);
    GetWindowText(hWindow, s_, i+1);
    GetMem(s, StrLen(LoadString0(81)) + i - 1 {+1-2});
    wvsprintf(s, @String0, s_);
    StrDispose(s_);
    case MessageBox(
           hWindow, s, LoadString0(96),
           mb_IconQuestion or mb_YesNoCancel)
    of
      id_Yes :
        begin
          SendMessage(hMainWin, ms_Save, hWindow, 0);
          CanClose := True;
        end;
      id_No : CanClose := True;
      else CanClose := False;
    end;
    StrDispose(s);
  end
  else CanClose := True;
end;

procedure tElementsWindow.msNotClose(var Msg : tMessage);
begin
  NotClose := True;
end;

procedure tElementsWindow.SetElement(i : Integer);
begin
  SendDlgItemMessage(hWindow, id_ListBox, lb_SetCaretIndex, Word(i), 0);
  IdxCaret := i;
  MDI_Act;
end;

procedure tElementsWindow.SetEleNr(p : pChapEle);
procedure DoNr(p_ : pChapEle); far;
begin
  if p_^.Nr >= p^.Nr then p^.Nr := p_^.Nr + 1;
end;
begin
  if p^.Nr = -1
  then begin
    p^.Nr := 0;
    ElementList^.ForEach(@DoNr);
  end;
end;

procedure tElementsWindow.AtInsertEle_(i : Integer; xElement : pChapEle);
var s : pChar;
begin
  SetEleNr(xElement);
  with xElement^ do
    if Name[0] = #1
    then begin
      GetMem(s, StrLen(Name) + 6{-1+6+1});
      wvsprintf(s, '%04i: ', xElement^.Nr);
      StrCat(s, @Name[1]);
      SendDlgItemMessage(
        hWindow, id_ListBox, lb_InsertString, i, Longint(s));
      StrDispose(s);
    end
    else begin
      GetMem(s, StrLen(Name) + 10{+6+3+1});
      wvsprintf(s, '%04i:    ', xElement^.Nr);
      StrCat(s, Name);
      SendDlgItemMessage(
        hWindow, id_ListBox, lb_InsertString, i, Longint(s));
      StrDispose(s);
    end;
  ElementList^.AtInsert(i-1, xElement);
  NotClose := True;
end;

procedure tElementsWindow.AtInsertEle(i : Integer; xElement : pChapEle);
begin
  AtInsertEle_(i, xElement);
  SetElement(i);
end;

procedure tElementsWindow.InsertElement(xElement : pChapEle);
begin
  AtInsertEle_(ElementList^.Count+1, xElement);
end;

procedure tElementsWindow.AtDeleteEle_(i : Integer);
var Idx : Integer;
procedure DoDestroy(p : pWindowsObject); far;
begin
  SendMessage(p^.hWindow, ms_EleWin, Idx, Longint(@Self));
end;
begin
  Idx := pChapEle(ElementList^.At(i-1))^.Nr;
  Application^.MainWindow^.ForEach(@DoDestroy);
  ElementList^.AtDelete(i-1);
  NotClose := True;
end;

procedure tElementsWindow.AtFreeEle_(i : Integer);
var Idx : Integer;
procedure DoDestroy(p : pWindowsObject); far;
begin
  SendMessage(p^.hWindow, ms_EleWin, Idx, Longint(@Self));
end;
begin
  Idx := pChapEle(ElementList^.At(i-1))^.Nr;
  Application^.MainWindow^.ForEach(@DoDestroy);
  ElementList^.AtFree(i-1);
  NotClose := True;
end;

procedure tElementsWindow.AtFreeEle(i : Integer);
begin
  AtFreeEle_(i);
  SendDlgItemMessage(hWindow, id_ListBox, lb_DeleteString, i, 0);
  if i>ElementList^.Count then dec(i);
  SetElement(i);
end;

procedure tElementsWindow.wmSize(var Msg : tMessage);
var R : tRect;
begin
  GetClientRect(hWindow, R);
  with R do
    MoveWindow(
      GetDlgItem(hWindow, id_ListBox), 0, 0, Right, Bottom, True);
  inherited wmSize(Msg);
end;

procedure tElementsWindow.cmNewTabEle(var Msg : tMessage);
var s : tInputStr;
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1033, 0);
  s[0] := #0;
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @s, 113, InputStrLen))) = id_OK
  then AtInsertEle(IdxCaret+1, New(pTabEle, Init(@s)));
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmNewBoolEle(var Msg : tMessage);
var s : tInputStr;
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1039, 0);
  s[0] := #0;
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @s, 113, InputStrLen))) = id_OK
  then AtInsertEle(IdxCaret+1, New(pBoolEle, Init(@s)));
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

{$ifdef layele}
procedure tElementsWindow.cmNewMacroEle(var Msg : tMessage);
var s : tInputStr;
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1042, 0);
  s[0] := #0;
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @s, 113, InputStrLen))) = id_OK
  then AtInsertEle(IdxCaret+1, New(pMacroEle, Init(@s)));
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;
{$endif}

procedure tElementsWindow.cmRenameEle(var Msg : tMessage);
var
  p : pChapEle;
  s : tInputStr1;
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1034, 0);
  p := pChapEle(ElementList^.At(IdxCaret-1));
  StrCopy(@s, p^.Name);
  { Achtung: Hier NUR LAZY EVALUATION. }
  if ((s[0] = #1) and
      (Application^.ExecDialog(
         New(pTextDlg, Init(@Self, @(s[1]), 116, InputStrLen))) = id_OK)) or
     (Application^.ExecDialog(
        New(pTextDlg, Init(@Self, @s, 115, InputStrLen))) = id_OK)
  then begin
    p^.ChangeName(@s);
    AtDeleteEle_(IdxCaret);
    SendDlgItemMessage(hWindow, id_ListBox, lb_DeleteString, IdxCaret, 0);
    AtInsertEle(IdxCaret, p);
  end;
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmDelEle(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1035, 0);
  AtFreeEle(IdxCaret);
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmChangeNr(var Msg : tMessage);
var p : pChapEle;
begin
  p := pChapEle(ElementList^.At(IdxCaret-1));
  Application^.ExecDialog(
    New(pNrDlg, Init(@Self, @(p^.Nr), 42)));
  AtDeleteEle_(IdxCaret);
  SendDlgItemMessage(hWindow, id_ListBox, lb_DeleteString, IdxCaret, 0);
  AtInsertEle(IdxCaret, p);
end;

procedure tElementsWindow.cmNewChap(var Msg : tMessage);
var Input : tInputStr1;
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1036, 0);
  Input[1] := #0;
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @(Input[1]), 114, InputStrLen))) = id_OK
  then begin
    Input[0] := #1;
    AtInsertEle(IdxCaret+1, New(pChapEle, Init(@Input)));
  end;
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmEleGraphic(var Msg : tMessage);
var
  p : pChapEle;
begin
  if IdxCaret > 0
  then begin
    p := pChapEle(ElementList^.At(IdxCaret-1));
    if p^.Name[0] <> #1
    then begin
      SendMessage(hMainWin, ms_UpdateInfo, 1037, 0);
      pElement(p)^.ChangeGraphic(@Self);
      SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
    end;
  end;
end;

procedure tElementsWindow.cmEleRegion(var Msg : tMessage);
var
  p : pChapEle;
begin
  if IdxCaret > 0
  then begin
    p := pChapEle(ElementList^.At(IdxCaret-1));
    if p^.Name[0] <> #1
    then begin
      SendMessage(hMainWin, ms_UpdateInfo, 1041, 0);
      pElement(p)^.ChangeRegion(@Self);
      SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
    end;
  end;
end;

procedure tElementsWindow.cmEleInOut(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1038, 0);
  pElement(ElementList^.At(IdxCaret-1))^.ChangeInOut(@Self);
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmDelEleInOut(var Msg : tMessage);
begin
  pElement(ElementList^.At(IdxCaret-1))^.DelInOut;
  NotClose := true;
end;

procedure tElementsWindow.cmEleInit(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_UpdateInfo, 1040, 0);
  pElement(ElementList^.At(IdxCaret-1))^.ChangeInit(@Self);
  SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
end;

procedure tElementsWindow.cmGrInOut(var Msg : tMessage);
begin
  pElement(ElementList^.At(IdxCaret-1))^.ChangeInOutPos(@Self);
end;

procedure tElementsWindow.wmCommand(var Msg : tMessage);
begin
  case Msg.lParamHi of
    cbn_SelChange :
      SetElement(
        SendDlgItemMessage(hWindow, Msg.wParam, lb_GetCaretIndex, 0, 0));
    cbn_DblClk : SendMessage(hWindow, wm_Command, cm_EleGraphic, 0);
    else inherited wmCommand(Msg);
  end;
end;

procedure tElementsWindow.MDI_Act;
var
  Menu : hMenu;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  (*EnableMenuItem(Menu, cm_Print, mf_ByCommand or mf_Enabled);*)
  EnableMenuItem(Menu, cm_FileSaveAs, mf_ByCommand or mf_Enabled);
  SendMessage(hMainWin, ms_ChildMenuPos, +1, 0);
  if NameEx
  then begin
    EnableMenuItem(Menu, cm_FileSave, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_FileSave);
  end
  else begin
    EnableMenuItem(Menu, cm_FileSave, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_FileSave);
  end;
  { Edit. }
  if SendDlgItemMessage(hWindow, id_ListBox, lb_GetSelCount, 0, 0) > 0
  then begin
    EnableMenuItem(Menu, cm_EditCopy, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_EditDelete, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_EditCut, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditCopy);
  end
  else begin
    EnableMenuItem(Menu, cm_EditCopy, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditDelete, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditCut, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EditCopy);
  end;
  if IsClipboardFormatAvailable(cf_Element)
  then begin
    EnableMenuItem(Menu, cm_EditPaste, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditPaste);
  end
  else begin
    EnableMenuItem(Menu, cm_EditPaste, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EditPaste);
  end;
  { Element. }
  if IdxCaret <= 0
  then begin
    EnableMenuItem(Menu, cm_RenameEle, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_DelEle, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_ChangeNr, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_EleGraphic, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_EleRegion, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_EleInOut, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_DelEleInOut, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_EleInit, mf_ByCommand + mf_Grayed);
    EnableMenuItem(Menu, cm_GrInOut, mf_ByCommand + mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleGraphic);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleRegion);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_GrInOut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleInOut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleInit);
  end
  else begin
    EnableMenuItem(Menu, cm_RenameEle, mf_ByCommand + mf_Enabled);
    EnableMenuItem(Menu, cm_DelEle, mf_ByCommand + mf_Enabled);
    EnableMenuItem(Menu, cm_ChangeNr, mf_ByCommand + mf_Enabled);
    if pChapEle(ElementList^.At(IdxCaret-1))^.Name[0]=#1
    then begin
      EnableMenuItem(Menu, cm_EleGraphic, mf_ByCommand + mf_Grayed);
      EnableMenuItem(Menu, cm_EleRegion, mf_ByCommand + mf_Grayed);
      EnableMenuItem(Menu, cm_EleInOut, mf_ByCommand + mf_Grayed);
      EnableMenuItem(Menu, cm_DelEleInOut, mf_ByCommand + mf_Grayed);
      EnableMenuItem(Menu, cm_EleInit, mf_ByCommand + mf_Grayed);
      EnableMenuItem(Menu, cm_GrInOut, mf_ByCommand + mf_Grayed);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleGraphic);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleRegion);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_GrInOut);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleInOut);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EleInit);
    end
    else begin
      EnableMenuItem(Menu, cm_EleGraphic, mf_ByCommand + mf_Enabled);
      EnableMenuItem(Menu, cm_EleRegion, mf_ByCommand + mf_Enabled);
      EnableMenuItem(Menu, cm_EleInOut, mf_ByCommand + mf_Enabled);
      EnableMenuItem(Menu, cm_DelEleInOut, mf_ByCommand + mf_Enabled);
      EnableMenuItem(Menu, cm_EleInit, mf_ByCommand + mf_Enabled);
      EnableMenuItem(Menu, cm_GrInOut, mf_ByCommand + mf_Enabled);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EleGraphic);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EleRegion);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_GrInOut);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EleInOut);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EleInit);
    end;
  end;
  DrawMenuBar(hMainWin);
end;

procedure tElementsWindow.MDI_Menu(b : Boolean);
begin
  with pWindow(Application^.MainWindow)^.Attr
  do begin
    if b
    then begin
      InsertMenu(Menu, 2 + MenuInc,
        mf_Enabled + mf_ByPosition + mf_Popup,
        LoadMenu(hRes, 'ELEMENU'), LoadString0(112));
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditCut);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditCopy);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditPaste);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_NewTabEle);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_NewBoolEle);
{$ifdef layele}
      SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_NewMacroEle);
{$endif}
      SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_NewChap);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EleGraphic);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EleRegion);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_GrInOut);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EleInOut);
      SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EleInit);
      SendDlgItemMessage(hWindow, id_ListBox, lb_SetCaretIndex, IdxCaret, 0);
      MDI_Act;
    end
    else begin
      DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
      RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditCut);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditCopy);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditPaste);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_NewTabEle);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_NewBoolEle);
{$ifdef layele}
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_NewMacroEle);
{$endif}
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_NewChap);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EleGraphic);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EleRegion);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_GrInOut);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EleInOut);
      SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EleInit);
      SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_FileSave);
      SendMessage(hMainWin, ms_ChildMenuPos, Word(-1), 0);
      SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
      DrawMenuBar(hMainWin);
    end;
  end;
end;

procedure tElementsWindow.msGetContext(var Msg : tMessage);
begin
  Msg.Result := cs_EleWin;
end;

procedure tElementsWindow.cmFileSaveAs(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_SaveAs, ext_ELE, hWindow);
end;

procedure tElementsWindow.cmEditCopy(var Msg : tMessage);
var
  S : tGlobalStream;
  i, l : Integer;
  Items, p : pIntegerArray;
begin
  l := SendDlgItemMessage(hWindow, id_ListBox, lb_GetSelCount, 0, 0);
  GetMem(Items, l * SizeOf(Integer));
  SendDlgItemMessage(hWindow, id_ListBox, lb_GetSelItems, l, Longint(Items));
  if Items^[0]=0
  then begin
    GetMem(p, (l-1)*SizeOf(Integer));
    Move(Items^[1], p^, (l-1)*SizeOf(Integer));
    FreeMem(Items, l*SizeOf(Integer));
    Items:=p;
    dec(l);
  end;
  S.Init;
  S.Write(l, SizeOf(Integer));
  for i := 0 to l-1 do
    S.Put(ElementList^.At(Items^[i]-1));
  FreeMem(Items, l * SizeOf(Integer));
  OpenClipboard(hWindow);
  EmptyClipboard;
  SetClipboardData(cf_Element, S.Handle);
  CloseClipboard;
  S.Done_; { Der Handle wird nicht freigegeben. }
  MDI_Act;
end;

procedure tElementsWindow.cmEditDelete(var Msg : tMessage);
var
  l : Integer;
  Items : pIntegerArray;
begin
  l := SendDlgItemMessage(hWindow, id_ListBox, lb_GetSelCount, 0, 0);
  GetMem(Items, l * SizeOf(Integer));
  SendDlgItemMessage(
    hWindow, id_ListBox, lb_GetSelItems, l, Longint(Items));
  while l > 0
  do begin
    dec(l);
    AtFreeEle_(Items^[l]);
    SendDlgItemMessage(
      hWindow, id_ListBox, lb_DeleteString, Items^[l], 0);
  end;
  if Items^[0] > ElementList^.Count
  then SetElement(Items^[0]-1)
  else SetElement(Items^[0]);
  FreeMem(Items, l * SizeOf(Integer));
  MDI_Act;
end;

procedure tElementsWindow.cmEditCut(var Msg : tMessage);
begin
  SendMessage(hWindow, wm_Command, cm_EditCopy, 0);
  SendMessage(hWindow, wm_Command, cm_EditDelete, 0);
end;

procedure tElementsWindow.cmEditPaste(var Msg : tMessage);
var
  S : tGlobalStream;
  l : Integer;
  p : pChapEle;
begin
  S.Init;
  OpenClipboard(hWindow);
  S.Handle := GetClipboardData(cf_Element);
  CloseClipboard;
  S.Read(l, SizeOf(Integer));
  inc(IdxCaret);
  while l > 0
  do begin
    p := pChapEle(S.Get);
    p^.Nr := -1;
    AtInsertEle_(IdxCaret, p);
    inc(IdxCaret);
    dec(l);
  end;
  dec(IdxCaret);
  S.Done_; { Der Handle wird nicht freigegeben. }
  MDI_Act;
end;

procedure tElementsWindow.cmHelpContext(var Msg : tMessage);
begin
  WinHelp(hWindow, 'LOKON.HLP', HELP_CONTEXT, 500);
end;

{$ifdef layele}
procedure tElementsWindow.msMacroInOut(var Msg : tMessage);
{ In Msg.lParam steht der Zeiger auf das Makro Element. }
var
  p : pWindow;
begin
  p := pWindow( SendMessage (
                  hMainWin, ms_IsShown, hWindow,
                  longint( pElement(Msg.lParam)^.Name ) ) );
  if p = nil
  then begin
    p := New( pMacroWindow, Init( @Self, pMacroEle(Msg.lParam) ) );
    SendMessage(
      hMainWin, ms_NewWin, 0,
      longint(p) );
    ShowWindow( p^.hWindow, SW_SHOWNORMAL );
    NotClose := true;
  end
  else SetFocus(p^.hWindow);
end;
{$endif}

{$ifdef layele}
procedure tElementsWindow.cmUpdateEle(var Msg : tMessage);
begin
  MessageBox( hWindow, 'Update', nil, mb_ok ); (**)
end;
{$endif}

end.