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
{$MODE DELPHI}
interface
uses TypeDescriptors,UGDBOpenArrayOfTObjLinkRecord,UGDBOpenArrayOfByte,gdbasetypes,
     varmandef,gdbase{,UGDBOpenArrayOfData,UGDBStringArray},memman;
type
PGDBSinonimDescriptor=^GDBSinonimDescriptor;
GDBSinonimDescriptor=object(TUserTypeDescriptor)
                     PSinonimOf:PUserTypeDescriptor;
                     SinonimName:GDBString;
                     constructor init(SinonimTypeName,Tname:GDBString;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     procedure ApplyOperator(oper,path:GDBString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;
                     function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     destructor Done;virtual;
                     function GetFactTypedef:PUserTypeDescriptor;virtual;
                     function Compare(pleft,pright:pointer):TCompareResult;virtual;
                     function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                     function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;

               end;
implementation
uses {ZBasicVisible,}UUnitManager{,log};
function GDBSinonimDescriptor.GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;
begin
     result:=GetFactTypedef^.GetFormattedValueAsString(pinstance,f);
end;
function GDBSinonimDescriptor.GetValueAsString;
begin
     result:=GetFactTypedef^.GetValueAsString(pinstance);
end;
destructor GDBSinonimDescriptor.done;
begin
     SinonimName:='';
     inherited;
end;
function GDBSinonimDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     result:=PSinonimOf^.Compare(pleft,pright);
end;

function GDBSinonimDescriptor.GetFactTypedef:PUserTypeDescriptor;
begin
     result:=PSinonimOf^.GetFactTypedef;
end;
constructor GDBSinonimDescriptor.init;
begin
    GDBPointer(SinonimName):=nil;
    SinonimName:=SinonimTypeName;
    PSinonimOf:=units.currentunit{ SysUnit}.TypeName2PTD(SinonimName);
    inherited init(PSinonimOf^.SizeInGDBBytes,Tname,pu);
end;
function GDBSinonimDescriptor.CreateProperties;
var
   td:TDecoratedProcs;
   tfe:TFastEditorProcs;
begin
     td:=PTUserTypeDescriptor(PSinonimOf)^.Decorators;
     tfe:=PTUserTypeDescriptor(PSinonimOf)^.FastEditor;
     PTUserTypeDescriptor(PSinonimOf)^.Decorators:=Decorators;
     PTUserTypeDescriptor(PSinonimOf)^.FastEditor:=FastEditor;
     PTUserTypeDescriptor(PSinonimOf)^.CreateProperties(f,mode,PPDA,Name,PCollapsed,ownerattrib,bmode,addr,valkey,valtype);
     PTUserTypeDescriptor(PSinonimOf)^.Decorators:=td;
     PTUserTypeDescriptor(PSinonimOf)^.FastEditor:=tfe;
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
