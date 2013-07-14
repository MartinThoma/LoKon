unit Item;
{$I define.inc}

interface

uses
  LK_Const,
  Strings,
  Objects,
  WinTypes, WinProcs,
  OWindows,
  OWinEx;

type
  pItem = ^tItem;

  pCon = ^tCon;
  tCon = object
    Con : pItem;
    Num : Integer;
    procedure Init(xCon : pItem; xNum : Integer);
    procedure Done;
    function DelCon : Integer;
    procedure Free;
    procedure Delete(Layout : pCollection);
    procedure Insert(Layout : pCollection; PaintDC : hDC);
    procedure NotPaint(PaintDC : hDC);
    function GetRegionCon : hRgn;
  end;

  pConArray = ^tConArray;
  tConArray = array [0..$1f00] of tCon;

{type
  pItem = ^tItem;}
  tItem = object (tObject)
    ItemRect : tRect;
      { Verbindungen mit DelCon kappen ! }
    destructor Done; virtual;
      { Aktuelles Objekt neu Initialisieren, keine
        "persönlichen" Daten kopieren. }
    function Copy : pItem; virtual;
      { Der Name des aktuellen Objekts ( für den
        Menüpunkt xxx wichtig ).
        Es wird KEINE Kopie gegeben.
        Name NICHT löschen. }
    function Name : pChar; virtual;
    procedure StoreText(var t : Text); virtual;
      { Schaltungselement zurücksetzen. }
    procedure Reset; virtual;
      { Neue Position bzw. Richtungsänderung ( um 90 Grad
        im Uhrzeigersinn ). }
    procedure NewPos(Pos : tPosition); virtual;
    procedure SetPos(xX, xY : Integer);
    procedure IncPos(xX, xY : Integer); virtual;
    function Position : pPosition; virtual;
    function PosPoint : longint; virtual;
    procedure IncDirection; virtual;
    procedure IncDirection_; virtual;
      { Berechnen des Bereichs auf der Schaltung, der vom
        Element bzw. den Ein-/Ausgängen belegt wird.
        Mit und ohne Ein-/Ausgänge.  }
    function GetRegion : hRgn;
    function GetRegionInOut : hRgn; virtual;
    function GetRegion_ : hRgn; virtual;
      { Bereich der Ein-/Ausgänge. }
    function GetRegionCon : hRgn; virtual;
      { Verbindungen aus Layout löschen/einfügen ( Ohne DelCon ).}
    procedure DisposeCon; virtual;
    procedure DeleteCon(Layout : pCollection); virtual;
    procedure InsertCon(Layout : pCollection; PaintDC : hDC); virtual;
    procedure SetCon(Num : Integer; p : pItem; Num_ : Integer); virtual;
      { SetCon_ entspricht SetCon, wird allerdings beim Laden verwendet. }
    procedure SetCon_(Num : Integer; p : pItem; Num_ : Integer); virtual;
                     { Gibt die Nr (Num) zurück. Siehe tConNode. }
    function DelCon(Num : Integer) : Integer; virtual;

    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutPos(Num : Integer) : Longint; virtual;
    function GetInOutPtr(Num : Integer) : pItem;
    function GetInOutCon(Num : Integer) : pCon; virtual;
      { Aktueller Status. A ist die aktuelle Position des
        Mauszeigers und b ist einer der folgenden Werte:
          lm_MouseMove - Maus bewegt
          lm_LButton - linke Maustaste gedrückt
          lm_RButton - rechte Maustaste gedrückt
          lm_Connect - ein Verbindungsende an Pos A. }
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
      { Darstellung:
          NotPaint - bei Bewegung
          Paint - in Schaltung zeichnen
          Paint_ - Hintergrund löschen und dann in Schaltung zeichnen
          PaintInOut - Ein-/Ausgänge anzeigen }
    procedure NotPaint(PaintDC: hDC); virtual;
    procedure Paint(PaintDC: hDC); virtual;
    procedure Paint_(PaintDC: hDC); virtual;
    procedure PaintInOut(PaintDC : hDC); virtual;
      { Impulseverarbeitung. }
    procedure GetInitImpulse(Impulses : pCollection); virtual;
    procedure SendImpulse(
      NumIn, Impulse : Integer;
      PaintCol : pCollection; Impulses : pCollection); virtual;
    procedure OutImpulse(Impulses : pCollection); virtual;
    function CalcEdit(R : tRect) : hRgn; virtual;
    procedure StoreInOut(var S : tStream); virtual;
    function LoadInOut(var S : tStream) : Boolean; virtual;
    function Full_in_Lay(Lay : pCollection) : Boolean; virtual;
      { Umschließendes Rechteck berechnen. }
    procedure CalcItemRect;
    procedure CalcItemRectCon;
      { Testet, ob Punkt des Element berührt. }
    function Pt_in_Item(A : tPoint) : Boolean;
      { Testet, ob das Rechteck das Element(rechteck) berührt. }
    function Rect_in_Item(R : tRect) : Boolean;
      { Testet, ob p das aktuelle Element berührt. }
    function Rgn_in_Item(Rgn : hRgn) : Boolean;
      { Element in Schaltung anzeigen/verändern. }
    procedure ItemEdit(Window : pWindowsObject); virtual;
      { Kontextsensitives Menü der rechten Maustaste. }
    function GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu; virtual;
{$ifdef osc}
    procedure DelOscCon( window : hWnd );
{$endif}
      { Umschalten in Schalter und in Eingangsbaustein des Makroelements. }
    procedure Toggle( A : tPoint ); virtual;
{$ifdef layele}
    procedure SimStart( hLayWin : HWND ); virtual;
    procedure EleTick; virtual;
    procedure ShowMacro; virtual;
{$endif}
  end;

  tDirectionItem = object (tItem)
    X, Y : Integer;
    Direction : Shortint;
    procedure Init;
    procedure Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure StoreText(var t : Text); virtual;
    procedure NewPos(Pos : tPosition); virtual;
    function Position : pPosition; virtual;
    procedure IncDirection; virtual;
    function GetState(A : tPoint; b : Integer) : Integer; virtual;
    function GetInOutPos(Num : Integer) : Longint; virtual;
  end;

  tInOutItem = object (tDirectionItem)
    InCon, OutCon : pConArray;
    function NumInCon : Integer; virtual;
    function NumOutCon : Integer; virtual;
    function GetRegionCon : hRgn; virtual;
    procedure DisposeCon; virtual;
    procedure DeleteCon(Layout : pCollection); virtual;
    procedure InsertCon(Layout : pCollection; PaintDC : hDC); virtual;
    procedure SetCon(Num : Integer; p : pItem; Num_ : Integer); virtual;
    function DelCon(Num : Integer) : Integer; virtual;
    function GetInOutCon(Num : Integer) : pCon; virtual;
  end;

  t1ConItem = object (tDirectionItem)
    on_ : Boolean;
    Con : tCon;
    constructor Init;
    destructor Done; virtual;
    function GetRegionCon : hRgn; virtual;
    function GetRegionInOut : hRgn; virtual;
    procedure DisposeCon; virtual;
    procedure DeleteCon(Layout : pCollection); virtual;
    procedure InsertCon(Layout : pCollection; PaintDC : hDC); virtual;
    function GetInOutNr(A : tPoint) : Integer; virtual;
    function GetInOutCon(Num : Integer) : pCon; virtual;
    procedure SetCon(Num : Integer; p : pItem; Num_ : Integer); virtual;
    function DelCon(Num : Integer) : Integer; virtual;
    procedure PaintInOut(PaintDC : hDC); virtual;
  end;

