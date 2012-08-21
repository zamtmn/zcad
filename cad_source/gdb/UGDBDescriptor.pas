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

unit UGDBDescriptor;
{$INCLUDE def.inc}
interface
uses
zcadsysvars,zcadinterface,zcadstrconsts,GDBWithLocalCS,UGDBOpenArrayOfUCommands,strproc,GDBBlockDef,UGDBDrawingdef,UGDBObjBlockdefArray,UGDBTableStyleArray,UUnitManager,
UGDBNumerator, gdbase,varmandef,varman,
sysutils, memman, geometry, gdbobjectsconstdef,
gdbasetypes,sysinfo,ugdbsimpledrawing,
GDBGenericSubEntry,
UGDBLayerArray,
GDBEntity,
UGDBSelectedObjArray,
UGDBTextStyleArray,
UGDBFontManager,
GDBCamera,
UGDBOpenArrayOfPV,
GDBRoot,UGDBSHXFont,
OGLWindow,UGDBOpenArrayOfPObjects,UGDBVisibleOpenArray;
const ls = $AAAA;
      ps:array [0..31] of LONGWORD=(
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC
                                  );
type
{EXPORT+}
GDBObjTrash=object(GDBObjEntity)
                 function GetHandle:GDBPlatformint;virtual;
                 function GetMatrix:PDMatrix4D;virtual;
                 constructor initnul;
                 destructor done;virtual;
           end;
TDWGProps=record
                Name:GDBString;
                Number:GDBInteger;
          end;
PTDrawing=^TDrawing;
TDrawing=object(TSimpleDrawing)

           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;
           UndoStack:GDBObjOpenArrayOfUCommands;

           constructor init(num:PTUnitManager);
           destructor done;virtual;
           function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
           function GetLastSelected:PGDBObjEntity;virtual;
           procedure SetCurrentDWG;virtual;
           function StoreOldCamerapPos:Pointer;virtual;
           procedure StoreNewCamerapPos(command:Pointer);virtual;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
           procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;
           procedure PushStartMarker(CommandName:GDBString);virtual;
           procedure PushEndMarker;virtual;
     end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor=object(GDBOpenArrayOfPObjects)
                    CurrentDWG:PTDrawing;
                    ProjectUnits:TUnitManager;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;
                    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;

                    function GetCurrentROOT:PGDBObjGenericSubEntry;

                    function GetCurrentDWG:PTDrawing;
                    procedure asociatedwgvars;
                    procedure SetCurrentDWG(PDWG:PTAbstractDrawing);

                    function CreateDWG:PTDrawing;
                    function CreateSimpleDWG:PTSimpleDrawing;virtual;
                    procedure eraseobj(ObjAddr:PGDBaseObject);virtual;

                    procedure CopyBlock(_from,_to:PTDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:PTDrawing;name:GDBString);
                    //procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
                    function FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:GDBWord; InOwner:GDBBoolean):PGDBObjEntity;
                    function FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjEntity;
                    procedure FindMultiEntityByVar(objID:GDBWord;vname,vvalue:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure FindMultiEntityByVar2(objID:GDBWord;vname:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
              end;
{EXPORT-}
var GDB: GDBDescriptor;
    BlockBaseDWG:PTDrawing;
    ClipboardDWG:PTDrawing;
    GDBTrash:GDBObjTrash;
    FontManager:GDBFontManager;
procedure CalcZ(z:GDBDouble);
procedure RemapAll(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
procedure startup;
procedure finalize;
procedure SetObjCreateManipulator(out domethod,undomethod:tmethod);
procedure clearotrack;
procedure clearcp;
procedure redrawoglwnd;
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses GDBTable,GDBText,GDBDevice,GDBBlockInsert,io,iodxf, GDBManager,shared,commandline,log,OGLSpecFunc;
procedure redrawoglwnd;
var
   pdwg:PTDrawing;
begin
  isOpenGLError;
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  begin
       gdb.GetCurrentRoot.FormatAfterEdit;
  pdwg.OGLwindow1.param.firstdraw := TRUE;
  pdwg.OGLwindow1.CalcOptimalMatrix;
  pdwg.pcamera^.totalobj:=0;
  pdwg.pcamera^.infrustum:=0;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentROOT.ObjArray.ObjTree);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.OGLwindow1.calcgrid;
  pdwg.OGLwindow1.draw;
  end;
  //gdb.GetCurrentDWG.OGLwindow1.repaint;
end;

procedure clearotrack;
begin
     gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.current:=0;
     gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.total:=0;
end;
procedure clearcp;
begin
     gdb.GetCurrentDWG.SelObjArray.clearallobjects;
     //gdb.SelObjArray.clear;
end;

procedure GDBDescriptor.standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
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
      domethod.Code:=pointer(gdb.GetCurrentROOT^.GoodAddObjectToObjArray);
      domethod.Data:=gdb.GetCurrentROOT;
      undomethod.Code:=pointer(gdb.GetCurrentROOT^.GoodRemoveMiFromArray);
      undomethod.Data:=gdb.GetCurrentROOT;
 end;
procedure TDrawing.SetCurrentDWG();
begin
  gdb.SetCurrentDWG(@self);
end;

function TDrawing.GetLastSelected:PGDBObjEntity;
begin
     result:=OGLwindow1.param.SelDesc.LastSelectedObject;
end;
function TDrawing.StoreOldCamerapPos:Pointer;
begin
     result:=UndoStack.PushCreateTGChangeCommand(GetPcamera^.prop)
end;
procedure TDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);
var
    tum:TUndableMethod;
begin
  tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
  tmethod(tum).Data:=obj;
  //tum:=tundablemethod(obj^.rtmodifyonepoint);
  with UndoStack.PushCreateTGObjectChangeCommand(rtmod,tmethod(tum))^ do
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
function GDBDescriptor.FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:GDBWord; InOwner:GDBBoolean):PGDBObjEntity;
var
   pobj:pGDBObjEntity;
   ir:itrec;
