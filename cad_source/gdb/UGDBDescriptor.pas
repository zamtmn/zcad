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
UGDBDrawingdef,WindowsSpecific,LResources,zcadsysvars,zcadinterface,zcadstrconsts,GDBWithLocalCS,UGDBOpenArrayOfUCommands,strproc,GDBBlockDef,ugdbabstractdrawing,UGDBObjBlockdefArray,UGDBTableStyleArray,UUnitManager,
UGDBNumerator, gdbase,varmandef,varman,
sysutils, memman, geometry, gdbobjectsconstdef,
gdbasetypes,sysinfo,ugdbsimpledrawing,
GDBGenericSubEntry,
UGDBLayerArray,
GDBEntity,
UGDBSelectedObjArray,
UGDBTextStyleArray,
UGDBFontManager,
ugdbltypearray,
GDBCamera,
UGDBOpenArrayOfPV,
GDBRoot,ugdbfont,
OGLWindow,UGDBOpenArrayOfPObjects,UGDBVisibleOpenArray,ugdbtrash,UGDBOpenArrayOfByte;
type
{EXPORT+}
TDWGProps=packed record
                Name:GDBString;
                Number:GDBInteger;
          end;
PTDrawing=^TDrawing;
TDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TSimpleDrawing)

           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;
           UndoStack:GDBObjOpenArrayOfUCommands;
           DWGUnits:TUnitManager;

           constructor init(num:PTUnitManager);
           destructor done;virtual;
           function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;

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
           function GetDWGUnits:PTUnitManager;virtual;
           procedure AddBlockFromDBIfNeed(name:GDBString);virtual;
     end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                    CurrentDWG:{PTDrawing}PTSimpleDrawing;
                    ProjectUnits:TUnitManager;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;
                    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;

                    function GetCurrentROOT:PGDBObjGenericSubEntry;

                    function GetCurrentDWG:{PTDrawing}PTSimpleDrawing;
                    procedure asociatedwgvars;
                    procedure freedwgvars;
                    procedure SetCurrentDWG(PDWG:PTAbstractDrawing);

                    function CreateDWG:PTDrawing;
                    //function CreateSimpleDWG:PTSimpleDrawing;virtual;
                    procedure eraseobj(ObjAddr:PGDBaseObject);virtual;

                    procedure CopyBlock(_from,_to:PTSimpleDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:{PTSimpleDrawing}PTDrawingDef;name:GDBString);
                    //procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
                    function FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:GDBWord; InOwner:GDBBoolean):PGDBObjEntity;
                    function FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjEntity;
                    procedure FindMultiEntityByVar(objID:GDBWord;vname,vvalue:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure FindMultiEntityByVar2(objID:GDBWord;vname:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
              end;
{EXPORT-}
var GDB: GDBDescriptor;
    BlockBaseDWG:PTDrawing=nil;
    ClipboardDWG:PTDrawing=nil;
    //GDBTrash:GDBObjTrash;
    LtypeManager:GDBLtypeArray;
procedure CalcZ(z:GDBDouble);
procedure RemapAll(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
procedure startup;
procedure finalize;
procedure SetObjCreateManipulator(out domethod,undomethod:tmethod);
procedure clearotrack;
procedure clearcp;
procedure redrawoglwnd;
function dwgSaveDXFDPAS(s:gdbstring;dwg:PTSimpleDrawing):GDBInteger;
function dwgQSave_com(dwg:PTSimpleDrawing):GDBInteger;
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses GDBTable,GDBText,GDBDevice,GDBBlockInsert,io,iodxf, GDBManager,shared,commandline,log,OGLSpecFunc;
 function dwgSaveDXFDPAS(s:gdbstring;dwg:PTSimpleDrawing):GDBInteger;
 var
    mem:GDBOpenArrayOfByte;
    pu:ptunit;
 begin
      savedxf2000(s,dwg^);
      pu:=PTDrawing(dwg).DWGUnits.findunit(DrawingDeviceBaseUnitName);
      mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
      pu^.SavePasToMem(mem);
      mem.SaveToFile(s+'.dbpas');
      mem.done;
      result:=cmd_ok;
 end;
 function dwgQSave_com(dwg:PTSimpleDrawing):GDBInteger;
 var s,s1:GDBString;
     itautoseve:boolean;
 begin
      begin
           if dwg.GetFileName=rsUnnamedWindowTitle then
           begin
                if not(SaveFileDialog(s1,'dxf',ProjectFileFilter,'',rsSaveFile)) then
                begin
                     result:=cmd_error;
                     exit;
                end;
           end
           else
               s1:=gdb.GetCurrentDWG.GetFileName;
      end;
      result:=dwgSaveDXFDPAS(s1,dwg);
 end;
function SetCurrentDWG(PDWG:pointer):pointer;
begin
     result:=gdb.GetCurrentDWG;
     if result<>pdwg then
                         gdb.SetCurrentDWG(pdwg);
end;

procedure redrawoglwnd;
var
   pdwg:PTSimpleDrawing;
begin
  isOpenGLError;
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  begin
       gdb.GetCurrentRoot.FormatAfterEdit(pdwg^);
  pdwg.OGLwindow1.param.firstdraw := TRUE;
  pdwg.OGLwindow1.CalcOptimalMatrix;
  pdwg.pcamera^.totalobj:=0;
  pdwg.pcamera^.infrustum:=0;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentROOT.ObjArray.ObjTree,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg^.myGluProject2,pdwg.pcamera.prop.zoom);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  pdwg.OGLwindow1.calcgrid;
  pdwg.OGLwindow1.draw;
  end;
  //gdb.GetCurrentDWG.OGLwindow1.repaint;
end;

procedure resetoglwnd;
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  begin
       pdwg.OGLwindow1.param.lastonmouseobject:=nil;
  end;
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
   //pobj:pGDBObjEntity;
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
   { TODO : переделать }
   if typeof(CurrentDWG^)=typeof(TDrawing) then
   begin
   DWGUnit:=PTDrawing(CurrentDWG).DWGUnits.findunit('DrawingVars');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_SnapGrid,'DWG_SnapGrid');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_DrawGrid,'DWG_DrawGrid');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_Snap,'DWG_Snap');
   DWGUnit.AssignToSymbol(SysVar.DWG.DWG_GridSpacing,'DWG_GridSpacing');

   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLType,'DWG_CLType');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CTStyle,'DWG_CTStyle');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_DrawMode,'DWG_DrawMode');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_LTscale,'DWG_LTScale');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CLTscale,'DWG_CLTScale');
   DWGUnit.AssignToSymbol(SysVar.dwg.DWG_CColor,'DWG_CColor');
   end;
