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
{$INCLUDE zengineconfig.inc}
interface
uses
    uzcTranslations,uzcinterface,uzgldrawcontext,zeundostack,gzundoCmdChgData,
    gzundoCmdChgMethod,zebaseundocommands,uzbpaths,uzestylesdim,
    uzcdialogsfiles,LResources,uzcsysvars,uzcstrconsts,uzbstrproc,uzeblockdef,UUnitManager,
    uzbtypes,varmandef,varman,sysutils,uzegeometry, uzeconsts,
    uzedrawingsimple,uzestyleslayers,uzeentity,uzefontmanager,
    uzedimensionaltypes,uzegeometrytypes,uzctnrVectorBytes,gzctnrVectorTypes,uzglviewareadata;
type
{EXPORT+}
PTZCADDrawing=^TZCADDrawing;
{REGISTEROBJECTTYPE TZCADDrawing}
TZCADDrawing= object(TSimpleDrawing)

           FileName:String;
           Changed:Boolean;
           attrib:LongWord;
           UndoStack:TZctnrVectorUndoCommands;
           DWGUnits:TUnitManager;

           constructor init(num:PTUnitManager;preloadedfile1,preloadedfile2:String);
           destructor done;virtual;
           procedure onUndoRedo;
           procedure onUndoRedoDataOwner(PDataOwner:Pointer);

           procedure SetCurrentDWG;virtual;
           function StoreOldCamerapPos:Pointer;virtual;
           procedure StoreNewCamerapPos(command:Pointer);virtual;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
           procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;
           procedure PushStartMarker(CommandName:String);virtual;
           procedure PushEndMarker;virtual;
           procedure SetFileName(NewName:String);virtual;
           function GetFileName:String;virtual;
           procedure ChangeStampt(st:Boolean);virtual;
           function GetChangeStampt:Boolean;virtual;
           function GetUndoTop:TArrayIndex;virtual;
           function GetUndoStack:Pointer;virtual;
           function CanUndo:boolean;virtual;
           function CanRedo:boolean;virtual;
           function GetDWGUnits:{PTUnitManager}pointer;virtual;
           procedure AddBlockFromDBIfNeed(name:String);virtual;
           function GetUnitsFormat:TzeUnitsFormat;virtual;
           procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;
           procedure FillDrawingPartRC(var dc:TDrawContext);virtual;
     end;
{EXPORT-}
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses uzcdrawings,uzccommandsmanager;
procedure TZCADDrawing.FillDrawingPartRC(var dc:TDrawContext);
var
  vd:pvardesk;
begin
  inherited FillDrawingPartRC(dc);
  vd:=nil;
  if DWGUnit<>nil then
    vd:=DWGUnit.InterfaceVariables.findvardesc('DWG_LTScale');
  if vd<>nil then
                 dc.DrawingContext.GlobalLTScale:=dc.DrawingContext.GlobalLTScale*PDouble(vd^.data.Addr.Instance)^;
  if commandmanager.CurrCmd.pcommandrunning<>nil then
                                               dc.DrawingContext.DrawHeplGeometryProc:=commandmanager.CurrCmd.pcommandrunning^.DrawHeplGeometry;
end;

function TZCADDrawing.GetUnitsFormat:TzeUnitsFormat;
begin
     result.DeciminalSeparator:=DDSDot;
     if Assigned(sysvar.DWG.DWG_AngBase) then
                                            result.abase:=sysvar.DWG.DWG_AngBase^
                                        else
                                            result.abase:=0;
     if Assigned(sysvar.DWG.DWG_AngDir) then
                                            result.adir:=sysvar.DWG.DWG_AngDir^
                                        else
                                            result.adir:=ADCounterClockwise;
     if Assigned(sysvar.DWG.DWG_AUnits) then
                                            result.aformat:=sysvar.DWG.DWG_AUnits^
                                        else
                                            result.aformat:=AUDecimalDegrees;
     if Assigned(sysvar.DWG.DWG_AUPrec) then
                                            result.aprec:=sysvar.DWG.DWG_AUPrec^
                                        else
                                            result.aprec:=UPrec2;
     if Assigned(sysvar.DWG.DWG_LUnits) then
                                            result.uformat:=sysvar.DWG.DWG_LUnits^
                                        else
                                            result.uformat:=LUDecimal;
     if Assigned(sysvar.DWG.DWG_LUPrec) then
                                            result.uprec:=sysvar.DWG.DWG_LUPrec^
                                        else
                                            result.uprec:=UPrec2;
     if Assigned(sysvar.DWG.DWG_UnitMode) then
                                            result.umode:=sysvar.DWG.DWG_UnitMode^
                                        else
                                            result.umode:=UMWithSpaces;
     if result.uformat in [LUDecimal,LUEngineering] then
                                                        result.RemoveTrailingZeros:=false
                                                    else
                                                        result.RemoveTrailingZeros:=true;
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
     result:=TGDBCameraBasePropChangeCommand.CreateAndPushIfNeed(UndoStack,GetPcamera^.prop,nil,nil)
end;
procedure TZCADDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);
var
    tum:TUndableMethod;
