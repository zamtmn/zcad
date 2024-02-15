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

unit URecordDescriptor;

{$MODE DELPHI}
interface
uses
  LCLProc,UPointerDescriptor,uzbstrproc,uzctnrVectorBytes,sysutils,UBaseTypeDescriptor,
  gzctnrVectorTypes,uzedimensionaltypes,TypeDescriptors,gzctnrVector,
  TypInfo,varmandef,uzbtypes,uzbLogIntf,math;
type
TFieldDescriptor=GZVector<FieldDescriptor>;
PRecordDescriptor=^RecordDescriptor;
RecordDescriptor=object(TUserTypeDescriptor)
                       Fields:{GDBOpenArrayOfData}TFieldDescriptor;
                       Parent:PRecordDescriptor;
                       constructor init(tname:string;pu:pointer);
                       function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                       procedure AddField(var fd:FieldDescriptor);
                       function FindField(fn:TInternalScriptString):PFieldDescriptor;virtual; //**< Найти требуемое поля. Пример : sampleRTTITypeDesk^.FindField('PolyWidth')
                       function SetAttrib(fn:TInternalScriptString;SetA,UnSetA:Word):PFieldDescriptor;
                       procedure ApplyOperator(oper,path:TInternalScriptString;var offset:Integer;out tc:PUserTypeDescriptor);virtual;
                       procedure AddConstField(const fd:FieldDescriptor);
                       procedure CopyTo(RD:PTUserTypeDescriptor);
                       //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PTZctnrVectorBytes;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                       //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:TZctnrVectorBytes;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                       function GetTypeAttributes:TTypeAttr;virtual;
                       procedure MagicFreeInstance(PInstance:Pointer);virtual;
                       destructor Done;virtual;
                       procedure SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                       procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
                       function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                       procedure RegisterTypeinfo(ti:PTypeInfo);virtual;
                       procedure CorrectFieldsOffset(ti:PTypeInfo);
                   end;
function typeformat(s:TInternalScriptString;PInstance,PTypeDescriptor:Pointer):TInternalScriptString;
var
    EmptyTypedData:TInternalScriptString;
implementation
uses varman;
function typeformat(s:TInternalScriptString;PInstance,PTypeDescriptor:Pointer):TInternalScriptString;
var i,i2:Integer;
    ps,fieldname:TInternalScriptString;
//    pv:pvardesk;
    offset:Integer;
    tc:PUserTypeDescriptor;
    pf:Pointer;
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
                                              //ps:=copy(ps,1,i-1)+ varman.valuetoString(pv^.pvalue,pv.ptd) +copy(ps,i2+1,length(ps)-i2)
                                              ps:=copy(ps,1,i-1)+tc^.GetUserValueAsString(pf)+copy(ps,i2+1,length(ps)-i2)
                                         end
                                     else
                                         ps:=copy(ps,1,i-1)+'!!ERR('+fieldname+')!!'+copy(ps,i2+1,length(ps)-i2)
                     end;
     until i<=0;
     result:=ps;
end;
procedure RecordDescriptor.RegisterTypeinfo(ti:PTypeInfo);
begin
//  if TypeName='trenderdeb' then begin
//       if TypeName='trenderdeb' then
//                 ti:=ti;
//  end;
  CorrectFieldsOffset(ti);
end;

procedure RecordDescriptor.CorrectFieldsOffset(ti:PTypeInfo);
var
   td:PTypeData;
   mf: PManagedField;
   i:integer;
   etd:PRecordDescriptor;
   pfd:pFieldDescriptor;
begin
  td:=GetTypeData(ti);
  self.SizeInBytes:=td.RecSize;
  mf:=@td.ManagedFldCount;
  inc(pointer(mf),sizeof(td.ManagedFldCount));
  if td.ManagedFldCount<>Fields.Count then
    DebugLn('{W}Fields count of "%s" record = %d, but rtti.ManagedFldCount = %d',[TypeName,Fields.Count,td.ManagedFldCount]);
  for i:=0 to min(td.ManagedFldCount,Fields.Count)-1 do
  begin
      ti:=mf.TypeRef;
      pfd:=Fields.getDataMutable(i);
      {fd.base.ProgramName:=ti.Name;
      fd.base.PFT:=RegisterType(ti);;
      fd.base.Attributes:=0;
      fd.base.Saved:=0;
      fd.Collapsed:=true;}
      Pfd.Offset:=mf.FldOffset;
      inc(mf);
  end;
