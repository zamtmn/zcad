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

unit uzgprimitivescreatorabstract;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfData,uzgindexsarray,gdbasetypes,sysutils,gdbase,memman,
geometry;
type
TLLPrimitivesCreatorAbstract=class
                function CreateLLLine(var pa:GDBOpenArrayOfData;const P1Index:TLLVertexIndex):TArrayIndex;virtual;abstract;
                function CreateLLTriangle(var pa:GDBOpenArrayOfData;const P1Index:TLLVertexIndex):TArrayIndex;virtual;abstract;
                function CreateLLFreeTriangle(var pa:GDBOpenArrayOfData;const P1Index,P2Index,P3Index:TLLVertexIndex; var ia:ZGLIndexsArray):TArrayIndex;virtual;abstract;
                function CreateLLTriangleStrip(var pa:GDBOpenArrayOfData):TArrayIndex;virtual;abstract;
                function CreateLLTriangleFan(var pa:GDBOpenArrayOfData):TArrayIndex;virtual;abstract;
                function CreateLLPoint(var pa:GDBOpenArrayOfData;const PIndex:TLLVertexIndex):TArrayIndex;virtual;abstract;
                function CreateLLSymbol(var pa:GDBOpenArrayOfData):TArrayIndex;virtual;abstract;
                function CreateLLSymbolLine(var pa:GDBOpenArrayOfData):TArrayIndex;virtual;abstract;
                function CreateLLSymbolEnd(var pa:GDBOpenArrayOfData):TArrayIndex;virtual;abstract;
                function CreateLLPolyLine(var pa:GDBOpenArrayOfData;const P1Index,_Count:TLLVertexIndex;_closed:GDBBoolean=false):TArrayIndex;virtual;abstract;
             end;
implementation
//uses log;
begin
end.

