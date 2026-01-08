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
unit uzeentdimensiongeneric;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzeentwithlocalcs,uzeentdimension,uzestylesdim,
  uzestyleslayers,uzedrawingdef,uzctnrVectorBytesStream,uzegeometry,
  SysUtils,uzeentity,uzeTypes,uzeconsts,uzeffdxfsupport,uzeentsubordinated,
  uzeentdimradial,uzeentdimdiametric,uzeentdimrotated,uzeentdimaligned,
  uzMVReader;

type
  TDimType=(DTRotated,DTAligned,DTAngular,DTDiameter,DTRadius,DTAngular3P,DTOrdinate);
  PGDBObjGenericDimension=^GDBObjGenericDimension;

  GDBObjGenericDimension=object(GDBObjWithLocalCS)
    DimData:TDXFDimData;
    PDimStyle:PGDBDimStyle;
    DimType:TDimType;
    a50,a52:double;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
      const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
    function GetObjType:TObjID;virtual;
  end;

implementation

var
  WorkingFormatSettings:TFormatSettings;

function GDBObjGenericDimension.FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
  const drawing:TDrawingDef):PGDBObjSubordinated;
var
  ResultDim:PGDBObjDimension;
begin
  case DimType of
    DTRotated:begin
      Getmem(
        Pointer(ResultDim),sizeof(GDBObjRotatedDimension));
      Result:=ResultDim;
      PGDBObjRotatedDimension(
        ResultDim)^.initnul(bp.ListPos.Owner);
      PGDBObjRotatedDimension(
        ResultDim)^.vectorD:=CreateRotatedXVector(a50*pi/180);
      PGDBObjRotatedDimension(
        ResultDim)^.vectorN:=CreateRotatedYVector(a50*pi/180);
      CopyVPto(ResultDim^);
      ResultDim^.Local:=local;
      ResultDim^.P_insert_in_WCS:=
        P_insert_in_WCS;
      PGDBObjRotatedDimension(
        ResultDim)^.DimData:=DimData;
      PGDBObjRotatedDimension(
        ResultDim)^.PDimStyle:=PDimStyle;
    end;
    DTAligned:
    begin
      Getmem(Pointer(ResultDim),sizeof(
        GDBObjAlignedDimension));
      Result:=ResultDim;
      PGDBObjAlignedDimension(
        ResultDim)^.initnul(bp.ListPos.Owner);
      CopyVPto(ResultDim^);
      ResultDim^.Local:=local;
      ResultDim^.P_insert_in_WCS:=P_insert_in_WCS;
      PGDBObjAlignedDimension(ResultDim)^.DimData:=
        DimData;
      PGDBObjAlignedDimension(ResultDim)^.PDimStyle:=
        PDimStyle;
    end;
    DTDiameter:
    begin
      Getmem(Pointer(ResultDim),sizeof(
        GDBObjDiametricDimension));
      Result:=ResultDim;
      PGDBObjDiametricDimension(
        ResultDim)^.initnul(bp.ListPos.Owner);
      CopyVPto(ResultDim^);
      ResultDim^.Local:=local;
      ResultDim^.P_insert_in_WCS:=P_insert_in_WCS;
      PGDBObjAlignedDimension(ResultDim)^.DimData:=DimData;
      PGDBObjAlignedDimension(ResultDim)^.PDimStyle:=
        PDimStyle;
    end;
    else
    begin
      Getmem(Pointer(ResultDim),sizeof(
        GDBObjRadialDimension));
      Result:=ResultDim;
      PGDBObjRadialDimension(
        ResultDim)^.initnul(bp.ListPos.Owner);
      CopyVPto(ResultDim^);
      ResultDim^.Local:=local;
      ResultDim^.P_insert_in_WCS:=P_insert_in_WCS;
      PGDBObjRadialDimension(ResultDim)^.DimData:=DimData;
      PGDBObjRadialDimension(ResultDim)^.PDimStyle:=
        PDimStyle;
      PGDBObjRadialDimension(
        ResultDim)^.P15ChangeTo(PGDBObjRadialDimension(ResultDim)^.DimData.P15InWCS);
    end;

  end;
end;

procedure GDBObjGenericDimension.LoadFromDXF;
var
  byt,dtype:integer;
  style:string;
begin
  byt:=rdr.ParseInteger;
  dtype:=-1;
  style:='';
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,DimData.P10InWCS) then
        if not dxfLoadGroupCodeVertex(rdr,11,byt,DimData.P11InOCS) then
          if not dxfLoadGroupCodeVertex(rdr,12,byt,DimData.P12InOCS) then
            if not dxfLoadGroupCodeVertex(rdr,13,byt,DimData.P13InWCS) then
              if not dxfLoadGroupCodeVertex(rdr,14,byt,DimData.P14InWCS) then
                if not dxfLoadGroupCodeVertex(rdr,15,byt,DimData.P15InWCS) then
                  if not dxfLoadGroupCodeVertex(rdr,16,byt,DimData.P16InOCS) then
                    if not dxfLoadGroupCodeInteger(rdr,70,byt,dtype) then
                      if not dxfLoadGroupCodeDouble(rdr,50,byt,a50) then
                        if not dxfLoadGroupCodeDouble(rdr,52,byt,a52) then
                          if dxfLoadGroupCodeString(rdr,3,byt,style) then begin
                            PDimStyle:=drawing.GetDimStyleTable^.getAddres(Style);
                            {if PDimStyle=nil then
                              PDimStyle:=pointer(drawing.GetDimStyleTable^.getDataMutable(0));}
                          end else
                            rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if PDimStyle=nil then
    PDimStyle:=pointer(drawing.GetDimStyleTable^.getDataMutable(0));
  if dtype<>-1 then begin
    case dtype and 15 of
      0:DimType:=DTRotated;
      1:DimType:=DTAligned;
      2:DimType:=DTAngular;
      3:DimType:=DTDiameter;
      4:DimType:=DTRadius;
      5:DimType:=DTAngular3P;
      6:DimType:=DTOrdinate;
    end;
  end;
  if dtype<>-1 then begin
    if (dtype and 128)<>0 then
      DimData.TextMoved:=True
    else
      DimData.TextMoved:=False;
  end;
end;

constructor GDBObjGenericDimension.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
  DimType:=TDimType.DTRotated;
  DimData.TextMoved:=False;
end;

constructor GDBObjGenericDimension.init;
begin
  inherited init(own,layeraddres,lw);
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
  DimType:=TDimType.DTRotated;
  DimData.TextMoved:=False;
end;

function GDBObjGenericDimension.GetObjType;
begin
  Result:=GDBGenericDimensionID;
end;

function AllocGenericDimension:PGDBObjGenericDimension;
begin
  Getmem(Result,sizeof(GDBObjGenericDimension));
end;

function AllocAndInitGenericDimension(owner:PGDBObjGenericWithSubordinated):
PGDBObjGenericDimension;
begin
  Result:=AllocGenericDimension;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

begin
  WorkingFormatSettings:=DefaultFormatSettings;
  RegisterDXFEntity(GDBGenericDimensionID,'DIMENSION','GenericDimension',@AllocGenericDimension,@AllocAndInitGenericDimension);
end.
