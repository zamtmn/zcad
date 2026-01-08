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
unit uzsbTypeDescriptors;

{$MODE DELPHI}
interface

uses
  SysUtils,
  uzsbVarmanDef,
  uzbUnits,
  gzctnrVectorTypes,gzctnrVectorP;

const
  m_procedure=1;
  m_function=2;
  m_constructor=4;
  m_destructor=8;
  m_virtual=16;
  field_no_attrib=nil;

  property_correct=1;
  property_build=0;

type
  PPropertyDeskriptor=^PropertyDeskriptor;

  PropertyDeskriptor=object(BasePropertyDeskriptor)
    constructor initnul;
    destructor done;virtual;
    function IsVisible(AShowEmptySections:boolean):boolean;
  end;
  PTPropertyDeskriptorArray=^TPropertyDeskriptorArray;

  TPropertyDeskriptorArray=object(GZVectorP<PPropertyDeskriptor>)
    procedure cleareraseobj;virtual;
    function GetRealPropertyDeskriptorsCount:integer;virtual;
    function findcategory(
      const category:TInternalScriptString):PPropertyDeskriptor;
    function findvalkey(valkey:string):integer;
  end;
  SimpleProcOfObj=procedure of object;
  SimpleProcOfObjDouble=procedure(arg:double) of object;
  SimpleFuncOfObjDouble=function :double of object;
  PFieldDescriptor=^FieldDescriptor;
  pBaseDescriptor=^BaseDescriptor;

  BaseDescriptor=record
    ProgramName:string;

    UserName:string;

    PFT:PUserTypeDescriptor;

    {** Сделать строку только для чтения/редактр или скрыть/открыть итд.
    Пример:
    samplef:=sampleInternalRTTITypeDesk^.FindField('VNum'); находим описание поля VNum
    samplef^.base.Attributes:=samplef^.base.Attributes and (not fldaHidden); сбрасываем ему флаг cкрытности
    samplef^.base.Attributes:=samplef^.base.Attributes or fldaHidden; устанавливаем ему флаг cкрытности
    }
    Attributes:TFieldAttrs;

    Saved:word;//todo убрать нахер
    constructor create(APN,AUN:string;ATD:PUserTypeDescriptor;AAttrs:TFieldAttrs);
  end;

  FieldDescriptor=record
    base:BaseDescriptor;
    Offset,Size:integer;
    Collapsed:boolean;
  end;
  PPropertyDescriptor=^PropertyDescriptor;

  PropertyDescriptor=record
    base:BaseDescriptor;
    //PropertyName:String;
    //UserName:String;
    r,w:string;
    //PFT:PUserTypeDescriptor;
    //Attributes:Word;
    Collapsed:boolean;
  end;
  PTUserTypeDescriptor=^TUserTypeDescriptor;

  TUserTypeDescriptor=object(UserTypeDescriptor)
    function CreateProperties(
      const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;
      const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:TFieldAttrs;
      var bmode:integer;const addr:Pointer;
      const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;abstract;
    //procedure IncAddr(var addr:Pointer);virtual;
    function CreatePD:Pointer;
    function GetPPD(PPDA:PTPropertyDeskriptorArray;
      var bmode:integer):PPropertyDeskriptor;
    function FindField(
      const fn:TInternalScriptString):PFieldDescriptor;virtual;
  end;

var
  debugShowHiddenFieldInObjInsp:boolean=False;

implementation

constructor BaseDescriptor.create(APN,AUN:string;ATD:PUserTypeDescriptor;AAttrs:TFieldAttrs);
begin
  ProgramName:=APN;
  UserName:=AUN;
  PFT:=ATD;
  Attributes:=AAttrs;
  Saved:=0;
end;

function TUserTypeDescriptor.GetPPD(PPDA:PTPropertyDeskriptorArray;
  var bmode:integer):PPropertyDeskriptor;
begin
  if bmode=property_build then begin
    Result:=CreatePD;
    PPDA^.PushBackData(Result);
  end else begin
    Result:=pointer(ppda^.getDataMutable(abs(bmode)-1));
    Result:=pPointer(Result)^;
    if bmode<0 then
      bmode:=property_build;
  end;
end;

function TUserTypeDescriptor.CreatePD;
begin
  Getmem(Result,sizeof(PropertyDeskriptor));
  PPropertyDeskriptor(Result)^.initnul;
end;

function TUserTypeDescriptor.FindField(const fn:TInternalScriptString):PFieldDescriptor;
begin
  Result:=nil;
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
  Attr:=[];
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
    if valueAddres<>nil then begin
      PTypeManager.MagicFreeInstance(valueAddres);
      Freemem(valueAddres);
    end;
  if SubNode<>nil then begin
    PTPropertyDeskriptorArray(SubNode)^.Done;
    Freemem(Pointer(SubNode));
  end;
  if assigned(FastEditors) then
    FreeAndNil(FastEditors);
end;

function PropertyDeskriptor.IsVisible(AShowEmptySections:boolean):boolean;
begin
  Result:=(not(fldaHidden in Attr))or(debugShowHiddenFieldInObjInsp);
  Result:=Result and ((not(fldaTmpHidden in Attr))or(AShowEmptySections));
end;

procedure TPropertyDeskriptorArray.cleareraseobj;
var
  curr:PPropertyDeskriptor;
  ir:itrec;
begin
  curr:=beginiterate(ir);
  if curr<>nil then
    repeat
      if curr^.SubNode<>nil then
        PTPropertyDeskriptorArray(curr^.SubNode)^.cleareraseobj;
      curr^.Name:='';
      curr^.Value:='';

      curr^.done;
      Freemem(Pointer(curr));
      curr:=iterate(ir);
    until curr=nil;
  Count:=0;
end;

function TPropertyDeskriptorArray.GetRealPropertyDeskriptorsCount:integer;
var
  curr:PPropertyDeskriptor;
  ir:itrec;
begin
  Result:=0;
  curr:=beginiterate(ir);
  if curr<>nil then
    repeat
      if curr^.SubNode<>nil then
        Result:=Result+PTPropertyDeskriptorArray(
          curr^.SubNode)^.GetRealPropertyDeskriptorsCount
      else
        Inc(Result);
      curr:=iterate(ir);
    until curr=nil;
end;

function TPropertyDeskriptorArray.findcategory(
  const category:TInternalScriptString):PPropertyDeskriptor;
var
  ir:itrec;
  ppd:PPropertyDeskriptor;
begin
  Result:=nil;
  ppd:=beginiterate(ir);
  if ppd<>nil then
    repeat
      if ppd^.category=category then begin
        Result:=ppd;
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
  Result:=0;
  ppd:=beginiterate(ir);
  if ppd<>nil then
    repeat
      if ppd^.ValKey=valkey then begin
        Result:=ir.itc+1;
        exit;
      end;


      ppd:=iterate(ir);
    until ppd=nil;

end;

begin
end.
