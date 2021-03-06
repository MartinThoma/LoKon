//#define _small
//#define _mini
#define _full
#undef _manual
#undef _userdef
//#define _small
//#define _mini

//#define _update
#undef _update

//
// Setup-Programm f�r LoKon
//
// Beginn: 10. 3. 1995
//    bis: 13. 4. 1995
//     in:   29h
//
// Englische Version.
//         28.11. 1995
//     in:    1h
//
//         06.03.1996 - LoKon V1.6
//     in:    1h
//
//         06.05.1996 - SETUP.INI
//         07.05.1996
//     in:    3h
//
// �nderung:
//         05.01.1998
//     in:    3h
//
// gesamt:   37h

#define WIN31
#include <owl.h>
#include <string.h>
#include <dir.h>
#include <stdio.h>
#include <lzexpand.h>
#include <sys/stat.h>
#include <time.h>
#include <dde.h>
#include <string.h>
#include "setup.h"
#include "ddeclient.h"

// TDialogEx    
class TDialogEx : public TDialog
{
public:
  static HBRUSH BkBrush;
  // Konstruktor
  TDialogEx(PTWindowsObject AParent, int ResourceId) :
    TDialog(AParent, ResourceId) {};
  // grauer Hintergrund
  virtual void WMCtlColor( TMessage& Msg ) = [ WM_FIRST + WM_CTLCOLOR ]
  {
    switch (Msg.LP.Hi)
    {
      case
	CTLCOLOR_EDIT,
	CTLCOLOR_LISTBOX :
	Msg.Result = NULL;
	break;
      default:
	SetTextColor( Msg.WParam, GetSysColor(COLOR_BTNTEXT) );
	SetBkColor( Msg.WParam, GetSysColor( COLOR_BTNFACE ) );
	Msg.Result = BkBrush;
        break;
    }
  }
};

HBRUSH TDialogEx::BkBrush;

// TSetupWindow
class TSetupWin : public TDDEClient
{
public:
  // Sprache
  static int language;
  static char dest_dir[256];
  static char src_dir[256];
  static char lang;
  static int stat_lang; 
  static char sHelp[64];
  static int Norm;
  static char LoKonVersion[20];
  static char LoKonVersionName[4];
  static char LoKonDate[20];
  static char RegName[61];
  static char RegCodeL[7];
  static char RegCodeH[7];
  static int pdeu, updeu;
  static int peng, upeng;
  int psize, upsize;
  char LoKon_INI_File[256];
protected:
  PTWindowsObject ProgressDlg;
  // Was intslliert werden soll
  int install;
public:
  // Konstruktor
  TSetupWin()
    : TDDEClient( NULL, "Setup" )
  { Attr.Style = WS_BORDER; };
  // Destruktor
  virtual ~TSetupWin()
  { LZDone(); };
protected:
  // Name
  virtual LPSTR GetClassName() { return "LoKonTSetupWin"; };
  // Klasseneigenschaften
  virtual void GetWindowClass(WNDCLASS _FAR & AWndClass);
  // SetupWindow
  virtual void SetupWindow();
  // Fenster malen
  virtual void Paint(HDC PaintDC, PAINTSTRUCT _FAR &);
  // Shareware-Information
  virtual void WMShareware( TMessage& ) = [ WM_FIRST + WM_SHAREWARE ];
  // Installation
  virtual void WMInstall( TMessage& ) = [ WM_FIRST + WM_INSTALL ];
  // Dekomprimierung
  virtual void WMDecompress( TMessage& Message ) = [ WM_FIRST + WM_DECOMPRESS ];
  // Schlu�
  virtual void WMEndSetup( TMessage& ) = [ WM_FIRST + WM_ENDSETUP ];
  // Eine Datei dekomprimieren.
  void decompress_( const char *src_name, const char *dest_name );
  void decompress( const char *src_name, const char *dest_name );
  // LoKon-Gruppe in Program-Manager einf�gen
  void ProgramManager(void);
  // Mit Program-Manager kommunizieren.
  virtual void WMDDEAck( TMessage& Msg ) = [ WM_FIRST + WM_DDE_ACK ];
  // PrivateProfileString schreiben, ggf. alte Einstellungen �bernehmen
  void WritePrivateProfileStr( LPSTR lpAppName, LPSTR lpKeyName, LPSTR lpString )
  {
    WritePrivateProfileString( lpAppName, lpKeyName, lpString, LoKon_INI_File );
  }
  void setAlias( char* alias, char* file );

};

int TSetupWin::language;
char TSetupWin::dest_dir[256];
char TSetupWin::src_dir[256] = "C:\\";
char TSetupWin::lang;
int TSetupWin::stat_lang;
char TSetupWin::sHelp[64];
char TSetupWin::LoKonVersion[20];
char TSetupWin::LoKonVersionName[4];
char TSetupWin::LoKonDate[20];
char TSetupWin::RegName[61];
char TSetupWin::RegCodeL[7];
char TSetupWin::RegCodeH[7];
int TSetupWin::pdeu;
int TSetupWin::updeu;
int TSetupWin::peng;
int TSetupWin::upeng;
int TSetupWin::Norm;

#define inherited TDDEClient::

