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

unit uzcdrawings;
{$INCLUDE zengineconfig.inc}
interface
uses
    uzglviewareageneral,uzcTranslations,uzedimblocksregister,uzeblockdefsfactory,
    uzemathutils,uzgldrawcontext,uzcdrawing,uzedrawingdef,uzbpaths,uzestylesdim,
    uzedrawingabstract,uzcdialogsfiles,LResources,uzcsysvars,uzcinterface,
    uzcstrconsts,uzbstrproc,uzeblockdef,UGDBObjBlockdefArray,UUnitManager,
    uzbtypes,varmandef,varman,sysutils,uzegeometry,uzeconsts,
    uzedrawingsimple,uzeentgenericsubentry,uzestyleslayers,uzeentity,
    UGDBSelectedObjArray,uzestylestexts,uzefontmanager,uzestyleslinetypes,
    UGDBOpenArrayOfPV,uzefont,UGDBVisibleOpenArray,
    gzctnrVectorTypes,uzedimensionaltypes,uzetrash,uzctnrVectorBytes,uzglviewareadata,
    uzccommandsabstract,
    uzeentitiestypefilter,uzctnrvectorpgdbaseobjects,
    LCLProc;
type
{EXPORT+}
PTZCADDrawingsManager=^TZCADDrawingsManager;
{REGISTEROBJECTTYPE TZCADDrawingsManager}
TZCADDrawingsManager= object(TZctnrVectorPGDBaseObjects)
                    CurrentDWG:{PTZCADDrawing}PTSimpleDrawing;
                    ProjectUnits:TUnitManager;
                    FileNameCounter:integer;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;
                    //function AfterDeSerialize(SaveFlag:Word; membuf:Pointer):integer;virtual;

                    function GetCurrentROOT:PGDBObjGenericSubEntry;

                    function GetCurrentDWG:{PTZCADDrawing}PTSimpleDrawing;
                    function GetCurrentOGLWParam:POGLWndtype;
                    function GetUndoStack:Pointer;
                    procedure asociatedwgvars;
                    procedure freedwgvars;
                    procedure SetCurrentDWG(PDWG:PTAbstractDrawing);

                    function CreateDWG(preloadedfile1,preloadedfile2:String):PTZCADDrawing;
                    //function CreateSimpleDWG:PTSimpleDrawing;virtual;
                    //procedure eraseobj(ObjAddr:PGDBaseObject);virtual;
                    procedure RemoveData(const data:PGDBaseObject);virtual;

                    procedure CopyBlock(_from,_to:PTSimpleDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:PTDrawingDef;name:String);
                    procedure AddLTStyleFromDBIfNeed(_to:PTSimpleDrawing;name:String);
                    //procedure rtmodify(obj:PGDBObjEntity;md:Pointer;dist,wc:gdbvertex;save:Boolean);virtual;
                    function FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:Word; InOwner:Boolean):PGDBObjEntity;
                    function FindEntityByVar(objID:Word;vname,vvalue:String):PGDBObjEntity;
                    procedure FindMultiEntityByType(Filter:TEntsTypeFilter;var entarray:TZctnrVectorPGDBaseObjects);
                    procedure FindMultiEntityByVar(objID:Word;vname,vvalue:String;var entarray:TZctnrVectorPGDBaseObjects);
                    procedure FindMultiEntityByVar2(objID:Word;vname:String;var entarray:TZctnrVectorPGDBaseObjects);
                    procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
                    //procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
                    function GetDefaultDrawingName:String;
                    function FindDrawingByName(DWGName:String):PTSimpleDrawing;
                    function GetUnitsFormat:TzeUnitsFormat;
                    procedure SetUnitsFormat(f:TzeUnitsFormat);
                    procedure redrawoglwnd(Sender:TObject;GUIAction:TZMessageID);
                    procedure resetoglwnd(Sender:TObject;GUIAction:TZMessageID);

                    {todo: переименовать по человечьи}
                    procedure AfterAutoProcessGDB(const AUndoMethod:TMethod);
                    procedure AfterNotAutoProcessGDB(const AUndoMethod:TMethod);
                    procedure AfterEnt(const pent:PGDBObjEntity);
              end;
{EXPORT-}
var drawings: TZCADDrawingsManager;
    BlockBaseDWG:{PTZCADDrawing}PTSimpleDrawing=nil;
    ClipboardDWG:{PTZCADDrawing}PTSimpleDrawing=nil;
    //GDBTrash:GDBObjTrash;
    LtypeManager:GDBLtypeArray;
procedure CalcZ(z:Double);
procedure RemapAll(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
procedure startup(preloadedfile1,preloadedfile2:String);
procedure finalize;
procedure SetObjCreateManipulator(out domethod,undomethod:tmethod);
procedure clearotrack;
procedure clearcp;
//procedure redrawoglwnd(GUIAction:TZMessageID);
function SetCurrentDWG(PDWG:pointer):pointer;
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses uzcenitiesvariablesextender,uzeenttext,uzeentdevice,uzeentblockinsert;
procedure TZCADDrawingsManager.AfterEnt(const pent:PGDBObjEntity);
begin
  if assigned(pent)then
    pent^.YouChanged(GetCurrentDWG^);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRebuild);
