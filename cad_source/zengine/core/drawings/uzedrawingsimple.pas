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

unit uzedrawingsimple;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzedrawingdef,uzeblockdefsfactory,uzestylesdim,gzctnrVectorTypes,
  uzedrawingabstract,uzbstrproc,UGDBObjBlockdefArray,uzestylestables,
  UGDBNumerator,uzeTypes,SysUtils,uzegeometry,uzeentgenericsubentry,
  uzestyleslayers,uzestyleslinetypes,uzeentity,UGDBSelectedObjArray,
  uzestylestexts,uzbUnits,uzegeometrytypes,uzecamera,UGDBOpenArrayOfPV,uzeroot,
  uzefont,uzglviewareaabstract,uzgldrawcontext,UGDBControlPointArray,
  uzglviewareadata,uzeExtdrAbstractDrawingExtender,uzCtnrVectorPBaseEntity;

type
  TMainBlockCreateProc=procedure(_to:PTDrawingDef;Name:string) of object;

  TDrawingActualy=record
    EntityLayers:TActuality;
    procedure CreateDef;
  end;
  PTSimpleDrawing=^TSimpleDrawing;

  TSimpleDrawing=object(TAbstractDrawing)
  type
    TSelector=procedure(PEntity,PGripsCreator:PGDBObjEntity;var SelectedObjCount:integer) of object;
    var
      protected
        //OnMouseObj:GDBObjOpenArrayOfPV;
        internalcamera:boolean;
        pcamera:PGDBObjCamera;
      public
      LastActl:TDrawingActualy;
      pObjRoot:PGDBObjGenericSubEntry;
      mainObjRoot:GDBObjRoot;

      ConstructObjRoot:GDBObjRoot;
      SelObjArray:GDBSelectedObjArray;
      //pcamera:PGDBObjCamera;
      OnMouseObj:GDBObjOpenArrayOfPV;

      wa:TAbstractViewArea;

      Numerator:GDBNumerator;

      DrawingExtensions:TDrawingExtensions;

      {styles}
      BlockDefArray:GDBObjBlockdefArray;
      TextStyleTable:GDBTextStyleArray;
      LayerTable:GDBLayerArray;
      TableStyleTable:GDBTableStyleArray;
      LTypeStyleTable:GDBLtypeArray;
      DimStyleTable:GDBDimStyleArray;

    function GetLastSelected:PGDBObjEntity;virtual;
    constructor init(pcam:PGDBObjCamera);
    destructor done;virtual;
    procedure myGluProject2(objcoord:TzePoint3d;out wincoord:TzePoint3d);virtual;
    procedure myGluUnProject(const win:TzePoint3d;out obj:TzePoint3d);virtual;
    function GetPCamera:PGDBObjCamera;virtual;
    function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;
    function GetCurrentRootSimple:Pointer;virtual;
    function GetCurrentRootObjArraySimple:Pointer;virtual;
    function GetBlockDefArraySimple:Pointer;virtual;
    function GetConstructObjRoot:PGDBObjRoot;virtual;
    function GetConstructEntsCount:integer;virtual;
    function GetSelObjArray:PGDBSelectedObjArray;virtual;
    function GetLayerTable:PGDBLayerArray;virtual;
    function GetLTypeTable:PGDBLtypeArray;virtual;
    function GetTableStyleTable:PGDBTableStyleArray;virtual;
    function GetTextStyleTable:PGDBTextStyleArray;virtual;
    function GetDimStyleTable:PGDBDimStyleArray;virtual;
    function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;
    procedure RotateCameraInLocalCSXY(ux,uy:double);virtual;
    procedure MoveCameraInLocalCSXY(oldx,oldy:double;ax:TzeVector3d);virtual;
    procedure SetCurrentDWG;virtual;
    function StoreOldCamerapPos:Pointer;virtual;
    procedure StoreNewCamerapPos(command:Pointer);virtual;
    procedure rtmodify(obj:PGDBObjEntity;md:Pointer;dist,wc:TzePoint3d;save:boolean);virtual;
    procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:TzePoint3d);virtual;
    procedure PushStartMarker(CommandName:string);virtual;
    procedure PushEndMarker;virtual;
    procedure SetFileName(NewName:string);virtual;
    function GetFileName:string;virtual;
    procedure SetAllChangeStampt;virtual;
    procedure ResetChangeStampt;virtual;abstract;
    procedure ResetChangeFromAutoSaveStampt;virtual;abstract;
    function GetUndoTop:TArrayIndex;virtual;
    function CanUndo:boolean;virtual;
    function CanRedo:boolean;virtual;
    function GetUndoStack:Pointer;virtual;
    function GetDWGUnits:pointer;virtual;
    procedure AssignLTWithFonts(pltp:PGDBLtypeProp);virtual;
    function GetMouseEditorMode:byte;virtual;
    function DefMouseEditorMode(SetMask,ReSetMask:byte):byte;virtual;
    function SetMouseEditorMode(mode:byte):byte;virtual;
    procedure FreeConstructionObjects;virtual;
    function GetChangeStampt:boolean;virtual;
    function GetAutoSavedStampt:boolean;virtual;
    function CreateDrawingRC(_maxdetail:boolean=False;ExcludeOpts:TDContextOptions=[]):TDrawContext;virtual;
    procedure FillDrawingPartRC(var dc:TDrawContext);virtual;
    function GetUnitsFormat:TzeUnitsFormat;virtual;
    procedure CreateBlockDef(Name:string);virtual;
    procedure HardReDraw;
    function GetCurrentLayer:PGDBLayerProp;
    function GetCurrentLType:PGDBLtypeProp;
    function GetCurrentTextStyle:PGDBTextStyle;
    function GetCurrentDimStyle:PGDBDimStyle;
    procedure Selector(PEntity,PGripsCreator:PGDBObjEntity;var SelectedObjCount:integer);
    procedure SelectorWOGrips(PEntity,PGripsCreator:PGDBObjEntity;var SelectedObjCount:integer);
    procedure DeSelector(PV:PGDBObjEntity;var SelectedObjCount:integer);
    procedure DeSelectAll;virtual;
    procedure SelectEnts(constref Ents:TZctnrVectorPGDBaseEntity);
    procedure UpdateActuality;
    procedure LostActuality;
  end;

