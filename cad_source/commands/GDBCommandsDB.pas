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
  gdbobjectsconstdef,zcadstrconsts,plugins,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  varman,
  UGDBOpenArrayOfByte,
  iodxf,
  cmdline,
  gdbEntity,
  shared,
  gdbasetypes,strutils,forms,Controls,zcadinterface;
implementation
uses sltexteditor,UObjectDescriptor,projecttreewnd,commandline,log,GDBSubordinated;

function DBaseAdd_com:GDBInteger;
var //t:PUserTypeDescriptor;
    p:pointer;
    pu:ptunit;
    pvd:pvardesk;
    vn:GDBString;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(DrawingDeviceBaseUnitName);
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
end;
function DBaseRename_com:GDBInteger;
var //t:PUserTypeDescriptor;
    pvd,pdbv:pvardesk;
    //pu:ptunit;
    pv:pGDBObjEntity;
    ir:itrec;
    c:integer;

    p:pointer;
    pu:ptunit;
    vn:GDBString;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
           begin
                 if sltexteditor1=nil then
                                  Application.CreateForm(Tsltexteditor1, sltexteditor1);
                 sltexteditor1.caption:=('Переименовать вхождение');
                 sltexteditor1.helptext.Caption:=' _EQ ';
                 sltexteditor1.EditField.Caption:=copy(pdbv.name,4,length(pdbv.name)-3);
                 if DoShowModal(sltexteditor1)=mrok then
                 begin
                      pdbv.name:='_EQ'+sltexteditor1.EditField.Caption;
                 end;
           end;
     end
        else
            HistoryOutStr(rscmCommandOnlyCTXMenu);
end;
function DBaseLink_com:GDBInteger;
var //t:PUserTypeDescriptor;
    pvd,pdbv:pvardesk;
    //pu:ptunit;
    pv:pGDBObjEntity;
    ir:itrec;
    c:integer;

    p:pointer;
    pu:ptunit;
    vn:GDBString;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=ptdrawing(gdb.GetCurrentDWG).DWGUnits.findunit(DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
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
                                                    PGDBString(pvd^.data.Instance)^:=pdbv^.name;
                                                    CreateDBLinkProcess(pv,gdb.GetCurrentDWG^);
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
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@DBaseAdd_com,'DBaseAdd',CADWG,0);
  CreateCommandFastObjectPlugin(@DBaseLink_com,'DBaseLink',CADWG,0);
  CreateCommandFastObjectPlugin(@DBaseRename_com,'DBaseRename',CADWG,0);
end;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsDB.initialization');{$ENDIF}
     startup;
end.
