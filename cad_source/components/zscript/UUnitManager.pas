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

unit UUnitManager;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses LCLProc,uzbpaths,uzbstrproc,Varman,languade,gzctnrvectorobjects,SysUtils,
     UBaseTypeDescriptor,uzbtypesbase, uzbtypes,UGDBOpenArrayOfByte, strmy, varmandef,
     gzctnrvectortypes,gzctnrvectordata,uzctnrvectorgdbstring,TypeDescriptors,UEnumDescriptor,UArrayDescriptor,
     UPointerDescriptor,URecordDescriptor,UObjectDescriptor,USinonimDescriptor;
type
{EXPORT+}
    PTUnitManager=^TUnitManager;
    {REGISTEROBJECTTYPE TUnitManager}
    TUnitManager=object(GZVectorObjects{-}<TUnit>{//})
                       currentunit:PTUnit;
                       NextUnitManager:PTUnitManager;
                       constructor init;
                       function CreateUnit(PPaths:GDBString;TranslateFunc:TTranslateFunction;UName:GDBString):PTUnit;
                       function loadunit(PPaths:GDBString;TranslateFunc:TTranslateFunction;fname:GDBString; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       function parseunit(PPaths:GDBString;TranslateFunc:TTranslateFunction;var f: GDBOpenArrayOfByte; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       function changeparsemode(PPaths:GDBString;TranslateFunc:TTranslateFunction;newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
                       function findunit(PPaths:GDBString;TranslateFunc:TTranslateFunction;uname:GDBString):ptunit;virtual;
                       function FindOrCreateEmptyUnit(uname:GDBString):ptunit;virtual;
                       function internalfindunit(uname:GDBString):ptunit;virtual;
                       procedure SetNextManager(PNM:PTUnitManager);
                       procedure LoadFolder(PPaths:GDBString;TranslateFunc:TTranslateFunction;path: GDBString);

                       //procedure AfterObjectDone(p:PGDBaseObject);virtual;
                       procedure free;virtual;

                       procedure CreateExtenalSystemVariable(PPaths:GDBString;sysunitname:GDBString;TranslateFunc:TTranslateFunction;varname,vartype:GDBString;pinstance:Pointer);
                 end;
{EXPORT-}
var
   units:TUnitManager;
   IrInDBUnit:itrec;
   PVardeskInDBUnit:PVardesk;
   PVariantsField:PFieldDescriptor;
   PTObj:PPointer;
implementation
uses
    uzbmemman;
//var s:gdbstring;
const
     {GDBGDBPointerType:gdbtypedesk=
                                (
                                 TypeIndex:TGDBPointer;
                                 sizeinmem:sizeof(GDBPointer);
                                );}
     (*VMTBase:BaseDescriptor=
                           (
                           ProgramName:'#';
                           UserName:'Object';
                           PFT:@FundamentalPointerDescriptorOdj;
                           Attributes:{FA_HIDDEN_IN_OBJ_INSP or }FA_READONLY;
                           );*)
     FPVMT:FieldDescriptor=
                           (
                            base:(ProgramName:'#';
                                  UserName:'Object';
                                  PFT:@FundamentalPointerDescriptorOdj;
                                  Attributes:FA_HIDDEN_IN_OBJ_INSP or FA_READONLY
                                  );
                            //FieldName:'#';
                            //UserName:'Object';
                            //PFT:@FundamentalPointerDescriptorOdj;
                            Offset:0;
                            Size:sizeof(GDBPointer);
                            //Attributes:{FA_HIDDEN_IN_OBJ_INSP or }FA_READONLY
                            );
procedure TUnitManager.CreateExtenalSystemVariable(PPaths:GDBString;sysunitname:GDBString;TranslateFunc:TTranslateFunction;varname,vartype:GDBString;pinstance:Pointer);
begin
  //TODO: убрать такуюже шнягу из urtl, сделать создание SysUnit в одном месте
  if SysUnit=nil then
    begin
      units.loadunit(ppaths,TranslateFunc,sysunitname,nil);
      SysUnit:=units.findunit(PPaths,TranslateFunc,'System');
    end;
  if SysVarUnit=nil then
    begin
      SysVarUnit:=units.FindOrCreateEmptyUnit('sysvar');
      SysVarUnit.InterfaceUses.PushBackIfNotPresent(SysUnit);
    end;
  SysVarUnit.CreateVariable(varname,vartype,pinstance);
end;
{procedure TUnitManager.AfterObjectDone;
begin
     //GDBFreeMem(pointer(p));
end;}
procedure TUnitManager.free;
var //p:GDBPointer;
    //ir:itrec;
    i:integer;
    punit:pgdbaseobject;
begin
  GDBPlatformUInt(punit):=GDBPlatformUInt(parray)+SizeOfData*(count-1);
  for i := count-1 downto 0 do
  begin
       punit^.Done;
       //AfterObjectDone(punit);
       dec(GDBPlatformUInt(punit),SizeOfData);
  end;

  {p:=beginiterate(ir);
  if p<>nil then
  repeat
        pgdbaseobject(p).done;
        AfterObjectDone(p);
        p:=iterate(ir);
  until p=nil;}
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
  //nfn:gdbstring;
  //tcurrentunit:PTUnit;
begin
  p:=beginiterate(ir);
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
                              result:=NextUnitManager^.internalfindunit(uname);
end;
function TUnitManager.FindOrCreateEmptyUnit(uname:GDBString):ptunit;
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
  nfn:gdbstring;
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
                         nfn:=FindInSupportPath(PPaths,uname+'.pas');
                         if nfn<>'' then
                                        begin
                                             tcurrentunit:=currentunit;
                                             result:=self.loadunit(PPaths,TranslateFunc,nfn,nil);
                                             currentunit:=tcurrentunit;
                                        end;
                    end;                           
  
end;
function TUnitManager.changeparsemode(PPaths:GDBString;TranslateFunc:TTranslateFunction;newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
var i:GDBInteger;
    //line:GDBString;
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
  f: GDBOpenArrayOfByte;
begin
  f.InitFromFile(fname);
  result:=parseunit(ppaths,TranslateFunc,f,pcreatedunit);
  f.done;
  //result:=pointer(pcreatedunit);
end;
function TUnitManager.CreateUnit(PPaths:GDBString;TranslateFunc:TTranslateFunction;UName:GDBString):PTUnit;
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
          result.init(UName);
          pfu:=findunit(PPaths,TranslateFunc,'SYSTEM');
          if (pfu=nil)then
          begin
               pfu:=pointer(CreateObject);
               PTUnit(pfu)^.init('system');
          end;
          result.InterfaceUses.PushBackIfNotPresent(pfu);
        end;
end;

function TUnitManager.parseunit;
var
  varname, vartype,vuname, line,oldline,unitname: GDBString;
  vd: vardesk;
  //parsepos:GDBInteger;
  parseresult,subparseresult:PTZctnrVectorGDBString;
  mode:GDBInteger;
  parseerror,subparseerror:GDBBoolean;
  i:GDBInteger;
  {kolvo,}typ:GDBInteger;
  typename, {fieldname, fieldvalue,} fieldtype, GDBStringtypearray {sub,} {indmins, indmaxs,} {,arrind1}: GDBString;
  fieldgdbtype:pUserTypeDescriptor;
  fieldoffset: GDBSmallint;
  //handle,poz, kolvo, i,oldcount: GDBInteger;
  indmin, indcount, razmer: GDBInteger;
  etd:PUserTypeDescriptor;
  addtype:GDBBoolean;
  penu:penumodj;
  enumodj:tenumodj;
  currvalue,maxvalue:GDBLongword;
  enumobjlist:GZVectorData<tenumodj>;
  indexx:ArrayIndexDescriptor;
  p,pfu:pointer;
  unitpart:TunitPart;
    ir:itrec;
  //tempstring:gdbstring;
  doexit:gdbboolean;
begin
  unitpart:=tnothing;
  currentunit:=pointer(pcreatedunit);
  enumobjlist.init({$IFDEF DEBUGBUILD}'{43998D84-19F0-4356-A9B8-B2D86B29C623}',{$ENDIF}255{,sizeof(enumodj)});
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
                                        //FatalError('Unable to parse line "'+line+'"');
                                        debugln('Unable to parse line "'+line+'"');
                                        halt(0);
                                        line := f.readtoparser(';');
                                        //kolvo:=0;
                                   end
                                   else
                                       oldline:=line;
                   end;
    line:=readspace(line);
   if line='GDBObjLWPolyline=object(GDBObjWithLocalCS) Closed:GDBBoolean;' then
                  line:=line;
   if VerboseLog^ then
     DebugLn('{T}[ZSCRIPT]%s',[line]);

    //programlog.LogOutFormatStr('%s',[line],lp_OldPos,LM_Trace);

    parseresult:=getpattern(@parsemodetemplate,maxparsemodetemplate,line,typ);
    if typ>0 then
    begin
         if typ=beginmode then
                              typ:=typ;
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
                                                                           end;
                                                           if (pfu=nil)and(uppercase(pstring(p)^)='SYSTEM')then
                                                           begin
                                                                pfu:=pointer(CreateObject);
                                                                PTUnit(pfu)^.init('system');
                                                                CurrentUnit.InterfaceUses.PushBackIfNotPresent(pfu);
                                                           end;
                                                           p:=parseresult.iterate(ir);
                                                     until p=nil;
                                                end;
                              if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
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
                              if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
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
                                   DebugLn('{W}Unit "%s" already exists',[unitname]);
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
                              if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                         end;
                subunitmode:
                         begin
                              parseresult:=runparser('_identifier'#0'_softend'#0,line,parseerror);
                              currentunit:=findunit(PPaths,TranslateFunc,parseresult^.getData(0));
                              if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
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
                                              if (typename<>'')and(fieldtype<>'')then begin
                                                if assigned(TranslateFunc)then
                                                  VarCategory.PushBackIfNotPresent(fieldtype+'_'+TranslateFunc('zcadexternal.variablecategory~'+fieldtype,typename));
                                              end;
                                            end;
                                  identtype:begin
                                                  typename:=parseresult^.getData(0);
                                                  if typename='GDBXCoordinate' then
                                                                                  typename:=typename;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{611C73B3-FC2B-4E77-A58F-061B3C7707C8}',{$ENDIF}GDBPointer(etd),sizeof(GDBSinonimDescriptor));
                                                  PGDBSinonimDescriptor(etd)^.init(parseresult^.getData(1),typename,currentunit);
                                                  fieldoffset:=PGDBSinonimDescriptor(etd)^.SizeInGDBBytes;
                                             end;
                                      ptype:begin
                                                  typename:=parseresult^.getData(0);
                                                  if typename='PTUnitManager' then
                                                                                  typename:=typename;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{70AF3E6D-C33B-4878-9E59-9FDAF04540EE}',{$ENDIF}GDBPointer(etd),sizeof(GDBPointerDescriptor));
                                                  PGDBPointerDescriptor(etd)^.init(pGDBString(parseresult^.getDataMutable(1))^,typename,currentunit);
                                                  //GDBStringtypearray := chr(TGDBPointer)+pGDBString(parseresult^.getelement(1))^;
                                                  GDBStringtypearray:='';
                                                  fieldoffset := sizeof(pointer);
                                             end;
                                 recordtype,packedrecordtype:begin
                                                  typename:=parseresult^.getData(0);
                                                  if typ<>packedrecordtype then
                                                                               begin
                                                                               //ShowError('Record "'+typename+'" not packed');
                                                                               if VerboseLog^ then
                                                                                 debugln('{W}Record "'+typename+'" not packed');

                                                                               end;
                                                  if (typename) = 'tmemdeb'
                                                  then
                                                       typename:=typename;
                                                  //GDBStringtypearray := chr(Trecord);
                                                  fieldoffset:=0;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{32834740-66CF-48EE-8CFF-58FE55EA293B}',{$ENDIF}GDBPointer(etd),sizeof(RecordDescriptor));
                                                  PRecordDescriptor(etd)^.init(typename,currentunit);
                                                  ObjOrRecordRead(TranslateFunc,f,line,GDBStringtypearray,fieldoffset,GDBPointer(etd));
                                             end;
                                 objecttype,packedobjecttype:begin
                                                  {FPVMT}
                                                  typename:=parseresult^.getData(0);
                                                  if typ<>packedobjecttype then
                                                                               begin
                                                                               //ShowError('Object "'+typename+'" not packed');
                                                                               if VerboseLog^ then
                                                                                 debugln('{W}]Object "'+typename+'" not packed');

                                                                               end;
                                                  if (typename) = 'GDBObj3DFace'
                                                  then
                                                       typename:=typename;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{792FCD4D-5B31-441D-82DC-F62FE270D4DB}',{$ENDIF}GDBPointer(etd),sizeof(ObjectDescriptor));
                                                  PObjectDescriptor(etd)^.init(typename,currentunit);
                                                  //GDBStringtypearray := chr(TGDBobject);
                                                  GDBStringtypearray:='';
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  if (typename) = 'GDBaseObject'
                                                  then
                                                       begin
                                                            PObjectDescriptor(etd)^.Parent:=nil;
                                                            PObjectDescriptor(etd)^.AddConstField(FPVMT);
                                                            //fieldgdbtype:=Types.TypeName2TypeDesc('GDBPointer');
                                                            fieldoffset:=FPVMT.size;//fieldgdbtype.sizeinmem
                                                       end;
                                                  parseresult:=runparser('_softspace'#0'=(_softspace'#0'_identifier'#0'_softspace'#0'=)',line,parseerror);
                                              if parseerror then
                                                  begin
                                                       (*if uppercase(parseresult^.getData(0)) = 'GDBASEOBJECT'
                                                       then
                                                           begin
                                                                PObjectDescriptor(etd)^.Parent:=nil;
                                                                PObjectDescriptor(etd)^.AddConstField(FPVMT);

                                                                fieldgdbtype := Types.TypeName2TypeDesc('GDBPointer');
                                                                //GDBStringtypearray := GDBStringtypearray + 'PVMT'+ #0+ 'C' + pac_GDBWord_to_GDBString(fieldgdbtype.gdbtypecustom) + pac_lGDBWord_to_GDBString(fieldgdbtype.sizeinmem);
                                                                fieldoffset := {fieldoffset + }fieldgdbtype.sizeinmem
                                                           end
                                                      else*)
                                                          begin
                                                               fieldgdbtype := currentunit.TypeName2PTD(parseresult^.getData(0));
                                                               //programlog.logoutstr(parseresult^.getData(0),0);
                                                               //GDBStringtypearray :=ptypedesk(Types.exttype.getelement(fieldgdbtype.gdbtypecustom)^)^.tdesk;
                                                               PObjectDescriptor(fieldgdbtype)^.CopyTo(PObjectDescriptor(etd));
                                                               PObjectDescriptor(etd)^.Parent:=PObjectDescriptor(fieldgdbtype);
                                                               fieldoffset:=PUserTypeDescriptor(fieldgdbtype)^.SizeInGDBBytes;
                                                               if fieldoffset=dynamicoffset then
                                                               fieldoffset:=fieldoffset;

                                                          end;

                                                  end
                                                                else
                                                  begin
                                                  end;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  //etd.typeobj:=nil;
                                                  ObjOrRecordRead(TranslateFunc,f,line,GDBStringtypearray,fieldoffset,GDBPointer(etd));
                                                  PObjectDescriptor(etd)^.SimpleMenods.Shrink;
                                             end;
                              proceduraltype:begin
                                                  line:='';
                                                  addtype:=false;
                                             end;
                                  arraytype,packedarraytype:begin
                                                  typename:=pGDBString(parseresult^.getDataMutable(0))^;
                                                  if typ<>packedarraytype then
                                                                              begin
                                                                               //ShowError('Array "'+typename+'" not packed');
                                                                               if VerboseLog^ then
                                                                                 debugln('{W}Array "'+typename+'" not packed');

                                                                              end;
                                                  if typename='GDBPalette' then
                                                                              typename:=typename;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=[_intdiapazons_cs'#0'_softspace'#0'=]',line,parseerror);
                                                  subparseresult:=runparser('_softspace'#0'=o=f_softspace'#0'_identifier'#0'_softend'#0,line,parseerror);
                                                  //GDBStringtypearray := chr(Tarray);
                                                  GDBStringtypearray:='';
                                                  fieldtype:=subparseresult^.getData(0);
                                                  fieldgdbtype := currentunit.TypeName2PTD(fieldtype);
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{A1A1275E-CE41-4EF5-A95E-B0040B568B40}',{$ENDIF}GDBPointer(etd),sizeof(ArrayDescriptor));
                                                  PArrayDescriptor(etd)^.init(fieldgdbtype,typename,currentunit);
                                                  //GDBStringtypearray := GDBStringtypearray + pac_GDBWord_to_GDBString(fieldgdbtype.TypeIndex) + pac_lGDBWord_to_GDBString(fieldgdbtype.sizeinmem);
                                                  razmer := 1;
                                                  fieldoffset:=0;
                                                  //arrind1 := '';
                                                  for i := 0 to (parseresult^.Count div 2)-1 do
                                                  begin
                                                       indcount := strtoint(parseresult^.getData(i*2+1));
                                                       indmin := strtoint(parseresult^.getData(i*2));
                                                       indcount := indcount - indmin + 1;
                                                       razmer := razmer * indcount;
                                                       //arrind1 := arrind1 + pac_lGDBWord_to_GDBString(indmin) + pac_lGDBWord_to_GDBString(indcount);

                                                       indexx.IndexMin:=indmin;
                                                       indexx.IndexCount:=indcount;
                                                       PArrayDescriptor(etd)^.AddIndex(indexx);
                                                  end;
                                                  //GDBStringtypearray := GDBStringtypearray + pac_GDBWord_to_GDBString(parseresult^.Count div 2) + arrind1;
                                                  fieldoffset := razmer*fieldgdbtype.SizeInGDBBytes;
                                                  if subparseresult<>nil then begin subparseresult^.Done;GDBfreeMem(gdbpointer(subparseresult));end;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                             end;
                                    enumtype:begin
                                                  (*currvalue:=0;
                                                  maxvalue:=0;

                                                  typename:=pGDBString(parseresult^.getelement(0))^;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getData(0)
                                                                else HaltOnFatalError('Syntax error in file '+f.name);
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)',line,parseerror);
                                                  if parseerror then enumodj.user:=parseresult^.getData(0)
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getData(0))
                                                                else begin enumodj.value:=currvalue;inc(currvalue);end;
                                                  if maxvalue<enumodj.value then maxvalue:=enumodj.value;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=,',line,parseerror);
                                                  enumobjlist.add(@enumodj);
                                                  GDBPointer(enumodj.source):=nil;
                                                  GDBPointer(enumodj.value):=nil;
                                                  until not parseerror;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=)_softend'#0,line,parseerror);
                                                  if maxvalue<256 then maxvalue:=1
                                             else if maxvalue<65536 then maxvalue:=2
                                             else if maxvalue<4294967296 then maxvalue:=4
                                             else HaltOnFatalError('Syntax error in file '+f.name);
                                             gdbgetmem({$IFDEF DEBUGBUILD}'{F26A6C48-52FE-437C-A017-382135CC3DC7}',{$ENDIF}GDBPointer(etd),sizeof(EnumDescriptor));
                                             PEnumDescriptor(etd)^.init(maxvalue,typename);
                                             penu:=enumobjlist.beginiterate;
                                             if penu<>nil then
                                               repeat
                                                     PEnumDescriptor(etd)^.SourceValue.add(@penu^.source);
                                                     GDBPointer(penu^.source):=nil;
                                                     //penu^.source:='';
                                                     PEnumDescriptor(etd)^.UserValue.add(@penu^.user);
                                                     GDBPointer(penu^.user):=nil;
                                                     //penu^.user:='';
                                                     PEnumDescriptor(etd)^.Value.add(@penu^.value);
                                                     penu:=enumobjlist.iterate;
                                              until penu=nil;
                                             enumobjlist.clear;
                                             GDBStringtypearray := chr(Tenum);
                                             fieldoffset:=maxvalue;*)
                                                  currvalue:=0;
                                                  maxvalue:=0;
                                                  typename:=pGDBString(parseresult^.getDataMutable(0))^;
                                                  if typename='TInsUnits' then
                                                                                typename:=typename;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getData(0)
                                                                else
                                                                    begin
                                                                      //FatalError('Syntax error in file '+f.name);
                                                                      debugln('{E}Syntax error in file '+f.name);
                                                                      halt(0);
                                                                    end;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)',line,parseerror);
                                                  if parseerror then
                                                                    begin
                                                                         enumodj.user:=parseresult^.getData(0);
                                                                         //{$IFNDEF DELPHI}enumodj.user:=InterfaceTranslate(typename+'~'+enumodj.source,enumodj.user);{$ENDIF}
                                                                         if assigned(TranslateFunc)then
                                                                                                       enumodj.user:=TranslateFunc(typename+'~'+enumodj.source,enumodj.user);
                                                                    end
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getData(0))
                                                                else begin enumodj.value:=currvalue;inc(currvalue);end;
                                                  if maxvalue<enumodj.value then maxvalue:=enumodj.value;
                                                  if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=,',line,parseerror);
                                                  enumobjlist.PushBackData(enumodj);
                                                  //GDBPointer(enumodj.source):=nil;
                                                  //GDBPointer(enumodj.user):=nil;
                                                  until not parseerror;
                                                  runparser('_softspace'#0'=)_softend'#0,line,parseerror);
                                                  if maxvalue<256 then maxvalue:=1
                                             else if maxvalue<65536 then maxvalue:=2
                                             else if maxvalue<4294967296 then maxvalue:=4
                                             else begin
                                                   debugln('{E}Syntax error in file '+f.name);
                                                   halt(0);
                                                  end;
                                             gdbgetmem({$IFDEF DEBUGBUILD}'{F26A6C48-52FE-437C-A017-382135CC3DC7}',{$ENDIF}GDBPointer(etd),sizeof(EnumDescriptor));
                                             PEnumDescriptor(etd)^.init(maxvalue,typename,currentunit);
                                             penu:=enumobjlist.beginiterate(ir);
                                             if penu<>nil then
                                               repeat
                                                     PEnumDescriptor(etd)^.SourceValue.PushBackData(penu^.source);
                                                     //GDBPointer(penu^.source):=nil;
                                                     penu^.source:='';
                                                     PEnumDescriptor(etd)^.UserValue.PushBackData(penu^.user);
                                                     //GDBPointer(penu^.user):=nil;
                                                     penu^.user:='';
                                                     PEnumDescriptor(etd)^.Value.PushBackData(penu^.value);
                                                     penu:=enumobjlist.iterate(ir);
                                              until penu=nil;
                                             enumobjlist.clear;
                                             //GDBStringtypearray := chr(Tenum);
                                             GDBStringtypearray:='';
                                             fieldoffset:=maxvalue;

                                             end;
                                           0:begin
                                                  debugln('{E}Syntax error in file '+f.name);
                                                  halt(0);
                                                  //FatalError('Syntax error in file '+f.name)
                                             end;
                                end;

                                if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;




if addtype then
        begin
        //GDBPointer(etd.typeobj.typename):=nil;
        //GDBPointer(etd.tdesk):=nil;
        if fieldoffset <> dynamicoffset then etd^.SizeInGDBBytes := fieldoffset
                                        else etd^.SizeInGDBBytes := 0;
        //etd.tdesk := GDBStringtypearray;
        //etd.name := typename;

        //p:=@etd;
        currentunit.InterfaceTypes.{exttype.}AddTypeByPP(@etd);
        if VerboseLog^ then
          DebugLn('{T}[ZSCRIPT]Type "%s" added',[typename]);

        //programlog.LogOutFormatStr('Type "%s" added',[typename],lp_OldPos,LM_Trace);
        if typename='tdisp' then
                                typename:=typename;
        //GDBPointer(etd.name):=nil;
        //GDBPointer(etd.tdesk):=nil;
        end;
        //addtype:=true;
                           end;
                varmode:begin
                                if VerboseLog^ then
                                  DebugLn('{T}[ZSCRIPT]Varmode string: "%s"',[line]);

                                //programlog.LogOutFormatStr('Varmode string: "%s"',[line],lp_OldPos,LM_Trace);
                                //parsepos:=1;
                                parseresult:=runparser('_identifiers_cs'#0'=:_identifier'#0'_softend'#0,line,parseerror);
                                if line<>'' then
                                                line:=line;
                                {(template:'_softspace'#0'=(=*_GDBString'#0'=*=)';id:username)}

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
                                        //FatalError('Unable to parse line "'+line+'"');
                                        debugln('{E}Unable to parse line "'+line+'"');
                                        halt(0);
                                        line := f.readtoparser(';');
                                        //kolvo:=0;
                                   end
                                   else
                                       oldline:=line;
                   end;
    line:=readspace(line);

                                subparseresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)'#0,line,subparseerror);
                                vuname:='';
                                if (subparseresult<>nil)and subparseerror then
                                                                              vuname:=pGDBString(subparseresult^.getDataMutable(0))^;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pGDBString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pGDBString(parseresult^.getDataMutable(i))^;
                                     if varname='INTF_ObjInsp_WhiteBackground' then
                                                            varname:=varname;
                                     if currentunit^.FindVariable(varname)=nil then
                                     begin
                                     currentunit^.setvardesc(vd, varname,vuname, vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                     end;
                                end;
                                vuname:='';
                                if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                if subparseresult<>nil then begin subparseresult^.Done;GDBfreeMem(gdbpointer(subparseresult));end;
                           end;
                beginmode:begin
                                //parsepos:=1;
                                parseresult:=runparser('=e=n=d=.',line,parseerror);
                                if parseerror then
                                                   system.break
                                               else
                                                   begin
                                                        if VerboseLog^ then
                                                          DebugLn('{D}[ZSCRIPT]'+line);

                                                        //programlog.logoutstr(line,0,LM_Debug);
                                                        if copy(line,1,10)='VIEW_ObjIn'
                                                        then
                                                            line:=line;
                                                        line:=copy(line,1,pos(';',line)-1);
                                                        if line='camera.prop.point.x:=111.0'
                                                                 then
                                                                     line:=line;
                                                        vd:=evaluate(line,currentunit);
                                                        deletetempvar(vd);
                                                   end;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pGDBString(parseresult^.getDataMutable(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pGDBString(parseresult^.getDataMutable(i))^;
                                     currentunit^.setvardesc(vd, varname,'', vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                end;
                                if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
                                line:='';
                           end;
    end;
  end;
  result:=currentunit;
  enumobjlist.done;
end;
constructor TUnitManager.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{94D787E9-97EE-4198-8A72-5B904B98F275}',{$ENDIF}500{,sizeof(TUnit)});
     NextUnitManager:=nil;
end;
procedure TUnitManager.LoadFolder(PPaths:GDBString;TranslateFunc:TTranslateFunction;path: GDBString);
var
  sr: TSearchRec;
begin
  if VerboseLog^ then
    DebugLn('{T+}[ZSCRIPT]TUnitManager.LoadFolder(%s)',[path]);

  //programlog.LogOutFormatStr('TUnitManager.LoadFolder(%s)',[path],lp_IncPos,LM_Debug);
  if FindFirst(path + '*.pas', faAnyFile, sr) = 0 then
  begin
    repeat
      if VerboseLog^ then
        DebugLn('{T}[ZSCRIPT]Found file "%s"',[path+sr.Name]);
      //programlog.LogOutFormatStr('Found file "%s"',[path+sr.Name],lp_OldPos,LM_Info);
      loadunit(PPaths,TranslateFunc,path+sr.Name,nil);
    until FindNext(sr) <> 0;
    sysutils.FindClose(sr);
  end;
  if VerboseLog^ then
    DebugLn('{T-}[ZSCRIPT]end;{TUnitManager.LoadFolder}');
  //programlog.logoutstr('end;{TUnitManager.LoadFolder}',lp_DecPos,LM_Debug);
end;
initialization;
     units.init;
finalization;
     debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
     if DBUnit<>nil then
     begin
          PVardeskInDBUnit:=DBUnit.InterfaceVariables.vardescarray.beginiterate(IrInDBUnit);
          if PVardeskInDBUnit<>nil then
          repeat
                PVariantsField:=PTUserTypeDescriptor(PVardeskInDBUnit.data.PTD)^.FindField('Variants');
                if PVariantsField<>nil then
                begin
                     PTObj:=pointer(GDBPlatformUInt(PVardeskInDBUnit.data.Instance)+GDBPlatformUInt(PVariantsField.Offset));
                     (tobject(PTObj^).Free);
                end;
                PVardeskInDBUnit:=DBUnit.InterfaceVariables.vardescarray.iterate(IrInDBUnit);
          until PVardeskInDBUnit=nil
     end;
     units.Done;
end.