end;

procedure TZCADDrawingsManager.AfterAutoProcessGDB(const AUndoMethod:TMethod);
begin
  PGDBObjEntity(AUndoMethod.Data)^.YouChanged(GetCurrentDWG^)
end;
procedure TZCADDrawingsManager.AfterNotAutoProcessGDB(const AUndoMethod:TMethod);
var
  DC:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  PGDBObjEntity(AUndoMethod.Data)^.formatEntity(GetCurrentDWG^,dc);
end;

procedure TZCADDrawingsManager.redrawoglwnd(Sender:TObject;GUIAction:TZMessageID);
var
   pdwg:PTSimpleDrawing;
   DC:TDrawContext;
begin
  if GUIAction=ZMsgID_GUIActionRedrawContent then
  begin
    pdwg:=drawings.GetCurrentDWG;
    if pdwg<>nil then begin
      DC:=pdwg^.CreateDrawingRC;
      drawings.GetCurrentRoot.FormatAfterEdit(pdwg^,dc);
      pdwg.wa.param.firstdraw := TRUE;
      pdwg.wa.CalcOptimalMatrix;
      pdwg.pcamera^.totalobj:=0;
      pdwg.pcamera^.infrustum:=0;
      drawings.GetCurrentROOT.CalcVisibleByTree(drawings.GetCurrentDWG.pcamera^.frustum,drawings.GetCurrentDWG.pcamera.POSCOUNT,drawings.GetCurrentDWG.pcamera.VISCOUNT,drawings.GetCurrentROOT.ObjArray.ObjTree,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg^.myGluProject2,pdwg.pcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
      pdwg.ConstructObjRoot.calcvisible(drawings.GetCurrentDWG.pcamera^.frustum,drawings.GetCurrentDWG.pcamera.POSCOUNT,drawings.GetCurrentDWG.pcamera.VISCOUNT,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
      pdwg.wa.calcgrid;
      pdwg.wa.draworinvalidate;
    end;
  end;
end;
function TZCADDrawingsManager.GetDefaultDrawingName:String;
var
    OldName:String;
    LoopCounter:Integer;
begin
  OldName:='';
  LoopCounter:=0;
  repeat
    inc(FileNameCounter);
    inc(LoopCounter);
  try
       result:=sysutils.format(rsUnnamedWindowTitle,[FileNameCounter]);;
  except
       result:=rsHardUnnamed;
  end;
  if OldName=result then
                        exit;
  if LoopCounter=100 then
                        begin
                             result:=rsHardUnnamed;
                             exit;
                        end;
  OldName:=result;
  until FindDrawingByName(result)=nil;
end;
function TZCADDrawingsManager.GetUnitsFormat:TzeUnitsFormat;
begin
     result.DeciminalSeparator:=DDSDot;
     if CurrentDWG<>nil then
                            result:=CurrentDWG.GetUnitsFormat
                        else
                            result:=CreateDefaultUnitsFormat;
end;
procedure TZCADDrawingsManager.SetUnitsFormat(f:TzeUnitsFormat);
begin
     if CurrentDWG<>nil then
                            CurrentDWG.SetUnitsFormat(f);
end;
function TZCADDrawingsManager.FindDrawingByName(DWGName:String):PTSimpleDrawing;
var
  ir:itrec;
begin
  DWGName:=uppercase(DWGName);
  result:=beginiterate(ir);
  if result<>nil then
  repeat
       if DWGName=uppercase(ChangeFileExt(extractfilename(result^.GetFileName),'')) then
       begin
            exit;
       end;
       result:=iterate(ir);
  until result=nil;
end;
 {procedure TZCADDrawingsManager.AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
 var
     domethod,undomethod:tmethod;
 begin
      SetObjCreateManipulator(domethod,undomethod);
      with PTZCADDrawing(GetCurrentDWG)^.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
      begin
           AddObject(PEnt);
           comit;
      end;
 end;}
function SetCurrentDWG(PDWG:pointer):pointer;
begin
     result:=drawings.GetCurrentDWG;
     if result<>pdwg then
                         drawings.SetCurrentDWG(pdwg);
end;

{procedure redrawoglwnd(GUIAction:TZMessageID);
var
   pdwg:PTSimpleDrawing;
   DC:TDrawContext;
begin
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then begin
    DC:=pdwg^.CreateDrawingRC;
    drawings.GetCurrentRoot.FormatAfterEdit(pdwg^,dc);
    pdwg.wa.param.firstdraw := TRUE;
    pdwg.wa.CalcOptimalMatrix;
    pdwg.pcamera^.totalobj:=0;
    pdwg.pcamera^.infrustum:=0;
    drawings.GetCurrentROOT.CalcVisibleByTree(drawings.GetCurrentDWG.pcamera^.frustum,drawings.GetCurrentDWG.pcamera.POSCOUNT,drawings.GetCurrentDWG.pcamera.VISCOUNT,drawings.GetCurrentROOT.ObjArray.ObjTree,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg^.myGluProject2,pdwg.pcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
    pdwg.ConstructObjRoot.calcvisible(drawings.GetCurrentDWG.pcamera^.frustum,drawings.GetCurrentDWG.pcamera.POSCOUNT,drawings.GetCurrentDWG.pcamera.VISCOUNT,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
    pdwg.wa.calcgrid;
    pdwg.wa.draworinvalidate;
  end;
end;}

procedure TZCADDrawingsManager.resetoglwnd;
var
   pdwg:PTSimpleDrawing;
begin
  if GUIAction<>ZMsgID_GUIResetOGLWNDProc then
    exit;
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
  begin
       pdwg.wa.param.lastonmouseobject:=nil;
  end;
end;


procedure clearotrack;
begin
     drawings.GetCurrentDWG.wa.param.ontrackarray.current:=0;
     drawings.GetCurrentDWG.wa.param.ontrackarray.total:=0;
end;
procedure clearcp;
begin
     drawings.GetCurrentDWG.SelObjArray.Free;
     //drawings.SelObjArray.clear;
end;

procedure TZCADDrawingsManager.standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
var
    pproglayer:PGDBLayerProp;
    pnevlayer:PGDBLayerProp;
begin
     case ObjType of
                  GDBNetID:
                    begin
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net<>nil then
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net^.Enabled then
                         begin
                              pproglayer:=BlockBaseDWG.LayerTable.getAddres(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net^.LayerName);
                              pnevlayer:=GetCurrentDWG.LayerTable.createlayerifneedbyname(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net^.LayerName,pproglayer);
                              if pnevlayer=nil then
                                                   pnevlayer:=GetCurrentDWG.LayerTable.addlayer(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net^.LayerName,7,-1,true,false,true,'???',TLOLoad);
                              pent.vp.Layer:=pnevlayer;
                         end;
                    end;
                  GDBCableID:
                    begin
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable<>nil then
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable^.Enabled then
                         begin
                              pproglayer:=BlockBaseDWG.LayerTable.getAddres(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable^.LayerName);
                              pnevlayer:=GetCurrentDWG.LayerTable.createlayerifneedbyname(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable^.LayerName,pproglayer);
                              if pnevlayer=nil then
                                                   pnevlayer:=GetCurrentDWG.LayerTable.addlayer(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable^.LayerName,7,-1,true,false,true,'???',TLOLoad);
                              pent.vp.Layer:=pnevlayer;
                         end;
                    end;
                  GDBElLeaderID:
                    begin
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader<>nil then
                         if sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader^.Enabled then
                         begin
                              pproglayer:=BlockBaseDWG.LayerTable.getAddres(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader^.LayerName);
                              pnevlayer:=GetCurrentDWG.LayerTable.createlayerifneedbyname(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader^.LayerName,pproglayer);
                              if pnevlayer=nil then
                                                   pnevlayer:=GetCurrentDWG.LayerTable.addlayer(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader^.LayerName,7,-1,true,false,true,'???',TLOLoad);
                              pent.vp.Layer:=pnevlayer;
                         end;
                    end;

     end;
end;
 procedure SetObjCreateManipulator(out domethod,undomethod:tmethod);
 begin
      domethod.Code:=pointer(drawings.GetCurrentROOT^.GoodAddObjectToObjArray);
      domethod.Data:=drawings.GetCurrentROOT;
      undomethod.Code:=pointer(drawings.GetCurrentROOT^.GoodRemoveMiFromArray);
      undomethod.Data:=drawings.GetCurrentROOT;
 end;
function TZCADDrawingsManager.FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:Word; InOwner:Boolean):PGDBObjEntity;
var
   //pobj:pGDBObjEntity;
   ir:itrec;
begin
     result:=entities.beginiterate(ir);
     if result<>nil then
     repeat
           if result.GetObjType=objID then
                                      exit;
           if inowner then
                          begin
                               result:=pointer(result.bp.ListPos.Owner);
                               while (result<>nil) do
                               begin
                                    if result.GetObjType=objID then
                                                              exit;
                                    result:=pointer(result.bp.ListPos.Owner);
                               end;

                          end;
           result:=entities.iterate(ir);
     until result=nil;
end;
function TZCADDrawingsManager.GetCurrentROOT;
begin
     if CurrentDWG<>nil then
                            result:=CurrentDWG.{pObjRoot}GetCurrentROOT
                        else
                            result:=nil;
end;
function TZCADDrawingsManager.GetCurrentOGLWParam:POGLWndtype;
begin
     if (currentdwg<>nil)and(currentdwg^.wa<>nil) then
                            begin
                                 if currentdwg^.wa.getviewcontrol<>nil then
                                                                    result:=@currentdwg^.wa.param
                                                                else
                                                                    result:=nil;
                            end
                        else
                            result:=nil;
end;

function TZCADDrawingsManager.GetCurrentDWG;
begin
 result:=CurrentDWG;
end;
function TZCADDrawingsManager.GetUndoStack:Pointer;
var
   pdwg:PTSimpleDrawing;
begin
     pdwg:=GetCurrentDWG;
     if pdwg<>nil then
                      result:=pdwg.GetUndoStack
                  else
                      result:=nil;
end;

procedure TZCADDrawingsManager.asociatedwgvars;
begin
   { TODO : переделать }
   if typeof(CurrentDWG^)=typeof(TZCADDrawing) then
   begin
   DWGDBUnit:=PTZCADDrawing(CurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
   DWGUnit:=PTZCADDrawing(CurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,'DrawingVars');
   //DWGUnit.AssignToSymbol(SysVar.DWG.DWG_SnapGrid,'DWG_SnapGrid');
   SysVar.dwg.DWG_SnapGrid:=@CurrentDWG.SnapGrid;
   //DWGUnit.AssignToSymbol(SysVar.DWG.DWG_DrawGrid,'DWG_DrawGrid');
   SysVar.DWG.DWG_DrawGrid:=@CurrentDWG.DrawGrid;
   //DWGUnit.AssignToSymbol(SysVar.DWG.DWG_Snap,'DWG_Snap');
   SysVar.DWG.DWG_Snap:=@CurrentDWG.Snap;
   //DWGUnit.AssignToSymbol(SysVar.DWG.DWG_GridSpacing,'DWG_GridSpacing');
   SysVar.DWG.DWG_GridSpacing:=@CurrentDWG.GridSpacing;

   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
   SysVar.dwg.DWG_CLayer:=@CurrentDWG.CurrentLayer;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLType,'DWG_CLType');
   SysVar.dwg.DWG_CLType:=@CurrentDWG.CurrentLType;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CTStyle,'DWG_CTStyle');
   SysVar.dwg.DWG_CTStyle:=@CurrentDWG.CurrentTextStyle;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');
   SysVar.dwg.DWG_CLinew:=@CurrentDWG.CurrentLineW;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_DrawMode,'DWG_DrawMode');
   SysVar.dwg.DWG_DrawMode:=@CurrentDWG.LWDisplay;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_LTscale,'DWG_LTScale');
   SysVar.dwg.DWG_LTscale:=@CurrentDWG.LTScale;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLTscale,'DWG_CLTScale');
   SysVar.dwg.DWG_CLTscale:=@CurrentDWG.CLTScale;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CColor,'DWG_CColor');
   SysVar.dwg.DWG_CColor:=@CurrentDWG.CColor;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CDimStyle,'DWG_CDimStyle');
   SysVar.dwg.DWG_CDimStyle:=@CurrentDWG.CurrentDimStyle;

   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_LUnits,'DWG_LUnits');
   SysVar.dwg.DWG_LUnits:=@CurrentDWG.LUnits;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_LUPrec,'DWG_LUPrec');
   SysVar.dwg.DWG_LUPrec:=@CurrentDWG.LUPrec;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_AUnits,'DWG_AUnits');
   SysVar.dwg.DWG_AUnits:=@CurrentDWG.AUnits;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_AUPrec,'DWG_AUPrec');
   SysVar.dwg.DWG_AUPrec:=@CurrentDWG.AUPrec;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_AngDir,'DWG_AngDir');
   SysVar.dwg.DWG_AngDir:=@CurrentDWG.AngDir;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_AngBase,'DWG_AngBase');
   SysVar.dwg.DWG_AngBase:=@CurrentDWG.AngBase;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_UnitMode,'DWG_UnitMode');
   SysVar.dwg.DWG_UnitMode:=@CurrentDWG.UnitMode;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_InsUnits,'DWG_InsUnits');
   SysVar.dwg.DWG_InsUnits:=@CurrentDWG.InsUnits;
   //DWGUnit.AssignToSymbol(SysVar.dwg.DWG_TextSize,'DWG_TextSize');
   SysVar.dwg.DWG_TextSize:=@CurrentDWG.TextSize;

   if assigned(CurrentDWG.wa)then
   begin
       sysvar.RD.RD_CurrentWAParam.Instance:=CurrentDWG.wa.getParam;
       sysvar.RD.RD_CurrentWAParam.PTD:=sysunit.TypeName2PTD(CurrentDWG.wa.getParamTypeName);
   end
   else
   begin
       sysvar.RD.RD_CurrentWAParam.Instance:=nil;
       sysvar.RD.RD_CurrentWAParam.PTD:=nil;
   end;
   end;