begin
     result:=entities.beginiterate(ir);
     if result<>nil then
     repeat
           if result.vp.ID=objID then
                                      exit;
           if inowner then
                          begin
                               result:=pointer(result.bp.ListPos.Owner);
                               while (result<>nil) do
                               begin
                                    if result.vp.ID=objID then
                                                              exit;
                                    result:=pointer(result.bp.ListPos.Owner);
                               end;

                          end;
           result:=entities.iterate(ir);
     until result=nil;
end;
function GDBDescriptor.GetCurrentROOT;
begin
     if CurrentDWG<>nil then
                            result:=CurrentDWG.{pObjRoot}GetCurrentROOT
                        else
                            result:=nil;
end;
function GDBDescriptor.GetCurrentDWG;
begin
 result:=CurrentDWG;
end;
procedure GDBDescriptor.asociatedwgvars;
//var
//    DWGUnit:PTUnit;
begin
   if typeof(CurrentDWG^)=typeof(TDrawing) then
   begin
   DWGUnit:=CurrentDWG.DWGUnits.findunit('DrawingVars');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_SnapGrid,'DWG_SnapGrid');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_DrawGrid,'DWG_DrawGrid');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_StepGrid,'DWG_StepGrid');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_OriginGrid,'DWG_OriginGrid');

   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_DrawMode,'DWG_DrawMode');
   end;
end;

procedure GDBDescriptor.SetCurrentDWG(PDWG:PTAbstractDrawing);
begin
 commandmanager.executecommandend;
 CurrentDWG:=PTDrawing(PDWG);
 asociatedwgvars;
end;

function GDBObjTrash.GetHandle;
begin
     result:=H_Trash;
end;
function GDBObjTrash.GetMatrix;
begin
     result:=@onematrix;
end;
constructor GDBObjTrash.initnul;
begin
end;
destructor GDBObjTrash.done;
begin
end;
procedure CalcZ(z:GDBDouble);
begin
     if z<gdb.GetCurrentDWG.pcamera^.obj_zmax then
     gdb.GetCurrentDWG.pcamera^.obj_zmax:=z;
     if z>gdb.GetCurrentDWG.pcamera^.obj_zmin then
     gdb.GetCurrentDWG.pcamera^.obj_zmin:=z;
end;
procedure TDrawing.PushStartMarker(CommandName:GDBString);
begin
     self.UndoStack.PushStartMarker(CommandName);
end;

procedure TDrawing.PushEndMarker;
begin
      self.UndoStack.PushEndMarker;
end;
constructor TDrawing.init;
var {tp:GDBTextStyleProp;}
    ts:PTGDBTableStyle;
    cs:TGDBTableCellStyle;
    pvd:pvardesk;