// Klasseneigenschaften
void TSetupWin::GetWindowClass(WNDCLASS _FAR & AWndClass)
{
  inherited GetWindowClass(AWndClass);
  AWndClass.style = CS_HREDRAW|CS_VREDRAW;
  AWndClass.hIcon =
    LoadIcon(
      GetApplicationObject()->hInstance ,
      MAKEINTRESOURCE(SETUPICON));
  AWndClass.hbrBackground = NULL;
}

// SetupWindow
void TSetupWin::SetupWindow()
{
  inherited SetupWindow();
  // Verzeichnis
  {
    char s[256];
    getcurdir (0, s);
    int d=getdisk();
    src_dir[0]=(char)(d+'A');
    if (strlen(s)>0)
      strcat(strcat( src_dir, s ), "\\");
  }
  // SETUP.INI
  {
    char s[256], s2[4];
    strcpy( s, src_dir);
    strcat( s, "setup.ini" );
    GetPrivateProfileString( "GENERAL", "lang", "B", s2, 2, s );
    lang = s2[0];
    GetPrivateProfileString( "GENERAL", "version", "x.x", LoKonVersion, 20, s );
    GetPrivateProfileString( "GENERAL", "versionname", "xx", LoKonVersionName, 4, s );
    GetPrivateProfileString( "GENERAL", "date", "xx.xx.xxxx", LoKonDate, 11, s );
    // Registrierung
    GetPrivateProfileString( "REG", "name", "SHAREWARE", RegName, 60, s );
    GetPrivateProfileString( "REG", "codel", "", RegCodeL, 6, s );
    GetPrivateProfileString( "REG", "codeh", "", RegCodeH, 6, s );
    // Gr��en
    pdeu = GetPrivateProfileInt( "SIZE", "pdeu", 3000, s );
    updeu = GetPrivateProfileInt( "SIZE", "updeu", 6000, s );
    peng = GetPrivateProfileInt( "SIZE", "peng", 3000, s );
    upeng = GetPrivateProfileInt( "SIZE", "upeng", 6000, s );
  }
  if ( lang == 'B' )
  {
    char s[100];
    // Sprache
    GetProfileString("Intl", "sLanguage", "ENG", s, 4);
    if (!stricmp(s, "DEU"))
      lang = 'D';
    else
      lang = 'E';
    TSetupWin::stat_lang = 0;
  }
  else
    TSetupWin::stat_lang = 1;
  if ( lang == 'D' )
    language = GER;
  else
    language = ENG;
  // Info
  LoadString(
    GetApplicationObject()->hInstance,
    HELPTEXT|language, sHelp, 63 );
  UpdateWindow( HWindow );
  PostMessage( HWindow, WM_SHAREWARE, 0, 0 );
}

// Fenster malen
void TSetupWin::Paint( HDC PaintDC, PAINTSTRUCT _FAR & )
{
  RECT R;
  GetClientRect( HWindow, &R );
  {
    int dy, y;
    BYTE blue;
    SelectObject(PaintDC, GetStockObject(NULL_PEN));
    for (
      dy=(R.bottom+127)/128,
      y=R.top, blue=255;
      y<R.bottom; y+=dy, blue-=1 )
    {
      HBRUSH brush=(HBRUSH)SelectObject( PaintDC, CreateSolidBrush(RGB(0, 0, blue)) );
      Rectangle(
        PaintDC,
        R.left, y,
        R.right+1, y+dy+1);
      DeleteObject( SelectObject( PaintDC, brush ) );
    }
  }
  int dy=R.bottom-R.top;
  int sy=(dy+59)/60;
  int h=(dy+5)/6;
  int dx=R.right-R.left;
  int sx=(dx+59)/60;
  HFONT font1=CreateFont(
#ifdef _full
    (dy+5)/6, (dx+15)/18, // H�he, Breite
#endif
#if defined(_mini) || defined(_small)
    (dy+5)/6, (dx+15)/22, // H�he, Breite
#endif
    0, 0, // Orientierung
    700, // fett
    0, 0, 0, //
    ANSI_CHARSET, //
    OUT_DEFAULT_PRECIS, //
    CLIP_DEFAULT_PRECIS, //
    DEFAULT_QUALITY, //
    DEFAULT_PITCH|FF_DONTCARE, //
    "Arial" // Schriftart
    );
  HFONT font2=CreateFont(
    (dy+9)/10, (dx+8)/9, // H�he, Breite
    0, 0, // Orientierung
    400, // normal
    0, 0, 0, //
    ANSI_CHARSET, //
    OUT_DEFAULT_PRECIS, //
    CLIP_DEFAULT_PRECIS, //
    DEFAULT_QUALITY, //
    DEFAULT_PITCH|FF_DONTCARE, //
    "Arial" // Schriftart
    );
  HFONT font3=CreateFont(
    (dy+40)/41, (dx+35)/36, // H�he, Breite
    0, 0, // Orientierung
    400, // normal
    0, 0, 0, //
    ANSI_CHARSET, //
    OUT_DEFAULT_PRECIS, //
    CLIP_DEFAULT_PRECIS, //
    DEFAULT_QUALITY, //
    DEFAULT_PITCH|FF_DONTCARE, //
    "Times" // Schriftart
    );
  SetBkMode(PaintDC, TRANSPARENT);
  SetTextAlign(PaintDC, TA_TOP|TA_LEFT);
  SetTextColor(PaintDC, RGB(0, 0, 0));
  HFONT font=(HFONT)SelectObject(PaintDC, font1);

  {
    char s[40]="LoKon ";
    strcat( s, LoKonVersion );
    TextOut( PaintDC, sx, sy, s, strlen(s) );
    SelectObject(PaintDC, font2);
    TextOut( PaintDC, sx, sy+h, "Setup", 5 );
    SetTextColor(PaintDC, RGB(255, 255, 255));
    SelectObject(PaintDC, font1);
    TextOut(PaintDC, 0, 0, s, strlen(s));
    SelectObject(PaintDC, font2);
    TextOut( PaintDC, 0, h, "Setup", 5);
    SelectObject(PaintDC, font3);
    SetTextColor(PaintDC, RGB(192, 192, 192));
    TextOut( PaintDC, 0, 2*h, LoKonDate, 10 );
  }

  SelectObject( PaintDC, font );
  DeleteObject( font1 );
  DeleteObject( font2 );
  DeleteObject( font3 );
}

