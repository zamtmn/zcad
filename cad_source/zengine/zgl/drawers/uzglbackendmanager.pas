{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
uses
  SysUtils,
  uzctnrvectorstrings,uzglviewareaabstract,uzctnrVectorPointers,uzbLogIntf;
const test:String='asdasd';
type
    TVA=class of TAbstractViewArea;
var
    Backends:TZctnrVectorPointer;
    BackendsNames:TEnumData;
procedure RegisterBackend(BackEndClass:TVA;Name:string);
function GetCurrentBackEnd:TVA;
function SetCurrentBackEnd(const BackEndName:string):boolean;
implementation
function SetCurrentBackEnd(const BackEndName:string):boolean;
var
  i:integer;
begin
  i:=BackendsNames.Enums.findstring(uppercase(BackEndName),true);
  if i>=0 then
    BackendsNames.Selected:=i
  else
    zDebugln('{E}RendererBackEnd "'+BackEndName+'" not found');
end;
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
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  BackendsNames.Enums.done;
  Backends.done;
end.