end;
procedure TZCADDrawingsManager.freedwgvars;
begin
   SysVar.DWG.DWG_SnapGrid:=nil;
   SysVar.DWG.DWG_DrawGrid:=nil;
   SysVar.DWG.DWG_Snap:=nil;
   SysVar.DWG.DWG_GridSpacing:=nil;

   SysVar.dwg.DWG_CLayer:=nil;
   SysVar.dwg.DWG_CLType:=nil;
   SysVar.dwg.DWG_CTStyle:=nil;
   SysVar.dwg.DWG_CLinew:=nil;
   SysVar.dwg.DWG_DrawMode:=nil;
   SysVar.dwg.DWG_LTscale:=nil;
   SysVar.dwg.DWG_CLTscale:=nil;
   SysVar.dwg.DWG_CColor:=nil;
   SysVar.dwg.DWG_CDimStyle:=nil;

   SysVar.dwg.DWG_LUnits:=nil;
   SysVar.dwg.DWG_LUPrec:=nil;
   SysVar.dwg.DWG_AUnits:=nil;
   SysVar.dwg.DWG_AUPrec:=nil;
   SysVar.dwg.DWG_AngDir:=nil;
   SysVar.dwg.DWG_AngBase:=nil;
   SysVar.dwg.DWG_UnitMode:=nil;
   SysVar.dwg.DWG_InsUnits:=nil;

   SysVar.dwg.DWG_TextSize:=nil;

   sysvar.RD.RD_CurrentWAParam.Instance:=nil;
   sysvar.RD.RD_CurrentWAParam.PTD:=nil;
