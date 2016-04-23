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

unit ugdbopenarrayofpidentobects;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfPObjects,
     uzbtypesbase,uzbtypes,uzbmemman;
type
{Export+}
GDBObjOpenArrayOfPIdentObects{-}<PGDBaseObject,GDBaseObject>{//}
                             ={$IFNDEF DELPHI}packed{$ENDIF} object(TZctnrVectorPObj{-}<PGDBaseObject,GDBaseObject>{//})
                             constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                             function CreateObject:PGDBaseObject;
                end;
{Export-}
implementation
constructor GDBObjOpenArrayOfPIdentObects<PGDBaseObject,GDBaseObject>.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
end;
function GDBObjOpenArrayOfPIdentObects<PGDBaseObject,GDBaseObject>.CreateObject;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{6F264155-0BCB-408F-BDA7-F3E8A4540F18}',{$ENDIF}result,sizeof(GDBaseObject));
  PushBackData(result);
end;
begin
end.
