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

unit uzcdrawings;
{$INCLUDE def.inc}
interface
uses
    uzglviewareageneral,uzctranslations,uzedimblocksregister,uzeblockdefsfactory,
    zemathutils,uzgldrawcontext,uzedrawing,uzedrawingdef,paths,uzestylesdim,
    uzedrawingabstract,WindowsSpecific,LResources,uzcsysvars,zcadinterface,
    uzcstrconsts,strproc,uzeblockdef,UGDBObjBlockdefArray,UUnitManager,
    gdbase,varmandef,varman,sysutils,memman,geometry,uzeconsts,
    gdbasetypes,uzedrawingsimple,uzeentgenericsubentry,uzestyleslayers,uzeentity,
    UGDBSelectedObjArray,uzestylestexts,uzefontmanager,uzestyleslinetypes,
    UGDBOpenArrayOfPV,uzefont,UGDBOpenArrayOfPObjects,UGDBVisibleOpenArray,
    uzetrash,UGDBOpenArrayOfByte,uzglviewareadata;
type
{REGISTEROBJECTTYPE GDBDescriptor}
{EXPORT+}
TDWGProps=packed record
                Name:GDBString;
                Number:GDBInteger;
          end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                    CurrentDWG:{PTDrawing}PTSimpleDrawing;
                    ProjectUnits:TUnitManager;
                    FileNameCounter:integer;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;
                    //function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;

                    function GetCurrentROOT:PGDBObjGenericSubEntry;

                    function GetCurrentDWG:{PTDrawing}PTSimpleDrawing;
                    function GetCurrentOGLWParam:POGLWndtype;
                    function GetUndoStack:GDBPointer;
                    procedure asociatedwgvars;
                    procedure freedwgvars;
                    procedure SetCurrentDWG(PDWG:PTAbstractDrawing);

                    function CreateDWG(preloadedfile1,preloadedfile2:GDBString):PTDrawing;
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
                    //procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
                    function GetDefaultDrawingName:GDBString;
                    function FindDrawingByName(DWGName:GDBString):PTSimpleDrawing;
                    function GetUnitsFormat:TzeUnitsFormat;
                    procedure SetUnitsFormat(f:TzeUnitsFormat);
              end;
{EXPORT-}
var GDB: GDBDescriptor;
    BlockBaseDWG:{PTDrawing}PTSimpleDrawing=nil;
    ClipboardDWG:{PTDrawing}PTSimpleDrawing=nil;
    //GDBTrash:GDBObjTrash;
    LtypeManager:GDBLtypeArray;
procedure CalcZ(z:GDBDouble);
procedure RemapAll(_from,_to:PTSimpleDrawing;_source,_dest:PGDBObjEntity);
procedure startup(preloadedfile1,preloadedfile2:GDBString);
procedure finalize;
procedure SetObjCreateManipulator(out domethod,undomethod:tmethod);
procedure clearotrack;
procedure clearcp;
procedure redrawoglwnd;
function dwgSaveDXFDPAS(s:gdbstring;dwg:PTSimpleDrawing):GDBInteger;
function dwgQSave_com(dwg:PTSimpleDrawing):GDBInteger;
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses uzcenitiesvariablesextender,uzeenttext,uzeentdevice,uzeentblockinsert,uzeffdxf, uzcutils,uzcshared,uzccommandsmanager;
function GDBDescriptor.GetDefaultDrawingName:GDBString;
var
    OldName:GDBString;
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
function GDBDescriptor.GetUnitsFormat:TzeUnitsFormat;
begin
     result.DeciminalSeparator:=DDSDot;
     if CurrentDWG<>nil then
                            result:=CurrentDWG.GetUnitsFormat
                        else
                            result:=CreateDefaultUnitsFormat;
end;
procedure GDBDescriptor.SetUnitsFormat(f:TzeUnitsFormat);
begin
     if CurrentDWG<>nil then
                            CurrentDWG.SetUnitsFormat(f);
end;
function GDBDescriptor.FindDrawingByName(DWGName:GDBString):PTSimpleDrawing;
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
 {procedure GDBDescriptor.AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
 var
     domethod,undomethod:tmethod;
 begin
      SetObjCreateManipulator(domethod,undomethod);
      with PTDrawing(GetCurrentDWG)^.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
      begin
           AddObject(PEnt);
           comit;
      end;
 end;}

 function dwgSaveDXFDPAS(s:gdbstring;dwg:PTSimpleDrawing):GDBInteger;
 var
    mem:GDBOpenArrayOfByte;
    pu:ptunit;
    allok:boolean;
 begin
      allok:=savedxf2000(s,dwg^);
      pu:=PTDrawing(dwg).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
      mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
      pu^.SavePasToMem(mem);
      mem.SaveToFile(expandpath(s+'.dbpas'));
      mem.done;
      if allok then
                   result:=cmd_ok
               else
                   result:=cmd_error;
 end;
 function dwgQSave_com(dwg:PTSimpleDrawing):GDBInteger;
 var s1:GDBString;
 begin
      begin
           if dwg.GetFileName=rsUnnamedWindowTitle then
           begin
                s1:='';
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
   DC:TDrawContext;
