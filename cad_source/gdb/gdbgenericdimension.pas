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
uses gdbdimension,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
PTDXFDimData2D=^TDXFDimData2D;
TDXFDimData2D=packed record
  P10:GDBVertex2D;
  P11:GDBVertex2D;
  P12:GDBVertex2D;
  P13:GDBVertex2D;
  P14:GDBVertex2D;
  P15:GDBVertex2D;
  P16:GDBVertex2D;
end;
PTDXFDimData=^TDXFDimData;
TDXFDimData=packed record
  P10InWCS:GDBVertex;
  P11InOCS:GDBVertex;
  P12InOCS:GDBVertex;
  P13InWCS:GDBVertex;
  P14InWCS:GDBVertex;
  P15InWCS:GDBVertex;
  P16InOCS:GDBVertex;
end;
PGDBObjGenericDimension=^GDBObjGenericDimension;
GDBObjGenericDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDimension)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit;const drawing:TDrawingDef);virtual;
                      function FromDXFPostProcessBeforeAdd(ptu:PTUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                   end;
{EXPORT-}
implementation
uses gdbaligneddimension,GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
var
  WorkingFormatSettings:TFormatSettings;
function GDBObjGenericDimension.FromDXFPostProcessBeforeAdd(ptu:PTUnit;const drawing:TDrawingDef):PGDBObjSubordinated;
var
  ResultDim:PGDBObjDimension;
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

procedure GDBObjGenericDimension.LoadFromDXF;
var
  byt:GDBInteger;
  style:GDBString;
begin
  byt:=readmystrtoint(f);
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
end;

constructor GDBObjGenericDimension.initnul;
begin
  inherited initnul;
  bp.ListPos.Owner:=owner;
  vp.ID := GDBGenericDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
constructor GDBObjGenericDimension.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBGenericDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbgenericdimension.initialization');{$ENDIF}
  WorkingFormatSettings:=DefaultFormatSettings;
end.
