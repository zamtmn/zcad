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

unit uzcregnavigatordevices;
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}
interface
uses uzcfnavigatordevices,uzcfcommandline,uzbpaths,uzctranslations,Forms,
     uzsbVarmanDef,uzeentdevice,uzcnavigatorsnodedesk,
     uzeentity,uzObjectInspector,uzcguimanager,uzcenitiesvariablesextender,
     Types,Controls,Varman,UUnitManager,uzcsysvars,uzcLog,laz.VirtualTrees,
     uzcfnavigatordevicescxmenu,{uzcmainwindow,}MacroDefIntf,sysutils,uzcActionsManager;
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
      if pnd^.Ident.pent<>nil  then
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
        if pnd^.Ident.pent<>nil  then
          exit('$'+inttohex(ptruint(pnd^.Ident.pent),8));
    end;
  end;
    Abort:=true;
end;

procedure ZCADFormSetupProc(Form:TControl);
begin
  InitializeNavigatorDevicesCXMenu({ZCADMainWindow}
                                   Application.MainForm//сюда попадает нил
                                                       //а вроде как нужна главная форма
                                                       //но если добавить зависимость
                                                       //то переменные будут грузиться раньше
                                                       //чем создадутся переменные навигаторов
                                                       //и переменные навигаторов
                                                       //DSGN_NavigatorsUseMainFunction
                                                       //DSGN_NavigatorsFollowToSelection
                                                       //задвоятся
                                  ,StandartActions);

  NavigatorDevicesMenuManager.RegisterContextCheckFunc('HaveSubNodes',NDMCCFHaveSubNodes);
  NavigatorDevicesMenuManager.RegisterContextCheckFunc('HaveEntity',NDMCCFNodeHaveEntity);

  NavigatorDevicesMacros.AddMacro(TTransferMacro.Create('EntInNodeAddr','',
                                  'Addres of entity  in node',NavigatorDevicesMacroMethods.MacroFuncEntInNodeAddr,[]));

end;
function CreateNavigatorDevices(FormName:string):TForm;
begin
 result:=tform(TNavigatorDevices.NewInstance);
 TNavigatorDevices(result).FileExt:='navdevicesxml';
 TNavigatorDevices(result).BP.TreeBuildMap:=GetAnsiStringFromSavedUnit(FormName,TreeBuildMapSaveVarSuffix,'+NMO_Prefix|+NMO_BaseName|+@@[NMO_Name]');
 TNavigatorDevices(result).BP.IncludeEntities:=GetAnsiStringFromSavedUnit(FormName,IncludeEntitiesSaveVarSuffix,'IncludeEntityName(''Device'')');
 TNavigatorDevices(result).BP.IncludeProperties:=GetAnsiStringFromSavedUnit(FormName,IncludePropertiesSaveVarSuffix,'');
 TNavigatorDevices(result).BP.TreeProperties:=GetAnsiStringFromSavedUnit(FormName,TreePropertiesSaveVarSuffix,'SetColumnsCount(2,0);'#10'SetColumnParams(0,''Tree'',''@@[NMO_Name]'',''tmpGUIParamSave_NavDev_C0'',1);'#10'SetColumnParams(1,''Comment'',''Тут чтото тоже надо сделать'',''tmpGUIParamSave_NavDev_C1'',1)');
 TNavigatorDevices(result).BP.CreateRootNode:=GetBooleanFromSavedUnit(FormName,TreeCreateRootNode,False);
 TNavigatorDevices(result).BP.UseMainFunctions:=True;
end;
function CreateNavigatorRisers(FormName:string):TForm;
begin
 result:=tform(TNavigatorRisers.NewInstance);
 TNavigatorRisers(result).FileExt:='navrisersxml';
 TNavigatorRisers(result).BP.TreeBuildMap:=GetAnsiStringFromSavedUnit(FormName,TreeBuildMapSaveVarSuffix,'+@@[RiserName]');
 TNavigatorRisers(result).BP.IncludeEntities:=GetAnsiStringFromSavedUnit(FormName,IncludeEntitiesSaveVarSuffix,'IncludeEntityName(''Device'')');
 TNavigatorRisers(result).BP.IncludeProperties:=GetAnsiStringFromSavedUnit(FormName,IncludePropertiesSaveVarSuffix,'IncludeIfMask(%%(''Name''),''EL_CABLE_*'')');
 TNavigatorRisers(result).BP.TreeProperties:=GetAnsiStringFromSavedUnit(FormName,TreePropertiesSaveVarSuffix,'SetColumnsCount(3,0);'#10'SetColumnParams(0,''Tree'',''@@[NMO_Name]'',''tmpGUIParamSave_NavRis_C0'',1);'#10'SetColumnParams(1,''Elevation'',''@@[Elevation]'',''tmpGUIParamSave_NavRis_C1'',1);'#10'SetColumnParams(2,''Text'',''@@[Text]'',''tmpGUIParamSave_NavRis_C2'',1)');
 TNavigatorRisers(result).BP.CreateRootNode:=GetBooleanFromSavedUnit(FormName,TreeCreateRootNode,False);
 TNavigatorRisers(result).BP.UseMainFunctions:=False;
end;
function CreateNavigatorCables(FormName:string):TForm;
begin
 result:=tform(TNavigatorCables.NewInstance);
 TNavigatorCables(result).FileExt:='navcablesxml';
 TNavigatorCables(result).BP.TreeBuildMap:=GetAnsiStringFromSavedUnit(FormName,TreeBuildMapSaveVarSuffix,'+NMO_Prefix|+NMO_BaseName|+@@[NMO_Name]');
 TNavigatorCables(result).BP.IncludeEntities:=GetAnsiStringFromSavedUnit(FormName,IncludeEntitiesSaveVarSuffix,'IncludeEntityName(''Cable'');'#10'IncludeEntityName(''Device'')');
 TNavigatorCables(result).BP.IncludeProperties:=GetAnsiStringFromSavedUnit(FormName,IncludePropertiesSaveVarSuffix,'IncludeIfSame(Or(SameMask(%%(''Name''),''CABLE_*''),SameMask(%%(''EntityName''),''Cable'')))');
 TNavigatorCables(result).BP.TreeProperties:=GetAnsiStringFromSavedUnit(FormName,TreePropertiesSaveVarSuffix,'SetColumnsCount(2,0);'#10'SetColumnParams(0,''Tree'',''@@[NMO_Name]'',''tmpGUIParamSave_NavCab_C0'',1);'#10'SetColumnParams(1,''Segment'',''@@[CABLE_Segment]'',''tmpGUIParamSave_NavCab_C1'',1)');
 TNavigatorCables(result).BP.CreateRootNode:=GetBooleanFromSavedUnit(FormName,TreeCreateRootNode,False);
 TNavigatorCables(result).BP.UseMainFunctions:=False;
end;

initialization
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'DSGN_NavigatorsUseMainFunction','Boolean',@UseMainFunction);
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'DSGN_NavigatorsFollowToSelection','Boolean',@FollowToSelection);
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'DSGN_NavigatorsInterfaceOnly','Boolean',@InterfaceOnly);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorDevices',rsDevices,TNavigatorDevices,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorDevices,@NavigatorDevices,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorRisers',rsRisers,TNavigatorRisers,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorRisers,@NavigatorRisers,true);
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorCables',rsCables,TNavigatorCables,rect(0,100,200,600),ZCADFormSetupProc,CreateNavigatorCables,@NavigatorCables,true);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

