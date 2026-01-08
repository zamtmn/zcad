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
unit uzcregisterenitiesextenders;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,
     uzcenitiesvariablesextender,uzccomdb,uzcentcable,uzcentnet,uzeentdevice,
     uzsbTypeDescriptors,
     uzetextpreprocessor,uzctnrVectorBytesStream,uzeobjectextender,
     uzeentity,uzeenttext,uzeblockdef,uzsbVarmanDef,Varman,UUnitManager,
     uzventsuperline,uzcentelleader,
     URecordDescriptor,UBaseTypeDescriptor;
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

