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

unit UUnitManager;

{$MODE DELPHI}
interface
uses uzbpaths,uzbstrproc,Varman,languade,gzctnrVectorObjects,SysUtils,
     UBaseTypeDescriptor,uzctnrVectorBytesStream,uzsbLexParser,
     uzsbVarmanDef,gzctnrVectorTypes,gzctnrVector,uzctnrvectorstrings,
     uzsbTypeDescriptors,UEnumDescriptor,UArrayDescriptor,UPointerDescriptor,
     URecordDescriptor,UObjectDescriptor,USinonimDescriptor,uzbLogIntf;
type

    PTUnitManager=^TUnitManager;
    TUnitManager=object(GZVectorObjects<TUnit>)
                       currentunit:PTUnit;
                       NextUnitManager:PTUnitManager;
                       constructor init;
                       function CreateUnit(const PPaths:String;TranslateFunc:TTranslateFunction;const UName:String):PTUnit;
                       function loadunit(const PPaths:String;TranslateFunc:TTranslateFunction;const fname:String; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       procedure MagictypePostProcess(etd:PUserTypeDescriptor);
                       function parseunit(const PPaths:String;TranslateFunc:TTranslateFunction;var f: TZctnrVectorBytes; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       function changeparsemode(const PPaths:String;TranslateFunc:TTranslateFunction;newmode:Integer;var mode:Integer):pasparsemode;
                       function findunit(const PPaths:String;TranslateFunc:TTranslateFunction;const uname:String):ptunit;virtual;
                       function FindOrCreateEmptyUnit(const uname:String):ptunit;virtual;
                       function internalfindunit(const uname:String):ptunit;virtual;
                       procedure SetNextManager(PNM:PTUnitManager);
                       procedure LoadFolder(const PPaths:String;TranslateFunc:TTranslateFunction;const path: String);
                       procedure free;virtual;

                       procedure CreateExtenalSystemVariable(var VarUnit:PTUnit;const VarUnitName:string;const PPaths:String;const sysunitname:String;TranslateFunc:TTranslateFunction;const varname,vartype:String;pinstance:Pointer);
                       function CreateInternalSystemVariable(var VarUnit:PTUnit;const VarUnitName:string;const PPaths:String;const sysunitname:String;TranslateFunc:TTranslateFunction;const varname,vartype:String):vardesk;
                 end;

var
   units:TUnitManager;
   IrInDBUnit:itrec;
   PVardeskInDBUnit:PVardesk;
   PVariantsField:PFieldDescriptor;
   PTObj:PPointer;
implementation
procedure TUnitManager.CreateExtenalSystemVariable(var VarUnit:PTUnit;const VarUnitName:string;const PPaths:String;const sysunitname:String;TranslateFunc:TTranslateFunction;const varname,vartype:String;pinstance:Pointer);
begin
  //TODO: убрать такуюже шнягу из urtl, сделать создание SysUnit в одном месте
  if SysUnit=nil then
    begin
      if FileExists(sysunitname)then
        units.loadunit(ppaths,TranslateFunc,sysunitname,nil)
      else
        units.CreateUnit(ppaths,TranslateFunc,'System');
      SysUnit:=units.findunit(PPaths,TranslateFunc,'System');
    end;
  if VarUnit=nil then
    begin
      VarUnit:=units.FindOrCreateEmptyUnit(VarUnitName);
      VarUnit.InterfaceUses.PushBackIfNotPresent(SysUnit);
    end;
  VarUnit.CreateFixedVariable(varname,vartype,pinstance);
end;
function TUnitManager.CreateInternalSystemVariable(var VarUnit:PTUnit;const VarUnitName:string;const PPaths:String;const sysunitname:String;TranslateFunc:TTranslateFunction;const varname,vartype:String):vardesk;
begin
  //TODO: убрать такуюже шнягу из urtl, сделать создание SysUnit в одном месте
  if SysUnit=nil then
    begin
      if FileExists(sysunitname)then
        units.loadunit(ppaths,TranslateFunc,sysunitname,nil)
      else
        units.CreateUnit(ppaths,TranslateFunc,'System');
      SysUnit:=units.findunit(PPaths,TranslateFunc,'System');
    end;
  if VarUnit=nil then
    begin
      VarUnit:=units.FindOrCreateEmptyUnit(VarUnitName);
      VarUnit.InterfaceUses.PushBackIfNotPresent(SysUnit);
    end;
  result:=VarUnit.CreateVariable(varname,vartype);
end;
procedure TUnitManager.free;
var //p:Pointer;
    //ir:itrec;
    i:integer;
    punit:PTUnit;
begin
  PtrUInt(punit):=PtrUInt(parray)+SizeOfData*(count-1);
  for i := count-1 downto 0 do
  begin
       punit^.Done;
       //AfterObjectDone(punit);
       dec(PtrUInt(punit),SizeOfData);
  end;
  clear;
end;

procedure TUnitManager.SetNextManager;
begin
     NextUnitManager:=PNM;
end;
function TUnitManager.internalfindunit;
var
  p:PTUnit;
  ir:itrec;
  //nfn:String;
  //tcurrentunit:PTUnit;
  upper_uname: String;
begin
  p:=beginiterate(ir);
  //uname:=uppercase(uname);
  result:=nil;
  if p<>nil then
  begin
    upper_uname:=uppercase(uname);
    repeat
         if uppercase(p^.Name)=upper_uname then
                              begin
                                   result:=p;
                                   exit;
                              end;
         p:=iterate(ir);
    until p=nil;
  end;
  if NextUnitManager<>NIL then
                              result:=NextUnitManager^.internalfindunit(uname);
end;
function TUnitManager.FindOrCreateEmptyUnit(const uname:String):ptunit;
begin
   result:=internalfindunit(uname);
   if result=nil then
   begin
        result:=pointer(CreateObject);
        result^.init(uname);
   end;
end;

function TUnitManager.findunit;
var
  //p:PTUnit;
  //ir:itrec;
  nfn:String;
  tcurrentunit:PTUnit;
begin
  {p:=beginiterate(ir);
  //uname:=uppercase(uname);
  result:=nil;
  if p<>nil then
  repeat
       if uppercase(p^.Name)=uppercase(uname) then
                            begin
                                 result:=p;
                                 exit;
                            end;
       p:=iterate(ir);
  until p=nil;
  if NextUnitManager<>NIL then
                              result:=NextUnitManager^.findunit(uname);}
  result:=internalfindunit(uname);
  if result=nil then
                    begin
                         nfn:=FindInPaths(PPaths,uname+'.pas');
                         if nfn<>'' then
                                        begin
                                             tcurrentunit:=currentunit;
                                             result:=self.loadunit(PPaths,TranslateFunc,nfn,nil);
                                             currentunit:=tcurrentunit;
                                        end;
                    end;                           
  
end;
function TUnitManager.changeparsemode(const PPaths:String;TranslateFunc:TTranslateFunction;newmode:Integer;var mode:Integer):pasparsemode;
var i:Integer;
    //line:String;
    //fieldgdbtype: gdbtypedesk;
    pfu:pointer;
begin
     result:=modeOk;
     if mode=typemode then
     begin
          if currentunit.InterfaceTypes.{exttype.}getcount-1 <> OldTypesCount then
          for i := OldTypesCount to currentunit.InterfaceTypes.{exttype.}getcount - 1 do
          begin
               currentunit.TypeIndex2PTD(i)^.Format;
          end;
     end;
     if (mode=unitmode)and(newmode<>unitmode) then
     if (CurrentUnit<>nil) then
     if (CurrentUnit.InterfaceUses.Count=0) then
     begin
       pfu:=findunit(PPaths,TranslateFunc,'system');
       if (pfu<>nil)and(pfu<>CurrentUnit) then
       begin
            CurrentUnit.InterfaceUses.PushBackIfNotPresent(pfu);
       end;
     end;
     if newmode=endmode then
     begin
          if mode=beginmode then result:=modeEnd;
     end;
     if newmode=typemode then
                             OldTypesCount:=currentunit.InterfaceTypes.{exttype.}getCount;
     mode:=newmode;
end;
function TUnitManager.loadunit;
var
  f: TZctnrVectorBytes;
begin
  f.InitFromFile(fname);
  result:=parseunit(ppaths,TranslateFunc,f,pcreatedunit);
  f.done;
  //result:=pointer(pcreatedunit);
end;
function TUnitManager.CreateUnit(const PPaths:String;TranslateFunc:TTranslateFunction;const UName:String):PTUnit;
var
  pfu:PTUnit;
begin
        pfu:=findunit(PPaths,TranslateFunc,UName);
        if pfu<>nil then
                        begin
                             result:=pfu;
                        end
        else
        begin
          result:=pointer(CreateObject);
          currentunit:=pointer(result);
          result.init(UName);
          if UpperCase(UName)<>'SYSTEM' then begin
            pfu:=findunit(PPaths,TranslateFunc,'SYSTEM');
            if (pfu=nil)then
            begin
                 pfu:=pointer(CreateObject);
                 PTUnit(pfu)^.init('system');
            end;
            result.InterfaceUses.PushBackIfNotPresent(pfu);
          end;
        end;
end;

function GetGSTyprName(TypeName:string):string;
const
  gsp:string='TGetterSetter';
begin
  result:='';
  if Length(TypeName)<Length(gsp) then
    exit;
  if not CompareMem(@TypeName[1],@gsp[1],Length(gsp)) then
    exit;
  result:=copy(TypeName,length(gsp)+1,Length(TypeName)-Length(gsp));
end;

procedure TUnitManager.MagictypePostProcess(etd:PUserTypeDescriptor);
var
  gstn:string;
  gsft,gstd:PUserTypeDescriptor;
begin
  gstn:=GetGSTyprName(etd^.TypeName);
  if gstn<>'' then begin
    gsft:=currentunit.TypeName2PTD(gstn);
    if gsft<>nil then begin
      gstd:=currentunit.TypeName2PTD(format('TGetterSetter%s',[gsft^.TypeName]));
      if gstd<>nil then
        etd.pSuperTypeDeskriptor:=gstd;
    end;
  end;
end;

function TUnitManager.parseunit;
var
  varname, vartype,vuname, line,oldline,unitname: String;
  vd: vardesk;
  //parsepos:Integer;
  parseresult,subparseresult:PTZctnrVectorStrings;
  mode:Integer;
  parseerror,subparseerror:Boolean;
  i:Integer;
  {kolvo,}typ:Integer;
  typename, {fieldname, fieldvalue,} fieldtype, Stringtypearray {sub,} {indmins, indmaxs,} {,arrind1}: String;
  fieldgdbtype:pUserTypeDescriptor;
  fieldoffset: SmallInt;
  //handle,poz, kolvo, i,oldcount: Integer;
  indmin, indcount, razmer: Integer;
  etd:PUserTypeDescriptor;
  addtype:Boolean;
  penu:penumodj;
  enumodj:tenumodj;
  currvalue,maxvalue:LongWord;
  enumobjlist:GZVector<tenumodj>;
  indexx:ArrayIndexDescriptor;
  p,pfu:pointer;
  unitpart:TunitPart;
    ir:itrec;
  //tempstring:String;
  doexit:Boolean;
begin
  unitpart:=tnothing;
  currentunit:=pointer(pcreatedunit);
  enumobjlist.init(255);
  //f.init(1000);
  mode:=unitmode;
  line:='';
  //kolvo:=0;
  doexit:=false;
  while ((f.notEOF)or(line<>''))and(not doexit) do
  begin
    if line='' then
                   begin
                        line := f.readtoparser(';');
                        oldline:=line;
                        //kolvo:=0;
                   end
               else
                   begin
                        //inc(kolvo);
                        if {kolvo=20}line=oldline then
                                   begin
                                        zdebugln('{E}Unable to parse line "%s"',[line]);
                                        raise Exception.CreateFmt('Unable to parse line "%s"',[line]);
                                        line := f.readtoparser(';');
                                   end
                                   else
                                       oldline:=line;
                   end;
    line:=readspace(line);
//   if line='GDBObjLWPolyline=object(GDBObjWithLocalCS) Closed:Boolean;' then
//                  line:=line;
   zTraceLn('{T}[ZSCRIPT]%s',[line]);

    //programlog.LogOutFormatStr('%s',[line],lp_OldPos,LM_Trace);

    parseresult:=getpattern(@parsemodetemplate,maxparsemodetemplate,line,typ);
    if typ>0 then
    begin
//         if typ=beginmode then
//                              typ:=typ;
         case changeparsemode(PPaths,TranslateFunc,typ,mode) of
                                          modeEnd:
                                                  system.break;
         end;{case}
    end;
    line:=readspace(line);
    addtype:=true;
    if (line<>'')then
    case mode of
                usesmode:begin
                              //line:='';
                              parseresult:=runparser('_identifiers_cs'#0'_softend'#0,line,parseerror);
                              if parseerror then
                                                begin
                                                     p:=parseresult.beginiterate(ir);
                                                     if p<>nil then
                                                     repeat
                                                           pfu:=findunit(PPaths,TranslateFunc,pstring(p)^);
                                                           if pfu<>nil then
                                                                           begin
                                                                                CurrentUnit.InterfaceUses.PushBackIfNotPresent(pfu);
                                                                           end
                                                           else if (pfu=nil)and(uppercase(pstring(p)^)='SYSTEM')then
                                                           begin
                                                                pfu:=pointer(CreateObject);
                                                                PTUnit(pfu)^.init('system');
                                                                CurrentUnit.InterfaceUses.PushBackIfNotPresent(pfu);
                                                           end;
                                                           p:=parseresult.iterate(ir);
                                                     until p=nil;
                                                end;
                              if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                         end;
                usescopymode:begin
                              //line:='';
                              parseresult:=runparser('_identifiers_cs'#0'_softend'#0,line,parseerror);
                              if parseerror then
                                                begin
                                                     p:=parseresult.beginiterate(ir);
                                                     if p<>nil then
                                                     repeat
                                                           //tempstring:=(pstring(p)^);
                                                           pfu:=findunit(PPaths,TranslateFunc,pstring(p)^);
                                                           if pfu<>nil then
                                                                           begin
                                                                                CurrentUnit.CopyFrom(pfu);  //breakpoint
                                                                           end;
                                                           p:=parseresult.iterate(ir);
                                                     until p=nil;
                                                end;
                              if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                         end;
                unitmode:
                         begin
                              if unitpart=tnothing then
                                                      begin
                              parseresult:=runparser('_identifier'#0'_softend'#0,line,parseerror);
                              unitname:=parseresult^.getData(0);
                              if currentunit=nil then
                                begin
                                currentunit:=internalfindunit(unitname);
                                if currentunit<>nil then
                                   zDebugLn('{W}Unit "%s" already exists',[unitname]);
                                end;
                              if currentunit=nil
                                               then
                                                   begin
                                                   currentunit:=pointer(CreateObject);
                                                   currentunit^.init(unitname);
                                                   end;
                                                      end
                                                   else
                                                       begin

                                                       end;   
                              line:='';
                              if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                         end;
                subunitmode:
                         begin
                              parseresult:=runparser('_identifier'#0'_softend'#0,line,parseerror);
                              currentunit:=findunit(PPaths,TranslateFunc,parseresult^.getData(0));
                              if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                         end;
                interf:
                         begin
                              unitpart:=tinterf;
                         end;
                impl:
                         begin
                              unitpart:=timpl;
                         end;
                proceduremode,functionmode:
                         begin
                              doexit:=true;
                         end;
                typemode:begin
                                 parseresult:=getpattern(@parsetype,maxtype,line,typ); // длдл
                                case typ of
                           variablecategory:
                                            begin
                                              addtype:=false;
                                              typename:=parseresult^.getData(0)+'_'+parseresult^.getData(1);
                                              GetPartOfPath(fieldtype,typename,'_');
                                              RegisterVarCategory(fieldtype,typename,TranslateFunc);
                                              {if (typename<>'')and(fieldtype<>'')then begin
                                                if assigned(TranslateFunc)then
                                                  VarCategory.PushBackIfNotPresent(fieldtype+'_'+TranslateFunc('zcadexternal.variablecategory~'+fieldtype,typename));
                                              end;}
                                            end;
                                  identtype:begin
                                                  typename:=parseresult^.getData(0);
//                                                  if typename='TzeXUnits' then
//                                                                                  typename:=typename;
                                                  Getmem(Pointer(etd),sizeof(GDBSinonimDescriptor));
                                                  PGDBSinonimDescriptor(etd)^.init(parseresult^.getData(1),typename,currentunit);
                                                  fieldoffset:=PGDBSinonimDescriptor(etd)^.SizeInBytes;
                                             end;
                                      ptype:begin
                                                  typename:=parseresult^.getData(0);
//                                                  if typename='PTUnitManager' then
//                                                                                  typename:=typename;
                                                  Getmem(Pointer(etd),sizeof(GDBPointerDescriptor));
                                                  PGDBPointerDescriptor(etd)^.init(pString(parseresult^.getDataMutable(1))^,typename,currentunit);
                                                  //Stringtypearray := chr(TGDBPointer)+pString(parseresult^.getelement(1))^;
                                                  Stringtypearray:='';
                                                  fieldoffset := sizeof(pointer);
                                             end;
                                 recordtype,packedrecordtype:begin
                                                  typename:=parseresult^.getData(0);
                                                  if typ<>packedrecordtype then
                                                                               begin
                                                                               //ShowError('Record "'+typename+'" not packed');
                                                                               zTraceLn('{W}Record "%s" not packed',[typename]);

                                                                               end;
//                                                  if (typename) = 'tmemdeb'
//                                                  then
//                                                       typename:=typename;
                                                  //Stringtypearray := chr(Trecord);
                                                  fieldoffset:=0;
                                                  Getmem(Pointer(etd),sizeof(RecordDescriptor));
                                                  PRecordDescriptor(etd)^.init(typename,currentunit);
                                                  ObjOrRecordRead(TranslateFunc,f,line,Stringtypearray,fieldoffset,Pointer(etd));
                                             end;
                                 objecttype,packedobjecttype:begin
                                                  {FPVMT}
                                                  typename:=parseresult^.getData(0);
                                                  if typ<>packedobjecttype then
                                                                               begin
                                                                               //ShowError('Object "'+typename+'" not packed');
                                                                               zTraceLn('{W}Object "%s" not packed',[typename]);

                                                                               end;
//                                                  if (typename) = 'GDBObj3DFace'
//                                                  then
//                                                       typename:=typename;
                                                  Getmem(Pointer(etd),sizeof(ObjectDescriptor));
                                                  PObjectDescriptor(etd)^.init(typename,currentunit);
                                                  //Stringtypearray := chr(TGDBobject);
                                                  Stringtypearray:='';
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                                  if (typename) = 'GDBaseObject'
                                                  then
                                                       begin
                                                            PObjectDescriptor(etd)^.Parent:=nil;
                                                            PObjectDescriptor(etd)^.AddConstField(FPVMT);
                                                            //fieldgdbtype:=Types.TypeName2TypeDesc('Pointer');
                                                            fieldoffset:=FPVMT.size;//fieldgdbtype.sizeinmem
                                                       end;
                                                  parseresult:=runparser('_softspace'#0'=(_softspace'#0'_identifier'#0'_softspace'#0'=)',line,parseerror);
                                              if parseerror then
                                                  begin
                                                          begin
                                                               fieldgdbtype := currentunit.TypeName2PTD(parseresult^.getData(0));
                                                               if fieldgdbtype=nil then
                                                                 fieldgdbtype:=nil;
                                                               fieldgdbtype := currentunit.TypeName2PTD(parseresult^.getData(0));
                                                               //programlog.logoutstr(parseresult^.getData(0),0);
                                                               //Stringtypearray :=ptypedesk(Types.exttype.getelement(fieldgdbtype.gdbtypecustom)^)^.tdesk;
                                                               PObjectDescriptor(fieldgdbtype)^.CopyTo(PObjectDescriptor(etd));
                                                               PObjectDescriptor(etd)^.Parent:=PObjectDescriptor(fieldgdbtype);
                                                               fieldoffset:=PUserTypeDescriptor(fieldgdbtype)^.SizeInBytes;
//                                                               if fieldoffset=dynamicoffset then
//                                                               fieldoffset:=fieldoffset;

                                                          end;

                                                  end
                                                                else
                                                  begin
                                                  end;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                                  //etd.typeobj:=nil;
                                                  ObjOrRecordRead(TranslateFunc,f,line,Stringtypearray,fieldoffset,Pointer(etd));
                                                  PObjectDescriptor(etd)^.SimpleMenods.Shrink;
                                             end;
                              proceduraltype:begin
                                                  line:='';
                                                  addtype:=false;
                                             end;
                                  arraytype,packedarraytype:begin
                                                  typename:=pString(parseresult^.getDataMutable(0))^;
                                                  if typ<>packedarraytype then
                                                                              begin
                                                                               //ShowError('Array "'+typename+'" not packed');
                                                                               zTraceLn('{W}Array "%s" not packed',[typename]);

                                                                              end;
//                                                  if typename='GDBPalette' then
//                                                                              typename:=typename;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                                  parseresult:=runparser('_softspace'#0'=[_intdiapazons_cs'#0'_softspace'#0'=]',line,parseerror);
                                                  subparseresult:=runparser('_softspace'#0'=o=f_softspace'#0'_identifier'#0'_softend'#0,line,parseerror);
                                                  //Stringtypearray := chr(Tarray);
                                                  Stringtypearray:='';
                                                  fieldtype:=subparseresult^.getData(0);
                                                  fieldgdbtype := currentunit.TypeName2PTD(fieldtype);
                                                  Getmem(Pointer(etd),sizeof(ArrayDescriptor));
                                                  PArrayDescriptor(etd)^.init(fieldgdbtype,typename,currentunit);
                                                  //Stringtypearray := Stringtypearray + pac_GDBWord_to_String(fieldgdbtype.TypeIndex) + pac_lGDBWord_to_String(fieldgdbtype.sizeinmem);
                                                  razmer := 1;
                                                  fieldoffset:=0;
                                                  //arrind1 := '';
                                                  for i := 0 to (parseresult^.Count div 2)-1 do
                                                  begin
                                                       indcount := strtoint(parseresult^.getData(i*2+1));
                                                       indmin := strtoint(parseresult^.getData(i*2));
                                                       indcount := indcount - indmin + 1;
                                                       razmer := razmer * indcount;
                                                       //arrind1 := arrind1 + pac_lGDBWord_to_String(indmin) + pac_lGDBWord_to_String(indcount);

                                                       indexx.IndexMin:=indmin;
                                                       indexx.IndexCount:=indcount;
                                                       PArrayDescriptor(etd)^.AddIndex(indexx);
                                                  end;
                                                  //Stringtypearray := Stringtypearray + pac_GDBWord_to_String(parseresult^.Count div 2) + arrind1;
                                                  fieldoffset := razmer*fieldgdbtype.SizeInBytes;
                                                  if subparseresult<>nil then begin subparseresult^.Done;Freemem(Pointer(subparseresult));subparseresult:=nil;end;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                             end;
                                    enumtype:begin
                                                  (*currvalue:=0;
                                                  maxvalue:=0;

                                                  typename:=pString(parseresult^.getelement(0))^;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getData(0)
                                                                else HaltOnFatalError('Syntax error in file '+f.name);
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_String'#0'=*=)',line,parseerror);
                                                  if parseerror then enumodj.user:=parseresult^.getData(0)
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getData(0))
                                                                else begin enumodj.value:=currvalue;inc(currvalue);end;
                                                  if maxvalue<enumodj.value then maxvalue:=enumodj.value;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=,',line,parseerror);
                                                  enumobjlist.add(@enumodj);
                                                  Pointer(enumodj.source):=nil;
                                                  Pointer(enumodj.value):=nil;
                                                  until not parseerror;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=)_softend'#0,line,parseerror);
                                                  if maxvalue<256 then maxvalue:=1
                                             else if maxvalue<65536 then maxvalue:=2
                                             else if maxvalue<4294967296 then maxvalue:=4
                                             else HaltOnFatalError('Syntax error in file '+f.name);
                                             Getmem(Pointer(etd),sizeof(EnumDescriptor));
                                             PEnumDescriptor(etd)^.init(maxvalue,typename);
                                             penu:=enumobjlist.beginiterate;
                                             if penu<>nil then
                                               repeat
                                                     PEnumDescriptor(etd)^.SourceValue.add(@penu^.source);
                                                     Pointer(penu^.source):=nil;
                                                     //penu^.source:='';
                                                     PEnumDescriptor(etd)^.UserValue.add(@penu^.user);
                                                     Pointer(penu^.user):=nil;
                                                     //penu^.user:='';
                                                     PEnumDescriptor(etd)^.Value.add(@penu^.value);
                                                     penu:=enumobjlist.iterate;
                                              until penu=nil;
                                             enumobjlist.clear;
                                             Stringtypearray := chr(Tenum);
                                             fieldoffset:=maxvalue;*)
                                                  currvalue:=0;
                                                  maxvalue:=0;
                                                  typename:=pString(parseresult^.getDataMutable(0))^;
//                                                  if typename='TInsUnits' then
//                                                                                typename:=typename;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getData(0)
                                                                else
                                                                    begin
                                                                      //FatalError('Syntax error in file '+f.name);
                                                                      zdebugln('{E}Syntax error in file "%s"',[f.name]);
                                                                      raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
                                                                    end;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_String'#0'=*=)',line,parseerror);
                                                  if parseerror then
                                                                    begin
                                                                         enumodj.user:=parseresult^.getData(0);
                                                                         //{$IFNDEF DELPHI}enumodj.user:=InterfaceTranslate(typename+'~'+enumodj.source,enumodj.user);{$ENDIF}
                                                                         if assigned(TranslateFunc)then
                                                                                                       enumodj.user:=TranslateFunc(typename+'~'+enumodj.source,enumodj.user);
                                                                    end
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getData(0))
                                                                else begin enumodj.value:=currvalue;inc(currvalue);end;
                                                  if maxvalue<enumodj.value then maxvalue:=enumodj.value;
                                                  if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                                  parseresult:=runparser('_softspace'#0'=,',line,parseerror);
                                                  enumobjlist.PushBackData(enumodj);
                                                  //Pointer(enumodj.source):=nil;
                                                  //Pointer(enumodj.user):=nil;
                                                  until not parseerror;
                                                  runparser('_softspace'#0'=)_softend'#0,line,parseerror);
                                                  if maxvalue<256 then maxvalue:=1
                                             else if maxvalue<65536 then maxvalue:=2
                                             else if maxvalue<4294967296 then maxvalue:=4
                                             else begin
                                                    zdebugln('{E}Syntax error in file "%s"',[f.name]);
                                                    raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
                                                  end;
                                             Getmem(Pointer(etd),sizeof(EnumDescriptor));
                                             PEnumDescriptor(etd)^.init(maxvalue,typename,currentunit);
                                             penu:=enumobjlist.beginiterate(ir);
                                             if penu<>nil then
                                               repeat
                                                     PEnumDescriptor(etd)^.SourceValue.PushBackData(penu^.source);
                                                     //Pointer(penu^.source):=nil;
                                                     penu^.source:='';
                                                     PEnumDescriptor(etd)^.UserValue.PushBackData(penu^.user);
                                                     //Pointer(penu^.user):=nil;
                                                     penu^.user:='';
                                                     PEnumDescriptor(etd)^.Value.PushBackData(penu^.value);
                                                     penu:=enumobjlist.iterate(ir);
                                              until penu=nil;
                                             enumobjlist.clear;
                                             //Stringtypearray := chr(Tenum);
                                             Stringtypearray:='';
                                             fieldoffset:=maxvalue;

                                             end;
                                           0:begin
                                              zdebugln('{E}Syntax error in file "%s"',[f.name]);
                                              raise Exception.CreateFmt('Syntax error in file "%s"',[f.name]);
                                             end;
                                end;

                                if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;




if addtype then
        begin
        //Pointer(etd.typeobj.typename):=nil;
        //Pointer(etd.tdesk):=nil;
        if fieldoffset <> dynamicoffset then etd^.SizeInBytes := fieldoffset
                                        else etd^.SizeInBytes := 0;
        //etd.tdesk := Stringtypearray;
        //etd.name := typename;

        //p:=@etd;
        MagictypePostProcess(etd);
        currentunit.InterfaceTypes.{exttype.}AddTypeByPP(@etd);
        zTraceLn('{T}[ZSCRIPT]Type "%s" added',[typename]);

        //programlog.LogOutFormatStr('Type "%s" added',[typename],lp_OldPos,LM_Trace);
//        if typename='tdisp' then
//                                typename:=typename;
        //Pointer(etd.name):=nil;
        //Pointer(etd.tdesk):=nil;
        end;
        //addtype:=true;
                           end;
                varmode:begin
                                zTraceLn('{T}[ZSCRIPT]Varmode string: "%s"',[line]);

                                //programlog.LogOutFormatStr('Varmode string: "%s"',[line],lp_OldPos,LM_Trace);
                                //parsepos:=1;
                                parseresult:=runparser('_identifiers_cs'#0'=:_identifier'#0'_softend'#0,line,parseerror);
//                                if line<>'' then
//                                                line:=line;
                                {(template:'_softspace'#0'=(=*_String'#0'=*=)';id:username)}

    if line='' then
                   begin
                        line := f.readtoparser(';');
                        oldline:=line;
                        //kolvo:=0;
                   end
               else
                   begin
                        //inc(kolvo);
                        if {kolvo=20}line=oldline then
                                   begin
                                     zdebugln('{E}Unable to parse line "%s"',[line]);
                                     raise Exception.CreateFmt('Unable to parse line "%s"',[line]);
                                   end
                                   else
                                       oldline:=line;
                   end;
    line:=readspace(line);

                                subparseresult:=runparser('_softspace'#0'=(=*_String'#0'=*=)'#0,line,subparseerror);
                                vuname:='';
                                if (subparseresult<>nil)and subparseerror then
                                                                              vuname:=pString(subparseresult^.getDataMutable(0))^;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pString(parseresult^.getDataMutable(i))^;
//                                     if varname='INTF_ObjInsp_WhiteBackground' then
//                                                            varname:=varname;
                                     if currentunit^.FindVariable(varname,true)=nil then
                                     begin
                                     currentunit^.setvardesc(vd, varname,vuname, vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                     end;
                                end;
                                vuname:='';
                                if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                if subparseresult<>nil then begin subparseresult^.Done;Freemem(Pointer(subparseresult));subparseresult:=nil;end;
                           end;
                beginmode:begin
                                //parsepos:=1;
                                parseresult:=runparser('=e=n=d=.',line,parseerror);
                                if parseerror then
                                                   system.break
                                               else
                                                   begin
                                                        zTraceLn('{D}[ZSCRIPT]%s',[line]);

                                                        //programlog.logoutstr(line,0,LM_Debug);
                                                        //if copy(line,1,10)='VIEW_ObjIn'
                                                        //then
                                                        //    line:=line;
                                                        line:=copy(line,1,PosWithBracket(';','''','''',line,1,0)-1);
//                                                        if line='camera.prop.point.x:=111.0'
//                                                                 then
//                                                                     line:=line;
                                                        vd:=evaluate(line,currentunit);
                                                        ClearTempVariable(vd);
                                                   end;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pString(parseresult^.getDataMutable(i))^;
                                     currentunit^.setvardesc(vd, varname,'', vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                end;
                                if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));parseresult:=nil;end;
                                line:='';
                           end;
    end;
  end;
  result:=currentunit;
  enumobjlist.done;
end;
constructor TUnitManager.init;
begin
     inherited init(500);
     NextUnitManager:=nil;
end;
procedure TUnitManager.LoadFolder(const PPaths:String;TranslateFunc:TTranslateFunction;const path: String);
var
  sr: TSearchRec;
begin
  zTraceLn('{T+}[ZSCRIPT]TUnitManager.LoadFolder(%s)',[path]);

  //programlog.LogOutFormatStr('TUnitManager.LoadFolder(%s)',[path],lp_IncPos,LM_Debug);
  if FindFirst(path + '*.pas', faAnyFile, sr) = 0 then
  begin
    repeat
      zTraceLn('{T}[ZSCRIPT]Found file "%s%s"',[path,sr.Name]);
      //programlog.LogOutFormatStr('Found file "%s"',[path+sr.Name],lp_OldPos,LM_Info);
      loadunit(PPaths,TranslateFunc,path+sr.Name,nil);
    until FindNext(sr) <> 0;
    sysutils.FindClose(sr);
  end;
  zTraceLn('{T-}[ZSCRIPT]end;{TUnitManager.LoadFolder}');
  //programlog.logoutstr('end;{TUnitManager.LoadFolder}',lp_DecPos,LM_Debug);
end;
initialization;
     units.init;
finalization;
     zdebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
     if DBUnit<>nil then
     begin
          PVardeskInDBUnit:=DBUnit.InterfaceVariables.vardescarray.beginiterate(IrInDBUnit);
          if PVardeskInDBUnit<>nil then
          repeat
                PVariantsField:=PTUserTypeDescriptor(PVardeskInDBUnit.data.PTD)^.FindField('Variants');
                if PVariantsField<>nil then
                begin
                     PTObj:=pointer(PtrUInt(PVardeskInDBUnit.data.Addr.Instance)+PtrUInt(PVariantsField.Offset));
                     (tobject(PTObj^).Free);
                end;
                PVardeskInDBUnit:=DBUnit.InterfaceVariables.vardescarray.iterate(IrInDBUnit);
          until PVardeskInDBUnit=nil
     end;
     units.Done;
end.
