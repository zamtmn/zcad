{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit UOpenGLControl;
{$INCLUDE def.inc}
interface
uses
  StdCtrls,ExtCtrls,Controls,Classes,menus,Forms,
  log;
type
  TOpenGLControl = class(TPanel)
    procedure SwapBuffers; virtual;abstract;
    function MakeCurrent(SaveOldToStack: boolean = false): boolean; virtual;abstract;
  end;
implementation
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UOpenGLControl.initialization');{$ENDIF}
end.
