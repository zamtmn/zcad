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

unit uzcregnavigatordevices;
{$INCLUDE def.inc}
interface
uses uzcfnavigatordevices,uzcfcommandline,uzbpaths,TypeDescriptors,uzctranslations,uzcshared,Forms,
     uzbtypes,varmandef,uzeconsts,uzeentdevice,uzcnavigatorsnodedesk,
     uzeentity,zcobjectinspector,uzcguimanager,uzcenitiesvariablesextender,uzbstrproc,
     Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,uzcsysinfo,LazLogger,VirtualTrees;
type
  TNavigatorRisers=class(TNavigatorDevices)
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);override;
    function NavGetOnlyText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): String;
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);override;

    function EntsFilter(pent:pGDBObjEntity):Boolean;override;
    function TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;override;
  end;
  TNavigatorCables=class(TNavigatorDevices)
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);override;

    function EntsFilter(pent:pGDBObjEntity):Boolean;override;
  end;
var
  NavigatorRisers:TNavigatorRisers;
  NavigatorCables:TNavigatorCables;
implementation
function TNavigatorCables.EntsFilter(pent:pGDBObjEntity):Boolean;
begin
  result:=pent^.GetObjType=GDBCableID;
end;
procedure TNavigatorCables.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
  begin
     if pnd^.NodeMode<>TNMData then
                                   celltext:=pnd^.name
                               else
                                   celltext:=GetEntityVariableValue(pnd^.pent,'NMO_Name','Absent Name')+' (:'+GetEntityVariableValue(pnd^.pent,'CABLE_Segment','??')+')';
  end;
end;


procedure TNavigatorRisers.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
  begin
     if pnd^.NodeMode<>TNMData then
                                   celltext:=pnd^.name
                               else
                                   celltext:=GetEntityVariableValue(pnd^.pent,'RiserName','Absent Name')+' ('+GetEntityVariableValue(pnd^.pent,'Elevation','??')+')'+' "'+GetEntityVariableValue(pnd^.pent,'Text','??')+'"';
  end;
end;
function TNavigatorRisers.NavGetOnlyText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): String;
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
  begin
     if pnd^.NodeMode<>TNMData then
                                   result:=pnd^.name
                               else
                                   result:=GetEntityVariableValue(pnd^.pent,'RiserName','Absent Name');
  end;
end;
 procedure TNavigatorRisers.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  pnd1,pnd2:PTNodeData;
  pvd1,pvd2:pvardesk;
  pentvarext1,pentvarext2:PTVariablesExtender;
begin
  //inherited VTCompareNodes(Sender,Node1,Node2,Column,Result);
  Result :=  AnsiNaturalCompare(NavGetOnlyText(sender,Node1, Column), NavGetOnlyText(sender,Node2, Column),False);
  if result=0 then
  begin
     pnd1 := Sender.GetNodeData(Node1);
     pnd2 := Sender.GetNodeData(Node2);
     if assigned(pnd1) and assigned(pnd2) then
     begin
       pentvarext1:=pnd1^.pent^.GetExtension(typeof(TVariablesExtender));
       pentvarext2:=pnd2^.pent^.GetExtension(typeof(TVariablesExtender));
       if assigned(pentvarext1) and assigned(pentvarext2) then
       begin
         pvd1:=pentvarext1^.entityunit.FindVariable('Elevation');
         pvd2:=pentvarext2^.entityunit.FindVariable('Elevation');
         if assigned(pvd1) and assigned(pvd2) then
           if pdouble(pvd1^.data.Instance)^ > pdouble(pvd2^.data.Instance)^ then
            result:=-1
           else if pdouble(pvd1^.data.Instance)^ < pdouble(pvd2^.data.Instance)^ then
            result:=1
       end;
     end;
  end;
end;

function TNavigatorRisers.EntsFilter(pent:pGDBObjEntity):Boolean;
begin
  if pent^.GetObjType=GDBDeviceID then
    if pos('EL_CABLE_',PGDBObjDevice(pent).Name)=1 then
      result:=true
    else
      result:=false
  else
    result:=false
end;
function  TNavigatorRisers.TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;
var
  BaseName:string;
  basenode:PVirtualNode;
begin
  result:={nil}rootdesk.rootnode;
  Name:=GetEntityVariableValue(pent,'RiserName','Absent Name');

  //if GroupByPrefix then begin
    //BaseName:=GetEntityVariableValue(pent,'NMO_Prefix','Absent Prefix');
    //basenode:=rootdesk.find(BaseName,rootdesk.rootnode);
  //end else
  //  basenode:=rootdesk.rootnode;

  //if GroupByBase then begin
    //BaseName:=GetEntityVariableValue(pent,'NMO_BaseName','Absent BaseName');
    //result:=rootdesk.find(BaseName,basenode);
  //end else
  //  result:=basenode;
end;

procedure ZCADFormSetupProc(Form:TControl);
begin
end;
initialization
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorDevices','Devices',TNavigatorDevices,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorDevices,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorRisers','Risers',TNavigatorRisers,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorRisers,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorCables','Cables',TNavigatorCables,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorCables,true);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

