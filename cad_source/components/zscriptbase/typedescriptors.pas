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
unit typedescriptors;

{$MODE DELPHI}
interface
uses uzedimensionaltypes,{uzctnrVectorPointers,}LCLProc,
     varmandef,//uzctnrvectorstrings,
     gzctnrVectorTypes,gzctnrVectorP,uzbstrproc,sysutils,uzbLogIntf;
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
                               function findcategory(const category:TInternalScriptString):PPropertyDeskriptor;
                               function findvalkey(valkey:String):integer;
                         end;
SimpleProcOfObj=procedure of object;
SimpleProcOfObjDouble=procedure (arg:Double) of object;
SimpleFuncOfObjDouble=function:Double  of object;
PFieldDescriptor=^FieldDescriptor;
pBaseDescriptor=^BaseDescriptor;
BaseDescriptor=record
                      ProgramName:String;

                      UserName:String;

                      PFT:PUserTypeDescriptor;

                      {** Сделать строку только для чтения/редактр или скрыть/открыть итд.
                       Пример:
                       samplef:=sampleInternalRTTITypeDesk^.FindField('VNum'); находим описание поля VNum
                       samplef^.base.Attributes:=samplef^.base.Attributes and (not FA_HIDDEN_IN_OBJ_INSP); сбрасываем ему флаг cкрытности
                       samplef^.base.Attributes:=samplef^.base.Attributes or FA_HIDDEN_IN_OBJ_INSP; устанавливаем ему флаг cкрытности
                       }
                      Attributes:Word;

                      Saved:Word;
               end;

FieldDescriptor=record
                      base:BaseDescriptor;
                      //FieldName:String;
                      //UserName:String;
                      //PFT:PUserTypeDescriptor;
                      Offset,Size:Integer;
                      //Attributes:Word;
                      Collapsed:Boolean;
                end;
PPropertyDescriptor=^PropertyDescriptor;
PropertyDescriptor=record
                      base:BaseDescriptor;
                      //PropertyName:String;
                      //UserName:String;
                      r,w:String;
                      //PFT:PUserTypeDescriptor;
                      //Attributes:Word;
                      Collapsed:Boolean;
                end;
PTUserTypeDescriptor=^TUserTypeDescriptor;
TUserTypeDescriptor=object(UserTypeDescriptor)
                          function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;abstract;
                          //procedure IncAddr(var addr:Pointer);virtual;
                          function CreatePD:Pointer;
                          function GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:Integer):PPropertyDeskriptor;
                          function FindField(const fn:TInternalScriptString):PFieldDescriptor;virtual;
                   end;
var zcpmode:tzcpmode;
    //currpd:PPropertyDeskriptor;
    debugShowHiddenFieldInObjInsp:boolean=false;
implementation
uses strmy;
function TUserTypeDescriptor.GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:Integer):PPropertyDeskriptor;
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
              result:=pPointer(result)^;
              if bmode<0 then
                             bmode:=property_build;
         end;
end;
function TUserTypeDescriptor.CreatePD;
begin
     Getmem(result,sizeof(PropertyDeskriptor));
     PPropertyDeskriptor(result)^.initnul;
end;
function TUserTypeDescriptor.FindField(const fn:TInternalScriptString):PFieldDescriptor;
begin
     result:=nil;
end;

{procedure TUserTypeDescriptor.IncAddr;
begin
     inc(PByte(addr),SizeInBytes);
end;}
constructor PropertyDeskriptor.initnul;
begin
     inherited;

    Pointer(Name):=nil;
    Pointer(Value):=nil;
    Pointer(ValKey):=nil;
    Pointer(ValType):=nil;
    Pointer(category):=nil;
    Pointer(r):=nil;
    Pointer(w):=nil;
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
                                      Freemem(valueAddres);
                                 end;
    if SubNode<>nil then
    begin
         PTPropertyDeskriptorArray(SubNode)^.Done;
         Freemem(Pointer(SubNode));
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
        zTraceLn('{T}[ZSCRIPT]%s=%s',[curr^.Name,curr^.Value]);
        //programlog.LogOutStr(curr^.Name,0,LM_Trace);
        //programlog.LogOutStr('='+curr^.Value,0,LM_Trace);
        curr^.Name:='';
        curr^.Value:='';

        curr^.done;
        Freemem(Pointer(curr));
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
function TPropertyDeskriptorArray.findcategory(const category:TInternalScriptString):PPropertyDeskriptor;
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