implementation

{ ------ tCon ----------------------------------------------------------- }

procedure tCon.Init(xCon : pItem; xNum : Integer);
begin
  Con := xCon;
  Num := xNum;
end;

procedure tCon.Done;
begin
  Con := nil;
  Num := 0;
end;

function tCon.DelCon : Integer;
begin
  if Con <> nil
  then DelCon := Con^.DelCon(Num)
  else DelCon := 0;
end;

procedure tCon.Free;
begin
  if Con <> nil
  then Dispose(Con, Done);
end;

procedure tCon.Delete(Layout : pCollection);
begin
  if (con <> nil) and (Layout^.IndexOf(Con) >= 0)
  then Layout^.Delete(con);
end;

procedure tCon.Insert(Layout : pCollection; PaintDC : hDC);
begin
  if (Con <> nil) and (Layout^.IndexOf(Con) < 0) and
     Con^.Full_in_Lay(Layout)
  then begin
    Layout^.Insert(Con);
    Con^.CalcItemRect;
    if PaintDC <> 0 then Con^.Paint(PaintDC);
  end;
end;

procedure tCon.NotPaint(PaintDC : hDC);
begin
  if Con <> nil
  then Con^.NotPaint(PaintDC);
end;

function tCon.GetRegionCon : hRgn;
begin
  if Con = nil
  then GetRegionCon := CreateEmptyRgn
  else GetRegionCon := Con^.GetRegion;