// Shareware-Information
void TSetupWin::WMShareware( TMessage& )
{
  char s1[256], s2[31], s3[256];
  LoadString(
    GetApplicationObject()->hInstance,
    SHAREWARE|language, s1, 255);
  LoadString(
    GetApplicationObject()->hInstance,
    NOCHANGES1|language, s2, 30);
  LoadString(
    GetApplicationObject()->hInstance,
    NOCHANGES2|language, s3, 255);
  if ( (MessageBox(
          HWindow, s1, "Shareware",
          MB_ICONINFORMATION|MB_OKCANCEL) == IDOK) &&
        (MessageBox(
          HWindow, s3, s2,
          MB_ICONINFORMATION|MB_YESNO) == IDYES) )
    PostMessage( HWindow, WM_INSTALL, 0, 0 );
  else
    PostMessage( HWindow, WM_CLOSE, 0, 0 );
}

// Installation
class TDirectoryDlg : public TDialogEx
{
public:
  // Konstruktor
  TDirectoryDlg(PTWindowsObject AParent, int ResourceId) :
    TDialogEx(AParent, ResourceId) {};
protected:
  // SetupWindow
  virtual void SetupWindow()
    { TDialogEx::SetupWindow(); };
  // Help
  virtual void IDHelp( RTMessage ) = [ ID_FIRST + IDHELP ];
  // OK
  virtual void Ok( RTMessage ) = [ID_FIRST + IDOK];
};
// Help
void TDirectoryDlg::IDHelp( RTMessage )
{
  char sText[1024];
  LoadString(
    GetApplicationObject()->hInstance,
    DIRECTORYHELP|TSetupWin::language, sText, 1023 );
  MessageBox( HWindow, sText, TSetupWin::sHelp, MB_OK );
}
void TDirectoryDlg::Ok(RTMessage)
{
  GetDlgItemText( HWindow, 100, TSetupWin::dest_dir, 255 );
  if (chdir(TSetupWin::dest_dir)==0)
  {
    char s[256];
    LoadString(
      GetApplicationObject()->hInstance,
      DIREXISTS|TSetupWin::language, s, 255);
    if (MessageBox( HWindow, s, "Setup", MB_ICONQUESTION|MB_YESNO)==IDYES)
      EndDialog(HWindow, IDOK);
  }
  else
  {
    char s[256];
    LoadString(
      GetApplicationObject()->hInstance,
      NODIR|TSetupWin::language, s, 255);
    if (MessageBox( HWindow, s, "Setup", MB_ICONQUESTION|MB_YESNO)==IDYES)
    {
      mkdir( TSetupWin::dest_dir);
      EndDialog( HWindow, IDOK );
    }
  }
  strcat( TSetupWin::dest_dir, "\\" );
  chdir( TSetupWin::src_dir );
};
class TLanguageDlg : public TDialogEx
{
public:
  // Konstruktor
  TLanguageDlg(PTWindowsObject AParent, int ResourceId) :
    TDialogEx(AParent, ResourceId) {};
protected:
  // SetupWindow
  virtual void SetupWindow()
    {
      TDialogEx::SetupWindow();
      if ( TSetupWin::stat_lang )
      {
        EnableWindow( GetDlgItem( HWindow, 100 ), FALSE );
	EnableWindow( GetDlgItem( HWindow, 1100 ), FALSE );
	EnableWindow( GetDlgItem( HWindow, TSetupWin::language|100 ), TRUE );
      }
      CheckDlgButton( HWindow, TSetupWin::language|100, TRUE );
    };
  // Help
  virtual void IDHelp( RTMessage ) = [ ID_FIRST + IDHELP ];
  // OK
  virtual void Ok( RTMessage ) = [ID_FIRST + IDOK];
};
// Help
void TLanguageDlg::IDHelp( RTMessage )
{
  char s[1024];
  LoadString(
    GetApplicationObject()->hInstance,
    LANGUAGEHELP|TSetupWin::language, s, 1023 );
  MessageBox( HWindow, s, TSetupWin::sHelp, MB_OK );
}
// OK
void TLanguageDlg::Ok( RTMessage )
{
  if ( IsDlgButtonChecked( HWindow, 100 ) )
  {
    TSetupWin::language = GER;
    TSetupWin::lang = 'D';
  }
  else
  {
    TSetupWin::language = ENG;
    TSetupWin::lang = 'E';
  }
  EndDialog(HWindow, IDOK);
}

