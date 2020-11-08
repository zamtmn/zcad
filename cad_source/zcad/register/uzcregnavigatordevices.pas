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
uses uzcfnavigatordevices,uzcfcommandline,uzbpaths,TypeDescriptors,uzctranslations,Forms,
     uzbtypes,varmandef,uzeconsts,uzeentdevice,uzcnavigatorsnodedesk,
     uzeentity,zcobjectinspector,uzcguimanager,uzcenitiesvariablesextender,uzbstrproc,
     Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,uzcsysinfo,LazLogger,laz.VirtualTrees,
     uzcstrconsts,uzcfnavigatordevicescxmenu,uzcmainwindow,MacroDefIntf,sysutils;
resourcestring
  rsDevices='Devices';
  rsRisers='Risers';
  rsCables='Cables';

type

  TNavigatorDevicesMacroMethods=class
    function MacroFuncEntInNodeAddr(const {%H-}Param: string; const Data: PtrInt;
                                      var {%H-}Abort: boolean): string;
  end;

  TNavigatorRisers=class(TNavigatorDevices)
    {procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);override;
    function NavGetOnlyText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): String;
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);override;}

    //function EntsFilter(pent:pGDBObjEntity):Boolean;override;
    //function TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;override;
  end;
  TNavigatorCables=class(TNavigatorDevices)
    //procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
    //                     TextType: TVSTTextType; var CellText: String);override;

    //function EntsFilter(pent:pGDBObjEntity):Boolean;override;
  end;
var
  NavigatorRisers:TNavigatorRisers;
  NavigatorCables:TNavigatorCables;

  NavigatorDevicesMacroMethods:TNavigatorDevicesMacroMethods;
implementation
{function TNavigatorCables.EntsFilter(pent:pGDBObjEntity):Boolean;
begin
  result:=pent^.GetObjType=GDBCableID;
end;}
{procedure TNavigatorCables.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
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
                                   celltext:=GetEntityVariableValue(pnd^.pent,'NMO_Name',rsNameAbsent)+' (:'+GetEntityVariableValue(pnd^.pent,'CABLE_Segment','??')+')';
  end;
end;}


{procedure TNavigatorRisers.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
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
                                   celltext:=GetEntityVariableValue(pnd^.pent,'RiserName',rsNameAbsent)+' ('+GetEntityVariableValue(pnd^.pent,'Elevation','??')+')'+' "'+GetEntityVariableValue(pnd^.pent,'Text','??')+'"';
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
                                   result:=GetEntityVariableValue(pnd^.pent,'RiserName',rsNameAbsent);
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
end;}

{function TNavigatorRisers.EntsFilter(pent:pGDBObjEntity):Boolean;
begin
  if pent^.GetObjType=GDBDeviceID then
    if pos('EL_CABLE_',PGDBObjDevice(pent).Name)=1 then
      result:=true
    else
      result:=false
  else
    result:=false
end;}
(*function  TNavigatorRisers.TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;
begin
  result:={nil}rootdesk.rootnode;
  Name:=GetEntityVariableValue(pent,'RiserName',rsNameAbsent);

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
end;*)
function NDMCCFHaveSubNodes(const Context:TNavigatorDevicesContext):boolean;
begin
  if Context.pnode<>nil then begin
    if Context.pnode^.ChildCount>0 then
      result:=true
    else
      result:=false;
  end else
    result:=false;
end;
function NDMCCFNodeHaveEntity(const Context:TNavigatorDevicesContext):boolean;
var
  pnd:PTNodeData;
begin
  if (Context.pnode<>nil)and(Context.tree<>nil) then begin
    pnd:=Context.tree.GetNodeData(Context.pnode);
    if pnd<>Nil then
      if pnd^.pent<>nil  then
        exit(true);
  end;
  result:=false;
end;

function TNavigatorDevicesMacroMethods.MacroFuncEntInNodeAddr(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
var
  pnd:PTNodeData;
begin
  if Data<>0 then begin
    if (PTNavigatorDevicesContext(data).pnode<>nil)and(PTNavigatorDevicesContext(data).tree<>nil) then begin
      pnd:=PTNavigatorDevicesContext(data).tree.GetNodeData(PTNavigatorDevicesContext(data).pnode);
      if pnd<>Nil then
        if pnd^.pent<>nil  then
          exit('$'+inttohex(ptruint(pnd^.pent),8));
    end;
  end;
    Abort:=true;
end;

procedure ZCADFormSetupProc(Form:TControl);
begin
  InitializeNavigatorDevicesCXMenu(ZCADMainWindow,ZCADMainWindow.StandartActions);

  NavigatorDevicesMenuManager.RegisterContextCheckFunc('HaveSubNodes',NDMCCFHaveSubNodes);
  NavigatorDevicesMenuManager.RegisterContextCheckFunc('HaveEntity',NDMCCFNodeHaveEntity);

  NavigatorDevicesMacros.AddMacro(TTransferMacro.Create('EntInNodeAddr','',
                                  'Addres of entity  in node',NavigatorDevicesMacroMethods.MacroFuncEntInNodeAddr,[]));

end;
function CreateNavigatorDevices:TForm;
begin
 result:=tform(TNavigatorDevices.NewInstance);
 TNavigatorDevices(result).TreeBuildMap:='+NMO_Prefix|+NMO_BaseName|+@@[NMO_Name]';
 TNavigatorDevices(result).IncludeEntities:='+Device';
 TNavigatorDevices(result).IncludeProperties:='';//'+*|-%%[Name]=EL_CABLE_*';
 TNavigatorDevices(result).UseMainFunctions:=True;
end;
function CreateNavigatorRisers:TForm;
begin
 result:=tform(TNavigatorRisers.NewInstance);
 TNavigatorRisers(result).TreeBuildMap:='+@@[RiserName]:@@[Elevation]:@@[Text]';
 TNavigatorRisers(result).IncludeEntities:='+Device';
 TNavigatorRisers(result).IncludeProperties:='+%%[Name]=EL_CABLE_*';
 TNavigatorRisers(result).UseMainFunctions:=False;
end;
function CreateNavigatorCables:TForm;
begin
 result:=tform(TNavigatorCables.NewInstance);
 {TNavigatorCables(result).TreeBuildMap:='+NMO_BaseName|+@@[NMO_Name]:@@[CABLE_Segment]';
 TNavigatorRisers(result).IncludeEntities:='+GDBObjCable';
 TNavigatorRisers(result).IncludeProperties:='+*';
 TNavigatorCables(result).UseMainFunctions:=False;}

 TNavigatorCables(result).TreeBuildMap:='+%%[Layer]';
 TNavigatorRisers(result).IncludeEntities:='';
 TNavigatorRisers(result).IncludeProperties:='';
 TNavigatorCables(result).UseMainFunctions:=False;
end;

initialization
  units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_NavigatorsUseMainFunction','GDBBoolean',@UseMainFunction);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorDevices',rsDevices,TNavigatorDevices,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorDevices,@NavigatorDevices,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorRisers',rsRisers,TNavigatorRisers,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorRisers,@NavigatorRisers,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorCables',rsCables,TNavigatorCables,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorCables,@NavigatorCables,true);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

