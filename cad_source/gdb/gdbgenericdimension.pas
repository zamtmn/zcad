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
unit gdbgenericdimension;
{$INCLUDE def.inc}

interface
uses GDBWithLocalCS,gdbdimension,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
TDimType=(DTRotated,DTAligned,DTAngular,DTDiameter,DTRadius,DTAngular3P,DTOrdinate);
PGDBObjGenericDimension=^GDBObjGenericDimension;
GDBObjGenericDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      DimType:TDimType;
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit;const drawing:TDrawingDef);virtual;
                      function FromDXFPostProcessBeforeAdd(ptu:PTUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                   end;
{EXPORT-}
implementation
uses gdbrotateddimension,gdbaligneddimension,GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
var
  WorkingFormatSettings:TFormatSettings;
function GDBObjGenericDimension.FromDXFPostProcessBeforeAdd(ptu:PTUnit;const drawing:TDrawingDef):PGDBObjSubordinated;
var
  ResultDim:PGDBObjDimension;
begin
         case DimType of
                               DTRotated:begin
                                 GDBGetMem({$IFDEF DEBUGBUILD}'{4C837C43-E018-4307-ADC2-DEB5134AF6D8}',{$ENDIF}GDBPointer(ResultDim),sizeof(GDBObjRotatedDimension));
                                 result:=ResultDim;
                                 PGDBObjRotatedDimension(ResultDim)^.initnul(bp.ListPos.Owner);
                                 ResultDim.vp.Layer:=vp.Layer;
                                 ResultDim^.Local:=local;
                                 ResultDim^.P_insert_in_WCS:=P_insert_in_WCS;
                                 PGDBObjRotatedDimension(ResultDim)^.DimData:=DimData;
                                 PGDBObjRotatedDimension(ResultDim)^.PDimStyle:=PDimStyle;
                               end;
                               else
                                   begin
                                     GDBGetMem({$IFDEF DEBUGBUILD}'{4C837C43-E018-4307-ADC2-DEB5134AF6D8}',{$ENDIF}GDBPointer(ResultDim),sizeof(GDBObjAlignedDimension));
                                     result:=ResultDim;
                                     PGDBObjAlignedDimension(ResultDim)^.initnul(bp.ListPos.Owner);
                                     ResultDim.vp.Layer:=vp.Layer;
                                     ResultDim^.Local:=local;
                                     ResultDim^.P_insert_in_WCS:=P_insert_in_WCS;
                                     PGDBObjAlignedDimension(ResultDim)^.DimData:=DimData;
                                     PGDBObjAlignedDimension(ResultDim)^.PDimStyle:=PDimStyle;
                                   end;
       end;
end;

procedure GDBObjGenericDimension.LoadFromDXF;
var
  byt,dtype:GDBInteger;
  style:GDBString;
begin
  byt:=readmystrtoint(f);
  dtype:=-1;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,DimData.P10InWCS) then
          if not dxfvertexload(f,11,byt,DimData.P11InOCS) then
             if not dxfvertexload(f,12,byt,DimData.P12InOCS) then
                if not dxfvertexload(f,13,byt,DimData.P13InWCS) then
                   if not dxfvertexload(f,14,byt,DimData.P14InWCS) then
                      if not dxfvertexload(f,15,byt,DimData.P15InWCS) then
                         if not dxfvertexload(f,16,byt,DimData.P16InOCS) then
                            if not dxfGDBIntegerload(f,70,byt,dtype) then
                            if dxfGDBStringload(f,3,byt,style)then
                                                                  begin
                                                                       PDimStyle:=drawing.GetDimStyleTable^.getAddres(Style);
                                                                       if PDimStyle=nil then
                                                                                            PDimStyle:=drawing.GetDimStyleTable^.getelement(0);
                                                                  end
                            else
                                f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
  if dtype<>-1 then
  begin
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
end;

constructor GDBObjGenericDimension.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  vp.ID := GDBGenericDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
  DimType:=TDimType.DTRotated;
end;
constructor GDBObjGenericDimension.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBGenericDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
  DimType:=TDimType.DTRotated;
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbgenericdimension.initialization');{$ENDIF}
  WorkingFormatSettings:=DefaultFormatSettings;
end.
