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

unit UObjectDescriptor;

{$MODE DELPHI}
interface
uses LCLProc,gzctnrVectorObjects,URecordDescriptor,uzctnrVectorBytes,sysutils,
     gzctnrVectorTypes,uzedimensionaltypes,UBaseTypeDescriptor,TypeDescriptors,
     strmy,uzctnrvectorstrings,objects,gzctnrVector,
     varmandef,uzbtypes,uzbstrproc,TypInfo,uzbLogIntf;
type
GDBTOperandStoreMode=Byte;
GDBOperandDesc=record
                     PTD:PUserTypeDescriptor;
                     StoreMode:GDBTOperandStoreMode;
               end;
GDBMetodModifier=Word;
TOperandsVector=GZVector<GDBOperandDesc>;
PMetodDescriptor=^MetodDescriptor;
MetodDescriptor=object(GDBaseObject)
                      objname:String;
                      MetodName:String;
                      OperandsName:String;
                      Operands:{GDBOpenArrayOfdata}TOperandsVector; {DATA}
                      ResultPTD:PUserTypeDescriptor;
                      MetodAddr:Pointer;
                      Attributes:GDBMetodModifier;
                      punit:pointer;
                      NameHash:LongWord;
                      constructor init(objn,mn,dt:String;ma:Pointer;attr:GDBMetodModifier;pu:pointer);
                      destructor Done;virtual;
                end;
simpleproc=procedure of object;
TSimpleMenodsVector=GZVectorObjects<MetodDescriptor>;
TPropertiesVector=GZVector<PropertyDescriptor>;

PObjectDescriptor=^ObjectDescriptor;
ObjectDescriptor=object(RecordDescriptor)
                       PVMT:Pointer;
                       VMTCurrentOffset:Integer;
                       PDefaultConstructor:Pointer;
                       SimpleMenods:{GDBOpenArrayOfObjects}TSimpleMenodsVector;
                       LincedData:String;
                       LincedObjects:Boolean;
                       ColArray:TZctnrVectorBytes;
                       Properties:TPropertiesVector;


                       constructor init(const tname:string;pu:pointer);
                       function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                       procedure CopyTo(RD:PTUserTypeDescriptor);
                       procedure RegisterVMT(pv:Pointer);
                       procedure RegisterDefaultConstructor(pv:Pointer);
                       procedure RegisterObject(pv,pc:Pointer);
                       procedure AddMetod(const objname,mn,dt:TInternalScriptString;ma:Pointer;attr:GDBMetodModifier);
                       procedure AddProperty(var pd:PropertyDescriptor);
                       function FindMetod(mn:TInternalScriptString;obj:Pointer):PMetodDescriptor;virtual;
                       function FindMetodAddr(mn:TInternalScriptString;obj:Pointer;out pmd:pMetodDescriptor):TMethod;virtual;
                       procedure RunMetod(const mn:TInternalScriptString;obj:Pointer);
                       procedure SimpleRunMetodWithArg(const mn:TInternalScriptString;obj,arg:Pointer);
                       procedure RunDefaultConstructor(PInstance:Pointer);
                       //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PTZctnrVectorBytes;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                       //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:TZctnrVectorBytes;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                       destructor Done;virtual;
                       function GetTypeAttributes:TTypeAttr;virtual;
                       procedure SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;const prefix:TInternalScriptString);virtual;
                       procedure MagicFreeInstance(PInstance:Pointer);virtual;
                       procedure RegisterTypeinfo(ti:PTypeInfo);virtual;
                       procedure CorrectFieldsOffset(ti: PTypeInfo);
                       procedure CorrectCurrentFieldsOffset(td:PTypeData;var i:integer);
                 end;
PTGenericVectorData=^TGenericVectorData;
TGenericVectorData=GZVector<byte>;
implementation
uses varman;
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
  parseerror:Boolean;
  parseresult{,subparseresult}:PTZctnrVectorStrings;
  od:GDBOperandDesc;
  i:integer;