end;
procedure GDBDescriptor.freedwgvars;
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
end;

procedure GDBDescriptor.SetCurrentDWG(PDWG:PTAbstractDrawing);
begin
 commandmanager.executecommandend;
 CurrentDWG:=PTDrawing(PDWG);
 asociatedwgvars;
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
function TDrawing.GetDWGUnits:PTUnitManager;
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
                                        begin
                                             CurrentDWG:=nil;
                                             DWGUnit:=nil;
                                        end;

end;
function GDBDescriptor.CreateDWG:PTDrawing;
var
   ptd:PTsimpleDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TDrawing));
     ptd:=currentdwg;
     currentdwg:=result;
     result^.init(@units);
     //self.AddRef(result^);
     currentdwg:=ptd;
end;
(*function GDBDescriptor.CreateSimpleDWG:PTSimpleDrawing;
var
   ptd:PTSimpleDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TSimpleDrawing));
     ptd:=currentdwg;
     currentdwg:=pointer(result);
     result^.init(nil);//(@units);
     //self.AddRef(result^);
     currentdwg:=pointer(ptd);
end;*)

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
       CurrentDWG.pObjRoot^.FormatEntity(CurrentDWG^);
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
  { TODO : переделать }
  if typeof(CurrentDWG^)=typeof(TDrawing) then
  begin
  PTDrawing(CurrentDWG).DWGUnits.init;
  end;
  //CurrentDWG.DWGUnits.init;
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
     DWGUnits.FreeAndDone;
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
procedure GDBDescriptor.AddBlockFromDBIfNeed(_to:{PTSimpleDrawing}PTDrawingDef;name:GDBString);
var
   {_dest,}td:PGDBObjBlockdef;
   //tn:gdbstring;
   //ir:itrec;
   //pvisible,pvisible2:PGDBObjEntity;
  // pl:PGDBLayerProp;
