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

unit uzgprimitivescreator;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgprimitivescreatorabstract,uzgindexsarray,uzgprimitives,
  sysutils,uzeTypes,uzgprimitivessarray,
  uzegeometry,uzbLogIntf,gzctnrVectorTypes;
type

TLLPrimitivesCreator=class(TLLPrimitivesCreatorAbstract)
                function CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;override;
                function CreateLLTriangle(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex):TArrayIndex;override;
                function CreateLLFreeTriangle(var pa:TLLPrimitivesArray;const P1Index,P2Index,P3Index:TLLVertexIndex; var ia:ZGLIndexsArray):TArrayIndex;override;
                function CreateLLTriangleStrip(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLTriangleFan(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLPoint(var pa:TLLPrimitivesArray;const PIndex:TLLVertexIndex):TArrayIndex;override;
                function CreateLLSymbol(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLSymbolLine(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLSymbolEnd(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLProxyLine(var pa:TLLPrimitivesArray):TArrayIndex;override;
                function CreateLLPolyLine(var pa:TLLPrimitivesArray;const P1Index,_Count:TLLVertexIndex;_closed:Boolean=false):TArrayIndex;override;
             end;
var
   DefaultLLPCreator:TLLPrimitivesCreator;
implementation
//uses log;
function TLLPrimitivesCreator.CreateLLTriangle(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex):TArrayIndex;
var
  ptt:PTLLTriangle;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(ptt):=pa.getDataMutable(pa.AllocData(sizeof(TLLTriangle)));
  ptt.init;
  ptt.P1Index:=P1Index;
end;
function TLLPrimitivesCreator.CreateLLFreeTriangle(var pa:TLLPrimitivesArray;const P1Index,P2Index,P3Index:TLLVertexIndex; var ia:ZGLIndexsArray):TArrayIndex;
var
  ptt:PTLLFreeTriangle;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(ptt):=pa.getDataMutable(pa.AllocData(sizeof(TLLFreeTriangle)));
  ptt.init;
  ptt.P1IndexInIndexesArray:=ia.PushBackData(P1Index);
  ia.PushBackData(P2Index);
  ia.PushBackData(P3Index);
  {ptt.P1Index:=P1Index;
  ptt.P2Index:=P2Index;
  ptt.P3Index:=P3Index;}
end;
function TLLPrimitivesCreator.CreateLLTriangleStrip(var pa:TLLPrimitivesArray):TArrayIndex;
var
  pts:PTLLTriangleStrip;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(pts):=pa.getDataMutable(pa.AllocData(sizeof(TLLTriangleStrip)));
  pts.init;
end;

function TLLPrimitivesCreator.CreateLLTriangleFan(var pa:TLLPrimitivesArray):TArrayIndex;
var
  ptf:PTLLTriangleFan;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(ptf):=pa.getDataMutable(pa.AllocData(sizeof(TLLTriangleFan)));
  ptf.init;
end;

function TLLPrimitivesCreator.CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;
var
   ptl:PTLLLine;
begin
  pa.AlignDataSize;
  result:=pa.count;
  if OnlyOne then
    pa.SetSize(result+sizeof(TLLLine));
  pointer(ptl):=pa.getDataMutable(pa.AllocData(sizeof(TLLLine)));
  ptl.init;
  ptl.P1Index:=P1Index;
end;
function TLLPrimitivesCreator.CreateLLPolyLine(var pa:TLLPrimitivesArray;const P1Index,_Count:TLLVertexIndex;_closed:Boolean=false):tarrayindex;
var
   ptpl:PTLLPolyLine;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(ptpl):=pa.getDataMutable(pa.AllocData(sizeof(TLLPolyLine)));
  ptpl.init;
  ptpl.P1Index:=P1Index;
  ptpl.Count:=_Count;
  ptpl.SimplifiedContourIndex:=-1;
  ptpl.SimplifiedContourSize:=-1;
  ptpl.Closed:=_closed;
end;
function TLLPrimitivesCreator.CreateLLPoint(var pa:TLLPrimitivesArray;const PIndex:TLLVertexIndex):TArrayIndex;
var
   ptp:PTLLPoint;
begin
  pa.AlignDataSize;
     result:=pa.count;
     pointer(ptp):=pa.getDataMutable(pa.AllocData(sizeof(TLLPoint)));
     ptp.init;
     ptp.PIndex:=PIndex;
end;
function TLLPrimitivesCreator.CreateLLSymbolLine(var pa:TLLPrimitivesArray):TArrayIndex;
var
   ptsl:PTLLSymbolLine;
begin
  pa.AlignDataSize;
     result:=pa.count;
     pointer(ptsl):=pa.getDataMutable(pa.AllocData(sizeof(TLLSymbolLine)));
     ptsl.init;
end;
function TLLPrimitivesCreator.CreateLLProxyLine(var pa:TLLPrimitivesArray):TArrayIndex;
var
  ptpl:PTLLProxyLine;
begin
  pa.AlignDataSize;
  result:=pa.count;
  pointer(ptpl):=pa.getDataMutable(pa.AllocData(sizeof(TLLProxyLine)));
  ptpl.init;
end;
function TLLPrimitivesCreator.CreateLLSymbol(var pa:TLLPrimitivesArray):TArrayIndex;
var
   pts:PTLLSymbol;
begin
  pa.AlignDataSize;
     result:=pa.count;
     pointer(pts):=pa.getDataMutable(pa.AllocData(sizeof(TLLSymbol)));
     pts.init;
end;
function TLLPrimitivesCreator.CreateLLSymbolEnd(var pa:TLLPrimitivesArray):TArrayIndex;
var
   ptse:PTLLSymbolEnd;
begin
  pa.AlignDataSize;
     result:=pa.count;
     pointer(ptse):=pa.getDataMutable(pa.AllocData(sizeof(TLLSymbolEnd)));
     ptse.init;
end;
initialization
  DefaultLLPCreator:=TLLPrimitivesCreator.create;
finalization
  zDebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  DefaultLLPCreator.Destroy;
end.