#ifdef _manual
class TInstallDlg : public TDialogEx
{
public:
  // Konstruktor
  TInstallDlg(PTWindowsObject AParent, int ResourceId) :
    TDialogEx(AParent, ResourceId) {};
protected:
  // SetupWindow
  virtual void SetupWindow();
  // Help
  virtual void IDHelp( RTMessage ) = [ ID_FIRST + IDHELP ];
  // OK
  virtual void Ok(RTMessage Msg) = [ID_FIRST + IDOK];
};
// SetupWindow
void TInstallDlg::SetupWindow()
{
  TDialogEx::SetupWindow();
  CheckDlgButton( HWindow, 100, TRUE );
};
// Help
void TInstallDlg::IDHelp( RTMessage )
{
  char s[1024];
  LoadString(
    GetApplicationObject()->hInstance,
    INSTALLHELP|TSetupWin::language, s, 1023);
  MessageBox( HWindow, s, TSetupWin::sHelp, MB_OK );
}
// OK
void TInstallDlg::Ok(RTMessage Msg)
{
  if (IsDlgButtonChecked( HWindow, 100 )) EndDialog( HWindow, 100);
  else if (IsDlgButtonChecked( HWindow, 101 )) EndDialog( HWindow, 101);
  else EndDialog( HWindow, 102);
};
#endif
#ifdef _userdef
class TUserInstDlg : public TDialogEx
{
public:
  // Konstruktor
  TUserInstDlg(PTWindowsObject AParent, int ResourceId) :
    TDialogEx(AParent, ResourceId) {};
protected:
  // SetupWindow
  virtual void SetupWindow()
    { TDialogEx::SetupWindow();
      CheckDlgButton( HWindow, 100, TRUE ); 
      CheckDlgButton( HWindow, 101, TRUE ); 
      CheckDlgButton( HWindow, 110, TRUE ); 
      CheckDlgButton( HWindow, 120, TRUE ); };
};
#endif
class TProgressDlg : public TDialogEx
{
protected:
  long sum1, all1;
  long sum2, all2;
public:
  // Konstruktor
  TProgressDlg(PTWindowsObject AParent, int ResourceId)
  :TDialogEx(AParent, ResourceId)
  { sum1=0; sum2=0; all2=1; };
protected:
  // insgesamt setzen
  virtual void WMSetAll( TMessage &Message ) = [ WM_FIRST+WM_SETALL ];
  // Dateiname setzen
  virtual void WMFILENAME( TMessage &Message ) = [ WM_FIRST+WM_FILENAME ];
  // Summe erh�hen
  virtual void WMIncSum( TMessage &Message ) = [ WM_FIRST+WM_INCSUM ];
  // Balken zeichnen
  virtual void WMDrawItem( TMessage &Message ) = [ WM_FIRST+WM_DRAWITEM ];
};
// insgesamt setzen
void TProgressDlg::WMSetAll( TMessage &Message )
{
  switch (Message.WParam)
  {
    case 1:
      all1=(long)Message.LParam * 1024;
      break;
    case 2:
      all2=(long)Message.LParam * 1024;
      break;
  }
}
// Dateiname setzen
void TProgressDlg::WMFILENAME( TMessage &Message )
{
  SetDlgItemText( HWindow, 100, (LPSTR)Message.LParam);
}
// Summe erh�hen
void TProgressDlg::WMIncSum( TMessage &Message )
{
  HWND wnd;
  switch (Message.WParam)
  {
    case 1:
      sum1+=Message.LParam;
      wnd=GetItemHandle(110);
      break;
    case 2:
      sum2+=Message.LParam;
      wnd=GetItemHandle(120);
      break;
  }
  InvalidateRect( wnd, NULL, TRUE );
  UpdateWindow(wnd);
}
// Balken zeichnen
void TProgressDlg::WMDrawItem( TMessage &Message )
{
  HDC hDC=((DRAWITEMSTRUCT*)Message.LParam)->hDC;
  RECT R=((DRAWITEMSTRUCT*)Message.LParam)->rcItem;
  HBRUSH brush;
  long dx=R.right-R.left;
  switch (((DRAWITEMSTRUCT*)Message.LParam)->CtlID)
  {
    case 110:
      brush=(HBRUSH)CreateSolidBrush( RGB(0,255,0) );
      dx=(long(dx)*long(sum1))/long(all1);
      break;
    case 120:
      brush=(HBRUSH)CreateSolidBrush( RGB(0,0,255) );
      dx=(long(dx)*long(sum2))/long(all2);
      break;
  }
  HBRUSH brush_=(HBRUSH)SelectObject( hDC, brush );
  SelectObject( hDC, GetStockObject( NULL_PEN ) );
  Rectangle( hDC, R.left, R.top, dx+1, R.bottom+1 );
  SetTextColor( hDC, RGB(0,0,0) );
  SetBkMode( hDC, TRANSPARENT );
  SetROP2( hDC, R2_MERGEPENNOT );
  SetTextAlign( hDC, TA_CENTER|TA_NOUPDATECP );
  dx=(dx*100)/(R.right-R.left);
  char s[12];
  wvsprintf( s, "%3lu%%", &dx);
  ExtTextOut( hDC, (R.right-R.left)/2, R.top/2, 0, &R, s, 4, NULL );
  DeleteObject( SelectObject( hDC, brush_) );
}