begin
  DWGUnits.init;
  DWGUnits.SetNextManager(num);
  DWGUnits.loadunit(expandpath('*rtl/dwg/DrawingDeviceBase.pas'),nil);
  DWGDBUnit:=DWGUnits.findunit(DrawingDeviceBaseUnitName);
  DWGUnits.loadunit(expandpath('*rtl/dwg/DrawingVars.pas'),nil);
  //DWGUnits.findunit('DrawingVars').AssignToSymbol(pcamera,'camera');

  pvd:=DWGUnits.findunit('DrawingVars').InterfaceVariables.findvardesc('camera');
  if pvd<>nil then
                 inherited init(pvd^.data.Instance)
             else
                 inherited init(nil);


  Pointer(FileName):=nil;
  FileName:=rsUnnamedWindowTitle;
  Changed:=False;
  UndoStack.init;


  //OGLwindow1.initxywh('oglwnd',nil,200,72,768,596,false);
  //OGLwindow1.show;
end;
procedure GDBDescriptor.eraseobj(ObjAddr:PGDBaseObject);
begin
     inherited eraseobj(objaddr);
     if objaddr=pointer(CurrentDWG) then
                               CurrentDWG:=nil;
     
end;
function GDBDescriptor.CreateDWG:PTDrawing;
var
   ptd:PTDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TDrawing));
     ptd:=currentdwg;
     currentdwg:=result;
     result^.init(@units);
     //self.AddRef(result^);
     currentdwg:=ptd;
end;
function GDBDescriptor.CreateSimpleDWG:PTSimpleDrawing;
var
   ptd:PTSimpleDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TSimpleDrawing));
     ptd:=currentdwg;
     currentdwg:=pointer(result);
     result^.init(nil);//(@units);
     //self.AddRef(result^);
     currentdwg:=pointer(ptd);
end;

constructor GDBDescriptor.init;
//var //tp:GDBTextStyleProp;
    //ts:PTGDBTableStyle;
    //cs:TGDBTableCellStyle;
begin
   inherited init({$IFDEF DEBUGBUILD}'{F5A454F1-CB6B-43AA-AD8D-AF3B9D781ED0}',{$ENDIF}100);
  //LayerTable.addlayer('EL_WIRES',CGDBGreen,40,true,false,true);








  ProjectUnits.init;
  ProjectUnits.SetNextManager(@units);

  CurrentDWG:=nil;
  //gdBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(CurrentDWG),sizeof(TDrawing));
  if CurrentDWG<>nil then
  begin
       CurrentDWG.init(@ProjectUnits);
       CurrentDWG.pObjRoot^.Format;
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_connector.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_OPS.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\teapot.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\shema_Poly_Line_Text_Circle_Arc.dxf',@CurrentDWG.ObjRoot);
  end;
end;
constructor GDBDescriptor.initnul;
//var tp:GDBTextStyleProp;
begin
  //Pointer(FileName):=nil;
  //Changed:=True;
  CurrentDWG.DWGUnits.init;
  inherited initnul;
end;
function GDBDescriptor.AfterDeSerialize;
begin
     CurrentDWG.pcamera:=SysUnit.InterfaceVariables.findvardesc('camera').data.Instance;
     //CurrentDWG.ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-56klhj2D-4B17-A33A-61CF3F5F2A90}',{$ENDIF}65535);
     CurrentDWG.ConstructObjRoot.initnul;
     CurrentDWG.SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FkjhB5-BFB1-8791C261C577}',{$ENDIF}65535);
     CurrentDWG.OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-427длро2-B429-4D134913BC26}',{$ENDIF}100);
     //BlockDefArray.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-fgjhfgh9-AF2E-D1AB116B5737}',{$ENDIF}1000);
end;
destructor TDrawing.done;
begin
     inherited;
     undostack.done;
     FileName:='';
end;
//procedure TDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
destructor GDBDescriptor.done;
begin
    CurrentDWG:=nil;
    inherited;
    // gdbfreemem(pointer(currentdwg));
     ProjectUnits.done;
end;
procedure GDBDescriptor.AddBlockFromDBIfNeed(_to:PTDrawing;name:GDBString);
var
   {_dest,}td:PGDBObjBlockdef;
   //tn:gdbstring;
   //ir:itrec;
   //pvisible,pvisible2:PGDBObjEntity;
  // pl:PGDBLayerProp;
begin
     td:=_to.BlockDefArray.getblockdef(name);
     if td=nil then
     begin
          td:=BlockBaseDWG.BlockDefArray.getblockdef(name);
          CopyBlock(BlockBaseDWG,_to,td);
     end;
