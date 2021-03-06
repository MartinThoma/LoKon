unit Paint;
{$I define.inc}

interface

uses
  LK_Const, Messages,
  Strings,
  Objects,
  WinTypes, WinProcs,
  OWindows, ODialogs,
  OPrinter,
  OWinEx,
  ScrolOrg;

const
  id_TestText     =  100;
  id_ScrollHeight =  101;
  id_ScrollWidth  =  102;
  id_HeightText   =  103;
  id_WidthText    =  104;
  id_TextDirect   =  105;
  id_ScrollDirect =  106;

type
  pFontDialog = ^tFontDialog;
  tFontDialog = object (tDialogEx)
    FD : ^tFontData;
    FontData : tFontData;
    Font : hFont;
    constructor Init(xParent : pWindowsObject; xFD : Pointer);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure WMCommand(var Msg: TMessage); virtual wm_First + wm_Command;
    procedure UpdateFont;
    procedure idScrollHeight(var Msg : tMessage);
      virtual id_First + id_ScrollHeight;
    procedure idScrollWidth(var Msg : tMessage);
      virtual id_First + id_ScrollWidth;
    procedure idScrollDirect(var Msg : tMessage);
      virtual id_First + id_ScrollDirect;
    procedure OK(var Msg : tMessage);
      virtual id_First + id_OK;
    procedure CMHelp(var Msg : tMessage);
      virtual CM_FIRST + CM_HELPCONTEXT;
  end;