end;


procedure RecordDescriptor.MagicFreeInstance(PInstance:Pointer);
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
                   PtrUInt(p):=PtrUInt(PInstance)+pd^.Offset;
                   if assigned(pd^.base.PFT) then
                                                 pd^.base.PFT^.MagicFreeInstance(p);
//                                             else
//                                                 pd:=pd;
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
constructor RecordDescriptor.init;
begin
     inherited init(0,tname,pu);
     fields.init(20);
     parent:=nil;
end;
procedure FREEFIELD(const p:PFieldDescriptor);
begin
     PFieldDescriptor(p)^.base.ProgramName:='';
     PFieldDescriptor(p)^.base.UserName:='';
end;
destructor RecordDescriptor.done;
begin
     inherited;
     fields.Freewithproc(freefield);
     fields.done;
     parent:=nil;
end;
procedure RecordDescriptor.AddConstField;
begin
     fields.PushBackData(fd);
     SizeInBytes:=SizeInBytes+fd.Size;
end;
procedure RecordDescriptor.AddField;
begin
     AddConstField(fd);
     //Pointer(fd.base.ProgramName):=nil;
end;
function RecordDescriptor.FindField(fn:TInternalScriptString):PFieldDescriptor;
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
function RecordDescriptor.SetAttrib(fn:TInternalScriptString;SetA,UnSetA:Word):PFieldDescriptor;
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
              //Pointer(d.base.ProgramName):=nil;
              //Pointer(d.base.userName):=nil;
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
procedure RecordDescriptor.SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);
var pd:PFieldDescriptor;
//    d:FieldDescriptor;
    ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if pd^.base.ProgramName<>'#' then
                                        pd.base.PFT.SavePasToMem(membuf,pointer(PtrUInt(PInstance)+pd^.Offset),prefix+'.'+pd^.base.ProgramName);
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
    bmodesave,bmodesave2,bmodetemp:Integer;
    tname:TInternalScriptString;
    ta,tb,taa:Pointer;
    pobj:PGDBaseObject;
    ir,ir2:itrec;
    pvd:pvardesk;
    tw:word;
    i:integer;
    category:TInternalScriptString;
    oldppda:PTPropertyDeskriptorArray;
    recreateunitvars:boolean;
    SaveDecorators:TDecoratedProcs;
    SaveFastEditors:TFastEditorsVector;
    startaddr:pointer;
begin
//        if TypeName='trenderdeb' then begin
//             if TypeName='trenderdeb' then
//                       TypeName:=TypeName;
//        end;
     zTraceLn('{T+}[ZSCRIPT]RecordDescriptor.CreateProperties "%s"',[name]);
     //programlog.LogOutFormatStr('RecordDescriptor.CreateProperties "%s"',[name],lp_IncPos,LM_Trace);

     pobj:=addr;
     startaddr:=addr;
