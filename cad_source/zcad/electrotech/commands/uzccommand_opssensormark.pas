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
unit uzcCommand_OPSSensorMark;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzeentity,uzeentdevice,uzccablemanager,
  uzeentline,
  uzcvariablesutils,
  uzgldrawcontext,
  uzcdrawings,uzeconsts,
  uzcEnitiesVariablesExtender,Varman,uzcdevicebaseabstract,uzcstrconsts,uzcutils,UUnitManager,
  uzCtnrVectorPBaseEntity,uzbPaths,uzcTranslations,zUndoCmdChgVariable,uzcdrawing,zUndoCmdChgTypes;

implementation

function OPS_Sensor_Mark_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pcabledesk:PTCableDesctiptor;
  ir,ir2,ir_inNodeArray:itrec;
  pvd,pvd1,pvd2,pvd3,pvd4:pvardesk;
  defaultunit:TUnit;
  currentunit:PTUnit;
  UManager:TUnitManager;
  ucount:integer;
  ptn:PGDBObjDevice;
  p:pointer;
  cman:TCableManager;
  SaveEntUName,SaveCabUName:string;
  cablemetric,devicemetric,numingroupmetric:string;
  ProcessedDevices:TZctnrVectorPGDBaseEntity;
  Name:string;
  DC:TDrawContext;
  pcablestartsegmentvarext,pptnownervarext:TVariablesExtender;
  UndoStartMarkerPlaced:boolean;
const
  DefNumMetric='default_num_in_group';

  function GetNumUnit(uname:string):PTUnit;
  begin
    Result:=UManager.internalfindunit(uname);
    if Result=nil then begin
      Result:=pointer(UManager.CreateObject);
      Result.init(uname);
      Result.CopyFrom(@defaultunit);
    end;
  end;

begin
  UndoStartMarkerPlaced:=False;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if drawings.GetCurrentROOT.ObjArray.Count=0 then
    exit;
  ProcessedDevices.init(100);
  cman.init;
  cman.build;
  UManager.init;
  defaultunit.init(DefNumMetric);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/objcalc/opsmarkdef.pas'),(@defaultunit));
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
    repeat
      begin
        pcablestartsegmentvarext:=pcabledesk.StartSegment^.GetExtension<TVariablesExtender>;
        pvd:=pcablestartsegmentvarext.entityunit.FindVariable('GC_Metric');
        if pvd<>nil then begin
          cablemetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
        end else begin
          cablemetric:='';
        end;

        currentunit:=Umanager.beginiterate(ir2);
        if currentunit<>nil then
          repeat
            pvd:=currentunit.FindVariable('CDC_temp');
            PInteger(pvd.Data.Addr.Instance)^:=0;
            pvd:=currentunit.FindVariable('CDSC_temp');
            PInteger(pvd.Data.Addr.Instance)^:=1;
            currentunit:=Umanager.iterate(ir2);
          until currentunit=nil;
        currentunit:=nil;
        ptn:=pcabledesk^.Devices.beginiterate(ir_inNodeArray);
        if ptn<>nil then
          repeat
            begin
              pptnownervarext:=ptn^.bp.ListPos.Owner^.GetExtension<TVariablesExtender>;
              pvd:=pptnownervarext.entityunit.FindVariable('GC_Metric');
              if pvd<>nil then begin
                devicemetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
              end else begin
                devicemetric:='';
              end;
              pvd:=pptnownervarext.entityunit.FindVariable('GC_InGroup_Metric');
              if pvd<>nil then begin
                numingroupmetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
                if numingroupmetric='' then
                  numingroupmetric:=DefNumMetric;

              end else begin
                numingroupmetric:=DefNumMetric;
              end;
              if devicemetric=cablemetric then begin
                if ProcessedDevices.IsDataExist(@ptn^.bp.ListPos.Owner^)=-1 then begin
                  currentunit:=GetNumUnit(numingroupmetric);

                  SaveCabUName:=pcablestartsegmentvarext.entityunit.Name;
                  pcablestartsegmentvarext.entityunit.Name:='Cable';
                  p:=@pcablestartsegmentvarext.entityunit;
                  currentunit.InterfaceUses.PushBackIfNotPresent(p);
                  ucount:=currentunit.InterfaceUses.Count;

                  SaveEntUName:=pptnownervarext.entityunit.Name;
                  pptnownervarext.entityunit.Name:='Entity';
                  p:=@pptnownervarext.entityunit;
                  currentunit.InterfaceUses.PushBackIfNotPresent(p);

                  pvd1:=pptnownervarext.entityunit.FindVariable('GC_NumberInGroup');
                  if pvd1<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd1^.Data.PTD,pvd1^.Data.Addr.GetInstance,'GC_NumberInGroup'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd2:=pptnownervarext.entityunit.FindVariable('GC_HeadDevice');
                  if pvd2<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd2^.Data.PTD,pvd2^.Data.Addr.GetInstance,'GC_HeadDevice'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd3:=pptnownervarext.entityunit.FindVariable('GC_HDGroup');
                  if pvd3<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd3^.Data.PTD,pvd3^.Data.Addr.GetInstance,'GC_HDGroup'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd4:=pptnownervarext.entityunit.FindVariable('GC_HDShortName');
                  if pvd4<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd3^.Data.PTD,pvd4^.Data.Addr.GetInstance,'GC_HDShortName'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;

                  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/objcalc/opsmark.pas'),(currentunit));
                  ProcessedDevices.PushBackData(ptn^.bp.ListPos.Owner);

                  Dec(currentunit.InterfaceUses.Count,2);

                  pptnownervarext.entityunit.Name:=SaveEntUName;
                  pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;

                  PGDBObjLine(ptn^.bp.ListPos.Owner)^.Formatentity(drawings.GetCurrentDWG^,dc);
                end else begin
                  pvd:=pptnownervarext.entityunit.FindVariable('NMO_Name');
                  if pvd<>nil then begin
                    Name:='"'+pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance)+'"';
                  end else begin
                    Name:='"без имени"';
                  end;
                  zcUI.TextMessage(format(
                    'Попытка повторной нумерации устройства %s кабелем (сегментом кабеля) %s',
                    [Name,'"'+pcabledesk^.Name+'"']),TMWOHistoryOut);
                end;
              end;
            end;
            ptn:=pcabledesk^.Devices.iterate(ir_inNodeArray);
          until ptn=nil;
        if currentunit<>nil then
          currentunit.InterfaceUses.Count:=ucount-1;
      end;
      pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;
      pcabledesk:=cman.iterate(ir);
    until pcabledesk=nil;

  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  defaultunit.done;
  UManager.done;
  cman.done;
  ProcessedDevices.Clear;
  ProcessedDevices.Done;
  zcRedrawCurrentDrawing;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@OPS_Sensor_Mark_com,'OPS_Sensor_Mark',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