end;

{ ------ tItem ---------------------------------------------------------- }

destructor tItem.Done;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'Done', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

function tItem.Copy : pItem;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'Copy', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

function tItem.Name : pChar;
begin
  Name := nil;
end;

procedure tItem.StoreText(var t : Text);
begin
end;

procedure tItem.Reset;
begin
end;

procedure tItem.NewPos(Pos : tPosition);
begin
  Abstract;
end;

function tItem.PosPoint : longint;
var
  p : pPosition;
  A : tPoint;
begin
  p := Position;
  A.X := p^.X;
  A.Y := p^.Y;
  PosPoint := longint(A);
end;

procedure tItem.SetPos(xX, xY : Integer);
begin
  with pPoint(Position)^
  do begin
    X := xX;
    Y := xY;
  end;
end;

procedure tItem.IncPos(xX, xY : Integer);
begin
  with pPoint(Position)^
  do begin
    inc(X, xX);
    inc(Y, xY);
  end;
  with ItemRect
  do begin
    inc(left, xX);
    inc(top, xY);
    inc(right, xX);
    inc(bottom, xY);
  end;
end;

function tItem.Position : pPosition;
begin
  Abstract;
end;

procedure tItem.IncDirection;
begin
end;

procedure tItem.IncDirection_;
var Pos : pPosition;
begin
  Pos := Position;
  with Pos^
  do begin
    GetPos(X, Y, X, Y, +1);
    NewPos(Pos^);
    IncDirection;
  end;
end;

function tItem.GetRegion : hRgn;
var Rgn, Rgn_ : hRgn;
begin
  Rgn := GetRegion_;
  Rgn_ := GetRegionInOut;
  CombineRgn(Rgn, Rgn, Rgn_, RGN_OR);
  DeleteObject(Rgn_);
  GetRegion := Rgn;
end;

function tItem.GetRegionInOut : hRgn;
begin
  GetRegionInOut := CreateEmptyRgn;
end;

function tItem.GetRegion_ : hRgn;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'GetRegion_', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

function tItem.GetRegionCon : hRgn;
begin
  GetRegionCon := CreateEmptyRgn;
end;

procedure tItem.DisposeCon;
begin
end;

procedure tItem.DeleteCon(Layout : pCollection);
begin
end;

procedure tItem.InsertCon(Layout : pCollection; PaintDC : hDC);
begin
end;

function tItem.GetInOutNr(A : tPoint) : Integer;
begin
  GetInOutNr := 0;
end;

function tItem.GetInOutPos(Num : Integer) : Longint;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'GetInOutPos', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

function tItem.GetInOutPtr(Num : Integer) : pItem;
begin
  GetInOutPtr := GetInOutCon(Num)^.Con;
end;

function tItem.GetInOutCon(Num : Integer) : pCon;
begin
  GetInOutCon := nil; { Unbedingt überschreiben! }
end;

function tItem.GetState(A : tPoint; b : Integer) : Integer;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'GetState', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