end;

procedure TZCADDrawingsManager.SetCurrentDWG(PDWG:PTAbstractDrawing);
begin
 //commandmanager.executecommandend;
 CurrentDWG:=PTZCADDrawing(PDWG);
 asociatedwgvars;
end;
procedure CalcZ(z:Double);
begin
     if z<drawings.GetCurrentDWG.pcamera^.obj_zmax then
     drawings.GetCurrentDWG.pcamera^.obj_zmax:=z;
     if z>drawings.GetCurrentDWG.pcamera^.obj_zmin then
     drawings.GetCurrentDWG.pcamera^.obj_zmin:=z;
end;
procedure TZCADDrawingsManager.RemoveData(const data:PGDBaseObject);
//procedure TZCADDrawingsManager.eraseobj(ObjAddr:PGDBaseObject);
begin
     inherited RemoveData(data);
     if data=pointer(CurrentDWG) then
                                        begin
                                             CurrentDWG:=nil;
                                             DWGUnit:=nil;
                                        end;

end;
function TZCADDrawingsManager.CreateDWG(preloadedfile1,preloadedfile2:String):PTZCADDrawing;
var
   ptd:PTsimpleDrawing;
begin
     Getmem(Pointer(result),sizeof(TZCADDrawing));
     ptd:=currentdwg;
     currentdwg:=result;
     result^.init(@units,preloadedfile1,preloadedfile2);
     //self.AddByRef(result^);
     currentdwg:=ptd;