class TNormDlg : public TDialogEx
{
public:
  // Konstruktor
  TNormDlg(PTWindowsObject AParent, int ResourceId) :
    TDialogEx(AParent, ResourceId) {};
protected:
  // SetupWindow
  virtual void SetupWindow()
    { TDialogEx::SetupWindow();
      CheckDlgButton( HWindow, 100, TRUE ); };
  // OK
  virtual void Ok(RTMessage Msg) = [ID_FIRST + IDOK];
};

// OK
void TNormDlg::Ok( RTMessage )
{
  if ( IsDlgButtonChecked( HWindow, 100 ) )
    TSetupWin::Norm = GER;
  else
    TSetupWin::Norm = ENG;
  EndDialog(HWindow, IDOK);
}

void TSetupWin::WMInstall( TMessage& )
{
  LZStart();
  if ( (GetApplication()->ExecDialog(
          new TDirectoryDlg(this, DIRECTORY|language))==IDOK) &&
       (GetApplication()->ExecDialog(
	  new TLanguageDlg(this, LANGUAGE|language))==IDOK) )
  {
    if (language==ENG)
    {
      psize = peng;
      upsize = upeng;
    }
    else
    {
      psize = pdeu;
      upsize = updeu;
    }
#ifdef _manual
    int i=GetApplication()->ExecDialog(
      new TInstallDlg(this, INSTALL|language));
#endif
    GetApplication()->ExecDialog(
      new TNormDlg(this, NORM|language));
    ProgressDlg=GetApplicationObject()->MakeWindow(
      new TProgressDlg( this, PROGRESS|language ));
#ifdef _manual
    switch (i)
    {
      case 101:
        if (GetApplication()->ExecDialog(
              new TUserInstDlg(this, USERINST|language))!=IDOK)
          PostMessage( HWindow, WM_CLOSE, 0, 0);
        break;
      case 100:
	SendMessage( ProgressDlg->HWindow, WM_SETALL, 1, 969728 );
	SendMessage( ProgressDlg->HWindow, WM_SETALL, 2, 3470786 );
        PostMessage( HWindow, WM_DECOMPRESS, ELEDIN|ELEAM|LAYOUT|HELP|MANUAL|DLL|EXE|INI, 0 );
	break;
      case 102:
#endif
        SendMessage( ProgressDlg->HWindow, WM_SETALL, 1, psize );
	SendMessage( ProgressDlg->HWindow, WM_SETALL, 2, upsize );
	PostMessage( HWindow, WM_DECOMPRESS, ELEDIN|ELEAM|LAYOUT|HELP|DLL|EXE|INI, 0 );
#ifdef _manual
	break;
      default: PostMessage( HWindow, WM_CLOSE, 0, 0);
    }
#endif
  }
  else
    PostMessage( HWindow, WM_CLOSE, 0, 0);
}