end;
function createtstylebyindex(_from,_to:PTDrawing;oldti:TArrayIndex):TArrayIndex;
var
   {_dest,}td:PGDBObjBlockdef;
   newti:TArrayIndex;
   tsname:gdbstring;
   poldstyle,pnevstyle:PGDBTextStyle;
   ir:itrec;
   {pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
                    poldstyle:=PGDBTextStyle(_from.TextStyleTable.getelement(oldti));
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname);
                    if newti<0 then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.prop);
                                        pnevstyle:=PGDBTextStyle(_to.TextStyleTable.getelement(newti));
                                        pnevstyle^:=poldstyle^;
                                   end;
      result:=_to.TextStyleTable.FindStyle(tsname);
end;
procedure createtstyleifneed(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
var
   {_dest,}td:PGDBObjBlockdef;
   oldti,newti:TArrayIndex;
   tsname:gdbstring;
   poldstyle,pnevstyle:PGDBTextStyle;
   ir:itrec;
   {pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
               if (_source^.vp.ID=GDBTextID)
               or (_source^.vp.ID=GDBMtextID) then
               begin
                    PGDBObjText(_dest)^.TXTStyleIndex:=createtstylebyindex(_from,_to,PGDBObjText(_source)^.TXTStyleIndex);
                    {oldti:=PGDBObjText(_source)^.TXTStyleIndex;
                    poldstyle:=PGDBTextStyle(_from.TextStyleTable.getelement(oldti));
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname);
                    if newti<0 then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.prop);
                                        pnevstyle:=PGDBTextStyle(_to.TextStyleTable.getelement(newti));
                                        pnevstyle^:=poldstyle^;
                                   end
                    createtstylebyindex
                    oldti:=_to.TextStyleTable.FindStyle(tsname);
                    PGDBObjText(_dest)^.TXTStyleIndex:=newti;}
               end;
end;
procedure createblockifneed(_from,_to:PTDrawing;_source:PGDBObjEntity);
var
   {_dest,}td:PGDBObjBlockdef;
   tn:gdbstring;
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
                      if (_source^.vp.ID=GDBDeviceID) then
                      begin
                      pvisible2:=PGDBObjDevice(_source)^.VarObjArray.beginiterate(ir);
                      if pvisible2<>nil then
                      repeat
                            createblockifneed(_from,_to,pvisible2);

                            pvisible2:=PGDBObjDevice(_source)^.VarObjArray.iterate(ir);
                      until pvisible2=nil;

                      end;


                      if td<>nil then
                                     gdb.CopyBlock(_from,_to,td);
                 end;
end;

begin
               if (_source^.vp.ID=GDBBlockInsertID)
               or (_source^.vp.ID=GDBDeviceID) then
               begin
                    tn:=PGDBObjBlockInsert(_source)^.name;
                    processblock;
                    if (_source^.vp.ID=GDBDeviceID) then
                    begin
                         tn:=DevicePrefix+tn;
                         processblock;
                    end;

               end;