function CreateSimpleDWG:PTSimpleDrawing;

var
  MainBlockCreateProc:TMainBlockCreateProc=nil;

implementation

procedure TDrawingActualy.CreateDef;
begin;
  EntityLayers:=zeHandles.CreateHandle;
end;

procedure TSimpleDrawing.UpdateActuality;
begin
  if LastActl.EntityLayers<>LayerTable.ActlState then begin
    LastActl.EntityLayers:=LayerTable.ActlState;
    GetCurrentROOT^.CalcActualVisible(TVisActuality.CreateRec(pcamera^.VISCOUNT,pcamera^.POSCOUNT));
  end;
end;

procedure TSimpleDrawing.LostActuality;
begin
  LastActl.CreateDef;
end;

procedure TSimpleDrawing.SelectEnts(constref Ents:TZctnrVectorPGDBaseEntity);
var
  pv:PGDBObjEntity;
  ir:itrec;
  TrueSel:boolean;
  SelProc:TSimpleDrawing.TSelector;
begin
  TrueSel:=Ents.GetRealCount<=sysvarDSGNMaxSelectEntsCountWithGrips;

  if TrueSel then
    SelProc:=Selector
  else
    SelProc:=SelectorWOGrips;

  pv:=Ents.beginiterate(ir);
  if pv<>nil then
    repeat
      pv^.select(wa.param.SelDesc.Selectedobjcount,SelProc);
      pv:=Ents.iterate(ir);
    until pv=nil;
end;

procedure TSimpleDrawing.DeSelectAll;
var
  tdesc:pselectedobjdesc;
  i:integer;
  pv:PGDBObjEntity;
  ir:itrec;
begin
  if SelObjArray.Count<>0 then begin
    tdesc:=SelObjArray.GetParrayAsPointer;
    for i:=0 to SelObjArray.Count-1 do begin
      tdesc.objaddr.selected:=False;
      SelObjArray.freeelement(tdesc);
      Inc(tdesc);
    end;
    SelObjArray.Clear;
  end;
  pv:=GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      pv^.Selected:=False;
      pv:=GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
