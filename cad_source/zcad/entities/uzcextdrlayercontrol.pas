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
unit uzcExtdrLayerControl;

interface

uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzetextpreprocessor,UGDBOpenArrayOfByte,
     uzbtypesbase,uzbtypes,uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,uzbmemman,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzcvariablesutils;
const
  LayerControlExtenderName='extdrLayerControl';
type
TLayerControlExtender=class(TBaseEntityExtender)
    GoodLayer,BadLayer:string;
    VariableName:string;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);override;
  end;

implementation
constructor TLayerControlExtender.Create(pEntity:Pointer);
begin
  GoodLayer:='EL_DEVICE_NAME';
  BadLayer:='SYS_METRIC';
  VariableName:='Test';
end;

procedure TLayerControlExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);
var
  pvd:pvardesk;
  pl:pointer;
begin
  pvd:=FindVariableInEnt(pEntity,VariableName);
  if pvd<>nil then
    if pvd^.data.Instance<>nil then
      if pvd^.data.PTD=@FundamentalBooleanDescriptorOdj then begin
        if pboolean(pvd^.data.Instance)^ then
          pl:=drawing.GetLayerTable^.getAddres(GoodLayer)
        else
          pl:=drawing.GetLayerTable^.getAddres(BadLayer);
        if pl<>nil then
          PGDBObjEntity(pEntity)^.vp.Layer:=pl;
      end;
end;

class function TLayerControlExtender.getExtenderName:string;
begin
  result:=LayerControlExtenderName;
end;

initialization
  EntityExtenders.RegisterKey(uppercase(LayerControlExtenderName),TLayerControlExtender);
finalization
end.
