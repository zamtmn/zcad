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
unit typedescriptors;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses uzedimensionaltypes,uzctnrvectorgdbpointer,LCLProc,uzbtypesbase,varmandef,uzbtypes,gzctnrvectordata,uzctnrvectorgdbstring,uzbmemman,
     gzctnrvectortypes,gzctnrvectorp,uzbstrproc,sysutils;
const
     m_procedure=1;
     m_function=2;
     m_constructor=4;
     m_destructor=8;
     m_virtual=16;
     field_no_attrib=nil;

     FA_HIDDEN_IN_OBJ_INSP=1;
     FA_READONLY=2;
     FA_DIFFERENT=4;
     FA_APPROXIMATELY=8;
     FA_COLORED1=16;
     SA_SAVED_TO_SHD=1;

     property_correct=1;
     property_build=0;

     SM_Var=1;
     SM_Default=0;

type tzcpmode=(zcptxt,zcpbin);

  PPropertyDeskriptor=^PropertyDeskriptor;
  PropertyDeskriptor=object(BasePropertyDeskriptor)
                           constructor initnul;
                           destructor done;virtual;
                           function IsVisible:boolean;
                     end;
PTPropertyDeskriptorArray=^TPropertyDeskriptorArray;
TPropertyDeskriptorArray=object(GZVectorP{-}<PPropertyDeskriptor>{//})
                               procedure cleareraseobj;virtual;
                               function GetRealPropertyDeskriptorsCount:integer;virtual;
                               function findcategory(category:TInternalScriptString):PPropertyDeskriptor;
                               function findvalkey(valkey:GDBString):integer;
                         end;
SimpleProcOfObj=procedure of object;
SimpleProcOfObjDouble=procedure (arg:GDBDouble) of object;
SimpleFuncOfObjDouble=function:GDBDouble  of object;
PFieldDescriptor=^FieldDescriptor;
pBaseDescriptor=^BaseDescriptor;
BaseDescriptor=record
                      ProgramName:GDBString;

                      UserName:GDBString;

                      PFT:PUserTypeDescriptor;

                      {** Сделать строку только для чтения/редактр или скрыть/открыть итд.
                       Пример:
                       samplef:=sampleInternalRTTITypeDesk^.FindField('VNum'); находим описание поля VNum
                       samplef^.base.Attributes:=samplef^.base.Attributes and (not FA_HIDDEN_IN_OBJ_INSP); сбрасываем ему флаг cкрытности
                       samplef^.base.Attributes:=samplef^.base.Attributes or FA_HIDDEN_IN_OBJ_INSP; устанавливаем ему флаг cкрытности
                       }
                      Attributes:GDBWord;

                      Saved:GDBWord;
               end;

FieldDescriptor=record
                      base:BaseDescriptor;
                      //FieldName:GDBString;
                      //UserName:GDBString;
                      //PFT:PUserTypeDescriptor;
                      Offset,Size:GDBInteger;
                      //Attributes:GDBWord;
                      Collapsed:GDBBoolean;
                end;
PPropertyDescriptor=^PropertyDescriptor;
PropertyDescriptor=record
                      base:BaseDescriptor;
                      //PropertyName:GDBString;
                      //UserName:GDBString;
                      r,w:GDBString;
                      //PFT:PUserTypeDescriptor;
                      //Attributes:GDBWord;
                      Collapsed:GDBBoolean;
                end;
PTUserTypeDescriptor=^TUserTypeDescriptor;
TUserTypeDescriptor=object(UserTypeDescriptor)
                          function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;abstract;
                          //procedure IncAddr(var addr:GDBPointer);virtual;
                          function CreatePD:GDBPointer;
                          function GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:GDBInteger):PPropertyDeskriptor;
                          function FindField(fn:TInternalScriptString):PFieldDescriptor;virtual;
                   end;
var zcpmode:tzcpmode;
    //currpd:PPropertyDeskriptor;
    debugShowHiddenFieldInObjInsp:boolean=false;
implementation
uses strmy;
function TUserTypeDescriptor.GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:GDBInteger):PPropertyDeskriptor;
begin
     if bmode=property_build
     then
         begin
              result:=CreatePD;
              PPDA^.PushBackData(result);
         end
     else
         begin
              result:=pointer(ppda^.getDataMutable(abs(bmode)-1));
              result:=pGDBPointer(result)^;
              if bmode<0 then
                             bmode:=property_build;
         end;