procedure tItem.SetCon(Num : Integer; p : pItem; Num_ : Integer);
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'SetCon', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

procedure tItem.SetCon_(Num : Integer; p : pItem; Num_ : Integer);
begin
  SetCon(Num, p, Num_);
end;

function tItem.DelCon(Num : Integer) : Integer;
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'DelCon', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

procedure tItem.NotPaint(PaintDC : hDC);
begin
  Paint(PaintDC);
end;

procedure tItem.Paint(PaintDC : hDC);
begin
  MessageBox(
    pWindow(Application^.MainWindow)^.hWindow,
    'Paint', 'Abstrakte Methode', mb_IconStop + mb_OK);
end;

procedure tItem.Paint_(PaintDC : hDC);
var Rgn : hRgn;
begin
  SetWindowOrg(PaintDC, 0, 0);
  Rgn:=GetRegion_;
  FillRgn(PaintDC, Rgn, GetStockObject(WHITE_BRUSH));
  DeleteObject(Rgn);
  Paint(PaintDC);
end;

procedure tItem.PaintInOut(PaintDC : hDC);
begin
end;

procedure tItem.GetInitImpulse(Impulses : pCollection);
begin
end;

procedure tItem.SendImpulse(
  NumIn, Impulse : Integer;
  PaintCol : pCollection; Impulses : pCollection);
begin
  { Keine Reaktion. Der Impuls "versickert". }
end;

procedure tItem.OutImpulse(Impulses : pCollection);
begin
end;

function tItem.CalcEdit(R : tRect) : hRgn;
var Edit : hRgn;
begin
  Edit := GetRegion;
  if RectInRegion(Edit, R)
  then CalcEdit := Edit
  else begin
    DeleteObject(Edit);
    CalcEdit := 0;
  end;
end;

procedure tItem.StoreInOut(var S : tStream);
begin
end;

function tItem.LoadInOut(var S : tStream) : Boolean;
begin
  LoadInOut := True;
end;

function tItem.Full_in_Lay(Lay : pCollection) : Boolean;
begin
  Full_in_Lay := Lay^.IndexOf(@Self) >= 0;
end;

procedure tItem.CalcItemRect;
var Rgn : hRgn;
begin
  Rgn := GetRegion;
  GetRgnBox(Rgn, ItemRect);
  DeleteObject(Rgn);
end;

procedure tItem.CalcItemRectCon;
var
  i : Integer;
  p : pCon;
begin
  CalcItemRect;
  i:=1;
  repeat
    p:=GetInOutCon(i);
    if (p<>nil) and (p^.Con<>nil)
    then p^.Con^.CalcItemRect;
    inc(i);
  until p=nil;
  i:=-1;
  repeat
    p:=GetInOutCon(i);
    if (p<>nil) and (p^.Con<>nil)
    then p^.Con^.CalcItemRect;
    dec(i);
  until p=nil;
end;

function tItem.Pt_in_Item(A : tPoint) : Boolean;
var Rgn : hRgn;
begin
  if PtInRect(ItemRect, A)
  then begin
    Rgn := GetRegion;
    Pt_in_Item := PtInRegion(Rgn, A.X, A.Y);
    DeleteObject(Rgn);
  end
  else Pt_in_Item := False;
end;

function tItem.Rect_in_Item(R : tRect) : Boolean;
begin
  Rect_in_Item := Boolean(IntersectRect(R, ItemRect, R));
end;

function tItem.Rgn_in_Item(Rgn : hRgn) : Boolean;
var
  R : tRect;
  Rgn_ : hRgn;
begin
  if RectInRegion(Rgn, ItemRect)
  then begin
    Rgn_ := GetRegion;
    Rgn_in_Item := CombineRgn(Rgn_, Rgn_, Rgn, Rgn_And) <> NullRegion;
    DeleteObject(Rgn_);
  end
  else Rgn_in_Item := False;
end;

procedure tItem.ItemEdit(Window : pWindowsObject);
begin
end;

function tItem.GetMenu( ItemMenu : hMenu; window : hWnd ) : hMenu;
begin
  GetMenu := GetSubMenu( ItemMenu, 0 );