end;
(*function TZCADDrawingsManager.CreateSimpleDWG:PTSimpleDrawing;
var
   ptd:PTSimpleDrawing;
begin
     Getmem(Pointer(result),sizeof(TSimpleDrawing));
     ptd:=currentdwg;
     currentdwg:=pointer(result);
     result^.init(nil);//(@units);
     //self.AddByRef(result^);
     currentdwg:=pointer(ptd);
end;*)

constructor TZCADDrawingsManager.init;
var
   DC:TDrawContext;
begin
  inherited init(100);
  FileNameCounter:=0;
  ProjectUnits.init;
  ProjectUnits.SetNextManager(@units);

  CurrentDWG:=nil;
  //Getmem(Pointer(CurrentDWG),sizeof(TZCADDrawing));
  if CurrentDWG<>nil then
  begin
       CurrentDWG.init(@ProjectUnits);
       dc:=CurrentDWG^.CreateDrawingRC;
       CurrentDWG.pObjRoot^.FormatEntity(CurrentDWG^,dc);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_connector.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_OPS.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\teapot.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\shema_Poly_Line_Text_Circle_Arc.dxf',@CurrentDWG.ObjRoot);
  end;
  MainBlockCreateProc:=AddBlockFromDBIfNeed;
  ZCMsgCallBackInterface.RegisterHandler_GUIAction(redrawoglwnd);
end;
constructor TZCADDrawingsManager.initnul;
//var tp:GDBTextStyleProp;
begin
  //Pointer(FileName):=nil;
  //Changed:=True;
  { TODO : переделать }
  FileNameCounter:=0;
  if typeof(CurrentDWG^)=typeof(TZCADDrawing) then
  begin
  PTZCADDrawing(CurrentDWG).DWGUnits.init;
  end;
  //CurrentDWG.DWGUnits.init;
  inherited initnul;
end;
(*function TZCADDrawingsManager.AfterDeSerialize;
begin
     CurrentDWG.pcamera:=SysUnit.InterfaceVariables.findvardesc('camera').Instance;
     //CurrentDWG.ConstructObjRoot.init(65535);
     CurrentDWG.ConstructObjRoot.initnul;
     CurrentDWG.SelObjArray.init(65535);
     CurrentDWG.OnMouseObj.init(100);
     //BlockDefArray.init(1000);
end;*)
//procedure TZCADDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
destructor TZCADDrawingsManager.done;
begin
    CurrentDWG:=nil;
    inherited;
    // Freemem(pointer(currentdwg));
     ProjectUnits.done;
end;
procedure TZCADDrawingsManager.AddBlockFromDBIfNeed(_to:{PTSimpleDrawing}PTDrawingDef;name:String);
var
  td:PGDBObjBlockdef;
begin
  td:=PTSimpleDrawing(_to).BlockDefArray.getblockdef(name);
  if td=nil then begin
    td:=BlockBaseDWG.BlockDefArray.getblockdef(name);
    if td=nil then begin
      td:=CreateBlockDef(_to,name);
      if td=nil then
        td:=BlockBaseDWG.BlockDefArray.getblockdef(name)
      else
        exit;
    end;
    if td=nil then begin
      DebugLn(sysutils.format('{EM}Block "%s" not found! If this dimension arrow block - manually creating block not implemented yet((',[name]));
      exit;
    end;
    CopyBlock(BlockBaseDWG,PTSimpleDrawing(_to),td);
  end;
