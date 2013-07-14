unit LayWin;
{$I define.inc}

interface

uses
  Objects, Messages,
  WinTypes, WinProcs,
  Strings,
  OWindows, ODialogs,
  CommDlg,
  LK_Const,
  OWinEx,
  ScrolOrg, Paint,
  EleFile,
  Element,
  Switch, ZeroOne,
  Item, EleItem,
  ItemText, Bitmap,
  Tick,
{$ifdef ROMRAM}
  ROMRAM,
{$endif}
{$ifdef PLA}
  PLA,
{$endif}
{$ifdef osc}
  OscWin,
{$endif}
  Connect, ConNode,
  EleWinCh,
  Impulse;

type
  pLayoutWindow = ^tLayoutWindow;
  tLayoutWindow = object ( tEleWinChild )
    Lay : tLay;
    EditLayout,
    Impulses : pCollection;
    ShowInOut,
    TestInit, TestOn : Boolean;
    ActItem : pItem;
    OldEleFile : Integer;
    NameEx : Boolean;
    SavePos : tPosition;
{$ifdef osc}
    OscWin : pOscilloscopeWindow;
{$endif}
    constructor Init(aParent : pWindowsObject);
    destructor Done; virtual;
{$ifdef osc}
    procedure SetupWindow; virtual;
{$endif}
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    procedure MDI_Act; virtual;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure GetWindowClass(var aWndClass : tWndClass); virtual;
    function GetClassName: PChar; virtual;
    function CanClose : Boolean; virtual;
    procedure EndDrag;
    procedure msDelInsItem(var Msg : tMessage);
      virtual ms_DelInsItem;
    procedure cmShowInOut(var Msg : tMessage);
      virtual cm_First + cm_ShowInOut;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure msZoomAll(var Msg : tMessage);
      virtual ms_ZoomAll;
    procedure SetActItem(p : pItem);
    procedure SetMenuActItem;
    procedure cmGate(var Msg : tMessage);
      virtual cm_First + cm_Gate;
    procedure cmActItem(var Msg : tMessage);
      virtual cm_First + cm_ActItem;
    procedure InitItem(p : pItem);
    procedure cmConNode(var Msg : tMessage);
      virtual cm_First + cm_ConNode;
    procedure cmSwitch(var Msg : tMessage);
      virtual cm_First + cm_Switch;
    procedure cmZero(var Msg : tMessage);
      virtual cm_First + cm_Zero;
    procedure cmOne(var Msg : tMessage);
      virtual cm_First + cm_One;
    procedure cmTickEle(var Msg : tMessage);
      virtual cm_First + cm_TickEle;
    function GetItem(Pos : tPoint) : pItem;
    procedure SetCursorOfState(xState : Integer); virtual;
    procedure WMMouseMove(var Msg : tMessage);
      virtual wm_First + wm_MouseMove;
    function TouchItem(p : pItem) : Boolean;
    procedure DeleteItem(p : pItem);
    procedure InsertItem(p : pItem; PaintDC : hDC);
    procedure lsNone(A : tPoint; b : Integer);
    procedure WMLButtonDown(var Msg : tMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMRButtonDown(var Msg : tMessage);
      virtual wm_First + wm_RButtonDown;
    procedure lsEditMove_;
    procedure WMLButtonUp(var Msg : tMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMLButtonDblclk(var Msg : tMessage);
      virtual wm_First + wm_LButtonDblclk;
    procedure msGetContext(var Msg : tMessage);
      virtual ms_GetContext;
    procedure msTick(var Msg : tMessage);
      virtual ms_Tick;
    procedure cmSimStart(var Msg : tMessage);
      virtual cm_First + cm_SimStart;
    procedure cmSimStop(var Msg : tMessage);
      virtual cm_First + cm_SimStop;
    procedure InitTest;
    procedure cmSimReset(var Msg : tMessage);
      virtual cm_First + cm_SimReset;
    procedure cmFileSaveAs(var Msg : tMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure msExport(var Msg : tMessage);
      virtual ms_Export;
    procedure CalcEdit(R : tRect); virtual;
    procedure DelEdit; virtual;
    function IsEditEmpty : Boolean; virtual;
    procedure InvertEdit(PaintDC : HDC); virtual;
    procedure cmEditDelete(var Msg : tMessage);
      virtual cm_First + cm_EditDelete;
    procedure cmEditCopy(var Msg : tMessage);
      virtual cm_First + cm_EditCopy;
    procedure cmEditPaste(var Msg : tMessage);
      virtual cm_First + cm_EditPaste;
    (*procedure cmExportBMP(var Msg : tMessage);
      virtual cm_First + cm_ExportBMP;
    procedure cmExportWMF(var Msg : tMessage);
      virtual cm_First + cm_ExportWMF;*)
    procedure cmItemText(var Msg : tMessage);
      virtual cm_First + cm_ItemText;
{$ifdef ROMRAM}
    procedure cmROMRAM(var Msg : tMessage);
      virtual cm_First + cm_ROMRAM;
{$endif}
{$ifdef PLA}
    procedure cmPLA(var Msg : tMessage);
      virtual cm_First + cm_PLA;
{$endif}
    procedure cmHelpContext(var Msg : tMessage);
      virtual cm_First + cm_HelpContext;
    procedure cmDeleteItem(var Msg : tMessage);
      virtual cm_First + cm_DeleteItem;
    procedure cmItemDlg(var Msg : tMessage);
      virtual cm_First + cm_ItemDlg;
    procedure cmSwitchState(var Msg : tMessage);
      virtual cm_First + cm_SwitchState;
    procedure cmTickState(var Msg : tMessage);
      virtual cm_First + cm_TickState;
    procedure cmDelAllPt(var Msg : tMessage);
      virtual cm_First + cm_DelAllPt;
{$ifdef osc}
    procedure cmOscRecord( var Msg : tMessage );
      virtual cm_First + cm_OscRecord;
    procedure msOscIsRecCon( var Msg : tMessage );
      virtual ms_OscIsRecCon;
    procedure msSetupOscWin( var Msg : tMessage );
      virtual ms_SetupOscWin;
{$endif}
    procedure msItemIndex( var Msg : tMessage );
      virtual ms_ItemIndex;
{$ifdef osc}
    procedure msSetCaption( var Msg : tMessage );
      virtual ms_SetCaption;
{$endif}
{$ifdef PLA}
    procedure cmPLADelIn( var Msg : tMessage );
      virtual cm_First + cm_PLADelIn;
    procedure cmPLADelOut( var Msg : tMessage );
      virtual cm_First + cm_PLADelOut;
    procedure cmPLADelAll( var Msg : tMessage );
      virtual cm_First + cm_PLADelAll;
{$endif}
    procedure InvalidateItem( p : pItem );
    procedure InvalidateActItem;
{$ifdef layele}
    procedure msMacroImpulse( var Msg : tMessage );
      virtual ms_MacroImpulse;
    procedure msMacroPaint( var Msg : tMessage );
      virtual ms_MacroPaint;
{$endif}
{$ifdef osc}
    procedure WMSysCommand(var Msg : tMessage);
      virtual WM_FIRST + WM_SYSCOMMAND;
    procedure cmShowOscWin(var Msg : tMessage);
      virtual cm_First + cm_ShowOscWin;
{$endif}
{$ifdef undo}
    { Gesamtes Fenster löschen, um aus Undo Puffer laden zu können. }
    procedure DelUndo; virtual;
{$endif}
{$ifdef layele}
    procedure cmShowMacro(var Msg : tMessage);
      virtual cm_First + cm_ShowMacro;
{$endif}
  end;

implementation

{ ------ tEleFileDlg ---------------------------------------------------- }

const
  id_List = 100;

type
  pEleFileDlg = ^tEleFileDlg;
  tEleFileDlg = object (tDialogEx)
    Input : Pointer;
    constructor Init(xParent : pWindowsObject; xInput : Pointer);
    procedure SetupWindow; virtual;
    procedure idList(var Msg : tMessage);
      virtual id_First + id_List;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tEleFileDlg.Init(xParent : pWindowsObject; xInput : Pointer);
begin
  inherited Init(xParent, 'ELEFILEDLG');
  Input := xInput;
end;

procedure tEleFileDlg.SetupWindow;
procedure DoAddString(p : pEleFile); far;
begin
  SendDlgItemMsg(id_List, lb_AddString, 0, Longint(p^.Name));
end;
var EleFiles : pCollection;
begin
  inherited SetupWindow;
  EleFiles := pCollection(SendMessage(hMainWin, ms_GetEleFile, 0, 0));
  EleFiles^.ForEach(@DoAddString);
end;

procedure tEleFileDlg.idList(var Msg : tMessage);
begin
  case Msg.lParamHi of
    lbn_SelChange : EnableWindow(GetItemHandle(id_OK), True);
    lbn_DblClk : OK(Msg);
  end;
end;

procedure tEleFileDlg.OK(var Msg : tMessage);
begin
  Integer(Input^) := SendDlgItemMsg(id_List, lb_GetCurSel, 0, 0);
  inherited OK(Msg);
end;

procedure tEleFileDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 300);
end;

{ ------ tGateDlg ------------------------------------------------------- }

const
  id_FileList = 100;
  id_EleList = 101;
  id_NewFile = 200;
  id_DeleteFile = 201;

type
  pGateDlg = ^tGateDlg;
  tGateDlg = object (tDialogEx)
    Input : ^Pointer;
    DelItemList : pCollection;
    OldEleFile : ^Integer;
    constructor Init(
      xParent : pWindowsObject; xInput : Pointer; xOldEleFile : Pointer);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure FileList_SelChange(i : Integer);
    procedure idFileList(var Msg : tMessage);
      virtual id_First + id_FileList;
    procedure idEleList(var Msg : tMessage);
      virtual id_First + id_EleList;
    procedure idNewFile(var Msg : tMessage);
      virtual id_First + id_NewFile;
    procedure idDeleteFile(var Msg : tMessage);
      virtual id_First + id_DeleteFile;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

constructor tGateDlg.Init(
  xParent : pWindowsObject; xInput : Pointer; xOldEleFile : Pointer);
begin
  inherited Init(xParent, 'GATEDLG');
  Input := xInput;
  DelItemList := New(pCollection, Init(20, 10));
  OldEleFile := xOldEleFile;
end;

destructor tGateDlg.Done;
begin
  DelItemList^.DeleteAll;
  Dispose(DelItemList, Done);
  inherited Done;
end;

procedure tGateDlg.SetupWindow;
procedure DoFiles(p : pEleFile); far;
begin
  SendDlgItemMsg(id_FileList, lb_AddString, 0, Longint(p^.Name));
end;
begin
  inherited SetupWindow;
  pLayoutWindow(Parent)^.Lay.EleFiles^.ForEach(@DoFiles);
  if SendDlgItemMsg(id_FileList, lb_SetCurSel, OldEleFile^, 0) <> lb_Err
  then FileList_SelChange(OldEleFile^);
end;

procedure tGateDlg.FileList_SelChange(i : Integer);
procedure DoAdd(p : pElement); far;
begin
  with p^ do
    if Name[0] = #1
    then
      SendDlgItemMsg(id_EleList, lb_AddString, 0, Longint(@Name[1]))
    else begin
      StrCopy(@String0, '   ');
      StrCat(@String0, Name);
      SendDlgItemMsg(id_EleList, lb_AddString, 0, Longint(@String0));
    end;
end;
var p : pEleFile;
begin
  SendDlgItemMsg(id_EleList, lb_ResetContent, 0, 0);
  p := pEleFile(pLayoutWindow(Parent)^.Lay.EleFiles^.At(i));
  p^.ElementList^.ForEach(@DoAdd);
  EnableWindow(GetItemHandle(id_DeleteFile), True);
  EnableWindow(GetItemHandle(id_OK), False);
  OldEleFile^ := i;
end;

procedure tGateDlg.idFileList(var Msg : tMessage);
begin
  case Msg.lParamHi of
    lbn_SelChange :
      FileList_SelChange(
        SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0));
  end;
end;

procedure tGateDlg.idEleList(var Msg : tMessage);
procedure SelChange;
var
  p : pEleFile;
  i : Integer;
begin
  i := SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0);
  p := pEleFile(pLayoutWindow(Parent)^.Lay.EleFiles^.At(i));
  i := SendDlgItemMsg(id_EleList, lb_GetCurSel, 0, 0);
  if pElement(p^.ElementList^.At(i))^.Name[0] = #1
  then EnableWindow(GetItemHandle(id_OK), False)
  else EnableWindow(GetItemHandle(id_OK), True);
