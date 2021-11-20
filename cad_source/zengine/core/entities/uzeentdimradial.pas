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
unit uzeentdimradial;
{$INCLUDE def.inc}

interface
uses uzeentityfactory,uzeentdimdiametric,uzeentdimension,uzestylesdim,
     uzestyleslayers,uzedrawingdef,uzbstrproc,UGDBOpenArrayOfByte,
     uzegeometry,uzbtypesbase,sysutils,uzeentity,uzbtypes,uzeconsts,uzeffdxfsupport,
     uzbgeomtypes,uzbmemman,uzeentsubordinated;
(*

Diametric dimension structure in DXF

    (11,21,31)
X<----X(text)----->X (10,20,30)
(15,25,35)

*)
type
{EXPORT+}
PGDBObjRadialDimension=^GDBObjRadialDimension;
{REGISTEROBJECTTYPE GDBObjRadialDimension}
GDBObjRadialDimension= object(GDBObjDiametricDimension)
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                        function GetObjTypeName:GDBString;virtual;

                        function GetDimStr(var drawing:TDrawingDef):GDBString;virtual;
                        function GetCenterPoint:GDBVertex;virtual;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;

                        function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function GetRadius:GDBDouble;virtual;

                        procedure SaveToDXF(var outhandle:GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                        function GetObjType:TObjID;virtual;
                   end;
{EXPORT-}
implementation
//uses log;
procedure GDBObjRadialDimension.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'DIMENSION','AcDbDimension',IODXFContext);
  dxfvertexout(outhandle,10,DimData.P10InWCS);
  dxfvertexout(outhandle,11,DimData.P11InOCS);
  {if DimData.TextMoved then}
                           dxfGDBIntegerout(outhandle,70,4+128)
                       {else
                           dxfGDBIntegerout(outhandle,70,4);};
  dxfGDBStringout(outhandle,3,PDimStyle^.Name);
  dxfGDBStringout(outhandle,100,'AcDbRadialDimension');
  dxfvertexout(outhandle,15,DimData.P15InWCS)
end;

function GDBObjRadialDimension.GetRadius:GDBDouble;
begin
     result:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
end;
function GDBObjRadialDimension.P10ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv:GDBVertex;
  d:double;
begin
     //center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
     d:=Vertexlength(DimData.P15InWCS,DimData.P11InOCS);
     dirv:=vertexsub(DimData.P15InWCS,tv);
     dirv:=normalizevertex(dirv);

     result:=tv;
     DimData.P11InOCS:=VertexDmorph(DimData.P15InWCS,dirv,d);
end;
function GDBObjRadialDimension.P15ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv:GDBVertex;
  r:double;
begin
     r:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
     dirv:=vertexsub(tv,DimData.P10InWCS);
     dirv:=normalizevertex(dirv);

     result:=VertexDmorph(DimData.P10InWCS,dirv,r);
     r:=Vertexlength(DimData.P10InWCS,DimData.P11InOCS);
     DimData.P11InOCS:=VertexDmorph(DimData.P10InWCS,dirv,r);
end;
function GDBObjRadialDimension.P11ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv:GDBVertex;
  r:double;
begin
     r:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
     dirv:=vertexsub(tv,DimData.P10InWCS);
     dirv:=normalizevertex(dirv);

     DimData.P15InWCS:=VertexDmorph(DimData.P10InWCS,dirv,r);
     result:=tv;
end;

function GDBObjRadialDimension.Clone;
var tvo: PGDBObjRadialDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'GDBObjRadialDimension.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjRadialDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.DimData := DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  result := tvo;
end;
function GDBObjRadialDimension.GetCenterPoint:GDBVertex;
begin
     result:=DimData.P10InWCS;
end;

function GDBObjRadialDimension.GetDimStr(var drawing:TDrawingDef):GDBString;
begin
     result:='R'+GetLinearDimStr(Vertexlength(DimData.P10InWCS,DimData.P15InWCS),drawing);
end;
constructor GDBObjRadialDimension.initnul;
begin
  inherited initnul(owner);
  //vp.ID := GDBRadialDimensionID;
end;
constructor GDBObjRadialDimension.init;
begin
  inherited init(own,layeraddres, lw);
  PProjPoint:=nil;
  //vp.ID := GDBRadialDimensionID;
end;
function GDBObjRadialDimension.GetObjType;
begin
     result:=GDBRadialDimensionID;
end;
function GDBObjRadialDimension.GetObjTypeName;
begin
     result:=ObjN_ObjRadialDimension;
end;
function AllocRadialDimension:PGDBObjRadialDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocRadialDimension}',{$ENDIF}result,sizeof(GDBObjRadialDimension));
end;
function AllocAndInitRadialDimension(owner:PGDBObjGenericWithSubordinated):PGDBObjRadialDimension;
begin
  result:=AllocRadialDimension;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
begin
  RegisterEntity(GDBRadialDimensionID,'RadialDimension',@AllocRadialDimension,@AllocAndInitRadialDimension);
end.