end;
function RemapLStyle2(_from,_to:PTSimpleDrawing;_source:PGDBLtypeProp):PGDBLtypeProp;
var
  ir:itrec;
  psp:PShapeProp;
  ptp:PTextProp;
begin
  if _source=nil then
    exit(nil);
  psp:=_source.shapearray.beginiterate(ir);
  if psp<>nil then
  repeat
        _to.TextStyleTable.addstyle(psp^.param.PStyle.name,psp^.param.PStyle.pfont.Name,psp^.param.PStyle.FontFamily,psp^.param.PStyle.prop,psp^.param.PStyle.UsedInLTYPE);
        psp:=_source.shapearray.iterate(ir);
  until psp=nil;
  ptp:=_source.textarray.beginiterate(ir);
  if ptp<>nil then
  repeat
        _to.TextStyleTable.addstyle(ptp^.param.PStyle.name,ptp^.param.PStyle.pfont.Name,ptp^.param.PStyle.FontFamily,ptp^.param.PStyle.prop,ptp^.param.PStyle.UsedInLTYPE);
        ptp:=_source.textarray.iterate(ir);
  until ptp=nil;
  result:=_to.LTypeStyleTable.createltypeifneed(_source,_to.TextStyleTable);
end;

procedure RemapLStyle(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
begin
  if _source.vp.LineType=nil then
    exit;
  _dest.vp.LineType:=RemapLStyle2(_from,_to,_source.vp.LineType);
end;

procedure TZCADDrawingsManager.AddLTStyleFromDBIfNeed(_to:PTSimpleDrawing;name:String);
var
  lt:PGDBLtypeProp;
begin
  lt:=PTSimpleDrawing(_to).LTypeStyleTable.getAddres(name);
  if lt=nil then begin
    lt:=BlockBaseDWG.LTypeStyleTable.getAddres(name);
    if lt<>nil then
      RemapLStyle2(BlockBaseDWG,_to,lt)
    else
      DebugLn(sysutils.format('{EM}Line type "%s" not found!',[name]));
    end;
end;

function createtstylebyindex(_from,_to:PTSimpleDrawing;oldti:{TArrayIndex}PGDBTextStyle):PGDBTextStyle;
var
   //{_dest,}td:PGDBObjBlockdef;
   newti:{TArrayIndex}PGDBTextStyle;
   tsname:String;
   poldstyle,pnevstyle:PGDBTextStyle;
   //ir:itrec;
   //{pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
                    poldstyle:=oldti{PGDBTextStyle(_from.TextStyleTable.getDataMutable(oldti))};
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname,poldstyle^.UsedInLTYPE);
                    if newti{<0}=nil then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.FontFamily,poldstyle.prop,poldstyle.UsedInLTYPE);
                                        pnevstyle:=PGDBTextStyle({_to.TextStyleTable.getDataMutable}(newti));
                                        pnevstyle^:=poldstyle^;
                                   end;
      result:={_to.TextStyleTable.getDataMutable}(_to.TextStyleTable.FindStyle(tsname,poldstyle^.UsedInLTYPE));
end;
procedure createtstyleifneed(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
//var
   //{_dest,}td:PGDBObjBlockdef;
   //oldti,newti:TArrayIndex;
   //tsname:String;
   //poldstyle,pnevstyle:PGDBTextStyle;
   //ir:itrec;
   //{pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
               if (_source^.GetObjType=GDBTextID)
               or (_source^.GetObjType=GDBMtextID) then
               begin
                    PGDBObjText(_dest)^.TXTStyleIndex:=createtstylebyindex(_from,_to,PGDBObjText(_source)^.TXTStyleIndex);
                    {oldti:=PGDBObjText(_source)^.TXTStyleIndex;
                    poldstyle:=PGDBTextStyle(_from.TextStyleTable.getDataMutable(oldti));
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname);
                    if newti<0 then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.prop);
                                        pnevstyle:=PGDBTextStyle(_to.TextStyleTable.getDataMutable(newti));
                                        pnevstyle^:=poldstyle^;
                                   end
                    createtstylebyindex
                    oldti:=_to.TextStyleTable.FindStyle(tsname);
                    PGDBObjText(_dest)^.TXTStyleIndex:=newti;}
               end;
