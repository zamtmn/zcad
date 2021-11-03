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
unit uzcregisterenitiesextenders;
{$INCLUDE def.inc}

interface
uses sysutils,
     uzcenitiesvariablesextender,uzccomdb,uzcentcable,uzcentnet,uzeentdevice,TypeDescriptors,
     uzetextpreprocessor,UGDBOpenArrayOfByte,uzbtypes,uzeobjectextender,
     uzeentity,uzeenttext,uzeblockdef,varmandef,Varman,UUnitManager,
     uzventsuperline,uzcentelleader,
     URecordDescriptor,UBaseTypeDescriptor,uzbmemman;
implementation
begin
  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);

  {from GDBObjSuperLine}
  GDBObjSuperLine.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);

  {from GDBObjElLeader}
  GDBObjElLeader.GetDXFIOFeatures.RegisterEntityExtenderObject(TVariablesExtender);
end.

