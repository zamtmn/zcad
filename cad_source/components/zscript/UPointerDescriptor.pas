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

unit UPointerDescriptor;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses types,TypeDescriptors,UGDBOpenArrayOfByte,
     uzedimensionaltypes,uzbtypesbase,varmandef,uzbtypes,uzctnrvectorgdbstring,uzbmemman;
resourcestring
  rsUnassigned='Unassigned';
type
PGDBPointerDescriptor=^GDBPointerDescriptor;
GDBPointerDescriptor=object(TUserTypeDescriptor)
                     TypeOf:PUserTypeDescriptor;
                     ReferType:GDBString;
                     //constructor init(var t:gdbtypedesk);
                     constructor init(ptype:GDBString;tname:string;pu:pointer);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     //function Serialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                     //function DeSerialize(PInstance:Pointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                     procedure Format;virtual;
                     function GetTypeAttributes:TTypeAttr;virtual;
                     function CreateEditor(TheOwner:TPropEditorOwner;rect:trect{x,y,w,h:GDBInteger};pinstance:pointer;psa:PTZctnrVectorGDBString;FreeOnLostFocus:boolean;InitialValue:TInternalScriptString;preferedHeight:integer):TEditorDesc{TPropEditor};virtual;
                     procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                     destructor Done;virtual;
               end;
const PAssigned:Pointer=nil;
      PNIL:byte=255;
var
    defaultptypehandler:GDBPointerDescriptor;
implementation
uses varman{,log};
procedure GDBPointerDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);
begin

end;

destructor GDBPointerDescriptor.done;
begin
     ReferType:='';
     inherited;
end;
function GDBPointerDescriptor.CreateEditor;
//var num:cardinal;
    //p:EnumDescriptor;
begin
     if assigned(TypeOf)and assigned(pointer(pinstance^)) then

     result:=TypeOf^.CreateEditor(theowner,rect,pointer(pinstance^),nil,FreeOnLostFocus,initialvalue,preferedHeight)
end;

constructor GDBPointerDescriptor.init;
begin
    Pointer(ReferType):=nil;
    Pointer(typename):=nil;
    typename:=tname;
    ReferType:=ptype;
    TypeOf:=nil;
    self.SizeInGDBBytes:={4 cpu64}sizeof(pointer);
    punit:=pu;
    format;
end;
function GDBPointerDescriptor.CreateProperties;
var ta,oldta{,tb}:Pointer;
    ppd:PPropertyDeskriptor;
    bm,bm2:integer;
begin
    ta:=pGDBPointer(addr)^;
    oldta:=ta;
    bm:=bmode;
    bm2:=property_build;
    //if PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.GetTypeAttributes=TA_COMPOUND then
    //                                                                                          ppd:=ppd;
    if (assigned(ta))and(name='lstonmouse') then
                                                       name:=name;

    if assigned(ta) then
                        begin

                             if (PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.GetTypeAttributes and TA_COMPOUND)=0 then
                                                                                                                        PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.CreateProperties(f,PDM_Field,PPDA,name,PCollapsed,ownerattrib,bmode,ta,valkey,valtype)
                                                                                                                    else
                                                                                                                    begin
                                                                                                                         if bmode<>property_build then
                                                                                                                         begin
                                                                                                                              ppd:=GetPPD(ppda,bmode);
                                                                                                                         if (ppd^.SubNode=nil) then
                                                                                                                                                       begin
                                                                                                                                                       bm2:=-bmode;
                                                                                                                                                       PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.CreateProperties(f,PDM_Field,PPDA,name,PCollapsed,ownerattrib,bm2,ta,valkey,valtype);
                                                                                                                                                       bmode:=bm2;
                                                                                                                                                       end
                                                                                                                                                   else
                                                                                                                                                       begin
                                                                                                                                                            if (ppd^.valueAddres=nil)or(ppd^.valueAddres=ta) then
                                                                                                                                                                                       PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.CreateProperties(f,PDM_Field,PPDA,name,PCollapsed,ownerattrib,bmode,ta,valkey,valtype)
                                                                                                                                                                                   else
                                                                                                                                                                                       begin
                                                                                                                                                                                            if ppd^.SubNode<>nil then
                                                                                                                                                                                            begin

                                                                                                                                                                                                 PTPropertyDeskriptorArray(ppd^.SubNode)^.cleareraseobj;
                                                                                                                                                                                                 ppd^.SubNode^.Done;
                                                                                                                                                                                                 gdbfreemem(ppd^.SubNode);
                                                                                                                                                                                                 ppd^.SubNode:=nil;

                                                                                                                                                                                            end;
                                                                                                                                                                                            bm2:=-bmode;
                                                                                                                                                                                            PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.CreateProperties(f,PDM_Field,PPDA,name,PCollapsed,ownerattrib,{bmode}bm2,ta,valkey,valtype);
                                                                                                                                                                                            bmode:=bm2;
                                                                                                                                                                                       end;
                                                                                                                                                       end;
                                                                                                                             ppd^.valueAddres:=oldta;
                                                                                                                         end
                                                                                                                         else
                                                                                                                             PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)))^.CreateProperties(f,PDM_Field,PPDA,name,PCollapsed,ownerattrib,bmode,ta,valkey,valtype)

                                                                                                                    end
                        end
                    else
                        begin
                             ppd:=GetPPD(ppda,bmode);
                             if ppd^.SubNode<>nil then
                                                          begin
                                                               PTPropertyDeskriptorArray(ppd^.SubNode)^.cleareraseobj;
                                                               ppd^.SubNode^.Done;
                                                               gdbfreemem(ppd^.SubNode);
                                                          end;
                             ppd^.Name:=name;
                             ppd^.PTypeManager:=PTUserTypeDescriptor(PUserTypeDescriptor((TypeOf)));
                             ppd^.Attr:=ownerattrib;
                             ppd^.Collapsed:=PCollapsed;
                             ppd^.SubNode:=nil;
                             ppd^.valueAddres:={addr}ta;
                             ppd^.value:=rsUnassigned;
                             ppd^.HelpPointer:=nil;
                        end;
     if bm<>bmode then
     bmode:=bm;
     //IncAddr(addr);
end;
procedure GDBPointerDescriptor.format;
begin
     //self.TypeOf:=Types.TypeName2TypeDesc(self.ReferType);
     if punit<>nil then
     self.TypeOf:=ptunit(punit)^.TypeName2PTD(self.ReferType);
end;
function GDBPointerDescriptor.GetTypeAttributes;
begin
     result:=TA_COMPOUND;
end;
begin
  defaultptypehandler.init('','',nil);
end.
