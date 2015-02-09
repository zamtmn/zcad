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
unit registerenitiesextenders;
{$INCLUDE def.inc}

interface
uses sysutils,
     enitiesextendervariables,shared,GDBCommandsDB,GDBCable,GDBNet,GDBDevice,TypeDescriptors,
     gdbfieldprocessor,UGDBOpenArrayOfByte,gdbase,gdbobjectextender,
     GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,memman;
implementation
begin
  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateTestExtender);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateTestExtender);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateTestExtender);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterEntityExtenderObject(@TVariablesExtender.CreateTestExtender);
end.

