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
{$Codepage UTF8}
{$Mode delphi}{$H+}
unit uzccommand_VariablesAdd;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,
  uzcstrconsts,
  uzeenttext,
  uzccommandsabstract,
  
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzcutils,
  sysutils,
  uzcinterface,
  uzeentity,
  uzeentmtext,
  uzeentblockinsert,
  Varman,
  uzcenitiesvariablesextender,
  uzcLog,
  uzeentsubordinated,
  varmandef,UBaseTypeDescriptor,uzeconsts,uzeentdevice,Masks;
type
  TEntsProcessedReport=record
    Processed,Total,Selected,Filtred:Integer;
    procedure Init;
    procedure IncTotal;inline;
    procedure IncSelected;inline;
    procedure IncFiltred;inline;
    procedure IncProcessed;inline;
    procedure Report;
  end;

TMFunction=(
        TMF_MainFunction,
        TMF_Delegate,
        TMF_All
       );
PTVariablesAddParams=^TVariablesAddParams;
TVariablesAddParams=record
                    MFunction:TMFunction;
                    NevVars:ansistring;
              end;
PTVarTextSelectParams=^TVarTextSelectParams;
TVarTextSelectParams=record
                    TemplateToFind:ansistring;
              end;
  {REGISTEROBJECTTYPE SelSim_com}
  VariablesAdd_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure Run(pdata:PtrInt); virtual;
                   end;
  VarTextSelect_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure Run(pdata:PtrInt); virtual;
                   end;
var
   VariablesAdd:VariablesAdd_com;
   VariablesAddParams:TVariablesAddParams;
   VarTextSelectParams:TVarTextSelectParams;
   VarTextSelect:VarTextSelect_com;
implementation

procedure TEntsProcessedReport.Init;
begin
  Total:=0;
  Selected:=0;
  Filtred:=0;
  Processed:=0;
end;
procedure TEntsProcessedReport.IncTotal;
begin
  inc(Total);
end;
procedure TEntsProcessedReport.IncSelected;
begin
  inc(Selected);
end;
procedure TEntsProcessedReport.IncFiltred;
begin
  inc(Filtred);
end;
procedure TEntsProcessedReport.IncProcessed;
begin
  inc(Processed);
end;
procedure TEntsProcessedReport.Report;
begin
  ZCMsgCallBackInterface.TextMessage(sysutils.format(rscmEntitiesCounter,[Processed,Total,Selected,Filtred]),TMWOHistoryOut);
end;

procedure VariablesAdd_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;

  if zcGetRealSelEntsCount>0 then
  begin
       commandmanager.DMAddMethod(rscmAdd,'Add variables to selected ents',run);
       commandmanager.DMShow;
       inherited CommandStart(context,'');
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

procedure VariablesAdd_com.Run(pdata:PtrInt);
var
   pobj: pGDBObjEntity;
   ir:itrec;
   VarExt:TVariablesExtender;
   accepted:boolean;
   vn,vt,vv,vun:String;
   vd: vardesk;
   counter:TEntsProcessedReport;
begin
  extractvarfromdxfstring(VariablesAddParams.NevVars,vn,vt,vv,vun);
  counter.init;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    counter.IncTotal;
    if pobj^.selected then begin
      counter.IncSelected;
      VarExt:=pobj^.GetExtension<TVariablesExtender>;
      if VarExt<>nil then begin
        accepted:=false;
        case VariablesAddParams.MFunction of
                           TMF_MainFunction:accepted:=VarExt.isMainFunction;
                               TMF_Delegate:accepted:=not VarExt.isMainFunction;
                                    TMF_All:accepted:=true;
        end;
        if accepted then begin
          counter.IncFiltred;
          if VarExt.entityunit.FindVariable(vn)=nil then begin
            VarExt.entityunit.setvardesc(vd,vn,vun,vt);
            VarExt.entityunit.InterfaceVariables.createvariable(vd.name,vd);
            PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Addr.Instance,vv);
            counter.IncProcessed;
            pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
          end;
        end;
      end;
    end;
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  counter.Report;
  Commandmanager.executecommandend;
end;
procedure VarTextSelect_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;

  if zcGetRealSelEntsCount>0 then
  begin
       commandmanager.DMAddMethod(rscmSelect,'Select',run);
       commandmanager.DMShow;
       inherited CommandStart(context,'');
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure VarTextSelect_com.Run(pdata:PtrInt);
var
   pobj,psubobj: pGDBObjEntity;
   ir,ir2:itrec;
   counter:TEntsProcessedReport;
begin
  counter.init;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then begin
      pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      if pobj^.GetObjType=GDBDeviceID then begin
        psubobj:=PGDBObjDevice(pobj)^.VarObjArray.beginiterate(ir2);
        if psubobj<>nil then
        repeat
          counter.IncTotal;
          if (psubobj^.GetObjType=GDBMTextID)or(psubobj^.GetObjType=GDBTextID) then
            if MatchesWindowsMask(PGDBObjText(psubobj)^.Template,VarTextSelectParams.TemplateToFind) then begin
              counter.IncProcessed;
              psubobj^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.Selector);
            end;

          psubobj:=PGDBObjDevice(pobj)^.VarObjArray.iterate(ir2);
        until psubobj=nil;
      end
    end;
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  counter.Report;
  Commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  SysUnit^.RegisterType(TypeInfo(TMFunction));
  SysUnit^.RegisterType(TypeInfo(PTVariablesAddParams));
  SysUnit^.SetTypeDesk(TypeInfo(TMFunction),['MainFunction','Delegate', 'All']);
  SysUnit^.SetTypeDesk(TypeInfo(TVariablesAddParams),['Process only','Variables']);
  VariablesAdd.init('VariablesAdd',CADWG or CASelEnts,0);
  VariablesAdd.CEndActionAttr:=[];
  VariablesAddParams.MFunction:=TMF_MainFunction;
  VariablesAddParams.NevVars:='NMO_SpecPos|String|??|Позиция по спецификации';
  VariablesAdd.SetCommandParam(@VariablesAddParams,'PTVariablesAddParams');


  SysUnit^.RegisterType(TypeInfo(PTVarTextSelectParams));
  SysUnit^.SetTypeDesk(TypeInfo(TVarTextSelectParams),['TemplateToFind']);
  VarTextSelect.init('VarTextSelect',CADWG or CASelEnts,0);
  VarTextSelect.CEndActionAttr:=[];
  VarTextSelectParams.TemplateToFind:='*NMO_Name*';
  VarTextSelect.SetCommandParam(@VarTextSelectParams,'PTVarTextSelectParams');
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
