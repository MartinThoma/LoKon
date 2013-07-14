//
// Update-Programm fÅr LoKon
//

#define WIN31
#include <owl.h>
#include <string.h>
#include <dir.h>
#include <stdio.h>

char LoKon_INI_File[256];

void WritePrivateProfileStr( LPSTR lpAppName, LPSTR lpKeyName, LPSTR lpString )
{
  WritePrivateProfileString( lpAppName, lpKeyName, lpString, LoKon_INI_File );
}

// Hauptprogramm
#pragma argsused
int PASCAL WinMain(
  HINSTANCE hInstance, HINSTANCE hPrevInstance,
  LPSTR lpCmd, int nCmdShow)
{          
  {
    char s_[256];
    char dest_dir[256];
    char s2[8], s3[80];
    getcwd( dest_dir, 256 );
    strcat( dest_dir, "\\" );
//    strcpy ( dest_dir, "c:\\lokon\\" );
    strcat( strcpy( LoKon_INI_File, dest_dir), "LOKON.INI" );
    int NumEleFiles = GetPrivateProfileInt( "ELEMENT-FILES", "Number", 0, LoKon_INI_File );
    // Elements2
    NumEleFiles++;
    wvsprintf( s2, "%i", &NumEleFiles );
    WritePrivateProfileStr( "ELEMENT-FILES", "Number", s2 );
    strcat( strcpy( s_, dest_dir ), "ELE_DIN2.ELE" );
    strcat( strcpy( s3, "File" ), s2 );
    WritePrivateProfileStr( "ELEMENT-FILES", s3, s_ );
    strcat( strcpy( s3, "Alias" ), s2 );
    WritePrivateProfileStr( "ELEMENT-FILES", s3, "Elements2" );
    // TTL
    NumEleFiles++;
    wvsprintf( s2, "%i", &NumEleFiles );
    WritePrivateProfileStr( "ELEMENT-FILES", "Number", s2 );
    strcat( strcpy( s_, dest_dir ), "TTL.ELE" );
    strcat( strcpy( s3, "File" ), s2 );
    WritePrivateProfileStr( "ELEMENT-FILES", s3, s_ );
    strcat( strcpy( s3, "Alias" ), s2 );
    WritePrivateProfileStr( "ELEMENT-FILES", s3, "TTL" );
    WritePrivateProfileString( "VERSION", "date", "12.03.1997", LoKon_INI_File );
    WritePrivateProfileString( "VERSION", "version", "2.1u", LoKon_INI_File );
  }
  return 0;
}