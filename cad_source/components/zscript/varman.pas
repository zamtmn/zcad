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

unit Varman;

{$MODE DELPHI}

interface
uses
  UEnumDescriptor,uzctnrVectorPointers,LCLProc,uabstractunit,
  SysUtils,UBaseTypeDescriptor,uzctnrVectorBytes,
  gzctnrVectorTypes,uzctnrvectorstrings,varmandef,gzctnrSTL,
  TypeDescriptors,URecordDescriptor,UObjectDescriptor,uzbstrproc,classes,typinfo,
  UPointerDescriptor,
  gzctnrVectorPData,gzctnrVector,
  uzbLogIntf,uzctnrAlignedVectorBytes,uzbtypes;
type
    td=record
             template:String;
             id:Integer;
       end;
    ptdarray=^tdarray;
    tdarray=array [1..maxint div sizeof(td)] of td;
    pasparsemode=(modeOk,modeError,modeEnd);
    penumodj=^tenumodj;
    tenumodj=record
                  source,user:String;
                  value:LongWord;
            end;
const
     SysVarN='sysvar';
     SysVarNSN='sysvarns';
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
      (template:'_softspace'#0'=(=*=v=a=r=c=a=t=e=g=o=r=y=f=o=r=o=i_softspace'#0'_identifier'#0'==_String'#0'=*=)';id:variablecategory)
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
      (template:'_softspace'#0'=(=*_String'#0'=*=)';id:username),
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
TNameToIndex=TMyAnsiStringDictionary<TArrayIndex>;
TFieldName=(FNUser,FNProgram);
TFieldNames=set of TFieldName;
{EXPORT+}
TZctnrVectorPUserTypeDescriptors=object(GZVectorPData{-}<PUserTypeDescriptor>{//})
                           end;
ptypemanager=^typemanager;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE typemanager}
typemanager=object(typemanagerdef)
                  {-}protected{/Pointer;/}
                  n2i:{-}TNameToIndex;{/Pointer;/}
                  {-}public{/Pointer;/}
                  exttype:TZctnrVectorPUserTypeDescriptors;
                  constructor init;
                  procedure CreateBaseTypes;virtual;
                  function _TypeName2PTD(name: TInternalScriptString):PUserTypeDescriptor;virtual;
                  function _ObjectTypeName2PTD(name: TInternalScriptString):PObjectDescriptor;virtual;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;
                  destructor done;virtual;
                  destructor systemdone;virtual;
                  procedure free;virtual;
                  {for hide exttype}
                  function getDataMutable(index:TArrayIndex):Pointer;virtual;
                  function getcount:TArrayIndex;virtual;
                  function AddTypeByPP(p:Pointer):TArrayIndex;virtual;
                  function AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;virtual;
            end;
Tvardescarray=GZVector{-}<vardesk>{//};
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE varmanager}
pvarmanager=^varmanager;
varmanager=object(varmanagerdef)
            vardescarray:Tvardescarray;
            vararray:TZctnrAlignedVectorBytes;
                 constructor init;
                 function findvardesc(varname:TInternalScriptString):pvardesk;virtual;
                 function findvardescbyinst(varinst:Pointer):pvardesk;virtual;
                 function findvardescbytype(pt:PUserTypeDescriptor):pvardesk;virtual;
                 function CreateVariable(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0):pvardesk;virtual;
                 function CreateVariable2(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0):TInVectorAddr;virtual;
                 procedure RemoveVariable(pvd:pvardesk);virtual;
                 function findvardesc2(varname:TInternalScriptString):TInVectorAddr;virtual;
                 function findfieldcustom(var pdesc: pByte; var offset: Integer;var tc:PUserTypeDescriptor; nam: ShortString): Boolean;virtual;
                 function getDS:Pointer;virtual;
                 destructor done;virtual;
                 procedure free;virtual;
           end;
TunitPart=(TNothing,TInterf,TImpl,TProg);
PTUnit=^TUnit;
PTSimpleUnit=^TSimpleUnit;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE TSimpleUnit}
TSimpleUnit=object(TAbstractUnit)
                  Name:TInternalScriptString;
                  InterfaceUses:TZctnrVectorPointer;
                  InterfaceVariables: varmanager;
                  constructor init(nam:TInternalScriptString);
                  destructor done;virtual;
                  function CreateFixedVariable(varname,vartype:TInternalScriptString;_pinstance:pointer):Pointer;virtual;
                  function CreateVariable(varname,vartype:TInternalScriptString):vardesk;virtual;
                  function FindVariable(varname:TInternalScriptString;InInterfaceOnly:Boolean=False):pvardesk;virtual;
                  function FindVarDesc(varname:TInternalScriptString):TInVectorAddr;virtual;
                  function FindVariableByInstance(_Instance:Pointer):pvardesk;virtual;
                  function FindValue(varname:TInternalScriptString):pvardesk;virtual;
                  function FindOrCreateValue(varname,vartype:TInternalScriptString):vardesk;virtual;
                  function TypeName2PTD(n: TInternalScriptString):PUserTypeDescriptor;virtual;
                  function SaveToMem(var membuf:TZctnrVectorBytes;PEntUnits:PTZctnrVectorPointer=nil):PUserTypeDescriptor;virtual;
                  function SavePasToMem(var membuf:TZctnrVectorBytes):PUserTypeDescriptor;virtual;abstract;
                  procedure setvardesc(out vd: vardesk; varname, username, typename: TInternalScriptString;_pinstance:pointer=nil);
                  procedure free;virtual;abstract;
                  procedure CopyTo(source:PTSimpleUnit);virtual;
                  procedure CopyFrom(source:PTSimpleUnit);virtual;
            end;
PTEntityUnit=^TEntityUnit;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE TEntityUnit}
TEntityUnit=object(TSimpleUnit)
                  ConnectedUses:TZctnrVectorPointer;
                  procedure free;virtual;
                  constructor init(nam:TInternalScriptString);
                  destructor done;virtual;

                  function FindVariable(varname:TInternalScriptString;InInterfaceOnly:Boolean=False):pvardesk;virtual;
                  function FindVarDesc(varname:TInternalScriptString):TInVectorAddr;virtual;
            end;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE TUnit}
