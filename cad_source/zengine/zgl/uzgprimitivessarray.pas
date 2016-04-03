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

unit uzgprimitivessarray;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,UGDBOpenArrayOfData,sysutils,uzbtypes,uzbmemman,
     uzegeometry;
const
     LLAttrNothing=0;
     LLAttrNeedSolid=1;
     LLAttrNeedSimtlify=2;

     {LLLineId=1;
     LLPointId=2;
     LLSymbolId=3;
     LLSymbolEndId=4;
     LLPolyLineId=5;
     LLTriangleId=6;}
type
{Export+}
TLLPrimitivesArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData{-}<GDBByte>{//})(*OpenArrayOfData=GDBByte*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
{Export-}
implementation
//uses log;
constructor TLLPrimitivesArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(GDBByte)});
end;
constructor TLLPrimitivesArray.initnul;
begin
  inherited initnul;
  //size:=sizeof(GDBByte);
end;
begin
end.

