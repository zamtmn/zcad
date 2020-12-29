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
uses gzctnrvectorpdata,gzctnrvector,
     typinfo,uzbtypes,uzbmemman;
type
{Export+}
{------------REGISTEROBJECTTYPE GZVectorPObects}
GZVectorPObects{-}<PTObj,TObj>{//}
                             =object(GZVectorPData{-}<PTObj,TObj>{//})
                             function CreateObject:PTObj;
                end;
TZctnrVectorPGDBaseObjects=object(GZVectorPData{-}<PGDBaseObject,GDBaseObject>{//})
                              end;
PGDBOpenArrayOfPObjects=^TZctnrVectorPGDBaseObjects;
{Export-}
implementation
function GZVectorPObects<PTObj,TObj>.CreateObject;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{6F264155-0BCB-408F-BDA7-F3E8A4540F18}',{$ENDIF}result,sizeof(TObj));
  if PTypeInfo(TypeInfo(TObj))^.kind in TypesNeedToInicialize
          then fillchar(pointer(result)^,sizeof(TObj),0);
  PushBackData(result);
end;
begin
end.
