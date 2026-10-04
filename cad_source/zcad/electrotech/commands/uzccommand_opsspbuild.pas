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
unit uzcCommand_OPSSPBuild;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzeconsts,
  uzcLog,
  Varman,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcinterface,
  uzeentity,uzcentcable,uzeentdevice,uzeentline,uzeentmtext,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzbPaths,uzcTranslations,uzccmdfloatinsert,UGDBSelectedObjArray,uzeblockdef,
  uzeGeometryTypes,uzeGeometry,uzccomdraw,uzcstrconsts,uzcsysvars,uzeentitiesmanager,uzcutils,
  uzcCommand_KIPCableMark,uzeroot,uzeentityfactory,uzeentabstracttext;

implementation

type
  OPS_SPBuild=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

var
  OPS_SPBuild_com:OPS_SPBuild;

procedure InsertDat2(datname,Name:string;var currentcoord:TzePoint3d;var root:GDBObjRoot);
var
  pv:pGDBObjDevice;
  pt:pGDBObjMText;
  lx,uy,dy:double;
  tv:TzePoint3d;
  DC:TDrawContext;
begin
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
  pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@root.ObjArray,drawings.GetCurrentDWG.GetCurrentLayer,
    drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,currentcoord,1,0,datname);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(pv);
  pv^.formatentity(drawings.GetCurrentDWG^,dc);
  pv^.getoutbound(dc);
  lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.pMin.x;
  dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.pMin.y;
  uy:=pv.vp.BoundingBox.pMax.y-pv.P_insert_in_WCS.y;
  pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
  pv^.Formatentity(drawings.GetCurrentDWG^,dc);
  tv:=currentcoord;
  tv.x:=tv.x-lx-1;
  tv.y:=tv.y+(dy+uy)/2;
  if Name<>'' then begin
    pt:=pointer(AllocEnt(GDBMtextID));
    pt^.init(@root,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,UTF8Decode(Name),tv,2.5,0,0.65,cRightAngle,jsbc,1,1);
    pt^.TXTStyle:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
    root.ObjArray.AddPEntity(pt^);
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
    pt^.Formatentity(drawings.GetCurrentDWG^,dc);
  end;
  currentcoord.y:=currentcoord.y+dy+uy;
end;


function InsertDat(datname,sname,ename:string;datcount:integer;var currentcoord:TzePoint3d;var root:GDBObjRoot):pgdbobjline;
var
  pl:pgdbobjline;
  oldcoord,oldcoord2:TzePoint3d;
  DC:TDrawContext;
  tv:TzeVector3d;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if datcount=1 then
    InsertDat2(datname,sname,currentcoord,root)
  else if datcount>1 then begin
    InsertDat2(datname,sname,currentcoord,root);
    oldcoord:=currentcoord;
    currentcoord.y:=currentcoord.y+10;
    oldcoord2:=currentcoord;
    InsertDat2(datname,ename,currentcoord,root);
  end;
  if datcount=2 then begin
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  end else if datcount>2 then begin
    tv:=(oldcoord2-oldcoord).Normalized;
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord+tv*2);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord+tv*4,oldcoord+tv*6);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord+tv*8,oldcoord2);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  end;
  oldcoord:=currentcoord;
  currentcoord.y:=currentcoord.y+10;
  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
  root.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  Result:=pl;
end;


procedure OPS_SPBuild.Command(Operands:TCommandOperands);
var
  Count:integer;
  pcabledesk:PTCableDesctiptor;
  PCableSS:PGDBObjCable;
  ir,ir_inNodeArray:itrec;
  pvd:pvardesk;
  cman:TCableManager;
  pv:pGDBObjDevice;
  coord,currentcoord:TzePoint3d;
  pvmc:pvardesk;
  nodeend,nodestart:PGDBObjDevice;
  isfirst:boolean;
  startmat,endmat,startname,endname,prevname:string;
  uy,dy:double;
  lsave:PPointer;
  DC:TDrawContext;
  pCableSSvarext,ppvvarext,pnodeendvarext:TVariablesExtender;
