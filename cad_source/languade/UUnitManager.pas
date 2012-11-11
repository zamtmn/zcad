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
interface
uses zcadsysvars,zcadstrconsts,intftranslations,strproc,Varman,languade,UGDBOpenArrayOfObjects,{RegCnownTypes,URegisterObjects,}SysUtils,
     UBaseTypeDescriptor,gdbasetypes, shared,gdbase,UGDBOpenArrayOfByte, strmy, varmandef,sysinfo,
     UGDBOpenArrayOfData,UGDBStringArray,TypeDescriptors,UEnumDescriptor,UArrayDescriptor,UPointerDescriptor,
     URecordDescriptor,UObjectDescriptor,USinonimDescriptor;
type
{EXPORT+}
    PTUnitManager=^TUnitManager;
    TUnitManager=object(GDBOpenArrayOfObjects)
                       currentunit:PTUnit;
                       NextUnitManager:PTUnitManager;
                       constructor init;
                       function loadunit(fname:GDBString; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       function parseunit(var f: GDBOpenArrayOfByte; pcreatedunit:PTSimpleUnit):ptunit;virtual;
                       function changeparsemode(newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
                       function findunit(uname:GDBString):ptunit;virtual;
                       function internalfindunit(uname:GDBString):ptunit;virtual;
                       procedure SetNextManager(PNM:PTUnitManager);
                       procedure LoadFolder(path: GDBString);

                       procedure AfterObjectDone(p:PGDBaseObject);virtual;
                       procedure free;virtual;
                 end;
{EXPORT-}                 
var units:TUnitManager;
    //SysUnit,SysVarUnit:PTUnit;
//procedure startup;
//procedure finalize;
implementation
uses
    log,memman;
var s:gdbstring;
const
     {GDBGDBPointerType:gdbtypedesk=
                                (
                                 TypeIndex:TGDBPointer;
                                 sizeinmem:sizeof(GDBPointer);
                                );}
     VMTBase:BaseDescriptor=
                           (
                           ProgramName:'#';
                           UserName:'Object';
                           PFT:@GDBPointerDescriptorOdj;
                           Attributes:{FA_HIDDEN_IN_OBJ_INSP or }FA_READONLY;
                           );
     FPVMT:FieldDescriptor=
                           (
                            base:(
                                  ProgramName:'#';
                           UserName:'Object';
                           PFT:@GDBPointerDescriptorOdj;
                           Attributes:{FA_HIDDEN_IN_OBJ_INSP or }FA_READONLY;
                           );
                            //FieldName:'#';
                            //UserName:'Объект';
                            //PFT:@GDBPointerDescriptorOdj;
                            Offset:0;
                            Size:sizeof(GDBPointer);
                            //Attributes:{FA_HIDDEN_IN_OBJ_INSP or }FA_READONLY;
                            );
procedure TUnitManager.AfterObjectDone;
begin
     //GDBFreeMem(pointer(p));
end;
procedure TUnitManager.free;
var //p:GDBPointer;
    //ir:itrec;
    i:integer;
    punit:pgdbaseobject;
begin
  GDBPlatformint(punit):=GDBPlatformint(parray)+size*(count-1);
  for i := count-1 downto 0 do
  begin
       punit^.Done;
       AfterObjectDone(punit);
       dec(GDBPlatformint(punit),size);
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
  nfn:gdbstring;
  tcurrentunit:PTUnit;
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
                              result:=NextUnitManager^.findunit(uname);
end;

function TUnitManager.findunit;
var
  p:PTUnit;
  ir:itrec;
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
                         nfn:=FindInSupportPath(uname+'.pas');
                         if nfn<>'' then
                                        begin
                                             tcurrentunit:=currentunit;
                                             result:=self.loadunit(nfn,nil);
                                             currentunit:=tcurrentunit;
                                        end;
                    end;                           
  
end;
function TUnitManager.changeparsemode(newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
var i:GDBInteger;
    //line:GDBString;
    //fieldgdbtype: gdbtypedesk;
begin
     result:=modeOk;
     if mode=typemode then
     begin
          if currentunit.InterfaceTypes.exttype.count-1 <> OldTypesCount then
          for i := OldTypesCount to currentunit.InterfaceTypes.exttype.count - 1 do
          begin
               currentunit.TypeIndex2PTD(i)^.Format;
          end;
     end;
     if newmode=endmode then
     begin
          if mode=beginmode then result:=modeEnd;
     end;
     if newmode=typemode then
                             OldTypesCount:=currentunit.InterfaceTypes.exttype.Count;
     mode:=newmode;
end;
function TUnitManager.loadunit;
var
  f: GDBOpenArrayOfByte;
begin
  f.InitFromFile(fname);
  result:=parseunit(f,pcreatedunit);
  f.done;
  //result:=pointer(pcreatedunit);
end;
function TUnitManager.parseunit;
var
  varname, vartype,vuname, line,oldline{,uline}: GDBString;
  vd: vardesk;
  //parsepos:GDBInteger;
  parseresult,subparseresult:PGDBGDBStringArray;
  mode:GDBInteger;
  parseerror,subparseerror:GDBBoolean;
  i:GDBInteger;
  {kolvo,}typ:GDBInteger;
  typename, {fieldname, fieldvalue,} fieldtype, GDBStringtypearray, {sub,} {indmins, indmaxs,} arrind1: GDBString;
  fieldgdbtype:pUserTypeDescriptor;
  fieldoffset: GDBSmallint;
  //handle,poz, kolvo, i,oldcount: GDBInteger;
  indmin, indcount, razmer: GDBInteger;
  etd:PUserTypeDescriptor;
  addtype:GDBBoolean;
  penu:penumodj;
  enumodj:tenumodj;
  currvalue,maxvalue:GDBLongword;
  enumobjlist:GDBOpenArrayOfData;
  indexx:ArrayIndexDescriptor;
  p,pfu:pointer;
  unitpart:TunitPart;
    ir:itrec;
  tempstring:gdbstring;
begin
  unitpart:=tnothing;
  currentunit:=pointer(pcreatedunit);
  enumobjlist.init({$IFDEF DEBUGBUILD}'{43998D84-19F0-4356-A9B8-B2D86B29C623}',{$ENDIF}255,sizeof(enumodj));
  //f.init(1000);
  mode:=unitmode;
  line:='';
  //kolvo:=0;
  while (f.notEOF)or(line<>'') do
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
                                        FatalError('Unable to parse line "'+line+'"');
                                        line := f.readtoparser(';');
                                        //kolvo:=0;
                                   end
                                   else
                                       oldline:=line;
                   end;
    line:=readspace(line);
   if line='GDBObjLWPolyline=object(GDBObjWithLocalCS) Closed:GDBBoolean;' then
                  line:=line;

    {$IFDEF TOTALYLOG}programlog.logoutstr(line,0);{$ENDIF}

    parseresult:=getpattern(@parsemodetemplate,maxparsemodetemplate,line,typ);
    if typ>0 then
    begin
         if typ=beginmode then
                              typ:=typ;
         case changeparsemode(typ,mode) of
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
                                                           pfu:=findunit(pstring(p)^);
                                                           if pfu<>nil then
                                                                           begin
                                                                                CurrentUnit.InterfaceUses.addnodouble(@pfu);
                                                                           end;
                                                           p:=parseresult.iterate(ir);
                                                     until p=nil;
                                                end;
                              if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                         end;
                usescopymode:begin
                              //line:='';
                              parseresult:=runparser('_identifiers_cs'#0'_softend'#0,line,parseerror);
                              if parseerror then
                                                begin
                                                     p:=parseresult.beginiterate(ir);
                                                     if p<>nil then
                                                     repeat
                                                           tempstring:=(pstring(p)^);
                                                           pfu:=findunit(pstring(p)^);
                                                           if pfu<>nil then
                                                                           begin
                                                                                CurrentUnit.CopyFrom(pfu);  //breakpoint
                                                                           end;
                                                           p:=parseresult.iterate(ir);
                                                     until p=nil;
                                                end;
                              if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                         end;
                unitmode:
                         begin
                              if unitpart=tnothing then
                                                      begin
                              parseresult:=runparser('_identifier'#0'_softend'#0,line,parseerror);
                              if currentunit=nil
                                               then
                                                   begin
                                                   currentunit:=pointer(CreateObject);
                                                   currentunit^.init(parseresult^.getGDBString(0));
                                                   end;
                                                      end
                                                   else
                                                       begin

                                                       end;   
                              line:='';
                              if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                         end;
                subunitmode:
                         begin
                              parseresult:=runparser('_identifier'#0'_softend'#0,line,parseerror);
                              currentunit:=findunit(parseresult^.getGDBString(0));
                              if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                         end;
                interf:
                         begin
                              unitpart:=tinterf;
                         end;
                impl:
                         begin
                              unitpart:=timpl;
                         end;

                typemode:begin
                                 parseresult:=getpattern(@parsetype,maxtype,line,typ); // длдл
                                case typ of
                                  identtype:begin
                                                  typename:=parseresult^.getGDBString(0);
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{611C73B3-FC2B-4E77-A58F-061B3C7707C8}',{$ENDIF}GDBPointer(etd),sizeof(GDBSinonimDescriptor));
                                                  PGDBSinonimDescriptor(etd)^.init(parseresult^.getGDBString(1),parseresult^.getGDBString(0),currentunit);
                                             end;
                                      ptype:begin
                                                  typename:=parseresult^.getGDBString(0);
                                                  if typename='PTUnitManager' then
                                                                                  typename:=typename;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{70AF3E6D-C33B-4878-9E59-9FDAF04540EE}',{$ENDIF}GDBPointer(etd),sizeof(GDBPointerDescriptor));
                                                  PGDBPointerDescriptor(etd)^.init(pGDBString(parseresult^.getelement(1))^,typename,currentunit);
                                                  //GDBStringtypearray := chr(TGDBPointer)+pGDBString(parseresult^.getelement(1))^;
                                                  GDBStringtypearray:='';
                                                  fieldoffset := sizeof(pointer);
                                             end;
                                 recordtype:begin
                                                  typename:=parseresult^.getGDBString(0);
                                                  if (typename) = 'TRestoreMode'
                                                  then
                                                       typename:=typename;
                                                  //GDBStringtypearray := chr(Trecord);
                                                  fieldoffset:=0;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{32834740-66CF-48EE-8CFF-58FE55EA293B}',{$ENDIF}GDBPointer(etd),sizeof(RecordDescriptor));
                                                  PRecordDescriptor(etd)^.init(typename,currentunit);
                                                  ObjOrRecordRead(f,line,GDBStringtypearray,fieldoffset,GDBPointer(etd));
                                             end;
                                 objecttype:begin
                                                  {FPVMT}
                                                  typename:=parseresult^.getGDBString(0);
                                                  if (typename) = 'GDBObj3DFace'
                                                  then
                                                       typename:=typename;
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{792FCD4D-5B31-441D-82DC-F62FE270D4DB}',{$ENDIF}GDBPointer(etd),sizeof(ObjectDescriptor));
                                                  PObjectDescriptor(etd)^.init(typename,currentunit);
                                                  //GDBStringtypearray := chr(TGDBobject);
                                                  GDBStringtypearray:='';
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
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
                                                       (*if uppercase(parseresult^.getGDBString(0)) = 'GDBASEOBJECT'
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
                                                               fieldgdbtype := currentunit.TypeName2PTD(parseresult^.getGDBString(0));
                                                               //programlog.logoutstr(parseresult^.getGDBString(0),0);
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
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  //etd.typeobj:=nil;
                                                  ObjOrRecordRead(f,line,GDBStringtypearray,fieldoffset,GDBPointer(etd));
                                                  PObjectDescriptor(etd)^.SimpleMenods.Shrink;
                                             end;
                              proceduraltype:begin
                                                  line:='';
                                                  addtype:=false;
                                             end;
                                  arraytype:begin
                                                  typename:=pGDBString(parseresult^.getelement(0))^;
                                                  if typename='GDBPalette' then
                                                                              typename:=typename;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=[_intdiapazons_cs'#0'_softspace'#0'=]',line,parseerror);
                                                  subparseresult:=runparser('_softspace'#0'=o=f_softspace'#0'_identifier'#0'_softend'#0,line,parseerror);
                                                  //GDBStringtypearray := chr(Tarray);
                                                  GDBStringtypearray:='';
                                                  fieldtype:=subparseresult^.getGDBString(0);
                                                  fieldgdbtype := currentunit.TypeName2PTD(fieldtype);
                                                  gdbgetmem({$IFDEF DEBUGBUILD}'{A1A1275E-CE41-4EF5-A95E-B0040B568B40}',{$ENDIF}GDBPointer(etd),sizeof(ArrayDescriptor));
                                                  PArrayDescriptor(etd)^.init(fieldgdbtype,typename,currentunit);
                                                  //GDBStringtypearray := GDBStringtypearray + pac_GDBWord_to_GDBString(fieldgdbtype.TypeIndex) + pac_lGDBWord_to_GDBString(fieldgdbtype.sizeinmem);
                                                  razmer := 1;
                                                  fieldoffset:=0;
                                                  arrind1 := '';
                                                  for i := 0 to (parseresult^.Count div 2)-1 do
                                                  begin
                                                       indcount := strtoint(parseresult^.getGDBString(i*2+1));
                                                       indmin := strtoint(parseresult^.getGDBString(i*2));
                                                       indcount := indcount - indmin + 1;
                                                       razmer := razmer * indcount;
                                                       arrind1 := arrind1 + pac_lGDBWord_to_GDBString(indmin) + pac_lGDBWord_to_GDBString(indcount);

                                                       indexx.IndexMin:=indmin;
                                                       indexx.IndexCount:=indcount;
                                                       PArrayDescriptor(etd)^.AddIndex(indexx);
                                                  end;
                                                  GDBStringtypearray := GDBStringtypearray + pac_GDBWord_to_GDBString(parseresult^.Count div 2) + arrind1;
                                                  fieldoffset := razmer*fieldgdbtype.SizeInGDBBytes;
                                                  if subparseresult<>nil then begin subparseresult^.FreeAndDone;GDBfreeMem(gdbpointer(subparseresult));end;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                             end;
                                    enumtype:begin
                                                  (*currvalue:=0;
                                                  maxvalue:=0;

                                                  typename:=pGDBString(parseresult^.getelement(0))^;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getGDBString(0)
                                                                else HaltOnFatalError('Syntax error in file '+f.name);
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)',line,parseerror);
                                                  if parseerror then enumodj.user:=parseresult^.getGDBString(0)
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getGDBString(0))
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
                                                  typename:=pGDBString(parseresult^.getelement(0))^;
                                                  if typename='TRestoreMode' then
                                                                                typename:=typename;
                                                  repeat
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_identifier'#0,line,parseerror);
                                                  if parseerror then enumodj.source:=parseresult^.getGDBString(0)
                                                                else FatalError('Syntax error in file '+f.name);
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=(=*_GDBString'#0'=*=)',line,parseerror);
                                                  if parseerror then
                                                                    begin
                                                                         enumodj.user:=parseresult^.getGDBString(0);
                                                                         enumodj.user:=InterfaceTranslate(typename+'~'+enumodj.source,enumodj.user);
                                                                    end
                                                                else enumodj.user:=enumodj.source;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'==_intnumber'#0,line,parseerror);
                                                  if parseerror then enumodj.value:=strtoint(parseresult^.getGDBString(0))
                                                                else begin enumodj.value:=currvalue;inc(currvalue);end;
                                                  if maxvalue<enumodj.value then maxvalue:=enumodj.value;
                                                  if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                                  parseresult:=runparser('_softspace'#0'=,',line,parseerror);
                                                  enumobjlist.add(@enumodj);
                                                  GDBPointer(enumodj.source):=nil;
                                                  GDBPointer(enumodj.user):=nil;
                                                  until not parseerror;
                                                  runparser('_softspace'#0'=)_softend'#0,line,parseerror);
                                                  if maxvalue<256 then maxvalue:=1
                                             else if maxvalue<65536 then maxvalue:=2
                                             else if maxvalue<4294967296 then maxvalue:=4
                                             else FatalError('Syntax error in file '+f.name);
                                             gdbgetmem({$IFDEF DEBUGBUILD}'{F26A6C48-52FE-437C-A017-382135CC3DC7}',{$ENDIF}GDBPointer(etd),sizeof(EnumDescriptor));
                                             PEnumDescriptor(etd)^.init(maxvalue,typename,currentunit);
                                             penu:=enumobjlist.beginiterate(ir);
                                             if penu<>nil then
                                               repeat
                                                     PEnumDescriptor(etd)^.SourceValue.add(@penu^.source);
                                                     //GDBPointer(penu^.source):=nil;
                                                     penu^.source:='';
                                                     PEnumDescriptor(etd)^.UserValue.add(@penu^.user);
                                                     //GDBPointer(penu^.user):=nil;
                                                     penu^.user:='';
                                                     PEnumDescriptor(etd)^.Value.add(@penu^.value);
                                                     penu:=enumobjlist.iterate(ir);
                                              until penu=nil;
                                             enumobjlist.clear;
                                             //GDBStringtypearray := chr(Tenum);
                                             GDBStringtypearray:='';
                                             fieldoffset:=maxvalue;

                                             end;
                                           0:begin
                                                  FatalError('Syntax error in file '+f.name)
                                             end;
                                end;

                                if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;




if addtype then
        begin
        //GDBPointer(etd.typeobj.typename):=nil;
        //GDBPointer(etd.tdesk):=nil;
        if fieldoffset <> dynamicoffset then etd^.SizeInGDBBytes := fieldoffset
                                        else etd^.SizeInGDBBytes := 0;
        //etd.tdesk := GDBStringtypearray;
        //etd.name := typename;

        //p:=@etd;
        currentunit.InterfaceTypes.exttype.add(@etd);

        {$IFDEF TOTALYLOG}programlog.logoutstr('Type "'+typename+'" added',0);{$ENDIF}
        if typename='tdisp' then
                                typename:=typename;
        //GDBPointer(etd.name):=nil;
        //GDBPointer(etd.tdesk):=nil;
        end;
        //addtype:=true;
                           end;
                varmode:begin
                                {$IFDEF TOTALYLOG}programlog.logoutstr('Varmode string: "'+line,0);{$ENDIF}
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
                                        FatalError('Unable to parse line "'+line+'"');
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
                                                                              vuname:=pGDBString(subparseresult^.getelement(0))^;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pGDBString(parseresult^.getelement(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pGDBString(parseresult^.getelement(i))^;
                                     if varname='rp_21' then
                                                            varname:=varname;
                                     currentunit^.setvardesc(vd, varname,vuname, vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                end;
                                vuname:='';
                                if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                if subparseresult<>nil then begin subparseresult^.FreeAndDone;GDBfreeMem(gdbpointer(subparseresult));end;
                           end;
                beginmode:begin
                                //parsepos:=1;
                                parseresult:=runparser('=e=n=d=.',line,parseerror);
                                if parseerror then
                                                   system.break
                                               else
                                                   begin
                                                        programlog.logoutstr(line,0);
                                                        if copy(line,1,10)='VIEW_ObjIn'
                                                        then
                                                            line:=line;
                                                        line:=copy(line,1,pos(';',line)-1);
                                                        if line='RD_Restore_Mode:=WND_Texture'
                                                                 then
                                                                     line:=line;
                                                        vd:=evaluate(line,currentunit);
                                                        deletetempvar(vd);
                                                   end;
                                if (parseresult<>nil)and parseerror then
                                begin
                                     vartype:=pGDBString(parseresult^.getelement(parseresult.Count-1))^;
                                     for i:=0 to parseresult.Count-2 do
                                     begin
                                     varname:=pGDBString(parseresult^.getelement(i))^;
                                     currentunit^.setvardesc(vd, varname,'', vartype);
                                     currentunit^.InterfaceVariables.createvariable(vd.name, vd);
                                     end;
                                end;
                                if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                                line:='';
                           end;
    end;
  end;
  result:=currentunit;
  enumobjlist.done;
end;
constructor TUnitManager.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{94D787E9-97EE-4198-8A72-5B904B98F275}',{$ENDIF}500,sizeof(TUnit));
     NextUnitManager:=nil;
end;
procedure TUnitManager.LoadFolder(path: GDBString);
var
  sr: TSearchRec;
begin
  programlog.logoutstr('TUnitManager.LoadFolder("'+path+'")',lp_IncPos);
  if FindFirst(path + '*.pas', faAnyFile, sr) = 0 then
  begin
    repeat
      programlog.logoutstr('Found file '+path + sr.Name,0);
      loadunit(path+sr.Name,nil);
    until FindNext(sr) <> 0;
    sysutils.FindClose(sr);
  end;
  programlog.logoutstr('end; //TUnitManager.LoadFolder',lp_DecPos);
end;
var
  ptd:PUserTypeDescriptor;
initialization;
     {$IFDEF DEBUGINITSECTION}LogOut('uunitmanager.initialization');{$ENDIF}
     programlog.logoutstr('UUnitManager.startup',lp_IncPos);
     units.init;
          units.loadunit(expandpath('*rtl/system.pas'),nil);

  SysUnit:=units.findunit('System');

  {RegCnownTypes.RegTypes;}
  {URegisterObjects.startup;}

  units.loadunit(expandpath('*rtl/sysvar.pas'),nil);
  units.loadunit(expandpath('*rtl/savedvar.pas'),nil);
  units.loadunit(expandpath('*rtl/devicebase.pas'),nil);

  SysVarUnit:=units.findunit('sysvar');
  SavedUnit:=units.findunit('savedvar');
  DBUnit:=units.findunit('devicebase');

  if SysVarUnit<>nil then
  begin
  SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_DrawMode,'DWG_DrawMode');
  SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_OSMode,'DWG_OSMode');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');
  SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_PolarMode,'DWG_PolarMode');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_StepGrid,'DWG_StepGrid');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_OriginGrid,'DWG_OriginGrid');

  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SnapGrid,'DWG_SnapGrid');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_DrawGrid,'DWG_DrawGrid');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SystmGeometryDraw,'DWG_SystmGeometryDraw');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_HelpGeometryDraw,'DWG_HelpGeometryDraw');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_EditInSubEntry,'DWG_EditInSubEntry');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_AdditionalGrips,'DWG_AdditionalGrips');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SelectedObjToInsp,'DWG_SelectedObjToInsp');

  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_TraceAutoInc,'DSGN_TraceAutoInc');
  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_LeaderDefaultWidth,'DSGN_LeaderDefaultWidth');
  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_HelpScale,'DSGN_HelpScale');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net,'DSGN_LCNet');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable,'DSGN_LCCable');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader,'DSGN_LCLeader');

  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_CursorSize,'DISP_CursorSize');
  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_CrosshairSize,'DISP_CrosshairSize');
  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_OSSize,'DISP_OSSize');
  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_ZoomFactor,'DISP_ZoomFactor');
  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_DrawZAxis,'DISP_DrawZAxis');
  SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_ColorAxis,'DISP_ColorAxis');

  SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuProjType,'PMenuProjType');
  SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuCommandLine,'PMenuCommandLine');
  SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuHistoryLine,'PMenuHistoryLine');
  SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuDebugObjInsp,'PMenuDebugObjInsp');
  SysVarUnit.AssignToSymbol(SysVar.MISC.ShowHiddenFieldInObjInsp,'ShowHiddenFieldInObjInsp');

  SysVarUnit.AssignToSymbol(SysVar.VIEW.VIEW_CommandLineVisible,'VIEW_CommandLineVisible');
  SysVarUnit.AssignToSymbol(SysVar.VIEW.VIEW_HistoryLineVisible,'VIEW_HistoryLineVisible');
  SysVarUnit.AssignToSymbol(SysVar.VIEW.VIEW_ObjInspVisible,'VIEW_ObjInspVisible');

  SysVarUnit.AssignToSymbol(SysVar.RD.RD_PanObjectDegradation,'RD_PanObjectDegradation');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_UseStencil,'RD_UseStencil');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_VSync,'RD_VSync');
  {$IFNDEF WINDOWS}
  if SysVar.RD.RD_VSync<>nil then
                                 SysVar.RD.RD_VSync^:=TVSDefault;
  ptd:=SysUnit.TypeName2PTD('trd');
  if ptd<>nil then
                  PRecordDescriptor(ptd).SetAttrib('RD_VSync',FA_READONLY,0);

  {$ENDIF}
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_LineSmooth,'RD_LineSmooth');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_Restore_Mode,'RD_Restore_Mode');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxLineWidth,'RD_MaxLineWidth');
  SysVar.RD.RD_MaxLineWidth^:=-1;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxPointSize,'RD_MaxPointSize');
  SysVar.RD.RD_MaxPointSize^:=-1;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_Vendor,'RD_Vendor');
  SysVar.RD.RD_Vendor^:=rsncOGLc;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_Renderer,'RD_Renderer');
  SysVar.RD.RD_Renderer^:=rsncOGLc;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_Version,'RD_Version');
  SysVar.RD.RD_Version^:=rsncOGLc;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxWidth,'RD_MaxWidth');
  SysVar.RD.RD_MaxWidth^:=-1;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_BackGroundColor,'RD_BackGroundColor');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_LastRenderTime,'RD_LastRenderTime');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_LastUpdateTime,'RD_LastUpdateTime');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxRenderTime,'RD_MaxRenderTime');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_Light,'RD_Light');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_Enabled,'RD_ID_Enabled');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor,'RD_ID_MaxDegradationFactor');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime,'RD_ID_PrefferedRenderTime');
  SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=0;

  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Current_Interval,'SAVE_Auto_Current_Interval');
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Interval,'SAVE_Auto_Interval');
  SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_FileName,'SAVE_Auto_FileName');
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_On,'SAVE_Auto_On');

  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_Version,'SYS_Version');
  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_RunTime,'SYS_RunTime');
  SysVar.SYS.SYS_RunTime^:=0;
  //SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_ActiveMouse,'SYS_ActiveMouse');
  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_SystmGeometryColor,'SYS_SystmGeometryColor');
  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_IsHistoryLineCreated,'SYS_IsHistoryLineCreated');
  SysVar.SYS.SYS_IsHistoryLineCreated^:=FALSE;
  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_AlternateFont,'SYS_AlternateFont');

  SysVarUnit.AssignToSymbol(SysVar.PATH.device_library,'PATH_Device_Library');
  s:=SysVar.PATH.device_library^;
  SysVarUnit.AssignToSymbol(SysVar.PATH.Program_Run,'PATH_Program_Run');
  s:=SysVar.PATH.Program_Run^;
  SysVarUnit.AssignToSymbol(SysVar.PATH.Support_Path,'PATH_Support_Path');
  s:=SysVar.PATH.Support_Path^;

  SysVarUnit.AssignToSymbol(SysVar.PATH.Template_Path,'PATH_Template_Path');
  s:=SysVar.PATH.Template_Path^;
  SysVarUnit.AssignToSymbol(SysVar.PATH.Template_File,'PATH_Template_File');
  s:=SysVar.PATH.Template_File^;

  SysVarUnit.AssignToSymbol(SysVar.PATH.LayoutFile,'PATH_LayoutFile');

  SysVarUnit.AssignToSymbol(SysVar.PATH.Fonts_Path,'PATH_Fonts');

  sysvar.RD.RD_LastRenderTime^:=0;
  sysvar.PATH.Program_Run^:=sysparam.programpath;
  sysvar.PATH.Temp_files:=@sysparam.temppath;
  sysvar.SYS.SYS_Version^:=sysparam.ver.versionstring;
  end;


  units.loadunit(expandpath('*rtl/cables.pas'),nil);
  units.loadunit(expandpath('*rtl/devices.pas'),nil);
  units.loadunit(expandpath('*rtl/connectors.pas'),nil);
  units.loadunit(expandpath('*rtl/styles/styles.pas'),nil);

  //units.loadunit(expandpath('*rtl\objdefunits\objname.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\blocktype.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\ark.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\connector.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elcableconnector.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\cable.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\trace.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elwire.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\objroot.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\firesensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\smokesensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\termosensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\handsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elmotor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elsr.pas'),nil);

  //units.loadunit(expandpath('*rtl\objdefunits\bgbsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bgtsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bglsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bias.pas'),nil);

  SysVar.debug.memdeb.GetMemCount:=@memman.GetMemCount;
  SysVar.debug.memdeb.FreeMemCount:=@memman.FreeMemCount;
  SysVar.debug.memdeb.TotalAllocMb:=@memman.TotalAllocMb;
  SysVar.debug.memdeb.CurrentAllocMB:=@memman.CurrentAllocMB;

  if sysunit<>nil then
  PRecordDescriptor(sysunit.TypeName2PTD('CommandRTEdObject'))^.FindField('commanddata')^.Collapsed:=false;
  programlog.logoutstr('UUnitManager.startup',lp_DecPos);

finalization;
     units.FreeAndDone;
end.
