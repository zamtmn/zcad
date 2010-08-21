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

unit UObjectDescriptor;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfObjects,log,ugdbopenarray,URecordDescriptor,UGDBOpenArrayOfByte,sysutils,
     UBaseTypeDescriptor,gdbobjectsconstdef,UGDBOpenArrayOfTObjLinkRecord,TypeDescriptors,
     UGDBOpenArrayOfPointer,UGDBOpenArrayOfData,gdbasetypes,varmandef,gdbase{,UGDBStringArray},memman;
type
simpleproc=procedure of object;
PObjectDescriptor=^ObjectDescriptor;
ObjectDescriptor=object(RecordDescriptor)
                       PVMT:GDBPointer;
                       VMTCurrentOffset:GDBInteger;
                       PDefaultConstructor:GDBPointer;
                       SimpleMenods:GDBOpenArrayOfObjects;
                       LincedData:GDBString;
                       LincedObjects:GDBboolean;
                       ColArray:GDBOpenArrayOfByte;


                       constructor init(tname:string;pu:pointer);
                       function CreateProperties(PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                       procedure CopyTo(RD:PTUserTypeDescriptor);
                       procedure RegisterVMT(pv:GDBPointer);
                       procedure RegisterDefaultConstructor(pv:GDBPointer);
                       procedure RegisterObject(pv,pc:GDBPointer);
                       procedure AddMetod(mn,dt:GDBString;ma:GDBPointer;attr:GDBMetodModifier);
                       function FindMetod(mn:GDBString):PMetodDescriptor;virtual;
                       procedure RunMetod(mn:GDBString;obj:GDBPointer);
                       procedure RunDefaultConstructor(PInstance:GDBPointer);
                       function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                       function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                       destructor Done;virtual;
                       function GetTypeAttributes:TTypeAttr;virtual;
                       procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                 end;
implementation
uses {ZBasicVisible,}varman{,UGDBDescriptor}{,shared};
procedure ObjectDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);
//var pd:PFieldDescriptor;
//    d:FieldDescriptor;
//    ir:itrec;
begin
        membuf.TXTAddGDBStringEOL(prefix+'.initnul;');
        inherited;
         membuf.TXTAddGDBStringEOL('');
end;
function ObjectDescriptor.Serialize;
var
   pld:PRecordDescriptor;
   p:pointer;
   objtypename:string;
       ir:itrec;
begin
     inherited serialize(PInstance,SaveFlag,membuf,linkbuf,sub);
     PGDBaseObject(PInstance)^.AfterSerialize(SaveFlag,pointer(membuf));
        if LincedData<>''then
        begin
             if LincedData='TObjLinkRecord' then
                                    LincedData:=LincedData;
             pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getelement(SysUnit.InterfaceTypes._TypeName2Index(LincedData))^));
             p:=PGDBOpenArrayOfData(PInstance)^.beginiterate(ir);
             if p<>nil then
             repeat
                   pld^.Serialize(p,saveflag,membuf,linkbuf,sub);
                   p:=PGDBOpenArrayOfData(PInstance)^.iterate(ir);
             until p=nil;
        end;
        if LincedObjects then
        begin
             p:=PGDBOpenArrayOfGDBPointer(PInstance)^.beginiterate(ir);
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjTypeName;
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename<>ObjN_GDBObjLine then
                                                            objtypename:=objtypename;
                        GDBStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf,sub);
                        pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getelement(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf,sub);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate(ir);
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             GDBStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf,sub);
        end;
end;
function ObjectDescriptor.DeSerialize;
var //pd:PFieldDescriptor;
//     d:FieldDescriptor;
     p:ppointer;
//     fo:integer;
     pld:PRecordDescriptor;
     objtypename:string;
     i:integer;
