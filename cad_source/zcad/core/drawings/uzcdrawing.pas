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

unit uzcdrawing;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,
  uzcTranslations,uzcinterface,uzgldrawcontext,zeundostack,gzUndoCmdChgData,
  gzUndoCmdChgMethod,zUndoCmdChgCameraBaseProp,zebaseundocommands,uzbpaths,
  uzestylesdim,uzcdialogsfiles,LResources,uzcsysvars,uzcstrconsts,
  uzeblockdef,UUnitManager,uzsbVarmanDef,varman,uzegeometry,
  uzeconsts,uzedrawingsimple,uzestyleslayers,uzeentity,uzefontmanager,uzbUnits,
  uzegeometrytypes,uzctnrVectorBytesStream,gzctnrVectorTypes,uzglviewareadata;

type

  PTZCADDrawing=^TZCADDrawing;

  TZCADDrawing=object(TSimpleDrawing)
  private
    FChanged:boolean;
    FChangedFromAutoSave:boolean;
    FFileName:string;
  public
    UndoStack:TZctnrVectorUndoCommands;
    DWGUnits:TUnitManager;

    constructor init(num:PTUnitManager;preloadedfile1,preloadedfile2:string);
    destructor done;virtual;
    procedure onUndoRedo;
    procedure onUndoRedoDataOwner(PDataOwner:Pointer);

    procedure SetCurrentDWG;virtual;
    function StoreOldCamerapPos:Pointer;virtual;
    procedure StoreNewCamerapPos(command:Pointer);virtual;
    procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:TzePoint3d);virtual;
    procedure PushStartMarker(CommandName:string);virtual;
    procedure PushEndMarker;virtual;
    procedure SetFileName(NewName:string);virtual;
    function GetFileName:string;virtual;
    procedure SetAllChangeStampt;virtual;
    procedure ResetChangeStampt;virtual;
    procedure ResetChangeFromAutoSaveStampt;virtual;
    function GetChangeStampt:boolean;virtual;
    function GetAutoSavedStampt:boolean;virtual;
    function GetUndoTop:TArrayIndex;virtual;
    function GetUndoStack:Pointer;virtual;
    function CanUndo:boolean;virtual;
    function CanRedo:boolean;virtual;
    function GetDWGUnits:pointer;virtual;
    procedure AddBlockFromDBIfNeed(Name:string);virtual;
    function GetUnitsFormat:TzeUnitsFormat;virtual;
    procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;
    procedure FillDrawingPartRC(var dc:TDrawContext);virtual;

    property FileName:string read FFileName write FFileName;
  end;

implementation

uses uzcdrawings,uzccommandsmanager;

procedure TZCADDrawing.FillDrawingPartRC(var dc:TDrawContext);
begin
  inherited FillDrawingPartRC(dc);
  dc.DrawingContext.GlobalLTScale:=LTScale;
  if commandmanager.CurrCmd.pcommandrunning<>nil then
    dc.DrawingContext.DrawHeplGeometryProc:=commandmanager.CurrCmd.pcommandrunning^.DrawHeplGeometry;
end;

function TZCADDrawing.GetUnitsFormat:TzeUnitsFormat;
begin
  Result.DeciminalSeparator:=DDSDot;
  if Assigned(sysvar.DWG.DWG_AngBase) then
    Result.abase:=sysvar.DWG.DWG_AngBase^
  else
    Result.abase:=0;
  if Assigned(sysvar.DWG.DWG_AngDir) then
    Result.adir:=sysvar.DWG.DWG_AngDir^
  else
    Result.adir:=ADCounterClockwise;
  if Assigned(sysvar.DWG.DWG_AUnits) then
    Result.aformat:=sysvar.DWG.DWG_AUnits^
  else
    Result.aformat:=AUDecimalDegrees;
  if Assigned(sysvar.DWG.DWG_AUPrec) then
    Result.aprec:=sysvar.DWG.DWG_AUPrec^
  else
    Result.aprec:=UPrec2;
  if Assigned(sysvar.DWG.DWG_LUnits) then
    Result.uformat:=sysvar.DWG.DWG_LUnits^
  else
    Result.uformat:=LUDecimal;
  if Assigned(sysvar.DWG.DWG_LUPrec) then
    Result.uprec:=sysvar.DWG.DWG_LUPrec^
  else
    Result.uprec:=UPrec2;
  if Assigned(sysvar.DWG.DWG_UnitMode) then
    Result.umode:=sysvar.DWG.DWG_UnitMode^
  else
    Result.umode:=UMWithSpaces;
  if Result.uformat in [LUDecimal,LUEngineering] then
    Result.RemoveTrailingZeros:=False
  else
    Result.RemoveTrailingZeros:=True;