begin
  tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
  tmethod(tum).Data:=obj;
  //tum:=tundablemethod(obj^.rtmodifyonepoint);
  with GUCmdChgMethod<TRTModifyData>.CreateAndPush(rtmod,tmethod(tum),UndoStack,drawings.AfterAutoProcessGDB) do
  begin
       comit;
       rtmod.wc:=rtmod.point.worldcoord;
       rtmod.dist:=nulvertex;
       StoreUndoData(rtmod);
  end;
end;
procedure TZCADDrawing.StoreNewCamerapPos(command:Pointer);
begin
     if command<>nil then
                         TGDBCameraBasePropChangeCommand(command).ComitFromObj;
end;
procedure TZCADDrawing.PushStartMarker(CommandName:String);
begin
     self.UndoStack.PushStartMarker(CommandName);
end;
procedure TZCADDrawing.PushEndMarker;
begin
      self.UndoStack.PushEndMarker;
end;
procedure TZCADDrawing.SetFileName(NewName:String);
begin
     self.FileName:=NewName;
end;
function TZCADDrawing.GetFileName:String;
begin
     result:=FileName;
end;
procedure TZCADDrawing.ChangeStampt;
begin
     self.Changed:={true}st;
     inherited;
end;
function TZCADDrawing.GetChangeStampt:Boolean;
begin
     result:=self.Changed;
end;
function TZCADDrawing.GetUndoTop:TArrayIndex;
begin
     result:=UndoStack.CurrentCommand;
end;
function TZCADDrawing.GetUndoStack:Pointer;
begin
     result:=@UndoStack;
end;
function TZCADDrawing.CanUndo:boolean;
begin
     if UndoStack.CurrentCommand>0 then
                                       result:=true
                                   else
                                       result:=false;
end;
function TZCADDrawing.CanRedo:boolean;
begin
     if UndoStack.CurrentCommand<UndoStack.Count then
                                                     result:=true
                                                 else
                                                     result:=false;
end;
function TZCADDrawing.GetDWGUnits:{PTUnitManager}pointer;
begin
     result:=@DWGUnits;
end;
procedure TZCADDrawing.AddBlockFromDBIfNeed(name:String);
begin
     drawings.AddBlockFromDBIfNeed(@self,name);
end;
constructor TZCADDrawing.init;
var {tp:GDBTextStyleProp;}
    //ts:PTGDBTableStyle;
    //cs:TGDBTableCellStyle;
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
  pdwgwarsunit^.CreateFixedVariable('DWG_GridSpacing','GDBvertex2D',@GridSpacing);
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
  pdwgwarsunit^.CreateFixedVariable('DWG_AngBase','GDBAngleDegDouble',@AngBase);
  pdwgwarsunit^.CreateFixedVariable('DWG_UnitMode','TUnitMode',@UnitMode);
  pdwgwarsunit^.CreateFixedVariable('DWG_InsUnits','TInsUnits',@InsUnits);
  pdwgwarsunit^.CreateFixedVariable('DWG_TextSize','Double',@TextSize);

  if preloadedfile1<>'' then
  DWGUnits.loadunit(GetSupportPath,InterfaceTranslate,expandpath({'*rtl/dwg/DrawingDeviceBase.pas')}preloadedfile1),nil);
  if preloadedfile2<>'' then
  DWGUnits.loadunit(GetSupportPath,InterfaceTranslate,expandpath({'*rtl/dwg/DrawingVars.pas'}preloadedfile2),nil);
  DWGDBUnit:=DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);

  pcam:=nil;
  pvd:=nil;
  pdwgwarsunit:=DWGUnits.findunit(GetSupportPath,InterfaceTranslate,'DrawingVars');
  if assigned(pdwgwarsunit) then
                                pvd:=pdwgwarsunit.InterfaceVariables.findvardesc('camera');
  if pvd<>nil then
                  pcam:=pvd^.data.Addr.Instance;
  inherited init(pcam);


  Pointer(FileName):=nil;
  FileName:=rsHardUnnamed;
  Changed:=False;
  UndoStack:=TZctnrVectorUndoCommands.Create;
  UndoStack.onUndoRedo:=self.onUndoRedo;
  zebaseundocommands.onUndoRedoDataOwner:=self.onUndoRedoDataOwner;


  //OGLwindow1.initxywh('oglwnd',nil,200,72,768,596,false);
  //OGLwindow1.show;
end;
procedure TZCADDrawing.onUndoRedoDataOwner(PDataOwner:Pointer);
var
   DC:TDrawContext;
begin
  if assigned(PDataOwner)then
                          begin
                               //PDataOwner^.YouChanged(drawings.GetCurrentDWG^);
                               if PGDBObjEntity(PDataOwner)^.bp.ListPos.Owner=drawings.GetCurrentDWG^.GetCurrentRootSimple
                               then
                                   PGDBObjEntity(PDataOwner)^.YouChanged(drawings.GetCurrentDWG^)
                               else
                                   begin
                                        dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                                        PGDBObjEntity(PDataOwner)^.FormatEntity(drawings.GetCurrentDWG^,dc);
                                        drawings.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                   end;
                          end;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRebuild);
  //if assigned(SetVisuaProplProc)then
  //                                  SetVisuaProplProc;
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
     FileName:='';
end;
//procedure TZCADDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
begin
end.