// Dekomprimierung
void TSetupWin::WMDecompress( TMessage& Message )
{
  if (Message.WParam&ELEDIN)
  {
    decompress( "DIS_DIN.E", "DIS_DIN.ELE" );
    decompress( "ELE_DIN.E", "ELE_DIN.ELE" );
    decompress( "REG_DIN.E", "REG_DIN.ELE" );
    decompress( "ANALOG.E", "ANALOG.ELE" );
#ifdef _full
    decompress( "ELE_DIN2.E", "ELE_DIN2.ELE" );
    decompress( "TTL.E", "TTL.ELE" );
#endif
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^ELEDIN, 0 );
  }
  else if (Message.WParam&ELEAM)
  {
    //decompress( "DIS_AM.E", "DIS_AM.ELE" );
    decompress( "ELE_AM.E", "ELE_AM.ELE" );
    //decompress( "REG_AM.E", "REG_AM.ELE" );
    decompress( "DIS_DIN.E", "DIS_DIN.ELE" );
    decompress( "REG_DIN.E", "REG_DIN.ELE" );
    decompress( "ANALOG.E", "ANALOG.ELE" );
#ifdef _full
    decompress( "ELE_DIN2.E", "ELE_DIN2.ELE" );
    decompress( "TTL.E", "TTL.ELE" );
#endif
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^ELEAM, 0 );
  }
  else if (Message.WParam&LAYOUT)
  {
#if defined(_full)
    decompress_( "MACRO.LA_", "MACRO.LAY" );
    decompress_( "MACRO2.LA_", "MACRO2.LAY" );
    decompress_( "MACRO.EL_", "MACRO.ELE" );
#endif
#if defined(_full) || defined(_small)
    decompress( "4BITREG.L", "4BITREG.LAY" );
#endif
    if (language == GER)
    {
#if defined(_full) || defined(_small)
    decompress( "7SEG.L", "7SEG.LAY" );
    decompress( "ELEMENTE.L", "ELEMENTE.LAY" );
    decompress( "FLIPFLOP.L", "FLIPFLOP.LAY" );
#endif
    decompress( "8BITADD.L", "8BITADD.LAY" );
    decompress( "ANZEIGE.L", "ANZEIGE.LAY" );
    decompress( "BSP01.L", "BSP01.LAY" );
    decompress( "BSP02.L", "BSP02.LAY" );
    decompress( "BSP03.L", "BSP03.LAY" );
    decompress( "HALBADD.L", "HALBADD.LAY" );
    decompress( "PARSER.L", "PARSER.LAY" );
    decompress( "SCHIEB.L", "SCHIEB.LAY" );
    decompress( "SERPAR.L", "SERPAR.LAY" );
    }
    else
    {
#if defined(_full) || defined(_small)
    decompress( "7SEG.L", "7SEG.LAY" );
    decompress( "ELEMENTS.L", "ELEMENTS.LAY" );
    decompress( "FLIPFLOP.L", "FLIPFLOP.LAY" );
#endif
    decompress( "8BITADD.L", "8BITADD.LAY" );
    decompress( "DISPLAY.L", "DISPLAY.LAY" );
    decompress( "EXP01.L", "EXP01.LAY" );
    decompress( "EXP02.L", "EXP02.LAY" );
    decompress( "EXP03.L", "EXP03.LAY" );
    decompress( "HALFADD.L", "HALFADD.LAY" );
    decompress( "PARSER.L", "PARSER.LAY" );
    decompress( "SHIFT.L", "SHIFT.LAY" );
    decompress( "SERPAR.L", "SERPAR.LAY" );
    }
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^LAYOUT, 0 );
  }
  else if (Message.WParam&DLL)
  {
    decompress( "LOKONRES.D", "LOKONRES.DLL" );
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^DLL, 0 );
  }
  else if (Message.WParam&EXE)
  {
    decompress( "INTERN.E", "INTERN.ELE");
    decompress_( "LOKON.EX_", "LOKON.EXE" );
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^EXE, 0 );
  }
  else if (Message.WParam&MANUAL)
  {
    //decompress( "MANUAL.R", "MANUAL.REC" );
#ifdef _manual
    decompress( "LOKON.W", "LOKON.WRI" );
    decompress( "LOKON00.W", "LOKON00.WRI" );
    decompress( "LOKON01.W", "LOKON01.WRI" );
    decompress( "LOKON02.W", "LOKON02.WRI" );
    decompress( "LOKON03.W", "LOKON03.WRI" );
#ifdef _full
    decompress( "LOKON04.W", "LOKON04.WRI" );
    decompress( "LOKON05.W", "LOKON05.WRI" );
    decompress( "LOKON06.W", "LOKON06.WRI" );
#endif
#ifdef _small
    decompress( "LOKON04.W", "LOKON04.WRI" );
#endif
    if (language==GER)
#ifdef _full
      decompress( "LOKON07.W", "LOKON07.WRI" );
#endif
#ifdef _small
      decompress( "LOKON05.W", "LOKON05.WRI" );
#endif
#ifdef _mini
      decompress( "LOKON04.W", "LOKON04.WRI" );
#endif
#endif
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^MANUAL, 0 );
  }
  else if (Message.WParam&HELP)
  {
#ifdef _full
    char s[20]="LOKON";
#endif
#ifdef _small
    char s[20]="LOKONC";
#endif
#ifdef _mini
    char s[20]="LOKONM";
#endif
    char ss_[20];
    strcpy( ss_, s );
    strcat( s, LoKonVersionName );
    strcat( s, ".TXT" );
    decompress_( s, s );
    decompress_( "FILE_ID.DIZ", "FILE_ID.DIZ" );
    decompress_( "LIESMICH.TXT", "LIESMICH.TXT" );
    decompress_( "README.TXT", "README.TXT" );
    decompress_( "DSINFO.TXT", "DSINFO.TXT" );
    decompress_( "SHAREW.TXT", "SHAREW.TXT" );
    decompress_( "DSAUTOR.TXT", "DSAUTOR.TXT" );
    decompress_( "BMTMICRO.TXT", "BMTMICRO.TXT" );
#ifndef _mini
    if ( language == GER )
    {
      decompress_( "HISTORIE.TXT", "HISTORIE.TXT" );
#ifdef _full
      decompress_( "NEU.TXT", "NEU.TXT" );
#endif
    }
    else
    {
      decompress_( "HISTORY.TXT", "HISTORY.TXT" );
#ifdef _full
      decompress_( "NEW.TXT", "NEW.TXT" );
#endif
    }
#endif
    decompress( "REGISTER.W", "REGISTER.WRI" );
//    decompress_( "SCHULE.WR_", "SCHULE.WRI" ); /**/
//    decompress_( "SLIZENZ.WR_", "SLIZENZ.WRI" ); /**/
    if (language==ENG)
      decompress_( "REGISTER.W_D", "REGDEU.WRI" );
    else
      decompress_( "REGISTER.W_E", "REGENG.WRI" );
    decompress( "LOKON.H", "LOKON.HLP" );
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^HELP, 0 );
  }
  else if (Message.WParam&INI)
  {
    SendMessage( ProgressDlg->HWindow, WM_FILENAME, 0, (DWORD)"LOKON.INI" );
    SendMessage( ProgressDlg->HWindow, WM_INCSUM, 1, (DWORD)306 );
    char s_[256];
    strcat( strcpy( LoKon_INI_File, dest_dir ), "LOKON.INI" );
    // Standard INI-Datei anlegen. (Seit 2.0 nicht mehr)
/*    WritePrivateProfileStr( "GENERAL", "Messages", "off" );
    WritePrivateProfileStr( "GENERAL", "ShowInOut", "off" );
    WritePrivateProfileStr( "GENERAL", "Connections", "thick/thin" );
    WritePrivateProfileStr( "GENERAL", "Collision", "off" );
    WritePrivateProfileStr( "TIMER", "Time", "100" );
    WritePrivateProfileStr( "TIMER", "State", "on" );
    WritePrivateProfileStr( "RASTER", "Type", "2" );
    WritePrivateProfileStr( "RASTER", "Position", "behind" );
    WritePrivateProfileStr( "RASTER", "Positioning", "10" );
    WritePrivateProfileStr( "FONT", "Height", "10" );
    WritePrivateProfileStr( "FONT", "Width", "0" );
    WritePrivateProfileStr( "FONT", "Direction", "0" );
    WritePrivateProfileStr( "FONT", "Number", "2" );
    WritePrivateProfileStr( "FONT", "Flag", "0" );*/

    if ( Norm == GER )
      setAlias( "Elements", "ELE_DIN.ELE" );
    else
      setAlias( "Elements", "ELE_AM.ELE" );
    setAlias( "Registers", "REG_DIN.ELE" );
    setAlias( "Display", "DIS_DIN.ELE" );
#ifdef _full
    setAlias( "Macro", "MACRO.ELE" );
    setAlias( "Elements2", "ELE_DIN2.ELE" );
    setAlias( "TTL", "TTL.ELE" );
#endif
    setAlias( "Analog", "ANALOG.ELE" );

    WritePrivateProfileString( "VERSION", "date", LoKonDate, LoKon_INI_File );
    WritePrivateProfileString( "VERSION", "version", LoKonVersion, LoKon_INI_File );
    WritePrivateProfileString( "VERSION", "intern", NULL, LoKon_INI_File );
    if (strcmp(RegName, "SHAREWARE") != 0)
    {
      WritePrivateProfileString( "REG", "name", RegName, LoKon_INI_File );
      WritePrivateProfileString( "REG", "codel", RegCodeL, LoKon_INI_File );
      WritePrivateProfileString( "REG", "codeh", RegCodeH, LoKon_INI_File );
    }
    SendMessage( ProgressDlg->HWindow, WM_INCSUM, 2, (DWORD)306 );
    PostMessage( HWindow, WM_DECOMPRESS, Message.WParam^INI, 0 );
  }
  else
  {
    char s[256], s_[256];
    SendMessage( ProgressDlg->HWindow, WM_CLOSE, 0, 0 );
    LoadString(
      GetApplicationObject()->hInstance,
      EXTENSIONS|language, s, 255);
    if (MessageBox( HWindow, s, "Setup", MB_YESNO )==IDYES)
    {
      strcat( strcpy( s, dest_dir ), "LOKON.EXE" );
      strcpy( s_, s );
      WriteProfileString( "Extensions", "LAY", strcat( s, " ^.LAY" ) );
      WriteProfileString( "Extensions", "ELE", strcat( s_, " ^.ELE" ) );
    }
    LoadString(
      GetApplicationObject()->hInstance,
      PROGMAN|language, s, 255);
    if (MessageBox( HWindow, s, "Setup", MB_YESNO )==IDYES)
      ProgramManager();
    else
      PostMessage( HWindow, WM_ENDSETUP, 0, 0 );
  }
}