end;
procedure DblClk;
var
  p : pEleFile;
  i : Integer;
begin
  i := SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0);
  p := pEleFile(pLayoutWindow(Parent)^.Lay.EleFiles^.At(i));
  i := SendDlgItemMsg(id_EleList, lb_GetCurSel, 0, 0);
  if pElement(p^.ElementList^.At(i))^.Name[0] <> #1 then OK(Msg);
end;
begin
  case Msg.lParamHi of
    lbn_SelChange : SelChange;
    lbn_DblClk : DblClk;
  end;
end;

procedure tGateDlg.idNewFile(var Msg : tMessage);
var
  p : pEleFile;
  i : Integer;
begin
  if Application^.ExecDialog(New(pEleFileDlg, Init(@Self, @i))) = id_OK
  then begin
    p := pEleFile(SendMessage(hMainWin, ms_GetEleFile, 1, i));
    if pLayoutWindow(Parent)^.Lay.EleFiles^.IndexOf(p) < 0
    then begin
      if p^.LoadEleFile
      then begin
        pLayoutWindow(Parent)^.Lay.EleFiles^.Insert(p);
        SendDlgItemMsg(id_FileList, lb_AddString, 0, Longint(p^.Name));
      end;
    end
    else ErrorMessage(4);
  end;
end;

procedure tGateDlg.idDeleteFile(var Msg : tMessage);
var
  i : Integer;
  s, s_ : pChar;
begin
  i := SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0);
  s_ := pEleFile(pLayoutWindow(Parent)^.Lay.EleFiles^.At(i))^.Name;
  GetMem(s, StrLen(LoadString0(64)) + StrLen(s_) - 1 {+1-2});
  wvsprintf(s, @String0, s_);
  if MessageBox(
       hWindow, pChar(@s), LoadString0(96),
       mb_IconStop + mb_YesNo) = id_Yes
  then MessageBeep(mb_OK);
end;

procedure tGateDlg.OK(var Msg : tMessage);
var
  i : Integer;
  p : Pointer;
begin
  i := SendDlgItemMsg(id_FileList, lb_GetCurSel, 0, 0);
  p := pLayoutWindow(Parent)^.Lay.EleFiles^.At(i);
  i := SendDlgItemMsg(id_EleList, lb_GetCurSel, 0, 0);
  p := pEleFile(p)^.ElementList^.At(i);
  Input^ := Pointer(New(pEleItem, Init(pElement(p))));
  inherited OK(Msg);
end;

procedure tGateDlg.CMHelp(var Msg : tMessage);
begin
  WinHelp(hWindow, HelpFileName, HELP_CONTEXT, 300);
end;

{ ------ tLayoutWindow -------------------------------------------------- }

constructor tLayoutWindow.Init(aParent : pWindowsObject);
begin
  inherited Init(aParent, LoadString0(5));
  ShowInOut := xShowInOut;
  TestOn := False;
  TestInit := False;
  Attr.Style := Attr.Style or ws_VScroll or ws_HScroll;
  Lay.Init;
  EditLayout := New(pCollection, Init(40, 40));
  Impulses := New(pCollection, Init(20, 20));
  ActItem := nil;
  State := ls_None;
  OldEleFile := 0;
  NameEx := False;
  FontData := FontDataOpt;
{$ifdef osc}
  OscWin := nil;
{$endif}
end;

destructor tLayoutWindow.Done;
begin
{$ifdef osc}
  SendMessage( OscWin^.hWindow, wm_Close, Word(true), 0 );
{$endif}
  Dispose(Impulses, Done);
  EditLayout^.DeleteAll;
  Dispose(EditLayout, Done);
  Lay.Done;
  inherited Done;
end;

{$ifdef osc}
procedure tLayoutWindow.SetupWindow;
var
  menu : hMenu;
begin
  inherited SetupWindow;
  OscWin := New( pOscilloscopeWindow, Init(Parent, Attr.Title) );
  OscWin^.LayWin := @Self;
  SendMessage( hWindow, ms_SetupOscWin, 0, 0 );
  menu := GetSystemMenu( hWindow, false );
  AppendMenu( menu, MF_SEPARATOR, 0, nil );
  { Oszilloskop }
  LoadString0(56);
  AppendMenu(
    menu,
    MF_STRING + MF_ENABLED + MF_UNCHECKED,
    CM_SHOWOSCWIN, @String0 );
end;
{$endif}

{$ifdef osc}
procedure tLayoutWindow.msSetupOscWin( var Msg : tMessage );
begin
  SendMessage( hMainWin, ms_NewWin, 0, longint(OscWin) );
  ShowWindow( OscWin^.hWindow, SW_HIDE );
  SendMessage(
    OscWin^.hWindow, ms_SetCaption, 0,
    longint(Attr.Title) );
end;
{$endif}

procedure tLayoutWindow.Load(var S : tStream);
var
  ActLay_ : pLay;
  i : integer;
begin
  if Lay.Load(S)
  then begin
    ActLay_ := SetActLay(@Lay);
    Impulses^.Load(S);
    SetActLay(ActLay_);
    inherited Load(S);
    S.Read(ShowInOut, SizeOf(ShowInOut) + SizeOf(TestInit));
    TestOn := false;
    NameEx := True;
{$ifdef osc}
    OscWin^.Load(S);
{$endif}
    MDI_Act;
  end
  else Destroy;
end;

procedure tLayoutWindow.Store(var S : tStream);
var
  ActLay_ : pLay;
  t : Text;
begin

{$ifdef storetext}
  Assign(t, 'c:\lokon\export.txt'); (**)
  Rewrite(t);
  Lay.StoreText(t);
  Close(t);                         (**)
{$endif}

  Lay.Store(S);
  ActLay_ := SetActLay(@Lay);
  Impulses^.Store(S);
  SetActLay(ActLay_);
  inherited Store(S);
  S.Write(ShowInOut, SizeOf(ShowInOut) + SizeOf(TestInit));
  NameEx := True;
  NotClose := False;
{$ifdef osc}
  OscWin^.Store(S);
{$endif}
  MDI_Act;
end;

procedure tLayoutWindow.GetWindowClass(var aWndClass : tWndClass);
begin
  inherited GetWindowClass(aWndClass);
  with aWndClass
  do begin
    Style := Style or $08 {cs_DblClk};
    hIcon := LoadIcon(hRes, 'LAYICON');
    hbrBackground := GetStockObject(White_Brush);
    AWndClass.hCursor := 0;
  end;
end;

function tLayoutWindow.GetClassName: PChar;
begin
  GetClassName := 'LK_LayWin';
end;

function tLayoutWindow.CanClose : Boolean;
var
  s, s_ : pChar;
