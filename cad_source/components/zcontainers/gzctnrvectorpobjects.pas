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

unit gzctnrvectorpobjects;
{$INCLUDE def.inc}
interface
uses gzctnrvectorpdata,
     {uzbtypesbase,}uzbtypes,uzbmemman;
type
{Export+}
GZVectorPObects{-}<PTObj,TObj>{//}
                             ={$IFNDEF DELPHI}packed{$ENDIF} object(GZVectorPData{-}<PTObj,TObj>{//})
                             function CreateObject:PTObj;
                end;
TZctnrVectorPGDBaseObjects=packed object(GZVectorPData{-}<PGDBaseObject,GDBaseObject>{//})
                              end;
PGDBOpenArrayOfPObjects=^TZctnrVectorPGDBaseObjects;
{Export-}
implementation
function GZVectorPObects<PTObj,TObj>.CreateObject;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{6F264155-0BCB-408F-BDA7-F3E8A4540F18}',{$ENDIF}result,sizeof(TObj));
  PushBackData(result);
end;
begin
end.