end;
{function createlayerifneed(_from,_to:PTDrawing;_source:PGDBLayerProp):PGDBLayerProp;
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
procedure RemapLayer(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
begin
     _dest.vp.Layer:=_to.LayerTable.createlayerifneed(_source.vp.Layer);
     _dest.correctsublayers(_to.LayerTable);
     //_dest.vp.Layer:=createlayerifneed(_from,_to,_source.vp.Layer);
end;
procedure RemapEntArray(_from,_to:PTDrawing;const _source,_dest:GDBObjEntityOpenArray);
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

procedure RemapAll(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
begin
  RemapLayer(_from,_to,_source,_dest);
  case _source.vp.ID of
                        GDBElLeaderID,gdbtableid:begin
                                           createtstylebyindex(_from,_to,0);
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
function GDBDescriptor.CopyEnt(_from,_to:PTDrawing;_source:PGDBObjEntity):PGDBObjEntity;
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
procedure GDBDescriptor.FindMultiEntityByVar(objID:GDBWord;vname,vvalue:GDBString;var entarray:GDBOpenArrayOfPObjects);
var
   croot:PGDBObjGenericSubEntry;
   pvisible,pvisible2,pv:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pvd:=pvisible^.ou.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         if pvd.data.PTD.GetValueAsString(pvd.data.Instance)=vvalue then
                         begin
                              entarray.Add(@pvisible);
                         end;
                    end;
               end;
              pvisible:=croot.ObjArray.iterate(ir);
         until pvisible=nil;
     end;
end;
procedure GDBDescriptor.FindMultiEntityByVar2(objID:GDBWord;vname:GDBString;var entarray:GDBOpenArrayOfPObjects);
var
   croot:PGDBObjGenericSubEntry;
   pvisible,pvisible2,pv:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pvd:=pvisible^.ou.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         entarray.Add(@pvisible);
                    end;
               end;
              pvisible:=croot.ObjArray.iterate(ir);
         until pvisible=nil;
     end;
end;

function GDBDescriptor.FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjEntity;
var
   croot:PGDBObjGenericSubEntry;
   pvisible,pvisible2,pv:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
begin
     result:=nil;
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pvd:=pvisible^.ou.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         if pvd.data.PTD.GetValueAsString(pvd.data.Instance)=vvalue then
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

procedure GDBDescriptor.CopyBlock(_from,_to:PTDrawing;_source:PGDBObjBlockdef);
var
   _dest{,td}:PGDBObjBlockdef;
   //tn:gdbstring;
   ir:itrec;
   pvisible,pvisible2,pv:PGDBObjEntity;
   pl:PGDBLayerProp;

begin
      if pos(DevicePrefix,_source.Name)=1 then
                                         CopyBlock(_from,_to,_from.BlockDefArray.getblockdef(copy(_source.Name,8,length(_source.Name)-7)));

     _dest:=_to.BlockDefArray.create(_source.Name);
     _dest.VarFromFile:='';
     _dest.Base:=_source.Base;
     _dest.BlockDesc:=_source.BlockDesc;

     _source.OU.CopyTo(@_dest.OU);

     pvisible:=_source.ObjArray.beginiterate(ir);
     if pvisible<>nil then
     repeat
           //pl:=createlayerifneed(_from,_to,pvisible.vp.layer);

           createblockifneed(_from,_to,pvisible);

               //pvisible:=CopyEnt(_from,_to,pvisible);
               pv:=pvisible;
               pvisible2:=pvisible^.Clone(_dest);
               RemapAll(_from,_to,pvisible,pvisible2);
               //pvisible2:=nil;
                                      begin
                                          pvisible2^.correctobjects(_dest,ir.itc);
                                          pvisible2^.format;
                                          pvisible2.BuildGeometry;
                                          _dest.ObjArray.add(@pvisible2);
                                     end;
          pvisible:=_source.ObjArray.iterate(ir);
     until pvisible=nil;


     _dest.format;
end;
procedure addf(fn:gdbstring);
begin
     FontManager.addFonf(fn);
end;

procedure startup;
begin
  RedrawOGLWNDProc:=RedrawOGLWND;
  FontManager.init({$IFDEF DEBUGBUILD}'{9D0E081C-796F-4EB1-98A9-8B6EA9BD8640}',{$ENDIF}100);

  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\times.shx');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\GENISO.SHX');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\amgdt.shx');

  //FromDirIterator({sysparam.programpath+'fonts/'}'C:\Program Files\AutoCAD 2010\Fonts\','*.shx','',addf,nil);

  FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,sysvar.SYS.SYS_AlternateFont^));
  pbasefont:=FontManager.getAddres(sysvar.SYS.SYS_AlternateFont^);
  if pbasefont=nil then
                       shared.FatalError('Альтернативный шрифт "'+sysvar.SYS.SYS_AlternateFont^+
                                         '" не найден в "'+ sysvar.PATH.Fonts_Path^+'"');

  //FontManager.addFonf(sysparam.programpath+'fonts/gewind.shx');
  //FontManager.addFonf('gothice.shx');
  //FontManager.addFonf('romant.shx');

  //pbasefont:=FontManager.getAddres('gewind.shx');
  //pbasefont:=FontManager.{FindFonf}getAddres('amgdt.shx');
  //pbasefont:=FontManager.getAddres('gothice.shx');
  gdb.init;
  BlockBaseDWG:=gdb.CreateDWG;
  ClipboardDWG:=gdb.CreateDWG;
  //gdb.currentdwg:=BlockBaseDWG;
  GDBTrash.initnul;
end;
procedure finalize;
begin
  gdb.done;
  BlockBaseDWG.done;
  GDBFreemem(pointer(BlockBaseDWG));
  ClipboardDWG.done;
  GDBFreemem(pointer(ClipboardDWG));
  pbasefont:=nil;
  FontManager.FreeAndDone;
  GDBTrash.done;
end;
begin
  programlog.logoutstr('UGDBDescriptor.startup',lp_IncPos);
  //UGDBDescriptor.startup;
  {$IFDEF DEBUGINITSECTION}LogOut('GDBDescriptor.initialization');{$ENDIF}
  programlog.logoutstr('UGDBDescriptor.startup',lp_DecPos);
end.
