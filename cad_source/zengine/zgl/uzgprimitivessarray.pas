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
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
const
     LLLineId=1;
     LLPointId=2;
type
{Export+}
TLLPrimitiveType=GDBInteger;
TLLVertexIndex=GDBInteger;
PTLLPrimitivePrefix=^TLLPrimitivePrefix;
TLLPrimitivePrefix={$IFNDEF DELPHI}packed{$ENDIF} record
                       LLPType:TLLPrimitiveType;
                   end;
PTLLLine=^TLLLine;
TLLLine={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
        end;
PTLLPoint=^TLLPoint;
TLLPoint={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              PIndex:TLLVertexIndex;
        end;
TLLPrimitivesArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBByte*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure AddLLPLine(const P1Index:TLLVertexIndex);
                procedure AddLLPPoint(const PIndex:TLLVertexIndex);
             end;
{Export-}
implementation
uses log;
procedure TLLPrimitivesArray.AddLLPLine(const P1Index:TLLVertexIndex);
var
   tl:TLLLine;
begin
     tl.Prefix.LLPType:=LLLineId;
     tl.P1Index:=P1Index;
     AddData(@tl,sizeof(tl));
end;
procedure TLLPrimitivesArray.AddLLPPoint(const PIndex:TLLVertexIndex);
var
   tp:TLLPoint;
begin
     tp.Prefix.LLPType:=LLPointId;
     tp.PIndex:=PIndex;
     AddData(@tp,sizeof(tp));
end;
constructor TLLPrimitivesArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBByte));
end;
constructor TLLPrimitivesArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBByte);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgvertex3sarray.initialization');{$ENDIF}
end.