begin
  if NotClose
  then begin
    GetWindowText(hWindow, @String1, StringLen);
    GetMem(s, StrLen(LoadString0(81)) + StrLen(@String1) - 1 {+1-2});
    s_ := @String1;
    wvsprintf(s, @String0, s_);
    case MessageBox(
           hWindow, s, LoadString0(96),
           mb_IconQuestion or mb_YesNoCancel)
    of
      id_Yes :
        begin
          if NameEx
          then SendMessage(hMainWin, ms_Save, hWindow, 0)
          else SendMessage(hMainWin, ms_SaveAs, hWindow, 0);
          CanClose := True;
        end;
      id_No : CanClose := True;
      else CanClose := False;
    end;
    StrDispose(s);
  end
  else CanClose := True;
end;

procedure tLayoutWindow.EndDrag;
begin
  inherited EndDrag;
  State := ls_None;
end;

procedure tLayoutWindow.msDelInsItem(var Msg : tMessage);
var
  PaintDC : hDC;
begin
  case Msg.wParam of
    di_DeleteItem : DeleteItem(pItem(Msg.lParam));
    di_InsertItem :
      begin
        PaintDC := GetDC(hWindow);
        pScrollerOrg(Scroller)^.BeginZoom(PaintDC);
        InsertItem(pItem(Msg.lParam), PaintDC);
        ReleaseDC(hWindow, PaintDC);
      end;
  end;
end;

procedure tLayoutWindow.cmShowInOut(var Msg : tMessage);
begin
  ShowInOut := not ShowInOut;
  CheckMenuItem(
    pWindow(Application^.MainWindow)^.Attr.Menu,
    cm_ShowInOut, mf_ByCommand or (Ord(ShowInOut) shl 3));
  if ShowInOut
  then SendMessage(
         hMainWin, ms_Speedbar, SBActivate,
         SBDown or SBActive or cm_ShowInOut)
  else SendMessage(
         hMainWin, ms_Speedbar, SBActivate,
         SBActive or cm_ShowInOut);
  DrawMenuBar(hMainWin);
  InvalidateRect(hWindow, nil, True);
end;

procedure tLayoutWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  Rgn : hRgn;
  font : hFont;
begin
  if RasterFront or (Raster=0)
  then Lay.Paint(PaintDC, PaintInfo.rcPaint)
  else Lay.Paint_(PaintDC, PaintInfo.rcPaint);
  if ShowInOut then Lay.PaintInOut(PaintDC);
{$ifdef osc}
  if xShowOsc
  then begin
    font := CreateFont(
      4, 0,
      0, 0,
      400,
      0, 0, 0,
      ANSI_Charset, Font_Precis,
      0, Font_Quality, 1, 'Arial');
    SelectObject(PaintDC, font);
    SetTextColor(PaintDC, OscTextColor);
    SendMessage(
      OscWin^.hWindow, ms_OscLayPaint,
      PaintDC, longint(@PaintInfo) );
    DeleteObject(font);
  end;
{$endif}
end;

procedure tLayoutWindow.msZoomAll(var Msg : tMessage);
var R : tRect;
procedure DoUnionRect(p : pItem); far;
begin
  UnionRect(R, R, p^.ItemRect);
end;
begin
  SetRectEmpty(R);
  Lay.Layout^.ForEach(@DoUnionRect);
  if not IsRectEmpty(R)
  then begin
    InflateRect(R, 5, 5);
    pScrollerOrg(Scroller)^.SetRectZoom(R);
  end;
end;

procedure tLayoutWindow.SetActItem(p : pItem);
begin
  ActItem := p;
  SetMenuActItem;
end;

procedure tLayoutWindow.SetMenuActItem;
var
  Menu : hMenu;
  s : array [0..100] of Char;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if ActItem <> nil
  then begin
    StrCopy(@s, ActItem^.Name);
    StrCat(@s, LoadString0(20));
    ModifyMenu(
      Menu,
      cm_ActItem, MF_ENABLED,
      cm_ActItem, @s);
    if ActItem^.Name[0] = '@'
    then EnableMenuItem( Menu, cm_ActItem, MF_GRAYED or MF_BYCOMMAND );
  end
  else begin
    StrCopy(@s, 'xxx');
    StrCat(@s, LoadString0(20));
    ModifyMenu(
      Menu,
      cm_ActItem, MF_GRAYED,
      cm_ActItem, @s);
  end;
  MDI_Act;
end;

procedure tLayoutWindow.cmGate(var Msg : tMessage);
var p : pItem;
begin
  if Application^.ExecDialog(New(pGateDlg, Init(@Self, @p, @OldEleFile))) = id_OK
  then InitItem(p)
  else State := ls_None;
end;

procedure tLayoutWindow.cmActItem(var Msg : tMessage);
begin
  InitItem( ActItem^.Copy );
  (*ActItem := ActItem^.Copy; { Kopie ! }
  State := ls_MoveActItem;
  SetCursorActState;
  BeginDrag;
  ActItem^.NotPaint(DragDC);*)
end;

procedure tLayoutWindow.InitItem(p : pItem);
begin
  BeginDrag;
  SetActItem(p);
  State := ls_MoveActItem;
  SetCursorActState;
  ActItem^.NotPaint(DragDC);
end;

procedure tLayoutWindow.cmConNode(var Msg : tMessage);
begin
  InitItem(New(pConNode, Init(0, 0)));
end;

procedure tLayoutWindow.cmSwitch(var Msg : tMessage);
begin
  InitItem(New(pSwitch, Init));
end;

procedure tLayoutWindow.cmZero(var Msg : tMessage);
begin
  InitItem(New(pZero, Init));
end;

procedure tLayoutWindow.cmOne(var Msg : tMessage);
begin
  InitItem(New(pOne, Init));
end;

procedure tLayoutWindow.cmTickEle(var Msg : tMessage);
var i : Integer;
begin
  i := 50;
  if Application^.ExecDialog(
       New(pNrDlg, Init(@Self, @i, 76))) = id_OK
  then begin
    if i > 0
    then InitItem(New(pTick, Init(i)))
    else MessageBeep(43);
  end;
end;

procedure tLayoutWindow.MDI_Act;
var
  Menu : hMenu;
  IncMenu : Integer;
begin
  if SendMessage(
       pMDIWindow(Application^.MainWindow)^.ClientWnd^.hWindow,
       wm_MDIGetActive, 0, 0) > $0000ffff
  then IncMenu := 1
  else IncMenu := 0;
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if NameEx
  then begin
    EnableMenuItem(Menu, cm_FileSave, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_FileSave);
  end
  else begin
    EnableMenuItem(Menu, cm_FileSave, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_FileSave);
  end;
  { Edit-Funktionen aktivieren. }
  EnableMenuItem(Menu, cm_EditAll, mf_ByCommand or mf_Enabled);
  { SimMenu. }
  if TestOn
  then begin
    EnableMenuItem(Menu, cm_SimStop, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_SimReset, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_SimStart, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_SimStop);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_SimReset);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_SimStart);
    EnableMenuItem(Menu, 1 + IncMenu, mf_ByPosition or mf_Grayed); { Bearbeiten. }
    SendMessage(hMainWin, ms_SpeedBar, SBEnabled, cm_EditCut+(cm_EditPaste shl 16));
  end
  else begin
    EnableMenuItem(Menu, cm_SimStop, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_SimReset, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_SimStart, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_SimStop);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_SimReset);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_SimStart);
    EnableMenuItem(Menu, 1 + IncMenu, mf_ByPosition or mf_Enabled); { Bearbeiten. }
    SendMessage(hMainWin, ms_SpeedBar, SBGrayed, cm_EditCut+(cm_EditPaste shl 16));
  end;
  { ShowInOut. }
  CheckMenuItem(
    Menu, cm_ShowInOut, mf_ByCommand or (Ord(ShowInOut) shl 3));
  { Edit-Menu. }
  EnableMenuItem(Menu, cm_EditPaste, mf_ByCommand or mf_Enabled);
  SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditPaste);
  inherited MDI_Act;
{$ifdef mini}
  if Lay.Layout^.Count > 100
  then begin
    { Bearbeiten. }
    EnableMenuItem(Menu, cm_EditPaste,  mf_Grayed );
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_EditPaste);
    { Elemente. }
    EnableMenuItem(Menu, cm_Gate, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_Gate);
    EnableMenuItem(Menu, cm_ActItem, mf_Grayed);
    EnableMenuItem(Menu, cm_ConNode, mf_Grayed);
    EnableMenuItem(Menu, cm_Zero, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_Zero);
    EnableMenuItem(Menu, cm_One, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_One);
    EnableMenuItem(Menu, cm_Switch, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_Switch);
    EnableMenuItem(Menu, cm_TickEle, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_TickEle);
    EnableMenuItem(Menu, cm_ItemText, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_ItemText);
    EnableMenuItem(Menu, cm_FileSave, mf_Grayed);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, cm_FileSave);
    EnableMenuItem(Menu, cm_FileSaveAs, mf_Grayed);
  end
  else begin
    { Elemente. }
    EnableMenuItem(Menu, cm_Gate, mf_Enabled);
    EnableMenuItem(Menu, cm_ConNode, mf_Enabled);
    EnableMenuItem(Menu, cm_Zero, mf_Enabled);
    EnableMenuItem(Menu, cm_One, mf_Enabled);
    EnableMenuItem(Menu, cm_Switch, mf_Enabled);
    EnableMenuItem(Menu, cm_TickEle, mf_Enabled);
    EnableMenuItem(Menu, cm_ItemText, mf_Enabled);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_Gate);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_ConNode);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_Zero);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_One);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_Switch);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_TickEle);
    SendMessage(hMainWin, ms_SpeedBar, SBActivate, SBActive or cm_ItemText);
  end;
{$endif}
end;