begin
     punit:=pu;
     Pointer(ObjName):=nil;
     Pointer(MetodName):=nil;
     Pointer(OperandsName):=nil;
     ResultPTD:=nil;
     ObjName:=objn;
     MetodName:=mn;
     NameHash:=makehash(uppercase(MetodName));
     OperandsName:=dt;
//     if dt='(var obj):Integer;' then
//                                        dt:=dt;

     MetodAddr:=ma;
     Attributes:=attr;
     Operands.init(10);
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
                                                   od.PTD:=ptunit(punit).TypeName2PTD(parseresult^.getData(parseresult.Count-1));
                                                   for i:=1 to parseresult.Count-1 do
                                                                                     Operands.PushBackData(od);
                                              end
                            else begin
                                      parseresult:=runparser('_identifiers_cs'#0'_softspace'#0,dt,parseerror);
                                      if parseerror then
                                              begin
                                                   od.PTD:=ptunit(punit).TypeName2PTD('Pointer');
                                                   for i:=1 to parseresult.Count do
                                                                                     Operands.PushBackData(od);
                                              end
                                 end;
                            if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                            parseresult:=runparser('=;_softspace'#0,dt,parseerror);
                            until not parseerror;
                            parseresult:=runparser('=)_softspace'#0,dt,parseerror);
                       end;
     parseresult:=runparser('=:_softspace'#0'_identifier'#0,dt,parseerror);
     if parseerror then
                       begin
                            self.ResultPTD:=ptunit(punit).TypeName2PTD(parseresult^.getData(0));
                       end;
     if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
     parseresult:=runparser('=:_softspace'#0'_identifier'#0'_softspace'#0,dt,parseerror);
     if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
     //parseresult:=runparser('_softspace'#0'=(_softspace'#0'_identifier'#0'_softspace'#0'=)',line,parseerror);

end;
procedure ObjectDescriptor.MagicFreeInstance(PInstance:Pointer);
begin
     RunMetod('Done',PInstance);
     inherited;
end;
procedure ObjectDescriptor.RegisterTypeinfo(ti:PTypeInfo);
begin
//     if TypeName='TMSEditor' then begin
//          if TypeName='TMSEditor' then
//                    ti:=ti;
//     end;
     CorrectFieldsOffset(ti);
end;
procedure ObjectDescriptor.CorrectCurrentFieldsOffset(td:PTypeData;var i:integer);
var
   mf: PManagedField;
   j:integer;
   pfd:pFieldDescriptor;
   ti:PTypeInfo;
   pti:PTypeInfo;
   ptd:PTypeData;
begin
     {pti:=td^.ParentInfo;
     ptd:=GetTypeData(pti);}
     mf:=@td.ManagedFldCount;
     inc(pointer(mf),sizeof(td.ManagedFldCount));
     for j:=0 to td.ManagedFldCount-1 do
     begin
          ti:=mf.TypeRef;
          if j=0 then begin
            if ti.Kind=tkObject then begin
              CorrectCurrentFieldsOffset(GetTypeData(ti),i);
              dec(i);
            end;
          end else begin
            pfd:=Fields.getDataMutable(i);
            if Pfd.Offset<>mf.FldOffset then
               Pfd.Offset:=mf.FldOffset;
            Pfd.Offset:=mf.FldOffset;
          end;
          inc(i);
          inc(mf);
     end;
end;
procedure ObjectDescriptor.CorrectFieldsOffset(ti:PTypeInfo);
var
   td:PTypeData;
   mf: PManagedField;
   i,j:integer;
   etd:PRecordDescriptor;
   pfd:pFieldDescriptor;
begin
     td:=GetTypeData(ti);
     self.SizeInBytes:=td.RecSize;
     //exit;
     i:=0;
     CorrectCurrentFieldsOffset(td,i);
end;


procedure ObjectDescriptor.AddProperty(var pd:PropertyDescriptor);
begin
     Properties.PushBackData(pd);
     //Pointer(pd.base.ProgramName):=nil;
     //Pointer(pd.r):=nil;
     //Pointer(pd.w):=nil;
end;

procedure ObjectDescriptor.SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;const prefix:TInternalScriptString);
//var pd:PFieldDescriptor;
//    d:FieldDescriptor;
//    ir:itrec;
begin
        membuf.TXTAddStringEOL(prefix+'.initnul;');
        inherited;
         membuf.TXTAddStringEOL('');
end;
(*function ObjectDescriptor.Serialize;
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
             pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.{exttype.}getDataMutable(SysUnit.InterfaceTypes._TypeName2Index(LincedData))^));
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
                        //if objtypename<>ObjN_GDBObjLine then
                        //                                    objtypename:=objtypename;
                        FundamentalStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf,sub);
                        pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.{exttype.}getDataMutable(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf,sub);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate(ir);
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             FundamentalStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf,sub);
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
             p:=PGDBOpenArrayOfData(PInstance)^.getDataMutable(i);
             pld^.DeSerialize(p,saveflag,membuf,linkbuf);
             end;
        end;
        if LincedObjects then
        begin
             i:=0;
             objtypename:='';
             FundamentalStringDescriptorObj.DeSerialize(@objtypename,saveflag,membuf,linkbuf);
             while objtypename<>ObjN_ArrayEnd do
             begin
                  p:=PGDBOpenArrayOfData(PInstance)^.getDataMutable(i);
                  pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.{exttype.}getDataMutable(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                  Getmem(pointer(p^),pld^.SizeInBytes);
                  pld^.deSerialize(p^,saveflag,membuf,linkbuf);

                  objtypename:='';
                  FundamentalStringDescriptorObj.DeSerialize(@objtypename,saveflag,membuf,linkbuf);
                  inc(i);
             end;

             (*for i := 0 to PGDBOpenArrayOfGDBPointer(PInstance)^.Count-1 do
             begin
                   p:=PGDBOpenArrayOfData(PInstance)^.getDataMutable(i);
                   FundamentalStringDescriptorObj^.DeSerialize(@objtypename,saveflag,membuf);
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename=ObjN_ArrayEnd then system.Break;
                        pld:=pointer(PUserTypeDescriptor(Types.exttype.getDataMutable(Types.TypeName2Index(objtypename))^));
                        Getmem(pointer(p^),pld^.SizeInBytes);
                        pld^.deSerialize(p^,saveflag,membuf);
                   end;
                   objtypename:='';
             end;
             objtypename:='';*)
//        end;
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
                        FundamentalStringDescriptorObj^.Serialize(@objtypename,saveflag,membuf,linkbuf);
                        pld:=pointer(PUserTypeDescriptor(Types.exttype.getDataMutable(Types.TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate;
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             FundamentalStringDescriptorObj^.Serialize(@objtypename,saveflag,membuf,linkbuf);
        end;}
//end;*)
procedure freemetods(p:Pointer);
begin
     PMetodDescriptor(p)^.MetodName:='';
     PMetodDescriptor(p)^.ObjName:='';
     PMetodDescriptor(p)^.Operands.done;
end;
procedure FREEPROP(p:Pointer);
begin
     PPropertyDescriptor(p)^.base.ProgramName:='';
     PPropertyDescriptor(p)^.base.UserName:='';
     PPropertyDescriptor(p)^.r:='';
     PPropertyDescriptor(p)^.w:='';
end;
destructor ObjectDescriptor.done;
begin
     //SimpleMenods.FreewithprocAndDone(freemetods);
     SimpleMenods.Done;
     //fields.FreewithprocAndDone(freeprop);
     Properties.Freewithproc(@freeprop);
     Properties.done;
     //Properties.FreeAndDone;
     parent:=nil;
     ColArray.done;
     LincedData:='';
     inherited;
end;
constructor ObjectDescriptor.init;
{type
VMT=RECORD
  Size,NegSize:Longint;
  ParentLink:PVMT;
END;}
begin
     inherited init(tname,pu);
     SimpleMenods.init(20);
     Properties.init(20);
     pvmt:=nil;
     {$IFDEF FPC}VMTCurrentOffset:=12;{$ENDIF}
     {$IFDEF CPU64}VMTCurrentOffset:=24{sizeof(VMT)};{$ENDIF}
     {$IFDEF DELPHI}VMTCurrentOffset:=0;{$ENDIF}
     PDefaultConstructor:=nil;
     pointer(LincedData):=nil;
     LincedObjects:=false;
     ColArray.init(200);
end;
procedure ObjectDescriptor.AddMetod;
var pcmd:pMetodDescriptor;
    pmd:PMetodDescriptor;
begin
     pmd:=FindMetod(mn,nil);
     if pmd=nil then
                    begin
                         pcmd:=pointer(SimpleMenods.CreateObject);
                         if (attr and m_virtual)=0 then
                                                       pcmd.init(objname,mn,dt,ma,attr,punit)
                                                   else
                                                       begin
//                                                            if uppercase(mn)='FORMAT' then
//                                                                                           mn:=mn;
                                                            pcmd.init(objname,mn,dt,pointer(vmtcurrentoffset),attr,punit);
                                                            inc(vmtcurrentoffset,{4 cpu64}sizeof(pointer));
                                                       end;
                    end
                else
                    begin
                         if (attr and m_virtual)=0 then
                                                        begin
//                                                             if uppercase(mn)='FORMAT' then
//                                                                                           mn:=mn;
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
procedure ObjectDescriptor.RegisterObject(pv,pc:Pointer);
begin
     RegisterVMT(pv);
     RegisterDefaultConstructor(pc);
end;
procedure ObjectDescriptor.RunDefaultConstructor(PInstance:Pointer);
var
   tm:tmethod;
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
     end
     else ;//------------------------------------ShowError('Cant run default constructor for '+self.TypeName);
      //programlog.logoutstr('ERROR: cant run default constructor for '+self.TypeName,0)
end;
function ObjectDescriptor.FindMetod;
var pmd:pMetodDescriptor;
    ir:itrec;
    //f,s:shortstring;
    //l:longint;
    //tm:tmethod;
    h:LongWord;
    umn:TInternalScriptString;
begin
     result:=nil;
     umn:=uppercase(mn);
     h:=MakeHash(umn);
     pmd:=SimpleMenods.beginiterate(ir);
     if pmd<>nil then
     repeat
           {if PVMT<>nil then
           begin
                 if (pmd^.Attributes and m_virtual)<>0 then
                                             begin
                                                  tm.Code:=
                                                  ppointer(PtrInt(self.PVMT)+
                                                  PtrInt(pmd^.MetodAddr))^;
                                             end
                                         else
                                             begin
                                                  tm.Code:=pmd^.MetodAddr;
                                             end;
           if GetLineInfo(ptruint(tm.Code),f,s,l) then
                                                      programlog.logoutstr(pmd^.MetodName+' '+pmd^.objname + ' '+f+' '+s,0);
           end;}
           if h=pmd^.NameHash then
           if uppercase(pmd^.MetodName)=umn then
           begin
                result:=pmd;
                exit;
           end
              else
                  result:=nil;
           pmd:=SimpleMenods.iterate(ir);
     until pmd=nil;
end;
function ObjectDescriptor.FindMetodAddr(mn:TInternalScriptString;obj:Pointer;out pmd:pMetodDescriptor):TMethod;
begin
     pmd:=findmetod(mn,obj);
     if pmd<>nil then
     begin
     result.Data:=obj;
     if (pmd^.Attributes and m_virtual)<>0 then
                                            begin
                                                 result.Code:=
                                                 ppointer(PtrUInt(self.PVMT)+
                                                 PtrUInt(pmd^.MetodAddr){+12})^;
                                            end
                                        else
                                            begin
                                                 result.Code:=pmd^.MetodAddr;
                                            end;
     end
     else
     begin
          result.Data:=obj;
          result.Code:=nil;
     end;
end;
procedure ObjectDescriptor.SimpleRunMetodWithArg(const mn:TInternalScriptString;obj,arg:Pointer);
var pmd:pMetodDescriptor;
    tm:tmethod;
begin
     tm:=FindMetodAddr(mn,obj,pmd);
     if pmd=nil then exit;
     case (pmd^.Attributes)and(not m_virtual) of
     m_procedure:
                 begin
                      SimpleProcOfObjDouble(tm)(PDouble(arg)^);
                 end;
     m_function:PDouble(arg)^:=SimpleFuncOfObjDouble(tm);
     end;
end;

procedure ObjectDescriptor.RunMetod;
var pmd:pMetodDescriptor;
    tm:tmethod;
    {$IFDEF fpc}
    p:Pointer;
    ppp:pointer;
    {$ENDIF}
begin
      {$IFDEF fpc}
      ppp:=@self;
      p:=pvmt;
      {$ENDIF}
      //pmd:=findmetod(mn,obj);
      tm:=FindMetodAddr(mn,obj,pmd);
      if pmd=nil then exit;
      {tm.Data:=obj;
      if (pmd^.Attributes and m_virtual)<>0 then
                                             begin
                                                  tm.Code:=
                                                  ppointer(PtrInt(self.PVMT)+
                                                  PtrInt(pmd^.MetodAddr))^;
                                             end
                                         else
                                             begin
                                                  tm.Code:=pmd^.MetodAddr;
                                             end;
      deb:=(pmd^.Attributes)and(not m_virtual);}
      case (pmd^.Attributes)and(not m_virtual) of
      m_procedure,m_destructor:
                  begin
                       {$ifdef WIN64}
                       //tm.Code:=ppointer(PtrInt(self.PVMT)+
                       //         PtrInt(pmd^.MetodAddr)+12)^;
                       {$endif WIN64}
                  SimpleProcOfObj(tm);
                       //pgdbaseobject(obj)^.Format;
                  (*asm
                                                                {$ifdef WINDOWS}
                                                                mov rax,[obj]//win64
                                                                mov rcx,[obj]//win64
                                                                mov rax,[rax]
                                                                call tm.Code//win64
                                                                {$endif WINDOWS}
                  end;*)
                  end;
      m_function:SimpleProcOfObj(tm);
      m_constructor:
                                                        begin
                                                             //CallVoidConstructor(Ctor: codepointer; Obj: pointer; VMT: pointer): pointer;inline;
                                                             CallVoidConstructor(tm.Code,obj,pvmt);
                                                             (*
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

                                                                //{$ifdef LINUX}
                                                                //mov rdi,[obj]//lin64
                                                                //mov rsi,[p]//lin64
                                                                //call tm.Code//lin64
                                                                //{$endif LINUX}

                                                                {$ifdef WIN64}
                                                                mov rcx,[obj]//win64
                                                                mov rdx,[p]//win64
                                                                call tm.Code//win64
                                                                {$else}
                                                                mov rdi,[obj]//lin64
                                                                mov rsi,[p]//lin64
                                                                call tm.Code//lin64
                                                                {$endif WIN64}

                                                                {mov rax,[ppp]
                                                                mov rdx,[p]
                                                                mov rax,[obj]}

                                                             end;
                                                             //simpleproc(tm);
                                                             //self.initnul;
                                                              end;
                                                            {$endif CPU64}
                                                            {$ENDIF}*)
                                                        end;
                  end;
        //if parent<>nil then PobjectDescriptor(parent)^.RunMetod(mn,obj);
end;
procedure ObjectDescriptor.CopyTo(RD:PTUserTypeDescriptor);
var pcmd:PMetodDescriptor;
    pmd:PMetodDescriptor;
        ir:itrec;
begin
     zTraceLn('{T+}[ZSCRIPT]ObjectDescriptor.CopyTo(@%s)',[RD.TypeName]);
     //programlog.LogOutFormatStr('ObjectDescriptor.CopyTo(@%s)',[RD.TypeName],lp_IncPos,LM_Debug);
//     if self.TypeName='DeviceDbBaseObject' then
//                                               TypeName:=TypeName;
//     if rd^.TypeName='DbBaseObject' then
//                                               TypeName:=TypeName;
     inherited CopyTo(RD);
     pmd:=SimpleMenods.beginiterate(ir);
     if pmd<>nil then
     repeat
           pointer(pcmd):=PObjectDescriptor(rd)^.SimpleMenods.createobject;
           pcmd^.initnul;
           pcmd.MetodName:=pmd^.MetodName;
           pcmd.objname:=pmd^.objname;
           pcmd.NameHash:=pmd^.NameHash;
           pcmd.OperandsName:=pmd^.OperandsName;
           pcmd.ResultPTD:=pmd^.ResultPTD;
           pcmd.MetodAddr:=pmd^.MetodAddr;
           pcmd.Attributes:=pmd^.Attributes;
           pcmd.Operands.init(10);
           //PObjectDescriptor(rd)^.SimpleMenods.AddByPointer(@pcmd);
           //pointer(pcmd.MetodName):=nil;
           //pointer(pcmd.OperandsName):=nil;
           pmd:=SimpleMenods.iterate(ir);
     until pmd=nil;
     PObjectDescriptor(rd)^.VMTCurrentOffset:=self.VMTCurrentOffset;
     PObjectDescriptor(rd)^.PVMT:=pvmt;
     zTraceLn('{T-}[ZSCRIPT]end;{ObjectDescriptor.CopyTo}');
     //programlog.logoutstr('end;{ObjectDescriptor.CopyTo}',lp_DecPos,LM_Debug);
end;
function ObjectDescriptor.GetTypeAttributes;
begin
     result:=TA_COMPOUND or TA_OBJECT;
end;
function processPROPERTYppd({ppd:PPropertyDeskriptor;}pp:PPropertyDescriptor):Pointer;
begin
     //ppd.mode:=PDM_Property;
     //ppd^.Name:=pp^.PropertyName;
     //ppd^.PTypeManager:=pp^.PFT;
     //if ppd^.valueAddres=nil then
                                 begin
                                      Getmem(result,pp^.base.PFT.SizeInBytes);
                                 end;
end;
function ObjectDescriptor.CreateProperties;
var
   pld:PtUserTypeDescriptor;
   p{,p2}:pointer;
   pp:PPropertyDescriptor;
   objtypename,propname:string;
   ir,ir2:itrec;
   baddr{,b2addr,eaddr}:Pointer;
//   ppd:PPropertyDeskriptor;
//   PDA:PTPropertyDeskriptorArray;
//   bmodesave:Integer;
   ts:PTPropertyDeskriptorArray;
   sca,sa:Integer;
   pcol:pboolean;
   ppd:PPropertyDeskriptor;
begin
     baddr:=addr;
     //b2addr:=baddr;
     ts:=inherited CreateProperties(f,PDM_Field,PPDA,Name,PCollapsed,ownerattrib,bmode,addr,valkey,valtype);
     exit;

     pp:=Properties.beginiterate(ir);
     if pp<>nil then
     repeat
           if pp^.base.UserName='' then
                                  propname:=pp^.base.ProgramName
                              else
                                  propname:=pp^.base.UserName;

           if bmode=property_build then
                                       p:=processPROPERTYppd({ppd{,}pp)
                                   else
                                       begin
                                            ppd:=pointer(ppda^.getDataMutable(abs(bmode)-1));
                                            ppd:=PPointer(ppd)^;
                                            ppd.r:=pp.r;
                                            ppd.w:=pp.w;
                                            p:=ppd^.valueAddres;
                                       end;
           ObjectDescriptor.SimpleRunMetodWithArg(pp.r,baddr,p);
           //p2:=p;
           PTUserTypeDescriptor(pp^.base.PFT)^.CreateProperties(f,PDM_Property,PPDA,propname,@pp^.collapsed,{ppd^.Attr}pp^.base.Attributes or ownerattrib,bmode,p,'','');

           pp:=Properties.iterate(ir);
     until pp=nil;

     if bmode<>property_build then exit;

     //-------------------------ownerattrib:=ownerattrib or FA_READONLY;

     //eaddr:=addr;
        if colarray.parray=nil then
                                   colarray.CreateArray;
     if LincedObjects or(LincedData<>'') then begin
        colarray.Count:=colarray.max;
        sca:=colarray.max;
        sa:={PGDBOpenArrayOfData}PTGenericVectorData(baddr)^.getcount;
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
                Getmem(Pointer(pda),sizeof(TPropertyDeskriptorArray));
                pda^.init(100);;
                ppd^.SubProperty:=Pointer(pda);
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
             //pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getDataMutable(SysUnit.InterfaceTypes._TypeName2Index(LincedData))^));
             p:={PGDBOpenArrayOfData}PTGenericVectorData(baddr)^.beginiterate(ir);
             pcol:=colarray.beginiterate(ir2);
             if p<>nil then
             repeat
                   //b2addr:=p;
                   //pcol^:=false;
                   //---------------------------------if bmode=property_build then
                                               pld^.CreateProperties(f,PDM_Field,{PPDA}ts,LincedData,pcol{PCollapsed}{field_no_attrib},ownerattrib,bmode,p,'','');
                   //p:=b2addr;
                   pcol:=colarray.iterate(ir2);
                   p:={PGDBOpenArrayOfData}PTGenericVectorData(baddr)^.iterate(ir);
                   //if (bmode<>property_build)then inc(bmode);
             until p=nil;
             //if bmodesave<>property_build then bmode:=bmodesave;
        end;
        if LincedObjects then
        begin
             //if assigned(sysvar.debug.ShowHiddenFieldInObjInsp) then
             if not debugShowHiddenFieldInObjInsp{sysvar.debug.ShowHiddenFieldInObjInsp^} then
                                                                exit;
             p:={PGDBOpenArrayOfData}PTGenericVectorData(baddr)^.beginiterate(ir);
             pcol:=colarray.beginiterate(ir2);
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjName{ObjToString('','')};
                   pld:=pointer(SysUnit.TypeName2PTD(PGDBaseObject(P)^.GetObjTypeName));
                   if bmode=property_build then
                                               pld^.CreateProperties(f,PDM_Field,{PPDA}ts,objtypename,pcol{PCollapsed}{field_no_attrib},ownerattrib,bmode,p,'','');
                   pcol:=colarray.iterate(ir2);
                   p:={PGDBOpenArrayOfData}PTGenericVectorData(baddr)^.iterate(ir);
             until p=nil;
             {p:=PGDBOpenArrayOfGDBPointer(PInstance)^.beginiterate(ir);
             if p<>nil then
             repeat
                   objtypename:=PGDBaseObject(P)^.GetObjTypeName;
                   if objtypename<>ObjN_NotRecognized then
                   begin
                        if objtypename<>ObjN_GDBObjLine then
                                                            objtypename:=objtypename;
                        FundamentalStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf);
                        pld:=pointer(PUserTypeDescriptor(SysUnit.InterfaceTypes.exttype.getDataMutable(SysUnit.InterfaceTypes._TypeName2Index(objtypename))^));
                        pld^.Serialize(p,saveflag,membuf,linkbuf);
                   end;
                   p:=PGDBOpenArrayOfGDBPointer(PInstance)^.iterate(ir);
             until p=nil;
             objtypename:=ObjN_ArrayEnd;
             FundamentalStringDescriptorObj.Serialize(@objtypename,saveflag,membuf,linkbuf);}
     end;
end;
begin
end.
