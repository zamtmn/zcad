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
     uzeentitiestree,usimplegenerics,uzeffdxfsupport;
const
  LayerControlExtenderName='extdrLayerControl';
type
TLayerControlExtender=class(TBaseEntityExtender)
    class function getExtenderName:string;override;
  end;

implementation

class function TLayerControlExtender.getExtenderName:string;
begin
  result:=LayerControlExtenderName;
end;

initialization
  EntityExtenders.RegisterKey(uppercase(LayerControlExtenderName),TLayerControlExtender);
finalization
end.