begin
  //isOpenGLError;
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  begin
       DC:=pdwg^.CreateDrawingRC;
       gdb.GetCurrentRoot.FormatAfterEdit(pdwg^,dc);
  pdwg.wa.param.firstdraw := TRUE;
  pdwg.wa.CalcOptimalMatrix;
  pdwg.pcamera^.totalobj:=0;
  pdwg.pcamera^.infrustum:=0;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentROOT.ObjArray.ObjTree,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg^.myGluProject2,pdwg.pcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,pdwg.pcamera^.totalobj,pdwg.pcamera^.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  pdwg.wa.calcgrid;
  pdwg.wa.draworinvalidate;
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
       pdwg.wa.param.lastonmouseobject:=nil;
  end;
end;


procedure clearotrack;
begin
     gdb.GetCurrentDWG.wa.param.ontrackarray.current:=0;
     gdb.GetCurrentDWG.wa.param.ontrackarray.total:=0;
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
function GDBDescriptor.GetCurrentOGLWParam:POGLWndtype;
begin
     if currentdwg<>nil then
                            begin
                                 if currentdwg^.wa.getviewcontrol<>nil then
                                                                    result:=@currentdwg^.wa.param
                                                                else
                                                                    result:=nil;
                            end
                        else
                            result:=nil;
end;

function GDBDescriptor.GetCurrentDWG;
begin
 result:=CurrentDWG;
end;
function GDBDescriptor.GetUndoStack:GDBPointer;
var
   pdwg:PTSimpleDrawing;
begin
     pdwg:=GetCurrentDWG;
     if pdwg<>nil then
                      result:=pdwg.GetUndoStack
                  else
                      result:=nil;
end;

procedure GDBDescriptor.asociatedwgvars;
begin
   { TODO : переделать }
   if typeof(CurrentDWG^)=typeof(TDrawing) then
   begin
   DWGUnit:=PTDrawing(CurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,'DrawingVars');
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
procedure GDBDescriptor.eraseobj(ObjAddr:PGDBaseObject);
begin
     inherited eraseobj(objaddr);
     if objaddr=pointer(CurrentDWG) then
                                        begin
                                             CurrentDWG:=nil;
                                             DWGUnit:=nil;
                                        end;

end;
function GDBDescriptor.CreateDWG(preloadedfile1,preloadedfile2:GDBString):PTDrawing;
var
   ptd:PTsimpleDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TDrawing));
     ptd:=currentdwg;
     currentdwg:=result;
     result^.init(@units,preloadedfile1,preloadedfile2);
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
var
   DC:TDrawContext;
begin
  inherited init({$IFDEF DEBUGBUILD}'{F5A454F1-CB6B-43AA-AD8D-AF3B9D781ED0}',{$ENDIF}100);
  FileNameCounter:=0;
  ProjectUnits.init;
  ProjectUnits.SetNextManager(@units);

  CurrentDWG:=nil;
  //gdBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(CurrentDWG),sizeof(TDrawing));
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
end;
constructor GDBDescriptor.initnul;
//var tp:GDBTextStyleProp;
begin
  //Pointer(FileName):=nil;
  //Changed:=True;
  { TODO : переделать }
  FileNameCounter:=0;
  if typeof(CurrentDWG^)=typeof(TDrawing) then
  begin
  PTDrawing(CurrentDWG).DWGUnits.init;
  end;
  //CurrentDWG.DWGUnits.init;
  inherited initnul;
end;
(*function GDBDescriptor.AfterDeSerialize;
begin
     CurrentDWG.pcamera:=SysUnit.InterfaceVariables.findvardesc('camera').data.Instance;
     //CurrentDWG.ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-56klhj2D-4B17-A33A-61CF3F5F2A90}',{$ENDIF}65535);
     CurrentDWG.ConstructObjRoot.initnul;
     CurrentDWG.SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FkjhB5-BFB1-8791C261C577}',{$ENDIF}65535);
     CurrentDWG.OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-427длро2-B429-4D134913BC26}',{$ENDIF}100);
     //BlockDefArray.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-fgjhfgh9-AF2E-D1AB116B5737}',{$ENDIF}1000);
