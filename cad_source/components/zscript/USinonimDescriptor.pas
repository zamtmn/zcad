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
     uzedimensionaltypes,varmandef,uzbtypes{,UGDBOpenArrayOfData,UGDBStringArray},uzbmemman;
type
PGDBSinonimDescriptor=^GDBSinonimDescriptor;
GDBSinonimDescriptor=object(TUserTypeDescriptor)
                     PSinonimOf:PUserTypeDescriptor;
                     SinonimName:GDBString;
                     constructor init(SinonimTypeName,Tname:GDBString;pu:pointer);
                     constructor init2(SinonimOf:PUserTypeDescriptor;Tname:TInternalScriptString;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     procedure ApplyOperator(oper,path:TInternalScriptString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;
                     //function Serialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     //function DeSerialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     destructor Done;virtual;
                     function GetFactTypedef:PUserTypeDescriptor;virtual;
                     function Compare(pleft,pright:pointer):TCompareResult;virtual;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                     procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                     function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
                     procedure MagicFreeInstance(PInstance:Pointer);virtual;
                     procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
               end;
implementation
uses {ZBasicVisible,}UUnitManager{,log};
function GDBSinonimDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
     result:=GetFactTypedef^.GetFormattedValueAsString(pinstance,f);
end;
function GDBSinonimDescriptor.GetValueAsString;
begin
     result:=GetFactTypedef^.GetValueAsString(pinstance);
end;
procedure GDBSinonimDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);
begin
     GetFactTypedef^.SavePasToMem(membuf,PInstance,prefix);
end;
procedure GDBSinonimDescriptor.SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);
begin
     GetFactTypedef^.SetValueFromString(pinstance,Value);
end;
procedure GDBSinonimDescriptor.MagicFreeInstance(PInstance:Pointer);
begin
     GetFactTypedef^.MagicFreeInstance(PInstance);
end;
procedure GDBSinonimDescriptor.MagicAfterCopyInstance(PInstance:Pointer);
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
    Pointer(SinonimName):=nil;
    SinonimName:=SinonimTypeName;
    PSinonimOf:=units.currentunit{ SysUnit}.TypeName2PTD(SinonimName);
    inherited init(PSinonimOf^.SizeInGDBBytes,Tname,pu);
end;
constructor GDBSinonimDescriptor.init2(SinonimOf:PUserTypeDescriptor;Tname:TInternalScriptString;pu:pointer);
begin
    Pointer(SinonimName):=nil;
    SinonimName:=SinonimOf^.TypeName;
    PSinonimOf:=SinonimOf;
    inherited init(PSinonimOf^.SizeInGDBBytes,Tname,pu);
end;
function GDBSinonimDescriptor.CreateProperties;
var
   td:TDecoratedProcs;
   tfe:TFastEditorsVector;
begin
     td:=PTUserTypeDescriptor(PSinonimOf)^.Decorators;
     tfe:=PTUserTypeDescriptor(PSinonimOf)^.FastEditors;
     PTUserTypeDescriptor(PSinonimOf)^.Decorators:=Decorators;
     PTUserTypeDescriptor(PSinonimOf)^.FastEditors:=FastEditors;
     PTUserTypeDescriptor(PSinonimOf)^.CreateProperties(f,mode,PPDA,Name,PCollapsed,ownerattrib,bmode,addr,valkey,valtype);
     PTUserTypeDescriptor(PSinonimOf)^.Decorators:=td;
     PTUserTypeDescriptor(PSinonimOf)^.FastEditors:=tfe;
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
