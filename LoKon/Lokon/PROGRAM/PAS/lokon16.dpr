program Lokon16;

uses
  Forms,
  Bitmap in 'BITMAP.PAS',
  Connect in 'CONNECT.PAS',
  ConNode in 'CONNODE.PAS',
  EleFile in 'ELEFILE.PAS',
  EleItem in 'ELEITEM.PAS',
  Element in 'ELEMENT.PAS',
  EleWin in 'ELEWIN.PAS',
  Elewinch in 'ELEWINCH.PAS',
  Graphic in 'GRAPHIC.PAS',
  Impulse in 'IMPULSE.PAS',
  Item in 'ITEM.PAS',
  ItemText in 'ITEMTEXT.PAS',
  LayWin in 'LAYWIN.PAS',
  LK_Const in 'LK_CONST.PAS',
  LoKon in 'LOKON.PAS',
  MacroWin in 'MACROWIN.PAS',
  MainWin in 'MAINWIN.PAS',
  OPrinter in 'OPRINTER.PAS',
  OscWin in 'OSCWIN.PAS',
  OWinEx in 'OWINEX.PAS',
  ZeroOne in 'ZEROONE.PAS',
  Tick in 'TICK.PAS',
  Switch in 'SWITCH.PAS',
  ScrolOrg in 'SCROLORG.PAS',
  ROMRAM in 'ROMRAM.PAS',
  PLA in 'PLA.PAS',
  Paint in 'PAINT.PAS';

{$R *.RES}

begin
  Application.Title := 'LoKon';
  Application.Run;
end.
