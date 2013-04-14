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
unit TypeDescriptors;
{$INCLUDE def.inc}

interface
uses zcadsysvars,log,gdbasetypes,varmandef,gdbase,UGDBOpenArrayOfData,UGDBStringArray,memman,
      UGDBOpenArrayOfPointer,UGDBOpenArrayOfObjects,strproc,sysutils;
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
TPropertyDeskriptorArray=object(GDBOpenArrayOfGDBPointer)
                               procedure cleareraseobj;virtual;
                               function findcategory(category:GDBString):PPropertyDeskriptor;
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
GDBTOperandStoreMode=GDBByte;
GDBOperandDesc=record
                     PTD:PUserTypeDescriptor;
                     StoreMode:GDBTOperandStoreMode;
               end;
GDBMetodModifier=GDBWord;
PMetodDescriptor=^MetodDescriptor;
MetodDescriptor=object(GDBaseObject)
                      objname:GDBString;
                      MetodName:GDBString;
                      OperandsName:GDBString;
                      Operands:GDBOpenArrayOfdata; {DATA}
                      ResultPTD:PUserTypeDescriptor;
                      MetodAddr:GDBPointer;
                      Attributes:GDBMetodModifier;
                      punit:pointer;
                      NameHash:GDBLongword;
                      constructor init(objn,mn,dt:GDBString;ma:GDBPointer;attr:GDBMetodModifier;pu:pointer);
                      destructor Done;virtual;
                end;
PTUserTypeDescriptor=^TUserTypeDescriptor;
TUserTypeDescriptor=object(UserTypeDescriptor)
                          function CreateProperties(mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;abstract;
                          //procedure IncAddr(var addr:GDBPointer);virtual;
                          function CreatePD:GDBPointer;
                          function GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:GDBInteger):PPropertyDeskriptor;
                          function FindField(fn:GDBString):PFieldDescriptor;virtual;
                   end;
var zcpmode:tzcpmode;
    currpd:PPropertyDeskriptor;
implementation
uses varman,strmy;
destructor MetodDescriptor.Done;
begin
                      MetodName:='';
                      ObjName:='';
                      OperandsName:='';
                      Operands.done;
                      ResultPTD:=nil;
                      MetodAddr:=nil;
                      Attributes:=0;
                      punit:=nil;
end;
constructor MetodDescriptor.init;
var
  parseerror:GDBBoolean;
  parseresult{,subparseresult}:PGDBGDBStringArray;
  od:GDBOperandDesc;
  i:integer;
begin
     punit:=pu;
     GDBPointer(ObjName):=nil;
     GDBPointer(MetodName):=nil;
     GDBPointer(OperandsName):=nil;
     ResultPTD:=nil;
     ObjName:=objn;
     MetodName:=mn;
     NameHash:=makehash(uppercase(MetodName));
     OperandsName:=dt;
     if dt='(var obj):GDBInteger;' then
                                        dt:=dt;

     MetodAddr:=ma;
     Attributes:=attr;
     Operands.init({$IFDEF DEBUGBUILD}'{CC044792-AE73-48C9-B10A-346BFE9E46C9}',{$ENDIF}10,sizeof(GDBOperandDesc));
     parseresult:=runparser('_softspace'#0'=(_softspace'#0,dt,parseerror);
     if parseerror then
                       begin
                            repeat
                            od.PTD:=nil;
                            od.StoreMode:=SM_Default;
                            parseresult:=runparser('=v=a=r_softspace'#0,dt,parseerror);
                            if parseerror then
                                              od.StoreMode:=SM_Var;
                            parseresult:=runparser('_identifiers_cs'#0'=:_identifier'#0'_softspace'#0,dt,parseerror);
                            if parseerror then
                                              begin
                                                   od.PTD:=ptunit(punit).TypeName2PTD(parseresult^.getGDBString(parseresult.Count-1));
                                                   for i:=1 to parseresult.Count-1 do
                                                                                     Operands.Add(@od);
                                              end
                            else begin
                                      parseresult:=runparser('_identifiers_cs'#0'_softspace'#0,dt,parseerror);
                                      if parseerror then
                                              begin
                                                   od.PTD:=ptunit(punit).TypeName2PTD('GDBPointer');
                                                   for i:=1 to parseresult.Count do
                                                                                     Operands.Add(@od);
                                              end
                                 end;
                            if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;     
                            parseresult:=runparser('=;_softspace'#0,dt,parseerror);
                            until not parseerror;
                            parseresult:=runparser('=)_softspace'#0,dt,parseerror);
                       end;
     parseresult:=runparser('=:_softspace'#0'_identifier'#0,dt,parseerror);
     if parseerror then
                       begin
                            self.ResultPTD:=ptunit(punit).TypeName2PTD(parseresult^.getGDBString(0));
                       end;
     if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
     parseresult:=runparser('=:_softspace'#0'_identifier'#0'_softspace'#0,dt,parseerror);
     if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
     //parseresult:=runparser('_softspace'#0'=(_softspace'#0'_identifier'#0'_softspace'#0'=)',line,parseerror);

end;
function TUserTypeDescriptor.GetPPD(PPDA:PTPropertyDeskriptorArray;var bmode:GDBInteger):PPropertyDeskriptor;
begin
     if bmode=property_build
     then
         begin
              result:=CreatePD;
              PPDA^.add(@result);
         end
     else
         begin
              result:=ppda^.getelement(abs(bmode)-1);
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
function TUserTypeDescriptor.FindField(fn:GDBString):PFieldDescriptor;
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
         PTPropertyDeskriptorArray(SubNode)^.FreeAndDone;
         gdbfreemem(GDBPointer(SubNode));
    end;
end;
function PropertyDeskriptor.IsVisible;
begin
     result:=((Attr and FA_HIDDEN_IN_OBJ_INSP)=0)or(sysvar.MISC.ShowHiddenFieldInObjInsp^);
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
        {$IFDEF TOTALYLOG}programlog.LogOutStr(curr^.Name,0);
        programlog.LogOutStr('='+curr^.Value,0);{$ENDIF}
        curr^.Name:='';
        curr^.Value:='';

        curr^.done;
        gdbfreemem(GDBPointer(curr));
        curr:=iterate(ir);
  until curr=nil;
  count:=0;
end;
function TPropertyDeskriptorArray.findcategory(category:GDBString):PPropertyDeskriptor;
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
       {$IFDEF DEBUGINITSECTION}LogOut('TypeDescriptor.initialization');{$ENDIF}
     zcpmode:=zcpbin;
end.
