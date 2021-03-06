unit ScrolOrg;
{$I define.inc}

interface

uses
  LK_Const,
  Objects,
  Strings,
  WinTypes, WinProcs,
  OWindows, ODialogs,
  OWinEx;

type
  pScrollerOrg = ^tScrollerOrg;
  tScrollerOrg = object (tScroller)
    OrgX, OrgY,
    Zoom : Integer;
    xPage_, yPage_ : Integer;
    constructor Init(TheWindow: PWindow;
                     xOrgX, xOrgY, TheXRange, TheYRange: LongInt);
    procedure Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure SetOrg(xOrgX, xOrgY : Integer);
    procedure SetZoom(xZoom : Integer);
    procedure SetRectZoom(R : tRect);
    procedure ZoomCoord(var A : tPoint);
    procedure ClientCoord(var A : tPoint);
    procedure BeginPrint(
      PaintDC : HDC; var ps : tPaintStruct; Zoom2 : Integer);
    procedure BeginZoom(PaintDC : HDC);
    procedure BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure ScrollTo(NewXPos, NewYPos : LongInt); virtual;
    procedure SetPageSize; virtual;
    procedure SetSBarRange; virtual;
    procedure VScroll(ScrollRequest: Word; ThumbPos: Integer); virtual;
    procedure HScroll(ScrollRequest: Word; ThumbPos: Integer); virtual;
    procedure ScrollBy(Dx, Dy: LongInt);
  end;

implementation

{ ------ tScrollOrg ----------------------------------------------------- }

constructor tScrollerOrg.Init(TheWindow: PWindow;
  xOrgX, xOrgY, TheXRange, TheYRange: LongInt);
var p : pWindowsObject;
begin
  inherited Init(TheWindow, 1, 1, TheXRange, TheYRange);
  xLine := 10;
  yLine := 10;
  OrgX := xOrgX;
  OrgY := xOrgY;
  Zoom := 2000;
  TrackMode := False;
  AutoMode := False;
end;

procedure tScrollerOrg.Load(var S : tStream);
var xZoom : Integer;
begin
  S.Read(XPos, SizeOf(XPos) + SizeOf(XPos));
  ScrollTo(XPos, YPos);
  S.Read(OrgX, SizeOf(OrgX) + SizeOf(OrgY));
  S.Read(xZoom, SizeOf(xZoom));
  SetZoom(xZoom);
end;

procedure tScrollerOrg.Store(var S : tStream);
begin
  S.Write(XPos, SizeOf(XPos) + SizeOf(YPos));
  S.Write(OrgX,
      SizeOf(OrgX) + SizeOf(OrgY) +
      SizeOf(Zoom));
end;

procedure tScrollerOrg.SetOrg(xOrgX, xOrgY : Integer);
begin
  OrgX := xOrgX;
  OrgY := xOrgY;
end;

procedure tScrollerOrg.SetZoom(xZoom : Integer);
begin
  if Zoom <> xZoom
  then begin
    Zoom := xZoom;
    if Zoom = 0 then Zoom := 20000;
    SetPageSize;
    InvalidateRect(Window^.hWindow, nil, True);
  end;
end;

procedure tScrollerOrg.SetRectZoom(R : tRect);
var
  dx, dy : Longint;
  i : Integer;