end;


procedure TSimpleDrawing.SelectorWOGrips(PEntity,PGripsCreator:PGDBObjEntity;var SelectedObjCount:integer);
begin
  SelObjArray.pushobject(PEntity);
  Inc(Selectedobjcount);
end;

procedure TSimpleDrawing.Selector;
var
  tdesc:pselectedobjdesc;
begin
  tdesc:=SelObjArray.addobject(PEntity);
  if tdesc<>nil then
    if PEntity^.IsHaveGRIPS then begin
      Getmem(Pointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
      PGripsCreator^.addcontrolpoints(tdesc);
    end;
  PEntity^.bp.ListPos.Owner.ImSelected(@self,PEntity^.bp.ListPos.SelfIndex);
  Inc(Selectedobjcount);
end;

procedure TSimpleDrawing.DeSelector;
var
  tdesc:pselectedobjdesc;
  ir:itrec;
begin
  tdesc:=SelObjArray.beginiterate(ir);
  if tdesc<>nil then
    repeat
      if tdesc^.objaddr=pv then begin
        SelObjArray.freeelement(tdesc);
        SelObjArray.deleteelementbyp(tdesc);
      end;

      tdesc:=SelObjArray.iterate(ir);
    until tdesc=nil;
  Dec(Selectedobjcount);
end;

function TSimpleDrawing.GetCurrentDimStyle:PGDBDimStyle;
begin
  if CurrentDimStyle<>nil then
    Result:=CurrentDimStyle
  else
    Result:=pointer(DimStyleTable.getDataMutable(0));
end;

function TSimpleDrawing.GetCurrentTextStyle;
begin
  if CurrentTextStyle<>nil then
    Result:=CurrentTextStyle
  else
    Result:=pointer(TextStyleTable.getDataMutable(0));
end;

function TSimpleDrawing.GetCurrentLType;
begin
  if CurrentLType<>nil then
    Result:=CurrentLType
  else
    Result:=pointer(LTypeStyleTable.getDataMutable(0));
end;

function TSimpleDrawing.GetCurrentLayer;
begin
  if CurrentLayer<>nil then
    Result:=CurrentLayer
  else
    Result:=LayerTable.getsystemlayer;
end;

procedure TSimpleDrawing.HardReDraw;
var
  DC:TDrawContext;
  Actlt:TVisActuality;
begin
  DC:=CreateDrawingRC;
  GetCurrentRoot^.FormatAfterEdit(self,dc);
  wa.param.firstdraw:=True;
  wa.CalcOptimalMatrix;
  pcamera^.Counters.totalobj:=0;
  pcamera^.Counters.infrustum:=0;
  Actlt.CreateRec(pcamera^.VISCOUNT,pcamera^.POSCOUNT);
  GetCurrentRoot^.CalcVisibleByTree(pcamera^.frustum,Actlt,GetCurrentROOT^.ObjArray.ObjTree,pcamera^.Counters,myGluProject2,
    pcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  ConstructObjRoot.calcvisible(pcamera^.frustum,Actlt,pcamera^.Counters,myGluProject2,getpcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  wa.calcgrid;
  wa.draworinvalidate;
end;

procedure TSimpleDrawing.CreateBlockDef(Name:string);
var
  td:pointer;
begin
  td:=BlockDefArray.getblockdef(Name);
  if td=nil then begin
    td:=uzeblockdefsfactory.CreateBlockDef(@self,Name);
    if td=nil then begin
      if assigned(MainBlockCreateProc) then
        MainBlockCreateProc(@self,Name);
    end;
  end;
end;

function TSimpleDrawing.GetUnitsFormat:TzeUnitsFormat;
begin
  Result.DeciminalSeparator:=DDSDot;
  Result.abase:=0;
  Result.adir:=ADCounterClockwise;
  Result.aformat:=AUDecimalDegrees;
  Result.aprec:=UPrec2;
  Result.uformat:=LUDecimal;
  Result.uprec:=UPrec2;
  Result.umode:=UMWithSpaces;
  Result.RemoveTrailingZeros:=True;
end;

function TSimpleDrawing.CreateDrawingRC(_maxdetail:boolean=False;ExcludeOpts:TDContextOptions=[]):TDrawContext;
begin
  if assigned(wa) then
    Result:=wa.CreateRC(_maxdetail)
  else begin
    Result:=CreateFaceRC;
    FillDrawingPartRC(Result);
  end;
  Result.Options:=Result.Options-ExcludeOpts;
end;

procedure TSimpleDrawing.FillDrawingPartRC(var dc:TDrawContext);
begin
  dc.DrawingContext.VActuality.VisibleActualy:=Getpcamera.VISCOUNT;
  dc.DrawingContext.VActuality.InfrustumActualy:=Getpcamera.POSCOUNT;
  dc.DrawingContext.DRAWCOUNT:=Getpcamera.DRAWCOUNT;
  dc.DrawingContext.SysLayer:=GetLayerTable.GetSystemLayer;
  dc.DrawingContext.Zoom:=GetPCamera.prop.zoom;
  dc.DrawingContext.matrixs.pmodelMatrix:=@GetPCamera.modelMatrix;
  dc.DrawingContext.matrixs.pprojMatrix:=@GetPCamera.projMatrix;
  dc.DrawingContext.matrixs.pviewport:=@GetPCamera.viewport;
  dc.DrawingContext.pcamera:=GetPCamera;
  dc.DrawingContext.DrawHeplGeometryProc:=nil;
  dc.DrawMode:=LWDisplay;
  dc.DrawingContext.GlobalLTScale:=LTScale;
  dc.DrawingContext.FrustumCenter.HasValue:=False;
end;

function TSimpleDrawing.GetChangeStampt:boolean;
begin
  Result:=False;
end;

function TSimpleDrawing.GetAutoSavedStampt:boolean;
begin
  Result:=True;
end;

procedure TSimpleDrawing.FreeConstructionObjects;
begin
  ConstructObjRoot.ObjArray.Free;
  ConstructObjRoot.ObjCasheArray.Clear;
  ConstructObjRoot.ObjMatrix:=cOneMatrix;
end;

function TSimpleDrawing.GetMouseEditorMode:byte;
begin
  if wa.getviewcontrol<>nil then
    Result:=wa.param.md.mode
  else
    Result:=0;
end;

function TSimpleDrawing.DefMouseEditorMode(SetMask,ReSetMask:byte):byte;
begin
  Result:=GetMouseEditorMode;
  SetMouseEditorMode((Result or setmask) and (not ReSetMask));
end;

function TSimpleDrawing.SetMouseEditorMode(mode:byte):byte;
begin
  if wa.getviewcontrol<>nil then begin
    Result:=wa.param.md.mode;
    wa.param.md.mode:=mode;
  end else
    Result:=0;
end;

procedure TSimpleDrawing.AssignLTWithFonts(pltp:PGDBLtypeProp);
var
  PSP:PShapeProp;
  PTP:PTextProp;
  ir2:itrec;
  pts:pGDBTextStyle;

  procedure createstyle;
  var
    tp:GDBTextStyleProp;
  begin
    tp.oblique:=0;
    tp.size:=1;
    tp.wfactor:=1;
    pts:=TextStyleTable.addstyle(psp.FontName,psp.FontName,psp.FontName,tp,True);
  end;

begin
  PSP:=pltp.shapearray.beginiterate(ir2);
  if PSP<>nil then
    repeat
      pts:=TextStyleTable.FindStyle(psp.FontName,True);
      if pts=nil then
        createstyle;
      PSP^.param.PStyle:=pts;
      if pts^.pfont<>nil then begin
        PSP^.Psymbol:=pts^.pfont.font.findunisymbolinfos(psp.SymbolName);
        PSP^.ShapeNum:=PSP^.Psymbol^.Number;
      end;
      PSP:=pltp.shapearray.iterate(ir2);
    until PSP=nil;
  PTP:=pltp.textarray.beginiterate(ir2);
  if PTP<>nil then
    repeat
      pts:=TextStyleTable.FindStyle(PTP.Style,False);
      if pts=nil then
        pts:=pointer(TextStyleTable.getDataMutable(0));
      PTP^.param.PStyle:=pts;
      PTP:=pltp.textarray.iterate(ir2);
    until PTP=nil;

end;


function TSimpleDrawing.GetDWGUnits:pointer;
begin
  Result:=nil;
end;

function TSimpleDrawing.GetLastSelected:PGDBObjEntity;
begin
  Result:=wa.param.SelDesc.LastSelectedObject;
end;

procedure TSimpleDrawing.SetFileName(NewName:string);
begin

end;

function TSimpleDrawing.GetFileName:string;
begin
  Result:='';
end;

procedure TSimpleDrawing.SetAllChangeStampt;
begin
  inherited;
  if wa.getviewcontrol<>nil then
    wa.param.lastonmouseobject:=nil;
end;

function TSimpleDrawing.GetUndoTop:TArrayIndex;
begin
  Result:=0;
end;

function TSimpleDrawing.GetUndoStack:Pointer;
begin
  Result:=nil;
end;

function TSimpleDrawing.CanUndo:boolean;
begin
  Result:=False;
end;

function TSimpleDrawing.CanRedo:boolean;
begin
  Result:=False;
end;

function CreateSimpleDWG:PTSimpleDrawing;
begin
  Getmem(Pointer(Result),sizeof(TSimpleDrawing));
  Result^.init(nil);
end;

procedure TSimpleDrawing.PushStartMarker(CommandName:string);
begin
end;

procedure TSimpleDrawing.PushEndMarker;
begin
end;

procedure TSimpleDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:TzePoint3d);
begin
  obj^.rtmodifyonepoint(rtmod);
  obj^.YouChanged(self);
end;

procedure TSimpleDrawing.rtmodify(obj:PGDBObjEntity;md:Pointer;dist,wc:TzePoint3d;save:boolean);
var
  i:integer;
  point:pcontrolpointdesc;
  p:Pointer;
  m,mt:TzeTypedMatrix4d;
  t:TzePoint3d;
  rtmod:TRTModifyData;
  dc:TDrawContext;
begin
  if PSelectedObjDesc(md).pcontrolpoint^.Count=0 then
    exit;
  if PSelectedObjDesc(md).ptempobj=nil then begin
    PSelectedObjDesc(md).ptempobj:=obj^.Clone(nil);
    include(PSelectedObjDesc(md).ptempobj^.State,ESConstructProxy);
    PSelectedObjDesc(md).ptempobj^.bp.ListPos.Owner:=obj^.bp.ListPos.Owner;
    dc:=self.CreateDrawingRC;
    PSelectedObjDesc(md).ptempobj.FormatFast(self,dc);
    PSelectedObjDesc(md).ptempobj.BuildGeometry(self);
  end;
  p:=obj^.beforertmodify;
  if save then
    PSelectedObjDesc(md).pcontrolpoint^.SelectedCount:=0;
  point:=PSelectedObjDesc(md).pcontrolpoint^.GetParrayAsPointer;
  for i:=1 to PSelectedObjDesc(md).pcontrolpoint^.Count do begin
    if point.selected then begin
      m:=PSelectedObjDesc(md).objaddr^.getownermatrix^;
      MatrixInvert(m);
      t:=VectorTransform3D(dist,m);
      rtmod.point:=point^;
      t:=point^.worldcoord;
      t:=VectorTransform3D(t,m);
      rtmod.point.worldcoord:=t;
      mt:=m;

      mt.mtr.v[3].v[0]:=0;
      mt.mtr.v[3].v[1]:=0;
      mt.mtr.v[3].v[2]:=0;

      rtmod.dist:=VectorTransform3D(dist,mt);
      rtmod.wc:=VectorTransform3D(wc,m);

      rtmod.point.dcoord:=VectorTransform3D(rtmod.point.dcoord,mt);
      if save then begin
        if obj^.IsRTNeedModify(point,p) then begin
          self.rtmodifyonepoint(obj,rtmod,wc);
        end;
        point.selected:=False;
      end else begin
        if PSelectedObjDesc(md).ptempobj^.IsRTNeedModify(point,p) then begin
          PSelectedObjDesc(md).ptempobj^.SetFromClone(obj);
          PSelectedObjDesc(md).ptempobj^.rtmodifyonepoint(rtmod);
        end;

      end;
    end;
    Inc(point);
  end;
  if save then begin
    PSelectedObjDesc(md).ptempobj^.done;
    Freemem(Pointer(PSelectedObjDesc(md).ptempobj));
    PSelectedObjDesc(md).ptempobj:=nil;
  end else begin
    dc:=self.CreateDrawingRC;
    PSelectedObjDesc(md).ptempobj.FormatFast(self,dc);
    PSelectedObjDesc(md).ptempobj.BuildGeometry(self);
  end;
  obj^.afterrtmodify(p);
end;

function TSimpleDrawing.StoreOldCamerapPos:Pointer;
begin
  Result:=nil;
end;

procedure TSimpleDrawing.StoreNewCamerapPos(command:Pointer);
begin
end;

function TSimpleDrawing.GetOnMouseObj:PGDBObjOpenArrayOfPV;
begin
  Result:=@OnMouseObj;
end;

function TSimpleDrawing.GetLayerTable:PGDBLayerArray;
begin
  Result:=@LayerTable;
end;

function TSimpleDrawing.GetLTypeTable:PGDBLtypeArray;
begin
  Result:=@LTypeStyleTable;
end;

function TSimpleDrawing.GetTableStyleTable:PGDBTableStyleArray;
begin
  Result:=@TableStyleTable;
end;

function TSimpleDrawing.GetTextStyleTable:PGDBTextStyleArray;
begin
  Result:=@TextStyleTable;
end;

function TSimpleDrawing.GetDimStyleTable:PGDBDimStyleArray;
begin
  Result:=@self.DimStyleTable;
end;

procedure TSimpleDrawing.SetCurrentDWG;
begin

end;

procedure TSimpleDrawing.MoveCameraInLocalCSXY(oldx,oldy:double;ax:TzeVector3d);
var
  uc:pointer;
begin
  uc:=StoreOldCamerapPos;
  GetPCamera.moveInLocalCSXY(oldx,oldy,ax);
  StoreNewCamerapPos(uc);
end;

procedure TSimpleDrawing.RotateCameraInLocalCSXY(ux,uy:double);
var
  uc:pointer;
begin
  uc:=StoreOldCamerapPos;
  GetPCamera.RotateInLocalCSXY(ux,uy);
  StoreNewCamerapPos(uc);
end;

function TSimpleDrawing.GetSelObjArray:PGDBSelectedObjArray;
begin
  Result:=@SelObjArray;
end;

function TSimpleDrawing.GetConstructObjRoot:PGDBObjRoot;
begin
  Result:=@ConstructObjRoot;
end;

function TSimpleDrawing.GetConstructEntsCount:integer;
var
  pr:PGDBObjRoot;
begin
  pr:=GetConstructObjRoot;
  if pr<>nil then
    Result:=pr^.ObjArray.Count
  else
    Result:=0;
end;

function TSimpleDrawing.GetCurrentRootSimple:Pointer;
begin
  Result:=self.pObjRoot;
end;

function TSimpleDrawing.GetCurrentRootObjArraySimple:Pointer;
begin
  Result:=@pObjRoot.ObjArray;
end;

function TSimpleDrawing.GetBlockDefArraySimple:Pointer;
begin
  Result:=@self.BlockDefArray;
end;

function TSimpleDrawing.GetCurrentROOT:PGDBObjGenericSubEntry;
begin
  Result:=self.pObjRoot;
end;

function TSimpleDrawing.GetPCamera:PGDBObjCamera;
begin
  Result:=pcamera;
end;

procedure TSimpleDrawing.myGluProject2;
begin
  objcoord:=objcoord+pcamera^.CamCSOffset;
  _myGluProject(objcoord.x,objcoord.y,objcoord.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport,wincoord.x,wincoord.y,wincoord.z);
end;

procedure TSimpleDrawing.myGluUnProject(const win:TzePoint3d;out obj:TzePoint3d);
begin
  _myGluUnProject(win.x,win.y,win.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport,obj.x,obj.y,obj.z);
  OBJ:=OBJ-pcamera^.CamCSOffset;
end;

destructor TSimpleDrawing.done;
begin
  mainObjRoot.done;
  LayerTable.Done;
  ConstructObjRoot.done;
  SelObjArray.Done;
  OnMouseObj.Clear;
  OnMouseObj.Done;
  TextStyleTable.Done;
  BlockDefArray.Done;
  Numerator.Done;
  TableStyleTable.Done;
  LTypeStyleTable.Done;
  DimStyleTable.Done;
  if internalcamera then
    if assigned(pcamera) then begin
      pcamera^.done;
      Freemem(pointer(pcamera));
    end;
  DrawingExtensions.Free;
end;

constructor TSimpleDrawing.init;
var
  ts:PTGDBTableStyle;
  cs:TGDBTableCellStyle;
begin
  inherited init;

  LastActl.CreateDef;
  pcamera:=pcam;
  internalcamera:=False;
  if pcamera=nil then begin
    Getmem(pointer(pcamera),sizeof(GDBObjCamera));
    pcamera^.initnul;
    internalcamera:=True;

    pcamera.fovy:=35.0;
    pcamera.prop.point.x:=0.0;
    pcamera.prop.point.y:=0.0;
    pcamera.prop.point.z:=50.0;
    pcamera.prop.look.x:=0.0;
    pcamera.prop.look.y:=0.0;
    pcamera.prop.look.z:=-1.0;
    pcamera.prop.ydir.x:=0.0;
    pcamera.prop.ydir.y:=1.0;
    pcamera.prop.ydir.z:=0.0;
    pcamera.prop.xdir.x:=-1.0;
    pcamera.prop.xdir.y:=0.0;
    pcamera.prop.xdir.z:=0.0;
    pcamera.prop.zoom:=0.1;
    pcamera.anglx:=-3.14159265359;
    pcamera.angly:=-1.570796326795;
    pcamera.zmin:=1.0;
    pcamera.zmax:=100000.0;
    pcamera.fovy:=35.0;
  end;
  LTypeStyleTable.init(100);
  LayerTable.init(200,LTypeStyleTable.GetSystemLT(TLTContinous));
  DimStyleTable.init(100);
  mainobjroot.initnul;
  mainobjroot.vp.Layer:=LayerTable.GetSystemLayer;
  pObjRoot:=@mainobjroot;
  ConstructObjRoot.initnul;
  ConstructObjRoot.vp.Layer:=LayerTable.GetSystemLayer;
  SelObjArray.init(65535);
  OnMouseObj.init(20);

  TextStyleTable.init(200);

  BlockDefArray.init(100);
  Numerator.init(10);

  TableStyleTable.init(10);

  PTempTableStyle:=TableStyleTable.AddStyle('Temp');

  PTempTableStyle.rowheight:=4;
  PTempTableStyle.textheight:=2.5;

  cs.Width:=1;
  cs.TextWidth:=0;
  cs.CF:=TTableCellJustify.jcc;
  PTempTableStyle.tblformat.PushBackData(cs);

  ts:=TableStyleTable.AddStyle('Standart');

  ts.rowheight:=4;
  ts.textheight:=2.5;

  cs.Width:=20;
  cs.TextWidth:=0;
  cs.CF:=jcc;
  ts.tblformat.PushBackData(cs);

  ts:=TableStyleTable.AddStyle('Spec');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_SPEC_HEAD';

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=130;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=60;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=35;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=45;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=25;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=40;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  ts:=TableStyleTable.AddStyle('ShRaspr');

  ts.rowheight:=10;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_PSRS_HEAD';

  cs.Width:=25;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=33;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=5;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=33;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=5;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=5;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=17;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=13;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=25;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=13;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=23;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=13;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=16;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=12;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=12;
  cs.TextWidth:=cs.Width-2;
  cs.cf:={TCellJustify.}jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=35;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);



  ts:=TableStyleTable.AddStyle('PE');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_PE_HEAD';

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=110;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);

  cs.Width:=10;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=45;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcl;
  ts.tblformat.PushBackData(cs);


  ts:=TableStyleTable.AddStyle('KZ');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_KZ_HEAD';

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=46;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=46;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=20;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-1;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=40;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=25;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  cs.Width:=15;
  cs.TextWidth:=cs.Width-2;
  cs.cf:=jcc;
  ts.tblformat.PushBackData(cs);

  DrawingExtensions:=TDrawingExtensions.Create;

end;

end.
