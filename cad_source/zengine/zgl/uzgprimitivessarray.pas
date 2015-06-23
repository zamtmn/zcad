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
uses uzgprimitives,uzglgeomdata,gdbdrawcontext,uzgvertex3sarray,uzglabstractdrawer,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
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
TLLPrimitivesArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBByte*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure AddLLPLine(const P1Index:TLLVertexIndex);
                procedure AddLLTriangle(const P1Index:TLLVertexIndex);
                procedure AddLLPPoint(const PIndex:TLLVertexIndex);
                function AddLLPSymbol:TArrayIndex;
                function AddLLPSymbolLine:TArrayIndex;
                procedure AddLLPSymbolEnd;
                procedure AddLLPPolyLine(const P1Index,Count:TLLVertexIndex);
             end;
{Export-}
implementation
uses log;
procedure TLLPrimitivesArray.AddLLTriangle(const P1Index:TLLVertexIndex);
var
  ptt:PTLLTriangle;
begin
  ptt:=AllocData(sizeof(TLLTriangle));
  ptt.init;
  ptt.P1Index:=P1Index;
end;
procedure TLLPrimitivesArray.AddLLPLine(const P1Index:TLLVertexIndex);
var
   ptl:PTLLLine;
begin
     ptl:=AllocData(sizeof(TLLLine));
     ptl.init;
     ptl.P1Index:=P1Index;
end;
procedure TLLPrimitivesArray.AddLLPPolyLine(const P1Index,Count:TLLVertexIndex);
var
   ptpl:PTLLPolyLine;
begin
     ptpl:=AllocData(sizeof(TLLPolyLine));
     ptpl.init;
     ptpl.P1Index:=P1Index;
     ptpl.Count:=Count;
end;
procedure TLLPrimitivesArray.AddLLPPoint(const PIndex:TLLVertexIndex);
var
   ptp:PTLLPoint;
begin
     ptp:=AllocData(sizeof(TLLPoint));
     ptp.init;
     ptp.PIndex:=PIndex;
end;
function TLLPrimitivesArray.AddLLPSymbolLine:TArrayIndex;
var
   ptsl:PTLLSymbolLine;
begin
     result:=count;
     ptsl:=AllocData(sizeof(TLLSymbolLine));
     ptsl.init;
end;
function TLLPrimitivesArray.AddLLPSymbol:TArrayIndex;
var
   pts:PTLLSymbol;
begin
     result:=count;
     pts:=AllocData(sizeof(TLLSymbol));
     pts.init;
end;
procedure TLLPrimitivesArray.AddLLPSymbolEnd;
var
   ptse:PTLLSymbolEnd;
begin
     ptse:=AllocData(sizeof(TLLSymbolEnd));
     ptse.init;
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
  {$IFDEF DEBUGINITSECTION}LogOut('uzgprimitivessarray.initialization');{$ENDIF}
end.