end;
procedure createblockifneed(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity);
var
   {_dest,}td:PGDBObjBlockdef;
   tn:String;
   ir:itrec;
   {pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
procedure processblock;
begin
  td:=_to.BlockDefArray.getblockdef(tn);
  if td=nil then
                 begin
                      td:=_from.BlockDefArray.getblockdef(tn);
                      if td<>nil then
                      begin
                      pvisible2:=td.ObjArray.beginiterate(ir);
                      if pvisible2<>nil then
                      repeat
                            createblockifneed(_from,_to,pvisible2);

                            pvisible2:=td.ObjArray.iterate(ir);
                      until pvisible2=nil;
                      end;
                      if (_source^.GetObjType=GDBDeviceID) then
                      begin
                      pvisible2:=PGDBObjDevice(_source)^.VarObjArray.beginiterate(ir);
                      if pvisible2<>nil then
                      repeat
                            createblockifneed(_from,_to,pvisible2);

                            pvisible2:=PGDBObjDevice(_source)^.VarObjArray.iterate(ir);
                      until pvisible2=nil;

                      end;


                      if td<>nil then
                                     drawings.CopyBlock(_from,_to,td);
                 end;
end;

begin
               if (_source^.GetObjType=GDBBlockInsertID)
               or (_source^.GetObjType=GDBDeviceID) then
               begin
                    tn:=PGDBObjBlockInsert(_source)^.name;
                    processblock;
                    if (_source^.GetObjType=GDBDeviceID) then
                    begin
                         tn:=DevicePrefix+tn;
                         processblock;
                    end;

               end;
end;
{function createlayerifneed(_from,_to:PTZCADDrawing;_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=_to.LayerTable.getAddres(_source.Name);
           if result=nil then
           begin
                result:=_to.LayerTable.addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;
end;}
procedure RemapLayer(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
begin
     _dest.vp.Layer:=_to.LayerTable.createlayerifneed(_source.vp.Layer);
     _dest.correctsublayers(_to.LayerTable);
     //_dest.vp.Layer:=createlayerifneed(_from,_to,_source.vp.Layer);
end;
procedure RemapEntArray(_from,_to:PTSimpleDrawing;const _source,_dest:GDBObjEntityOpenArray);
var
   irs,ird:itrec;
   s,d:PGDBObjEntity;
begin
  s:=_source.beginiterate(irs);
  d:=_dest.beginiterate(ird);
  if (d<>nil)and(s<>nil) then
  repeat
         remapall(_from,_to,s,d);
       s:=_source.iterate(irs);
       d:=_dest.iterate(ird);
  until (s=nil)or(d=nil);
end;

procedure RemapAll(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
begin
  RemapLayer(_from,_to,_source,_dest);
  RemapLStyle(_from,_to,_source,_dest);
  case _source.GetObjType of
                        GDBElLeaderID,gdbtableid:begin
                                           createtstylebyindex(_from,_to,_from.TextStyleTable.getAddres(TSNStandardStyleName));
                                             end;
                        GDBTextID,GDBMtextID:begin
                                             createtstyleifneed(_from,_to,_source,_dest);
                                             end;
                        GDBDeviceID:begin
                                         RemapEntArray(_from,_to,PGDBObjDevice(_source).VarObjArray,PGDBObjDevice(_dest).VarObjArray);
                                         RemapEntArray(_from,_to,PGDBObjDevice(_source).ConstObjArray,PGDBObjDevice(_dest).ConstObjArray);
                                    end;
                        GDBBlockInsertID:begin
                                         RemapEntArray(_from,_to,PGDBObjBlockInsert(_source).ConstObjArray,PGDBObjBlockInsert(_dest).ConstObjArray);
                                    end;
                    end;
end;
function TZCADDrawingsManager.CopyEnt(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity):PGDBObjEntity;
var
   tv: pGDBObjEntity;
begin
    createblockifneed(_from,_to,_source);
    tv := _source^.Clone(_to.pObjRoot);
    if tv<>nil then
    begin
        tv.correctobjects(pointer(tv.bp.ListPos.Owner),tv.bp.ListPos.SelfIndex);
        _to.pObjRoot.AddObjectToObjArray(addr(tv));// .ObjArray.add(addr(tv));
        RemapAll(_from,_to,_source,tv);
    end;
    result:=tv;
end;
procedure TZCADDrawingsManager.FindMultiEntityByType(Filter:TEntsTypeFilter;var entarray:TZctnrVectorPGDBaseObjects);
var
   croot:PGDBObjGenericSubEntry;
   pvisible:PGDBObjEntity;
   ir:itrec;
   //pvd:pvardesk;
   //pentvarext:TVariablesExtender;
begin
  croot:=self.GetCurrentROOT;
  if croot<>nil then begin
    pvisible:=croot.ObjArray.beginiterate(ir);
    if pvisible<>nil then
    repeat
      if Filter.IsEntytyTypeAccepted(pvisible.GetObjType) then
        entarray.PushBackData(pvisible);
      pvisible:=croot.ObjArray.iterate(ir);
    until pvisible=nil;
  end;
end;
procedure TZCADDrawingsManager.FindMultiEntityByVar(objID:Word;vname,vvalue:String;var entarray:TZctnrVectorPGDBaseObjects);
var
   croot:PGDBObjGenericSubEntry;
   pvisible{,pvisible2,pv}:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
   pentvarext:TVariablesExtender;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.GetObjType=objID then
               begin
                    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
                    pvd:=pentvarext.entityunit.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         if pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)=vvalue then
                         begin
                              entarray.PushBackData(pvisible);
                         end;
                    end;
               end;
              pvisible:=croot.ObjArray.iterate(ir);
         until pvisible=nil;
     end;
end;
procedure TZCADDrawingsManager.FindMultiEntityByVar2(objID:Word;vname:String;var entarray:TZctnrVectorPGDBaseObjects);
var
   croot:PGDBObjGenericSubEntry;
   pvisible{,pvisible2,pv}:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
   pentvarext:TVariablesExtender;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.GetObjType=objID then
               begin
                    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
                    pvd:=pentvarext.entityunit.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         entarray.PushBackData(pvisible);
                    end;
               end;
              pvisible:=croot.ObjArray.iterate(ir);
         until pvisible=nil;
     end;
end;

function TZCADDrawingsManager.FindEntityByVar(objID:Word;vname,vvalue:String):PGDBObjEntity;
var
   croot:PGDBObjGenericSubEntry;
   pvisible{,pvisible2,pv}:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
   pentvarext:TVariablesExtender;
begin
     result:=nil;
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.GetObjType=objID then
               begin
                    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
                    pvd:=pentvarext.entityunit.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         if pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)=vvalue then
                         begin
                              result:=pvisible;
                              exit;
                         end;
                    end;
               end;
              pvisible:=croot.ObjArray.iterate(ir);
         until pvisible=nil;
     end;
end;

procedure TZCADDrawingsManager.CopyBlock(_from,_to:PTSimpleDrawing;_source:PGDBObjBlockdef);
var
   _dest:PGDBObjBlockdef;
   ir:itrec;
   pvisible,pvisible2:PGDBObjEntity;
   DC:TDrawContext;
   //psourcevarext,pdestvarext:TVariablesExtender;
begin
      if pos(DevicePrefix,_source.Name)=1 then
                                         CopyBlock(_from,_to,_from.BlockDefArray.getblockdef(copy(_source.Name,8,length(_source.Name)-7)));

     _dest:=_to.BlockDefArray.create(_source.Name);
     _dest.VarFromFile:='';
     _dest.Base:=_source.Base;
     _dest.BlockDesc:=_source.BlockDesc;

     _source^.CopyExtensionsTo(_dest^);
     {psourcevarext:=_source^.GetExtension<TVariablesExtender>;
     pdestvarext:=_dest^.GetExtension<TVariablesExtender>;
     if (psourcevarext<>nil)and(pdestvarext<>nil)then
     psourcevarext.entityunit.CopyTo(@pdestvarext.entityunit);}

     dc:=_to^.CreateDrawingRC;
     exclude(dc.Options,DCODrawable);

     pvisible:=_source.ObjArray.beginiterate(ir);
     if pvisible<>nil then
     repeat
           //pl:=createlayerifneed(_from,_to,pvisible.vp.layer);

           createblockifneed(_from,_to,pvisible);

               //pvisible:=CopyEnt(_from,_to,pvisible);
               //pv:=pvisible;
               pvisible2:=pvisible^.Clone(_dest);
               RemapAll(_from,_to,pvisible,pvisible2);
               //pvisible2:=nil;
                                      begin
                                          pvisible2^.correctobjects(_dest,ir.itc);
                                          pvisible2^.FormatEntity(_to^,dc);
                                          pvisible2.BuildGeometry(_to^);
                                          _dest.ObjArray.AddPEntity(pvisible2^);
                                     end;
          pvisible:=_source.ObjArray.iterate(ir);
     until pvisible=nil;


     _dest.formatentity(_to^,dc);
end;

procedure startup(preloadedfile1,preloadedfile2:String);
var
   {r: TLResource;
   f:TZctnrVectorBytes;}
   pds:PGDBDimStyle;
{const
   resname='GEWIND';
   filename='GEWIND.SHX';}
begin
  //RedrawOGLWNDProc:=RedrawOGLWND;
  //ResetOGLWNDProc:=ResetOGLWND;


  LTypeManager.init(100);

  LTypeManager.LoadFromFile(FindInPaths(GetSupportPath,'zcad.lin'),TLOLoad);


  //FromDirIterator({sysparam.programpath+'fonts/'}'C:\Program Files\AutoCAD 2010\Fonts\','*.shx','',addf,nil);

  FontManager.CreateBaseFont;
  FontManager.addFonfByFile(FindInPaths(sysvarPATHFontsPath,'ltypeshp.shx'));


  //pbasefont:=FontManager.getAddres(sysvar.SYS.SYS_AlternateFont^);


  //pbasefont:=FontManager.getAddres('gewind.shx');
  //pbasefont:=FontManager.{FindFonf}getAddres('amgdt.shx');
  //pbasefont:=FontManager.getAddres('gothice.shx');
  drawings.init;
  ZCMsgCallBackInterface.RegisterHandler_GUIAction(drawings.ResetOGLWND);
  //SetCurrentDWGProc:=SetCurrentDWG;
  BlockBaseDWG:=drawings.CreateDWG('','');
  _GetUndoStack:=drawings.GetUndoStack;
  ClipboardDWG:=drawings.CreateDWG(preloadedfile1,preloadedfile2);
  ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
  pds.init('Standart');
  //drawings.currentdwg:=BlockBaseDWG;
  GDBTrash.initnul;
end;
procedure finalize;
begin
  drawings.done;
  if BlockBaseDWG<>nil then
  begin
  BlockBaseDWG.done;
  Freemem(pointer(BlockBaseDWG));
  end;
  if ClipboardDWG<>nil then
  begin
  ClipboardDWG.done;
  Freemem(pointer(ClipboardDWG));
  end;
  pbasefont:=nil;
  LTypeManager.Done;
  GDBTrash.done;
end;
begin
end.
