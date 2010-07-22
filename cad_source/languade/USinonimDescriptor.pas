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

unit USinonimDescriptor;
{$INCLUDE def.inc}
interface
uses TypeDescriptors,UGDBOpenArrayOfTObjLinkRecord,UGDBOpenArrayOfByte,gdbasetypes,varmandef,gdbase{,UGDBOpenArrayOfData,UGDBStringArray},memman;
type
PGDBSinonimDescriptor=^GDBSinonimDescriptor;
GDBSinonimDescriptor=object(TUserTypeDescriptor)
                     PSinonimOf:PUserTypeDescriptor;
                     SinonimName:GDBString;
                     constructor init(SinonimTypeName,Tname:GDBString;pu:pointer);
                     function CreateProperties(PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     procedure ApplyOperator(oper,path:GDBString;var offset:GDBLongword;var tc:PUserTypeDescriptor);virtual;
                     function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     destructor Done;virtual;

               end;
implementation
uses {ZBasicVisible,}UUnitManager,log;
destructor GDBSinonimDescriptor.done;
begin
     SinonimName:='';
     inherited;
end;
constructor GDBSinonimDescriptor.init;
begin
    GDBPointer(SinonimName):=nil;
    SinonimName:=SinonimTypeName;
    PSinonimOf:=units.currentunit{ SysUnit}.TypeName2PTD(SinonimName);
    inherited init(PSinonimOf^.SizeInGDBBytes,Tname,pu);
end;
function GDBSinonimDescriptor.CreateProperties;
begin
     PTUserTypeDescriptor(PSinonimOf)^.CreateProperties(PPDA,Name,PCollapsed,ownerattrib,bmode,addr,valkey,valtype);
end;
procedure GDBSinonimDescriptor.ApplyOperator;
begin
     PTUserTypeDescriptor(PSinonimOf)^.ApplyOperator(oper,path,offset,tc);
end;
function GDBSinonimDescriptor.Serialize;
begin
      PTUserTypeDescriptor(PSinonimOf)^.Serialize(PInstance,SaveFlag,membuf,linkbuf,sub);
end;
function GDBSinonimDescriptor.DeSerialize;
begin
      PTUserTypeDescriptor(PSinonimOf)^.DeSerialize(PInstance,SaveFlag,membuf,linkbuf);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('USinonimDescriptor.initialization');{$ENDIF}
end.
