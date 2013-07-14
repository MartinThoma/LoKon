unit Impulse;
{$I define.inc}

interface

uses
  LK_Const,
  Objects,
  WinTypes,
  WinProcs,
  EleFile,
  Item;

type
  pImpulse = ^tImpulse;
  tImpulse = object (tObject)
    ActItem : pItem;
    NumIn, Impulse : Integer;
    Time : Word;
    constructor Init(
      xActItem : pItem; xNumIn, xImpulse : Integer; xTime : Word);
    constructor Load(var S : tStream);
    procedure Store(var S : tStream);
    procedure Tick(PaintCol : pCollection; Impulses : pCollection);
  end;

implementation

{ ------ tImpulse ------------------------------------------------------- }

constructor tImpulse.Init(
  xActItem : pItem; xNumIn, xImpulse : Integer; xTime : Word);
begin
  ActItem := xActItem;
  NumIn := xNumIn;
  Impulse := xImpulse;
  Time := xTime;
end;

constructor tImpulse.Load(var S : tStream);
var
  i : Integer;
begin
  S.Read(i, SizeOf(i));
  if i>=0
  then ActItem := pItem(ActLay^.Layout^.At(i))
  else ActItem := nil;
  S.Read(NumIn, SizeOf(NumIn)+SizeOf(Impulse)+SizeOf(Time));
end;

procedure tImpulse.Store(var S : tStream);
var
  i : Integer;
begin
  i := ActLay^.Layout^.IndexOf(ActItem);
  S.Write(i, SizeOf(i));
  S.Write(NumIn, SizeOf(NumIn)+SizeOf(Impulse)+SizeOf(Time));
end;

{$B-}
procedure tImpulse.Tick(PaintCol : pCollection; Impulses : pCollection);
begin
  dec(Time);
  { Nur mit LAZY-Evalutation kompilieren ! }
  if (Time = $ffff) and (ActItem <> nil)
  then ActItem^.SendImpulse(NumIn, Impulse, PaintCol, Impulses);
end;

{ ------ rImpulse ------------------------------------------------------- }

const
  rImpulse : TStreamRec = (
     ObjType : riImpulse;
     VmtLink : Ofs(TypeOf(tImpulse)^);
     Load  : @tImpulse.Load;
     Store : @tImpulse.Store
  );

{ ------ Registrierung -------------------------------------------------- }

begin
  RegisterType(rImpulse);
end.