end;
function TUserTypeDescriptor.CreatePD;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{CC044792-AE73-48C9-B10A-346BFE9E46C9}',{$ENDIF}result,sizeof(PropertyDeskriptor));
     PPropertyDeskriptor(result)^.initnul;
end;
function TUserTypeDescriptor.FindField(fn:TInternalScriptString):PFieldDescriptor;
begin
     result:=nil;
end;

{procedure TUserTypeDescriptor.IncAddr;
begin
     inc(pGDBByte(addr),SizeInGDBBytes);
end;}
constructor PropertyDeskriptor.initnul;
begin
     inherited;

    GDBPointer(Name):=nil;
    GDBPointer(Value):=nil;
    GDBPointer(ValKey):=nil;
    GDBPointer(ValType):=nil;
    GDBPointer(category):=nil;
    GDBPointer(r):=nil;
    GDBPointer(w):=nil;
    PTypeManager:=nil;
    Attr:=0;
    Collapsed:=nil;
    ValueOffsetInMem:=0;
    valueAddres:=nil;
    HelpPointer:=nil;
    Mode:=PDM_Field;
    _ppda:=nil;
    _bmode:=-1000;
end;
destructor PropertyDeskriptor.done;
begin
    Name:='';
    Value:='';
    ValKey:='';
    ValType:='';
    category:='';
    r:='';
    w:='';
    if mode=PDM_Property then
    if valueAddres<>nil then
                                 begin
                                      PTypeManager.MagicFreeInstance(valueAddres);
                                      GDBFreeMem(valueAddres);
                                 end;
    if SubNode<>nil then
    begin
         PTPropertyDeskriptorArray(SubNode)^.Done;
         gdbfreemem(GDBPointer(SubNode));
    end;
    if assigned(FastEditors) then
                                 freeandnil(FastEditors);
end;
function PropertyDeskriptor.IsVisible;
begin
     result:=((Attr and FA_HIDDEN_IN_OBJ_INSP)=0)or(debugShowHiddenFieldInObjInsp);
end;
procedure TPropertyDeskriptorArray.cleareraseobj;
var curr:PPropertyDeskriptor;
        ir:itrec;
begin
  curr:=beginiterate(ir);
  if curr<>nil then
  repeat
        if curr^.SubNode<>nil then
                                      PTPropertyDeskriptorArray(curr^.SubNode)^.cleareraseobj;
        if VerboseLog^ then
          DebugLn('{T}[ZSCRIPT]',curr^.Name,'=',curr^.Value);
        //programlog.LogOutStr(curr^.Name,0,LM_Trace);
        //programlog.LogOutStr('='+curr^.Value,0,LM_Trace);
        curr^.Name:='';
        curr^.Value:='';

        curr^.done;
        gdbfreemem(GDBPointer(curr));
        curr:=iterate(ir);
  until curr=nil;
  count:=0;
end;
function TPropertyDeskriptorArray.GetRealPropertyDeskriptorsCount:integer;
var curr:PPropertyDeskriptor;
    ir:itrec;
begin
  result:=0;
  curr:=beginiterate(ir);
  if curr<>nil then
  repeat
        if curr^.SubNode<>nil then
           result:=result+PTPropertyDeskriptorArray(curr^.SubNode)^.GetRealPropertyDeskriptorsCount
        else
           inc(result);
        curr:=iterate(ir);
  until curr=nil;
end;
function TPropertyDeskriptorArray.findcategory(category:TInternalScriptString):PPropertyDeskriptor;
var
   ir:itrec;
   ppd:PPropertyDeskriptor;
begin
     result:=nil;
     ppd:=beginiterate(ir);
     if ppd<>nil then
     repeat
           if ppd^.category=category then
           begin
                result:=ppd;
                exit;
           end;


           ppd:=iterate(ir);
     until ppd=nil;

end;
function TPropertyDeskriptorArray.findvalkey;
var
   ir:itrec;
   ppd:PPropertyDeskriptor;
begin
     result:=0;
     ppd:=beginiterate(ir);
     if ppd<>nil then
     repeat
           if ppd^.ValKey=valkey then
           begin
                result:=ir.itc+1;
                exit;
           end;


           ppd:=iterate(ir);
     until ppd=nil;

end;

begin
     zcpmode:=zcpbin;
end.