begin
     td:=PTSimpleDrawing(_to).BlockDefArray.getblockdef(name);
     if td=nil then
     begin
          td:=BlockBaseDWG.BlockDefArray.getblockdef(name);
          CopyBlock(BlockBaseDWG,PTSimpleDrawing(_to),td);
     end;
end;
function createtstylebyindex(_from,_to:PTSimpleDrawing;oldti:{TArrayIndex}PGDBTextStyle):PGDBTextStyle;
var
   //{_dest,}td:PGDBObjBlockdef;
   newti:{TArrayIndex}PGDBTextStyle;
   tsname:gdbstring;
   poldstyle,pnevstyle:PGDBTextStyle;
   //ir:itrec;
   //{pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
                    poldstyle:=oldti{PGDBTextStyle(_from.TextStyleTable.getelement(oldti))};
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname,poldstyle^.UsedInLTYPE);
                    if newti{<0}=nil then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.prop,poldstyle.UsedInLTYPE);
                                        pnevstyle:=PGDBTextStyle({_to.TextStyleTable.getelement}(newti));
                                        pnevstyle^:=poldstyle^;
                                   end;
      result:={_to.TextStyleTable.getelement}(_to.TextStyleTable.FindStyle(tsname,poldstyle^.UsedInLTYPE));