void TSetupWin::setAlias( char* alias, char* file )
{
  char s[200];
  char s2[200];
  char s3[200];
  int found = FALSE;
  int num = GetPrivateProfileInt( "ELEMENT-FILES", "Number", 0, LoKon_INI_File );
  for (int i=1; i<=num; i++) {
    strcpy( s, "Alias" );
    wvsprintf( s2, "%i", &i );
    strcat( s, s2 );
    GetPrivateProfileString( "ELEMENT-FILES", s, "_", s3, 190, LoKon_INI_File );
    if (strcmp(s3, alias)==0)
      found = TRUE;
  }
  if (!found) {
    num++;
    wvsprintf( s, "%i", &num );
    WritePrivateProfileString( "ELEMENT-FILES", "Number", s, LoKon_INI_File );
    strcat( strcpy( s2, dest_dir ), file );
    strcat( strcpy( s3, "File" ), s );
    WritePrivateProfileString( "ELEMENT-FILES", s3, s2, LoKon_INI_File );
    strcat( strcpy( s3, "Alias" ), s );
    WritePrivateProfileString( "ELEMENT-FILES", s3, alias, LoKon_INI_File );
  }
}

// Schlu�
void TSetupWin::WMEndSetup( TMessage& )
{
  char s[1024];
  LoadString(
    GetApplicationObject()->hInstance,
    SHAREWARE2|language, s, 1023);
  MessageBox( HWindow, s, "SHAREWARE", MB_OK );
  LoadString(
    GetApplicationObject()->hInstance,
    SHAREWARE3|language, s, 1023);
  MessageBox( HWindow, s, "SHAREWARE", MB_OK );
  LoadString(
    GetApplicationObject()->hInstance,
    SHAREWARE4|language, s, 1023);
  MessageBox( HWindow, s, "SHAREWARE", MB_OK );
  LoadString(
    GetApplicationObject()->hInstance,
    ENDSETUP|language, s, 1023);
  MessageBox( HWindow, s, "Setup", MB_OK );
  PostMessage( HWindow, WM_CLOSE, 0, 0);
}

