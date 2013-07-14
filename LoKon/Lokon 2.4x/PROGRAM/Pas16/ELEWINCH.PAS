unit EleWinCh;
{$I define.inc}

interface

uses
  Messages,
  Strings,
  WinTypes, WinProcs,
  OWindows,
  LK_const,
  Paint;

type
  pEleWinChild = ^tEleWinChild;
  tEleWinChild = object ( tPaint )
    EleWinParent : pWindowsObject;
    constructor Init( xParent : pWindowsObject; s : pChar );
    procedure msEleWin(var Msg : tMessage);
      virtual ms_EleWin;
    procedure msIsShown(var Msg : tMessage);
      virtual ms_IsShown;
  end;

implementation

{ ------ tEleWinChild --------------------------------------------------- }


constructor tEleWinChild.Init( xParent : pWindowsObject; s : pChar );
begin
  inherited Init(Application^.MainWindow, s);
  EleWinParent := xParent;
end;

procedure tEleWinChild.msIsShown(var Msg : tMessage);
begin
  if ( Msg.wParam = EleWinParent^.hWindow ) and
     ( StrComp( pChar(Msg.lParam), Attr.Title ) = 0 )
  then Msg.Result := longint(@Self)
  else Msg.Result := longint(nil);
end;

procedure tEleWinChild.msEleWin(var Msg : tMessage);
begin
  if Longint(EleWinParent) = Msg.lParam
  then begin
    case Msg.wParam of
      ew_Destroy : SendMessage( hWindow, wm_Close, 0, 0);
      ew_EleWinStored : NotClose := False;
      ew_NotClose : Msg.Result := Longint(NotClose);
    end;
  end;
end;

end.