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

unit uzglbackendmanager;
{$INCLUDE zengineconfig.inc}

interface
uses uzctnrvectorstrings,uzglviewareaabstract,uzctnrVectorPointers,LazLogger;
const test:String='asdasd';
type
    TVA=class of TAbstractViewArea;
var
    Backends:TZctnrVectorPointer;
    BackendsNames:TEnumData;
procedure RegisterBackend(BackEndClass:TVA;Name:string);
function GetCurrentBackEnd:TVA;
implementation
procedure RegisterBackend(BackEndClass:TVA;Name:string);
begin
     //sysvar.RD.RD_RendererBackEnd.Enums.add(@name);
     BackendsNames.Enums.PushBackData(name);
     Backends.PushBackData(BackEndClass);
end;
function GetCurrentBackEnd:TVA;
begin
     result:=ppointer(Backends.getDataMutable(BackendsNames.Selected))^;
end;
initialization
  BackendsNames.Enums.init(10);
  BackendsNames.Selected:=0;
  Backends.init(10);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  BackendsNames.Enums.done;
  Backends.done;
end.