TUnit=object(TSimpleUnit)
            InterfaceTypes:typemanager;
            //ImplementationUses:Integer;
            ImplementationTypes:typemanager;
            ImplementationVariables: varmanager;

            constructor init(nam:TInternalScriptString);
            function TypeIndex2PTD(ind:Integer):PUserTypeDescriptor;virtual;
            function TypeName2PTD(n: TInternalScriptString):PUserTypeDescriptor;virtual;
            function ObjectTypeName2PTD(n: TInternalScriptString):PObjectDescriptor;virtual;
            function AssignToSymbol(var psymbol;symbolname:TInternalScriptString):Integer;
            function SavePasToMem(var membuf:TZctnrVectorBytes):PUserTypeDescriptor;virtual;
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
  SysVarNotSavedUnit:PTUnit=nil;
  SavedUnit,DBUnit,DWGDBUnit,DWGUnit:PTUnit;
  BaseTypesEndIndex:Integer;
  OldTypesCount:Integer;
  VarCategory:TZctnrVectorStrings;
  CategoryCollapsed:TZctnrVectorBytes;
  CategoryUnknownCOllapsed:boolean;

function getpattern(ptd:ptdarray; max:Integer;var line:TInternalScriptString; out typ:Integer):PTZctnrVectorStrings;
function ObjOrRecordRead(TranslateFunc:TTranslateFunction;var f: TZctnrVectorBytes; var line,Stringtypearray:TInternalScriptString; var fieldoffset: SmallInt; ptd:PRecordDescriptor):Boolean;
function GetPVarMan: Pointer; export;
function FindCategory(category:TInternalScriptString;var catname:TInternalScriptString):Pointer;
procedure SetCategoryCollapsed(category:TInternalScriptString;value:Boolean);
function GetBoundsFromSavedUnit(name:string;w,h:integer):Trect;
procedure StoreBoundsToSavedUnit(name:string;tr:Trect);
procedure SetTypedDataVariable(out TypedTataVariable:THardTypedData;pTypedTata:pointer;TypeName:string);
function GetIntegerFromSavedUnit(name,suffix:string;def,min,max:integer):integer;
function GetAnsiStringFromSavedUnit(name,suffix:ansistring;def:ansistring):ansistring;
function GetBooleanFromSavedUnit(name,suffix:ansistring;def:Boolean):Boolean;
procedure StoreIntegerToSavedUnit(name,suffix:string;value:integer);
procedure StoreAnsiStringToSavedUnit(name,suffix:string;value:string);
procedure RegisterVarCategory(CategoryName,CategoryUserName:string;TranslateFunc:TTranslateFunction);
implementation
uses strmy;

procedure RegisterVarCategory(CategoryName,CategoryUserName:string;TranslateFunc:TTranslateFunction);
begin
  if (CategoryUserName<>'')and(CategoryName<>'')then begin
    if assigned(TranslateFunc)then
      VarCategory.PushBackIfNotPresent(CategoryName+'_'+TranslateFunc('VarCategory~'+CategoryName,CategoryUserName))
    else
      VarCategory.PushBackIfNotPresent(CategoryName+'_'+CategoryUserName);
  end;
end;

procedure SetTypedDataVariable(out TypedTataVariable:THardTypedData;pTypedTata:pointer;TypeName:string);
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
  pvd:pvardesk;
  pint:PInteger;
begin
  pvd:=SavedUnit.FindValue(name+suffix);
  if assigned(pvd) then begin
    pint:=pvd.data.Addr.Instance;
    if assigned(pint)then begin
      result:=pint^;
      result:=setfrominterval(result,min,max);
    end else
      result:=def;
  end else
    result:=def;
end;
function GetAnsiStringFromSavedUnit(name,suffix:ansistring;def:ansistring):ansistring;
var
  pvd:pvardesk;
  pstr:PAnsiString;
begin
  pvd:=SavedUnit.FindValue(name+suffix);
  if assigned(pvd) then begin
    pstr:=pvd.data.Addr.Instance;
    if assigned(pstr)then begin
      result:=pstr^;
    end else
      result:=def;
  end else
    result:=def;
end;
function GetBooleanFromSavedUnit(name,suffix:ansistring;def:Boolean):Boolean;
var
  pvd:pvardesk;
  pbool:PBoolean;
begin
  pvd:=SavedUnit.FindValue(name+suffix);
  if assigned(pvd) then begin
    pbool:=pvd.data.Addr.Instance;
    if assigned(pbool)then begin
      result:=pbool^;
    end else
      result:=def;
  end else
    result:=def;