end;

procedure TZCADDrawing.SetUnitsFormat(f:TzeUnitsFormat);
begin
  if Assigned(sysvar.DWG.DWG_AngBase) then
    sysvar.DWG.DWG_AngBase^:=f.abase;
  if Assigned(sysvar.DWG.DWG_AngDir) then
    sysvar.DWG.DWG_AngDir^:=f.adir;
  if Assigned(sysvar.DWG.DWG_AUnits) then
    sysvar.DWG.DWG_AUnits^:=f.aformat;
  if Assigned(sysvar.DWG.DWG_AUPrec) then
    sysvar.DWG.DWG_AUPrec^:=f.aprec;
  if Assigned(sysvar.DWG.DWG_LUnits) then
    sysvar.DWG.DWG_LUnits^:=f.uformat;
  if Assigned(sysvar.DWG.DWG_LUPrec) then
    sysvar.DWG.DWG_LUPrec^:=f.uprec;
  if Assigned(sysvar.DWG.DWG_UnitMode) then
    sysvar.DWG.DWG_UnitMode^:=f.umode;
end;

procedure TZCADDrawing.SetCurrentDWG();
begin
  drawings.SetCurrentDWG(@self);
end;

function TZCADDrawing.StoreOldCamerapPos:Pointer;
begin
  Result:=TGDBCameraBasePropChangeCommand.CreateAndPushIfNeed(UndoStack,GetPCamera^.prop,nil,nil);
end;

procedure TZCADDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:TzePoint3d);
var
  tum:TUndableMethod;
begin
  tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
  tmethod(tum).Data:=obj;
  with GUCmdChgMethod<TRTModifyData>.CreateAndPush(rtmod,tmethod(tum),UndoStack,drawings.AfterAutoProcessGDB) do begin
    comit;
    rtmod.wc:=rtmod.point.worldcoord;
    rtmod.dist:=cP3d__0__0__0;
    StoreUndoData(rtmod);
  end;
end;

procedure TZCADDrawing.StoreNewCamerapPos(command:Pointer);
begin
  if command<>nil then
    TGDBCameraBasePropChangeCommand(command).ComitFromObj;
end;

procedure TZCADDrawing.PushStartMarker(CommandName:string);
begin
  self.UndoStack.PushStartMarker(CommandName);
end;

procedure TZCADDrawing.PushEndMarker;
begin
  self.UndoStack.PushEndMarker;
end;

procedure TZCADDrawing.SetFileName(NewName:string);
begin
  FFileName:=NewName;
end;

function TZCADDrawing.GetFileName:string;
begin
  Result:=FFileName;
end;

procedure TZCADDrawing.SetAllChangeStampt;
begin
  inherited;
  FChanged:=True;
  FChangedFromAutoSave:=True;
end;

procedure TZCADDrawing.ResetChangeStampt;
begin
  inherited;
  FChanged:=False;
end;

procedure TZCADDrawing.ResetChangeFromAutoSaveStampt;
begin
  inherited;
  FChangedFromAutoSave:=False;
end;

function TZCADDrawing.GetChangeStampt:boolean;
begin
  Result:=FChanged;
end;

function TZCADDrawing.GetAutoSavedStampt:boolean;
begin
  Result:=FChangedFromAutoSave;
end;

function TZCADDrawing.GetUndoTop:TArrayIndex;
begin
  Result:=UndoStack.CurrentCommand;
end;

function TZCADDrawing.GetUndoStack:Pointer;
begin
  Result:=@UndoStack;
end;

function TZCADDrawing.CanUndo:boolean;
begin
  if UndoStack.CurrentCommand>0 then
    Result:=True
  else
    Result:=False;
end;

function TZCADDrawing.CanRedo:boolean;
begin
  if UndoStack.CurrentCommand<UndoStack.Count then
    Result:=True
  else
    Result:=False;
end;

function TZCADDrawing.GetDWGUnits:pointer;
begin
  Result:=@DWGUnits;
end;

procedure TZCADDrawing.AddBlockFromDBIfNeed(Name:string);
begin
  drawings.AddBlockFromDBIfNeed(@self,Name);
end;

constructor TZCADDrawing.init;
var
  pvd:pvardesk;
  pcam:pointer;
  pdwgwarsunit:ptunit;
