// ObjectWindows - (C) Copyright 1992 by Borland International

#ifndef __DDECLIEN_H
#define __DDECLIEN_H

// OWL headers
#include <owl.h>

// Windows header
#include <dde.h>

/*
	TDDEClient is an interface object for a DDE client.
	This was made a dialog window for the 'ProgTalk' demo because
	that is	a convenient type for a window with several controls.
*/

class TDDEClient : public TWindow
{
	protected:
		HWND ServerWindow;
		WORD PendingMessage;

	public:

		/*
			DDE window constructor.
			Clear the DDE server window handle and the
			pending DDE message ID.
		*/
		TDDEClient( PTWindowsObject Parent, LPSTR AName )
			: TWindow( Parent, AName ),
			ServerWindow( 0 ),
			PendingMessage( 0 )
		{}

		/*
			Return window class name. This name corresponds
			to the class name specified for the DDE dialog
			in the resource file.
		*/
		void InitiateProgmanDDE( void );
		void TerminateDDE( void );
                BOOL ProgmanCreateGroup( char *group, char *items );

		virtual void WMDDEAck( TMessage& Msg )
			= [ WM_FIRST + WM_DDE_ACK ];
		virtual void WMDDETerminate( TMessage& Msg )
			= [ WM_FIRST + WM_DDE_TERMINATE ];
};

#endif