end;*)
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
          if td=nil then
                        begin
                             td:=CreateBlockDef(_to,name);
                             if td=nil  then
                                            td:=BlockBaseDWG.BlockDefArray.getblockdef(name)
                                        else
                                            exit;
                        end;
          if td=nil then
                        begin
                          exit;
                          uzcshared.FatalError(sysutils.format('Block "%s" not found! If this dimension arrow block - manually creating block not implemented yet((',[name]));
                        end;
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
   pentvarext:PTVariablesExtender;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pentvarext:=pvisible^.GetExtension(typeof(TVariablesExtender));
                    pvd:=pentvarext^.entityunit.FindVariable(vname);
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
   pentvarext:PTVariablesExtender;
begin
     croot:=self.GetCurrentROOT;
     if croot<>nil then
     begin
         pvisible:=croot.ObjArray.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pentvarext:=pvisible^.GetExtension(typeof(TVariablesExtender));
                    pvd:=pentvarext^.entityunit.FindVariable(vname);
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
   pentvarext:PTVariablesExtender;
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
                    pentvarext:=pvisible^.GetExtension(typeof(TVariablesExtender));
                    pvd:=pentvarext^.entityunit.FindVariable(vname);
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
   _dest:PGDBObjBlockdef;
   ir:itrec;
   pvisible,pvisible2:PGDBObjEntity;
   DC:TDrawContext;
   psourcevarext,pdestvarext:PTVariablesExtender;
begin
      if pos(DevicePrefix,_source.Name)=1 then
                                         CopyBlock(_from,_to,_from.BlockDefArray.getblockdef(copy(_source.Name,8,length(_source.Name)-7)));

     _dest:=_to.BlockDefArray.create(_source.Name);
     _dest.VarFromFile:='';
     _dest.Base:=_source.Base;
     _dest.BlockDesc:=_source.BlockDesc;

     psourcevarext:=_source^.GetExtension(typeof(TVariablesExtender));
     pdestvarext:=_dest^.GetExtension(typeof(TVariablesExtender));
     if (psourcevarext<>nil)and(pdestvarext<>nil)then
     psourcevarext^.entityunit.CopyTo(@pdestvarext^.entityunit);

     dc:=_to^.CreateDrawingRC;

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
                                          _dest.ObjArray.add(@pvisible2);
                                     end;
          pvisible:=_source.ObjArray.iterate(ir);
     until pvisible=nil;


     _dest.formatentity(_to^,dc);
end;
procedure addf(fn:gdbstring);
begin
     FontManager.addFonf(fn);
end;

procedure startup(preloadedfile1,preloadedfile2:GDBString);
var
   r: TLResource;
   f:GDBOpenArrayOfByte;
   pds:PGDBDimStyle;
const
   resname='GEWIND';
   filename='GEWIND.SHX';
begin
  RedrawOGLWNDProc:=RedrawOGLWND;
  ResetOGLWNDProc:=ResetOGLWND;

  LTypeManager.init({$IFDEF DEBUGBUILD}'{9D0E081C-796F-4EB1-98A9-8B6EA9BD8640}',{$ENDIF}100);

  LTypeManager.LoadFromFile(FindInPaths(SupportPath,'zcad.lin'),TLOLoad);

  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\times.shx');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\GENISO.SHX');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\amgdt.shx');

  //FromDirIterator({sysparam.programpath+'fonts/'}'C:\Program Files\AutoCAD 2010\Fonts\','*.shx','',addf,nil);

  FontManager.CreateBaseFont;
  FontManager.addFonf(FindInPaths(sysvarPATHFontsPath,'ltypeshp.shx'));


  //pbasefont:=FontManager.getAddres(sysvar.SYS.SYS_AlternateFont^);

  //FontManager.addFonf(sysparam.programpath+'fonts/gewind.shx');
  //FontManager.addFonf('gothice.shx');
  //FontManager.addFonf('romant.shx');

  //pbasefont:=FontManager.getAddres('gewind.shx');
  //pbasefont:=FontManager.{FindFonf}getAddres('amgdt.shx');
  //pbasefont:=FontManager.getAddres('gothice.shx');
  gdb.init;
  SetCurrentDWGProc:=SetCurrentDWG;
  BlockBaseDWG:=gdb.CreateDWG('','');
  _GetUndoStack:=gdb.GetUndoStack;
  ClipboardDWG:=gdb.CreateDWG(preloadedfile1,preloadedfile2);
  ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
  pds.init('Standart');
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
end.
