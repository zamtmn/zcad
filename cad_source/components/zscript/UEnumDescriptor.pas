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

unit UEnumDescriptor;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses types,sysutils,UGDBOpenArrayOfByte,TypeDescriptors,
     gzctnrvectortypes,uzedimensionaltypes,uzbtypesbase,varmandef,uzbtypes,gzctnrvectordata,uzctnrvectorgdbstring,uzbmemman;
resourcestring
  rsDifferent='Different';
type
PTByteVector=^TByteVector;
TByteVector=GZVectorData<Byte>;
PTWordVector=^TWordVector;
TWordVector=GZVectorData<Word>;
PTCardinalVector=^TCardinalVector;
TCardinalVector=GZVectorData<Cardinal>;
PEnumDescriptor=^EnumDescriptor;
EnumDescriptor=object(TUserTypeDescriptor)
                     SourceValue:TZctnrVectorGDBString;
                     UserValue:TZctnrVectorGDBString;
                     Value:PTByteVector;
                     constructor init(size:GDBInteger;tname:string;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     function CreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorGDBString;FreeOnLostFocus:boolean;InitialValue:TInternalScriptString;preferedHeight:integer):TEditorDesc;virtual;
                     function GetNumberInArrays(addr:Pointer;out number:GDBLongword):GDBBoolean;virtual;
                     //function Serialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     //function DeSerialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     function GetUserValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     destructor Done;virtual;
                     function GetTypeAttributes:TTypeAttr;virtual;
                     procedure SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);virtual;
               end;
var
    EnumGlobalEditor:TCreateEditorFunc;
implementation
//uses log;
function EnumDescriptor.GetTypeAttributes:TTypeAttr;
begin
     result:=ta_enum;
end;
destructor EnumDescriptor.done;
begin
     inherited;
     SourceValue.Done;
     UserValue.Done;
     value.Done;
     gdbfreemem(Value);
end;
constructor EnumDescriptor.init;
begin
     //gdbgetmem({$IFDEF DEBUGBUILD}'{B8CB2886-0E46-4426-B99B-EA4A0948FAE7}',{$ENDIF}Pointer(PSourceValue),sizeof(PSourceValue^));
     //gdbgetmem({$IFDEF DEBUGBUILD}'{28FC622D-1EAD-4CCA-801B-ECF3B7E3C9D5}',{$ENDIF}Pointer(PSourceValue),sizeof(PUserValue^));
     inherited init(size,tname,pu);
     SourceValue.init(20);
     UserValue.init(20);
     gdbgetmem({$IFDEF DEBUGBUILD}'{B8CB2886-0E46-4426-B99B-EA4A0948FAE7}',{$ENDIF}Pointer(Value),sizeof(TByteVector));
     case size of
                 1:Value.init({$IFDEF DEBUGBUILD}'{EA29780F-2455-4BBF-9CB6-054B6A4D48C5}',{$ENDIF}20{,1});
                 2:PTWordVector(Value).init({$IFDEF DEBUGBUILD}'{E17DB617-1782-4815-BA8B-12F53B06DAD8}',{$ENDIF}20{,2});
                 4:PTCardinalVector(Value).init({$IFDEF DEBUGBUILD}'{21381F6A-26DC-43C3-B4F8-0BBB24722B75}',{$ENDIF}20{,4});
     end;
end;
function EnumDescriptor.CreateProperties;
var currval:GDBLongword;
//    p:Pointer;
//    found:GDBBoolean;
//    i:GDBInteger;
    ppd:PPropertyDeskriptor;
begin
     ppd:=GetPPD(ppda,bmode);
     ppd^.Name:=name;
     ppd^.PTypeManager:=@self;
     ppd^.Decorators:=Decorators;
     convertToRunTime(FastEditors,ppd^.FastEditors);
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     ppd^.ValKey:=valkey;
     ppd^.ValType:=valtype;
     
     if (ppd^.Attr and FA_DIFFERENT)=0 then
                                           begin
                                                 if GetNumberInArrays(Pointer(ppd^.valueAddres),currval)then ppd^.value:=UserValue.getData(currval)
                                                                                                           else ppd^.value:='NotFound';
                                           end
                                       else
                                           ppd^.value:=rsDifferent;
     //IncAddr(addr);
end;
function EnumDescriptor.GetNumberInArrays;
var currval:GDBLongword;
    p:Pointer;
    //found:GDBBoolean;
//    i:GDBInteger;
        ir:itrec;
begin
     result:=false;
     case SizeInGDBBytes of
                      1:begin
                             currval:=pGDBByte(addr)^;
                             p:=Value.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   if pGDBByte(p)^=currval then
                                                            begin
                                                                 //found:=true;
                                                                 number:=ir.itc;
                                                                 result:=true;
                                                                 system.Break;
                                                            end;
                                   p:=Value.iterate(ir);
                             until p=nil;
                        end;
     end;
end;
procedure EnumDescriptor.SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);
var //currval:GDBLongword;
    p,p2,pp:Pointer;
//    found:GDBBoolean;
//    i:GDBInteger;
        ir,ir2,irr:itrec;
begin
     _value:=uppercase(_value);
     case SizeInGDBBytes of
                      1:begin
                             p:=SourceValue.beginiterate(ir);
                             p2:=UserValue.beginiterate(ir2);
                             pp:=Value.beginiterate(irr);
                             if p<>nil then
                             repeat
                             if (_value=uppercase(pstring(p)^))
                             or (_value=uppercase(pstring(p2)^))then
                             begin
                                  pGDBByte(pinstance)^:=pbyte(pp)^;
                                  exit;
                             end;
                                   p:=SourceValue.iterate(ir);
                                   p2:=UserValue.iterate(ir2);
                                   pp:=Value.iterate(irr);
                             until p=nil;
                      end;
     end;
end;
function EnumDescriptor.GetValueAsString;
var //currval:GDBLongword;
//    p:Pointer;
//    found:GDBBoolean;
//    i:GDBInteger;
    num:cardinal;
begin
     result:='ENUMERROR';
     GetNumberInArrays(pinstance,num);
     result:={UserValue}SourceValue.getData(num)
end;
function EnumDescriptor.GetUserValueAsString;
var //currval:GDBLongword;
//    p:Pointer;
//    found:GDBBoolean;
//    i:GDBInteger;
    num:cardinal;
begin
     result:='ENUMERROR';
     GetNumberInArrays(pinstance,num);
     result:=UserValue.getData(num)
end;
function EnumDescriptor.CreateEditor;
begin
     result:=inherited;
     if (result.editor=nil)and(result.mode=TEM_Nothing)then
     if assigned(EnumGlobalEditor) then
                                         result:=EnumGlobalEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,initialvalue,@self,preferedHeight)
                                   else
                                       begin
                                           result.editor:=nil;
                                           result.mode:=TEM_Nothing;
                                       end;
end;
begin
end.