begin
     if self.TypeName='GDBObjRoot' then
                                    LincedData:=LincedData;
     RunDefaultConstructor(Pinstance);
     inherited DeSerialize(PInstance,SaveFlag,membuf,linkbuf);
     PGDBaseObject(PInstance)^.AfterDeSerialize(SaveFlag,pointer(@membuf));
     if LincedData<>''then
        begin
             if LincedData='GDBTextStyle' then
                                    LincedData:=LincedData;
             pld:=pointer(SysUnit.TypeName2PTD(LincedData));
             for i := 0 to PGDBOpenArrayOfData(PInstance)^.Count-1 do
             begin
             p:=PGDBOpenArrayOfData(PInstance)^.getelement(i);
             pld^.DeSerialize(p,saveflag,membuf,linkbuf);
             end;
        end;
        if LincedObjects then
        begin
             i:=0;
             objtypename:='';
             GDBStringDescriptorObj.DeSerialize(@objtypename,saveflag,membuf,linkbuf);
             while objtypename<>ObjN_ArrayEnd do
             begin
                  p:=PGDBOpenArrayOfData(PInstance)^.getelement(i);
                  pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getelement(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                  gdbgetmem({$IFDEF DEBUGBUILD}'{lsdfgqweqweqwe}',{$ENDIF}pointer(p^),pld^.SizeInGDBBytes);
                  pld^.deSerialize(p^,saveflag,membuf,linkbuf);

                  objtypename:='';
                  GDBStringDescriptorObj.DeSerialize(@objtypename,saveflag,membuf,linkbuf);
                  inc(i);
             end;

             (*for i := 0 to PGDBOpenArrayOfGDBPointer(PInstance)^.Count-1 do
             begin
                   p:=PGDBOpenArrayOfData(PInstance)^.getelement(i);
                   GDBStringDescriptorObj^.DeSerialize(@objtypename,saveflag,membuf);
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename=ObjN_ArrayEnd then system.Break;
                        pld:=pointer(PUserTypeDescriptor(Types.exttype.getelement(Types.TypeName2Index(objtypename))^));
                        gdbgetmem({$IFDEF DEBUGBUILD}'{lsdfgqweqweqwe}',{$ENDIF}pointer(p^),pld^.SizeInGDBBytes);
                        pld^.deSerialize(p^,saveflag,membuf);
                   end;
                   objtypename:='';
             end;
             objtypename:='';*)
        end;
        {if LincedObjects then
        begin
             p:=PGDBOpenArrayOfGDBPointer(PInstance)^.beginiterate;
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjTypeName;
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename<>ObjN_GDBObjLine then
                                                            objtypename:=objtypename;
                        GDBStringDescriptorObj^.Serialize(@objtypename,saveflag,membuf,linkbuf);
                        pld:=pointer(PUserTypeDescriptor(Types.exttype.getelement(Types.TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate;
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             GDBStringDescriptorObj^.Serialize(@objtypename,saveflag,membuf,linkbuf);
        end;}
end;
procedure freemetods(p:GDBPointer);
begin
     PMetodDescriptor(p)^.MetodName:='';
     PMetodDescriptor(p)^.Operands.done;
end;
destructor ObjectDescriptor.done;
begin
     //destructor FreewithprocAndDone(freeproc:freeelproc);virtual;
     //SimpleMenods.FreewithprocAndDone(freemetods);
     SimpleMenods.FreeAndDone;
     parent:=nil;
     ColArray.done;
     LincedData:='';
     inherited;
end;
constructor ObjectDescriptor.init;
begin
     inherited init(tname,pu);
     SimpleMenods.init({$IFDEF DEBUGBUILD}'{E4674594-B99F-4A72-8766-E2B49DF50FCE}',{$ENDIF}20,sizeof(MetodDescriptor));
     pvmt:=nil;
     {$IFDEF FPC}VMTCurrentOffset:=12;{$ENDIF}
     {$IFDEF DELPHI}VMTCurrentOffset:=0;{$ENDIF}
     PDefaultConstructor:=nil;
     pointer(LincedData):=nil;
     LincedObjects:=false;
     ColArray.init({$IFDEF DEBUGBUILD}'{83ABED34-4E72-42A7-BF3F-B697D75B3568}',{$ENDIF}200);
end;
procedure ObjectDescriptor.AddMetod;
var pcmd:pMetodDescriptor;
    pmd:PMetodDescriptor;
begin
     pmd:=FindMetod(mn);
     if pmd=nil then
                    begin
                         pcmd:=pointer(SimpleMenods.CreateObject);
                         if (attr and m_virtual)=0 then
                                                       pcmd.init(mn,dt,ma,attr,punit)
                                                   else
                                                       begin
                                                            if uppercase(mn)='FORMAT' then
                                                                                           mn:=mn;
                                                            pcmd.init(mn,dt,pointer(vmtcurrentoffset),attr,punit);
                                                            inc(vmtcurrentoffset,{4 cpu64}sizeof(pointer));
                                                       end;
                         //SimpleMenods.add(@pcmd);
                         //GDBPointer(pcmd.MetodName):=nil;
                         //GDBPointer(pcmd.OperandsName):=nil;
                    end
                else
                    begin
                         if (attr and m_virtual)=0 then
                                                        begin
                                                             if uppercase(mn)='FORMAT' then
                                                                                           mn:=mn;
                                                             pmd^.MetodAddr:=ma;
                                                        end;
                    end;

end;
procedure ObjectDescriptor.RegisterVMT;
begin
     pvmt:=pv;
end;
procedure ObjectDescriptor.RegisterDefaultConstructor;
begin
     PDefaultConstructor:=pv;
end;
procedure ObjectDescriptor.RegisterObject(pv,pc:GDBPointer);
begin
     RegisterVMT(pv);
     RegisterDefaultConstructor(pc);
end;
procedure ObjectDescriptor.RunDefaultConstructor(PInstance:GDBPointer);
var
   tm:tmethod;
   {$include debugvars.inc}
begin
     if (Pdefaultconstructor<>nil)and(pvmt<>nil)
     then
     begin
          tm.Code:=PDefaultConstructor;
          tm.Data:=PInstance;
          {$IFDEF DELPHI}
          asm
             mov eax,[self]
             mov edx,[eax+pvmt]
          end;
          {$ENDIF}
          SimpleProcOfObj(tm);
          {$IFDEF DEBUGBUILD}{programlog.logoutstr('Run default constructor for '+self.TypeName)}{$ENDIF}
     end
     else ;//------------------------------------ShowError('Cant run default constructor for '+self.TypeName);
      //programlog.logoutstr('ERROR: cant run default constructor for '+self.TypeName,0)
end;
function ObjectDescriptor.FindMetod;
var pmd:pMetodDescriptor;
    ir:itrec;
begin
     result:=nil;
     pmd:=SimpleMenods.beginiterate(ir);
     if pmd<>nil then
     repeat
           if uppercase(pmd^.MetodName)=uppercase(mn) then
           begin
                result:=pmd;
                exit;
           end;
           pmd:=SimpleMenods.iterate(ir);
     until pmd=nil;
end;
procedure ObjectDescriptor.RunMetod;
var pmd:pMetodDescriptor;
//    pp:SimpleProcOfObj;
    tm:tmethod;
    {$IFDEF fpc}
    p:GDBPointer;
    ppp:pointer;
    {$ENDIF}
//    ppp2:pointer;
//    ps:gdbstring;
begin

      {$IFDEF fpc}
      ppp:=@self;
      p:=pvmt;
      {$ENDIF}
      pmd:=findmetod(mn);
      tm.Data:=obj;
      if (pmd^.Attributes and m_virtual)<>0 then
                                             begin
                                                  tm.Code:=ppointer(GDBPlatformint(self.PVMT)+GDBPlatformint(pmd^.MetodAddr))^;
                                             end
                                         else
                                             begin
                                                  tm.Code:=pmd^.MetodAddr;
                                             end;

      case pmd^.Attributes of
      m_procedure:SimpleProcOfObj(tm);
      m_function:SimpleProcOfObj(tm);
      m_constructor:
                                                        begin
                                                             {$IFDEF DELPHI}
                                                             begin
                                                             asm
                                                                mov eax,[self]
                                                                mov edx,[eax+pvmt]
                                                                mov eax,[obj]
                                                             end;
                                                             SimpleProcOfObj(tm);
                                                             end;
                                                             {$ENDIF}
                                                             {$IFDEF fpc}
                                                             {$ifdef CPU32}
                                                             begin
                                                             asm
                                                                mov eax,[ppp]
                                                                mov edx,[p]
                                                                mov eax,[obj]
                                                                call tm.Code
                                                             end;
                                                             //simpleproc(tm);
                                                              end;
                                                            {$endif CPU32}
                                                            {$ifdef CPU64}
                                                             begin
                                                             asm
                                                                {mov rax,[ppp]
                                                                mov rdx,[p]
                                                                mov rax,[obj]}
                                                                {mov rsi,[obj]
                                                                mov rdi,[p]}

                                                                mov rdi,[obj]
                                                                mov rsi,[p]

                                                                {mov rax,[ppp]
                                                                mov rdx,[p]
                                                                mov rax,[obj]}
                                                                call tm.Code
                                                             end;
                                                             //simpleproc(tm);
                                                             //self.initnul;
                                                              end;
                                                            {$endif CPU64}
                                                            {$ENDIF}
                                                        end;
                  end;
        //if parent<>nil then PobjectDescriptor(parent)^.RunMetod(mn,obj);
end;
procedure ObjectDescriptor.CopyTo(RD:PTUserTypeDescriptor);
var pcmd:PMetodDescriptor;
    pmd:PMetodDescriptor;
        ir:itrec;
begin
     if self.TypeName='DeviceDbBaseObject' then
                                               TypeName:=TypeName;
     if rd^.TypeName='DbBaseObject' then
                                               TypeName:=TypeName;
     inherited CopyTo(RD);
     pmd:=SimpleMenods.beginiterate(ir);
     if pmd<>nil then
     repeat
           pointer(pcmd):=PObjectDescriptor(rd)^.SimpleMenods.createobject;
           pcmd^.initnul;
           pcmd.MetodName:=pmd^.MetodName;
           pcmd.OperandsName:=pmd^.OperandsName;
           pcmd.ResultPTD:=pmd^.ResultPTD;
           pcmd.MetodAddr:=pmd^.MetodAddr;
           pcmd.Attributes:=pmd^.Attributes;
           pcmd.Operands.init({$IFDEF DEBUGBUILD}'{AD13B409-3869-418B-A314-DF70AB5C1601}',{$ENDIF}10,sizeof(GDBOperandDesc));
           //PObjectDescriptor(rd)^.SimpleMenods.Add(@pcmd);
           //pointer(pcmd.MetodName):=nil;
           //pointer(pcmd.OperandsName):=nil;
           pmd:=SimpleMenods.iterate(ir);
     until pmd=nil;
     PObjectDescriptor(rd)^.VMTCurrentOffset:=self.VMTCurrentOffset;
     PObjectDescriptor(rd)^.PVMT:=pvmt;
end;
function ObjectDescriptor.GetTypeAttributes;
begin
     result:=TA_COMPOUND or TA_OBJECT;
end;
function ObjectDescriptor.CreateProperties;
var
   pld:PtUserTypeDescriptor;
   p:pointer;
   objtypename:string;
   ir,ir2:itrec;
   baddr{,b2addr,eaddr}:GDBPointer;
//   ppd:PPropertyDeskriptor;
//   PDA:PTPropertyDeskriptorArray;
//   bmodesave:GDBInteger;
   ts:PTPropertyDeskriptorArray;
   sca,sa:GDBINTEGER;
   pcol:pboolean;

begin
     baddr:=addr;
     //b2addr:=baddr;
     ts:=inherited CreateProperties(PPDA,Name,PCollapsed,ownerattrib,bmode,addr,valkey,valtype);
     if bmode<>property_build then exit;
     ownerattrib:=ownerattrib or FA_READONLY;
     //eaddr:=addr;
        if colarray.parray=nil then
                                   colarray.CreateArray;
     if LincedObjects or(LincedData<>'') then begin
        colarray.Count:=colarray.max;
        sca:=colarray.max;
        sa:=PGDBOpenArrayOfData(baddr)^.getelemcount;
        if sa<=0 then exit;
        if sca>sa then
                      begin
                           //colarray.SetSize(sa);
                           fillchar(colarray.PArray^,sa,true);
                      end
                  else if sca=sa then
                                     begin

                                     end
                  else
                      begin
                           colarray.SetSize(sa);
                           //colarray.grow;
                           fillchar(colarray.PArray^,sa,true);
                      end;
                  end;
        if ppointer(baddr)^=nil then exit;

        if LincedData<>''then
        begin
 (*       bmodesave:=property_build;
     if PCollapsed<>field_no_attrib then
     begin
           ppd:=GetPPD(ppda,bmode);
           ppd^.Name:='LincedData';
           ppd^.Attr:=ownerattrib;
           ppd^.Collapsed:=PCollapsed;
           if bmode=property_build then
           begin
                gdbgetmem({$IFDEF DEBUGBUILD}'{6F9EBE33-15A8-4FF5-87D7-BF01A40F6789}',{$ENDIF}GDBPointer(pda),sizeof(TPropertyDeskriptorArray));
                pda^.init({$IFDEF DEBUGBUILD}'{EDA18239-9432-453B-BA54-0381DA1BB665}',{$ENDIF}100);;
                ppd^.SubProperty:=GDBPointer(pda);
                ppda:=pda;
           end else
           begin
                bmodesave:=bmode;
                bmode:=0;
                ppda:=PTPropertyDeskriptorArray(ppd^.subproperty);
                ppd:=GetPPD(ppda,bmode);
           end;
     end;
             if LincedData='TObjLinkRecord' then
                                    LincedData:=LincedData;
 *)
             pld:=pointer(SysUnit.TypeName2PTD(LincedData));
             //pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getelement(SysUnit.InterfaceTypes._TypeName2Index(LincedData))^));
             p:=PGDBOpenArrayOfData(baddr)^.beginiterate(ir);
             pcol:=colarray.beginiterate(ir2);
             if p<>nil then
             repeat
                   //b2addr:=p;
                   //pcol^:=false;
                   if bmode=property_build then
                                               pld^.CreateProperties({PPDA}ts,LincedData,pcol{PCollapsed}{field_no_attrib},ownerattrib,bmode,p,'','');
                   //p:=b2addr;
                   pcol:=colarray.iterate(ir2);
                   p:=PGDBOpenArrayOfData(baddr)^.iterate(ir);
                   //if (bmode<>property_build)then inc(bmode);
             until p=nil;
             //if bmodesave<>property_build then bmode:=bmodesave;
        end;
        if LincedObjects then
        begin
             p:=PGDBOpenArray(baddr)^.beginiterate(ir);
             pcol:=colarray.beginiterate(ir2);
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjName{ObjToGDBString('','')};
                   pld:=pointer(SysUnit.TypeName2PTD(PGDBaseObject(P)^.GetObjTypeName));
                   if bmode=property_build then
                                               pld^.CreateProperties({PPDA}ts,objtypename,pcol{PCollapsed}{field_no_attrib},ownerattrib,bmode,p,'','');
                   pcol:=colarray.iterate(ir2);
                   p:=PGDBOpenArrayOfData(baddr)^.iterate(ir);
             until p=nil;
             {p:=PGDBOpenArrayOfGDBPointer(PInstance)^.beginiterate(ir);
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjTypeName;
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename<>ObjN_GDBObjLine then
                                                            objtypename:=objtypename;
                        GDBStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf);
                        pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getelement(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate(ir);
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             GDBStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf);}
     end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UObjectDescriptor.initialization');{$ENDIF}
end.