type
  pPaint = ^tPaint;
  tPaint = object (tWindowEx)
    Raster : Shortint;
    RasterFront : Boolean;
    State : Integer;
    Poi : Pointer;
    DragDC : hDC;
    NotClose : Boolean;
    FontData : tFontData;
    IsRasterPos : Boolean;
    RasterIncX, RasterIncY,
    RasterMulX, RasterMulY,
    crossX, crossY : integer;
{$ifdef undo}
    UndoBuf : pCollection;
    RedoBuf : pCollection;
{$endif}
    procedure Init(aParent : pWindowsObject; s : pChar);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure Load(var S : tStream); virtual;
    procedure Store(var S : tStream); virtual;
    procedure MDI_Act; virtual;
    procedure MDI_Menu(b : Boolean); virtual;
    procedure SetRaster(xRaster : Integer);
    procedure SetRasterFront(xRasterFront : Boolean);
    procedure msSetZoom(var Msg : tMessage);
      virtual ms_SetZoom;
    procedure SetCursorOfState(xState : Integer); virtual;
    procedure SetCursorActState;
    procedure BeginDrag;
    procedure EndDrag;
    procedure wmPaint(var Msg : tMessage);
      virtual wm_First + wm_Paint;
    procedure RasterPaint(PaintDC : hDC; var PaintInfo : tPaintStruct);
    {procedure Paint(PaintDC : hDC; var PaintInfo : tPaintStruct);}
    procedure cmRasterOff(var Msg : tMessage);
      virtual cm_First + cm_RasterOff;
    procedure cmRasterBig(var Msg : tMessage);
      virtual cm_First + cm_RasterBig;
    procedure cmRasterSmall(var Msg : tMessage);
      virtual cm_First + cm_RasterSmall;
    procedure cmRasterFront(var Msg : tMessage);
      virtual cm_First + cm_RasterFront;
    procedure cmRasterBack(var Msg : tMessage);
      virtual cm_First + cm_RasterBack;
    procedure cmZoomBox(var Msg : tMessage);
      virtual cm_First + cm_ZoomBox;
    procedure cmZoom90(var Msg : tMessage);
      virtual cm_First + cm_Zoom90;
    procedure cmZoom75(var Msg : tMessage);
      virtual cm_First + cm_Zoom75;
    procedure cmZoom50(var Msg : tMessage);
      virtual cm_First + cm_Zoom50;
    procedure cmZoomAll(var Msg : tMessage);
      virtual cm_First + cm_ZoomAll;
    procedure cmPaint(var Msg : tMessage);
      virtual cm_First + cm_Paint;
    procedure cmPos1(var Msg : tMessage);
      virtual cm_First + cm_Pos1;
    procedure cmPos5(var Msg : tMessage);
      virtual cm_First + cm_Pos5;
    procedure cmPos10(var Msg : tMessage);
      virtual cm_First + cm_Pos10;
    procedure DragEdit(A : tPoint);
    procedure EditDel;
    function IsEditEmpty : Boolean; virtual;
    procedure InvertEdit(PaintDC : HDC); virtual;
    procedure cmEditCut(var Msg : tMessage);
      virtual cm_First + cm_EditCut;
    procedure cmEditAll(var Msg : tMessage);
      virtual cm_First + cm_EditAll;
    procedure cmEditDel(var Msg : tMessage);
      virtual cm_First + cm_EditDel;
    procedure CalcEdit(R : tRect); virtual;
    procedure DelEdit; virtual;
    procedure PosCoord(var A : tPoint);
    procedure WMMouseMove(var Msg : tMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonDown(var Msg : tMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg : tMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMRButtonDown(var Msg : tMessage);
      virtual WM_FIRST + WM_RBUTTONDOWN;
    procedure cmFileSaveAs(var Msg : tMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure cmFileExport(var Msg : tMessage);
      virtual cm_First + cm_FileExport;
    procedure msExport(var Msg : tMessage);
      virtual ms_Export;
    procedure msPrint(var Msg : tMessage);
      virtual ms_Print;
    procedure cmFont(var Msg : tMessage);
      virtual cm_First + cm_Font;
    procedure cmExportBMP(var Msg : tMessage);
      virtual cm_First + cm_ExportBMP;
    procedure MSEndDrag(var Msg : tMessage);
      virtual MS_ENDDRAG;
    procedure msIsShown(var Msg : tMessage);
      virtual ms_IsShown;
{$ifdef undo}
    procedure SaveUndo( buf : pCollection );
    procedure cmUndo(var Msg : tMessage);
      virtual cm_First + cm_Undo;
    procedure cmRedo(var Msg : tMessage);
      virtual cm_First + cm_Redo;
    { Gesamtes Fenster l�schen, um aus Undo Puffer laden zu k�nnen. }
    procedure DelUndo; virtual;
    procedure msFreeUndo(var Msg : tMessage);
      virtual ms_FreeUndo;
{$endif}
    procedure SetNotClose;
  end;

implementation

{ ------ tPaintPrintOut ------------------------------------------------- }

type
  pPaintPrintout = ^tPaintPrintout;
  tPaintPrintout = object(tPrintOut)
    Window : pPaint;
    constructor Init(AWindow : pPaint);
    function GetDialogInfo(var Pages : Integer) : Boolean; virtual;
    procedure PrintPage(
      Page : Word; var Rect : TRect; Flags : Word); virtual;
  end;

constructor tPaintPrintout.Init(aWindow : pPaint);
var
  l : Integer;
  s : pChar;
begin
  l := GetWindowTextLength(aWindow^.hWindow);
  GetMem(s, l + 1);
  GetWindowText(aWindow^.hWindow, s, l+1);
  inherited Init(s);
  StrDispose(s);
  Window := aWindow;
end;

procedure tPaintPrintout.PrintPage(
  Page : Word; var Rect : TRect; Flags : Word);
var
{$ifdef test}
{$ifndef mini}
  Font : hFont;
  i : Integer;
{$endif}
{$endif}
  PS : TPaintStruct;
  PrevMode : Integer;
  WindowSize : TRect;
  OldVExt, OldWExt : Longint;
  OldZoom : Integer;
  R : tRect;
  w1, w2,
  zx, zy : Real;
{$ifdef test}
{$ifndef mini}
  ColorRef : TColorRef;
  RasterFront_ : Boolean;
{$endif}
{$endif}
begin
  { Fake up a TPaintStruct to give the window banding information }
  with PS
  do begin
    rcPaint := Rect;
    fErase := False;
    fRestore := False;
  end;
{$ifdef personal_print}
  i := (Rect.right-Rect.left) div 40;
  Font := CreateFont(
    i-2, 0,
    900, 900,
    700,
    0, 0, 0,
    ANSI_Charset, Font_Precis,
    0, Font_Quality, 1, 'Arial');
  SelectObject(DC, Font);
  TextOut(DC, Rect.right-i, Rect.bottom, @person_, StrLen(@person_));
  DeleteObject(Font);
  dec(Rect.right, 2*i);
{$endif}
  { BeginPrint }
  GetClientRect(Window^.hWindow, R);
{$ifdef test}
{$ifndef mini}
  if expired
  then begin
    SetBkMode( DC, TRANSPARENT );
    ColorRef := SetTextColor( DC, RGB( 63, 63, 0 ) );
    font := CreateFont(
      Rect.bottom-Rect.top, (Rect.right-Rect.left) div 10,
      0, 0,
      700,
      0, 0, 0,
      ANSI_CHARSET,
      0, 0,
      0, 0,
      'Arial' );
    font := SelectObject( DC, font );
    TextOut( DC, 2, 2, 'EXPIRED', 7 );
    DeleteObject(SelectObject( DC, font ));
    SetTextColor( DC, COlorRef );
    RasterFront_ := pPaint(Window)^.RasterFront;
    pPaint(Window)^.RasterFront := True;
  end;
{$endif}
{$endif}
  w1 := R.Right-R.left;
  w2 := Rect.Right-Rect.left;
  zx := w1 / w2;
  w1 := R.Bottom-R.top;
  w2 := Rect.Bottom-Rect.top;
  zy := w1 / w2;
  if zy > zx then zx := zy;
  zx := 1000.0 * zx;
  pScrollerOrg(Window^.Scroller)^.BeginPrint(DC, ps, trunc(zx));
  { Call the window to paint itself. }
  Window^.RasterPaint(DC, PS);
{$ifdef test}
{$ifndef mini}
  pPaint(Window)^.RasterFront := RasterFront_;
{$endif}
{$endif}
end;

function tPaintPrintout.GetDialogInfo(var Pages: Integer): Boolean;
begin
  Pages := 0;
  GetDialogInfo := False;
end;

{ ------ tFontDialog ---------------------------------------------------- }

constructor tFontDialog.Init(xParent : pWindowsObject; xFD : Pointer);
begin
  inherited Init(xParent, 'FONTDLG');
  FD := xFD;
  FontData := tFontData(xFD^);
  Font := 0;
end;

destructor tFontDialog.Done;
begin
  DeleteObject(Font);
  inherited Done;
end;

type tdInt = record i1, i2 : Integer; end;

procedure tFontDialog.SetupWindow;
var
  dInt : tdInt;
  i : Byte;
begin
  inherited SetupWindow;
  SetScrollRange(GetDlgItem(hWindow, id_ScrollHeight),
    sb_Ctl, 0, MaxFontVal, False);
  SetScrollRange(GetDlgItem(hWindow, id_ScrollWidth),
    sb_Ctl, 0, MaxFontVal, False);
  SetScrollRange(GetDlgItem(hWindow, id_ScrollDirect),
    sb_Ctl, 0, 3600, False);
  with FontData
  do begin
    SetScrollPos(GetItemHandle(id_ScrollHeight), sb_Ctl, Height, False);
    SetDlgItemInt(hWindow, id_HeightText, Height, False);
    SetScrollPos(GetItemHandle(id_ScrollWidth), sb_Ctl, Width, False);
    SetDlgItemInt(hWindow, id_WidthText, Width, False);
    dInt.i1 := Direct div 10;
    dInt.i2 := Direct mod 10;
    wvsprintf(@String0, '%i.%i', dInt);
    SetScrollPos(GetItemHandle(id_ScrollDirect), sb_Ctl, Direct, False);
    SetDlgItemText(hWindow, id_TextDirect, @String0);
    CheckDlgButton(hWindow, 110+FontNr, 1);
    for i := 0 to 3 do
      CheckDlgButton(hWindow, 120+i, FontFlag and (Byte(1) shl i));
  end;
  UpdateFont;
end;

procedure tFontDialog.wmCommand(var Msg : tMessage);
procedure idFontNr;
begin
  FontData.FontNr := Msg.wParam-110;
  UpdateFont;
end;
procedure idFontFlag;
var Mask : Byte;
begin
  Mask := Byte(1) shl (Msg.wParam-120);
  with FontData
  do FontFlag := FontFlag xor Mask;
  UpdateFont;
end;
begin
  case Msg.wParam of
    110..119 : idFontNr;
    120..129 : idFontFlag;
    else inherited wmCommand(Msg);
  end;
end;

procedure tFontDialog.UpdateFont;
begin
  DeleteObject(Font);
  with FontData do
    Font := CreateFont(
      Height, Width,
      Direct, Direct,
      400 + 300 * (FontFlag and $01),
      FontFlag and $02,
      FontFlag and $04,
      FontFlag and $08, ANSI_Charset, 6 {Out_Raster_Precis},
      0, 1 {Draft_Quality}, 1, FontName[FontNr]);
  SendDlgItemMsg(id_TestText, wm_SetFont, Font, 1);
end;

procedure tFontDialog.idScrollHeight(var Msg : tMessage);
begin
  if Msg.Message = wm_VScroll then
    with FontData
    do begin
      case Msg.wParam of
        sb_LineUp : dec(Height);
        sb_LineDown : inc(Height);
        sb_PageUp : dec(Height, 5);
        sb_PageDown : inc(Height, 5);
        sb_ThumbTrack,
        sb_ThumbPosition : Height := Msg.lParamLo;
      end;
      if Height < 0 then Height := 0;
      if Height > MaxFontVal then Height := MaxFontVal;
      SetScrollPos(Msg.lParamHi, sb_Ctl, Height, True);
      SetDlgItemInt(hWindow, id_HeightText, Height, False);
      UpdateFont;
    end;
end;

procedure tFontDialog.idScrollWidth(var Msg : tMessage);
begin
  if Msg.Message = wm_HScroll then
    with FontData
    do begin
      case Msg.wParam of
        sb_LineUp : dec(Width);
        sb_LineDown : inc(Width);
        sb_PageUp : dec(Width, 5);
        sb_PageDown : inc(Width, 5);
        sb_ThumbTrack,
        sb_ThumbPosition : Width := Msg.lParamLo;
      end;
      if Width < 0 then Width := 0;
      if Width > MaxFontVal then Width := MaxFontVal;
      SetScrollPos(Msg.lParamHi, sb_Ctl, Width, True);
      SetDlgItemInt(hWindow, id_WidthText, Width, False);
      UpdateFont;
    end;
end;

procedure tFontDialog.idScrollDirect(var Msg : tMessage);
var dInt : tdInt;
begin
  with Msg
  do begin
    if Message = wm_HScroll then
      with FontData
      do begin
        case wParam of
          sb_LineUp : dec(Direct, 5);
          sb_LineDown : inc(Direct, 5);
          sb_PageUp : dec(Direct, 50);
          sb_PageDown : inc(Direct, 50);
          sb_ThumbTrack,
          sb_ThumbPosition : Direct := (lParamLo div 5) * 5;
        end;
        if Direct < 0 then Direct := 3600 + Direct;
        if Direct >= 3600 then Direct := Direct - 3600;
        SetScrollPos(lParamHi, sb_Ctl, Direct, True);
        dInt.i1 := Direct div 10;
        dInt.i2 := Direct mod 10;
        wvsprintf(@String0, '%i.%i', dInt);
        SetDlgItemText(hWindow, id_TextDirect, @String0);
        if wParam <> sb_ThumbTrack then UpdateFont;
      end;
  end;
end;

procedure tFontDialog.OK(var Msg : tMessage);
begin
  FD^ := FontData;
  inherited OK(Msg);
end;

procedure tFontDialog.CMHelp(var Msg : tMessage);
begin
  WinHelp(hMainWin, HelpFileName, HELP_CONTEXT, 120);
end;

{ ------ tPaint --------------------------------------------------------- }

procedure tPaint.Init(aParent : pWindowsObject; s : pChar);
begin
  inherited Init(aParent, s);
  Raster := xRaster;
  RasterFront := xRasterFront;
  Scroller := New(pScrollerOrg, Init(@Self, -10000, -10000, 20000, 20000));
  NotClose := False;
  IsRasterPos := True;
  RasterIncX := 10;
  RasterIncY := 10;
  RasterMulX := 5;
  RasterMulY := 5;
  crossX := 2;
  crossY := 2;
{$ifdef undo}
  UndoBuf := New( pCollection, Init(20, 20) );
  RedoBuf := New( pCollection, Init(10, 10) );
{$endif}
end;

destructor tPaint.Done;
begin
  EndDrag;
{$ifdef undo}
  Dispose( UndoBuf, Done );
  Dispose( RedoBuf, Done );
{$endif}
  inherited Done;
end;

procedure tPaint.SetupWindow;
begin
  inherited SetupWindow;
  Scroller^.ScrollTo(0, 0);
end;

procedure tPaint.Load(var S : tStream);
begin
  S.Read(Raster, SizeOf(Raster) + SizeOf(RasterFront));
  pScrollerOrg(Scroller)^.Load(S);
end;

procedure tPaint.Store(var S : tStream);
begin
  S.Write(Raster, SizeOf(Raster) + SizeOf(RasterFront));
  pScrollerOrg(Scroller)^.Store(S);
end;

procedure tPaint.MDI_Act;
var
  Menu : hMenu;
  R : tRect;
begin
  inherited MDI_Act;
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  EnableMenuItem(Menu, cm_Print, mf_ByCommand or mf_Enabled);
  EnableMenuItem(Menu, cm_FileSaveAs, mf_ByCommand or mf_Enabled);
  EnableMenuItem(Menu, cm_FileExport, mf_ByCommand or mf_Enabled);
  { Edit-Funktionen aktivieren. }
  EnableMenuItem(Menu, cm_EditAll, mf_ByCommand or mf_Enabled);
  EnableMenuItem(Menu, cm_EditDel, mf_ByCommand or mf_Enabled);
  CheckMenuItem(Menu, cm_RasterOff, mf_ByCommand or mf_Unchecked);
  CheckMenuItem(Menu, cm_RasterBig, mf_ByCommand or mf_Unchecked);
  CheckMenuItem(Menu, cm_RasterSmall, mf_ByCommand or mf_Unchecked);
  case Raster of
    0 : CheckMenuItem(Menu, cm_RasterOff, mf_ByCommand or mf_Checked);
    1 : CheckMenuItem(Menu, cm_RasterBig, mf_ByCommand or mf_Checked);
    2 : CheckMenuItem(Menu, cm_RasterSmall, mf_ByCommand or mf_Checked);
  end;
  if RasterFront then
    ModifyMenu(
      pWindow(Application^.MainWindow)^.Attr.Menu,
      cm_RasterFront, mf_ByCommand,
      cm_RasterBack, LoadString0(18));
  { Edit-Menu. }
  if IsEditEmpty
  then begin
    EnableMenuItem(Menu, cm_EditDelete, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditCopy, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditCut, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_EditCopy);
    EnableMenuItem(Menu, cm_ExportBMP, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_ExportWMF, mf_ByCommand or mf_Grayed);
  end
  else begin
    EnableMenuItem(Menu, cm_EditDelete, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_EditCopy, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_EditCut, mf_ByCommand or mf_Enabled);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditCut);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, SBActive or cm_EditCopy);
    EnableMenuItem(Menu, cm_ExportBMP, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Menu, cm_ExportWMF, mf_ByCommand or mf_Enabled);
  end;
  { Undo/Redo }
{$ifdef undo}
  if UndoBuf^.Count > 0
  then EnableMenuItem(Menu, cm_Undo, mf_ByCommand or mf_Enabled)
  else EnableMenuItem(Menu, cm_Undo, mf_ByCommand or mf_Grayed);
  if RedoBuf^.Count > 0
  then EnableMenuItem(Menu, cm_Redo, mf_ByCommand or mf_Enabled)
  else EnableMenuItem(Menu, cm_Redo, mf_ByCommand or mf_Grayed);
{$endif}
end;

procedure tPaint.MDI_Menu(b : Boolean);
var
  Menu : hMenu;
begin
  Menu := pWindow(Application^.MainWindow)^.Attr.Menu;
  if b
  then MDI_Act
  else begin
    EnableMenuItem(Menu, cm_Print, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_FileSave, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_Speedbar, SBActivate, cm_FileSave);
    EnableMenuItem(Menu, cm_FileSaveAs, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_FileExport, mf_ByCommand or mf_Grayed);
    SendMessage(hMainWin, ms_UpdateInfo, 0, 0);
    { Edit-Funktionen deaktivieren. }
    EnableMenuItem(Menu, cm_EditAll, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditDel, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_EditDelete, mf_ByCommand or mf_Grayed);
{$ifdef undo}
    EnableMenuItem(Menu, cm_Undo, mf_ByCommand or mf_Grayed);
    EnableMenuItem(Menu, cm_Redo, mf_ByCommand or mf_Grayed);
{$endif}
    SetRedrawSpeedbar;
  end;
end;

procedure tPaint.SetRaster(xRaster : Integer);
begin
  Raster := xRaster;
  InvalidateRect(hWindow, nil, True);
end;

procedure tPaint.SetRasterFront(xRasterFront : Boolean);
begin
  RasterFront := xRasterFront;
  InvalidateRect(hWindow, nil, True);
end;

procedure tPaint.msSetZoom(var Msg : tMessage);
begin
  if Msg.wParam <> 0
  then pScrollerOrg(Scroller)^.SetZoom(Integer(Msg.wParam));
  Msg.Result := pScrollerOrg(Scroller)^.Zoom;
end;

procedure tPaint.wmPaint(var Msg : tMessage);
var
  PaintInfo : TPaintStruct;
  PaintDC : hDC;
{$ifdef test}
{$ifndef mini}
  ColorRef : TColorRef;
  font : HFont;
  R : TRect;
{$endif}
{$endif}
begin
  BeginPaint(HWindow, PaintInfo);
  PaintDC := PaintInfo.hDC;
{$ifdef test}
{$ifndef mini}
  if expired
  then begin
    SetBkMode( PaintDC, TRANSPARENT );
    ColorRef := SetTextColor( PaintDC, RGB( 255, 255, 0 ) );
    GetClientRect( HWindow, R );
    font := CreateFont(
      R.bottom-R.top, (R.right-R.left) div 10,
      0, 0,
      700,
      0, 0, 0,
      ANSI_CHARSET,
      0, 0,
      0, 0,
      'Arial' );
    font := SelectObject( PaintDC, font );
    TextOut( PaintDC, 2, 2, 'EXPIRED', 7 );
    DeleteObject(SelectObject( PaintDC, font ));
    SetTextColor( PaintDC, COlorRef );
  end;
{$endif}
{$endif}
  Scroller^.BeginView(PaintDC, PaintInfo);

  RasterPaint(PaintDC, PaintInfo);
  SetWindowOrg(PaintDC, 0, 0);
  InvertEdit(PaintDC);

  Scroller^.EndView;
  EndPaint(HWindow, PaintInfo);
end;

procedure tPaint.RasterPaint(PaintDC : hDC; var PaintInfo : tPaintStruct);
procedure PaintRaster;
var
  i, j,
  i5, j5 : Integer;
begin
  with tRect_(PaintInfo.rcPaint)
  do begin
    SetWindowOrg(PaintDC, 0, 0);
    SelectObject(PaintDC, RasterPen);
    i5 := RasterMulX*RasterIncX;
    j5 := RasterMulY*RasterIncY;
    case Raster of
      1 :
        begin
          i := ((left - RasterIncX) div i5) * i5;
          while i < right + RasterIncX
          do begin
            j := ((top - RasterIncY) div j5) * j5;
            while j < bottom + RasterIncY
            do begin
              MoveTo(PaintDC, i, j);
              LineTo(PaintDC, i, j);
              inc(j, j5);
            end;
            inc(i, i5);
          end;
        end;
      2 :
        begin
          i := ((left - RasterIncX) div RasterIncX) * RasterIncX;
          while i < right + RasterIncX
          do begin
            j := ((top - RasterIncY) div RasterIncY) * RasterIncY;
            while j < bottom + RasterIncY
            do begin
              if (i mod i5 = 0) and (j mod j5 = 0)
              then begin
                MoveTo(PaintDC, i-crossX, j);
                LineTo(PaintDC, i+crossX, j);
                MoveTo(PaintDC, i, j-crossY);
                LineTo(PaintDC, i, j+crossY);
              end
              else begin
                MoveTo(PaintDC, i, j);
                LineTo(PaintDC, i, j);
              end;
              inc(j, RasterIncY);
            end;
            inc(i, RasterIncX);
          end;
        end;
    end;
  end;
end;
begin
  if not RasterFront then PaintRaster;
  SelectObject(PaintDC, DrawPen);
  Paint(PaintDC, PaintInfo);
  if RasterFront then PaintRaster;
end;

procedure tPaint.SetCursorOfState(xState : Integer);
begin
  case xState of
    ls_None : SetCursor(LoadCursor(0, idc_Arrow));
    ls_ZoomBox,
    ls_ZoomBoxB : SetCursor(LoadCursor(hRes, 'IDC_ZOOMBOX'));
    ls_EditSize : SetCursor(LoadCursor(hRes, 'IDC_Edit'));
  end;
  SendMessage(hMainWin, ms_UpdateInfo, inc_State + xState, 0);
end;

procedure tPaint.SetCursorActState;
begin
  SetCursorOfState(State);
end;

procedure tPaint.BeginDrag;
begin
  SetNotClose;
  DragDC := GetDC(hWindow);
  pScrollerOrg(Scroller)^.BeginZoom(DragDC);
  SetROP2(DragDC, R2_Not);
  UpdateWindow(hWindow);
  SetCapture(hWindow);
end;

procedure tPaint.EndDrag;
begin
  ReleaseDC(hWindow, DragDC);
  ReleaseCapture;
  SetCursorActState;
end;

procedure tPaint.cmRasterOff(var Msg : tMessage);
begin
  with pWindow(Application^.MainWindow)^.Attr
  do begin
    CheckMenuItem(Menu, cm_RasterOff, mf_ByCommand + mf_Checked);
    CheckMenuItem(Menu, cm_RasterBig, mf_ByCommand + mf_Unchecked);
    CheckMenuItem(Menu, cm_RasterSmall, mf_ByCommand + mf_Unchecked);
  end;
  SetRaster(0);
end;

procedure tPaint.cmRasterBig(var Msg : tMessage);
begin
  with pWindow(Application^.MainWindow)^.Attr
  do begin
    CheckMenuItem(Menu, cm_RasterOff, mf_ByCommand + mf_Unchecked);
    CheckMenuItem(Menu, cm_RasterBig, mf_ByCommand + mf_Checked);
    CheckMenuItem(Menu, cm_RasterSmall, mf_ByCommand + mf_Unchecked);
  end;
  SetRaster(1);
end;

procedure tPaint.cmRasterSmall(var Msg : tMessage);
begin
  with pWindow(Application^.MainWindow)^.Attr
  do begin
    CheckMenuItem(Menu, cm_RasterOff, mf_ByCommand + mf_Unchecked);
    CheckMenuItem(Menu, cm_RasterBig, mf_ByCommand + mf_Unchecked);
    CheckMenuItem(Menu, cm_RasterSmall, mf_ByCommand + mf_Checked);
  end;
  SetRaster(2);
end;

procedure tPaint.cmRasterFront(var Msg : tMessage);
begin
  ModifyMenu(
    pWindow(Application^.MainWindow)^.Attr.Menu,
    cm_RasterFront, mf_ByCommand,
    cm_RasterBack, LoadString0(18));
  SetRasterFront(True);
end;

procedure tPaint.cmRasterBack(var Msg : tMessage);
begin
  ModifyMenu(
    pWindow(Application^.MainWindow)^.Attr.Menu,
    cm_RasterBack, mf_ByCommand,
    cm_RasterFront, LoadString0(19));
  SetRasterFront(False);
end;

type
  pZoomRec = ^tZoomRec;
  tZoomRec = record
    xR : tRect;
    xState : Integer;
    xIsRasterPos : Boolean;
  end;

procedure tPaint.cmZoomBox(var Msg : tMessage);
begin
  GetMem(Poi, SizeOf(tZoomRec));
  with pZoomRec(Poi)^
  do begin
    xState:=State;
    xIsRasterPos:=IsRasterPos;
  end;
  IsRasterPos := False;
  State := ls_ZoomBox;
  SetCursorActState;
  SetCapture(hWindow);
end;

procedure tPaint.cmZoom90(var Msg : tMessage);
begin
  with pScrollerOrg(Scroller)^ do
    SetZoom((Longint(Zoom)*900) div 1000);
end;

procedure tPaint.cmZoom75(var Msg : tMessage);
begin
  with pScrollerOrg(Scroller)^ do
    SetZoom((Longint(Zoom)*750) div 1000);
end;

procedure tPaint.cmZoom50(var Msg : tMessage);
begin
  with pScrollerOrg(Scroller)^ do
    SetZoom((Longint(Zoom)*500) div 1000);
end;

procedure tPaint.cmZoomAll(var Msg : tMessage);
begin
  SendMessage( hWindow, ms_ZoomAll, 0, 0 );
  SetNotClose;
end;

procedure tPaint.cmPaint(var Msg : tMessage);
begin
  InvalidateRect(hWindow, nil, True);
  UpdateWindow(hWindow);
end;

procedure tPaint.cmPos1(var Msg : tMessage);
begin
  RasterPos := 1;
  MDI_Act;
end;

procedure tPaint.cmPos5(var Msg : tMessage);
begin
  RasterPos := 5;
  MDI_Act;
end;

procedure tPaint.cmPos10(var Msg : tMessage);
begin
  RasterPos := 10;
  MDI_Act;
end;

type
  tDragEdit = record
    R : tRect;
    xState : Integer;
    xIsRasterPos : Boolean;
  end;

procedure tPaint.DragEdit(A : tPoint);
begin
  BeginDrag;
  GetMem(Poi, SizeOf(tDragEdit));
  with tDragEdit(Poi^)
  do begin
    xState := State;
    xIsRasterPos := IsRasterPos;
    IsRasterPos := False;
    with A do SetRect(R, X, Y, X, Y);
    InvertRect(DragDC, R);
  end;
  State := ls_EditSize;
  SetCursorActState;
end;

procedure tPaint.EditDel;
var PaintDC : hDC;
begin
  PaintDC := GetDC(hWindow);
  pScrollerOrg(Scroller)^.BeginZoom(PaintDC);
  InvertEdit(PaintDC);
  ReleaseDC(hWindow, PaintDC);
  DelEdit;
  MDI_Act;
end;

function tPaint.IsEditEmpty : Boolean;
begin
  IsEditEmpty := TRUE;
end;

procedure tPaint.InvertEdit(PaintDC : HDC);
begin
end;

procedure tPaint.cmEditCut(var Msg : tMessage);
begin
  SendMessage(hWindow, wm_Command, cm_EditCopy, 0);
  SendMessage(hWindow, wm_Command, cm_EditDelete, 0);
end;

procedure tPaint.cmEditAll(var Msg : tMessage);
var
  R : tRect;
  PaintDC : hDC;
begin
  UpdateWindow(hWindow);
  PaintDC := GetDC(hWindow);
  pScrollerOrg(Scroller)^.BeginZoom(PaintDC);
  InvertEdit(PaintDC);
  SetRect(R, -$3fff, -$3fff, $3fff, $3fff);
  CalcEdit(R);
  InvertEdit(PaintDC);
  ReleaseDC(hWindow, PaintDC);
  MDI_Act;
end;

procedure tPaint.cmEditDel(var Msg : tMessage);
begin
  EditDel;
end;

procedure tPaint.CalcEdit(R : tRect);
begin
  Abstract;
end;

procedure tPaint.DelEdit;
begin
end;

procedure tPaint.PosCoord(var A : tPoint);
begin
  if IsRasterPos then
    with A
    do begin
      if X < 0
      then X := ((X - (RasterPos div 2)) div RasterPos) * RasterPos
      else X := ((X + (RasterPos div 2)) div RasterPos) * RasterPos;
      if Y < 0
      then Y := ((Y - (RasterPos div 2)) div RasterPos) * RasterPos
      else Y := ((Y + (RasterPos div 2)) div RasterPos) * RasterPos;
    end;
end;

procedure tPaint.WMMouseMove(var Msg : tMessage);
(*var R : tRect;*)
begin
  (*GetClientRect(hWindow, R);
  with tPoint(Msg.lParam)
  do begin
    if X <= R.Left then Scroller^.HScroll(sb_LineUp, 0);
    if Y <= R.Top then Scroller^.VScroll(sb_LineUp, 0);
    if X >= R.Right then Scroller^.HScroll(sb_LineDown, 0);
    if Y >= R.Bottom then Scroller^.VScroll(sb_LineDown, 0);
  end;*)
  pScrollerOrg(Scroller)^.ZoomCoord(tPoint(Msg.lParam));
  if (State <> ls_None) and
     (State <> ls_Connection) and
     (RasterPos > 1)
  then PosCoord(tPoint(Msg.lParam));
  case State of
    ls_ZoomBox : SetCursorActState;
    ls_ZoomBoxB :
      with tZoomRec(Poi^)
      do begin
        InvertRect(DragDC, xR);
        tRect_(xR).B := tPoint(Msg.lParam);
        InvertRect(DragDC, xR);
      end;
    ls_EditSize :
      with tDragEdit(Poi^)
      do begin
        InvertRect(DragDC, R);
        tRect_(R).B := tPoint(Msg.lParam);
        InvertRect(DragDC, R);
      end;
  end;
  SendMessage(hMainWin, ms_UpdatePos, 0, Msg.lParam);
end;

procedure tPaint.WMLButtonDown(var Msg : tMessage);
var R : tRect;
begin
  pScrollerOrg(Scroller)^.ZoomCoord(tPoint(Msg.lParam));
  if (State <> ls_None) and (RasterPos > 1)
  then PosCoord(tPoint(Msg.lParam));
  case State of
    ls_ZoomBox :
      begin
        BeginDrag;
        with tPoint(Msg.lParam) do
          SetRect(tRect(Poi^), X, Y, X, Y);
        InvertRect(DragDC, tZoomRec(Poi^).xR);
        State := ls_ZoomBoxB;
        SetCursorActState;
      end;
  end;
end;

procedure tPaint.WMLButtonUp(var Msg : tMessage);
procedure CombineEdit;
begin
  with tDragEdit(Poi^)
  do begin
    InvertRect(DragDC, R);
    InvertEdit(DragDC);
    CalcEdit(R);
    InvertEdit(DragDC);
    State := xState;
    IsRasterPos := xIsRasterPos;
  end;
  FreeMem(Poi, SizeOf(tDragEdit));
  tPaint.EndDrag;
  MDI_Act;
end;
begin
  pScrollerOrg(Scroller)^.ZoomCoord(tPoint(Msg.lParam));
  case State of
    ls_ZoomBoxB :
      with tZoomRec(Poi^)
      do begin
        InvertRect(DragDC, xR);
        pScrollerOrg(Scroller)^.SetRectZoom(xR);
        State:=xState;
        IsRasterPos:=xIsRasterPos;
        FreeMem(Poi, SizeOf(tZoomRec));
        EndDrag;
      end;
    ls_EditSize : CombineEdit;
  end;
end;

procedure tPaint.WMRButtonDown(var Msg : tMessage);
begin
  pScrollerOrg(Scroller)^.ZoomCoord(tPoint(Msg.lParam));
  if (State <> ls_None) and (RasterPos > 1)
  then PosCoord(tPoint(Msg.lParam));
  case State of
    ls_ZoomBox :
      with tZoomRec(Poi^)
      do begin
        State := xState;
        IsRasterPos := xIsRasterPos;
        FreeMem(Poi, SizeOf(tZoomRec));
        PostMessage(hWindow, MS_ENDDRAG, 0, 0);
      end;
    ls_ZoomBoxB :
      with tZoomRec(Poi^)
      do begin
        InvertRect(DragDC, tRect(Poi^));
        State := xState;
        IsRasterPos := xIsRasterPos;
        FreeMem(Poi, SizeOf(tZoomRec));
        PostMessage(hWindow, MS_ENDDRAG, 0, 0);
      end;
  end;
end;

procedure tPaint.cmFileSaveAs(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_SaveAs, ext_GRC, hWindow);
end;

procedure tPaint.cmFileExport(var Msg : tMessage);
begin
  SendMessage(hMainWin, ms_SaveAs, ext_FileExport or ext_BMP, hWindow);
end;

type
  tBitmapInfo4 = record
    bmiHeader : tBitmapInfoHeader;
    bmiColors : array [0..4] of Longint;
  end;

procedure tPaint.msExport(var Msg : tMessage);
var ps : tPaintStruct;
procedure Export_WMF;
var mf : tHandle;
begin
  with ps
  do begin
    GetClientRect(hWindow, rcPaint);
    fErase := False;
    fRestore := False;
  end;
  mf := CreateMetaFile(pChar(Msg.lParam));
  RasterPaint(mf, PS);
  DeleteMetaFile(CloseMetaFile(mf));
end;
procedure Export_BMP;
var
  BitmapInfo : tBitmapInfo4;
  BitmapInfoHeader : tBitmapInfoHeader;
  BitmapFileHeader : tBitmapFileHeader;
  buffer : Pointer;
  l : Longint;
  y : Integer;
  f : tHandle;
  dc : hDC;
  bmp : hBitmap;
begin
  with ps
  do begin
    GetClientRect(hWindow, rcPaint);
    fErase := False;
    fRestore := False;
  end;
  with BitmapInfoHeader
  do begin
    biSize := SizeOf(BitmapInfoHeader); { Wegen Color-Tabelle. }
    biWidth := ps.rcPaint.Right+1;
    biHeight := ps.rcPaint.Bottom+1;
    biPlanes := 1;
    biBitCount := 4;
    biCompression := bi_RGB; { Keine Kompression. }
    biSizeImage := 0; { Ohne Kompression nicht n�tig. }
    biXPelsPerMeter := 0; { Standard. }
    biYPelsPerMeter := 0; { Standard. }
    biClrUsed := co_num; { Anzahl der verwendeten Farben. }
    biClrImportant := co_num; { Alle verwendeten Farben sind wichtig. }
  end;
  with BitmapInfo
  do begin
    bmiHeader := BitmapInfoHeader;
    bmiColors[0] := co_white;
    bmiColors[1] := co_black;
    bmiColors[2] := co_gray;
    bmiColors[3] := co_red;
    bmiColors[4] := co_green;
  end;
  l := ((ps.rcPaint.Right+7) div 8) * 4; { Long-Grenze beachten! }
  with BitmapFileHeader
  do begin
    bfType := 19778 { 66(=b) + 77(=M)*256 };
    bfSize :=
      SizeOf(BitmapFileHeader) +
      SizeOf(BitmapInfo) +
      (l * (ps.rcPaint.Bottom+1));
    bfReserved1 := 0;
    bfReserved2 := 0;
    bfOffBits :=
      SizeOf(BitmapFileHeader) +
      SizeOf(BitmapInfo);
  end;
  dc := CreateCompatibleDC(0);
  bmp := CreateDIBitmap(
           dc, BitmapInfoHeader, 0, nil,
           tBitmapInfo((@BitmapInfo)^), dib_RGB_Colors);
  SelectObject(dc, bmp);
  FillRect(dc, ps.rcPaint, GetStockObject(White_Brush));
  pScrollerOrg(Scroller)^.BeginZoom(dc);
  with tRect_(ps.rcPaint)
  do begin
    pScrollerOrg(Scroller)^.ZoomCoord(A);
    pScrollerOrg(Scroller)^.ZoomCoord(B);
  end;
  RasterPaint(dc, ps);
  f := _lcreat(pChar(Msg.lParam), 0);
  _lwrite(f, pChar(@BitmapFileHeader), SizeOf(BitmapFileHeader));
  _lwrite(f, pChar(@BitmapInfo), SizeOf(BitmapInfo));
  GetMem(buffer, l);
  for y := 0 to BitmapInfoHeader.biHeight-1
  do begin
    GetDIBits(
      dc, bmp, y, 1, buffer,
      tBitmapInfo((@BitmapInfo)^), dib_RGB_Colors);
    _lwrite(f, buffer, l);
  end;
  _lclose(f);
  FreeMem(buffer, l);
  DeleteObject(bmp);
  DeleteDC(dc);
end;
begin
  Msg.Result := Word(True);
  case Msg.wParam of
    ext_WMF : Export_WMF;
    ext_BMP : Export_BMP;
    else Msg.Result := Word(False);
  end;
end;

procedure tPaint.msPrint(var Msg : tMessage);
var
  Output : pPrintout;
begin
  Output := New(pPaintPrintout, Init(@Self));
  pPrinter(Msg.lParam)^.Print(@Self, Output);
  Dispose(Output, Done);
end;

procedure tPaint.cmFont(var Msg : tMessage);
begin
  Application^.ExecDialog(New(pFontDialog, Init(@Self, @FontData)));
end;

procedure tPaint.cmExportBMP(var Msg : tMessage);
begin
  OpenClipboard(hWindow);
  EmptyClipboard;
  SetClipboardData(cf_Bitmap, LoadBitmap(hRes, 'PAINTTOOL'));
  CloseClipboard;
end;

procedure tPaint.MSEndDrag(var Msg : tMessage);
begin
  EndDrag;
  State := LS_NONE;
end;

procedure tPaint.msIsShown(var Msg : tMessage);
begin
  Msg.Result := longint(nil);
end;

{$ifdef undo}
procedure tPaint.SaveUndo( buf : pCollection );
var
  S : pStream;
begin
  S := New( pGlobalStream, Init );
  Store(S^);
  buf^.Insert(S);
end;

procedure tPaint.cmUndo(var Msg : tMessage);
var
  S : pStream;
  i : integer;
begin
  SaveUndo( RedoBuf );
  with UndoBuf^ do
    S := At(Count-1);
  DelUndo;
  S^.Seek(0);
  Load(S^);
  with UndoBuf^ do
    AtFree(Count-1);
  InvalidateRect( hWindow, nil, true );
  MDI_Act;
end;

procedure tPaint.cmRedo(var Msg : tMessage);
var
  S : pStream;
begin
  with RedoBuf^ do
    S := At(Count-1);
  DelUndo;
  S^.Seek(0);
  Load(S^);
  with RedoBuf^ do
    AtDelete(Count-1);
  UndoBuf^.Insert(S);
  InvalidateRect( hWindow, nil, true );
  MDI_Act;
end;

procedure tPaint.DelUndo;
begin
  { Abstract. }
end;

procedure tPaint.msFreeUndo(var Msg : tMessage);
begin
  UndoBuf^.FreeAll;
  RedoBuf^.FreeAll;
  MDI_Act;
end;
{$endif}

procedure tPaint.SetNotClose;
begin
{$ifdef undo}
  if xUndo
  then begin
    SaveUndo( UndoBuf );
    RedoBuf^.FreeAll;
  end;
{$endif}
  NotClose := TRUE;
end;

end.