begin
  with R
  do begin
    if right<left
    then begin
      dx:=left;
      left:=right;
      right:=dx;
    end;
    if bottom<top
    then begin
      dy:=bottom;
      bottom:=top;
      top:=dy;
    end;
    dx:=Right-Left;
    dy:=Bottom-Top;
    if dx<20
    then begin
      InflateRect(R, (20-dx+1) div 2, 0);
      dx:=Right-Left;
    end;
    if dy<20
    then begin
      InflateRect(R, 0, (20-dy+1) div 2);
      dy:=Bottom-Top;
    end;
    if (dx > 20000) or (dy > 20000)
    then begin
      UserMessage_(Window^.hWindow, 40, -1, mb_IconStop + mb_OK);
      InflateRect(R, (dx-20000) div 2, (dy-20000) div 2);
      dx := Right-Left;
      dy := Bottom-Top;
    end;
    ShowWindow(Window^.hWindow, sw_Hide);
    ScrollTo(Left + (dx div 2), Top + (dy div 2));
    GetClientRect(Window^.hWindow, R);
    dx := (Longint(Right) * 1000) div dx;
    dy := (Longint(Bottom) * 1000) div dy;
    if dy <= dx then dx := dy;
    if dx>$7fff then dx:=$7fff;
    i:=dx;
    SendMessage(Window^.hWindow, ms_SetZoom, Word(i), 0);
    ShowWindow(Window^.hWindow, sw_Show);
  end;
end;

procedure tScrollerOrg.ZoomCoord(var A : tPoint);
begin
  with A
  do begin
    X := (((Longint(X) * 1000) + (Zoom shr 1)) div Zoom) + XPos
         - XPage;
    Y := (((Longint(Y) * 1000) + (Zoom shr 1)) div Zoom) + YPos
         - YPage;
  end;
end;

procedure tScrollerOrg.ClientCoord(var A : tPoint);
begin
  with A
  do begin
    X := integer((Longint(X-XPos+XPage) * longint(Zoom)) div 1000);
    Y := integer((Longint(Y-YPos+YPage) * longint(Zoom)) div 1000);
  end;
end;

procedure tScrollerOrg.BeginPrint(
  PaintDC : HDC; var ps : tPaintStruct; Zoom2 : Integer);
var
  ZoomDiv2 : integer;
begin
  ZoomDiv2 := Zoom div 2;
  with ps.rcPaint
  do begin
    Left :=
      (((Longint(Left) * Zoom2) + ZoomDiv2) div Zoom) + XPos
      - XPage;
    Top :=
      (((Longint(Top) * Zoom2) + ZoomDiv2) div Zoom) + YPos
      - YPage;
    Right :=
      (((Longint(Right) * Zoom2) + ZoomDiv2) div Zoom) + XPos
      - XPage;
    Bottom :=
      (((Longint(Bottom) * Zoom2) + ZoomDiv2) div Zoom) + YPos
      - YPage;
  end;
  BeginZoom(PaintDC);
  SetViewPortOrg(PaintDC,
    (Longint(-XPos+XPage) * Zoom) div Zoom2,
    (Longint(-YPos+YPage) * Zoom) div Zoom2);
  SetWindowExt(PaintDC, Zoom2, Zoom2);
end;

procedure tScrollerOrg.BeginZoom(PaintDC : HDC);
begin
  SetMapMode(PaintDC, mm_Isotropic);
  SetWindowExt(PaintDC, 1000, 1000);
  SetViewportExt(PaintDC, Zoom, Zoom);
  SetViewPortOrg(PaintDC,
    (Longint(-XPos+XPage) * Zoom) div 1000,
    (Longint(-YPos+YPage) * Zoom) div 1000);
  SelectObject(PaintDC, DrawPen);
  SelectObject(PaintDC, GetStockObject(Null_Brush));
  SetBkMode(PaintDC, Transparent); { Wegen Schrift. }
end;

procedure tScrollerOrg.BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  with tRect_(PaintInfo.rcPaint)
  do begin
    ZoomCoord(A);
    ZoomCoord(B);
  end;
  BeginZoom(PaintDC);
end;

procedure tScrollerOrg.ScrollTo(NewXPos, NewYPos: LongInt);
var
  R : tRect;
  (*NewXPos, NewYPos : Longint;*)
  Xscr, Yscr : Integer;