begin
  DWGUnits.init;
  DWGUnits.SetNextManager(num);
  pdwgwarsunit:=pointer(DWGUnits.CreateObject);
  pdwgwarsunit^.init('DrawingVars');
  pdwgwarsunit.InterfaceUses.PushBackIfNotPresent(SysUnit);
  pdwgwarsunit^.CreateFixedVariable('DWG_DrawMode','Boolean',@LWDisplay);
  pdwgwarsunit^.CreateFixedVariable('DWG_SnapGrid','Boolean',@SnapGrid);
  pdwgwarsunit^.CreateFixedVariable('DWG_DrawGrid','Boolean',@DrawGrid);
  pdwgwarsunit^.CreateFixedVariable('DWG_GridSpacing','TzePoint2d',@GridSpacing);
  pdwgwarsunit^.CreateFixedVariable('DWG_Snap','GDBSnap2D',@Snap);
  pdwgwarsunit^.CreateFixedVariable('DWG_CLayer','PGDBLayerProp',@CurrentLayer);
  pdwgwarsunit^.CreateFixedVariable('DWG_CLType','PGDBLtypeProp',@CurrentLType);
  pdwgwarsunit^.CreateFixedVariable('DWG_CTStyle','PGDBTextStyle',@CurrentTextStyle);
  pdwgwarsunit^.CreateFixedVariable('DWG_CDimStyle','PGDBDimStyle',@CurrentDimStyle);
  pdwgwarsunit^.CreateFixedVariable('DWG_CLinew','TGDBLineWeight',@CurrentLineW);
  pdwgwarsunit^.CreateFixedVariable('DWG_CLTScale','Double',@CLTScale);
  pdwgwarsunit^.CreateFixedVariable('DWG_CColor','Integer',@CColor);


  pdwgwarsunit^.CreateFixedVariable('DWG_LUnits','TLUnits',@LUnits);
  pdwgwarsunit^.CreateFixedVariable('DWG_LUPrec','TUPrec',@LUPrec);
  pdwgwarsunit^.CreateFixedVariable('DWG_AUnits','TAUnits',@AUnits);
  pdwgwarsunit^.CreateFixedVariable('DWG_AUPrec','TUPrec',@AUPrec);
  pdwgwarsunit^.CreateFixedVariable('DWG_AngDir','TAngDir',@AngDir);
  pdwgwarsunit^.CreateFixedVariable('DWG_AngBase','TZeAngleDeg',@AngBase);
  pdwgwarsunit^.CreateFixedVariable('DWG_UnitMode','TUnitMode',@UnitMode);
  pdwgwarsunit^.CreateFixedVariable('DWG_InsUnits','TInsUnits',@InsUnits);
  pdwgwarsunit^.CreateFixedVariable('DWG_TextSize','Double',@TextSize);

  if preloadedfile1<>'' then
    DWGUnits.loadunit(GetSupportPaths,InterfaceTranslate,expandpath(preloadedfile1),nil);
  if preloadedfile2<>'' then
    DWGUnits.loadunit(GetSupportPaths,InterfaceTranslate,expandpath(preloadedfile2),nil);
  DWGDBUnit:=DWGUnits.findunit(GetSupportPaths,InterfaceTranslate,DrawingDeviceBaseUnitName);

  pcam:=nil;
  pvd:=nil;
  pdwgwarsunit:=DWGUnits.findunit(GetSupportPaths,InterfaceTranslate,'DrawingVars');
  if assigned(pdwgwarsunit) then
    pvd:=pdwgwarsunit.InterfaceVariables.findvardesc('camera');
  if pvd<>nil then
    pcam:=pvd^.Data.Addr.Instance;
  inherited init(pcam);


  Pointer(FFileName):=nil;
  FFileName:=rsHardUnnamed;
  FChanged:=False;
  FChangedFromAutoSave:=False;
  UndoStack.init;
  UndoStack.onUndoRedo:=self.onUndoRedo;
  zebaseundocommands.onUndoRedoDataOwner:=self.onUndoRedoDataOwner;
end;

procedure TZCADDrawing.onUndoRedoDataOwner(PDataOwner:Pointer);
var
  DC:TDrawContext;
begin
  if assigned(PDataOwner) then begin
    if PGDBObjEntity(PDataOwner)^.bp.ListPos.Owner=drawings.GetCurrentDWG^.GetCurrentRootSimple then
      PGDBObjEntity(PDataOwner)^.YouChanged(drawings.GetCurrentDWG^)
    else begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      PGDBObjEntity(PDataOwner)^.FormatEntity(drawings.GetCurrentDWG^,dc);
      drawings.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
    end;
  end;
  zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
end;

procedure TZCADDrawing.onUndoRedo;
var
  DC:TDrawContext;
begin
  DC:=CreateDrawingRC;
  GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
end;

destructor TZCADDrawing.done;
begin
  inherited;
  undostack.Destroy;
  DWGUnits.Done;
  FFileName:='';
end;

begin
end.