end;
procedure createtstyleifneed(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
//var
   //{_dest,}td:PGDBObjBlockdef;
   //oldti,newti:TArrayIndex;
   //tsname:gdbstring;
   //poldstyle,pnevstyle:PGDBTextStyle;
   //ir:itrec;
   //{pvisible,}pvisible2:PGDBObjEntity;
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
procedure createblockifneed(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity);
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
procedure RemapLayer(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
begin
     _dest.vp.Layer:=_to.LayerTable.createlayerifneed(_source.vp.Layer);
     _dest.correctsublayers(_to.LayerTable);
     //_dest.vp.Layer:=createlayerifneed(_from,_to,_source.vp.Layer);
end;
procedure RemapLStyle(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
var //p:GDBPointer;
    ir:itrec;
    psp:PShapeProp;
    ptp:PTextProp;
    //sp:ShapeProp;
    //tp:TextProp;
begin
  if _source.vp.LineType=nil then
                                 exit;
  psp:=_source.vp.LineType.shapearray.beginiterate(ir);
  if psp<>nil then
  repeat
        _to.TextStyleTable.addstyle(psp^.param.PStyle.name,psp^.param.PStyle.pfont.Name,psp^.param.PStyle.prop,psp^.param.PStyle.UsedInLTYPE);
        psp:=_source.vp.LineType.shapearray.iterate(ir);
  until psp=nil;
  ptp:=_source.vp.LineType.textarray.beginiterate(ir);
  if ptp<>nil then
  repeat
        _to.TextStyleTable.addstyle(ptp^.param.PStyle.name,ptp^.param.PStyle.pfont.Name,ptp^.param.PStyle.prop,ptp^.param.PStyle.UsedInLTYPE);
        ptp:=_source.vp.LineType.textarray.iterate(ir);
  until ptp=nil;
     _dest.vp.LineType:=_to.LTypeStyleTable.createltypeifneed(_source.vp.LineType,_to.TextStyleTable);
     //_dest.correctsublayers(_to.LayerTable);
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
function GDBDescriptor.CopyEnt(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity):PGDBObjEntity;
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
   pvisible{,pvisible2,pv}:PGDBObjEntity;
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
   pvisible{,pvisible2,pv}:PGDBObjEntity;
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
   pvisible{,pvisible2,pv}:PGDBObjEntity;
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

procedure GDBDescriptor.CopyBlock(_from,_to:PTSimpleDrawing;_source:PGDBObjBlockdef);
var
   _dest{,td}:PGDBObjBlockdef;
   //tn:gdbstring;
   ir:itrec;
   pvisible,pvisible2{,pv}:PGDBObjEntity;
   //pl:PGDBLayerProp;

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
               //pv:=pvisible;
               pvisible2:=pvisible^.Clone(_dest);
               RemapAll(_from,_to,pvisible,pvisible2);
               //pvisible2:=nil;
                                      begin
                                          pvisible2^.correctobjects(_dest,ir.itc);
                                          pvisible2^.FormatEntity(_to^);
                                          pvisible2.BuildGeometry(_to^);
                                          _dest.ObjArray.add(@pvisible2);
                                     end;
          pvisible:=_source.ObjArray.iterate(ir);
     until pvisible=nil;


     _dest.formatentity(_to^);
end;
procedure addf(fn:gdbstring);
begin
     FontManager.addFonf(fn);
end;

procedure startup;
var
   r: TLResource;
   f:GDBOpenArrayOfByte;
const
   resname='GEWIND';
   filename='GEWIND.SHX';
begin
  RedrawOGLWNDProc:=RedrawOGLWND;
  ResetOGLWNDProc:=ResetOGLWND;

  LTypeManager.init({$IFDEF DEBUGBUILD}'{9D0E081C-796F-4EB1-98A9-8B6EA9BD8640}',{$ENDIF}100);

  LTypeManager.LoadFromFile(FindInPaths(sysvar.PATH.Support_Path^,'zcad.lin'),TLOLoad);

  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\times.shx');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\GENISO.SHX');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\amgdt.shx');

  //FromDirIterator({sysparam.programpath+'fonts/'}'C:\Program Files\AutoCAD 2010\Fonts\','*.shx','',addf,nil);

  pbasefont:=FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,sysvar.SYS.SYS_AlternateFont^));
  if pbasefont=nil then
  begin
       shared.LogError(format(rsAlternateFontNotFoundIn,[sysvar.SYS.SYS_AlternateFont^,sysvar.PATH.Fonts_Path^]));
       r := LazarusResources.Find(resname);
       if r = nil then
                      shared.FatalError(rsReserveFontNotFound)
                  else
                      begin
                           f.init({$IFDEF DEBUGBUILD}'{94091172-3DD7-4038-99B6-90CD8B8E971D}',{$ENDIF}length(r.Value));
                           f.AddData(@r.Value[1],length(r.Value));
                           f.SaveToFile(sysvar.PATH.Temp_files^+filename);
                           pbasefont:=FontManager.addFonf(sysvar.PATH.Temp_files^+filename);
                           f.done;
                           if pbasefont=nil then
                                                shared.FatalError(rsReserveFontNotLoad);
                      end;
  end;
  FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,'ltypeshp.shx'));


  //pbasefont:=FontManager.getAddres(sysvar.SYS.SYS_AlternateFont^);

  //FontManager.addFonf(sysparam.programpath+'fonts/gewind.shx');
  //FontManager.addFonf('gothice.shx');
  //FontManager.addFonf('romant.shx');

  //pbasefont:=FontManager.getAddres('gewind.shx');
  //pbasefont:=FontManager.{FindFonf}getAddres('amgdt.shx');
  //pbasefont:=FontManager.getAddres('gothice.shx');
  gdb.init;
  SetCurrentDWGProc:=SetCurrentDWG;
  BlockBaseDWG:=gdb.CreateDWG;
  ClipboardDWG:=gdb.CreateDWG;
  //gdb.currentdwg:=BlockBaseDWG;
  GDBTrash.initnul;
end;
procedure finalize;
begin
  gdb.done;
  if BlockBaseDWG<>nil then
  begin
  BlockBaseDWG.done;
  GDBFreemem(pointer(BlockBaseDWG));
  end;
  if ClipboardDWG<>nil then
  begin
  ClipboardDWG.done;
  GDBFreemem(pointer(ClipboardDWG));
  end;
  pbasefont:=nil;
  LTypeManager.FreeAndDone;
  GDBTrash.done;
end;
begin
  {$I gewind.lrs}
  programlog.logoutstr('UGDBDescriptor.startup',lp_IncPos);
  //UGDBDescriptor.startup;
  {$IFDEF DEBUGINITSECTION}LogOut('GDBDescriptor.initialization');{$ENDIF}
  programlog.logoutstr('UGDBDescriptor.startup',lp_DecPos);
end.