begin
  if drawings.GetCurrentROOT.ObjArray.Count=0 then
    exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  coord:=cP3d__0__0__0;
  coord.y:=0;
  coord.x:=0;
  prevname:='';
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
    repeat
      PCableSS:=pcabledesk^.StartSegment;
      pCableSSvarext:=PCableSS^.GetExtension<TVariablesExtender>;
      { TODO : Сделать поиск переменных caseнезависимым }
      pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');

      if pvd<>nil then begin
        if pcabledesk.StartDevice<>nil then begin
          zcUI.TextMessage(pcabledesk.Name,TMWOHistoryOut);
          currentcoord:=coord;
          PTCableType(pvd^.Data.Addr.Instance)^:=TCT_ShleifOPS;
          lsave:=SysVar.dwg.DWG_CLayer^;
          SysVar.dwg.DWG_CLayer^:=drawings.GetCurrentDWG.LayerTable.GetSystemLayer;
          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_CABLE_MARK');
          pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,
            @drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,drawings.GetCurrentDWG.GetCurrentLayer,
            drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,currentcoord,1,0,'DEVICE_CABLE_MARK');
          zcSetEntPropFromCurrentDrawingProp(pv);
          SysVar.dwg.DWG_CLayer^:=lsave;
          ppvvarext:=pv^.GetExtension<TVariablesExtender>;
          pvmc:=ppvvarext.entityunit.FindVariable('CableName');
          if pvmc<>nil then begin
            pstring(pvmc^.Data.Addr.Instance)^:=pcabledesk.Name;
          end;
          Cable2CableMark(pcabledesk,pv);
          pv^.formatentity(drawings.GetCurrentDWG^,dc);
          pv^.getoutbound(dc);
          dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.pMin.y;
          uy:=pv.vp.BoundingBox.pMax.y-pv.P_insert_in_WCS.y;
          pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
          pv^.Formatentity(drawings.GetCurrentDWG^,dc);
          currentcoord.y:=currentcoord.y+dy+uy;
          isfirst:=True;
          pcabledesk^.Devices.beginiterate(ir_inNodeArray);
          nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
          nodestart:=nil;
          Count:=0;
          if nodeend<>nil then
            repeat
              if nodeend^.bp.ListPos.Owner<>pointer(drawings.GetCurrentROOT) then
                nodeend:=pointer(nodeend^.bp.ListPos.Owner);
              pnodeendvarext:=nodeend^.GetExtension<TVariablesExtender>;
              pvd:=pnodeendvarext.entityunit.FindVariable('NMO_Name');
              if pvd<>nil then begin
                endname:=pvd^.Data.PTD.GetValueAsString(pvd^.Data.Addr.Instance);
              end else
                endname:='';
              pvd:=pnodeendvarext.entityunit.FindVariable('DB_link');
              if pvd<>nil then begin
                endmat:=nodeend^.Name+pvd^.Data.PTD.GetValueAsString(pvd^.Data.Addr.Instance);
                if isfirst then begin
                  isfirst:=False;
                  nodestart:=nodeend;
                  startmat:=endmat;
                  startname:=endname;
                end;
                if startmat<>endmat then begin
                  InsertDat(nodestart^.Name,startname,prevname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot);
                  Count:=0;
                  nodestart:=nodeend;
                  startmat:=endmat;
                  startname:=endname;
                end;
                Inc(Count);
              end;
              prevname:=endname;
              nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
            until nodeend=nil;
          if nodestart<>nil then
            InsertDat(nodestart^.Name,startname,endname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(
              drawings.GetCurrentDWG^)
          else
            InsertDat('_error_here',startname,endname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(
              drawings.GetCurrentDWG^);
          pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_WireCount');
          if pvd=nil then
            coord.x:=coord.x+12
          else begin
            if PInteger(pvd^.Data.Addr.Instance)^<>0 then
              coord.x:=coord.x+6*PInteger(pvd^.Data.Addr.Instance)^
            else
              coord.x:=coord.x+12;
          end;
        end;

      end;
      pcabledesk:=cman.iterate(ir);
    until pcabledesk=nil;

  cman.done;

  zcRedrawCurrentDrawing;
end;



initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  OPS_SPBuild_com.init('OPS_SPBuild',0,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
