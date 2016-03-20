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

unit uzedrawing;
{$INCLUDE def.inc}
interface
uses
    uzctranslations,zcadinterface,uzgldrawcontext,zeundostack,zcchangeundocommand,
    zcobjectchangeundocommand,zebaseundocommands,paths,uzestylesdim,
    WindowsSpecific,LResources,uzcsysvars,uzcstrconsts,strproc,GDBBlockDef,UUnitManager,
    gdbase,varmandef,varman,sysutils, memman, geometry, gdbobjectsconstdef,
    gdbasetypes,uzedrawingsimple,uzestyleslayers,uzeentity,uzefontmanager,
    UGDBOpenArrayOfPObjects,ugdbtrash,UGDBOpenArrayOfByte;
type
{EXPORT+}
{TDWGProps=packed record
                Name:GDBString;
                Number:GDBInteger;
          end;}
PTDrawing=^TDrawing;
TDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TSimpleDrawing)

           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;
           UndoStack:GDBObjOpenArrayOfUCommands;
           DWGUnits:TUnitManager;

           constructor init(num:PTUnitManager;preloadedfile1,preloadedfile2:GDBString);
           destructor done;virtual;
           procedure onUndoRedo;
           procedure onUndoRedoDataOwner(PDataOwner:Pointer);

           procedure SetCurrentDWG;virtual;
           function StoreOldCamerapPos:Pointer;virtual;
           procedure StoreNewCamerapPos(command:Pointer);virtual;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
           procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;
           procedure PushStartMarker(CommandName:GDBString);virtual;
           procedure PushEndMarker;virtual;
           procedure SetFileName(NewName:GDBString);virtual;
           function GetFileName:GDBString;virtual;
           procedure ChangeStampt(st:GDBBoolean);virtual;
           function GetChangeStampt:GDBBoolean;virtual;
           function GetUndoTop:TArrayIndex;virtual;
           function GetUndoStack:GDBPointer;virtual;
           function CanUndo:boolean;virtual;
           function CanRedo:boolean;virtual;
           function GetDWGUnits:{PTUnitManager}pointer;virtual;
           procedure AddBlockFromDBIfNeed(name:GDBString);virtual;
           function GetUnitsFormat:TzeUnitsFormat;virtual;
           procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;
           procedure FillDrawingPartRC(var dc:TDrawContext);virtual;
     end;
{EXPORT-}
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses uzcdrawings,uzeenttext,uzeentdevice,uzeentblockinsert,uzeffdxf,uzcutils,uzcshared,uzccommandsmanager;
procedure TDrawing.FillDrawingPartRC(var dc:TDrawContext);
var
  vd:pvardesk;
begin
  inherited FillDrawingPartRC(dc);
  vd:=nil;
  if DWGUnit<>nil then
    vd:=DWGUnit.InterfaceVariables.findvardesc('DWG_LTScale');
  if vd<>nil then
                 dc.DrawingContext.GlobalLTScale:=dc.DrawingContext.GlobalLTScale*PGDBDouble(vd^.data.Instance)^;
  if commandmanager.pcommandrunning<>nil then
                                               dc.DrawingContext.DrawHeplGeometryProc:=commandmanager.pcommandrunning^.DrawHeplGeometry;
end;

function TDrawing.GetUnitsFormat:TzeUnitsFormat;
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
procedure TDrawing.SetUnitsFormat(f:TzeUnitsFormat);
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

procedure TDrawing.SetCurrentDWG();
begin
  gdb.SetCurrentDWG(@self);
end;
function TDrawing.StoreOldCamerapPos:Pointer;
begin
     result:=PushCreateTGChangeCommand(UndoStack,GetPcamera^.prop)
end;
procedure TDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);
var
    tum:TUndableMethod;
begin
  tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
  tmethod(tum).Data:=obj;
  //tum:=tundablemethod(obj^.rtmodifyonepoint);
  with PushCreateTGObjectChangeCommand(UndoStack,rtmod,tmethod(tum))^ do
  begin
       comit;
       rtmod.wc:=rtmod.point.worldcoord;
       rtmod.dist:=nulvertex;
       StoreUndoData(rtmod);
  end;
end;
procedure TDrawing.StoreNewCamerapPos(command:Pointer);
begin
     if command<>nil then
                         PTGDBCameraBasePropChangeCommand(command).ComitFromObj;
end;
procedure TDrawing.PushStartMarker(CommandName:GDBString);
begin
     self.UndoStack.PushStartMarker(CommandName);
end;
procedure TDrawing.PushEndMarker;
begin
      self.UndoStack.PushEndMarker;
end;
procedure TDrawing.SetFileName(NewName:GDBString);
begin
     self.FileName:=NewName;
end;
function TDrawing.GetFileName:GDBString;
begin
     result:=FileName;
end;
procedure TDrawing.ChangeStampt;
begin
     self.Changed:={true}st;
     inherited;
end;
function TDrawing.GetChangeStampt:GDBBoolean;
begin
     result:=self.Changed;
end;
function TDrawing.GetUndoTop:TArrayIndex;
begin
     result:=UndoStack.CurrentCommand;
end;
function TDrawing.GetUndoStack:GDBPointer;
begin
     result:=@UndoStack;
end;
function TDrawing.CanUndo:boolean;
begin
     if UndoStack.CurrentCommand>0 then
                                       result:=true
                                   else
                                       result:=false;
