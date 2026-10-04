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
{$mode delphi}
unit uzcCommand_KIPCableMark;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzeentity,uzeentdevice,uzccablemanager,
  uzcvariablesutils,
  uzgldrawcontext,
  uzcdrawings,uzeconsts,
  uzcEnitiesVariablesExtender,Varman,uzcdevicebaseabstract,uzcstrconsts,uzcutils;

function GetCableMaterial(pcd:PTCableDesctiptor):string;
procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);

implementation

function GetCableMaterial(pcd:PTCableDesctiptor):string;
var
  pvmc:pvardesk;
  line:string;
  eq:pvardesk;
begin
  pvmc:=FindVariableInEnt(pcd^.StartSegment,'DB_link');
  if pvmc<>nil then begin
    line:=pstring(pvmc^.Data.Addr.Instance)^;
    eq:=DWGDBUnit.FindVariable(line);
    if eq=nil then
      Result:='(!)'+line
    else begin
      Result:=PDbBaseObject(eq^.Data.Addr.Instance)^.NameShort;
    end;
  end else
    Result:=rsNotSpecified;
end;


procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);
var
  pvm,pvl:pvardesk;
  pentvarext:TVariablesExtender;
begin
  pentvarext:=pv^.GetExtension<TVariablesExtender>;
  pvm:=pentvarext.entityunit.FindVariable('CableMaterial');
  if pvm<>nil then begin
    pstring(pvm^.Data.Addr.Instance)^:=GetCableMaterial(pcd);
  end;
  pvl:=pentvarext.entityunit.FindVariable('CableLength');
  if pvl<>nil then
    pDouble(pvl^.Data.Addr.Instance)^:=pcd^.length;
end;


function _Cable_mark_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjDevice;
  ir:itrec;
  pvn:pvardesk;
  cman:TCableManager;
  pcd:PTCableDesctiptor;
  DC:TDrawContext;
  pentvarext:TVariablesExtender;
begin
  cman.init;
  cman.build;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      begin
        if pv^.GetObjType=GDBDeviceID then
          if pv^.Name='CABLE_MARK' then begin
            pentvarext:=pv^.GetExtension<TVariablesExtender>;
            pvn:=pentvarext.entityunit.FindVariable('CableName');
            if (pvn<>nil) then begin
              pcd:=cman.Find(pstring(pvn^.Data.Addr.Instance)^);
              if pcd<>nil then begin
                Cable2CableMark(pcd,pv);
                pv^.Formatentity(drawings.GetCurrentDWG^,dc);
              end else
                zcUI.TextMessage(format('Cable %s not found on plan',[pstring(pvn^.Data.Addr.Instance)^]),TMWOHistoryOut);
            end;
          end;
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  zcRedrawCurrentDrawing;
  cman.done;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@_Cable_mark_com,'KIP_Cable_Mark',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