end;
procedure StoreIntegerToSavedUnit(name,suffix:string;value:integer);
var
   pint:PInteger;
   pvd:pvardesk;
   vn:TInternalScriptString;
begin
     vn:=name+suffix;
     pvd:=SavedUnit.FindValue(vn);
     if not assigned(pvd) then
       pint:=SavedUnit.CreateVariable(vn,'Integer').data.Addr.instance
     else
       pint:=pvd^.data.Addr.Instance;
     pint^:=value;
end;
procedure StoreAnsiStringToSavedUnit(name,suffix:string;value:string);
var
   pas:PAnsiString;
   pvd:pvardesk;
   vn:TInternalScriptString;
begin
     vn:=name+suffix;
     pvd:=SavedUnit.FindValue(vn);
     if not assigned(pvd) then
       pas:=SavedUnit.CreateVariable(vn,'AnsiString').data.Addr.instance
     else
       pas:=pvd^.data.Addr.Instance;
     pas^:=value;
end;
function GetBoundsFromSavedUnit(name:string;w,h:integer):Trect;
var
   pint:PInteger;
   pvd:pvardesk;
begin
     result:=rect(0,0,100,100);
     pvd:=SavedUnit.FindValue(name+SuffLeft);
     if assigned(pvd) then begin
       pint:=pvd.data.Addr.Instance;
       if assigned(pint)then
                            result.Left:=pint^;
       result.Left:=setfrominterval(result.Left,0,w);
     end;
     pvd:=SavedUnit.FindValue(name+SuffTop);
     if assigned(pvd) then begin
       pint:=pvd.data.Addr.Instance;
       if assigned(pint)then
                            result.Top:=pint^;
       result.Top:=setfrominterval(result.Top,0,h);
     end;
     pvd:=SavedUnit.FindValue(name+SuffWidth);
     if assigned(pvd) then begin
       pint:=pvd.data.Addr.Instance;
       if assigned(pint)then
                            result.Right:=result.Left+pint^;
     end;
     pvd:=SavedUnit.FindValue(name+SuffHeight);
     if assigned(pvd) then begin
       pint:=pvd.data.Addr.Instance;
       if assigned(pint)then
                            result.Bottom:=result.Top+pint^;
     end;
end;
procedure StoreBoundsToSavedUnit(name:string;tr:Trect);
var
   pint:PInteger;
   vn:TInternalScriptString;
   pvd:pvardesk;
begin
     vn:=name+SuffLeft;
     pvd:=SavedUnit.FindValue(vn);
     if assigned(pvd) then
       pint:=SavedUnit.FindValue(vn).data.Addr.Instance
     else
       pint:=SavedUnit.CreateVariable(vn,'Integer').data.Addr.instance;
     pint^:=tr.Left;

     vn:=name+SuffTop;
     pvd:=SavedUnit.FindValue(vn);
     if assigned(pvd) then
       pint:=SavedUnit.FindValue(vn).data.Addr.Instance
     else
       pint:=SavedUnit.CreateVariable(vn,'Integer').data.Addr.instance;
     pint^:=tr.Top;

     vn:=name+SuffWidth;
     pvd:=SavedUnit.FindValue(vn);
     if assigned(pvd) then
       pint:=SavedUnit.FindValue(vn).data.Addr.Instance
     else
       pint:=SavedUnit.CreateVariable(vn,'Integer').data.Addr.instance;
     pint^:=tr.Right-tr.Left;

     vn:=name+SuffHeight;
     pvd:=SavedUnit.FindValue(vn);
     if assigned(pvd) then
       pint:=SavedUnit.FindValue(vn).data.Addr.Instance
     else
       pint:=SavedUnit.CreateVariable(vn,'Integer').data.Addr.instance;
     pint^:=tr.Bottom-tr.Top;
end;
procedure TSimpleUnit.CopyTo;
var
   pu:PTUnit;
   pv:pvardesk;
   vd: vardesk;
   ir:itrec;
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
          if source^.FindVariable(pv^.name,True)=nil then begin
            source^.setvardesc(vd,pv^.name,pv^.username,pv^.data.ptd^.TypeName);
            source^.InterfaceVariables.createvariable(vd.name, vd);
            pv^.data.ptd^.CopyInstanceTo(pv^.data.Addr.Instance,vd.data.Addr.Instance);
          end;
          pv:=InterfaceVariables.vardescarray.iterate(ir);
        until pv=nil;
end;
procedure TSimpleUnit.CopyFrom;
var
   pu:PTUnit;
   pv:pvardesk;
   vd: vardesk;
   ir:itrec;
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
          if FindVariable(pv^.name,True)=nil then begin
              setvardesc(vd,pv^.name,pv^.username,pv^.data.ptd^.TypeName);
              InterfaceVariables.createvariable(vd.name, vd);
              pv^.data.ptd^.CopyInstanceTo(pv^.data.Addr.Instance,vd.data.Addr.Instance);
          end;
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
     Getmem(Pointer(etd),sizeof(RecordDescriptor));
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
                             fd.Size:=fd.base.PFT^.SizeInBytes
                         else
                             system.break;
          etd^.AddField(fd);

          inc(mf);
     end;
     etd^.SizeInBytes:=td.RecSize;
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
     Getmem(Pointer(etd),sizeof(GDBPointerDescriptor));
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
     Getmem(Pointer(etd),sizeof(EnumDescriptor));
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

