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

unit uzctnrvectorpobjects;
{$INCLUDE def.inc}
interface
uses uzctnrvectorpdata,
     uzbtypesbase,uzbtypes,uzbmemman;
type
{Export+}
TZctnrVectorPObects{-}<PObj,Obj>{//}
                             ={$IFNDEF DELPHI}packed{$ENDIF} object(TZctnrVectorPData{-}<PObj,Obj>{//})
                             function CreateObject:PObj;
                end;
{Export-}
implementation
function TZctnrVectorPObects<PObj,Obj>.CreateObject;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{6F264155-0BCB-408F-BDA7-F3E8A4540F18}',{$ENDIF}result,sizeof(Obj));
  PushBackData(result);
end;
begin
end.
