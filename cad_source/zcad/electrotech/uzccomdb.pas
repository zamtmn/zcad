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

unit uzccomdb;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,uzbpaths,uzcsysvars,uzctranslations,uzcdrawing,uzeconsts,uzcstrconsts,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcdrawings,
  sysutils,
  varmandef,
  varman,
  uzctnrVectorBytes,
  uzeentity,
  uzcdevicebaseabstract,UUnitManager,strutils,forms,Controls,uzcinterface,uzedrawingdef,uzctnrvectorstrings,strmy,
  uzcenitiesvariablesextender,uzcfsinglelinetexteditor,UObjectDescriptor,uzcfprojecttree,uzccommandsmanager,uzclog,uzeentsubordinated,
  uzcuitypes;

procedure DBLinkProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);

implementation

function DBaseAdd_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //t:PUserTypeDescriptor;
    p:pointer;
    pu:ptunit;
    pvd:pvardesk;
    vn:String;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pvd:=pu^.FindVariable('DBCounter');
           vn:=inttostr(Integer(pvd.data.Addr.Instance^));
           vn:='_EQ'+dupestring('0',6-length(vn))+vn;
           pu.CreateVariable(vn,PUserTypeDescriptor(PTHardTypedData(commandmanager.ContextCommandParams).ptd)^.TypeName);
           p:=pu.FindVariable(vn).data.Addr.Instance;
           PObjectDescriptor(PTHardTypedData(commandmanager.ContextCommandParams)^.ptd)^.RunMetod('initnul',p);
           PUserTypeDescriptor(PTHardTypedData(commandmanager.ContextCommandParams)^.ptd)^.CopyInstanceTo(PTHardTypedData(commandmanager.ContextCommandParams)^.Instance,p);
           //PObjectDescriptor(PTTypedData(commandmanager.ContextCommandParams)^.ptd)^.RunMetod('format',p);
           inc(Integer(pvd.data.Addr.Instance^));
     end
        else
            ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
     result:=cmd_ok;
end;
function DBaseRename_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pdbv:pvardesk;
    pu:ptunit;
    s,s1:String;
    parseresult:PTZctnrVectorStrings;
    parseerror:boolean;
    renamed:boolean;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTHardTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
           begin
                 if SingleLineTextEditorForm=nil then
                                  Application.CreateForm(TSingleLineTextEditorForm, SingleLineTextEditorForm);
                 SingleLineTextEditorForm.caption:=('Rename entry');
                 SingleLineTextEditorForm.HelpText.Caption:=' _EQ ';
                 SingleLineTextEditorForm.EditField.Caption:=copy(pdbv.name,4,length(pdbv.name)-3);
                 renamed:=false;
                 repeat
                 if ZCMsgCallBackInterface.DoShowModal(SingleLineTextEditorForm)=ZCmrok then
                 begin
                      s:='_EQ'+SingleLineTextEditorForm.EditField.Caption;
                      s1:=s;

                      if pu^.FindVariable(s)<>nil then
                                                 begin
                                                      ZCMsgCallBackInterface.TextMessage(format(rsEntryAlreadyExist,[s]),TMWOShowError);
                                                 end
                      else
                      begin
                      parseresult:=runparser('_sym'#0'[{_symordig'#0'}',s1,parseerror);
                      if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
                      if parseerror and (s1='') then
                                        begin
                                             ZCMsgCallBackInterface.TextMessage(format(rsRenamedTo,['Entry',pdbv.name,s]),TMWOHistoryOut);
                                             pdbv.name:=s;
                                             renamed:=true;
                                        end
                                           else
                                               ZCMsgCallBackInterface.TextMessage(format(rsInvalidIdentificator,[s]),TMWOShowError);
                      end;
                 end;
                 until renamed or (SingleLineTextEditorForm.ModalResult<>mrok);
           end;
     end
        else
            ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
     result:=cmd_ok;
end;
procedure DBLinkProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvnt,pdbv:pvardesk;
   pdbu:ptunit;
   pum:PTUnitManager;
   pentvarext:TVariablesExtender;
begin
     pentvarext:=pEntity^.GetExtension<TVariablesExtender>;
     pvn:=pentvarext.entityunit.FindVariable('DB_link');
     pvnt:=pentvarext.entityunit.FindVariable('DB_MatName');
     if pvnt<>nil then
     pvnt^.attrib:=pvnt^.attrib or (vda_RO);
     if (pvn<>nil)and(pvnt<>nil) then
     begin
          pum:=drawing.GetDWGUnits;
          if pum<>nil then
          begin
            pdbu:=pum^.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
            if pdbu<>nil then
            begin
              pdbv:=pdbu^.FindVariable(pstring(pvn.data.Addr.Instance)^);
              if pdbv<>nil then
                               pstring(pvnt.data.Addr.Instance)^:=PDbBaseObject(pdbv.data.Addr.Instance)^.Name
                           else
                               pstring(pvnt.data.Addr.Instance)^:='Error!!!';
              exit;
            end;
          end;
     end;
     if pvnt<>nil then
                      pstring(pvnt.data.Addr.Instance)^:='Error!!!'
end;
function DBaseLink_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //t:PUserTypeDescriptor;
    pvd,pdbv:pvardesk;
    //pu:ptunit;
    pv:pGDBObjEntity;
    ir:itrec;
    c:integer;

    //p:pointer;
    pu:ptunit;
    //vn:String;
    pentvarext:TVariablesExtender;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
           pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           pdbv:=pu.InterfaceVariables.findvardescbyinst(PTHardTypedData(commandmanager.ContextCommandParams)^.Instance);
           if pdbv<>nil then
           begin
                 c:=0;
                 pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
                 if pv<>nil then
                 repeat
                      if pv^.Selected then
                                          begin
                                               pentvarext:=pv^.GetExtension<TVariablesExtender>;
                                               pvd:=pentvarext.entityunit.FindVariable('DB_link');
                                               if pvd<>nil then
                                               begin
                                                    PString(pvd^.data.Addr.Instance)^:=pdbv^.name;
                                                    DBLinkProcess(pv,drawings.GetCurrentDWG^);
                                                    inc(c);
                                               end;
                                          end;
                 pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
                 until pv=nil;
                 ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[c]),TMWOHistoryOut);
           end;
     end
        else
            ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
    result:=cmd_ok;
end;
procedure startup;
begin
  CreateZCADCommand(@DBaseAdd_com,'DBaseAdd',CADWG,0);
  CreateZCADCommand(@DBaseLink_com,'DBaseLink',CADWG,0);
  CreateZCADCommand(@DBaseRename_com,'DBaseRename',CADWG,0);
end;
begin
     startup;
end.