procedure TEntityUnit.free;
begin
     self.InterfaceUses.clear;
     self.InterfaceVariables.vardescarray.Freewithproc(vardeskclear);
     //self.InterfaceVariables.vardescarray.Clear;
     self.InterfaceVariables.vararray.Clear;
end;
constructor TEntityUnit.init;
begin
  inherited;
  ConnectedUses.init(10);
end;
destructor TEntityUnit.done;
begin
  ConnectedUses.done;
  inherited;
end;

function TEntityUnit.findvariable;
var
  p:ptunit;
  ir:itrec;
begin
  result:=inherited findvariable(varname,InInterfaceOnly);
  if (result=nil)and(InInterfaceOnly=False) then begin
    p:=ConnectedUses.beginiterate(ir);
    if p<>nil then
      repeat
        result:=p^.FindVariable(varname);
        if result<>nil then
          exit;
        p:=ConnectedUses.iterate(ir);
      until p=nil;
  end;
end;

function TEntityUnit.FindVarDesc(varname:TInternalScriptString):TInVectorAddr;
var
  p:ptunit;
  ir:itrec;
  i:integer;
begin
  result:=inherited FindVarDesc(varname);
  if result.IsNil then begin
    p:=ConnectedUses.beginiterate(ir);
    if p<>nil then
      repeat
        result:=p^.FindVarDesc(varname);
        if not result.IsNil then
          exit;
        p:=ConnectedUses.iterate(ir);
    until p=nil;
  end;
end;



function TSimpleUnit.SaveToMem(var membuf:TZctnrVectorBytes;PEntUnits:PTZctnrVectorPointer=nil):PUserTypeDescriptor;
var
   pu:PTUnit;
   pv:pvardesk;
   ir:itrec;
   value:TInternalScriptString;
   realUsesCount:integer;