end;

{$ifdef osc}
procedure tItem.DelOscCon( window : hWnd );
var
  i : integer;
  con : pCon;
begin
  SendMessage( window, ms_OscDelCon, 0, longint(@self) );
  i := 0;
  repeat
    inc(i);
    con := GetInOutCon(i);
    if con <> nil
    then SendMessage( window, ms_OscDelCon, 0, longint(con^.con) );
  until con = nil;
  i := 0;
  repeat
    dec(i);
    con := GetInOutCon(i);
    if con <> nil
    then SendMessage( window, ms_OscDelCon, 0, longint(con^.con) );
  until con = nil;
end;
{$endif}

procedure tItem.Toggle( A : tPoint );
begin
  { Nur in Schalter und Eingangsbeustein des Makroelements definiert. }
end;

{$ifdef layele}
procedure tItem.SimStart( hLayWin : HWND );
begin
end;

procedure tItem.EleTick;
begin
end;

procedure tItem.ShowMacro;
begin
end;

{$endif}

{ ------ tDirectionItem ------------------------------------------------- }

procedure tDirectionItem.Init;
begin
  FillChar(X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction), $00);
end;

procedure tDirectionItem.Load(var S : tStream);
begin
{$ifdef debug}
  appendLog('DirectionItem.Load 1');
{$endif}
  S.Read(X, SizeOf(X) + SizeOf(Y) + SizeOf(Direction));
{$ifdef debug}
  appendLog('DirectionItem.Load 2');
{$endif}
end;

procedure tDirectionItem.Store(var S : tStream);
begin
  S.Write(X, SizeOf(X) + SizeOf(Y) + SizeOf(Direction));
end;

procedure tDirectionItem.StoreText(var t : Text);
begin
  StoreInt(t, 'x', X);
  StoreInt(t, 'y', Y);
  StoreInt(t, 'direction', Direction);
end;

procedure tDirectionItem.NewPos(Pos : tPosition);
begin
  Move(Pos, X, SizeOf(X)+SizeOf(Y)+SizeOf(Direction));
end;

function tDirectionItem.Position : pPosition;
begin
  Position := @X;
end;

procedure tDirectionItem.IncDirection;
begin
  inc(Direction);
  Direction := Direction and $03;
end;

function tDirectionItem.GetState(A : tPoint; b : Integer) : Integer;
begin
  if (b and lm_Test) = lm_Test
  then GetState := ls_Test
  else
    case (b and lm_First) of
      lm_MouseMove,
      lm_LButton :
        begin
          if GetInOutNr(A) = 0
          then GetState := ls_MoveActItem
          else begin
            if GetInOutPtr(GetInOutNr(A)) = nil
            then GetState := ls_Connection
            else GetState := ls_ConMove;
          end;
        end;
      lm_Connect :
        begin
          if GetInOutNr(A) = 0
          then GetState := ls_ConnectionB
          else
            if GetInOutPtr(GetInOutNr(A)) = nil
            then GetState := ls_Connection
            else GetState := ls_ConnectionC;
        end;
    end;
end;

function tDirectionItem.GetInOutPos(Num : Integer) : Longint;
var A : tPoint;
begin
  A.X := X;
  A.Y := Y;
  GetInOutPos := Longint(A);
end;

{ ------ tInOutItem ----------------------------------------------------- }

function tInOutItem.NumInCon : Integer;
begin
end;

function tInOutItem.NumOutCon : Integer;
begin
end;

function tInOutItem.GetRegionCon : hRgn;
var Rgn : hRgn;
procedure DoCon(Con : pConArray; Num : Integer);
var
  i : Integer;
  Rgn_ : hRgn;
begin
  for i := 0 to Num-1 do
    if Con^[i].Num <> 0
    then begin
      Rgn_ := Con^[i].Con^.GetRegion;
      CombineRgn(Rgn, Rgn, Rgn_, Rgn_Or);
      DeleteObject(Rgn_);
    end;
