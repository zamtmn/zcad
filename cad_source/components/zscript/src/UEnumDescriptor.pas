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

unit UEnumDescriptor;

{$MODE DELPHI}
interface
uses
  types,sysutils,uzctnrVectorBytesStream,uzsbTypeDescriptors,
  uzbUnits,
  gzctnrVectorTypes,uzsbVarmanDef,gzctnrVector,uzctnrvectorstrings;
resourcestring
  rsDifferent='Different';
type
PTByteVector=^TByteVector;
TByteVector=GZVector<Byte>;
PTWordVector=^TWordVector;
TWordVector=GZVector<Word>;
PTCardinalVector=^TCardinalVector;
TCardinalVector=GZVector<Cardinal>;
PEnumDescriptor=^EnumDescriptor;
EnumDescriptor=object(TUserTypeDescriptor)
                     SourceValue:TZctnrVectorStrings;
                     UserValue:TZctnrVectorStrings;
                     Value:PTByteVector;
                     constructor init(size:Integer;tname:string;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:TFieldAttrs;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     function CreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;const InitialValue:TInternalScriptString;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;virtual;
                     function GetNumberInArrays(addr:Pointer;out number:LongWord):Boolean;virtual;
                     //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PTZctnrVectorBytes;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:TZctnrVectorBytes;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     function GetUserValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     destructor Done;virtual;
                     function GetTypeAttributes:TTypeAttr;virtual;
                     procedure SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);virtual;
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
     Freemem(Value);
end;
constructor EnumDescriptor.init;
begin
     inherited init(size,tname,pu);
     SourceValue.init(20);
     UserValue.init(20);
     Getmem(Pointer(Value),sizeof(TByteVector));
     case size of
                 1:Value.init(20);
                 2:PTWordVector(Value).init(20);
                 4:PTCardinalVector(Value).init(20);
     end;
end;
function EnumDescriptor.CreateProperties;
var currval:LongWord;
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
     
     if fldaDifferent in ppd^.Attr then
       ppd^.value:=rsDifferent
     else begin
       if GetNumberInArrays(Pointer(ppd^.valueAddres),currval)then
         ppd^.value:=UserValue.getData(currval)
       else
         ppd^.value:='NotFound';
     end
end;
function EnumDescriptor.GetNumberInArrays;
var currval:LongWord;
    p:Pointer;
    //found:Boolean;
//    i:Integer;
        ir:itrec;
begin
     result:=false;
     case SizeInBytes of
                      1:begin
                             currval:=PByte(addr)^;
                             p:=Value.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   if PByte(p)^=currval then
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
procedure EnumDescriptor.SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);
var //currval:LongWord;
    p,p2,pp:Pointer;
//    found:Boolean;
//    i:Integer;
        ir,ir2,irr:itrec;
        uppercase_value:TInternalScriptString;
begin
     uppercase_value:=uppercase(_value);
     case SizeInBytes of
                      1:begin
                             p:=SourceValue.beginiterate(ir);
                             p2:=UserValue.beginiterate(ir2);
                             pp:=Value.beginiterate(irr);
                             if p<>nil then
                             repeat
                             if (uppercase_value=uppercase(pstring(p)^))
                             or (uppercase_value=uppercase(pstring(p2)^))then
                             begin
                                  PByte(pinstance)^:=pbyte(pp)^;
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
var //currval:LongWord;
//    p:Pointer;
//    found:Boolean;
//    i:Integer;
    num:cardinal;
begin
     result:='ENUMERROR';
     GetNumberInArrays(pinstance,num);
     result:={UserValue}SourceValue.getData(num)
end;
function EnumDescriptor.GetUserValueAsString;
var //currval:LongWord;
//    p:Pointer;
//    found:Boolean;
//    i:Integer;
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
                                         result:=EnumGlobalEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,initialvalue,@self,preferedHeight,f)
                                   else
                                       begin
                                           result.editor:=nil;
                                           result.mode:=TEM_Nothing;
                                       end;
end;
begin
end.