begin
     membuf.TXTAddStringEOL('unit '+Name+';');
     membuf.TXTAddStringEOL('interface');
     realUsesCount:=0;
     if InterfaceUses.Count<>0 then begin
       pu:=InterfaceUses.beginiterate(ir);
       if pu<>nil then
         repeat
           if not IsIt(typeof(pu^),typeof(TEntityUnit)) then begin
             if realUsesCount=0 then
               membuf.TXTAddString('uses '+pu^.Name)
             else
               membuf.TXTAddString(','+pu^.Name);
             inc(realUsesCount);
           end else begin
             if PEntUnits<>nil then
               PEntUnits^.PushBackData(pu);
           end;
           pu:=InterfaceUses.iterate(ir);
         until pu=nil;
       if realUsesCount>0 then
         membuf.TXTAddStringEOL(';');
     end;
     if InterfaceVariables.vardescarray.Count<>0 then
        begin
              membuf.TXTAddStringEOL('var');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 membuf.TXTAddString('  '+pv^.name+':');
                                 membuf.TXTAddString(pv.data.PTD.TypeName+';');
                                 if pv^.username<>'' then membuf.TXTAddString('(*'''+pv^.username+'''*)');
                                 membuf.TXTAddStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
        end;
        begin
              membuf.TXTAddStringEOL('implementation');
              membuf.TXTAddStringEOL('begin');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 //membuf.TXTAddString('  '+pv^.name+':=');
                                 pv.data.PTD.SavePasToMem(membuf,pv.data.Addr.Instance,'  '+pv^.name);
                                 {value:=pv.data.PTD.GetValueAsString(pv.Instance);
                                 if pv.data.PTD=@FundamentalStringDescriptorObj then
                                             value:=''''+value+'''';

                                 membuf.TXTAddString(value+';');}
                                 //membuf.TXTAddStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
            membuf.TXTAddString('end.');
        end;
end;
{function getpsysvar: Pointer; export;
begin
  result := @sysvar;
end;}
function GetPVarMan: Pointer; export;
begin
  result := @SysUnit.InterfaceVariables;
end;
procedure vardeskclear(const p:pvardesk);
//var
   //s:string;
begin
     zTraceLn(format('{T}[ZSCRIPT]vardeskclear: "%s"',[pvardesk(p)^.name]));
     //programlog.LogOutFormatStr('vardeskclear: "%s"',[pvardesk(p)^.name],lp_OldPos,LM_Trace);
     if pvardesk(p)^.name='_EQ_C2000_KPB' then
     pvardesk(p)^.name:=pvardesk(p)^.name;

     //s:=pvardesk(p)^.name;

     pvardesk(p)^.name:='';
     pvardesk(p)^.username:='';

     pvardesk(p)^.data.ptd^.MagicFreeInstance(pvardesk(p)^.data.Addr.Instance);

     //if pvardesk(p)^.data.ptd=@FundamentalStringDescriptorObj then
       //                                                   pString(pvardesk(p)^.Instance)^:='';
     pvardesk(p)^.data.ptd:=nil;
     //Freemem(pvardesk(p)^.pvalue);
end;
procedure varmanager.free;
begin
     vardescarray.freewithproc(vardeskclear);
end;
destructor typemanager.done;
begin
     zTraceLn('{T+}[ZSCRIPT]TypeManager.done');
     //programlog.LogOutStr('TypeManager.done',lp_IncPos,LM_Trace);
     exttype.free;
     exttype.done;
     n2i.destroy;
     zTraceLn('{T-}[ZSCRIPT]TypeManager.done;//end');
     //programlog.LogOutStr('end;',lp_DecPos,LM_Trace);
end;
destructor typemanager.systemdone;
begin
     zTraceLn('{T+}[ZSCRIPT]TypeManager.systemdone;');
     //programlog.LogOutStr('TypeManager.systemdone',lp_IncPos,LM_Trace);
     exttype.cleareraseobjfrom(BaseTypesEndIndex-1);
     exttype.done;
     n2i.destroy;
     zTraceLn('{T-}[ZSCRIPT]TypeManager.systemdone;//end');
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
function typemanager.getDataMutable(index:TArrayIndex):Pointer;
begin
     result:=exttype.getDataMutable(index);
end;
function typemanager.getcount:TArrayIndex;
begin
     result:=exttype.count;
end;
function typemanager.AddTypeByPP(p:Pointer):TArrayIndex;
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
     exttype.init(1000);
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
  vd.SetInstance(_pinstance);
  //vd.Instance := _pinstance;
  vd.data.ptd:={SysUnit.}TypeName2PTD(typename);

  if vd.data.ptd=nil then
                         begin
                              zTraceLn(sysutils.format('{E}Type "%S" not defined in unit "%S"',[typename,self.Name]));

                              //programlog.LogOutStr(sysutils.format('Type "%S" not defined in unit "%S"',[typename,self.Name]),lp_OldPos,LM_Error);
                         end;
end;
constructor varmanager.init;
begin
  vardescarray.init(64);
  vararray.init(1024);
end;
destructor varmanager.done;
begin
     zTraceLn('{T+}[ZSCRIPT]varmanager.done;');

     //programlog.LogOutStr('varmanager.done',lp_IncPos,LM_Trace);
     vardescarray.freewithproc(vardeskclear);
     vardescarray.done;
     vararray.done;//TODO:проверить чистятся ли стринги внутри
     //exttype.freewithproc(basetypedescclear);
     zTraceLn('{T-}[ZSCRIPT]varmanager.done;//end');


     //programlog.LogOutStr('end;',lp_DecPos,LM_Trace);
end;
function varmanager.CreateVariable(varname: TInternalScriptString; var vd: vardesk;attr:TVariableAttributes=0):pvardesk;
var
  size: LongWord;
  i:TArrayIndex;
begin
       if vd.data.ptd<>nil then
                          size:=vd.data.ptd^.SizeInBytes
                      else
                          begin
                               size:=1;
                          end;
       if vd.data.Addr.Instance=nil then
       begin
         vd.SetInstance(@vararray,vararray.AllocData(size));
         //vd.Instance:=vararray.getDataMutable(vararray.AllocData(size));
         vd.data.PTD.InitInstance(vd.data.Addr.Instance);
       end;
       vd.attrib:=attr;
       i:=vardescarray.PushBackData(vd);
       result:=vardescarray.getDataMutable(i);
       //KillString(vd.name);
       //KillString(vd.username);
end;
function varmanager.CreateVariable2(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0):TInVectorAddr;
var
  size: LongWord;
  i:TArrayIndex;
begin
       if vd.data.ptd<>nil then
                          size:=vd.data.ptd^.SizeInBytes
                      else
                          begin
                               size:=1;
                          end;
       if vd.data.Addr.Instance=nil then
       begin
         vd.SetInstance(@vararray,vararray.AllocData(size));
         vd.data.PTD.InitInstance(vd.data.Addr.Instance);
       end;
       vd.attrib:=attr;
       Result.SetInstance(@vardescarray,vardescarray.PushBackData(vd));
end;
procedure varmanager.RemoveVariable(pvd:pvardesk);
begin
  pvd.data.PTD.MagicFreeInstance(pvd.data.Addr.GetInstance);
  Vardescarray.DeleteElementByP(pvd);
end;
function varmanager.findvardesc2(varname: TInternalScriptString):TInVectorAddr;
var
  //pblock: pdblock;
  pdesc: pvardesk;
  offset: Integer;
  temp: pvardesk;
  bc:PUserTypeDescriptor;
      ir:itrec;
begin
   pdesc:=self.vardescarray.beginiterate(ir);
   if pdesc<>nil then
     repeat
       if pdesc^.name=varname then begin
         result.SetInstance(@vardescarray,ir.itc);
         exit;
       end;
    pdesc:=self.vardescarray.iterate(ir);
    until pdesc=nil;
   result.SetInstance(nil,0);
end;

function getpattern(ptd:ptdarray; max:Integer;var line:TInternalScriptString; out typ:Integer):PTZctnrVectorStrings;
var i:Integer;
    parseresult:PTZctnrVectorStrings;
    parseerror:Boolean;
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
                                                Freemem(Pointer(parseresult));
                                                end;
                   end;
end;
function ObjOrRecordRead(TranslateFunc:TTranslateFunction;var f: TZctnrVectorBytes; var line,Stringtypearray:TInternalScriptString; var fieldoffset: SmallInt; ptd:PRecordDescriptor):Boolean;
type
    trrstate=(fields,metods);
var parseerror{,parsesuberror}:Boolean;
    parseresult{,parsesubresult}:PTZctnrVectorStrings;
    count,typ:Integer;
    {typename,}oldline, fieldname, {fieldvalue,} fieldtype, {sub, indmins, indmaxs, arrind1,}rname,wname,functionname,functionoperands: TInternalScriptString;
    fieldgdbtype:PUserTypeDescriptor;
    i: Integer;
//  indmin, indcount, size: LongWord;
//  etd:PUserTypeDescriptor;
//  addtype:Boolean;
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
//                     state:=state;
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
                                                    {IFDEF LOUDERRORS}
                                                       Raise Exception.Create('Something wrong');
                                                    {ENDIF}
                                                  end;
//                               if uppercase(functionname)='FORMAT' then
//                                                                   functionname:=functionname;

                               if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                               repeat
                               line := f.readtoparser(';');
                               parseresult:=getpattern(@parsefuncmodss,maxmod,line,typ); // длдл
                               case typ of
                                mod_virtual:begin
                                                 mattr:=mattr or m_virtual;
                                            end;
//                               mod_abstract:begin
//                                                 mattr:=mattr;
//                                            end;
                               end;
                               if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
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
//                      if fieldtype='Paths' then
//                                          fieldtype:=fieldtype;
                      {$IFNDEF DELPHI}
                      if assigned(TranslateFunc)then
                        fieldtype:=TranslateFunc(ptd.TypeName+'~'+getlastfirld.ProgramName,fieldtype);
                      {$ENDIF}
                      getlastfirld.username:={parseresult^.getString(0)}fieldtype;
                      //fieldtype:=parseresult^.getString(0);
                    end;
           membermodifier:
                          begin
                               if state<>metods then
                                                    begin
                                                      debugln('{E}Syntax error in file "%s"',[f.name]);
                                                      raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
                                                    end;

                          end;
          propertymember:
          begin
               if state<>metods then
                                    begin
                                      debugln('{E}Syntax error in file "%s"',[f.name]);
                                      raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
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
                                       {IFDEF LOUDERRORS}
                                         Raise Exception.Create('Something wrong');
                                      {ENDIF}
                                  end;
              //if parseresult<>nil then begin parseresult^.FreeAndDone;Freemem(Pointer(parseresult));end;
          end;
                    field:
                          begin
                               if state=metods then
                                                  begin
                                                    debugln('{E}Syntax error in file "%s"',[f.name]);
                                                    raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
                                                  end
                                               else
                                                   begin
                                                       {if (line='')or(count=5) then
                                                             line := f.readtoparser(';')
                                                         else
                                                             begin
                                                                  inc(count);
                                                             end;
                                                        parsesubresult:=runparser('_softspace'#0'=(=*_String'#0'=*=)',line,parsesuberror);}
                                                        fieldtype:=parseresult^.getData(parseresult.Count-1);
                                                        //pString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                                        fieldgdbtype:=PTUnit(PRecordDescriptor(ptd)^.punit).TypeName2PTD(fieldtype);
                                                        for i:=0 to parseresult.Count-2 do
                                                        begin
                                                             fieldname:=parseresult^.getData(i);
//                                                             if fieldname='PInOCS' then
//                                                                                           fieldname:=fieldname;
                                                             Stringtypearray := Stringtypearray + fieldname + #0;
                                                             if fieldsmode=primary then Stringtypearray := Stringtypearray+'P'
                                                                                   else Stringtypearray := Stringtypearray+'C';
                                                             //Stringtypearray := Stringtypearray + char(fieldsmode);
                                                             //Stringtypearray := Stringtypearray + pac_GDBWord_to_String(fieldgdbtype.gdbtypecustom) + pac_lGDBWord_to_String(fieldgdbtype.sizeinmem);
                                                             fd.base.ProgramName:=fieldname;
                                                             fd.base.PFT:=fieldgdbtype;
                                                             //Pointer(fd.base.UserName):=nil;
                                                             //fd.UserName:='sdfsdf';
                                                             fd.base.Attributes:=0;
                                                             fd.base.Saved:=0;
                                                             fd.Collapsed:=true;
                                                             //if fieldsmode<>primary then fd.Attributes:=fd.Attributes or FA_CALCULATED;
                                                             fd.Offset:=fieldoffset;
                                                             if fd.base.PFT<>nil then
                                                                                fd.Size:=fd.base.PFT^.SizeInBytes
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
           if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
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
function varmanager.getDS:Pointer;
begin
  result:=vararray.PArray;
end;

function varmanager.findfieldcustom;
var
  path,{sp,} {typeString,} sub, {field,} inds: TInternalScriptString;
  oper: ansichar;
  i, oldi, j, indexcount: Integer;
  pind: parrayindex;
  ind, sum: Integer;
  //sizeinmem: LongWord;
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
  //typeString := ptypedesk(Types.exttype.getDataMutable(pvardesk(pdesc)^.vartypecustom))^.tdesk;
  pt:=pointer(pvardesk(pdesc)^.data.ptd);// pointer(PUserTypeDescriptor(Types.exttype.getDataMutable(pvardesk(pdesc)^.vartypecustom)^));
     {result:=true;}
  repeat
    case oper of
      '.':
        begin
          //typeString := exttypearrayptr^.typearray[pvardesk(pdesc)^.vartypecustom].tdesk;
          //typeString := copy(typeString, 2, length(typeString));
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
                                       //typeString := ptypedesk(Types.exttype.getDataMutable(tc))^.tdesk;
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
          //typeString := copy(typeString, 2, length(typeString));
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
          {bt := Byte(typeString[i]);
          inc(i);}
//----------------------------------          tc := unpac_String_to_GDBWord(copy(typeString, i, 2));
          inc(i, 2);
          {sizeinmem :=} //unpac_String_to_lGDBWord(copy(typeString, i, 4));
             //offset:=offset+sizeinmem;
          inc(i, 4);
          indexcount :=-100;// unpac_String_to_GDBWord(copy(typeString, i, 2));
          inc(i, 2);
          //pind := @typeString[i];
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







function varmanager.findvardescbyinst(varinst:Pointer):pvardesk;
var
  //pblock: pdblock;
  pdesc: pvardesk;
  //offset: LongWord;
  //temp: pvardesk;
  //bc:PUserTypeDescriptor;
      ir:itrec;

begin
  result:=nil;
  pdesc:=self.vardescarray.beginiterate(ir);
  if pdesc<>nil then
  repeat
        if pdesc.data.Addr.Instance=varinst then
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
  //offset: LongWord;
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
  offset: Integer;
  temp: pvardesk;
  bc:PUserTypeDescriptor;
      ir:itrec;
begin
  //pblock := firstblockdesc;
  //while true do
  //begin
//    if varname='camera.point.x' then
//       varname:=varname;
    pdesc:=self.vardescarray.beginiterate(ir);
    if pdesc<>nil then
    repeat
    offset := 0;
      bc := nil;
//          if pdesc^.name='RD_BackGroundColor' then
//                                       varname:=varname;

          if findfieldcustom(PByte(pdesc), offset, bc, varname) then
      begin
        if offset = 0 then
        begin
          if (bc = nil) then
          begin
            result := Pointer(pdesc);
            exit;
          end
          else
          begin
            Getmem(Pointer(temp),sizeof(vardesk));
            fillchar(temp^,sizeof(vardesk),0);
            //new(temp);
            temp^.data:=pvardesk(pdesc)^.data;
            //temp^.Instance := pvardesk(pdesc)^.Instance;
            temp^.name := invar;
            temp^.data.ptd := bc;
            temp^.data.Addr.Instt.offs:=temp^.data.Addr.Instt.offs+offset;
            //inc(PByte(temp^.Instance), offset);
            result := temp;
            exit;
          end;
        end
        else
        begin
          Getmem(Pointer(temp),sizeof(vardesk));
          fillchar(temp^,sizeof(vardesk),0);
          //new(temp);
          temp^.data:=pvardesk(pdesc)^.data;
          //temp^.Instance := pvardesk(pdesc)^.Instance;
          temp^.name := invar;
          temp^.data.ptd := bc;
          temp^.data.Addr.Instt.offs:=temp^.data.Addr.Instt.offs+offset;
          //inc(PByte(temp^.Instance), offset);
          result := temp;
          exit;
        end
      end;
    pdesc:=self.vardescarray.iterate(ir);
    until pdesc=nil;
    result:=nil;
    {sizeused := pblock^.sizeused;
    Pointer(pdesc) := Pointer(pblock);
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
            result := Pointer(pdesc);
            exit;
          end
          else
          begin
            new(temp);
            temp^.pvalue := pvardesk(pdesc)^.pvalue;
            temp^.name := invar;
            temp^.vartype := bt;
            temp^.vartypecustom := bc;
            inc(PByte(temp^.pvalue), offset);
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
          inc(PByte(temp^.pvalue), offset);
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
  Pointer(name):=nil;
  name := nam;

  InterfaceVariables.init;
  InterfaceUses.init(10);
end;
destructor tsimpleunit.done;
begin
     InterfaceVariables.done;
     InterfaceUses.done;
     name:='';
end;
function tsimpleunit.FindValue(varname:TInternalScriptString):pvardesk;
var
  temp:pvardesk;
begin
     temp:=findvariable(varname);
     if assigned(temp)then
                          result:=temp{^.Instance}
                      else
                          result:=nil;
end;
function tsimpleunit.FindOrCreateValue(varname,vartype:TInternalScriptString):vardesk;
var
  temp:pvardesk;
begin
  temp:=FindValue(varname);
  if temp=nil then
    result:=CreateVariable(varname,vartype)
  else
    result:=temp^;
  {result:=FindValue(varname);
  if result=nil then
    result:=CreateVariable(varname,vartype);}
end;

function tsimpleunit.FindVariableByInstance(_Instance:Pointer):pvardesk;
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
     if (result=nil)and(InInterfaceOnly=False) then
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

function tsimpleunit.FindVarDesc(varname:TInternalScriptString):TInVectorAddr;
var p:ptunit;
    ir:itrec;
    i:integer;
begin
     result:=self.InterfaceVariables.findvardesc2(varname);
     if result.IsNil then begin
       p:=InterfaceUses.beginiterate(ir);
       if p<>nil then
         repeat
           result:=p^.FindVarDesc(varname);
           if not result.IsNil then
             exit;
           p:=InterfaceUses.iterate(ir);
         until p=nil;
     end;
end;

function tsimpleunit.CreateFixedVariable(varname,vartype:TInternalScriptString;_pinstance:pointer):Pointer;
var
  vd:vardesk;
begin
  setvardesc(vd, varname,'', vartype,_pinstance);
  InterfaceVariables.createvariable(varname,vd);
  result:=vd.data.Addr.Instance;
end;
function tsimpleunit.CreateVariable(varname,vartype:TInternalScriptString):vardesk;
var
  vd:vardesk;
begin
  setvardesc(vd, varname,'', vartype);
  InterfaceVariables.createvariable(varname,vd);
  result:=vd;
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

    FundamentalPStringDescriptorObj.init('String','PString',@self);

    FundamentalPAnsiStringDescriptorObj.init('AnsiString','PAnsiString',@self);
    FundamentalPAnsiStringDescriptorObj.Format;
    FundamentalPBooleanDescriptorObj.init('Boolean','PBoolean',@self);
    FundamentalPBooleanDescriptorObj.Format;
    FundamentalPIntegerDescriptorObj.init('Integer','PInteger',@self);
    FundamentalPIntegerDescriptorObj.Format;
    FundamentalPDoubleDescriptorObj.init('Double','PDouble',@self);
    FundamentalPDoubleDescriptorObj.Format;

    InterfaceTypes.AddTypeByRef(FundamentalPStringDescriptorObj);
    InterfaceTypes.AddTypeByRef(FundamentalPAnsiStringDescriptorObj);
    InterfaceTypes.AddTypeByRef(FundamentalPBooleanDescriptorObj);
    InterfaceTypes.AddTypeByRef(FundamentalPIntegerDescriptorObj);
    InterfaceTypes.AddTypeByRef(FundamentalPDoubleDescriptorObj);

    BaseTypesEndIndex:=InterfaceTypes.exttype.Count;

    if assigned(OnCreateSystemUnit) then
                                        OnCreateSystemUnit(@self);
  end;
end;
function tunit.SavePasToMem(var membuf:TZctnrVectorBytes):PUserTypeDescriptor;
var
   pu:PTUnit;
   pv:pvardesk;
   ir:itrec;
//   value:TInternalScriptString;
begin
     membuf.TXTAddString('unit ');
     membuf.TXTAddStringEOL(self.Name+';');
     membuf.TXTAddStringEOL('interface');
     if InterfaceUses.Count<>0 then
        begin
             pu:=InterfaceUses.beginiterate(ir);
             if pu<>nil then
                            begin
                                 membuf.TXTAddString('uses '+pu^.Name);
                            end;
             pu:=InterfaceUses.iterate(ir);
                          if pu<>nil then
                            repeat
                                 membuf.TXTAddString(','+pu^.Name);
                                 pu:=InterfaceUses.iterate(ir);
                            until pu=nil;
            membuf.TXTAddStringEOL(';');
        end;
     if InterfaceVariables.vardescarray.Count<>0 then
        begin
              membuf.TXTAddStringEOL('var');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 membuf.TXTAddString('  '+pv^.name+':');
                                 membuf.TXTAddString(pv.data.PTD.TypeName+';');
                                 if pv^.username<>'' then membuf.TXTAddString('(*'''+pv^.username+'''*)');
                                 membuf.TXTAddStringEOL('');
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
        end;
        begin
              membuf.TXTAddStringEOL('implementation');
              membuf.TXTAddStringEOL('begin');
              pv:=InterfaceVariables.vardescarray.beginiterate(ir);
                          if pv<>nil then
                            repeat
                                 pv.data.PTD.SavePasToMem(membuf,pv.data.Addr.Instance,'  '+pv^.name);
                                 {membuf.TXTAddString('  '+pv^.name+':=');
                                 value:=pv.data.PTD.GetValueAsString(pv.Instance);
                                 if pv.data.PTD=@FundamentalStringDescriptorObj then
                                             value:=''''+value+'''';

                                 membuf.TXTAddString(value+';');
                                 membuf.TXTAddStringEOL('');}
                                 pv:=InterfaceVariables.vardescarray.iterate(ir);
                            until pv=nil;
            membuf.TXTAddString('end.');
        end;
end;
destructor tunit.done;
begin
//     if name='devicebase' then
//                               name:=name;
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
  {IFDEF LOUDERRORS}
    //Raise Exception.Create('Something wrong');
  {ENDIF}
                       end;

end;
function tunit.TypeName2PTD;
//var p:ptunit;
begin
     result:=inherited TypeName2PTD(n);
     if result<>nil then
                        exit;
     result:=InterfaceTypes._TypeName2PTD(n);
     if result=nil then
       zTraceLn('{W}In unit "%s" not found type "%s"',[name,n]);

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
     pointer(psymbol):=vd^.data.Addr.Instance;
end;
function FindCategory(category:TInternalScriptString;var catname:TInternalScriptString):Pointer;
var
   ps:pString;
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
procedure SetCategoryCollapsed(category:TInternalScriptString;value:Boolean);
var
  cn:TInternalScriptString;
  pc:PBoolean;
begin
     pc:=FindCategory(category,cn);
     if pc<>@CategoryUnknownCOllapsed then
                                          pc^:=value;
end;

initialization;
begin
  zTraceLn('{D+}[ZSCRIPT]Varman.startup');
  //programlog.logoutstr('Varman.startup',lp_IncPos,LM_Debug);
  //DecimalSeparator := '.';
  ShortDateFormat:='MM.yy';
  VarCategory.init(100);
  //VarCategory.loadfromfile(expandpath('*rtl/VarCategory.cat'));
  CategoryCollapsed.init(VarCategory.Max);
  CategoryCollapsed.CreateArray;
  fillchar(CategoryCollapsed.parray^,CategoryCollapsed.max,byte(true));
  CategoryUnknownCOllapsed:=true;
  zTraceLn('{D-}[ZSCRIPT]end; {Varman.startup}');
  //programlog.logoutstr('end; {Varman.startup}',lp_DecPos,LM_Debug);
end;
finalization;
begin
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  VarCategory.Done;
  CategoryCollapsed.done;
end;
end.

