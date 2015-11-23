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

unit GDBCommandsDB;
{$INCLUDE def.inc}

interface
uses
  paths,uzcsysvars,intftranslations,ugdbdrawing,gdbobjectsconstdef,zcadstrconsts,plugins,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  varman,
  UGDBOpenArrayOfByte,
  gdbEntity,
  uzcshared,
  devicebaseabstract,UUnitManager,gdbasetypes,strutils,forms,Controls,zcadinterface,UGDBDrawingdef,UGDBStringArray,strmy,memman;

procedure DBLinkProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);

implementation
uses enitiesextendervariables,sltexteditor,UObjectDescriptor,projecttreewnd,commandline,uzclog,GDBSubordinated;

function DBaseAdd_com(operands:TCommandOperands):TCommandResult;
var //t:PUserTypeDescriptor;
    p:pointer;
    pu:ptunit;
    pvd:pvardesk;
    vn:GDBString;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pvd:=pu^.FindVariable('DBCounter');
           vn:=inttostr(GDBInteger(pvd.data.Instance^));
           vn:='_EQ'+dupestring('0',6-length(vn))+vn;
           pu.createvariable(vn,PUserTypeDescriptor(PTTypedData(commandmanager.ContextCommandParams).ptd)^.TypeName);
           p:=pu.FindVariable(vn).data.Instance;
           PObjectDescriptor(PTTypedData(commandmanager.ContextCommandParams)^.ptd)^.RunMetod('initnul',p);
           PUserTypeDescriptor(PTTypedData(commandmanager.ContextCommandParams)^.ptd)^.CopyInstanceTo(PTTypedData(commandmanager.ContextCommandParams)^.Instance,p);
           //PObjectDescriptor(PTTypedData(commandmanager.ContextCommandParams)^.ptd)^.RunMetod('format',p);
           inc(GDBInteger(pvd.data.Instance^));
     end
        else
            HistoryOutStr(rscmCommandOnlyCTXMenu);
     result:=cmd_ok;
end;
function DBaseRename_com(operands:TCommandOperands):TCommandResult;
var
    pdbv:pvardesk;
    pu:ptunit;
    s,s1:gdbstring;
    parseresult:PGDBGDBStringArray;
    parseerror:boolean;
    renamed:boolean;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
           begin
                 if sltexteditor1=nil then
                                  Application.CreateForm(Tsltexteditor1, sltexteditor1);
                 sltexteditor1.caption:=('Rename entry');
                 sltexteditor1.helptext.Caption:=' _EQ ';
                 sltexteditor1.EditField.Caption:=copy(pdbv.name,4,length(pdbv.name)-3);
                 renamed:=false;
                 repeat
                 if DoShowModal(sltexteditor1)=mrok then
                 begin
                      s:='_EQ'+sltexteditor1.EditField.Caption;
                      s1:=s;

                      if pu^.FindVariable(s)<>nil then
                                                 begin
                                                      uzcshared.ShowError(format(rsEntryAlreadyExist,[s]));
                                                 end
                      else
                      begin
                      parseresult:=runparser('_sym'#0'[{_symordig'#0'}',s1,parseerror);
                      if parseresult<>nil then begin parseresult^.FreeAndDone;GDBfreeMem(gdbpointer(parseresult));end;
                      if parseerror and (s1='') then
                                        begin
                                             uzcshared.HistoryOutStr(format(rsRenamedTo,['Entry',pdbv.name,s]));
                                             pdbv.name:=s;
                                             renamed:=true;
                                        end
                                           else
                                               uzcshared.ShowError(format(rsInvalidIdentificator,[s]));
                      end;
                 end;
                 until renamed or (sltexteditor1.ModalResult<>mrok);
           end;
     end
        else
            HistoryOutStr(rscmCommandOnlyCTXMenu);
     result:=cmd_ok;
end;
procedure DBLinkProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvnt,pdbv:pvardesk;
   pdbu:ptunit;
   pum:PTUnitManager;
   pentvarext:PTVariablesExtender;
begin
     pentvarext:=pEntity^.GetExtension(typeof(TVariablesExtender));
     pvn:=pentvarext^.entityunit.FindVariable('DB_link');
     pvnt:=pentvarext^.entityunit.FindVariable('DB_MatName');
     if pvnt<>nil then
     pvnt^.attrib:=pvnt^.attrib or (vda_RO);
     if (pvn<>nil)and(pvnt<>nil) then
     begin
          pum:=drawing.GetDWGUnits;
          if pum<>nil then
          begin
            pdbu:=pum^.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
            if pdbu<>nil then
            begin
              pdbv:=pdbu^.FindVariable(pstring(pvn.data.Instance)^);
              if pdbv<>nil then
                               pstring(pvnt.data.Instance)^:=PDbBaseObject(pdbv.data.Instance)^.Name
                           else
                               pstring(pvnt.data.Instance)^:='Error!!!';
              exit;
            end;
          end;
     end;
     if pvnt<>nil then
                      pstring(pvnt.data.Instance)^:='Error!!!'
end;
function DBaseLink_com(operands:TCommandOperands):TCommandResult;
var //t:PUserTypeDescriptor;
    pvd,pdbv:pvardesk;
    //pu:ptunit;
    pv:pGDBObjEntity;
    ir:itrec;
    c:integer;

    //p:pointer;
    pu:ptunit;
    //vn:GDBString;
    pentvarext:PTVariablesExtender;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
           begin
                 c:=0;
                 pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                 if pv<>nil then
                 repeat
                      if pv^.Selected then
                                          begin
                                               pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
                                               pvd:=pentvarext^.entityunit.FindVariable('DB_link');
                                               if pvd<>nil then
                                               begin
                                                    PGDBString(pvd^.data.Instance)^:=pdbv^.name;
                                                    DBLinkProcess(pv,gdb.GetCurrentDWG^);
                                                    inc(c);
                                               end;
                                          end;
                 pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                 until pv=nil;
                 HistoryOutSTR(format(rscmNEntitiesProcessed,[inttostr(c)]));
           end;
     end
        else
            HistoryOutStr(rscmCommandOnlyCTXMenu);
{     if TempPGDBEqNode<>nil then
     begin
             c:=0;
             pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
             if pv<>nil then
             repeat
                  if pv^.Selected then
                                      begin
                                           pvd:=pv^.ou.FindVariable('DB_link');
                                           if pvd<>nil then
                                           begin
                                                PGDBString(pvd^.data.Instance)^:=TempPGDBEqNode^.NodeName;
                                                inc(c);
                                           end;
                                      end;
             pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
             until pv=nil;
             HistoryOutSTR(inttostr(c)+' примитивов обработано');
     end
        else
            HistoryOut('Команда работает только из контекстного меню');  }
    result:=cmd_ok;
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@DBaseAdd_com,'DBaseAdd',CADWG,0);
  CreateCommandFastObjectPlugin(@DBaseLink_com,'DBaseLink',CADWG,0);
  CreateCommandFastObjectPlugin(@DBaseRename_com,'DBaseRename',CADWG,0);
end;
begin
     startup;
end.
