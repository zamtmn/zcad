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
unit uzeentdimradial;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzeentdimdiametric,uzeentdimension,uzestylesdim,
  uzestyleslayers,uzedrawingdef,uzbstrproc,uzctnrVectorBytesStream,
  uzegeometry,SysUtils,uzeentity,uzeTypes,uzeconsts,uzeffdxfsupport,
  uzegeometrytypes,uzeentsubordinated;
(*

Diametric dimension structure in DXF

    (11,21,31)
X<----X(text)----->X (10,20,30)
(15,25,35)

*)
type
  PGDBObjRadialDimension=^GDBObjRadialDimension;

  GDBObjRadialDimension=object(GDBObjDiametricDimension)
    function GetObjTypeName:string;virtual;
    function GetDimStr(
      var drawing:TDrawingDef):TDXFEntsInternalStringType;virtual;
    function GetCenterPoint:TzePoint3d;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function P10ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P15ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P11ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function GetRadius:double;virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    function GetObjType:TObjID;virtual;
  end;

implementation

procedure GDBObjRadialDimension.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'DIMENSION','AcDbDimension',IODXFContext);
  dxfvertexout(outStream,10,DimData.P10InWCS);
  dxfvertexout(outStream,11,DimData.P11InOCS);
  dxfIntegerout(outStream,70,4+128);
  dxfStringout(outStream,3,PDimStyle^.Name);
  dxfStringout(outStream,100,'AcDbRadialDimension');
  dxfvertexout(outStream,15,DimData.P15InWCS);
end;

function GDBObjRadialDimension.GetRadius:double;
begin
  Result:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
end;

function GDBObjRadialDimension.P10ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv:TzePoint3d;
  d:double;
begin
  d:=Vertexlength(DimData.P15InWCS,DimData.P11InOCS);
  dirv:=vertexsub(DimData.P15InWCS,tv);
  dirv:=normalizevertex(dirv);

  Result:=tv;
  DimData.P11InOCS:=VertexDmorph(DimData.P15InWCS,dirv,d);
end;

function GDBObjRadialDimension.P15ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv:TzePoint3d;
  r:double;
begin
  r:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
  dirv:=vertexsub(tv,DimData.P10InWCS);
  dirv:=normalizevertex(dirv);

  Result:=VertexDmorph(DimData.P10InWCS,dirv,r);
  r:=Vertexlength(DimData.P10InWCS,DimData.P11InOCS);
  DimData.P11InOCS:=VertexDmorph(DimData.P10InWCS,dirv,r);
end;

function GDBObjRadialDimension.P11ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv:TzePoint3d;
  r:double;
begin
  r:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);
  dirv:=vertexsub(tv,DimData.P10InWCS);
  dirv:=normalizevertex(dirv);

  DimData.P15InWCS:=VertexDmorph(DimData.P10InWCS,dirv,r);
  Result:=tv;
end;

function GDBObjRadialDimension.Clone;
var
  tvo:PGDBObjRadialDimension;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjRadialDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.DimData:=DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  Result:=tvo;
end;

function GDBObjRadialDimension.GetCenterPoint:TzePoint3d;
begin
  Result:=DimData.P10InWCS;
end;

function GDBObjRadialDimension.GetDimStr(
  var drawing:TDrawingDef):TDXFEntsInternalStringType;
begin
  Result:='R'+GetLinearDimStr(
    Vertexlength(DimData.P10InWCS,DimData.P15InWCS),drawing);
end;

function GDBObjRadialDimension.GetObjType;
begin
  Result:=GDBRadialDimensionID;
end;

function GDBObjRadialDimension.GetObjTypeName;
begin
  Result:=ObjN_ObjRadialDimension;
end;

function AllocRadialDimension:PGDBObjRadialDimension;
begin
  Getmem(Result,sizeof(GDBObjRadialDimension));
end;

function AllocAndInitRadialDimension(owner:PGDBObjGenericWithSubordinated):
PGDBObjRadialDimension;
begin
  Result:=AllocRadialDimension;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

begin
  RegisterEntity(GDBRadialDimensionID,'RadialDimension',@AllocRadialDimension,@AllocAndInitRadialDimension);
end.
