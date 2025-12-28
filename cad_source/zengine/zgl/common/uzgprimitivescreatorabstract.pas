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

unit uzgprimitivescreatorabstract;
{$INCLUDE zengineconfig.inc}
interface
uses uzgprimitivessarray,uzgindexsarray,sysutils,uzbtypes,uzeTypes,
     gzctnrVectorTypes,uzegeometry;
type
TLLPrimitivesCreatorAbstract=class
                function CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;virtual;abstract;
                function CreateLLTriangle(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex):TArrayIndex;virtual;abstract;
                function CreateLLFreeTriangle(var pa:TLLPrimitivesArray;const P1Index,P2Index,P3Index:TLLVertexIndex; var ia:ZGLIndexsArray):TArrayIndex;virtual;abstract;
                function CreateLLTriangleStrip(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLTriangleFan(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLPoint(var pa:TLLPrimitivesArray;const PIndex:TLLVertexIndex):TArrayIndex;virtual;abstract;
                function CreateLLSymbol(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLSymbolLine(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLSymbolEnd(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLProxyLine(var pa:TLLPrimitivesArray):TArrayIndex;virtual;abstract;
                function CreateLLPolyLine(var pa:TLLPrimitivesArray;const P1Index,_Count:TLLVertexIndex;_closed:Boolean=false):TArrayIndex;virtual;abstract;
             end;
implementation
//uses log;
begin
end.

