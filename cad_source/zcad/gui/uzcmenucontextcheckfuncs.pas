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

unit uzcmenucontextcheckfuncs;
{$INCLUDE def.inc}
interface
uses
  LCLIntf,LCLType;
function GMCCFTrue(const Context:TObject):boolean;
function GMCCFFalse(const Context:TObject):boolean;
function GMCCFDebugMode(const Context:TObject):boolean;

function GMCCFCtrlPressed(const Context:TObject):boolean;
function GMCCFShiftPressed(const Context:TObject):boolean;
function GMCCFAltPressed(const Context:TObject):boolean;
implementation
function GMCCFTrue(const Context:TObject):boolean;
begin
  result:=true;
end;
function GMCCFFalse(const Context:TObject):boolean;
begin
  result:=true;
end;
function GMCCFDebugMode(const Context:TObject):boolean;
begin
  {$IFDEF DEBUGBUILD}result:=true;{$ELSE}result:=false;{$ENDIF}
end;
function GMCCFCtrlPressed(const Context:TObject):boolean;
begin
  result:=(GetKeyState(VK_CONTROL) and $8000 <> 0);
end;
function GMCCFShiftPressed(const Context:TObject):boolean;
begin
  result:=(GetKeyState(VK_SHIFT) and $8000 <> 0);
end;
function GMCCFAltPressed(const Context:TObject):boolean;
begin
  result:=(GetKeyState(VK_MENU) and $8000 <> 0);
end;

begin
end.
