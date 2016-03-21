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
     uzcenitiesvariablesextender,uzcshared,uzccomdb,uzcentcable,uzcentnet,uzeentdevice,TypeDescriptors,
     uzetextpreprocessor,UGDBOpenArrayOfByte,gdbase,uzeobjectextender,
     uzeentity,uzeenttext,uzeblockdef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,memman;
implementation
begin
  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateEntVariablesExtender);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateEntVariablesExtender);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateEntVariablesExtender);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateEntVariablesExtender);
end.

