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
uses UPointerDescriptor,strproc,log,UGDBOpenArrayOfByte,sysutils,UBaseTypeDescriptor,UGDBOpenArrayOfTObjLinkRecord,
  TypeDescriptors{,UGDBOpenArrayOfPointer},UGDBOpenArrayOfData,gdbasetypes,varmandef,gdbase{,UGDBStringArray},memman;
type
PRecordDescriptor=^RecordDescriptor;
RecordDescriptor=object(TUserTypeDescriptor)
                       Fields:GDBOpenArrayOfData;
                       Parent:PRecordDescriptor;
                       constructor init(tname:string;pu:pointer);
                       function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                       procedure AddField(var fd:FieldDescriptor);
                       function FindField(fn:GDBString):PFieldDescriptor;virtual;
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
var
    EmptyTypedData:GDBString;
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
                   GDBPlatformUInt(p):=GDBPlatformUInt(PInstance)+pd^.Offset;
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
     programlog.LogOutFormatStr('Start Serialize for "%s"',[self.TypeName],lp_IncPos,LM_Trace);
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
                   {$IFDEF DEBUGBUILD}programlog.logoutstr(pd^.base.ProgramName,0,LM_Fatal);{$ENDIF}
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
     dec(sub);
     programlog.LogOutFormatStr('End Serialize for "%s"',[self.TypeName],lp_DecPos,LM_Trace);
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
     programlog.LogOutFormatStr('Start DeSerialize for "%s"',[self.TypeName],lp_IncPos,LM_Trace);
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
     programlog.LogOutFormatStr('End Serialize for "%s"',[self.TypeName],lp_DecPos,LM_Trace);
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
                                        pd.base.PFT.SavePasToMem(membuf,pointer(GDBPlatformUInt(PInstance)+pd^.Offset),prefix+'.'+pd^.base.ProgramName);
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
    recreateunitvars:boolean;
    SaveDecorators:TDecoratedProcs;
    SaveFastEditor:TFastEditorProcs;