procedure tLayoutWindow.MDI_Menu(b : Boolean);
var
  Menu : hMenu;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if b
  then begin
    InsertMenu(Menu, 2 + MenuInc,
      mf_Enabled + mf_ByPosition + mf_Popup,
      LoadMenu(hRes, 'LAYVIEW'), LoadString0(17));
    InsertMenu(Menu, 2 + MenuInc,
      mf_Enabled + mf_ByPosition + mf_Popup,
      LoadMenu(hRes, 'GATEMENU'), LoadString0(16));
    InsertMenu(Menu, 2 + MenuInc,
      mf_Enabled + mf_ByPosition + mf_Popup,
      LoadMenu(hRes, 'SIMMENU'), LoadString0(23));
    SendMessage(hMainWin, ms_ChildMenuPos, +2, 0);
    { Speedbar. }
    SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditCopy);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_EditPaste);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_SimStart);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, cm_SimStop);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_SimReset);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Gate);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zero);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_One);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Switch);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_TickEle);
{$ifdef ROMRAM}
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ROMRAM);
{$endif}
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ItemText);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ZoomAll);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_ShowInOut);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos1);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos5);
    SendMessage(hMainWin, ms_Speedbar, SBInsert, SBActive or cm_Pos10);
  end
  else begin
    DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
    RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
    DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
    RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
    DestroyMenu(GetSubMenu(Menu, 2 + MenuInc));
    RemoveMenu(Menu, 2 + MenuInc, mf_ByPosition);
    EnableMenuItem(Menu, 1 + MenuInc, mf_ByPosition or mf_Enabled); { Bearbeiten. }
    SendMessage(hMainWin, ms_ChildMenuPos, Word(-3), 0);
    { Speedbar. }
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditCopy);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_EditPaste);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_SimStart);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_SimStop);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_SimReset);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Gate);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zero);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_One);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Switch);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_TickEle);
{$ifdef ROMRAM}
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ROMRAM);
{$endif}
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ItemText);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom50);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom75);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Zoom90);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomBox);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ZoomAll);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_ShowInOut);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos1);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos5);
    SendMessage(hMainWin, ms_Speedbar, SBDelete, cm_Pos10);
  end;
  inherited MDI_Menu(b);
end;

function tLayoutWindow.GetItem(Pos : tPoint) : pItem;
function DoGetItem(p : pItem) : Boolean; far;
begin
  DoGetItem := p^.Pt_in_Item(Pos);
end;
begin
  GetItem := Lay.Layout^.FirstThat(@DoGetItem);
end;

procedure tLayoutWindow.SetCursorOfState(xState : Integer);
begin
  case xState of
    ls_MoveActItem,
    ls_MoveActItemB,
    ls_EditMove,
    ls_EditMoveB : SetCursor(LoadCursor(hRes, 'IDC_MOVEACTITEM'));
    ls_MoveActItemC : SetCursor(LoadCursor(hRes, 'IDC_MOVEACTITEMC'));
    ls_Connection : SetCursor(LoadCursor(hRes, 'IDC_CONNECT'));
    ls_ConMove : SetCursor(LoadCursor(hRes, 'IDC_CONMOVE'));
    ls_ConnectionB : SetCursor(LoadCursor(hRes, 'IDC_CONNECTB'));
    ls_ConnectionC : SetCursor(LoadCursor(hRes, 'IDC_CONNECTC'));
    ls_ConnectionPt : SetCursor(LoadCursor(hRes, 'IDC_CONNECTPT'));
    ls_ConPtMove : SetCursor(LoadCursor(hRes, 'IDC_CONPTMOVE'));
    ls_ConNode : SetCursor(LoadCursor(hRes, 'IDC_CONNODE'));
    ls_ToggleSwitch : SetCursor(LoadCursor(hRes, 'IDC_TOGGLESW'));
{$ifdef PLA}
    ls_PLAMatrix : SetCursor(LoadCursor(hRes, 'IDC_PLAMATRIX'));
{$endif}
  end;
  inherited SetCursorOfState(xState); { wegen ms_UpdateInfo }
end;

type
  tEditMoveRec = record
    xA : tPoint;
    xRicht : Shortint;
    xIsPasted : Boolean;
  end;

procedure tLayoutWindow.WMMouseMove(var Msg : tMessage);
procedure lsNone_;
var
  p : pItem;
  i : Integer;
begin
  p := GetItem(tPoint(Msg.lParam));
  if p = nil
  then SetCursorActState
  else
    if TestOn
    then
      SetCursorOfState(
        p^.GetState(tPoint(Msg.lParam), lm_MouseMove or lm_Test))
    else
      if EditLayout^.IndexOf(p) >= 0
      then SetCursorOfState(ls_EditMove)
      else SetCursorOfState(p^.GetState(tPoint(Msg.lParam), lm_MouseMove));
end;
procedure lsConnection;
var
  p : pItem;
  st_ : Integer;
begin
  with pConnection(Poi)^
  do begin
    NotPaint(DragDC);
    MoveTo_(tPoint(Msg.lParam));
    NotPaint(DragDC);
  end;
  p := GetItem(tPoint(Msg.lParam));
  if (p = nil)
  then SetCursorOfState(ls_ConnectionB)
  else begin
    st_ := p^.GetState(tPoint(Msg.lParam), lm_Connect);
    SetCursorOfState(st_);
    if (st_ = LS_CONNODE) and (RasterPos > 1)
    then begin
      PosCoord(tPoint(Msg.lParam));
      SendMessage(hMainWin, ms_UpdatePos, 0, Msg.lParam);
    end;
  end;
end;
procedure lsEditMove;
var
  incX, incY : Integer;
procedure DoNotPaint(p : pItem); far;
begin
  p^.NotPaint(DragDC);
end;
procedure DoIncPos(p : pItem); far;
begin
  p^.IncPos(incX, incY);
end;
function DoTouch(p : pItem) : Boolean; far;
begin
  DoTouch := TouchItem(p);
end;
begin
  EditLayout^.ForEach(@DoNotPaint);
  incX := tPoint(Msg.lParam).X - tEditMoveRec(Poi^).xA.X;
  incY := tPoint(Msg.lParam).Y - tEditMoveRec(Poi^).xA.Y;
  EditLayout^.ForEach(@DoIncPos);
  tEditMoveRec(Poi^).xA := tPoint(Msg.lParam);
  EditLayout^.ForEach(@DoNotPaint);
  if xCollision and (EditLayout^.FirstThat(@DoTouch)<>nil)
  then SetCursorOfState(ls_MoveActItemC)
  else SetCursorOfState(ls_MoveActItem);
end;
begin
  inherited wmMouseMove(Msg);
  if State = ls_None
  then lsNone_
  else begin
    case State of
      ls_MoveActItem,
      ls_MoveActItemB :
        with ActItem^
        do begin
          NotPaint(DragDC);
          with tPoint(Msg.lParam) do SetPos(X, Y);
          if xCollision and TouchItem(ActItem)
          then SetCursorOfState(ls_MoveActItemC)
          else SetCursorOfState(ls_MoveActItem);
          NotPaint(DragDC);
        end;
      ls_Connection : lsConnection;
      ls_ConnectionPt :
        with pConnectionPt(Poi)^.Connection^
        do begin
          Paint(DragDC);
          SetPt(pConnectionPt(Poi)^.NumPt, tPoint(Msg.lParam));
          Paint(DragDC);
        end;
      ls_EditMove,
      ls_EditMoveB : lsEditMove;
    end;
  end;
end;

function tLayoutWindow.TouchItem(p : pItem) : Boolean;
var Rgn : hRgn;
function DoTouch(p_ : pItem) : Boolean; far;
begin
  DoTouch := p_^.Rgn_in_Item(Rgn);
end;
begin
  Rgn := p^.GetRegion;
  if Lay.Layout^.FirstThat(@DoTouch) = nil
  then TouchItem := False
  else TouchItem := True;
  DeleteObject(Rgn);
end;

procedure tLayoutWindow.DeleteItem(p : pItem);
var
  Rgn, Rgn_ : hRgn;
  R : tRect;
begin
  if Lay.Layout^.IndexOf(p) >= 0
  then begin
    { Wird ein Element gelöscht, so werden auch ALLE
      Impulse gelöscht. TestInit wird zurückgesetzt. }
    InitTest;
    Rgn := p^.GetRegion;
    Rgn_ := p^.GetRegionCon;
    Lay.Layout^.Delete(p);
    if EditLayout^.IndexOf(p) >= 0 then
      EditLayout^.Delete(p);
    p^.DeleteCon(Lay.Layout);
    CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
    DeleteObject(Rgn_);
    GetRgnBox(Rgn, R);
    DeleteObject(Rgn);
    InflateRect(R, 1, 1);
    with pScrollerOrg(Scroller)^
    do begin
      ClientCoord(tRect_(R).A);
      ClientCoord(tRect_(R).B);
    end;
    DeleteObject(Rgn);
    InvalidateRect(hWindow, @R, True);
  end;
end;

procedure tLayoutWindow.InsertItem(p : pItem; PaintDC : hDC);
begin
  if Lay.Layout^.IndexOf(p) < 0
  then begin
    SetROP2(PaintDC, R2_CopyPen);
    Lay.Layout^.Insert(p);
    p^.Paint(PaintDC);
    p^.InsertCon(Lay.Layout, PaintDC);
    p^.CalcItemRect;
  end;
end;

procedure tLayoutWindow.lsNone(A : tPoint; b : Integer);
var
  p : pItem;
procedure lsMoveActItem;
begin
  BeginDrag;
  if b = lm_LButton
  then DeleteItem(p)
  else p := p^.Copy;
  UpdateWindow(hWindow);
  SetActItem(p);
  SavePos := p^.Position^;
  State := ls_MoveActItemB;
  ActItem^.NotPaint(DragDC);
