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

unit Varman;
{$INCLUDE def.inc}
{$MODE DELPHI}

interface
uses
  UEnumDescriptor,uzctnrvectorgdbpointer,gzctnrvectordata,gzctnrvectorpobjects,LCLProc,uabstractunit,
  SysUtils,UBaseTypeDescriptor,uzbtypesbase,uzbtypes,UGDBOpenArrayOfByte,
  gzctnrvectortypes,uzctnrvectorgdbstring,varmandef,gzctnrstl,uzbmemman,
  TypeDescriptors,URecordDescriptor,UObjectDescriptor,uzbstrproc,classes,typinfo,UPointerDescriptor,
  uzctnrobjectschunk;
type
    td=record
             template:GDBString;
             id:GDBInteger;
       end;
    ptdarray=^tdarray;
    tdarray=array [1..maxint div sizeof(td)] of td;
    pasparsemode=(modeOk,modeError,modeEnd);
    penumodj=^tenumodj;
    tenumodj=record
                  source,user:GDBString;
                  value:GDBLongword;
            end;
const
     SuffLeft='_Left';
     SuffTop='_Top';
     SuffWidth='_Width';
     SuffHeight='_Height';
     identtype=1;
     ptype=2;
     recordtype=3;
     objecttype=4;
     arraytype=5;
     enumtype=6;
     proceduraltype=7;
     variablecategory=8;
     packedrecordtype=9;
     packedobjecttype=10;
     packedarraytype=11;
     maxtype=11;
     parsetype:array [1..maxtype] of td=
     (
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'_identifier'#0'_softend'#0;id:identtype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=^_identifier'#0'_softend'#0;id:ptype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=r=e=c=o=r=d_hardspace'#0;id:recordtype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=p=a=c=k=e=d_hardspace'#0'=r=e=c=o=r=d_hardspace'#0;id:packedrecordtype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=o=b=j=e=c=t_endlexem'#0'_softspace'#0;id:objecttype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=p=a=c=k=e=d_hardspace'#0'=o=b=j=e=c=t_endlexem'#0'_softspace'#0;id:packedobjecttype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=a=r=r=a=y_softspace'#0;id:arraytype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=p=a=c=k=e=d_hardspace'#0'=a=r=r=a=y_softspace'#0;id:packedarraytype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=p=r=o=c=e=d=u=r=e_hardspace'#0;id:proceduraltype),
      (template:'_identifier'#0'_softspace'#0'==_softspace'#0'=(_softspace'#0;id:enumtype),
      (template:'_softspace'#0'=(=*=v=a=r=c=a=t=e=g=o=r=y=f=o=r=o=i_softspace'#0'_identifier'#0'==_GDBString'#0'=*=)';id:variablecategory)
      );
     functionmember=1;
     proceduremember=2;
     constructormember=3;
     destructormember=4;
     membermodifier=5;
     field=6;
     objend=7;
     oi_readonly=8;
     savedtoshd=9;
     username=10;
     oi_hidden=11;
     oaod=12;
     oaopo=13;
     propertymember=14;
     maxobjmember=15;
     parseobjmember:array [1..maxobjmember] of td=
     (
      (template:'_softspace'#0'=(=*=O=p=e=n=A=r=r=a=y=O=f=P=O=b=j=*=)';id:oaopo),
      (template:'_softspace'#0'=(=*=O=p=e=n=A=r=r=a=y=O=f=D=a=t=a==_identifier'#0'=*=)';id:oaod),
      (template:'_softspace'#0'=p=r=o=c=e=d=u=r=e_hardspace'#0;id:proceduremember),
      (template:'_softspace'#0'=f=u=n=c=t=i=o=n_hardspace'#0;id:functionmember),
      (template:'_softspace'#0'=c=o=n=s=t=r=u=c=t=o=r_hardspace'#0;id:constructormember),
      (template:'_softspace'#0'=d=e=s=t=r=u=c=t=o=r_hardspace'#0;id:destructormember),
      (template:'_softspace'#0'=a=b=s=t=r=a=c=t_softend'#0;id:membermodifier),
      (template:'_softspace'#0'=v=i=r=t=u=a=l_softend'#0;id:membermodifier),
      (template:'_softspace'#0'=(=*=o=i=_=r=e=a=d=o=n=l=y=*=)';id:oi_readonly),
      (template:'_softspace'#0'=(=*=s=a=v=e=d=_=t=o=_=s=h=d=*=)';id:savedtoshd),
      (template:'_softspace'#0'=(=*=h=i=d=d=e=n=_=i=n=_=o=b=j=i=n=s=p=*=)';id:oi_hidden),
      (template:'_identifiers_cs'#0'=:_identifier'#0'_softend'#0;id:field),
      (template:'_softspace'#0'=e=n=d_softspace'#0'=;';id:objend),
      (template:'_softspace'#0'=(=*_GDBString'#0'=*=)';id:username),
      (template:'_softspace'#0'=p=r=o=p=e=r=t=y_hardspace'#0;id:propertymember)
      );
     varmode=1;
     typemode=2;
     unitmode=3;
     beginmode=4;
     endmode=5;
     impl=6;
     interf=7;
     usesmode=8;
     subunitmode=9;
     usescopymode=10;
     proceduremode=11;
     functionmode=12;
     maxparsemodetemplate=12;
     parsemodetemplate:array [1..maxparsemodetemplate] of td=
     (
     (template:'_softspace'#0'=i=m=p=l=e=m=e=n=t=a=t=i=o=n_hardspace'#0;id:impl),
     (template:'_softspace'#0'=u=s=e=s_hardspace'#0;id:usesmode),
     (template:'_softspace'#0'=i=n=t=e=r=f=a=c=e_hardspace'#0;id:interf),
     (template:'_softspace'#0'=v=a=r_hardspace'#0;id:varmode),
     (template:'_softspace'#0'=t=y=p=e_hardspace'#0;id:typemode),
     (template:'_softspace'#0'=u=n=i=t_hardspace'#0;id:unitmode),
     (template:'_softspace'#0'=s=u=b=u=n=i=t_hardspace'#0;id:subunitmode),
     (template:'_softspace'#0'=u=s=e=s=c=o=p=y_hardspace'#0;id:usescopymode),
     (template:'_softspace'#0'=b=e=g=i=n_hardspace'#0;id:beginmode),
     (template:'_softspace'#0'=e=n=d_softspace'#0'=.';id:endmode),
     (template:'_softspace'#0'=p=r=o=c=e=d=u=r=e_hardspace'#0;id:proceduremode),
     (template:'_softspace'#0'=f=u=n=c=t=i=o=n_hardspace'#0;id:functionmode)
     );
     mod_virtual=1;
     mod_abstract=2;
     maxmod=2;
     parsefuncmodss:array [1..maxmod] of td=
     (
      (template:'_softspace'#0'=v=i=r=t=u=a=l'+'_softspace'#0+'=;';id:mod_virtual),
      (template:'_softspace'#0'=a=b=s=t=r=a=c=t'+'_softspace'#0+'=;';id:mod_abstract)
      );
type
TNameToIndex=TMyGDBAnsiStringDictionary<TArrayIndex>;
TFieldName=(FNUser,FNProgram);
TFieldNames=set of TFieldName;
{EXPORT+}
ptypemanager=^typemanager;
{REGISTEROBJECTTYPE typemanager}
typemanager=object(typemanagerdef)
                  protected
                  n2i:TNameToIndex;
                  public
                  exttype:TZctnrVectorPGDBaseObjects;
                  constructor init;
                  procedure CreateBaseTypes;virtual;
                  function _TypeName2PTD(name: TInternalScriptString):PUserTypeDescriptor;virtual;
                  function _ObjectTypeName2PTD(name: TInternalScriptString):PObjectDescriptor;virtual;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;
                  destructor done;virtual;
                  destructor systemdone;virtual;
                  procedure free;virtual;
                  {for hide exttype}
                  function getDataMutable(index:TArrayIndex):GDBPointer;virtual;
                  function getcount:TArrayIndex;virtual;
                  function AddTypeByPP(p:GDBPointer):TArrayIndex;virtual;
                  function AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;virtual;
            end;
Tvardescarray=GZVectorData{-}<vardesk>{//};
{REGISTEROBJECTTYPE varmanager}
pvarmanager=^varmanager;
varmanager=object(varmanagerdef)
            vardescarray:{GDBOpenArrayOfData}Tvardescarray;
            vararray:{GDBOpenArrayOfByte}TObjectsChunk;
                 constructor init;
                 function findvardesc(varname:TInternalScriptString): pvardesk;virtual;
                 function findvardescbyinst(varinst:GDBPointer):pvardesk;virtual;
                 function findvardescbytype(pt:PUserTypeDescriptor):pvardesk;virtual;
                 function createvariable(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0): pvardesk;virtual;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBInteger;var tc:PUserTypeDescriptor; nam: ShortString): GDBBoolean;virtual;
                 destructor done;virtual;
                 procedure free;virtual;
           end;
TunitPart=(TNothing,TInterf,TImpl,TProg);
PTUnit=^TUnit;
PTSimpleUnit=^TSimpleUnit;
{REGISTEROBJECTTYPE TSimpleUnit}
TSimpleUnit=object(TAbstractUnit)
                  Name:TInternalScriptString;
                  InterfaceUses:TZctnrVectorGDBPointer;
                  InterfaceVariables: varmanager;
                  constructor init(nam:TInternalScriptString);
                  destructor done;virtual;
                  function CreateVariable(varname,vartype:TInternalScriptString;_pinstance:pointer=nil):GDBPointer;virtual;
                  function FindVariable(varname:TInternalScriptString):pvardesk;virtual;
                  function FindVariableByInstance(_Instance:GDBPointer):pvardesk;virtual;
                  function FindValue(varname:TInternalScriptString):GDBPointer;virtual;
                  function FindOrCreateValue(varname,vartype:TInternalScriptString):GDBPointer;virtual;
                  function TypeName2PTD(n: TInternalScriptString):PUserTypeDescriptor;virtual;
                  function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;
                  function SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  procedure setvardesc(out vd: vardesk; varname, username, typename: TInternalScriptString;_pinstance:pointer=nil);
                  procedure free;virtual;abstract;
                  procedure CopyTo(source:PTSimpleUnit);virtual;
                  procedure CopyFrom(source:PTSimpleUnit);virtual;
            end;
PTObjectUnit=^TObjectUnit;
{REGISTEROBJECTTYPE TObjectUnit}
TObjectUnit=object(TSimpleUnit)
                  //function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;
                  procedure free;virtual;
            end;
{REGISTEROBJECTTYPE TUnit}
TUnit=object(TSimpleUnit)
            InterfaceTypes:typemanager;
            //ImplementationUses:GDBInteger;
            ImplementationTypes:typemanager;
            ImplementationVariables: varmanager;

            constructor init(nam:TInternalScriptString);
            function TypeIndex2PTD(ind:GDBinteger):PUserTypeDescriptor;virtual;
            function TypeName2PTD(n: TInternalScriptString):PUserTypeDescriptor;virtual;
            function ObjectTypeName2PTD(n: TInternalScriptString):PObjectDescriptor;virtual;
            function AssignToSymbol(var psymbol;symbolname:TInternalScriptString):GDBInteger;
            function SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;
            destructor done;virtual;
            procedure free;virtual;
            function RegisterType(ti:PTypeInfo):PUserTypeDescriptor;
            function SetTypeDesk(ti:PTypeInfo;fieldnames:array of const;SetNames:TFieldNames=[FNUser,FNProgram]):PUserTypeDescriptor;
            function RegisterRecordType(ti:PTypeInfo):PUserTypeDescriptor;
            function RegisterPointerType(ti:PTypeInfo):PUserTypeDescriptor;
            function RegisterEnumType(ti:PTypeInfo):PUserTypeDescriptor;
      end;
{EXPORT-}
TOnCreateSystemUnit=procedure (ptsu:PTUnit);
procedure vardeskclear(const p:pvardesk);
var
  OnCreateSystemUnit:TOnCreateSystemUnit=nil;
  SysUnit:PTUnit=nil;
  SysVarUnit:PTUnit=nil;
  SavedUnit,DBUnit,DWGDBUnit,DWGUnit:PTUnit;
  BaseTypesEndIndex:GDBInteger;
  OldTypesCount:GDBInteger;
  VarCategory:TZctnrVectorGDBString;
  CategoryCollapsed:GDBOpenArrayOfByte;
  CategoryUnknownCOllapsed:boolean;

function getpattern(ptd:ptdarray; max:GDBInteger;var line:TInternalScriptString; out typ:GDBInteger):PTZctnrVectorGDBString;
function ObjOrRecordRead(TranslateFunc:TTranslateFunction;var f: GDBOpenArrayOfByte; var line,GDBStringtypearray:TInternalScriptString; var fieldoffset: GDBSmallint; ptd:PRecordDescriptor):GDBBoolean;
function GetPVarMan: GDBPointer; export;
function FindCategory(category:TInternalScriptString;var catname:TInternalScriptString):Pointer;
procedure SetCategoryCollapsed(category:TInternalScriptString;value:GDBBoolean);
function GetBoundsFromSavedUnit(name:string;w,h:integer):Trect;
procedure StoreBoundsToSavedUnit(name:string;tr:Trect);
procedure SetTypedDataVariable(out TypedTataVariable:TTypedData;pTypedTata:pointer;TypeName:string);
function GetIntegerFromSavedUnit(name,suffix:string;def,min,max:integer):integer;
procedure StoreIntegerToSavedUnit(name,suffix:string;value:integer);
implementation
uses strmy;

procedure SetTypedDataVariable(out TypedTataVariable:TTypedData;pTypedTata:pointer;TypeName:string);
var
  ptd:PUserTypeDescriptor;
begin
  ptd:=nil;
  if assigned(SysUnit) then
                           ptd:=SysUnit^.TypeName2PTD(TypeName);
  if ptd<>nil then
                  begin
                       TypedTataVariable.Instance:=pTypedTata;
                       TypedTataVariable.PTD:=ptd;
                  end
              else
              begin
                   TypedTataVariable.Instance:=pTypedTata;
                    TypedTataVariable.PTD:=nil;
              end
end;
function setfrominterval(value,vmin,vmax:integer):integer;
begin
     if (value<vmin)or(value>vmax)then
                                      result:=vmin
                                  else
                                      result:=value;
end;
function GetIntegerFromSavedUnit(name,suffix:string;def,min,max:integer):integer;
var
   pint:PGDBInteger;
begin
  pint:=SavedUnit.FindValue(name+suffix);
  if assigned(pint)then begin
    result:=pint^;
    result:=setfrominterval(result,min,max);
  end else
    result:=def;
end;
procedure StoreIntegerToSavedUnit(name,suffix:string;value:integer);
var
   pint:PGDBInteger;
   vn:TInternalScriptString;
begin
     vn:=name+suffix;
     pint:=SavedUnit.FindValue(vn);
     if not assigned(pint)then
                              pint:=SavedUnit.CreateVariable(vn,'GDBInteger');
     pint^:=value;
end;

function GetBoundsFromSavedUnit(name:string;w,h:integer):Trect;
var
   pint:PGDBInteger;
begin
     result:=rect(0,0,100,100);
     pint:=SavedUnit.FindValue(name+SuffLeft);
     if assigned(pint)then
                          result.Left:=pint^;
     result.Left:=setfrominterval(result.Left,0,w);
     pint:=SavedUnit.FindValue(name+SuffTop);
     if assigned(pint)then
                          result.Top:=pint^;
     result.Top:=setfrominterval(result.Top,0,h);
     pint:=SavedUnit.FindValue(name+SuffWidth);
     if assigned(pint)then
                          result.Right:=result.Left+pint^;
     pint:=SavedUnit.FindValue(name+SuffHeight);
     if assigned(pint)then
                          result.Bottom:=result.Top+pint^;
end;
procedure StoreBoundsToSavedUnit(name:string;tr:Trect);
var
   pint:PGDBInteger;
   vn:TInternalScriptString;
begin
     vn:=name+SuffLeft;
     pint:=SavedUnit.FindValue(vn);
     if not assigned(pint)then
                              pint:=SavedUnit.CreateVariable(vn,'GDBInteger');
     pint^:=tr.Left;
     vn:=name+SuffTop;
     pint:=SavedUnit.FindValue(vn);
     if not assigned(pint)then
                              pint:=SavedUnit.CreateVariable(vn,'GDBInteger');
     pint^:=tr.Top;
     vn:=name+SuffWidth;
     pint:=SavedUnit.FindValue(vn);
     if not assigned(pint)then
                              pint:=SavedUnit.CreateVariable(vn,'GDBInteger');
     pint^:=tr.Right-tr.Left;
     vn:=name+SuffHeight;
     pint:=SavedUnit.FindValue(vn);
     if not assigned(pint)then
                              pint:=SavedUnit.CreateVariable(vn,'GDBInteger');
     pint^:=tr.Bottom-tr.Top;
end;
procedure TSimpleUnit.CopyTo;
var
   pu:PTUnit;
   pv:pvardesk;
   vd: vardesk;
   ir:itrec;
//   value:TInternalScriptString;
begin
     pu:=InterfaceUses.beginiterate(ir);
     if pu<>nil then
                    repeat
                          source.InterfaceUses.PushBackIfNotPresent(pu);
                          pu:=InterfaceUses.iterate(ir);
                    until pu=nil;
     pv:=InterfaceVariables.vardescarray.beginiterate(ir);
      if pv<>nil then
        repeat
              source^.setvardesc(vd,pv^.name,pv^.username,pv^.data.ptd^.TypeName);
              source^.InterfaceVariables.createvariable(vd.name, vd);
              pv^.data.ptd^.CopyInstanceTo(pv^.data.Instance,vd.data.Instance);
              pv:=InterfaceVariables.vardescarray.iterate(ir);
        until pv=nil;
end;
procedure TSimpleUnit.CopyFrom;
var
   pu:PTUnit;
   pv:pvardesk;
   vd: vardesk;
   ir:itrec;
//   value:TInternalScriptString;
begin
     pu:=source.InterfaceUses.beginiterate(ir);
     if pu<>nil then
                    repeat
                          InterfaceUses.PushBackIfNotPresent(pu);
                          pu:=source.InterfaceUses.iterate(ir);
                    until pu=nil;
     pv:=source.InterfaceVariables.vardescarray.beginiterate(ir);
      if pv<>nil then
        repeat
              setvardesc(vd,pv^.name,pv^.username,pv^.data.ptd^.TypeName);
              InterfaceVariables.createvariable(vd.name, vd);
              pv^.data.ptd^.CopyInstanceTo(pv^.data.Instance,vd.data.Instance);
              pv:=source.InterfaceVariables.vardescarray.iterate(ir);
        until pv=nil;
end;
function TUnit.RegisterRecordType(ti:PTypeInfo):PUserTypeDescriptor;
var
   td:PTypeData;
   mf: PManagedField;
   i:integer;
   etd:PRecordDescriptor;
   fd:FieldDescriptor;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{874DEDEF-E023-4558-A3C6-392D9C3B23C9}',{$ENDIF}GDBPointer(etd),sizeof(RecordDescriptor));
     PRecordDescriptor(etd)^.init(ti^.Name,@self);
     td:=GetTypeData(ti);
     mf:=@td.ManagedFldCount;
     inc(pointer(mf),sizeof(td.ManagedFldCount));
     for i:=0 to td.ManagedFldCount-1 do
     begin
          ti:=mf.TypeRef;


          fd.base.ProgramName:=ti.Name;
          fd.base.PFT:=RegisterType(ti);;
          fd.base.Attributes:=0;
          fd.base.Saved:=0;
          fd.Collapsed:=true;
          fd.Offset:=mf.FldOffset;
          if fd.base.PFT<>nil then
                             fd.Size:=fd.base.PFT^.SizeInGDBBytes
                         else
                             fd.Size:=1;
          etd^.AddField(fd);

          inc(mf);
     end;
     etd^.SizeInGDBBytes:=td.RecSize;
     InterfaceTypes.AddTypeByPP(@etd);
     result:=etd;
end;
function TUnit.RegisterPointerType(ti:PTypeInfo):PUserTypeDescriptor;
var
   td:PTypeData;
   mf: PManagedField;
   i:integer;
   etd:PGDBPointerDescriptor;
   fd:FieldDescriptor;
begin
     td:=GetTypeData(ti);
     gdbgetmem({$IFDEF DEBUGBUILD}'{EB691608-9520-4E6F-9042-960EFE61FA89}',{$ENDIF}GDBPointer(etd),sizeof(GDBPointerDescriptor));
     etd^.init(td.RefType^.Name,ti^.Name,@self);
     etd^.TypeOf:=RegisterType(td.RefType);
     InterfaceTypes.AddTypeByPP(@etd);
     result:=etd;
end;
function TUnit.RegisterEnumType(ti:PTypeInfo):PUserTypeDescriptor;
var
   td:PTypeData;
   etd:PEnumDescriptor;
   bytessize:integer;

  procedure SetEnumData(TypeInfo : PTypeInfo);
  var PS : PShortString;
      PT : PTypeData;
      Count:Integer;
  begin
    PT:=GetTypeData(TypeInfo);
    PS:=@PT^.NameList;
    Count:=PT^.MinValue;
    While (PByte(PS)^<>0)and(Count<=PT^.MaxValue) do
      begin
        etd^.SourceValue.PushBackData(PS^);
        etd^.UserValue.PushBackData(PS^);
        etd^.Value.PushBackData(Count);

        PS:=PShortString(pointer(PS)+PByte(PS)^+1);
        Inc(Count);
      end;
  end;

begin
     td:=GetTypeData(ti);
     gdbgetmem({$IFDEF DEBUGBUILD}'{EB691608-9520-4E6F-9042-960EFE61FA89}',{$ENDIF}GDBPointer(etd),sizeof(EnumDescriptor));
     case td.OrdType of
        otSByte:bytessize:=1;
        otUByte:bytessize:=1;
        otSWord:bytessize:=2;
        otUWord:bytessize:=2;
        otSLong:bytessize:=4;
        otULong:bytessize:=4;
     end;
     etd^.init(bytessize,ti^.Name,@self);
     SetEnumData(ti);
     InterfaceTypes.AddTypeByPP(@etd);
     result:=etd;
end;
function TUnit.RegisterType(ti:PTypeInfo):PUserTypeDescriptor;
begin
   result:=TypeName2PTD(ti^.Name);
   if result=nil then
     case ti^.Kind of
       tkRecord:result:=RegisterRecordType(ti);
       tkPointer:result:=RegisterPointerType(ti);
       tkEnumeration:result:=RegisterEnumType(ti);
     end;
end;
function TUnit.SetTypeDesk(ti:PTypeInfo;fieldnames:array of const;SetNames:TFieldNames=[FNUser,FNProgram]):PUserTypeDescriptor;
function GetFieldName(index:integer;oldname:string):string;
begin
  if index>high(fieldnames) then
                            begin
                              result:=oldname;
                              exit;
                            end;
  case fieldnames[index].VType of
                    vtString:result:=fieldnames[index].VString^;
                    vtChar:result:=fieldnames[index].VChar;
                vtAnsiString:result:=ansistring(fieldnames[index].VAnsiString);
                else
                  result:=oldname;
  end;{case}
end;
var
    i:integer;
begin
  result:=TypeName2PTD(ti^.Name);
  if result<>nil then
    case ti^.Kind of
      tkRecord:
      begin
        for i:=0 to PRecordDescriptor(result)^.Fields.Count-1 do begin
          if FNUser in SetNames then
            PRecordDescriptor(result)^.Fields.PArray^[i].base.UserName:=GetFieldName(i,PRecordDescriptor(result)^.Fields.PArray^[i].base.UserName);
          if FNProgram in SetNames then
            PRecordDescriptor(result)^.Fields.PArray^[i].base.ProgramName:=GetFieldName(i,PRecordDescriptor(result)^.Fields.PArray^[i].base.UserName);
        end;
      end;
      tkEnumeration:
      begin
        for i:=0 to PEnumDescriptor(result)^.UserValue.Count-1 do begin
          if FNUser in SetNames then
            PEnumDescriptor(result)^.UserValue.PArray^[i]:=GetFieldName(i,PEnumDescriptor(result)^.UserValue.PArray^[i]);
          if FNProgram in SetNames then
            PEnumDescriptor(result)^.SourceValue.PArray^[i]:=GetFieldName(i,PEnumDescriptor(result)^.SourceValue.PArray^[i]);
        end;
      end;
    end;
end;

procedure TObjectUnit.free;
begin
     self.InterfaceUses.clear;
     self.InterfaceVariables.vardescarray.Freewithproc(vardeskclear);
     //self.InterfaceVariables.vardescarray.Clear;
     self.InterfaceVariables.vararray.Clear;
end;
function TSimpleUnit.SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;
var
   pu:PTUnit;
   pv:pvardesk;
   ir:itrec;
   value:TInternalScriptString;
begin
     membuf.TXTAddGDBStringEOL('unit '+Name+';');
     membuf.TXTAddGDBStringEOL('interface');
     if InterfaceUses.Count<>0 then
        begin
             pu:=InterfaceUses.beginiterate(ir);
             if pu<>nil then
                            begin
                                 membuf.TXTAddGDBString('uses '+pu^.Name);
                            end;
             pu:=InterfaceUses.iterate(ir);
                          if pu<>nil then
                            repeat
                                 membuf.TXTAddGDBString(','+pu^.Name);
                                 pu:=InterfaceUses.iterate(ir);
                            until pu=nil;
            membuf.TXTAddGDBStringEOL(';');
        end;
     if InterfaceVariables.vardescarray.Count<>0 then
        begin
              membuf.TXTAddGDBStringEOL('var');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 membuf.TXTAddGDBString('  '+pv^.name+':');
                                 membuf.TXTAddGDBString(pv.data.PTD.TypeName+';');
                                 if pv^.username<>'' then membuf.TXTAddGDBString('(*'''+pv^.username+'''*)');
                                 membuf.TXTAddGDBStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
        end;
        begin
              membuf.TXTAddGDBStringEOL('implementation');
              membuf.TXTAddGDBStringEOL('begin');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 //membuf.TXTAddGDBString('  '+pv^.name+':=');
                                 pv.data.PTD.SavePasToMem(membuf,pv.data.Instance,'  '+pv^.name);
                                 {value:=pv.data.PTD.GetValueAsString(pv.data.Instance);
                                 if pv.data.PTD=@FundamentalStringDescriptorObj then
                                             value:=''''+value+'''';

                                 membuf.TXTAddGDBString(value+';');}
                                 //membuf.TXTAddGDBStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
            membuf.TXTAddGDBString('end.');
        end;
end;
{function getpsysvar: GDBPointer; export;
begin
  result := @sysvar;
end;}
function GetPVarMan: GDBPointer; export;
begin
  result := @SysUnit.InterfaceVariables;
end;
procedure vardeskclear(const p:pvardesk);
//var
   //s:string;
begin
     if VerboseLog^ then
       DebugLn(format('{T}[ZSCRIPT]vardeskclear: "%s"',[pvardesk(p)^.name]));
     //programlog.LogOutFormatStr('vardeskclear: "%s"',[pvardesk(p)^.name],lp_OldPos,LM_Trace);
     if pvardesk(p)^.name='_EQ_C2000_KPB' then
     pvardesk(p)^.name:=pvardesk(p)^.name;

     //s:=pvardesk(p)^.name;

     pvardesk(p)^.name:='';
     pvardesk(p)^.username:='';

     pvardesk(p)^.data.ptd^.MagicFreeInstance(pvardesk(p)^.data.Instance);

     //if pvardesk(p)^.data.ptd=@FundamentalStringDescriptorObj then
       //                                                   pgdbstring(pvardesk(p)^.data.Instance)^:='';
     pvardesk(p)^.data.ptd:=nil;
     //gdbfreemem(pvardesk(p)^.pvalue);
end;
procedure varmanager.free;
begin
     vardescarray.freewithproc(vardeskclear);
end;
destructor typemanager.done;
begin
     if VerboseLog^ then
       DebugLn('{T+}[ZSCRIPT]TypeManager.done');
     //programlog.LogOutStr('TypeManager.done',lp_IncPos,LM_Trace);
     exttype.free;
     exttype.done;
     n2i.destroy;
     if VerboseLog^ then
       DebugLn('{T-}[ZSCRIPT]TypeManager.done;//end');
     //programlog.LogOutStr('end;',lp_DecPos,LM_Trace);
end;
destructor typemanager.systemdone;
begin
     if VerboseLog^ then
       DebugLn('{T+}[ZSCRIPT]TypeManager.systemdone;');
     //programlog.LogOutStr('TypeManager.systemdone',lp_IncPos,LM_Trace);
     exttype.cleareraseobjfrom(BaseTypesEndIndex-1);
     exttype.done;
     n2i.destroy;
     if VerboseLog^ then
       DebugLn('{T-}[ZSCRIPT]TypeManager.systemdone;//end');
     //programlog.LogOutStr('end;',lp_DecPos,LM_Trace);
end;

procedure typemanager.free;
begin
     exttype.cleareraseobjfrom(BaseTypesEndIndex);
end;
function typemanager._TypeIndex2PTD;
begin
  result:=PUserTypeDescriptor(exttype.getDataMutable(ind));
end;
function typemanager.getDataMutable(index:TArrayIndex):GDBPointer;
begin
     result:=exttype.getDataMutable(index);
end;
function typemanager.getcount:TArrayIndex;
begin
     result:=exttype.count;
end;
function typemanager.AddTypeByPP(p:GDBPointer):TArrayIndex;
var
  pt:PUserTypeDescriptor;
begin
     result:=exttype.PushBackData(ppointer(p)^);
     pt:=ppointer(p)^;
     n2i.insert(uppercase(pt^.TypeName),result);
end;
function typemanager.AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;
var
   p:pointer;
begin
     p:=@_type;
     result:=AddTypeByPP(@p);
end;
function typemanager._TypeName2PTD;
var
  {tp:PUserTypeDescriptor;
  ir:itrec;
  S:TInternalScriptString;}
  rr:tarrayindex;
begin
  if n2i.MyGetValue(uppercase(name),rr) then
  begin
       result:=_TypeIndex2PTD(rr);
  end
  else
  begin
       result:=nil;
  end;
  {result:=nil;
  name:=uppercase(name);
  tp:=exttype.beginiterate(ir);
  if tp<>nil then
  repeat
    if tp<>nil then
    //programlog.logoutstr(tp^.typename,0);
    s:=uppercase(tp^.typename);
    if name = s then
    begin
      result:=tp;
      system.Exit;
    end;
  tp:=exttype.iterate(ir);
  until tp=nil;}
end;
function typemanager._ObjectTypeName2PTD;
begin
  result:=pointer(_TypeName2PTD(name));
end;
constructor typemanager.init;
begin
     exttype.init({$IFDEF DEBUGBUILD}'{5C8C5991-F908-4A85-B47E-56EA0ED03084}',{$ENDIF}1000{,sizeof(typedesk)});
     n2i:=TNameToIndex.create;
     //CreateBaseTypes;
end;
procedure typemanager.CreateBaseTypes;
begin
     AddTypeByRef(FundamentalPointerDescriptorOdj);
     AddTypeByRef(FundamentalBooleanDescriptorOdj);
     AddTypeByRef(FundamentalShortIntDescriptorObj);
     AddTypeByRef(FundamentalByteDescriptorObj);
     AddTypeByRef(FundamentalSmallIntDescriptorObj);
     AddTypeByRef(FundamentalWordDescriptorObj);
     AddTypeByRef(FundamentalLongIntDescriptorObj);
     AddTypeByRef(FundamentalLongWordDescriptorObj);
     AddTypeByRef(FundamentalQWordDescriptorObj);
     AddTypeByRef(FundamentalDoubleDescriptorObj);
     AddTypeByRef(FundamentalStringDescriptorObj);
     AddTypeByRef(FundamentalUnicodeStringDescriptorObj);
     AddTypeByRef(FundamentalAnsiStringDescriptorObj);
     AddTypeByRef(FundamentalSingleDescriptorObj);
     AddTypeByRef(GDBEnumDataDescriptorObj);
     AddTypeByRef(AliasIntegerDescriptorOdj);
     AddTypeByRef(AliasCardinalDescriptorOdj);
     AddTypeByRef(AliasDWordDescriptorOdj);
     AddTypeByRef(AliasPtrUIntDescriptorOdj);
     AddTypeByRef(AliasUInt64DescriptorOdj);
     BaseTypesEndIndex:=exttype.Count;
end;





procedure tsimpleunit.setvardesc(out vd: vardesk; varname, username, typename: TInternalScriptString;_pinstance:pointer=nil);
//var
//  tpe:PUserTypeDescriptor;
begin
  varname := readspace(varname);
  vd.name := varname;
  vd.username := username;
  vd.data.Instance := _pinstance;
  vd.data.ptd:={SysUnit.}TypeName2PTD(typename);

  if vd.data.ptd=nil then
                         begin
                              if VerboseLog^ then
                                DebugLn(sysutils.format('{E}Type "%S" not defined in unit "%S"',[typename,self.Name]));

                              //programlog.LogOutStr(sysutils.format('Type "%S" not defined in unit "%S"',[typename,self.Name]),lp_OldPos,LM_Error);
                         end;
end;
constructor varmanager.init;
begin
  vardescarray.init({$IFDEF DEBUGBUILD}'{7216CFFF-47FA-4F4E-BE07-B12E967EEF91} - описания переменных',{$ENDIF}50{,sizeof(vardesk)});
  vararray.init({$IFDEF DEBUGBUILD}'{834B86B5-4581-4C93-8446-8CEE664A66A2} - содержимое переменных',{$ENDIF}10024); { TODO: из описания переменной пужно относительную ссылку на значение. рушится при реаллокации }
end;
destructor varmanager.done;
begin
     if VerboseLog^ then
       DebugLn('{T+}[ZSCRIPT]varmanager.done;');

     //programlog.LogOutStr('varmanager.done',lp_IncPos,LM_Trace);
     vardescarray.freewithproc(vardeskclear);
     vardescarray.done;
     vararray.done;//TODO:проверить чистятся ли стринги внутри
     //exttype.freewithproc(basetypedescclear);
     if VerboseLog^ then
       DebugLn('{T-}[ZSCRIPT]varmanager.done;//end');


     //programlog.LogOutStr('end;',lp_DecPos,LM_Trace);
end;
function varmanager.createvariable(varname: TInternalScriptString; var vd: vardesk;attr:TVariableAttributes=0):pvardesk;
var
  size: GDBLongword;
  i:TArrayIndex;
begin
       if vd.data.ptd<>nil then
                          size:=vd.data.ptd^.SizeInGDBBytes
                      else
                          begin
                               size:=1;
                          end;
       if vd.data.Instance=nil then
       begin
         vd.data.Instance:=vararray.getDataMutable(vararray.AllocData(size));
         vd.data.PTD.InitInstance(vd.data.Instance);
       end;
       vd.attrib:=attr;
       i:=vardescarray.PushBackData(vd);
       result:=vardescarray.getDataMutable(i);
       //KillString(vd.name);
       //KillString(vd.username);
end;
function getpattern(ptd:ptdarray; max:GDBInteger;var line:TInternalScriptString; out typ:GDBInteger):PTZctnrVectorGDBString;
var i:GDBInteger;
    parseresult:PTZctnrVectorGDBString;
    parseerror:GDBBoolean;
begin
     typ:=0;
     i:=1;
     result:=nil;
     parseresult:=nil;
     while i<=max do
                   begin
                        parseresult:=runparser(ptd^[i].template,line,parseerror);
                        if parseerror then
                                      begin
                                           typ:=ptd^[i].id;
                                           result:=parseresult;
                                           system.Break;
                                      end;
                                      inc(i);
                        if parseresult<>nil then
                                                begin
                                                parseresult.Done;
                                                GDBFreeMem(Gdbpointer(parseresult));
                                                end;
                   end;
end;
function ObjOrRecordRead(TranslateFunc:TTranslateFunction;var f: GDBOpenArrayOfByte; var line,GDBStringtypearray:TInternalScriptString; var fieldoffset: GDBSmallint; ptd:PRecordDescriptor):GDBBoolean;
type
    trrstate=(fields,metods);
var parseerror{,parsesuberror}:GDBBoolean;
    parseresult{,parsesubresult}:PTZctnrVectorGDBString;
    count,typ:GDBInteger;
    {typename,}oldline, fieldname, {fieldvalue,} fieldtype, {sub, indmins, indmaxs, arrind1,}rname,wname,functionname,functionoperands: TInternalScriptString;
    fieldgdbtype:PUserTypeDescriptor;
    i: GDBInteger;
//  indmin, indcount, size: GDBLongword;
//  etd:PUserTypeDescriptor;
//  addtype:GDBBoolean;
  state:trrstate;
  fieldsmode:(primary,calced);
  fd:FieldDescriptor;
  pd:PropertyDescriptor;
  //a:word;
  //vv:smallint;
  mattr:GDBMetodModifier;
  //md:MetodDescriptor;
  pf:PFieldDescriptor;
//function getla
function getlastfirld:PBaseDescriptor;
begin
     if state=metods then
                         result:=@PPropertyDescriptor(PObjectDescriptor(ptd)^.Properties.getDataMutable(PObjectDescriptor(ptd)^.Properties.Count-1))^.base
                     else
                         result:=@PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count-1))^.base
end;

begin
     //vv:=fieldoffset;
     state:=fields;
     count:=0;
     fieldsmode:=primary;
     repeat
           //programlog.LogOutStr(line,0);
           parseresult:=getpattern(@parseobjmember,maxobjmember,line,typ);
           case typ of
           oaopo:begin
                      PObjectDescriptor(ptd)^.LincedObjects:=True;
                 end;

           oaod:begin
                     PObjectDescriptor(ptd)^.LincedData:=parseresult^.getData(0);
                     state:=state;
                end;
           functionmember,
           proceduremember,
           constructormember,
           destructormember:
                          begin
                               state:=metods;
                               mattr:=0;
                               case typ of
                            functionmember:begin
                                                mattr:=m_function;
                                           end;
                           proceduremember:begin
                                                mattr:=m_procedure;
                                           end;
                         constructormember:begin
                                                mattr:=m_constructor;
                                           end;
                          destructormember:begin
                                                mattr:=m_destructor;
                                           end;
                               end;
                               oldline:=line;
                               parseresult:=runparser('_softspace'#0'_identifier'#0'_softspace'#0,line,parseerror);
                               if parseerror then
                                                  begin
                                                       functionname:=parseresult^.getData(0);
                                                       functionoperands:=line;
                                                  end
                                              else
                                                  begin
                                                    {$IFDEF LOUDERRORS}
                                                       Raise Exception.Create('Something wrong');
                                                    {$ENDIF}
                                                  end;
                               if uppercase(functionname)='FORMAT' then
                                                                   functionname:=functionname;

                               if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                               repeat
                               line := f.readtoparser(';');
                               parseresult:=getpattern(@parsefuncmodss,maxmod,line,typ); // длдл
                               case typ of
                                mod_virtual:begin
                                                 mattr:=mattr or m_virtual;
                                            end;
                               mod_abstract:begin
                                                 mattr:=mattr;
                                            end;
                               end;
                               if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                               until typ=0;
                               PObjectDescriptor(ptd)^.addmetod(ptd^.TypeName,functionname,functionoperands,nil,mattr);
                               //line:=oldline;
                               //typ:=0;
                          end;
           oi_hidden:
                          begin
                               //a:=PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count-1))^.Attributes;
                               getlastfirld.Attributes:=
                               getlastfirld.Attributes or FA_HIDDEN_IN_OBJ_INSP;
                          end;
           oi_readonly:
                       begin
                               //a:=PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count-1))^.Attributes;
                               getlastfirld.Attributes:=
                               getlastfirld.Attributes or FA_READONLY;
                          end;
           savedtoshd:
                      getlastfirld.saved:=
                      getlastfirld.saved or SA_SAVED_TO_SHD;
           username:
                    begin
                      fieldtype:=parseresult^.getData(0);
                      //pf:=PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count-1));
                      if fieldtype='Paths' then
                                          fieldtype:=fieldtype;
                      {$IFNDEF DELPHI}
                      if assigned(TranslateFunc)then
                        fieldtype:=TranslateFunc(ptd.TypeName+'~'+getlastfirld.ProgramName,fieldtype);
                      {$ENDIF}
                      getlastfirld.username:={parseresult^.getGDBString(0)}fieldtype;
                      //fieldtype:=parseresult^.getGDBString(0);
                    end;
           membermodifier:
                          begin
                               if state<>metods then
                                                    begin
                                                         DebugLn('{F}Syntax error in file '+f.name);
                                                         //programlog.LogOutStr('Syntax error in file '+f.name,lp_OldPos,LM_Fatal);
                                                         halt(0);
                                                    end;

                          end;
          propertymember:
          begin
               if state<>metods then
                                    begin
                                      DebugLn('{F}Syntax error in file '+f.name);
                                      //programlog.LogOutStr('Syntax error in file '+f.name,lp_OldPos,LM_Fatal);
                                      halt(0);
                                    end;
               oldline:=line;
               parseresult:=runparser('_softspace'#0'_identifier'#0'_softspace'#0'=:'#0'_softspace'#0'_identifier'#0'_softspace'#0'=r=e=a=d'#0'_softspace'#0'_identifier'#0'_softspace'#0'=w=r=i=t=e'#0'_softspace'#0'_identifier'#0'_softspace'#0'=;',line,parseerror);
               if parseerror then
                                  begin
                                       pd.base.ProgramName:=parseresult^.getData(0);
                                       fieldtype:=parseresult^.getData(1);
                                       fieldgdbtype:=PTUnit(PRecordDescriptor(ptd)^.punit).TypeName2PTD(fieldtype);
                                       pd.base.PFT:=fieldgdbtype;
                                       pd.r:=parseresult^.getData(2);
                                       pd.w:=parseresult^.getData(3);
                                       pd.base.Attributes:=0;
                                       if ptd<>nil then PObjectDescriptor(ptd)^.AddProperty(pd);
                                  end
                              else
                                  begin
                                       {$IFDEF LOUDERRORS}
                                         Raise Exception.Create('Something wrong');
                                      {$ENDIF}
                                  end;
              //if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
          end;
                    field:
                          begin
                               if state=metods then
                                                  begin
                                                    DebugLn('{F}Syntax error in file '+f.name);
                                                    //programlog.LogOutStr('Syntax error in file '+f.name,lp_OldPos,LM_Fatal);
                                                    halt(0);
                                                  end
                                               else
                                                   begin
                                                       {if (line='')or(count=5) then
                                                             line := f.readtoparser(';')
                                                         else
                                                             begin
                                                                  inc(count);
                                                             end;
                                                        parsesubresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)',line,parsesuberror);}
                                                        fieldtype:=parseresult^.getData(parseresult.Count-1);
                                                        //pGDBString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                                        fieldgdbtype:=PTUnit(PRecordDescriptor(ptd)^.punit).TypeName2PTD(fieldtype);
                                                        for i:=0 to parseresult.Count-2 do
                                                        begin
                                                             fieldname:=parseresult^.getData(i);
                                                             if fieldname='PInOCS' then
                                                                                           fieldname:=fieldname;
                                                             GDBStringtypearray := GDBStringtypearray + fieldname + #0;
                                                             if fieldsmode=primary then GDBStringtypearray := GDBStringtypearray+'P'
                                                                                   else GDBStringtypearray := GDBStringtypearray+'C';
                                                             //GDBStringtypearray := GDBStringtypearray + char(fieldsmode);
                                                             //GDBStringtypearray := GDBStringtypearray + pac_GDBWord_to_GDBString(fieldgdbtype.gdbtypecustom) + pac_lGDBWord_to_GDBString(fieldgdbtype.sizeinmem);
                                                             fd.base.ProgramName:=fieldname;
                                                             fd.base.PFT:=fieldgdbtype;
                                                             //GDBPointer(fd.base.UserName):=nil;
                                                             //fd.UserName:='sdfsdf';
                                                             fd.base.Attributes:=0;
                                                             fd.base.Saved:=0;
                                                             fd.Collapsed:=true;
                                                             //if fieldsmode<>primary then fd.Attributes:=fd.Attributes or FA_CALCULATED;
                                                             fd.Offset:=fieldoffset;
                                                             if fd.base.PFT<>nil then
                                                                                fd.Size:=fd.base.PFT^.SizeInGDBBytes
                                                                            else
                                                                                fd.Size:=1;
                                                             //if PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count))^.username=''
                                                             //then PFieldDescriptor(PRecordDescriptor(ptd)^.Fields.getDataMutable(PRecordDescriptor(ptd)^.Fields.Count))^.username:=fieldname;
                                                             if ptd<>nil then PRecordDescriptor(ptd)^.AddField(fd);
                                                             if (fd.Size <> 0) and (fieldoffset <> dynamicoffset) then
                                                                                                              fieldoffset := fieldoffset + fd.Size
                                                                                                          else
                                                                                                              fieldoffset := dynamicoffset;
                                                        end;
                                                   end;
                          end;
           end;{case}
           if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
           if (line='')or(count=300) then
                                         begin
                                              line := f.readtoparser(';');
                                              count:=0;
                                         end
                                                         else
                                                             begin
                                                                  inc(count);
                                                             end;
     until typ=objend;
end;
function varmanager.findfieldcustom;
var
  path,{sp,} {typeGDBString,} sub, {field,} inds: TInternalScriptString;
  oper: ansichar;
  i, oldi, j, indexcount: GDBInteger;
  pind: parrayindex;
  ind, sum: GDBInteger;
  //sizeinmem: GDBLongword;
  //deb1,deb2:shortString;
  pt:PTUserTypeDescriptor;
begin
  result := false;
  if pvardesk(pdesc)^.name = nam then
  begin
    result := true;
    exit;
  end;
  if length(pvardesk(pdesc)^.name) >= length(nam) then
  begin
    exit;
  end;
  //deb1:=pvardesk(pdesc)^.name;
  //deb2:=copy(nam, 1, length(pvardesk(pdesc)^.name));
  if pvardesk(pdesc)^.name <> copy(nam, 1, length(pvardesk(pdesc)^.name)) then
  begin
    exit;
  end;
  oper := nam[length(pvardesk(pdesc)^.name) + 1];
  if not (oper in ['.', '[', '^']) then
  begin
    exit;
  end;
  if length(nam) > length(pvardesk(pdesc)^.name) + 1 then
  begin
    path := copy(nam, length(pvardesk(pdesc)^.name) + 2, length(nam) - length(pvardesk(pdesc)^.name) + 3);
  end
  else
  begin
    path := '';
  end;
  //typeGDBString := ptypedesk(Types.exttype.getDataMutable(pvardesk(pdesc)^.vartypecustom))^.tdesk;
  pt:=pointer(pvardesk(pdesc)^.data.ptd);// pointer(PUserTypeDescriptor(Types.exttype.getDataMutable(pvardesk(pdesc)^.vartypecustom)^));
     {result:=true;}
  repeat
    case oper of
      '.':
        begin
          //typeGDBString := exttypearrayptr^.typearray[pvardesk(pdesc)^.vartypecustom].tdesk;
          //typeGDBString := copy(typeGDBString, 2, length(typeGDBString));
          i := 1;
          while not (path[i] in ['.', '[', '^']) do
          begin
            if i = length(path) then
              system.break;
            i := i + 1;
          end;
          if i <> length(path) then
            i := i - 1;
          sub := copy(path, 1, i);
          i := i + 1;
          if i >= length(path) then
          begin
            oper := #00;
            //sp:=path;
            path := '';
          end
          else
          begin
            oper := path[i];
            path := copy(path, i + 1, length(path) - i)
          end;

          PObjectDescriptor(pt)^.ApplyOperator('.',sub{sp},offset,tc);
          if tc<>nil then
                                  begin
                                       result := true;
                                       //typeGDBString := ptypedesk(Types.exttype.getDataMutable(tc))^.tdesk;
                                       //pt:=pointer(PUserTypeDescriptor(Types.exttype.getDataMutable(tc)^));
                                       pt:=pointer(tc);
                                  end
                              else
                                  begin
                                       result := false;
                                       exit;
                                  end;
        end;
      '[':
        begin
          //typeGDBString := copy(typeGDBString, 2, length(typeGDBString));
          i := 1;
          while not (path[i] in [']']) do
          begin
            if i = length(path) then
              system.break;
            i := i + 1;
          end;
          sub := copy(path, 1, i - 1);
          if i = length(path) then
          begin
            oper := #00;
            path := '';
          end
          else
          begin
            oper := path[i + 1];
            path := copy(path, i + 2, length(path) - i - 1)
          end;
          i := 1;
          sum:=0;
          {bt := GDBByte(typeGDBString[i]);
          inc(i);}
//----------------------------------          tc := unpac_GDBString_to_GDBWord(copy(typeGDBString, i, 2));
          inc(i, 2);
          {sizeinmem :=} //unpac_GDBString_to_lGDBWord(copy(typeGDBString, i, 4));
             //offset:=offset+sizeinmem;
          inc(i, 4);
          indexcount :=-100;// unpac_GDBString_to_GDBWord(copy(typeGDBString, i, 2));
          inc(i, 2);
          //pind := @typeGDBString[i];
          i := 1;
             //offset:=0;
          for oldi := 1 to indexcount - 1 do
          begin
            inds := '';
            while not (sub[i] in ['0'..'9']) do
              inc(i);
            while sub[i] in ['0'..'9'] do
            begin
              inds := inds + sub[i];
              inc(i);
            end;
            ind := strtoint(inds);
            j := oldi + 1;
            sum := 1;
            while j <= indexcount do
            begin
              sum := sum * pind^[j].count;
              inc(j);
            end;
            sum := sum * (ind - pind^[oldi].indexmin);
          end;
          inds := '';
          while not (sub[i] in ['0'..'9']) do
            inc(i);
          while sub[i] in ['0'..'9'] do
          begin
            inds := inds + sub[i];
            inc(i);
          end;
          ind := strtoint(inds);

          sum := sum + (ind - pind^[oldi].indexmin);
          offset := offset + sum;
          result := true;

        end;
      '^':
        begin
        end;
      '@':
        begin
        end;
    end;
  until oper = #00;
end;







function varmanager.findvardescbyinst(varinst:GDBPointer):pvardesk;
var
  //pblock: pdblock;
  pdesc: pvardesk;
  //offset: GDBLongword;
  //temp: pvardesk;
  //bc:PUserTypeDescriptor;
      ir:itrec;

begin
  result:=nil;
  pdesc:=self.vardescarray.beginiterate(ir);
  if pdesc<>nil then
  repeat
        if pdesc.data.Instance=varinst then
        begin
             result:=pdesc;
             exit;
        end;
  pdesc:=self.vardescarray.iterate(ir);
  until pdesc=nil;
end;
function varmanager.findvardescbytype(pt:PUserTypeDescriptor):pvardesk;
var
  pdesc: pvardesk;
  //offset: GDBLongword;
  //temp: pvardesk;
  //bc:PUserTypeDescriptor;
      ir:itrec;

begin
  result:=nil;
  pdesc:=self.vardescarray.beginiterate(ir);
  if pdesc<>nil then
  repeat
        if pdesc.data.PTD=pt then
        begin
             result:=pdesc;
             exit;
        end;
  pdesc:=self.vardescarray.iterate(ir);
  until pdesc=nil;
end;
function varmanager.findvardesc(varname: TInternalScriptString): pvardesk;
var
  //pblock: pdblock;
  pdesc: pvardesk;
  offset: GDBInteger;
  temp: pvardesk;
  bc:PUserTypeDescriptor;
      ir:itrec;
begin
  //pblock := firstblockdesc;
  //while true do
  //begin
    if varname='camera.point.x' then
       varname:=varname;
    pdesc:=self.vardescarray.beginiterate(ir);
    if pdesc<>nil then
    repeat
    offset := 0;
      bc := nil;
          if pdesc^.name='RD_BackGroundColor' then
                                       varname:=varname;

          if findfieldcustom(pGDBByte(pdesc), offset, bc, varname) then
      begin
        if offset = 0 then
        begin
          if (bc = nil) then
          begin
            result := GDBPointer(pdesc);
            exit;
          end
          else
          begin
            gdbgetmem({$IFDEF DEBUGBUILD}'{9A28C83C-C227-41B1-A334-365942DC17CB}',{$ENDIF}GDBPointer(temp),sizeof(vardesk));
            fillchar(temp^,sizeof(vardesk),0);
            //new(temp);
            temp^.data.Instance := pvardesk(pdesc)^.data.Instance;
            temp^.name := invar;
            temp^.data.ptd := bc;
            inc(pGDBByte(temp^.data.Instance), offset);
            result := temp;
            exit;
          end;
        end
        else
        begin
          gdbgetmem({$IFDEF DEBUGBUILD}'{8E7E4D67-1D25-4D95-BB32-04D2F00BC201}',{$ENDIF}GDBPointer(temp),sizeof(vardesk));
          fillchar(temp^,sizeof(vardesk),0);
          //new(temp);
          temp^.data.Instance := pvardesk(pdesc)^.data.Instance;
          temp^.name := invar;
          temp^.data.ptd := bc;
          inc(pGDBByte(temp^.data.Instance), offset);
          result := temp;
          exit;
        end
      end;
    pdesc:=self.vardescarray.iterate(ir);
    until pdesc=nil;
    result:=nil;
    {sizeused := pblock^.sizeused;
    GDBPointer(pdesc) := GDBPointer(pblock);
    inc(pdesc, sizeof(dblock));
    while sizeused > 0 do
    begin
      offset := 0;
      bt := 0;
      bc := 0;
      if findfieldcustom(pdesc, offset, bt, bc, varname) then
      begin
        if offset = 0 then
        begin
          if (bt = 0) and (bc = 0) then
          begin
            result := GDBPointer(pdesc);
            exit;
          end
          else
          begin
            new(temp);
            temp^.pvalue := pvardesk(pdesc)^.pvalue;
            temp^.name := invar;
            temp^.vartype := bt;
            temp^.vartypecustom := bc;
            inc(pGDBByte(temp^.pvalue), offset);
            result := temp;
            exit;
          end;
        end
        else
        begin
          new(temp);
          temp^.pvalue := pvardesk(pdesc)^.pvalue;
          temp^.name := invar;
          temp^.vartype := bt;
          temp^.vartypecustom := bc;
          inc(pGDBByte(temp^.pvalue), offset);
          result := temp;
          exit;
        end
      end;
      inc(pdesc, sizeof(vardesk));
      dec(sizeused, sizeof(vardesk));
    end;
    if pblock^.nextblock <> nil then
    begin
      pblock := pblock^.nextblock;
    end
    else
    begin
      result := nil;
      exit;
    end;
  end;}
end;
procedure registertypes;
begin
end;
constructor tsimpleunit.init;
begin
  GDBPointer(name):=nil;
  name := nam;

  InterfaceVariables.init;
  InterfaceUses.init({$IFDEF DEBUGBUILD}'{BDC39F0D-79B7-4F89-89D7-C530D3542F36} - tsimpleunit (uses секция)',{$ENDIF}10);
end;
destructor tsimpleunit.done;
begin
     InterfaceVariables.done;
     InterfaceUses.done;
     name:='';
end;
function tsimpleunit.FindValue(varname:TInternalScriptString):GDBPointer;
var
  temp:pvardesk;
begin
     temp:=findvariable(varname);
     if assigned(temp)then
                          result:=temp^.data.Instance
                      else
                          result:=nil;
end;
function tsimpleunit.FindOrCreateValue(varname,vartype:TInternalScriptString):GDBPointer;
begin
  result:=FindValue(varname);
  if result=nil then
    result:=CreateVariable(varname,vartype);
end;

function tsimpleunit.FindVariableByInstance(_Instance:GDBPointer):pvardesk;
begin
     result:=InterfaceVariables.findvardescbyinst(_Instance)
end;

function tsimpleunit.findvariable;
var p:ptunit;
    ir:itrec;
    un:TInternalScriptString;
    i:integer;
begin
     i:=pos('.',varname);
     un:=varname;
     if i>0 then
                begin
                     un:=copy(varname,1,i-1);
                     if uppercase(un)=uppercase(name) then
                                               un:=copy(varname,i+1,length(varname)-i)
                                           else
                                               un:=varname;
                end;
     result:=self.InterfaceVariables.findvardesc(un);
     if result=nil then
     begin
                            p:=InterfaceUses.beginiterate(ir);
                            if p<>nil then
                            repeat
                                  result:=p^.FindVariable(varname);
                                  if result<>nil then
                                                     begin
                                                          exit;
                                                     end;
                                  p:=InterfaceUses.iterate(ir);
                            until p=nil;
     end;
end;
function tsimpleunit.createvariable(varname,vartype:TInternalScriptString;_pinstance:pointer=nil):GDBPointer;
var //t:PUserTypeDescriptor;
    //pvd:pvardesk;
    vd:vardesk;
begin
     {t:=TypeName2PTD(vartype);
     pvd:=findvariable(varname);

     vd.name:=varname;
     vd.pvalue:=nil;
     vd.ptd:=t;}
     setvardesc(vd, varname,'', vartype,_pinstance);
     InterfaceVariables.createvariable(varname,vd);
     result:=vd.data.Instance;
end;
constructor tunit.init(nam: TInternalScriptString);
begin
  inherited init(nam);
  InterfaceTypes.init;
  ImplementationTypes.init;
  ImplementationVariables.init;
  //InterfaceVariables.init;
  if uppercase(name)='SYSTEM' then
  begin
    InterfaceTypes.CreateBaseTypes;
    if assigned(OnCreateSystemUnit) then
                                        OnCreateSystemUnit(@self);
  end;
end;
function tunit.SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;
var
   pu:PTUnit;
   pv:pvardesk;
   ir:itrec;
//   value:TInternalScriptString;
begin
     membuf.TXTAddGDBString('unit ');
     membuf.TXTAddGDBStringEOL(self.Name+';');
     membuf.TXTAddGDBStringEOL('interface');
     if InterfaceUses.Count<>0 then
        begin
             pu:=InterfaceUses.beginiterate(ir);
             if pu<>nil then
                            begin
                                 membuf.TXTAddGDBString('uses '+pu^.Name);
                            end;
             pu:=InterfaceUses.iterate(ir);
                          if pu<>nil then
                            repeat
                                 membuf.TXTAddGDBString(','+pu^.Name);
                                 pu:=InterfaceUses.iterate(ir);
                            until pu=nil;
            membuf.TXTAddGDBStringEOL(';');
        end;
     if InterfaceVariables.vardescarray.Count<>0 then
        begin
              membuf.TXTAddGDBStringEOL('var');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 membuf.TXTAddGDBString('  '+pv^.name+':');
                                 membuf.TXTAddGDBString(pv.data.PTD.TypeName+';');
                                 if pv^.username<>'' then membuf.TXTAddGDBString('(*'''+pv^.username+'''*)');
                                 membuf.TXTAddGDBStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
        end;
        begin
              membuf.TXTAddGDBStringEOL('implementation');
              membuf.TXTAddGDBStringEOL('begin');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 pv.data.PTD.SavePasToMem(membuf,pv.data.Instance,'  '+pv^.name);
                                 {membuf.TXTAddGDBString('  '+pv^.name+':=');
                                 value:=pv.data.PTD.GetValueAsString(pv.data.Instance);
                                 if pv.data.PTD=@FundamentalStringDescriptorObj then
                                             value:=''''+value+'''';

                                 membuf.TXTAddGDBString(value+';');
                                 membuf.TXTAddGDBStringEOL('');}
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
            membuf.TXTAddGDBString('end.');
        end;
end;
destructor tunit.done;
begin
     if name='devicebase' then
                               name:=name;
     ImplementationVariables.done;
     InterfaceVariables.done;
     InterfaceUses.done;
     if uppercase(name)<>'SYSTEM' then
                                      InterfaceTypes.done
                                  else
                                      InterfaceTypes.systemdone;
     ImplementationTypes.done;
     name:='';
     //inherited done;
     //name:='';
     //InterfaceVariables.done;
     //ImplementationUses.done;
     //ImplementationTypes.done;
     //ImplementationVariables.done;
     (*InterfaceVariables.done;*)
end;
procedure tunit.free;
begin
      { TODO : Униты надо чистить }
     //inherited clear;
     //name:='';
     InterfaceTypes.free;
     InterfaceVariables.free;
     //ImplementationUses. . done;
     ImplementationTypes.free;
     ImplementationVariables.free;
     (*InterfaceVariables.done;*)
end;
function tsimpleunit.TypeName2PTD;
var p:ptunit;
    ir:itrec;
begin
     result:=nil;
                       begin
                            p:=InterfaceUses.beginiterate(ir);
                            if p<>nil then
                            repeat
                                  result:=p^.InterfaceTypes._TypeName2PTD(n);
                                  if result<>nil then
                                                     begin
                                                          exit;
                                                     end;
                                  p:=InterfaceUses.iterate(ir);
                            until p=nil;
  {$IFDEF LOUDERRORS}
    //Raise Exception.Create('Something wrong');
  {$ENDIF}
                       end;

end;
function tunit.TypeName2PTD;
//var p:ptunit;
begin
     result:=inherited TypeName2PTD(n);
     if result<>nil then
                        exit;
     result:=InterfaceTypes._TypeName2PTD(n);
     if VerboseLog^ then
       if result=nil then
         DebugLn('{W}In unit "%s" not found type "%s"',[name,n]);

      //programlog.LogOutStr(sysutils.format('In unit "%s" not found type "%s"',[name,n]),0,LM_Warning);
end;
function tunit.ObjectTypeName2PTD;
begin
     result:=InterfaceTypes._ObjectTypeName2PTD(n);
end;
function tunit.TypeIndex2PTD;
begin
     result:=InterfaceTypes._TypeIndex2PTD(ind);
end;
function tunit.AssignToSymbol;//(var psymbol;symbolname:TInternalScriptString);
var
  vd:pvardesk;
begin
     vd:=InterfaceVariables.findvardesc(symbolname);
     if vd<>nil then
     pointer(psymbol):=vd^.data.Instance;
end;
function FindCategory(category:TInternalScriptString;var catname:TInternalScriptString):Pointer;
var
   ps:pgdbstring;
   ir:itrec;
begin
     result:=CategoryCollapsed.parray;
     ps:=VarCategory.beginiterate(ir);
     if (ps<>nil) then
     repeat
          if length(ps^)>length(category) then

          if (copy(ps^,1,length(category))=category)
          and(ps^[length(category)+1]='_') then
                                              begin
                                                    catname:=copy(ps^,length(category)+2,length(ps^)-length(category)-1);
                                                    exit;
                                              end;
          ps:=VarCategory.iterate(ir);
          inc(pbyte(result));
     until ps=nil;
     result:=@CategoryUnknownCOllapsed;
     catname:=category;
end;
procedure SetCategoryCollapsed(category:TInternalScriptString;value:GDBBoolean);
var
  cn:TInternalScriptString;
  pc:PGDBBoolean;
begin
     pc:=FindCategory(category,cn);
     if pc<>@CategoryUnknownCOllapsed then
                                          pc^:=value;
end;

initialization;
begin
  if VerboseLog^ then
    DebugLn('{D+}[ZSCRIPT]Varman.startup');
  //programlog.logoutstr('Varman.startup',lp_IncPos,LM_Debug);
  //DecimalSeparator := '.';
  ShortDateFormat:='MM.yy';
  VarCategory.init(100);
  //VarCategory.loadfromfile(expandpath('*rtl/VarCategory.cat'));
  CategoryCollapsed.init({$IFDEF DEBUGBUILD}'{716C3EDB-32A3-416D-A599-B04B1B45D6E4}',{$ENDIF}VarCategory.Max);
  CategoryCollapsed.CreateArray;
  fillchar(CategoryCollapsed.parray^,CategoryCollapsed.max,byte(true));
  CategoryUnknownCOllapsed:=true;
  if VerboseLog^ then
    DebugLn('{D-}[ZSCRIPT]end; {Varman.startup}');
  //programlog.logoutstr('end; {Varman.startup}',lp_DecPos,LM_Debug);
end;
finalization;
begin
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  VarCategory.Done;
  CategoryCollapsed.done;
end;
end.

