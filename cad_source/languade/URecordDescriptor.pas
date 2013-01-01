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

unit URecordDescriptor;
{$INCLUDE def.inc}
interface
uses strproc,log,UGDBOpenArrayOfByte,sysutils,UBaseTypeDescriptor,UGDBOpenArrayOfTObjLinkRecord,
  TypeDescriptors{,UGDBOpenArrayOfPointer},UGDBOpenArrayOfData,gdbasetypes,varmandef,gdbase{,UGDBStringArray},memman;
type
PRecordDescriptor=^RecordDescriptor;
RecordDescriptor=object(TUserTypeDescriptor)
                       Fields:GDBOpenArrayOfData;
                       Parent:PRecordDescriptor;
                       constructor init(tname:string;pu:pointer);
                       function CreateProperties(mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                       procedure AddField(var fd:FieldDescriptor);
                       function FindField(fn:GDBString):PFieldDescriptor;
                       function SetAttrib(fn:GDBString;SetA,UnSetA:GDBWord):PFieldDescriptor;
                       procedure ApplyOperator(oper,path:GDBString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;
                       procedure AddConstField(const fd:FieldDescriptor);
                       procedure CopyTo(RD:PTUserTypeDescriptor);
                       function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                       function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                       function GetTypeAttributes:TTypeAttr;virtual;
                       procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                       destructor Done;virtual;
                       procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                       procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                       function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                   end;
function typeformat(s:GDBString;PInstance,PTypeDescriptor:GDBPointer):GDBString;
implementation
uses varman;
function typeformat(s:GDBString;PInstance,PTypeDescriptor:GDBPointer):GDBString;
var i,i2:GDBInteger;
    ps,fieldname:GDBString;
//    pv:pvardesk;
    offset:GDBInteger;
    tc:PUserTypeDescriptor;
    pf:GDBPointer;
begin
     ps:=s;
     repeat
          i:=pos('%%[',ps);
          if i>0 then
                     begin
                          i2:=pos(']',ps);
                          if i2<i then system.break;
                          fieldname:=copy(ps,i+3,i2-i-3);
                          //pv:=nil;
                          offset:=0;
                          if (PInstance<>nil)and(PTypeDescriptor<>nil) then
                          begin
                               PRecordDescriptor(PTypeDescriptor).ApplyOperator('.',fieldname,offset,tc);
                          end;
                          if offset>0 then
                                         begin
                                              pf:=pointer(offset+ptruint(PInstance));
                                              //ps:=copy(ps,1,i-1)+ varman.valuetoGDBString(pv^.pvalue,pv.ptd) +copy(ps,i2+1,length(ps)-i2)
                                              ps:=copy(ps,1,i-1)+tc^.GetUserValueAsString(pf)+copy(ps,i2+1,length(ps)-i2)
                                         end
                                     else
                                         ps:=copy(ps,1,i-1)+'!!ERR('+fieldname+')!!'+copy(ps,i2+1,length(ps)-i2)
                     end;
     until i<=0;
     result:=ps;
end;
procedure RecordDescriptor.MagicFreeInstance(PInstance:GDBPointer);
var pd:PFieldDescriptor;
//     d:FieldDescriptor;
     p:pointer;
//     fo:integer;
//     pld:PRecordDescriptor;
//     objtypename:string;
         ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              begin
                   GDBPlatformint(p):=GDBPlatformint(PInstance)+pd^.Offset;
                   if assigned(pd^.base.PFT) then
                                                 pd^.base.PFT^.MagicFreeInstance(p)
                                             else
                                                 pd:=pd;
              end;
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
procedure RecordDescriptor.ApplyOperator;
var pd:PFieldDescriptor;
//   d:FieldDescriptor;
//     p:pointer;
//     fo:integer;
//     pld:PRecordDescriptor;
//     objtypename:string;
         ir:itrec;
begin
      tc:=nil;
      //offset:=0;

        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if (pd^.base.ProgramName=path) then
              begin
                   tc:=pd^.base.PFT;
                   offset:=offset+pd^.Offset;
                   exit;
              end;
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
function RecordDescriptor.Serialize;
var pd:PFieldDescriptor;
//     d:FieldDescriptor;
     p:pointer;
     fo:integer;
//     pld:PRecordDescriptor;
//     objtypename:string;
//     linkdata:TObjLinkRecord;
         ir:itrec;
     {$include debugvars.inc}
begin
     {$IFDEF TOTALYLOG}
     logstr:='Start Serialize for '+self.TypeName;
     programlog.logoutstr(pansichar(logstr),lp_IncPos);
     {$ENDIF}
     fo:=0;
     inc(sub);
     if membuf=nil then
                       begin
                            gdbgetmem({$IFDEF DEBUGBUILD}'{1E61A15A-E5F2-4B77-99AB-4A89CC4D0A3B}',{$ENDIF}pointer(membuf),sizeof(GDBOpenArrayOfByte));
                            membuf.init({$IFDEF DEBUGBUILD}'{EFEC2C2D-FAF1-4122-9A0B-72E1B42FEFF7}',{$ENDIF}10000000);
                       end;
     if linkbuf=nil then
                        begin
                            gdbgetmem({$IFDEF DEBUGBUILD}'{9FE39C49-5962-4E00-BB0D-30A8974E16AF}',{$ENDIF}pointer(linkbuf),sizeof(GDBOpenArrayOfTObjLinkRecord));
                            linkbuf.init({$IFDEF DEBUGBUILD}'{C0740070-0EA9-4BE3-A837-5F9668F1768C}',{$ENDIF}1000000);
                        end;
     linkbuf.CreateLinkRecord(PInstance,membuf^.Count,OBT);
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
                   if pd^.base.ProgramName='Entities' then
                                    pd:=pd;
              if (pd^.base.Saved and SaveFlag)<>0 then
              begin
                   {$IFDEF DEBUGBUILD}programlog.logoutstr(pd^.base.ProgramName,0);{$ENDIF}
                   p:=PInstance;
                   if pd^.Offset<>fo then
                                         begin
                                              asm
                                                 int 3;
                                              end;
                                         end;
                   inc(pbyte(p),pd^.Offset{fo});

                   linkbuf.CreateLinkRecord(p,membuf^.Count,OFT);

                   if zcpmode=zcptxt then
                   begin
                   membuf^.AddData(pointer(pd^.base.ProgramName),length(pd^.base.ProgramName));
                   membuf^.AddData(pointer(lineend),length(lineend));
                   end;
                   if {pd^.FieldType.TypeIndex>=Basetypesendindex}((pd^.base.PFT^.GetTypeAttributes)and TA_COMPOUND)>0 then
                                                            begin
                                                                 pd^.base.PFT^.Serialize(p,SaveFlag,membuf,linkbuf,sub)
                                                            end
                                                        else
                                                            begin
                                                                 pd^.base.PFT^.Serialize(p,SaveFlag,membuf,linkbuf,sub)
                                                            end;
                   pd^.base.Saved:=pd^.base.Saved;
              end;
              fo:=fo+pd^.Size;
              pd:=Fields.iterate(ir);
        until pd=nil;
     {$IFDEF TOTALYLOG}
     logstr:='End Serialize for '+self.TypeName;
     programlog.logoutstr(pansichar(logstr),lp_DecPos);
     {$ENDIF}
     dec(sub);
end;
function RecordDescriptor.DeSerialize;
var pd:PFieldDescriptor;
//     d:FieldDescriptor;
     p:pointer;
//     fo:integer;
//     pld:PRecordDescriptor;
//     objtypename:string;
     PLinkData:PTObjLinkRecord;
         ir:itrec;
     {$include debugvars.inc}
begin
     {$IFDEF TOTALYLOG}
     logstr:='Start DeSerialize for '+self.TypeName;
     programlog.logoutstr(logstr,lp_IncPos);
     {$ENDIF}
     //linkbuf.CreateLinkRecord(PInstance,membuf^.Count,OBT);
     if linkbuf<>nil then
                         begin
                              PLinkData:=linkbuf.FindByTempAddres(membuf.ReadPos);
                              if PLinkData<>nil then
                                                    begin
                                                         PLinkData^.NewAddr:=GDBPlatformint(pinstance);
                                                    end;

                         end;
     pd:=Fields.beginiterate(ir);
     if pd<>nil then
     repeat
              if (pd^.base.Saved and SaveFlag)<>0 then
              begin
                   {$IFDEF TOTALYLOG}programlog.logoutstr(pd^.base.ProgramName,0);{$ENDIF}
                   p:=PInstance;
                   inc(pbyte(p),pd^.Offset);
                   if pd^.base.ProgramName='TextStyleTable' then
                                    pd:=pd;
                   if {pd^.FieldType.TypeIndex>=basetypesendindex}((pd^.base.PFT^.GetTypeAttributes)and TA_COMPOUND)>0 then
                                                            begin
                                                                 pd^.base.PFT^.DeSerialize(p,SaveFlag,membuf,linkbuf)
                                                            end
                                                        else
                                                            begin
                                                                 pd^.base.PFT^.DeSerialize(p,SaveFlag,membuf,linkbuf)
                                                            end;
              end;
              //fo:=fo+pd^.Size;
              pd:=Fields.iterate(ir);
        until pd=nil;
     {$IFDEF TOTALYLOG}
     logstr:='End DeSerialize for '+self.TypeName;
     programlog.logoutstr(logstr,lp_DecPos);
     {$ENDIF}
end;
constructor RecordDescriptor.init;
begin
     inherited init(0,tname,pu);
     fields.init({$IFDEF DEBUGBUILD}'{693E7B49-A224-4778-9FD6-49E131AEBD54}',{$ENDIF}20,sizeof({RecordDescriptor}FieldDescriptor));
     parent:=nil;
end;
procedure FREEFIELD(p:GDBPointer);
begin
     PFieldDescriptor(p)^.base.ProgramName:='';
     PFieldDescriptor(p)^.base.UserName:='';
end;
destructor RecordDescriptor.done;
begin
     inherited;
     //destructor FreewithprocAndDone(freeproc:freeelproc);virtual;
     fields.FreewithprocAndDone(freefield);
     parent:=nil;
end;
procedure RecordDescriptor.AddConstField;
begin
     fields.add(@fd);
     SizeInGDBBytes:=SizeInGDBBytes+fd.Size;
end;
procedure RecordDescriptor.AddField;
begin
     AddConstField(fd);
     GDBPointer(fd.base.ProgramName):=nil;
end;
function RecordDescriptor.FindField(fn:GDBString):PFieldDescriptor;
var pd:PFieldDescriptor;
//     d:FieldDescriptor;
     ir:itrec;
begin
        fn:=uppercase(fn);
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if fn=uppercase(pd^.base.ProgramName) then
                                      begin
                                           result:=pd;
                                           exit;
                                      end;
              pd:=Fields.iterate(ir);
        until pd=nil;
        result:=nil;
end;
function RecordDescriptor.SetAttrib(fn:GDBString;SetA,UnSetA:GDBWord):PFieldDescriptor;
begin
     result:=FindField(fn);
     if result<>nil then
                        begin
                             result.base.Attributes:=result.base.Attributes or SetA;
                             result.base.Attributes:=result.base.Attributes and (not UnSetA);
                        end;
end;

procedure RecordDescriptor.CopyTo(RD:PTUserTypeDescriptor);
var pd:PFieldDescriptor;
     d:FieldDescriptor;
     ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              d.base.ProgramName:=pd^.base.ProgramName;
              d.base.UserName:=pd^.base.UserName;
              d.base.PFT:=pd^.base.PFT;
              d.Offset:=pd^.Offset;
              d.Size:=pd^.Size;
              d.base.Attributes:=pd^.base.Attributes;
              d.base.Saved:=pd^.base.Saved;
              d.Collapsed:=pd^.Collapsed;
              PRecordDescriptor(rd)^.AddField(d);
              GDBPointer(d.base.ProgramName):=nil;
              GDBPointer(d.base.userName):=nil;
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
procedure RecordDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);
var pd:PFieldDescriptor;
//    d:FieldDescriptor;
    ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if pd^.base.ProgramName<>'#' then
                                        pd.base.PFT.SavePasToMem(membuf,pointer(GDBPlatformint(PInstance)+pd^.Offset),prefix+'.'+pd^.base.ProgramName);
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
function RecordDescriptor.GetTypeAttributes;
begin
     result:=TA_COMPOUND;
end;
function RecordDescriptor.CreateProperties;
var PFD:PFieldDescriptor;
    ppd:PPropertyDeskriptor;
    bmodesave,bmodesave2,bmodetemp:GDBInteger;
    tname:GDBString;
    ta,tb,taa:GDBPointer;
    pobj:PGDBaseObject;
    ir,ir2:itrec;
    pvd:pvardesk;
    tw:word;
    i:integer;
    category:gdbstring;
    oldppda:PTPropertyDeskriptorArray;
begin
     {$IFDEF TOTALYLOG}programlog.LogOutStr('RecordDescriptor.CreateProperties('+name+')'+inttostr(bmode),lp_IncPos);{$ENDIF}

     pobj:=addr;
     //programlog.logoutstr(inttohex(cardinal(pobj),10),0);
     if bmode<>property_build then
                                  begin
                                       bmode:=bmode;
                                  end;
     bmodesave:=property_build;
     if PCollapsed<>field_no_attrib then
     begin
           ppd:=GetPPD(ppda,bmode);
           ppd^.Name:=name;
           ppd^.Attr:=ownerattrib;
           ppd^.Collapsed:=PCollapsed;
           if bmode=property_build then
           begin
                gdbgetmem({$IFDEF DEBUGBUILD}'{6F9EBE33-15A8-4FF5-87D7-BF01A40F6789}',{$ENDIF}GDBPointer(ppd^.SubNode),sizeof(TPropertyDeskriptorArray));
                PTPropertyDeskriptorArray(ppd^.SubNode)^.init({$IFDEF DEBUGBUILD}'{EDA18239-9432-453B-BA54-0381DA1BB665}',{$ENDIF}100);;
                ppda:=PTPropertyDeskriptorArray(ppd^.SubNode);
           end else
           begin
                bmodesave:=bmode;
                bmode:=property_correct;
                ppda:=PTPropertyDeskriptorArray(ppd^.SubNode);
           end;
     end;
     result:=ppda;

     {if PCollapsed<>field_no_attrib then
     if pboolean(pcollapsed)^ then exit;}
     if (self.TypeName='TObjectUnit')or(self.TypeName='TUnit') then
                                        begin
                                        //if (bmode=property_build)then
                                        begin
                                             pvd:=PTObjectUnit(addr)^.InterfaceVariables.vardescarray.beginiterate(ir2);
                                             if pvd<>nil then
                                             repeat
                                                  if pvd^.name='BTY_TreeCoord' then
                                                                                   pvd^.name:=pvd^.name;

                                                  {$IFDEF TOTALYLOG}programlog.logoutstr('process prop:'+pvd^.name,0);{$ENDIF}
                                                  i:=pos('_',pvd^.name);
                                                  tname:=pvd^.username;
                                                  if tname='' then
                                                                  tname:=pvd^.name;
                                                  taa:=pvd^.data.Instance;
                                                  if (pvd^.attrib and vda_different)>0 then
                                                                                           tw:=FA_DIFFERENT
                                                                                       else
                                                                                           tw:=0;
                                                  if (pvd^.attrib and vda_RO)>0 then
                                                                                           tw:=tw or FA_READONLY;
                                                  oldppda:=ppda;
                                                  if i>0 then
                                                  begin
                                                       category:=uppercase(copy(pvd^.name,1,i-1));
                                                       ppd:=PPDA.findcategory(category);
                                                       if ppd=nil then
                                                                      begin
                                                                           bmodetemp:=property_build;
                                                                           ppd:=GetPPD(ppda,{bmode}bmodetemp);
                                                                           //ppd^.Name:=category;
                                                                           ppd^.Collapsed:=FindCategory(category,ppd^.Name);
                                                                           ppd^.category:=category;
                                                                           ppd^.Attr:=ownerattrib;
                                                                           gdbgetmem({$IFDEF DEBUGBUILD}'{6F9EBE33-15A8-4FF5-87D7-BF01A40F6789}',{$ENDIF}GDBPointer(ppd^.SubNode),sizeof(TPropertyDeskriptorArray));
                                                                           PTPropertyDeskriptorArray(ppd^.SubNode)^.init({$IFDEF DEBUGBUILD}'{EDA18239-9432-453B-BA54-0381DA1BB665}',{$ENDIF}100);;
                                                                      end;
                                                      ppda:=PTPropertyDeskriptorArray(ppd^.SubNode);
                                                  end;
                                                  bmodesave2:=ppda^.findvalkey(pvd^.name);
                                                  if bmodesave2<>0 then
                                                  PTUserTypeDescriptor(pvd^.data.PTD)^.CreateProperties
                                                  (PDM_Field,PPDA,tname,{pcollapsed}@pvd^.data.PTD^.collapsed,(ownerattrib or tw),bmodesave2,taa,pvd^.name,pvd^.data.ptd.TypeName)
                                                                   else
                                                                   begin
                                                  bmodetemp:=property_build;
                                                  PTUserTypeDescriptor(pvd^.data.PTD)^.CreateProperties
                                                  (PDM_Field,PPDA,tname,{pcollapsed}@pvd^.data.PTD^.collapsed,(ownerattrib or tw),{bmode}bmodetemp,taa,pvd^.name,pvd^.data.ptd.TypeName);

                                                  if (bmode<>property_build)then
                                                                                inc(bmode);
                                                                   end;

                                                  ppda:=oldppda;

                                                   pvd:=PTObjectUnit(addr)^.InterfaceVariables.vardescarray.iterate(ir2);
                                             until pvd=nil;
                                        end;
                                        inc(GDBPlatformint(addr),sizeof(TObjectUnit));
                                        end
                                        else

     begin
     pfd:=Fields.beginiterate(ir);
     if pfd<>nil then
     repeat
           begin
           tname:=pfd^.base.UserName;
           if tname='' then
                           tname:=pfd^.base.ProgramName;
           if tname='ObjArray' then
                                   tname:=tname;
           if (pfd^.base.PFT^.TypeName='TEnumData') then
                       begin
                            GDBEnumDataDescriptorObj.CreateProperties(PDM_Field,PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,addr,'','')
                       end
                   else
           (*if (pfd^.PFT^.TypeName='TObjectUnit') then
                       begin
                            ppd:=GetPPD(ppda,bmode);

                            ppd^.Name:=tname;
                            ppd^.PTypeManager:=nil;
                            ppd^.Attr:=ownerattrib;
                            ppd^.Collapsed:=PCollapsed;
                            ppd^.valueAddres:=addr;
                            ppd^.value:='Пусто';

                            //pvd:=PTObjectUnit(addr)^.InterfaceVariables.vardescarray.beginiterate(ir2);
                            //taa:=pvd^.data.Instance;
                            //PTUserTypeDescriptor(pvd^.data.PTD).CreateProperties(PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.Attributes or ownerattrib,bmode,taa);
                            inc(integer(addr),sizeof(TObjectUnit));
                       end
                   else*)
           if pfd^.base.ProgramName='#' then begin
                                                {$IFDEF TOTALYLOG}programlog.LogOutStr('Found ##PVMT',lp_OldPos);{$ENDIF}
                                                ppd:=GetPPD(ppda,bmode);
                                                if ppd^._bmode=property_build then
                                                                                  ppd^._bmode:=bmode;
                                                if bmode=property_build then
                                                                            begin
                                                                                 ppd^._ppda:=ppda;
                                                                                 ppd^._bmode:=bmode;
                                                                            end
                                                                        else
                                                                            begin
                                                                                 if (ppd^._ppda<>ppda)
                                                                                                      then
                                                                                                           asm
                                                                                                              int 3;
                                                                                                           end;


                                                                            end;
                                                                                ppd^.Name:=tname;
                                                                                ppd^.PTypeManager:=nil;
                                                                                ppd^.Attr:=ownerattrib or pfd^.base.Attributes;
                                                                                ppd^.Collapsed:=PCollapsed;
                                                                                ppd^.valueAddres:=addr;
                                                                                ppd^.value:='Не инициализирован';
                                                                                if assigned(pobj) then
                                                                                                      if assigned(ppointer(pobj)^) then
                                                                                                                                       begin
                                                                                                                                       {$IFDEF TOTALYLOG}
                                                                                                                                       programlog.logoutstr(inttohex(GDBPlatformint(pobj),10),0);
                                                                                                                                       //programlog.logoutstr(inttohex(GDBPlatformint(gdb.GetCurrentDWG.pcamera),10),0);
                                                                                                                                       {$ENDIF}
                                                                                                                                       ppd^.value:=pobj^.GetObjTypeName;
                                                                                                                                       //pobj^.whoisit;
                                                                                                                                       //pobj^.GetObjTypeName;
                                                                                                                                       end;
                                                                                Inc(GDBPlatformint(addr),sizeof(gdbpointer));
                                           end
                   else
                   begin
                   if pfd^.base.PFT^.TypeName='TTypedData' then
                                                          Begin
                                                               tb:=PTTypedData(addr)^.Instance;
                                                               ta:=PTTypedData(addr)^.ptd;
                                                               PTUserTypeDescriptor(ta)^.CreateProperties(PDM_Field,PPDA,{PTTypedData(addr)^.ptd^.TypeName}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,tb,'','');
                                                               inc(GDBPlatformint(addr),sizeof(TTypedData));
                                                          end
                                                       else
                                                           begin
                                                                PTUserTypeDescriptor(pfd^.base.PFT)^.CreateProperties(PDM_Field,PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,addr,'','')
                                                           end;
                   end;
           end;

           pfd:=Fields.iterate(ir);
           if (bmode<>property_build)then
                                         inc(bmode);
     until pfd=nil;
     end;
               if bmodesave<>property_build then
                                      bmode:=bmodesave;
     {$IFDEF TOTALYLOG}programlog.LogOutStr('RecordDescriptor.CreateProperties('+name+') (end)',lp_DecPos);{$ENDIF}
end;

//procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
function RecordDescriptor.GetValueAsString(pinstance:GDBPointer):GDBString;
var pd:PFieldDescriptor;
    ir:itrec;
    notfirst:gdbboolean;
begin
     result:='(';
     notfirst:=false;
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if pd^.base.ProgramName<>'#' then
              begin
                   if notfirst then
                                   result:=result+'; ';
                   result:=result+pd.base.ProgramName+'='+pd.base.PFT.GetValueAsString(pointer(GDBPlatformint(PInstance)+pd^.Offset));
                   notfirst:=true;
              end;
              pd:=Fields.iterate(ir);
        until pd=nil;
     result:=result+')';
end;
procedure RecordDescriptor.MagicAfterCopyInstance(PInstance:GDBPointer);
var pd:PFieldDescriptor;
//    d:FieldDescriptor;
    ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if pd^.base.ProgramName<>'#' then
                                        pd.base.PFT.MagicAfterCopyInstance(pointer(GDBPlatformint(PInstance)+pd^.Offset));
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('URecordDescriptor.initialization');{$ENDIF}
end.