end;
procedure lsConnection;
var
  i : Integer;
begin
  BeginDrag;
  i := p^.GetInOutNr(A);
  Poi := New(pConnection, Init(i, 0, p, pItem(p^.GetInOutPos(i))));
  p^.SetCon(i, Poi, 1);
  pConnection(Poi)^.NotPaint(DragDC);
end;
procedure lsConMove;
var
  Connection : pConnection;
  Con : tCon;
  Num : Integer;
  b : Boolean;
begin
  Num := p^.GetInOutNr(A);
  Connection := pConnection(p^.GetInOutPtr(Num));
  with Connection^ do b := (Con1.Con=p) and (Con1.Num=Num);
  if b
  then Con := Connection^.Con2
  else Con := Connection^.Con1;
  BeginDrag;
  DeleteItem(Connection);
  UpdateWindow(hWindow);
  with Connection^
  do begin
    DelAllPt;
    Init(Con.Num, 0, Con.Con, pItem(A));
    NotPaint(DragDC);
  end;
  Poi := Connection;
  State := ls_Connection;
end;
procedure lsConnectionPt;
begin
  Poi := New(pConnectionPt);
  with pConnectionPt(Poi)^
  do begin
    Connection := pConnection(p);
    BeginDrag;
    DeleteItem(p);
    UpdateWindow(hWindow);
    NumPt := Connection^.GetLineNum(A);
    Connection^.InsertPt(NumPt, A);
    Connection^.NotPaint(DragDC);
  end;
end;
procedure lsConPtMove;
begin
  Poi := New(pConnectionPt);
  with pConnectionPt(Poi)^
  do begin
    Connection := pConnection(p);
    BeginDrag;
    DeleteItem(p);
    UpdateWindow(hWindow);
    NumPt := Connection^.GetPtNum(A);
    Connection^.NotPaint(DragDC);
    State := ls_ConnectionPt;
  end;
end;
procedure lsDeleteItem;
procedure DeleteItem_;
begin
  { Vgl. mit cmEditDelete. }
  DeleteItem(p);
{$ifdef osc}
  p^.DelOscCon(OscWin^.hWindow);
{$endif}
  p^.DisposeCon;
  Dispose(p, Done);
end;
var
  s_ : pChar;
begin
  SetNotClose;
  if MessageOn
  then begin
    s_ := p^.Name;
    wvsprintf(@String0, LoadString2(51), s_);
    if MessageBox(
         hWindow, @String0, LoadString2(96),
         mb_IconQuestion or mb_YesNo) = idYes
    then DeleteItem_;
  end
  else DeleteItem_;
  State := ls_None;
end;
procedure lsDeleteConPt;
begin
  BeginDrag;
  DeleteItem(p);
  with pConnection(p)^
  do DelPt(GetPtNum(A));
  InsertItem(p, DragDC);
  p^.CalcItemRect;
  EndDrag;
end;
procedure lsToggleSwitch;
begin
  SetNotClose;
  p^.Toggle(A);
  InvalidateItem(p);
  p^.GetInitImpulse(Impulses);
  State := ls_None;
end;
procedure lsEditMove;
var
  EditLayout_ : pCollection;
  R : tRect;
procedure DoDeleteItem(p : pItem); far;
begin
  DeleteItem(p);
  UnionRect(R, R, p^.ItemRect);
end;
procedure DoPaint(p : pItem); far;
begin
  p^.NotPaint(DragDC);
end;
begin
  BeginDrag;
  EditLayout_ := EditLayout;
  EditLayout := New(pCollection, Init(20, 20));
  EditLayout_^.ForEach(@DoDeleteItem);
  State := ls_EditMove;
  SavePos := p^.Position^;
  GetMem(Poi, SizeOf(tEditMoveRec));
  with tEditMoveRec(Poi^)
  do begin
    xA := tPoint((@SavePos)^);
    xRicht:=0;
    xIsPasted:=False;
  end;
  with tRect_(R)
  do begin
    pScrollerOrg(Scroller)^.ClientCoord(A);
    pScrollerOrg(Scroller)^.ClientCoord(B);
  end;
  InvalidateRect(hWindow, @R, TRUE);
  UpdateWindow(hWindow);
  Dispose(EditLayout, Done);
  EditLayout := EditLayout_;
  EditLayout^.ForEach(@DoPaint);
end;
var
  ItemMenu,
  Menu : hMenu;
  CrsrPos : tPoint;
begin
  GetCursorPos(CrsrPos);
  p := GetItem(A);
  if p <> nil
  then begin
    if TestOn then
      b := b or lm_Test;
    if EditLayout^.IndexOf(p) >= 0
    then begin
      case b and lm_First of
        lm_LButton : lsEditMove;
        lm_RButton :
          begin
            { Kontextsensitives Menü der rechten Maustaste. }
            ItemMenu := LoadMenu( hRes, 'ITEMMENU' );
            Menu :=
              AppendLayMenus( GetSubMenu( ItemMenu, 2 ), RasterFront );
            if TestOn
            then begin
              EnableMenuItem(
                Menu,
                cm_EditCut,
                MF_BYCOMMAND or MF_GRAYED );
              EnableMenuItem(
                Menu,
                24323,
                MF_BYCOMMAND or MF_GRAYED );
            end;
            TrackPopupMenu(
              Menu, 2,
              CrsrPos.X, CrsrPos.Y, 0,
              Application^.MainWindow^.hWindow, nil );
            DestroyMenu(Menu);
            DestroyMenu(ItemMenu);
          end;
      end;
    end
    else begin
      if (b and lm_First) = lm_RButton
      then begin
        { Kontextsensitives Menü der rechten Maustaste. }
        ItemMenu := LoadMenu( hRes, 'ITEMMENU' );
        SetActItem(p);
        Menu :=
          AppendLayMenus( p^.GetMenu( ItemMenu, hWindow ), RasterFront );
        InsertMenu(
          Menu, 0,
          MF_BYPOSITION or MF_GRAYED,
          0, p^.Name );
        if TestOn
        then begin
          EnableMenuItem(
            Menu,
            cm_DeleteItem,
            MF_BYCOMMAND or MF_GRAYED);
        end;
        TrackPopupMenu(
          Menu, 2,
          CrsrPos.X, CrsrPos.Y, 0,
          Application^.MainWindow^.hWindow, nil );
        DestroyMenu(Menu);
        DestroyMenu(ItemMenu);
      end
      else begin
        State := p^.GetState(A, b);
        case State of
          ls_MoveActItem : lsMoveActItem;
          ls_Connection : lsConnection;
          ls_ConnectionPt : lsConnectionPt;
          ls_ConPtMove : lsConPtMove;
          ls_DeleteConPt : lsDeleteConPt;
          ls_ConMove : lsConMove;
          ls_ToggleSwitch : lsToggleSwitch;
          ls_Test :
            begin
              case (b and lm_First) of
                lm_lButton,
                lm_RButton : BeepMessage(162);
              end;
              State := ls_None;
            end;
        end;
      end;
    end;
  end
  else
    case b of
      LM_LBUTTON : if not(TestOn) then DragEdit(A);
      LM_RBUTTON :
        begin
          ItemMenu := LoadMenu( hRes, 'ITEMMENU' );
          Menu :=
            AppendLayMenus( GetSubMenu( ItemMenu, 1 ), RasterFront );
          { Einfügen. }
          EnableMenuItem(
            Menu,
            cm_EditPaste,
            GetMenuState(
              GetMenu( Application^.MainWindow^.hWindow ),
              cm_EditPaste,
              MF_BYCOMMAND ) );
          TrackPopupMenu(
            Menu, 2,
            CrsrPos.X, CrsrPos.Y, 0,
            Application^.MainWindow^.hWindow, nil );
          DestroyMenu(Menu);
          DestroyMenu(ItemMenu);
        end;
    end;
end;

procedure tLayoutWindow.WMLButtonDown(var Msg : tMessage);
begin
  inherited wmLButtonDown(Msg);
  if State = ls_None
  then lsNone(tPoint(Msg.lParam), lm_LButton)
  else begin
    case State of
      ls_MoveActItem,
      ls_MoveActItemB :
        begin
          ActItem^.NotPaint(DragDC);
          if xCollision and TouchItem(ActItem)
          then BeepMessage(102)
          else InsertItem(ActItem, DragDC);
          EndDrag;
        end;
      ls_ZoomBox :
        begin
          with tPoint(Msg.lParam) do SetRect(tRect(Poi^), X, Y, X, Y);
          InvertRect(DragDC, tRect(Poi^));
          State := ls_ZoomBoxB;
        end;
      ls_EditMoveB : lsEditMove_;
    end;
  end;
end;

procedure tLayoutWindow.WMRButtonDown(var Msg : tMessage);
procedure lsEditMove;
procedure DoNotPaint(p : pItem); far;
begin
  p^.NotPaint(DragDC);
end;
procedure DoNewPos(p : pItem); far;
begin
  with tPoint(Msg.lParam) do
    p^.IncPos(-X, -Y);
  p^.IncDirection_;
  with tPoint(Msg.lParam) do
    p^.IncPos(X, Y);
end;
begin
  with EditLayout^
  do begin
    ForEach(@DoNotPaint);
    ForEach(@DoNewPos);
    ForEach(@DoNotPaint);
  end;
  with tEditMoveRec(Poi^)
  do begin
    inc(xRicht);
    xRicht := xRicht and $03;
  end;
