#include <string.h>
#include "ddeclien.h"

/*
	Initiate a DDE conversation. Bring up a
	message box if the server does not respond to the
	WM_DDE_INITIATE message.
*/

void TDDEClient::InitiateProgmanDDE( void )
{
	ATOM Atom;

	PendingMessage = WM_DDE_INITIATE;
	Atom = GlobalAddAtom( "PROGMAN" );
	SendMessage( HWND( 0xFFFF ), WM_DDE_INITIATE, (WPARAM)HWindow,
		MAKELONG( Atom, Atom ) );
	GlobalDeleteAtom( Atom );
	PendingMessage = 0;
	if ( ServerWindow == 0 )
		MessageBox( HWindow,
			"Cannot establish DDE link to DDE Server.",
			"Error",
			MB_ICONEXCLAMATION | MB_OK );
}

/*
	Terminate the DDE conversation. Send the WM_DDE_TERMINATE message
	only if the server window still exists.
*/

void TDDEClient::TerminateDDE( void )
{
	HWND W = ServerWindow;
	ServerWindow = 0;
	if ( IsWindow( W ) )
		PostMessage( W, WM_DDE_TERMINATE, (WPARAM)HWindow, 0 );
}

BOOL TDDEClient::ProgmanCreateGroup( char *group, char *items )
{
	LPSTR lpCreateGroup = "[CreateGroup(%s)]";
	LPSTR lpAddItem = "[AddItem(%s)]";

	BOOL Executed;
	int len;
	HANDLE HCommands;
	LPSTR lpCommands;

	Executed = False;
        if ( ( ServerWindow != 0 ) && ( PendingMessage == 0 ) )
	{
		// Subtract 2 for the '%s' in 'lpCreateGroup'
		// plus 1 for null terminator.
  		len = strlen( group ) + _fstrlen( lpCreateGroup ) - 2 + 1;
                LPSTR s;
                for ( s = items; s[0] != 0; s += _fstrlen(s)+1 )
                    len += _fstrlen( s ) + _fstrlen( lpAddItem ) - 2;
		HCommands = (HANDLE)GlobalAlloc( GHND | GMEM_DDESHARE, len );
		if ( HCommands != 0 )
		{
		        lpCommands = (LPSTR)GlobalLock( HCommands );
			wsprintf( lpCommands, lpCreateGroup, (LPSTR)group );
			lpCommands += _fstrlen( lpCommands );
                        for ( s = items; s[0] != 0;
                              s += _fstrlen( s )+1,
                              lpCommands+=_fstrlen(lpCommands) )
			    wsprintf( lpCommands, lpAddItem, s );
			GlobalUnlock( HCommands );
			if ( PostMessage( ServerWindow,
				WM_DDE_EXECUTE,
				(WPARAM)HWindow,
				MAKELONG( 0, HCommands ) ) )
			{
				PendingMessage = WM_DDE_EXECUTE;
				Executed = True;
			}
			else
				GlobalFree( HCommands );
		}
	}
        return Executed;
}

/*
	WM_DDE_ACK message response method. If the current DDE message
	is a WM_DDE_INITIATE, store off the window handle of the window
	that responded. If more than one window responds, terminate all
	conversations but the first. If the current DDE message is a
	WM_DDE_EXECUTE, free the command string memory block, and focus our
	window.
*/

void TDDEClient::WMDDEAck( TMessage& Msg )
{
	switch( PendingMessage )
	{
		case WM_DDE_INITIATE:

			if ( ServerWindow == 0 )
				ServerWindow = (HWND)Msg.WParam;
			else
				PostMessage( (HWND)Msg.WParam,
					WM_DDE_TERMINATE,
					(WPARAM)HWindow,
					0L );
			GlobalDeleteAtom( Msg.LP.Lo );
			GlobalDeleteAtom( Msg.LP.Hi );
			break;

		case WM_DDE_EXECUTE:

			GlobalFree( (HGLOBAL)Msg.LP.Hi );
			PendingMessage = 0;
			SetFocus( HWindow );
			break;
	}
}

/*
	WM_DDE_TERMINATE message response method. If the window signaling
	termination is our server window, terminate
	the DDE conversation. Otherwise ignore the WM_DDE_TERMINATE.
*/

void TDDEClient::WMDDETerminate( TMessage& Msg )
{
	if ( (HWND)Msg.WParam == ServerWindow )
		TerminateDDE();
}

/*
	WM_CLOSE message response method. Terminate the DDE link and
	call the inherited WMClose.
*/