//     if bmode<>property_build then
//                                  begin
//                                       bmode:=bmode;
//                                  end;
     bmodesave:=property_build;
     if PCollapsed<>field_no_attrib then
     begin
           ppd:=GetPPD(ppda,bmode);
           ppd^.Name:=name;
           ppd^.Attr:=ownerattrib;
           ppd^.Collapsed:=PCollapsed;
           ppd^.Decorators:=Decorators;
           convertToRunTime(FastEditors,ppd^.FastEditors);
           ppd^.valueAddres:=addr;
           ppd^.PTypeManager:=@self;
           if bmode=property_build then
           begin
                Getmem(Pointer(ppd^.SubNode),sizeof(TPropertyDeskriptorArray));
                PTPropertyDeskriptorArray(ppd^.SubNode)^.init(100);
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
     if (self.TypeName='TEntityUnit')or(self.TypeName='TUnit') then
                                        begin
                                        //if (bmode=property_build)then
                                              if (bmode=property_correct)then
                                              begin
                                               if PTPropertyDeskriptorArray(ppd^.SubNode)^.GetRealPropertyDeskriptorsCount<>PTEntityUnit(addr)^.InterfaceVariables.vardescarray.Count then
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
                                             pvd:=PTEntityUnit(addr)^.InterfaceVariables.vardescarray.beginiterate(ir2);
                                             if pvd<>nil then
                                             repeat
                                                  if pvd^.name='BTY_TreeCoord' then
                                                                                   pvd^.name:=pvd^.name;
                                                  zTraceLn('{T}[ZSCRIPT]process prop: "%s"',[pvd^.name]);
                                                  //programlog.LogOutFormatStr('process prop: "%s"',[pvd^.name],lp_OldPos,LM_Trace);
                                                  i:=pos('_',pvd^.name);
                                                  tname:=pvd^.username;
                                                  if tname='' then
                                                                  tname:=pvd^.name;
                                                  taa:=pvd^.data.Addr.Instance;
                                                  if (pvd^.attrib and vda_different)>0 then
                                                                                           tw:=FA_DIFFERENT
                                                                                       else
                                                                                           tw:=0;
                                                  if (pvd^.attrib and vda_approximately)>0 then
                                                                                           tw:=tw or FA_APPROXIMATELY;
                                                  if (pvd^.attrib and vda_RO)>0 then
                                                                                           tw:=tw or FA_READONLY;
                                                  if (pvd^.attrib and vda_colored1)>0 then
                                                    tw:=tw or FA_COLORED1;
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
                                                                           Getmem(Pointer(ppd^.SubNode),sizeof(TPropertyDeskriptorArray));
                                                                           PTPropertyDeskriptorArray(ppd^.SubNode)^.init(100);
                                                                      end;
                                                      ppda:=PTPropertyDeskriptorArray(ppd^.SubNode);
                                                  end;
                                                  bmodesave2:=ppda^.findvalkey(pvd^.name);
                                                  if bmodesave2<>0 then
                                                  begin
                                                       if (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumData')
                                                       or (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumDataWithOtherStrings')
                                                       or (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumDataWithOtherPointers')then
                                                                   begin
                                                                        SaveDecorators:=GDBEnumDataDescriptorObj.Decorators;
                                                                        SaveFastEditors:=GDBEnumDataDescriptorObj.FastEditors;
                                                                        GDBEnumDataDescriptorObj.Decorators:=PTUserTypeDescriptor(pvd^.data.PTD)^.Decorators;
                                                                        GDBEnumDataDescriptorObj.FastEditors:=PTUserTypeDescriptor(pvd^.data.PTD)^.FastEditors;
                                                                        GDBEnumDataDescriptorObj.CreateProperties(f,PDM_Field,PPDA,tname,@pvd^.data.PTD^.collapsed,(ownerattrib or tw),bmodesave2,taa,pvd^.name,pvd^.data.ptd.TypeName);
                                                                        GDBEnumDataDescriptorObj.Decorators:=SaveDecorators;
                                                                        GDBEnumDataDescriptorObj.FastEditors:=SaveFastEditors;
                                                                   end
                                                               else
                                                  PTUserTypeDescriptor(pvd^.data.PTD)^.CreateProperties
                                                  (f,PDM_Field,PPDA,tname,@pvd^.data.PTD^.collapsed,(ownerattrib or tw),bmodesave2,taa,pvd^.name,pvd^.data.ptd.TypeName)
                                                  end
                                                                   else
                                                                   begin
                                                  bmodetemp:=property_build;
                                                                        if (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumData')
                                                                        or (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumDataWithOtherStrings')
                                                                        or (PTUserTypeDescriptor(pvd^.data.PTD)^.GetFactTypedef^.TypeName='TEnumDataWithOtherPointers')then                                                                   begin
                                                                        SaveDecorators:=GDBEnumDataDescriptorObj.Decorators;
                                                                        SaveFastEditors:=GDBEnumDataDescriptorObj.FastEditors;
                                                                        GDBEnumDataDescriptorObj.Decorators:=PTUserTypeDescriptor(pvd^.data.PTD)^.Decorators;
                                                                        GDBEnumDataDescriptorObj.FastEditors:=PTUserTypeDescriptor(pvd^.data.PTD)^.FastEditors;
                                                                        GDBEnumDataDescriptorObj.CreateProperties(f,PDM_Field,PPDA,tname,@pvd^.data.PTD^.collapsed,(ownerattrib or tw),bmodetemp,taa,pvd^.name,pvd^.data.ptd.TypeName);
                                                                        GDBEnumDataDescriptorObj.Decorators:=SaveDecorators;
                                                                        GDBEnumDataDescriptorObj.FastEditors:=SaveFastEditors;
                                                                   end
                                                               else
                                                  PTUserTypeDescriptor(pvd^.data.PTD)^.CreateProperties
                                                  (f,PDM_Field,PPDA,tname,@pvd^.data.PTD^.collapsed,(ownerattrib or tw),{bmode}bmodetemp,taa,pvd^.name,pvd^.data.ptd.TypeName);

                                                  if (bmode<>property_build)then
                                                                                inc(bmode);
                                                                   end;

                                                  ppda:=oldppda;

                                                   pvd:=PTEntityUnit(addr)^.InterfaceVariables.vardescarray.iterate(ir2);
                                             until pvd=nil;
                                        end;
                                        if recreateunitvars then
                                                                bmode:=property_correct;
                                        //inc(PtrInt(addr),sizeof(TEntityUnit));
                                        end
                                        else

     begin
     pfd:=Fields.beginiterate(ir);
     if pfd<>nil then
     repeat
           begin
           startaddr:=addr+pfd^.Offset;
           tname:=pfd^.base.UserName;
           if tname='' then
                           tname:=pfd^.base.ProgramName;
//           if tname='Geometry' then
//                                   tname:=tname;
           if (pfd^.base.PFT^.GetFactTypedef^.TypeName='TEnumData') or
              (pfd^.base.PFT^.GetFactTypedef^.TypeName='TEnumDataWithOtherData') then
                       begin
                            SaveDecorators:=GDBEnumDataDescriptorObj.Decorators;
                            SaveFastEditors:=GDBEnumDataDescriptorObj.FastEditors;
                            GDBEnumDataDescriptorObj.Decorators:=pfd^.base.PFT^.Decorators;
                            GDBEnumDataDescriptorObj.FastEditors:=pfd^.base.PFT^.FastEditors;
                            GDBEnumDataDescriptorObj.CreateProperties(f,PDM_Field,PPDA,tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,startaddr,'','');
                            GDBEnumDataDescriptorObj.Decorators:=SaveDecorators;
                            GDBEnumDataDescriptorObj.FastEditors:=SaveFastEditors;
                       end
                   else
           if (pfd^.base.PFT^.GetFactTypedef^.TypeName='PTEnumData') then
                       begin
                            SaveDecorators:=GDBEnumDataDescriptorObj.Decorators;
                            SaveFastEditors:=GDBEnumDataDescriptorObj.FastEditors;
                            GDBEnumDataDescriptorObj.Decorators:=PGDBPointerDescriptor(pfd^.base.PFT)^.TypeOf^.Decorators;
                            GDBEnumDataDescriptorObj.FastEditors:=PGDBPointerDescriptor(pfd^.base.PFT)^.TypeOf^.FastEditors;
                            ta:=ppointer(startaddr)^;
                            GDBEnumDataDescriptorObj.CreateProperties(f,PDM_Field,PPDA,tname,@pfd^.collapsed,pfd^.base.Attributes or ownerattrib,bmode,ta,'','');
                            GDBEnumDataDescriptorObj.Decorators:=SaveDecorators;
                            GDBEnumDataDescriptorObj.FastEditors:=SaveFastEditors;
                            //Inc(PtrInt(startaddr),sizeof(Pointer));
                       end
                   else
           (*if (pfd^.PFT^.TypeName='TObjectUnit') then
                       begin
                            ppd:=GetPPD(ppda,bmode);

                            ppd^.Name:=tname;
                            ppd^.PTypeManager:=nil;
                            ppd^.Attr:=ownerattrib;
                            ppd^.Collapsed:=PCollapsed;
                            ppd^.valueAddres:=startaddr;
                            ppd^.value:='Empty';

                            //pvd:=PTEntityUnit(startaddr)^.InterfaceVariables.vardescarray.beginiterate(ir2);
                            //taa:=pvd^.Instance;
                            //PTUserTypeDescriptor(pvd^.data.PTD).CreateProperties(PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.Attributes or ownerattrib,bmode,taa);
                            inc(integer(startaddr),sizeof(TEntityUnit));
                       end
                   else*)
           if pfd^.base.ProgramName='#' then begin
                                                zTraceLn('{T}[ZSCRIPT]Found ##PVMT');
                                                //programlog.LogOutStr('Found ##PVMT',lp_OldPos,LM_Trace);
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
                                                                                                      {IFDEF LOUDERRORS}
                                                                                                        Raise Exception.Create('Something wrong');
                                                                                                      {ENDIF}


                                                                            end;
                                                                                ppd^.Name:=tname;
                                                                                ppd^.PTypeManager:=nil;
                                                                                ppd^.Attr:=ownerattrib or pfd^.base.Attributes;
                                                                                ppd^.Collapsed:=PCollapsed;
                                                                                ppd^.valueAddres:=startaddr;
                                                                                ppd^.value:='Not initialized';
                                                                                if assigned(pobj) then
                                                                                                      if assigned(ppointer(pobj)^) then
                                                                                                                                       begin
                                                                                                                                       zTraceLn('{T}[ZSCRIPT]%p',[pobj]);
                                                                                                                                       //programlog.LogOutFormatStr('%p',[pobj],lp_OldPos,LM_Trace);
                                                                                                                                       ppd^.value:=pobj^.GetObjTypeName;
                                                                                                                                       //pobj^.whoisit;
                                                                                                                                       //pobj^.GetObjTypeName;
                                                                                                                                       end;
                                                                                //Inc(PtrInt(startaddr),sizeof(Pointer));
                                           end
                   else
                   begin
                   if (pfd^.base.PFT^.GetFactTypedef^.TypeName='THardTypedData') or
                      (pfd^.base.PFT^.TypeName='TFaceTypedData') then
                                                          Begin
                                                               tb:={PTTypedData(startaddr)^.Instance}startaddr;
                                                               ta:=PTHardTypedData(startaddr)^.ptd;
                                                               if ta<>nil then
                                                               PTUserTypeDescriptor(ta)^.CreateProperties(f,PDM_Field,PPDA,{PTTypedData(startaddr)^.ptd^.TypeName}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,tb,'','')
                                                               else
                                                               begin
                                                                    //tb:=@EmptyTypedData;
                                                                    defaultptypehandler.CreateProperties(f,PDM_Field,PPDA,{PTTypedData(startaddr)^.ptd^.TypeName}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib or FA_READONLY,bmode,tb,'','');
                                                               end;
                                                               //inc(PtrInt(startaddr),sizeof(TTypedData));
                                                          end
                                                       else
                                                           begin
                                                           if pfd^.base.UserName='Renderer' then
                                                                pfd^.base.UserName:=pfd^.base.UserName+'1';
                                                                PTUserTypeDescriptor(pfd^.base.PFT)^.CreateProperties(f,PDM_Field,PPDA,{ppd^.Name}tname,@pfd^.collapsed,{ppd^.Attr}pfd^.base.Attributes or ownerattrib,bmode,startaddr,'','')
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
     zTraceLn('{T-}[ZSCRIPT]end;{RecordDescriptor.CreateProperties "%s"}',[name]);
     //programlog.LogOutFormatStr('end;{RecordDescriptor.CreateProperties "%s"}',[name],lp_DecPos,LM_Trace);
end;

//procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
function RecordDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
var pd:PFieldDescriptor;
    ir:itrec;
    notfirst:Boolean;
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
                   result:=result+pd.base.ProgramName+'='+pd.base.PFT.GetValueAsString(pointer(PtrInt(PInstance)+pd^.Offset));
                   notfirst:=true;
              end;
              pd:=Fields.iterate(ir);
        until pd=nil;
     result:=result+')';
end;
procedure RecordDescriptor.MagicAfterCopyInstance(PInstance:Pointer);
var pd:PFieldDescriptor;
//    d:FieldDescriptor;
    ir:itrec;
begin
        pd:=Fields.beginiterate(ir);
        if pd<>nil then
        repeat
              if pd^.base.ProgramName<>'#' then
                                        pd.base.PFT.MagicAfterCopyInstance(pointer(PtrUInt(PInstance)+pd^.Offset));
              pd:=Fields.iterate(ir);
        until pd=nil;
end;
begin
  EmptyTypedData:='Empty';
end.