end;
begin
  inherited WMRButtonDown(Msg);
  case State of
    ls_None : lsNone(tPoint(Msg.lParam), lm_RButton);
    ls_MoveActItem,
    ls_MoveActItemB :
      with ActItem^
      do begin
        NotPaint(DragDC);
        IncDirection;
        if xCollision and TouchItem(ActItem)
        then SetCursorOfState(ls_MoveActItemC)
        else SetCursorOfState(ls_MoveActItem);
        NotPaint(DragDC);
      end;
    ls_EditMove,
    ls_EditMoveB : lsEditMove;
  end;
end;

procedure tLayoutWindow.lsEditMove_;
procedure DoNotPaint(p : pItem); far;
begin
  p^.NotPaint(DragDC);
end;
procedure DoInsertItem(p : pItem); far;
begin
  InsertItem(p, DragDC);
end;
var incX, incY : Integer;
procedure DoIncPos(p : pItem); far;
begin
  p^.IncPos(incX, incY);
end;
procedure DoIncDirection(p : pItem); far;
begin
  with p^
  do begin
    IncPos(-incX, -incY);
    IncDirection_;
    IncPos(incX, incY);
  end;
end;
function DoTouch(p : pItem) : Boolean; far;
begin
  DoTouch := TouchItem(p);
end;
var i : Shortint;
begin
  EditLayout^.ForEach(@DoNotPaint);
  if xCollision and (EditLayout^.FirstThat(@DoTouch)<>nil)
  then begin
    BeepMessage(103);
    with tEditMoveRec(Poi^)
    do begin
      if xIsPasted
      then EditLayout^.FreeAll
      else begin
        { An alte Position zurücksetzen. }
        incX := xA.X;
        incY := xA.Y;
        if xRicht <> 0 then
          for i := xRicht to 3 do
            EditLayout^.ForEach(@DoIncDirection);
        incX := SavePos.X - xA.X;
        incY := SavePos.Y - xA.Y;
        EditLayout^.ForEach(@DoIncPos);
      end;
    end;
  end;
  { Elemente wieder in Schaltung einfügen. }
  EditLayout^.ForEach(@DoInsertItem);
  InvertEdit(DragDC);
  FreeMem(Poi, SizeOf(tEditMoveRec));
  EndDrag;
  State := ls_None;
  MDI_Act;
end;

procedure tLayoutWindow.WMLButtonUp(var Msg : tMessage);
procedure releaseConnection;
begin
  with pConnection(Poi)^
  do begin
    Con1.DelCon;
    Con1.Done;
    Con2.Done;
  end;
  Dispose(pConnection(Poi), Done);
end;
procedure lsConnection;
var
  p : pItem;
  i : Integer;
begin
  pConnection(Poi)^.NotPaint(DragDC);
  p := GetItem(tPoint(Msg.lParam));
  if p = nil
  then begin
    releaseConnection;
    BeepMessage(97);
  end
  else
    case p^.GetState(tPoint(Msg.lParam), lm_Connect) of
      ls_ConnectionB :
        begin
          releaseConnection;
          BeepMessage(97);
        end;
      ls_ConnectionC :
        begin
          releaseConnection;
          BeepMessage(101);
        end;
      ls_Connection :
        with pConnection(Poi)^
        do begin
          i := p^.GetInOutNr(tPoint(Msg.lParam));
          Init(Con1.Num, i, Con1.Con, p);
          Con1.Con^.SetCon(Con1.Num, pConnection(Poi), 1);
          Con2.Con^.SetCon(Con2.Num, pConnection(Poi), 2);
          InsertItem(pConnection(Poi), DragDC);
          pItem(Poi)^.CalcItemRect;
        end;
      ls_ConNode :
        begin
          { Rückgabe: Zeiger auf Verbindungsknoten. }
          if (RasterPos > 1)
          then PosCoord(tPoint(Msg.lParam));
          p := pConnection(p)^.InsertNode(@Self, tPoint(Msg.lParam));
          with pConnection(Poi)^
          do begin
            i := p^.GetInOutNr(tPoint(Msg.lParam));
            Init(Con1.Num, i, Con1.Con, p);
            Con1.Con^.SetCon(Con1.Num, pConnection(Poi), 1);
            p^.SetCon(i, pConnection(Poi), 2);
            InsertItem(pConnection(Poi), DragDC);
            pItem(Poi)^.CalcItemRect;
          end;
        end;
    end;
  EndDrag;
end;
{$ifdef PLA}
procedure lsPLAMatrix;
var
  p : pPLA;
  R : tRect;
begin
  p := pPLA(GetItem(tPoint(Msg.lParam)));
  if p <> nil
  then begin
    SetNotClose;
    p^.ToggleMatrix(tPoint(Msg.lParam));
    p^.Paint(DragDC);
    R := p^.ItemRect;
    pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).A);
    pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).B);
    InvalidateRect(hWindow, @R, TRUE);
  end;
  State := ls_None;
end;
{$endif}
begin
  inherited wmLButtonUp(Msg);
  case State of
    ls_MoveActItemB :
      begin { WMLButtonDown }
        ActItem^.NotPaint(DragDC);
        if xCollision and TouchItem(ActItem)
        then begin
          BeepMessage(102);
          ActItem^.NewPos(SavePos);
        end;
        InsertItem(ActItem, DragDC);
        EndDrag;
      end;
    ls_Connection : lsConnection;
    ls_ConnectionPt :
      with pConnectionPt(Poi)^
      do begin
        InsertItem(Connection, DragDC);
        Connection^.CalcItemRect;
        Dispose(pConnectionPt(Poi));
        EndDrag;
      end;
    ls_EditMove : lsEditMove_;
{$ifdef PLA}
    ls_PLAMatrix : lsPLAMatrix;
{$endif}
  end;
end;

procedure tLayoutWindow.WMLButtonDblclk(var Msg : tMessage);
var
  p : pItem;
begin
  pScrollerOrg(Scroller)^.ZoomCoord(tPoint(Msg.lParam));
  p := GetItem(tPoint(Msg.lParam));
  if p = nil
  then EditDel
  else begin
    if not TestOn
    then begin
      SetActItem(p);
      SendMessage( hWindow, WM_COMMAND, cm_ItemDlg, 0 );
    end;
  end;
end;

procedure tLayoutWindow.msGetContext(var Msg : tMessage);
begin
  Msg.Result := cs_LayWin;
end;

procedure tLayoutWindow.msTick(var Msg : tMessage);
var
  Impuls1,
  Impuls2,
  PaintCol : pCollection;
  PaintDC : hDC;
procedure DoTick(p : pImpulse); far;
begin
  p^.Tick(PaintCol, Impuls2);
  if p^.Time = $ffff
  then p^.Free
  else Impuls1^.Insert(p);
end;
procedure DoPaint(p:pItem); far;
begin
  p^.Paint_(PaintDC);
end;
{$ifdef layele}
procedure DoEleTick(p:pItem); far;
begin
  p^.EleTick;
end;
{$endif}
begin
  if TestOn
  then begin
    PaintDC := GetDC(hWindow);
    Impuls1 := New(pCollection, Init(20, 20));
    Impuls2 := New(pCollection, Init(20, 20));
    PaintCol := New(pCollection, Init(20, 20));
{$ifdef layele}
    Lay.Layout^.ForEach(@DoEleTick);
{$endif}
    while Impulses^.Count > 0
    do begin
      Impulses^.ForEach(@DoTick);
      Impulses^.DeleteAll;
      Dispose(Impulses, Done);
      Impulses := Impuls2;
      Impuls2 := New(pCollection, Init(20, 20));
    end;
    Dispose(Impulses, Done);
    Dispose(Impuls2, Done);
    Impulses := Impuls1;
    pScrollerOrg(Scroller)^.BeginZoom(PaintDC);
    PaintCol^.ForEach(@DoPaint);
    ReleaseDC(hWindow, PaintDC);
    PaintCol^.DeleteAll;
    Dispose(PaintCol, Done);

{$ifdef osc}
    SendMessage( OscWin^.hWindow, ms_Tick, 1, 0 );
{$endif}
  end;
end;

procedure tLayoutWindow.cmSimStart(var Msg : tMessage);
procedure DoInit(p : pItem); far;
begin
  p^.GetInitImpulse(Impulses);
end;
{$ifdef layele}
procedure DoSimStart(p : pItem); far;
begin
  p^.SimStart( hWindow );
end;
{$endif}
begin
  if not TestInit
  then begin
    InitTest;
    Lay.Layout^.ForEach(@DoInit);
    TestInit := True;
    InvalidateRect(hWindow, nil, True);
  end;
{$ifdef layele}
  Lay.Layout^.ForEach(@DoSimStart);
{$endif}
  TestOn := True;
  EditDel;
  MDI_Act;
end;

procedure tLayoutWindow.cmSimStop(var Msg : tMessage);
begin
  TestOn := False;
  MDI_Act;
end;

procedure tLayoutWindow.InitTest;
procedure DoReset(p : pItem); far;
begin
  p^.Reset;
end;
begin
  TestOn := False;
  TestInit := False;
  Impulses^.FreeAll;
  Lay.Layout^.ForEach(@DoReset);
end;

procedure tLayoutWindow.cmSimReset(var Msg : tMessage);
begin
  InitTest;
  MDI_Act;
  InvalidateRect(hWindow, nil, True);
end;

procedure tLayoutWindow.cmFileSaveAs(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_SaveAs, ext_LAY, hWindow);
end;

procedure tLayoutWindow.msExport(var Msg : tMessage);
var
  s : pChar;
begin
  inherited msExport(Msg);
  if not LongBool(Msg.Result)
  then begin
    GetMem(s, StrLen(LoadString0(83)) + 2 {+4-2});
    wvsprintf(s, @String0, extName[Msg.wParam]);
    MessageBox(hWindow, s, LoadString0(96), mb_IconStop or mb_OK);
    StrDispose(s);
  end;
end;

