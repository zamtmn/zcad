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

unit UArrayDescriptor;

{$MODE DELPHI}
interface
uses
  gzctnrVectorTypes,sysutils,LCLProc,uzsbTypeDescriptors,
  uzbUnits,
  uzsbVarmanDef,gzctnrVector,uzbLogIntf;
type
PArrayIndexDescriptor=^ArrayIndexDescriptor;
ArrayIndexDescriptor=record
                           IndexMin,IndexCount:Integer;
                     end;
TArrayIndexDescriptorVector=GZVector<ArrayIndexDescriptor>;
PArrayDescriptor=^ArrayDescriptor;
ArrayDescriptor=object(TUserTypeDescriptor)
                     NumOfIndex:Integer;
                     typeof:PUserTypeDescriptor;
                     Indexs:{GDBOpenArrayOfData}TArrayIndexDescriptorVector;
                     constructor init(var t:PUserTypeDescriptor;tname:string;pu:pointer);
                     procedure AddIndex(var Index:ArrayIndexDescriptor);
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:TFieldAttrs;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     destructor Done;virtual;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
               end;
implementation
uses {ZBasicVisible,}varman;
function ArrayDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
var
   PAID:PArrayIndexDescriptor;
   ir:itrec;
   i:integer;
begin
     result:='(';
     PAID:=Indexs.beginiterate(ir);
     if paid<>nil then
                     repeat
                           for i:=paid^.IndexMin to paid^.IndexMin+paid^.IndexCount-1 do
                           begin
                                if i<>paid^.IndexMin then
                                                         begin
                                                              result:=result+',';
                                                              //if typeof^.GetTypeAttributes=TA_COMPOUND then result:=result+#10#13;
                                                         end;
                                result:=result+typeof^.GetValueAsString(pinstance);
                                typeof^.IncAddr(pinstance);
                           end;
                           PAID:=Indexs.iterate(ir);
                     until paid=nil;
     result:=result+')'{#10#13;};
end;

constructor ArrayDescriptor.init;
begin
     inherited init(0,tname,pu);
     NumOfIndex:=0;
     typeof:=t;
     Indexs.init(20);
end;
destructor ArrayDescriptor.done;
begin
     inherited;
     Indexs.Done;
end;
procedure ArrayDescriptor.AddIndex;
begin
     indexs.PushBackData(Index);
     inc(NumOfIndex);
     SizeInBytes:=SizeInBytes+typeof^.SizeInBytes*Index.IndexCount
end;
function ArrayDescriptor.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     zTraceLn('{T}[ZSCRIPT]ArrayDescriptor.CreateProperties(%s)',[name]);
     //programlog.LogOutFormatStr('ArrayDescriptor.CreateProperties(%s)',[name],lp_OldPos,LM_Trace);
     ppd:=GetPPD(ppda,bmode);
     ppd^.Name:=name;
     ppd^.PTypeManager:=@self;
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     ppd^.value:=GetValueAsString(addr);//'not ready';

           if ppd<>nil then
                           begin
                                //IncAddr(addr);
                                //inc(PByte(addr),SizeInBytes);
                                //if bmode=property_build then PPDA^.add(@ppd);
                           end;
     //IncAddr(addr);
end;
begin
end.
