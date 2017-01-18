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
uses TypeDescriptors,UGDBOpenArrayOfByte,uzbtypesbase,
     varmandef,uzbtypes{,UGDBOpenArrayOfData,UGDBStringArray},uzbmemman;
type
PGDBSinonimDescriptor=^GDBSinonimDescriptor;
GDBSinonimDescriptor=object(TUserTypeDescriptor)
                     PSinonimOf:PUserTypeDescriptor;
                     SinonimName:GDBString;
                     constructor init(SinonimTypeName,Tname:GDBString;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     procedure ApplyOperator(oper,path:GDBString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;
                     //function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     //function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     destructor Done;virtual;
                     function GetFactTypedef:PUserTypeDescriptor;virtual;
                     function Compare(pleft,pright:pointer):TCompareResult;virtual;
                     function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                     procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                     function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;
                     procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                     procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
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
procedure GDBSinonimDescriptor.SetValueFromString(PInstance:GDBPointer;Value:GDBstring);
begin
     GetFactTypedef^.SetValueFromString(pinstance,Value);
end;
procedure GDBSinonimDescriptor.MagicFreeInstance(PInstance:GDBPointer);
begin
     GetFactTypedef^.MagicFreeInstance(PInstance);
end;
procedure GDBSinonimDescriptor.MagicAfterCopyInstance(PInstance:GDBPointer);
begin
     GetFactTypedef^.MagicAfterCopyInstance(PInstance);
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
{function GDBSinonimDescriptor.Serialize;
begin
      PTUserTypeDescriptor(PSinonimOf)^.Serialize(PInstance,SaveFlag,membuf,linkbuf,sub);
end;
function GDBSinonimDescriptor.DeSerialize;
begin
      PTUserTypeDescriptor(PSinonimOf)^.DeSerialize(PInstance,SaveFlag,membuf,linkbuf);
end;}
begin
end.