begin
     programlog.LogOutFormatStr('RecordDescriptor.CreateProperties "%s"',[name],lp_IncPos,LM_Trace);

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
           ppd^.Decorators:=Decorators;
           ppd^.FastEditor:=FastEditor;
           ppd^.valueAddres:=addr;
           ppd^.PTypeManager:=@self;
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
                                              if (bmode=property_correct)then
                                              begin
                                               if PTPropertyDeskriptorArray(ppd^.SubNode)^.GetRealPropertyDeskriptorsCount<>PTObjectUnit(addr)^.InterfaceVariables.vardescarray.Count then
                                                  begin
                                                  PTPropertyDeskriptorArray(ppd^.SubNode)^.cleareraseobj;
                                                  recreateunitvars:=true;
                                                  bmode:=property_build;
                                                  end;
                                              end
                                               else
                                                  recreateunitvars:=false;
                                             //recreateunitvars:=false;
                                        begin
                                             pvd:=PTObjectUnit(addr)^.InterfaceVariables.vardescarray.beginiterate(ir2);
                                             if pvd<>nil then
                                             repeat
                                                  if pvd^.name='BTY_TreeCoord' then
                                                                                   pvd^.name:=pvd^.name;
                                                  programlog.LogOutFormatStr('process prop: "%s"',[pvd^.name],lp_OldPos,LM_Trace);
                                                  i:=pos('_',pvd^.name);
                                                  tname:=pvd^.username;
                                                  if tname='' then
                                                                  tname:=pvd^.name;
                                                  taa:=pvd^.data.Instance;
                                                  if (pvd^.attrib and vda_different)>0 then
                                                                                           tw:=FA_DIFFERENT
                                                                                       else
                                                                                           tw:=0;
                                                  if (pvd^.attrib and vda_approximately)>0 then
                                                                                           tw:=tw or FA_APPROXIMATELY;
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
                                                  (f,PDM_Field,PPDA,tname,{pcollapsed}@pvd^.data.PTD^.collapsed,(ownerattrib or tw),bmodesave2,taa,pvd^.name,pvd^.data.ptd.TypeName)
                                                                   else
                                                                   begin
                                                  bmodetemp:=property_build;
                                                  PTUserTypeDescriptor(pvd^.data.PTD)^.CreateProperties
                                                  (f,PDM_Field,PPDA,tname,{pcollapsed}@pvd^.data.PTD^.collapsed,(ownerattrib or tw),{bmode}bmodetemp,taa,pvd^.name,pvd^.data.ptd.TypeName);

                                                  if (bmode<>property_build)then
                                                                                inc(bmode);
                                                                   end;

                                                  ppda:=oldppda;

                                                   pvd:=PTObjectUnit(addr)^.InterfaceVariables.vardescarray.iterate(ir2);
                                             until pvd=nil;
                                        end;
                                        if recreateunitvars then
                                                                bmode:=property_correct;
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
           if tname='PTDimStyleDXFLoadingData' then
                                   tname:=tname;
           if (pfd^.base.PFT^.GetFactTypedef^.TypeName='TEnumData') then
                       begin
                            SaveDecorators:=GDBEnumDataDescriptorObj.Decorators;
                            SaveFastEditor:=GDBEnumDataDescriptorObj.FastEditor;
                            GDBEnumDataDescriptorObj.Decorators:=pfd^.base.PFT^.Decorators;
                            GDBEnumDataDescriptorObj.FastEditor:=pfd^.base.PFT^.FastEditor;
                            GDBEnumDataDescriptorObj.CreateProperties(f,PDM_Field,PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,addr,'','');
                            GDBEnumDataDescriptorObj.Decorators:=SaveDecorators;
                            GDBEnumDataDescriptorObj.FastEditor:=SaveFastEditor;
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
                                                programlog.LogOutStr('Found ##PVMT',lp_OldPos,LM_Trace);
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
                                                                                ppd^.value:='Not initialized';
                                                                                if assigned(pobj) then
                                                                                                      if assigned(ppointer(pobj)^) then
                                                                                                                                       begin
                                                                                                                                       programlog.LogOutFormatStr('%p',[pobj],lp_OldPos,LM_Trace);
                                                                                                                                       ppd^.value:=pobj^.GetObjTypeName;
                                                                                                                                       //pobj^.whoisit;
                                                                                                                                       //pobj^.GetObjTypeName;
                                                                                                                                       end;
                                                                                Inc(GDBPlatformint(addr),sizeof(gdbpointer));
                                           end
                   else
                   begin
                   if (pfd^.base.PFT^.GetFactTypedef^.TypeName='TTypedData') or
                      (pfd^.base.PFT^.TypeName='TFaceTypedData') then
                                                          Begin
                                                               tb:={PTTypedData(addr)^.Instance}addr;
                                                               ta:=PTTypedData(addr)^.ptd;
                                                               if ta<>nil then
                                                               PTUserTypeDescriptor(ta)^.CreateProperties(f,PDM_Field,PPDA,{PTTypedData(addr)^.ptd^.TypeName}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,tb,'','')
                                                               else
                                                               begin
                                                                    //tb:=@EmptyTypedData;
                                                                    defaultptypehandler.CreateProperties(f,PDM_Field,PPDA,{PTTypedData(addr)^.ptd^.TypeName}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib or FA_READONLY,bmode,tb,'','');
                                                               end;
                                                               inc(GDBPlatformint(addr),sizeof(TTypedData));
                                                          end
                                                       else
                                                           begin
                                                                PTUserTypeDescriptor(pfd^.base.PFT)^.CreateProperties(f,PDM_Field,PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,addr,'','')
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
     programlog.LogOutFormatStr('end;{RecordDescriptor.CreateProperties "%s"}',[name],lp_DecPos,LM_Trace);
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
                                        pd.base.PFT.MagicAfterCopyInstance(pointer(GDBPlatformUInt(PInstance)+pd^.Offset));
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('URecordDescriptor.initialization');{$ENDIF}
  EmptyTypedData:='Empty';
end.