// Eine Datei dekomprimieren.
void TSetupWin::decompress_( const char *src_name, const char *dest_name )
{
  SendMessage( ProgressDlg->HWindow, WM_FILENAME, 0, (DWORD)dest_name );
  OFSTRUCT os_src, os_dest;
  int src, dest;
  char s[256];
  strcat(strcpy(s, src_dir), src_name);
  do
  {
    src = LZOpenFile(s, &os_src, OF_READ);
    if (src==-1)
    {
#ifndef _update
      char s_[256];
      LoadString(
        GetApplicationObject()->hInstance,
	FILENOTFOUND|language, s_, 255 );
      if ( MessageBox( HWindow, s_, s, MB_YESNO )!=IDYES )
	src=-2;
#else
      src=-2;
#endif
    }
  }
  while ( src==-1 );
  if ( src==-2 )
    return;
  struct stat st;
  stat( s, &st );
  SendMessage( ProgressDlg->HWindow, WM_INCSUM, 1, (DWORD)st.st_size );
  strcat(strcpy(s, dest_dir), dest_name);
  dest = LZOpenFile(s, &os_dest, OF_CREATE|OF_WRITE);
  CopyLZFile( src, dest );
  LZClose( src );
  LZClose( dest );
  stat( s, &st );
  SendMessage( ProgressDlg->HWindow, WM_INCSUM, 2, (DWORD)st.st_size );
}

void TSetupWin::decompress( const char *src_name, const char *dest_name )
{
  char s[32];
  strncat(strcat(strcpy(s, src_name), "_"), &lang, 1);
  decompress_( s, dest_name );
}

// LoKon-Gruppe in Program-Manager einf�gen
void TSetupWin::ProgramManager(void)
{
  InitiateProgmanDDE();
  char items[1024], *s=items, s_[256];
  LoadString(
    GetApplicationObject()->hInstance,
    LOKONEXE_PROGMAN|language, s_, 255 );
  strcat( strcat( strcpy( s, dest_dir ), "LOKON.EXE," ), s_ );
  s += strlen(s) + 1;
  LoadString(
    GetApplicationObject()->hInstance,
    LOKONHLP_PROGMAN|language, s_, 255 );
  strcat( strcat( strcpy( s, dest_dir ), "LOKON.HLP," ), s_ );
  s += strlen(s) + 1;
  LoadString(
    GetApplicationObject()->hInstance,
    REGISTER_PROGMAN|language, s_, 255 );
  strcat( strcat( strcpy( s, dest_dir ), "REGISTER.WRI," ), s_ );
  s += strlen(s) + 1;
  s[0]=0;
  ProgmanCreateGroup( "LoKon", items );
  PostMessage( HWindow, WM_ENDSETUP, 0, 0 );
};

// Mit Program-Manager kommunizieren.
void TSetupWin::WMDDEAck( TMessage &Msg )
{
  inherited WMDDEAck( Msg );
  if ( PendingMessage == WM_DDE_EXECUTE )
  {
    TerminateDDE();
    PostMessage( HWindow, WM_ENDSETUP, 0, 0 );
  }
}


// TSetupApp
class TSetupApp : public TApplication
{
public:
  // Konstruktor
  TSetupApp(
    LPSTR name, HINSTANCE hInstance,
    HINSTANCE hPrevInstance, LPSTR lpCmd, int nCmdShow)
    : TApplication( name, hInstance, hPrevInstance, lpCmd, nCmdShow ) {};
  // Hauptfenster
  virtual void InitMainWindow( void )
  { MainWindow = new TSetupWin(); };
};


// Hauptprogramm
#pragma argsused
int PASCAL WinMain(
  HINSTANCE hInstance, HINSTANCE hPrevInstance,
  LPSTR lpCmd, int nCmdShow)
{
  TDialogEx::BkBrush = CreateSolidBrush( GetSysColor( COLOR_BTNFACE ) );
  if ( hPrevInstance == 0 )
  {  
    TSetupApp App(
      "LoKonTSetupApp",
      hInstance, hPrevInstance, lpCmd,
      SW_SHOWMAXIMIZED);
    App.Run();
    return ( App.Status );
  }
  else
    MessageBox( 0, "Setup is already running.", NULL, MB_OK );
  return 0;
}