procedure tLayoutWindow.CalcEdit(R : tRect);
procedure DoCalc(p : pItem); far;
var Edit : hRgn;
begin
  Edit := p^.CalcEdit(R);
  if Edit <> 0
  then begin
    if EditLayout^.IndexOf(p) < 0 then
      EditLayout^.Insert(p);
    DeleteObject(Edit);
  end;
end;
procedure DoCon(p : pItem); far;
begin
  if (EditLayout^.IndexOf(p) < 0) and (p^.Full_in_Lay(EditLayout)) then
    EditLayout^.Insert(p);
end;
begin
  Lay.Layout^.ForEach(@DoCalc);
  Lay.Layout^.ForEach(@DoCon);
end;

procedure tLayoutWindow.DelEdit;
begin
  EditLayout^.DeleteAll;
end;

function tLayoutWindow.IsEditEmpty : Boolean;
begin
  IsEditEmpty := EditLayout^.Count=0;
end;

procedure tLayoutWindow.InvertEdit(PaintDC : HDC);
var Rgn : hRgn;
procedure DoNotPaint(p : pItem); far;
begin
  Rgn := p^.GetRegion;
  InvertRgn(PaintDC, Rgn);
  DeleteObject(Rgn);
end;
begin
  SetWindowOrg(PaintDC, 0, 0);
  EditLayout^.ForEach(@DoNotPaint);
end;

procedure tLayoutWindow.cmEditDelete(var Msg : tMessage);
procedure DoDispose(p : pItem); far;
begin
  if Lay.Layout^.IndexOf(p) >= 0
  then begin
    { Vgl. mit lsDeleteItem. }
    DeleteItem(p);
{$ifdef osc}
    p^.DelOscCon(OscWin^.hWindow);
{$endif}
    p^.DisposeCon;
    Dispose(p, Done);
  end;
end;
var
  p : pItem;
  EL : pCollection;
begin
  if (not MessageOn) or
     (MessageBox(
        hWindow, LoadString0(52), LoadString1(96),
        mb_IconQuestion or mb_YesNo) = idYes)
  then begin
    el := EditLayout;
    EditLayout := New(pCollection, Init(40, 40));
    el^.ForEach(@DoDispose);
    el^.DeleteAll;
    Dispose(el, Done);
    EditDel;
  end;
end;

procedure tLayoutWindow.cmEditCopy(var Msg : tMessage);
var
  S : tGlobalStream;
  Layout_ : pCollection;
begin
  { Edit in Stream speichern. }
  Layout_ := Lay.Layout;
  Lay.Layout := EditLayout;
  S.Init;
  Lay.Store(S);
  Lay.Layout := Layout_;
  { Daten ins Clipboard kopieren. }
  OpenClipBoard(hWindow);
  EmptyClipBoard;
  SetClipboardData(cf_Layout, S.Handle);
  CloseClipBoard;
  S.Done_; { Der Handle wird nicht freigegeben. }
  MDI_Act;
end;

procedure tLayoutWindow.cmEditPaste(var Msg : tMessage);
var Lay_ : tLay;
procedure DoInsert(p : pEleFile); far;
begin
  if Lay_.EleFiles^.IndexOf(p) >= 0
  then p^.DecCount
  else Lay_.EleFiles^.Insert(p);
end;
procedure DoNotPaint(p : pItem); far;
begin
  p^.NotPaint(DragDC);
end;
procedure cfBitmap;
var
  bmp : tBitmap;
  col_size : Integer;
  bmp_size : Longint;
  hbmp : hBitmap;
  h : tHandle;
  i : Integer;
  p : Pointer;
  PaintDC : hDC;
begin
  OpenClipboard(hWindow);
  hbmp := GetClipboardData(CF_BITMAP);
  GetObject(hbmp, SizeOf(bmp), @bmp);
  PaintDC := GetDC(hWindow);
  case bmp.bmBitsPixel of
    1 : i:=2;
    4 : i:=16;
    8 : i:=256;
    else i:=0;
  end;
  col_size := i*SizeOf(tRGBQuad)*bmp.bmPlanes;
  bmp_size := bmp.bmWidthBytes*bmp.bmHeight;
  h := GlobalAlloc(GPTR, SizeOf(tBitmapInfoHeader)+col_size+bmp_size);
  p := GlobalLock(h);
  with tBitmapInfo(p^).bmiHeader
  do begin
    biSize := SizeOf(tBitmapInfoHeader);
    biWidth := bmp.bmWidth;
    biHeight := bmp.bmHeight;
    biPlanes := bmp.bmPlanes;
    biBitCount := bmp.bmBitsPixel;
    biCompression := BI_RGB;
    biSizeImage := bmp_size;
    biXPelsPerMeter := 1;
    biYPelsPerMeter := 1;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  GetDIBits(
    PaintDC,
    hbmp, 0, bmp.bmHeight,
    @(pByteArray(p)^[SizeOf(tBitmapInfoHeader)+col_size]),
    tBitmapInfo(p^), DIB_RGB_COLORS);
  ReleaseDC(hWindow, PaintDC);
  InitItem(New(pItemBitmap, Init(h)));
  GlobalUnlock(h);
  GlobalFree(h);
  CloseClipboard;
end;
var
  S : tGlobalStream; { CF_LAYOUT }
  h : tHandle; { CF_TEXT, CF_DIB, CF_BITMAP }
  p : Pointer; { CF_TEXT, CF_LAYOUT }
begin
  if IsClipboardFormatAvailable(CF_LAYOUT)
  then begin
    EditDel;
    BeginDrag;
    UpdateWindow(hWindow);
    { Layout aus Clipboard laden. }
    Lay_ := Lay;
    Lay.EleFiles := New(pCollection, Init(5, 3));
    Lay.Layout := New(pCollection, Init(50, 50));
    S.Init;
    OpenClipboard(hWindow);
    S.Handle := GetClipboardData(cf_Layout);
    Lay.Load(S);
    CloseClipboard;
    S.Done_; { Der Handle wird nicht freigegeben. }
    { Clipboard nach Edit und vorherige Schaltung wieder setzen. }
    EditLayout := Lay.Layout;
    Lay.EleFiles^.ForEach(@DoInsert);
    Lay.EleFiles^.DeleteAll;
    Dispose(Lay.EleFiles, Done);
    Lay := Lay_;
    State := ls_EditMoveB;
    SetCursorActState;
    GetMem(Poi, SizeOf(tEditMoveRec));
    with tEditMoveRec(Poi^)
    do begin
      xIsPasted:=True;
      p := pItem(EditLayout^.At(0))^.Position;
      xA := tPoint(p^)
    end;
    EditLayout^.ForEach(@DoNotPaint);
  end
  else if IsClipboardFormatAvailable(CF_TEXT)
  then begin
    OpenClipboard(hWindow);
    h := GetClipboardData(CF_TEXT);
    p := GlobalLock(h);
    InitItem(New(pItemText, Init(pChar(p), FontData)));
    GlobalUnlock(h);
    CloseClipboard;
  end
  else if IsClipboardFormatAvailable(CF_DIB)
  then begin
    OpenClipboard(hWindow);
    h := GetClipboardData(CF_DIB);
    InitItem(New(pItemBitmap, Init(h)));
    CloseClipboard;
  end
  else if IsClipboardFormatAvailable(CF_BITMAP)
  then cfBitmap
  else begin
    MessageBeep(29);
  end;
end;

(*procedure tLayoutWindow.cmExportBMP(var Msg : tMessage);
var
  R : tRect;
  ps : tPaintStruct;
  hBMP : hBitmap;
  bmp : tHandle;
begin
  GetClientRect(hWindow, R);
  with tRect_(R)
  do begin
    hBMP := CreateCompatibleBitmap(hWindow, Right, Bottom);
    pScrollerOrg(Scroller)^.ZoomCoord(A);
    pScrollerOrg(Scroller)^.ZoomCoord(B);
  end;
  with ps
  do begin
    hDC := hBMP;
    rcPaint := R;
    fErase := False;
  end;
  Paint(hBMP, ps);
  OpenClipBoard(hWindow);
  EmptyClipBoard;
  SetClipboardData(cf_Bitmap, hBMP);
  CloseClipBoard;
end;

procedure tLayoutWindow.cmExportWMF(var Msg : tMessage);
var
  ps : tPaintStruct;
  hWMF : tHandle;
begin
  hWMF := CreateMetaFile(nil);
  with ps
  do begin
    hDC := hWMF;
    fErase := False;
    {rcPaint := R;}
    fRestore := False;
  end;
  Paint(hWMF, ps);
  hWMF := CloseMetaFile(hWMF);
  OpenClipBoard(hWindow);
  EmptyClipBoard;
  SetClipboardData(cf_DspMetafilePict, hWMF);
  CloseClipBoard;
end;*)

procedure tLayoutWindow.cmItemText(var Msg : tMessage);
var s : tString;
begin
  s[0] := #0;
  if Application^.ExecDialog(
       New(pTextDlg, Init(@Self, @s, 7, StringLen))) = id_OK
  then InitItem(New(pItemText, Init(s, FontData)));
end;

{$ifdef ROMRAM}
type
  pROMRAM = ^tROMRAM;
  tROMRAM = object (tDialogSB)
    p : Pointer;
    xNumAdr, xNumData : Byte;
    xEnable, xIsRAM : Boolean;
    constructor Init(xParent : pWindowsObject; xp : Pointer);
    procedure SetupWindow; virtual;
    procedure wmCommand(var Msg : tMessage);
      virtual wm_First + wm_Command;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tROMRAM.Init(xParent : pWindowsObject; xp : Pointer);