end;
begin
  Rgn := CreateEmptyRgn;
  DoCon(InCon, NumInCon);
  DoCon(OutCon, NumOutCon);
  GetRegionCon := Rgn;
end;

procedure tInOutItem.DisposeCon;
var i : Integer;
begin
  for i := 0 to NumInCon-1 do InCon^[i].Free;
  for i := 0 to NumOutCon-1 do OutCon^[i].Free;
end;

procedure tInOutItem.DeleteCon(Layout : pCollection);
var i : Integer;
begin
  for i := 0 to NumInCon-1 do
    InCon^[i].Delete(Layout);
  for i := 0 to NumOutCon-1 do
    OutCon^[i].Delete(Layout);
end;

procedure tInOutItem.InsertCon(Layout : pCollection; PaintDC : hDC);
var i : Integer;
begin
  for i := 0 to NumInCon-1 do
    InCon^[i].Insert(Layout, PaintDC);
  for i := 0 to NumOutCon-1 do
    OutCon^[i].Insert(Layout, PaintDC);
end;

procedure tInOutItem.SetCon(Num : Integer; p : pItem; Num_ : Integer);
begin
  if Num > 0
  then InCon^[Num-1].Init(p, Num_)
  else OutCon^[(-Num)-1].Init(p, Num_);
end;

function tInOutItem.DelCon(Num : Integer) : Integer;
begin
  if Num > 0
  then InCon^[Num-1].Done
  else OutCon^[(-Num)-1].Done;
  DelCon := Num;
end;

function tInOutItem.GetInOutCon(Num : Integer) : pCon;
begin
  if Num=0
  then begin
    GetInOutCon := nil;
  end
  else if Num > 0
  then begin
    if Num<=NumInCon
    then GetInOutCon := @InCon^[Num-1]
    else GetInOutCon := nil;
  end
  else begin
    if (-Num)<=NumOutCon
    then GetInOutCon := @OutCon^[(-Num)-1]
    else GetInOutCon := nil;
  end;
end;

{ ------ t1ConItem ------------------------------------------------------ }

constructor t1ConItem.Init;
begin
  inherited Init;
  on_ := False;
  Con.Done;
end;

destructor t1ConItem.Done;
begin
  Con.DelCon;
end;

function t1ConItem.GetRegionCon : hRgn;
begin
  GetRegionCon := Con.GetRegionCon;
end;

function t1ConItem.GetRegionInOut : hRgn;
var Rgn : hRgn;
begin
  Rgn := CreateEllipticRgn(-4, -4, +4, +4);
  OffSetRgn(Rgn, X, Y);
  GetRegionInOut := Rgn;
end;

procedure t1ConItem.DisposeCon;
begin
  Con.Free;
end;

procedure t1ConItem.DeleteCon(Layout : pCollection);
begin
  Con.Delete(Layout);
end;

procedure t1ConItem.InsertCon(Layout : pCollection; PaintDC : hDC);
begin
  Con.Insert(Layout, PaintDC);
end;

function t1ConItem.GetInOutNr(A : tPoint) : Integer;
var B : tPoint;
begin
  B.X := X;
  B.Y := Y;
  if EqualPt(A, B)
  then GetInOutNr := 1
  else GetInOutNr := 0;
end;

function t1ConItem.GetInOutCon(Num : Integer) : pCon;
begin
  if Num=1
  then GetInOutCon := @Con
  else GetInOutCon := nil;
end;

procedure t1ConItem.SetCon(Num : Integer; p : pItem; Num_ : Integer);
begin
  with Con
  do begin
    Con := p;
    Num := Num_;
  end;
end;

function t1ConItem.DelCon(Num : Integer) : Integer;
begin
  Con.Done;
  DelCon := Num;
end;

procedure t1ConItem.PaintInOut(PaintDC : hDC);
var
  Font : hFont;
begin
  SetWindowOrg(PaintDC, -X, -Y);
  Font := SetInOutFont(PaintDC, Direction);
  DrawInOut(PaintDC, 0, 0, Direction, -1);
  DeleteObject(Font);
end;

end.