end;
function TDrawing.CanRedo:boolean;
begin
     if UndoStack.CurrentCommand<UndoStack.Count then
                                                     result:=true
                                                 else
                                                     result:=false;
end;
function TDrawing.GetDWGUnits:{PTUnitManager}pointer;
begin
     result:=@DWGUnits;
end;
procedure TDrawing.AddBlockFromDBIfNeed(name:GDBString);
begin
     gdb.AddBlockFromDBIfNeed(@self,name);
end;
constructor TDrawing.init;
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
  pdwgwarsunit.InterfaceUses.addnodouble(@SysUnit);
  pdwgwarsunit^.CreateVariable('DWG_DrawMode','GDBBoolean',@LWDisplay);
  pdwgwarsunit^.CreateVariable('DWG_SnapGrid','GDBBoolean',@SnapGrid);
  pdwgwarsunit^.CreateVariable('DWG_DrawGrid','GDBBoolean',@DrawGrid);
  pdwgwarsunit^.CreateVariable('DWG_GridSpacing','GDBvertex2D',@GridSpacing);
  pdwgwarsunit^.CreateVariable('DWG_Snap','GDBSnap2D',@Snap);
  pdwgwarsunit^.CreateVariable('DWG_CLayer','PGDBLayerProp',@CurrentLayer);
  pdwgwarsunit^.CreateVariable('DWG_CLType','PGDBLtypeProp',@CurrentLType);
  pdwgwarsunit^.CreateVariable('DWG_CTStyle','PGDBTextStyle',@CurrentTextStyle);
  pdwgwarsunit^.CreateVariable('DWG_CDimStyle','PGDBDimStyle',@CurrentDimStyle);
  pdwgwarsunit^.CreateVariable('DWG_CLinew','TGDBLineWeight',@CurrentLineW);
  pdwgwarsunit^.CreateVariable('DWG_CLTScale','GDBDouble',@CLTScale);
  pdwgwarsunit^.CreateVariable('DWG_CColor','GDBInteger',@CColor);


  pdwgwarsunit^.CreateVariable('DWG_LUnits','TLUnits',@LUnits);
  pdwgwarsunit^.CreateVariable('DWG_LUPrec','TUPrec',@LUPrec);
  pdwgwarsunit^.CreateVariable('DWG_AUnits','TAUnits',@AUnits);
  pdwgwarsunit^.CreateVariable('DWG_AUPrec','TUPrec',@AUPrec);
  pdwgwarsunit^.CreateVariable('DWG_AngDir','TAngDir',@AngDir);
  pdwgwarsunit^.CreateVariable('DWG_AngBase','GDBAngleDegDouble',@AngBase);
  pdwgwarsunit^.CreateVariable('DWG_UnitMode','TUnitMode',@UnitMode);
  pdwgwarsunit^.CreateVariable('DWG_InsUnits','TInsUnits',@InsUnits);
  pdwgwarsunit^.CreateVariable('DWG_TextSize','GDBDouble',@TextSize);

  if preloadedfile1<>'' then
  DWGUnits.loadunit(SupportPath,InterfaceTranslate,expandpath({'*rtl/dwg/DrawingDeviceBase.pas')}preloadedfile1),nil);
  if preloadedfile2<>'' then
  DWGUnits.loadunit(SupportPath,InterfaceTranslate,expandpath({'*rtl/dwg/DrawingVars.pas'}preloadedfile2),nil);
  DWGDBUnit:=DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);

  pcam:=nil;
  pvd:=nil;
  pdwgwarsunit:=DWGUnits.findunit(SupportPath,InterfaceTranslate,'DrawingVars');
  if assigned(pdwgwarsunit) then
                                pvd:=pdwgwarsunit.InterfaceVariables.findvardesc('camera');
  if pvd<>nil then
                  pcam:=pvd^.data.Instance;
  inherited init(pcam);


  Pointer(FileName):=nil;
  FileName:=rsHardUnnamed;
  Changed:=False;
  UndoStack.init;
  UndoStack.onUndoRedo:=self.onUndoRedo;
  zebaseundocommands.onUndoRedoDataOwner:=self.onUndoRedoDataOwner;


  //OGLwindow1.initxywh('oglwnd',nil,200,72,768,596,false);
  //OGLwindow1.show;
end;
procedure TDrawing.onUndoRedoDataOwner(PDataOwner:Pointer);
var
   DC:TDrawContext;
begin
  if assigned(PDataOwner)then
                          begin
                               //PDataOwner^.YouChanged(gdb.GetCurrentDWG^);
                               if PGDBObjEntity(PDataOwner)^.bp.ListPos.Owner=gdb.GetCurrentDWG^.GetCurrentRootSimple
                               then
                                   PGDBObjEntity(PDataOwner)^.YouChanged(gdb.GetCurrentDWG^)
                               else
                                   begin
                                        dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                        PGDBObjEntity(PDataOwner)^.FormatEntity(gdb.GetCurrentDWG^,dc);
                                        gdb.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
                                   end;
                          end;
  if assigned(SetVisuaProplProc)then
                                    SetVisuaProplProc;
end;
procedure TDrawing.onUndoRedo;
var
   DC:TDrawContext;
begin
  DC:=CreateDrawingRC;
  GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

destructor TDrawing.done;
begin
     inherited;
     undostack.done;
     DWGUnits.FreeAndDone;
     FileName:='';
end;
//procedure TDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
begin
end.