begin
  if Window <> nil
  then begin
    (*NewXPos := LongMax(OrgX, LongMin(X, XRange+OrgX));
    NewYPos := LongMax(OrgY, LongMin(Y, YRange+OrgY));*)
    if (NewXPos <> XPos) or (NewYPos <> YPos)
    then begin
      if (Abs(YPos - NewYPos) < YPage) and
         (Abs(XPos - NewXPos) < XPage)
      then begin
        GetClientRect(Window^.hWindow, R);
        Xscr := (*(Longint(XPos - NewXPos) * Zoom) div 1000;*)
              ((Longint(XPos) * Zoom) div 1000) -
                ((Longint(NewXPos) * Zoom) div 1000);
        Yscr := (*(Longint(YPos - NewYPos) * Zoom) div 1000;*)
              ((Longint(YPos) * Zoom) div 1000) -
                ((Longint(NewYPos) * Zoom) div 1000);
        ScrollWindow(Window^.HWindow, Xscr, Yscr, @R, @R);
      end
      else
        InvalidateRect(Window^.HWindow, nil, True);
      (*dec(XPos, (Longint(Xscr)*1000) div Zoom);
      dec(YPos, (Longint(Yscr)*1000) div Zoom);*)
      XPos := NewXPos;
      YPos := NewYPos;
      SetScrollPos(Window^.hWindow, sb_Horz, XPos, True);
      SetScrollPos(Window^.hWindow, sb_Vert, YPos, True);
      UpdateWindow(Window^.HWindow);
    end;
  end;
end;

procedure tScrollerOrg.SetPageSize;
var
  ClientRect: TRect;
  Width, Height: Integer;
  ZoomMul2 : integer;
begin
  if (Window <> nil) and (Window^.HWindow <> 0) then
  begin
    GetClientRect(Window^.HWindow, ClientRect);
    with ClientRect do
    begin
      Width := Right - Left;  Height := Bottom - Top;
      if (Width <> 0) and (Height <> 0)
      then begin
        ZoomMul2 := Zoom*2;
        XPage := integer ((Longint(Width) * 1000) div ZoomMul2);
        YPage := integer ((Longint(Height) * 1000) div ZoomMul2);
      end;
    end;
  end;
end;

procedure tScrollerOrg.SetSBarRange;
begin
  with Window^
  do begin
    SetScrollRange(hWindow, sb_Horz, OrgX, OrgX+XRange, False);
    SetScrollRange(hWindow, sb_Vert, OrgY, OrgX+YRange, False);
  end;
end;

procedure tScrollerOrg.VScroll(ScrollRequest: Word; ThumbPos: Integer);
begin
  case ScrollRequest of
    sb_LineDown: ScrollBy(0, YLine);
    sb_LineUp: ScrollBy(0, -YLine);
    sb_PageDown: ScrollBy(0, YPage);
    sb_PageUp: ScrollBy(0, -YPage);
    sb_ThumbPosition: ScrollTo(XPos, ThumbPos);
    sb_ThumbTrack:
      begin
        if TrackMode then ScrollTo(XPos, ThumbPos);
        if ((Window <> nil) and HasVScrollBar)
        then SetScrollPos(Window^.HWindow, sb_Vert, ThumbPos, True);
      end;
  end;
end;

procedure tScrollerOrg.HScroll(ScrollRequest: Word; ThumbPos: Integer);
begin
  case ScrollRequest of
    sb_LineDown: ScrollBy(XLine, 0);
    sb_LineUp: ScrollBy(-XLine, 0);
    sb_PageDown: ScrollBy(XPage, 0);
    sb_PageUp: ScrollBy(-XPage, 0);
    sb_ThumbPosition: ScrollTo(ThumbPos, YPos);
    sb_ThumbTrack:
      begin
        if TrackMode then ScrollTo(ThumbPos, YPos);
        if ((Window <> nil) and HasHScrollBar)
        then SetScrollPos(Window^.HWindow, sb_Horz, ThumbPos, True);
      end;
  end;
end;

procedure tScrollerOrg.ScrollBy(Dx, Dy: LongInt);
begin
  ScrollTo(XPos + Dx, YPos + Dy);
end;

end.