begin
  inherited Init(xParent, 'ROMRAMDLG');
  p := xp;
  xNumAdr := 1;
  xNumData := 1;
  xEnable := False;
  xIsRAM := False;
end;

procedure tROMRAM.SetupWindow;
begin
  inherited SetupWindow;
  CheckDlgButton(hWindow, 101, 1);
  CheckDlgButton(hWindow, 111, 1);
  CheckDlgButton(hWindow, 121, 1);
end;

procedure tROMRAM.wmCommand(var Msg : tMessage);
begin
  with Msg do
    case wParam of
      100..109 : xNumAdr := wParam-100;
      110..119 : xNumData := wParam-110;
      120 : xEnable := not xEnable;
      121 : xIsRAM := False;
      122 : xIsRAM := True;
      else inherited wmCommand(Msg);
    end;
end;

procedure tROMRAM.OK(var Msg : tMessage);
var i : Integer;
begin
  i := GetDlgItemInt(hWindow, 130, nil, False);
  if i <= 0 then i := 1;
  pItem(p^) := New(pROM, Init(xNumAdr, xNumData, xEnable, xIsRAM, i));
  EndDlg(id_OK);
end;

procedure tLayoutWindow.cmROMRAM(var Msg : tMessage);
var p : pItem;
begin
  if Application^.ExecDialog(New(pROMRAM, Init(@Self, @p))) = id_OK
  then InitItem(p);
end;
{$endif}

{$ifdef PLA}
type
  pPLA_Dlg = ^tPLA_Dlg;
  tPLA_Dlg = object (tDialogSB)
    p : Pointer;
    constructor Init(xParent : pWindowsObject; xp : Pointer);
    procedure SetupWindow; virtual;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
  end;

constructor tPLA_Dlg.Init(xParent : pWindowsObject; xp : Pointer);
begin
  inherited Init(xParent, 'PLAINITDLG');
  p := xp;
end;

procedure tPLA_Dlg.SetupWindow;
begin
  inherited SetupWindow;
end;

procedure tPLA_Dlg.OK(var Msg : tMessage);
var
  NumIn, NumOut,
  NumLines,
  Time : Integer;
begin
  NumIn := Integer(GetDlgItemInt(hWindow, 100, nil, FALSE));
  NumOut := Integer(GetDlgItemInt(hWindow, 101, nil, FALSE));
  NumLines := Integer(GetDlgItemInt(hWindow, 102, nil, FALSE));
  Time := Integer(GetDlgItemInt(hWindow, 130, nil, FALSE));
  pItem(p^) := New(pPLA, Init(NumIn, NumOut, NumLines, Time));
  EndDlg(id_OK);
end;

procedure tLayoutWindow.cmPLA(var Msg : tMessage);
var p : pItem;
begin
  if Application^.ExecDialog(New(pPLA_Dlg, Init(@Self, @p))) = id_OK
  then InitItem(p);
end;
{$endif}

procedure tLayoutWindow.cmHelpContext(var Msg : tMessage);
begin
  WinHelp(hWindow, HelpFileName, HELP_CONTEXT, 200);
end;

procedure tLayoutWindow.cmDeleteItem(var Msg : tMessage);
begin
  case state of
    ls_None:
      begin
        if EditLayout^.Count > 0
        then begin
          cmEditDelete(Msg);
        end
        else begin
          if ActItem <> nil
          then begin
            SetNotClose;
            DeleteItem(ActItem);
{$ifdef osc}
            ActItem^.DelOscCon(OscWin^.hWindow);
{$endif}
            ActItem^.DisposeCon;
            Dispose(ActItem, Done);
            SetActItem(nil);
          end;
        end;
      end;
    ls_MoveActItem,
    ls_MoveActItemB :
      begin
        ActItem^.NotPaint(DragDC);
        EndDrag;
      end;
  end; {of case}
end;

procedure tLayoutWindow.cmDelAllPt;
begin
  if ActItem <> nil
  then begin
    BeginDrag;
    DeleteItem(ActItem);
    pConnection(ActItem)^.DelAllPt;
    InsertItem(ActItem, DragDC);
    ActItem^.CalcItemRect;
    EndDrag;
  end;
end;

procedure tLayoutWindow.cmItemDlg(var Msg : tMessage);
var
  R1, R2, R_ : tRect;
  Rgn : hRgn;
  ActLay_ : pLay;
begin
  SetNotClose;
  R1 := ActItem^.ItemRect;
  Rgn := ActItem^.GetRegionCon;
  GetRgnBox(Rgn, R_);
  DeleteObject(Rgn);
  UnionRect(R1, R1, R_);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R1).A);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R1).B);
  EditDel;
  ActLay_ := SetActLay(@Lay);
  ActItem^.ItemEdit(@Self);
  SetActLay(ActLay_);
  ActItem^.OutImpulse(Impulses);
  R2 := ActItem^.ItemRect;
  Rgn := ActItem^.GetRegionCon;
  GetRgnBox(Rgn, R_);
  DeleteObject(Rgn);
  UnionRect(R2, R2, R_);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R2).A);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R2).B);
  InvalidateRect(hWindow, @R1, TRUE);
  InvalidateRect(hWindow, @R2, TRUE);
end;

procedure tLayoutWindow.cmSwitchState(var Msg : tMessage);
var
  R : tRect_;
begin
  SetNotClose;
  ActItem^.Toggle(tRect_(R).A); { Übergebene Koordinaten egal,
                                  da der Schalter diesen Parameter ignoriert. }
  ActItem^.GetInitImpulse(Impulses);
  R := tRect_(ActItem^.ItemRect);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).A);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).B);
  InvalidateRect( hWindow, @R, true );
  MDI_Act;
end;

procedure tLayoutWindow.cmTickState(var Msg : tMessage);
var
  R : tRect_;
begin
  SetNotClose;
  with pTick(ActItem)^ do
    on_ := not on_;
  ActItem^.GetInitImpulse(Impulses);
  R := tRect_(ActItem^.ItemRect);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).A);
  pScrollerOrg(Scroller)^.ClientCoord(tRect_(R).B);
  InvalidateRect( hWindow, @R, true );
  MDI_Act;
end;

{$ifdef osc}
procedure tLayoutWindow.cmOscRecord( var Msg : tMessage );
begin
  SendMessage( OscWin^.hWindow, ms_OscAddCon, hWindow, Longint(ActItem) );
end;

procedure tLayoutWindow.msOscIsRecCon( var Msg : tMessage );
begin
  with Msg do
    Result := SendMessage( OscWin^.hWindow, Message, wParam, lParam );
end;
{$endif}

procedure tLayoutWindow.msItemIndex( var Msg : tMessage );
begin
  with Msg do
    if wParam = 0
    then Result := Lay.Layout^.IndexOf( pItem(lParam) )
    else Result := longint(Lay.Layout^.At(lParam));
end;

{$ifdef osc}
procedure tLayoutWindow.msSetCaption( var Msg : tMessage );
begin
  inherited msSetCaption(Msg);
  SendMessage( OscWin^.hWindow, ms_SetCaption, 0, Msg.lParam );
end;
{$endif}

{$ifdef PLA}
procedure tLayoutWindow.cmPLADelIn( var Msg : tMessage );
begin
  SetNotClose;
  pPLA(ActItem)^.DelInNodes;
  InvalidateActItem;
end;

procedure tLayoutWindow.cmPLADelOut( var Msg : tMessage );
begin
  SetNotClose;
  pPLA(ActItem)^.DelOutNodes;
  InvalidateActItem;
end;

procedure tLayoutWindow.cmPLADelAll( var Msg : tMessage );
begin
  SetNotClose;
  pPLA(ActItem)^.DelInNodes;
  pPLA(ActItem)^.DelOutNodes;
  InvalidateActItem;
end;
{$endif}

procedure tLayoutWindow.InvalidateItem( p : pItem );
var
  Rgn : hRgn;
  R : tRect;
begin
  Rgn := p^.GetRegion;
  GetRgnBox(Rgn, R);
  DeleteObject(Rgn);
  InflateRect(R, 1, 1);
  with tRect_(R)
  do begin
    pScrollerOrg(Scroller)^.ClientCoord(A);
    pScrollerOrg(Scroller)^.ClientCoord(B);
  end;
  InvalidateRect(hWindow, @R, True);
end;

procedure tLayoutWindow.InvalidateActItem;
begin
  InvalidateItem( ActItem );
end;

{$ifdef layele}
procedure tLayoutWindow.msMacroImpulse( var Msg : tMessage );
begin
  Impulses^.Insert( pImpulse(Msg.lParam) );
end;

procedure tLayoutWindow.msMacroPaint( var Msg : tMessage );
begin
  InvalidateItem( pItem(Msg.lParam) );
end;
{$endif}

{$ifdef osc}
procedure tLayoutWindow.WMSysCommand(var Msg : tMessage);
begin
  case Msg.wParam of
    cm_ShowOscWin : cmShowOscWin(Msg);
  else
    inherited WMSysCommand(Msg);
  end;
end;

procedure tLayoutWindow.cmShowOscWin(var Msg : tMessage);
begin
  SendMessage( OscWin^.hWindow, ms_ShowWindow, 0, 0 );
end;
{$endif}

{$ifdef undo}
procedure tLayoutWindow.DelUndo;
begin
  EditLayout^.DeleteAll;
  Impulses^.FreeAll;
  Lay.DelUndo;
{$ifdef osc}
  OscWin^.DelUndo;
{$endif}

  ActItem := nil;
  State := ls_None;
  OldEleFile := 0;
  NameEx := False;
  FontData := FontDataOpt;
end;
{$endif}

{$ifdef layele}
procedure tLayoutWindow.cmShowMacro(var Msg : tMessage);
begin
  ActItem^.ShowMacro;
end;
{$endif}

end.