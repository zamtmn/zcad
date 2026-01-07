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

unit uzeentity;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzepalette,uzeobjectextender,uzgldrawerabstract,uzgldrawcontext,uzedrawingdef,
  uzecamera,uzeentitiesprop,uzestyleslinetypes,uzegeometrytypes,
  UGDBControlPointArray,uzeentsubordinated,uzbtypes,uzeTypes,uzeconsts,
  uzglviewareadata,uzegeometry,uzeffdxfsupport,SysUtils,uzctnrVectorBytesStream,
  uzestyleslayers,uzeenrepresentation,uzbLogIntf,uzMVReader,
  uzCtnrVectorpBaseEntity,uzbBaseUtils;

type
  taddotrac=procedure(var posr:os_record;const axis:TzePoint3d) of object;
  TEFStage=(EFCalcEntityCS,EFDraw);
  TEFStages=set of TEFStage;

const
  EFAllStages=[EFCalcEntityCS,EFDraw];

type
  PGDBObjEntity=^GDBObjEntity;
  TSelect2Stage=procedure(PEntity,PGripsCreator:PGDBObjEntity;
    var SelectedObjCount:integer) of object;
  TDeSelect2Stage=procedure(PV:PGDBObjEntity;var SelectedObjCount:integer) of object;
  TEntityState=(ESCalcWithoutOwner,ESTemp,ESConstructProxy);
  TEntityStates=set of TEntityState;
  PTExtAttrib=^TExtAttrib;

  TExtAttrib=record
    OwnerHandle:QWord;
    MainFunctionHandle:QWord;
    dwgHandle:QWord;
    Handle:QWord;
    Upgrade:TEntUpgradeInfo;
    ExtAttrib2:boolean;
  end;

  GDBObjEntity=object(GDBObjSubordinated)
    {-}protected{//}
    //fInfrustum:TActuality;
    {-}public{//}
    vp:GDBObjVisualProp;
    Selected:boolean;
    Visible:TActuality;
    PExtAttrib:PTExtAttrib;
    Representation:TZEntityRepresentation;
    State:TEntityStates;
    {-}protected{//}
    function GetInfrustumFromTree:TActuality;virtual;
    {-}public{//}
    destructor done;virtual;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure SaveToDXFObjPrefix(
      var outStream:TZctnrVectorBytes;entname,dbname:string;
      var IODXFContext:TIODXFSaveContext;notprocessHandle:boolean=False);
    function LoadFromDXFObjShared(
      var rdr:TZMemReader;DXFCode:integer;ptu:PExtensionData;var drawing:TDrawingDef;
      var context:TIODXFLoadContext):boolean;
    function ProcessFromDXFObjXData(
      const _Name,_Value:string;ptu:PExtensionData;const drawing:TDrawingDef):boolean;virtual;
    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
      const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
    procedure FromDXFPostProcessAfterAdd;virtual;
    procedure postload(var context:TIODXFLoadContext);virtual;
    procedure createfield;virtual;
    function AddExtAttrib:PTExtAttrib;
    function CopyExtAttrib:PTExtAttrib;
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;abstract;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DXFOut(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFfollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFPostProcess(var outStream:TZctnrVectorBytes;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;
      var IODXFContext:TIODXFSaveContext);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure FormatFeatures(var drawing:TDrawingDef);virtual;
    procedure FormatFast(var drawing:TDrawingDef;
      var DC:TDrawContext);virtual;
    procedure FormatAfterEdit(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
      virtual;
    procedure DrawWithAttrib(var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure DrawWithOutAttrib(var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function CalculateLineWeight(const DC:TDrawContext):integer;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure SetFromClone(_clone:PGDBObjEntity);virtual;
    function CalcOwner(own:Pointer):Pointer;virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);
      virtual;abstract;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure getonlyoutbound(var DC:TDrawContext);virtual;
    function getonlyvisibleoutbound(
      var DC:TDrawContext):TBoundingBox;virtual;
    procedure correctbb(var DC:TDrawContext);virtual;
    function GetLTCorrectH(GlobalLTScale:double):double;virtual;
    function GetLTCorrectL(GlobalLTScale:double):double;virtual;
    procedure calcbb(var DC:TDrawContext);virtual;
    procedure DrawBB(var DC:TDrawContext);
    function calcvisible(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    function isonmouse(var popa:TZctnrVectorPGDBaseEntity;
      const mousefrustum:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure endsnap(out osp:os_record;var pdata:Pointer);virtual;
    function getintersect(var osp:os_record;pobj:PGDBObjEntity;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure higlight(var DC:TDrawContext);virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;abstract;
    function select(var SelectedObjCount:integer;
      s2s:TSelect2Stage):boolean;virtual;
    procedure DeSelect(var SelectedObjCount:integer;
      ds2s:TDeSelect2Stage);virtual;
    function SelectQuik:boolean;virtual;
    procedure remapcontrolpoints(pp:PGDBControlPointArray;
      pcount:TActuality;ScrollMode:boolean;var camera:GDBObjCamera;ProjectProc:GDBProjectProc;
      var DC:TDrawContext);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);
      virtual;abstract;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure remaponecontrolpoint(pdesc:PControlPointDesc;
      ProjectProc:GDBProjectProc);virtual;abstract;
    function beforertmodify:Pointer;virtual;
    procedure afterrtmodify(p:Pointer);virtual;
    function IsRTNeedModify(const Point:PControlPointDesc;
      p:Pointer):boolean;virtual;
    procedure clearrtmodify(p:Pointer);virtual;
    function getowner:PGDBObjSubordinated;virtual;
    function GetMainOwner:PGDBObjSubordinated;virtual;
    function getmatrix:PzeTypedMatrix4d;virtual;
    function getownermatrix:PzeTypedMatrix4d;virtual;
    function ObjToString(const prefix,sufix:string):string;virtual;
    function ReturnLastOnMouse(InSubEntry:boolean):PGDBObjEntity;virtual;
    procedure YouDeleted(var drawing:TDrawingDef);virtual;
    procedure YouChanged(var drawing:TDrawingDef);virtual;
    function GetObjTypeName:string;virtual;
    function GetObjType:TObjID;virtual;
    procedure correctobjects(powner:PGDBObjEntity;
      pinownerarray:integer);virtual;
    function GetLineWeight:smallint;inline;
    function IsSelected:boolean;virtual;
    function IsActualy:boolean;virtual;
    function IsHaveLCS:boolean;virtual;
    function IsHaveGRIPS:boolean;virtual;
    function GetLayer:PGDBLayerProp;virtual;
    function GetCenterPoint:TzePoint3d;virtual;
    procedure SetInFrustum(infrustumactualy:TActuality;
      var Counters:TCameraCounters);virtual;
    procedure SetInFrustumFromTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;
    function CalcActualVisible(
      const Actuality:TVisActuality):boolean;virtual;
    procedure SetNotInFrustum(infrustumactualy:TActuality;
      var Counters:TCameraCounters);virtual;
    function CalcInFrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    function IsIntersect_Line(lbegin,lend:TzePoint3d):Intercept3DProp;
      virtual;
    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function CalcObjMatrixWithoutOwner:TzeTypedMatrix4d;virtual;
    procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:integer;
      var drawing:TDrawingDef);virtual;
    function GetTangentInPoint(const point:TzePoint3d):TzePoint3d;virtual;
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
    procedure ReCalcFromObjMatrix;virtual;
    procedure correctsublayers(var la:GDBLayerArray);virtual;
    procedure CopyVPto(var toObj:GDBObjEntity);virtual;
    function CanSimplyDrawInWCS(const DC:TDrawContext;
      const ParamSize,TargetSize:double):boolean;inline;
    function SqrCanSimplyDrawInWCS(const DC:TDrawContext;
      const ParamSize,TargetSize:double):boolean;//inline;
    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;
      var DC:TDrawContext);virtual;
    procedure IterateCounter(PCounted:Pointer;
      var Counter:integer;proc:TProcCounter);virtual;
    class function GetDXFIOFeatures:TDXFEntIODataManager;static;
    function GetNameInBlockTable:string;virtual;
    procedure addtoconnect2(pobj:pgdbobjEntity;
      var ConnectedArray:TZctnrVectorPGDBaseEntity);
    function CheckState(AStates:TEntityStates):boolean;
    function GetObjName:string;virtual;
    {-} property infrustum:TActuality
      read GetInfrustumFromTree{ write fInfrustum};{//}
  end;

var
  onlygetsnapcount:integer;
  GDBObjEntityDXFFeatures:TDXFEntIODataManager;

implementation

uses usimplegenerics,uzeentityfactory,uzeentitiestree;

function GDBObjEntity.GetInfrustumFromTree:TActuality;
begin
  if bp.TreePos.Owner=nil then begin
    if bp.ListPos.Owner=nil then
      Result:=0
    else
      Result:=pgdbobjEntity(bp.ListPos.Owner).infrustum;
  end else
    Result:=PTEntTreeNode(bp.TreePos.Owner)^.NodeData.infrustum;
end;

function GDBObjEntity.GetObjName:string;
begin
  Result:='entity';
end;

function GDBObjEntity.CheckState(AStates:TEntityStates):boolean;
begin
  Result:=(AStates*State)<>[];
  if not Result then
    if bp.ListPos.Owner<>nil then
      if IsObjectIt(typeof(bp.ListPos.Owner^),typeof(GDBObjEntity)) then
        Result:=PGDBObjEntity(bp.ListPos.Owner)^.CheckState(AStates);
end;

procedure GDBObjEntity.addtoconnect2(pobj:pgdbobjEntity;
  var ConnectedArray:TZctnrVectorPGDBaseEntity);
begin
  ConnectedArray.PushBackIfNotPresent(pobj);
end;

procedure GDBObjEntity.IterateCounter(PCounted:Pointer;
  var Counter:integer;proc:TProcCounter);
begin
  proc(@self,PCounted,Counter);
end;

function GDBObjEntity.GetNameInBlockTable:string;
begin
  Result:='';
end;

procedure GDBObjEntity.FormatAfterDXFLoad;
begin
  //format;
  CalcObjMatrix;
  CalcGeometry;
  calcbb(dc);
end;

function GDBObjEntity.CanSimplyDrawInWCS(const DC:TDrawContext;
  const ParamSize,TargetSize:double):boolean;
var
  templod:double;
begin
  if dc.maxdetail then
    exit(True);
  templod:=(ParamSize)/(dc.DrawingContext.zoom);
  if templod>TargetSize then
    exit(True)
  else
    exit(False);
end;

function GDBObjEntity.SqrCanSimplyDrawInWCS(const DC:TDrawContext;
  const ParamSize,TargetSize:double):boolean;
var
  templod:double;
begin
  if dc.maxdetail then
    exit(True);
  templod:=(ParamSize)/(dc.DrawingContext.zoom*dc.DrawingContext.zoom);
  if templod>TargetSize then
    exit(True)
  else
    exit(False);
end;


procedure GDBObjEntity.CopyVPto(var toObj:GDBObjEntity);
begin
  toObj.OSnapModeControl:=OSnapModeControl;
  toObj.vp.LineType:=vp.LineType;
  toObj.vp.LineTypeScale:=vp.LineTypeScale;
  toObj.vp.color:=vp.color;
  toObj.vp.Layer:=vp.Layer;
  toObj.vp.LineWeight:=vp.LineWeight;
end;

procedure GDBObjEntity.correctsublayers(var la:GDBLayerArray);
begin

end;

function GDBObjEntity.IsHaveGRIPS:boolean;
begin
  Result:=True;
end;

procedure GDBObjEntity.ReCalcFromObjMatrix;
begin

end;

procedure GDBObjEntity.CalcObjMatrix;
begin

end;

procedure GDBObjEntity.EraseMi(pobj:pGDBObjEntity;pobjinarray:integer;
  var drawing:TDrawingDef);
begin

end;

function GDBObjEntity.GetTangentInPoint(const point:TzePoint3d):TzePoint3d;
begin
  Result:=nulvertex;
end;

function GDBObjEntity.IsHaveLCS:boolean;
begin
  Result:=False;
end;

function GDBObjEntity.CalcObjMatrixWithoutOwner:TzeTypedMatrix4d;
begin
  Result:=onematrix;
end;

procedure GDBObjEntity.SetInFrustumFromTree;
begin
end;

function GDBObjEntity.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  oldValue:TActuality;
begin
  oldValue:=Visible;
  if (self.vp.Layer._on) then
    Visible:=Actuality.visibleactualy
  else
    Visible:=0;
  Result:=oldValue<>Visible;
end;

procedure GDBObjEntity.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin

end;

procedure GDBObjEntity.BuildGeometry;
begin

end;

function GDBObjEntity.IsIntersect_Line(lbegin,lend:TzePoint3d):Intercept3DProp;
begin
  Result.isintercept:=False;
end;

procedure GDBObjEntity.createfield;
begin
  inherited;
  Selected:=False;
  self.Visible:=0;
  vp.lineweight:=-1;
  vp.LineType:={''}nil;
  vp.LineTypeScale:=1;

     {if gdb.GetCurrentDWG<>nil then
                                   vp.layer:=gdb.GetCurrentDWG.LayerTable.GetSystemLayer
                               else
                                   vp.layer:=nil;}
  vp.layer:=@DefaultErrorLayer;
  self.PExtAttrib:=nil;
  vp.LastCameraPos:=NotActual;
  vp.color:=ClByLayer;
  State:=[];
end;

function GDBObjEntity.CalcOwner(own:Pointer):Pointer;
begin
  if own=nil then
    Result:=bp.ListPos.owner
  else
    Result:=own;
end;

procedure GDBObjEntity.DrawBB;
begin
  if DC.SystmGeometryDraw then begin
    dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
    dc.drawer.DrawAABB3DInModelSpace(vp.BoundingBox,dc.DrawingContext.matrixs);
  end;
end;

function GDBObjEntity.GetCenterPoint;
begin
  Result:=nulvertex;
end;

procedure GDBObjEntity.FromDXFPostProcessAfterAdd;
begin
end;

procedure GDBObjEntity.postload(var context:TIODXFLoadContext);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunPostload(context);
end;

function GDBObjEntity.FromDXFPostProcessBeforeAdd;
var
  EntUpgradeKey:TEntUpgradeKey;
  EntUpgradeData:TEntUpgradeData;
begin
  Result:=nil;
  if self.PExtAttrib<>nil then
    if self.PExtAttrib^.Upgrade>0 then begin
      EntUpgradeKey.EntityID:={vp.ID}GetObjType;
      EntUpgradeKey.UprradeInfo:=self.PExtAttrib^.Upgrade;
      if EntUpgradeKey2EntUpgradeData.MyGetValue(EntUpgradeKey,EntUpgradeData) then
        if assigned(EntUpgradeData.EntityUpgradeFunc) then
          Result:=EntUpgradeData.EntityUpgradeFunc(ptu,@self,drawing);
    end;
end;

function GDBObjEntity.AddExtAttrib;
begin
  if PExtAttrib=nil then begin
    Getmem(Pointer(PExtAttrib),sizeof(TExtAttrib));
    fillchar(PExtAttrib^,sizeof(TExtAttrib),0);
    PExtAttrib^.ExtAttrib2:=False;
  end;
  Result:=PExtAttrib;
end;

function GDBObjEntity.CopyExtAttrib;
begin
  if PExtAttrib<>nil then begin
    Getmem(Pointer(Result),sizeof(TExtAttrib));
    fillchar(Result^,sizeof(TExtAttrib),0);
    Result^:=PExtAttrib^;
  end else
    Result:=nil;
end;

function GDBObjEntity.GetLineWeight;
begin
  Result:=vp.LineWeight;
end;

function GDBObjEntity.GetLayer;
begin
  Result:=vp.Layer;
end;

function GDBObjEntity.IsSelected;
begin
  //result:=selected;
  if selected then
    Result:=selected
  else begin
    if bp.ListPos.owner<>nil then
      Result:=bp.ListPos.owner.IsSelected
    else
      Result:=False;
  end;
end;

procedure GDBObjEntity.correctobjects;
begin
  bp.ListPos.Owner:=powner;
  bp.ListPos.SelfIndex:=pinownerarray;
end;

function GDBObjEntity.GetObjTypeName;
begin
  Result:=ObjN_NotRecognized;
end;

function GDBObjEntity.GetObjType;
begin
  Result:={vp.ID}0;
end;

procedure GDBObjEntity.YouDeleted;
begin
  PGDBObjEntity(bp.ListPos.owner)^.EraseMi(@self,bp.ListPos.SelfIndex,drawing);
end;

procedure GDBObjEntity.YouChanged;
begin
  PGDBObjGenericWithSubordinated(bp.ListPos.owner)^.ImEdited(@self,bp.ListPos.SelfIndex,drawing);
end;

function GDBObjEntity.ReturnLastOnMouse;
begin
  Result:=@self;
end;

function GDBObjEntity.ObjToString(const prefix,sufix:string):string;
begin
  Result:=prefix+'#'+inttohex(PtrInt(@self),10)+sufix;
end;

function GDBObjEntity.GetMainOwner:PGDBObjSubordinated;
begin
  if bp.ListPos.Owner<>nil then
    Result:=PGDBObjEntity(bp.ListPos.Owner)^.getmainowner
  else
    Result:=nil;
end;

function GDBObjEntity.getowner;
begin
  Result:=PGDBObjEntity(bp.ListPos.Owner)^.getowner;
end;

function GDBObjEntity.getmatrix;
begin
  Result:=PGDBObjEntity(bp.ListPos.Owner)^.GetMatrix;
end;

function GDBObjEntity.getownermatrix;
begin
  Result:=PGDBObjEntity(bp.ListPos.Owner)^.GetMatrix;
end;

procedure GDBObjEntity.DrawGeometry;
begin
  drawbb(dc);
end;

function GDBObjEntity.CalculateLineWeight;
var
  lw:integer;
  minlw:integer;
begin
  if not dc.drawmode then begin
    lw:=1;
    exit;
  end;

  if dc.LWDisplayScale>14 then
    minlw:=2
  else
    minlw:=1;

  if vp.lineweight<0 then begin
    case vp.lineweight of -3:lw:=dc.DefaultLW;-2:lw:=dc.OwnerLineWeight;-1:lw:=vp.layer^.lineweight;
    end;
  end else
    lw:=vp.lineweight;

  case lw of -3:lw:=dc.DefaultLW;-2:lw:=dc.OwnerLineWeight;-1:lw:=vp.layer^.lineweight;
  end;

  if lw<=0 then
    lw:=minlw;
  if lw>65-2*dc.LWDisplayScale then begin
    lw:=(lw div (35-dc.LWDisplayScale))+1;
    if lw>dc.MaxWidth then
      lw:=dc.MaxWidth;
    Result:=lw;
  end else begin
    Result:=minlw;
  end;
  dc.drawer.setlinewidth(Result);
end;

constructor GDBObjEntity.init;
begin
  createfield;
  vp.Layer:=layeraddres;
  vp.LineWeight:=LW;
  vp.LineType:=nil;
  vp.LineTypeScale:=1;
  bp.ListPos.owner:=own;
  Representation.init();
  GetDXFIOFeatures.RunConstructorFeature(@self);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;

constructor GDBObjEntity.initnul;
begin
  createfield;
  if owner<>nil then
    bp.ListPos.owner:=owner;
  Representation.init();
  GetDXFIOFeatures.RunConstructorFeature(@self);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;

procedure GDBObjEntity.DrawWithOutAttrib;
var
  lw:integer;
begin
  lw:=CalculateLineWeight(dc);
  if Visible=dc.DrawingContext.VActuality.visibleactualy then
    DrawGeometry(lw,dc,infrustumstate);
  if lw>1 then begin
    dc.drawer.setlinewidth(1);
  end;
end;

procedure GDBObjEntity.DrawWithAttrib;
var
  lw:integer;
  sel,_selected:boolean;

  procedure SetEntColor(color:integer;var DC:TDrawContext);
  begin
    if color<>7 then
      dc.drawer.SetColor(palette[color].RGB)
    else
      dc.drawer.SetColor(
        palette[DC.DrawingContext.ForeGroundColorIndex].RGB);
  end;

begin
  sel:=False;
  if not dc.drawmode then
    lw:=1
  else
    lw:=CalculateLineWeight(dc);
  if selected or dc.selected then begin
    _selected:=dc.selected;
    dc.selected:=True;
    dc.drawer.SetSelectedStencilMode;
    dc.drawer.SetPenStyle(TPS_Selected);
    sel:=True;
  end;
  if (dc.subrender=0) then begin
    case vp.color of
      ClByLayer:
        SetEntColor(vp.layer^.color,dc);
      ClByBlock:
        SetEntColor(dc.ownercolor,dc);
      else
        SetEntColor(vp.color,dc);
    end;
  end else if (vp.layer<>dc.DrawingContext.SysLayer) then begin
    case vp.color of
      ClByLayer:
        SetEntColor(vp.layer^.color,dc);
      ClByBlock:
        SetEntColor(dc.ownercolor,dc);
      else
        SetEntColor(vp.color,dc);
    end;
  end else begin
    case vp.color of
      ClByLayer:
        SetEntColor(bp.ListPos.owner.getlayer^.color,dc);
      ClByBlock:
        SetEntColor(dc.ownercolor,dc);
      else
        SetEntColor(vp.color,dc);
    end;
  end;
  if Visible=dc.DrawingContext.VActuality.visibleactualy then
    DrawGeometry(lw,dc,infrustumstate);
  if lw>1 then begin
    dc.drawer.setlinewidth(1);
  end;
  if sel then begin
    dc.drawer.SetPenStyle(TPS_Solid);
    dc.selected:=_selected;
  end;
end;

procedure GDBObjEntity.FormatFast;
begin
  FormatEntity(drawing,dc);
end;

function GDBObjEntity.IsStagedFormatEntity:boolean;
begin
  Result:=False;
end;

procedure GDBObjEntity.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
end;

procedure GDBObjEntity.FormatFeatures(var drawing:TDrawingDef);
begin
  inherited;
  GetDXFIOFeatures.RunFormatProcs(drawing,@self);
end;

procedure GDBObjEntity.FormatAfterEdit;
begin
  formatentity(drawing,dc,Stage);
end;

procedure GDBObjEntity.FormatAfterFielfmod;
begin

end;

procedure GDBObjEntity.higlight;
begin
end;

procedure GDBObjEntity.SetInFrustum;
begin
  Inc(Counters.totalobj);
  Inc(Counters.infrustum);
end;

procedure GDBObjEntity.SetNotInFrustum;
begin
  Inc(Counters.totalobj);
end;

procedure GDBObjEntity.DXFOut;
begin
  SaveToDXF(outStream,drawing,IODXFContext);
  SaveToDXFPostProcess(outStream,IODXFContext);
  SaveToDXFFollow(outStream,drawing,IODXFContext);
end;

procedure GDBObjEntity.SaveToDXF;
begin
end;

procedure GDBObjEntity.SaveToDXFfollow;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunSaveToDXFfollow(@self,outStream,drawing,IODXFContext);
  inherited;
end;

procedure GDBObjEntity.SaveToDXFObjXData(var outStream:TZctnrVectorBytes;
  var IODXFContext:TIODXFSaveContext);
begin
  GetDXFIOFeatures.RunSaveFeatures(outStream,@self,IODXFContext);
  if assigned(EntExtensions) then
    EntExtensions.RunSaveToDxf(outStream,@self,IODXFContext);
  inherited;
end;

procedure GDBObjEntity.SaveToDXFPostProcess;
begin
  dxfStringout(outStream,1001,ZCADAppNameInDXF);
  dxfStringout(outStream,1002,'{');
  self.SaveToDXFObjXData(outStream,IODXFContext);
  dxfStringout(outStream,1002,'}');
end;

function GDBObjEntity.CalcInFrustum;
begin
  Result:=True;
end;

function GDBObjEntity.CalcTrueInFrustum;
begin
  Result:=IREmpty;
end;

function GDBObjEntity.calcvisible;
begin
  Visible:=Actuality.visibleactualy;
  Result:=True;
  if CalcInFrustum(frustum,Actuality,Counters,ProjectProc,zoom,
    currentdegradationfactor) then begin
    setinfrustum(Actuality.infrustumactualy,Counters);
  end else begin
    setnotinfrustum(Actuality.infrustumactualy,Counters);
    Visible:=0;
    Result:=False;
  end;
  if self.vp.Layer<>nil then
    if not(self.vp.Layer._on) then begin
      Visible:=0;
      Result:=False;
    end;
end;

function GDBObjEntity.GetLTCorrectH(GlobalLTScale:double):double;
var
  LT:PGDBLtypeProp;
begin
  LT:=getLTfromVP(vp);
  if LT<>nil then begin
    Result:=GlobalLTScale*vp.LineTypeScale*LT.h;
  end else
    Result:=0;

end;

function GDBObjEntity.GetLTCorrectL(GlobalLTScale:double):double;
var
  LT:PGDBLtypeProp;
begin
  LT:=getLTfromVP(vp);
  if LT<>nil then begin
    Result:=GlobalLTScale*vp.LineTypeScale*LT.strokesarray.LengthFact;
  end else
    Result:=0;

end;

procedure GDBObjEntity.correctbb;
var
  cv:TzePoint3d;
  d:double;
begin
  d:=GetLTCorrectL(dc.DrawingContext.globalltscale);
  cv:=VertexSUB(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
  if (d>0)and(d*d<cv.x*cv.x+cv.y*cv.y+cv.z*cv.z) then begin
    d:=GetLTCorrectH(dc.DrawingContext.globalltscale);
    cv:=createvertex(d,d,d);
    vp.BoundingBox.LBN:=VertexSUB(vp.BoundingBox.LBN,cv);
    vp.BoundingBox.RTF:=VertexAdd(vp.BoundingBox.RTF,cv);
  end;
end;

procedure GDBObjEntity.calcbb;
begin
  getoutbound(dc);
  correctbb(dc);
end;

procedure GDBObjEntity.getoutbound;
begin
end;

procedure GDBObjEntity.getonlyoutbound;
begin
  getoutbound(dc);
end;

function GDBObjEntity.getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
begin
  getonlyoutbound(dc);
  Result:=vp.BoundingBox;
end;

function GDBObjEntity.IsActualy:boolean;
begin
  if vp.Layer^._on then
    Result:=True
  else
    Result:=False;
end;

function GDBObjEntity.isonmouse;
begin
  if IsActualy then
    Result:=onmouse(popa,mousefrustum,InSubEntry)
  else
    Result:=False;
end;

function GDBObjEntity.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  Result:=False;
end;

function GDBObjEntity.onmouse;
begin
  Result:=False;
end;

procedure GDBObjEntity.SetFromClone(_clone:PGDBObjEntity);
begin
end;

function GDBObjEntity.Clone;
begin
  Result:=nil;
end;

destructor GDBObjEntity.done;
begin
  inherited;
  if PExtAttrib<>nil then
    Freemem(pointer(PExtAttrib));
  vp.LineType:=nil;
  Representation.done;
  GetDXFIOFeatures.RunDestructorFeature(@self);
end;

procedure GDBObjEntity.rtsave;
begin
end;

procedure GDBObjEntity.startsnap;
begin
  onlygetsnapcount:=0;
  osp.PGDBObject:=@self;
  pdata:=nil;
end;

procedure GDBObjEntity.endsnap(out osp:os_record;var pdata:Pointer);
begin
end;

function GDBObjEntity.getsnap;
begin
  Result:=False;
end;

function GDBObjEntity.getintersect;
begin
  Result:=False;
end;

function GDBObjEntity.SelectQuik;
begin
  if (vp.Layer._lock)or(not vp.Layer._on) then begin
    Result:=False;
  end else begin
    Result:=True;
    selected:=True;
  end;
end;

function GDBObjEntity.select;
begin
  Result:=False;
  if selected=False then begin
    Result:=SelectQuik;
    if Result then
      if assigned(s2s) then
        s2s(@self,@self,SelectedObjCount);
  end;
end;

procedure GDBObjEntity.DeSelect;
begin
  if selected then begin
    if assigned(ds2s) then
      ds2s(@self,SelectedObjCount);
    Selected:=False;
  end;
end;

procedure GDBObjEntity.remapcontrolpoints;
var
  pdesc:pcontrolpointdesc;
  i:integer;
begin
  if pp.Count<>0 then begin
    pdesc:=pp^.getparrayaspointer;
    for i:=0 to pp.Count-1 do begin
      remaponecontrolpoint(pdesc,ProjectProc);
      Inc(pdesc);
    end;
  end;
end;

function GDBObjEntity.beforertmodify;
begin
  Result:=nil;
end;

procedure GDBObjEntity.clearrtmodify(p:Pointer);
begin

end;

procedure GDBObjEntity.afterrtmodify;
begin
  if p<>nil then
    Freemem(p);
end;

function GDBObjEntity.IsRTNeedModify(const Point:PControlPointDesc;p:Pointer):boolean;
begin
  Result:=True;
end;

procedure GDBObjEntity.transform;
begin
end;

procedure GDBObjEntity.SaveToDXFObjPrefix;
var
  tmpHandle:TDWGHandle;
begin
  dxfStringout(outStream,0,entname);
  //TODO: MyGetOrCreateValue можно желать не для всех примитивов, а только для главных функций
  //TODO: это чуток ускорит сохранение с ним 0.35сек, без 0.34~0.33 в тесте
  if notprocessHandle then begin
    tmpHandle:=IODXFContext.handle;
    Inc(IODXFContext.handle);
  end else begin
    if IODXFContext.currentEntAddrOverrider=nil then
      IODXFContext.p2h.MyGetOrCreateValue(@self,IODXFContext.handle,tmpHandle)
    else begin
      IODXFContext.p2h.MyGetOrCreateValue(
        IODXFContext.currentEntAddrOverrider,IODXFContext.handle,tmpHandle);
      IODXFContext.currentEntAddrOverrider:=nil;
      Inc(IODXFContext.handle);
    end;
  end;
  dxfStringout(outStream,5,inttohex(tmpHandle,0));
  dxfStringout(outStream,100,dxfName_AcDbEntity);
  dxfStringout(outStream,8,dxfEnCodeString(vp.layer^.Name,IODXFContext.header));
  if vp.color<>ClByLayer then
    dxfStringout(outStream,62,IntToStr(vp.color));
  if vp.lineweight<>-1 then
    dxfIntegerout(outStream,370,vp.lineweight);
  if dbname<>'' then
    dxfStringout(outStream,100,dbname);
  if vp.LineType<>nil then
    dxfStringout(outStream,6,dxfEnCodeString(vp.LineType^.Name,IODXFContext.header));
  if vp.LineTypeScale<>1 then
    dxfDoubleout(outStream,48,vp.LineTypeScale);
end;

function GDBObjEntity.LoadFromDXFObjShared;
var
  APP_NAME:shortstring;
  XGroup:integer;
  XValue:string;
  Name,Value:string;
  i:integer;
begin
  Result:=False;
  case DXFCode of
    5:begin
      if AddExtAttrib^.dwgHandle=0 then begin
        PExtAttrib^.dwgHandle:=rdr.ParseHexQWord;
      end else begin
        //при загрузке полилинии у вертексов есть хэндл
        rdr.SkipString;
      end;
      Result:=True;
    end;
    6:begin
      vp.LineType:=drawing.GetLTypeTable.getAddres(
        dxfDeCodeString(rdr.ParseShortString,Context.header));
      Result:=True;
    end;
    8:begin
      if vp.layer=@DefaultErrorLayer then begin
        vp.Layer:=drawing.getlayertable.getAddres(
          dxfDeCodeString(rdr.ParseShortString,Context.header));
        if vp.Layer=nil then
          vp.Layer:=vp.Layer;
      end else
        APP_NAME:=rdr.ParseString;
      Result:=True;
    end;
    48:begin
      vp.LineTypeScale:=rdr.ParseDouble;
      Result:=True;
    end;
    62:begin
      vp.color:=rdr.ParseInteger;
      Result:=True;
    end;
    370:begin
      vp.lineweight:=rdr.ParseInteger;
      Result:=True;
    end;
    1001:begin
      APP_NAME:=rdr.ParseShortString;
      Result:=True;
      if (Length(APP_NAME)=Length(ZCADAppNameInDXF)) and
        (StrLComp(@APP_NAME[1],@ZCADAppNameInDXF[1],Length(APP_NAME))=0) then begin
        repeat
          XGroup:=rdr.ParseInteger;
          XValue:=rdr.ParseString;
          if XGroup=1000 then begin
            i:=pos('=',Xvalue);
            if i>1 then
              Name:=copy(Xvalue,1,i-1)
            else
              Name:='empty';
            Value:=copy(Xvalue,i+1,length(xvalue)-i);
            ProcessFromDXFObjXData(Name,Value,ptu,drawing);
          end;
        until (XGroup=1002)and(XValue='}');
      end;
    end;
  end;
end;

class function GDBObjEntity.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  Result:=GDBObjEntityDXFFeatures;
end;

function GDBObjEntity.ProcessFromDXFObjXData(const _Name,_Value:string;
  ptu:PExtensionData;
  const drawing:TDrawingDef):boolean;
var
  features:TDXFEntIODataManager;
  FeatureLoadProc:TDXFEntLoadFeature;
begin
  Result:=False;
  features:=GetDXFIOFeatures;
  if assigned(features) then begin
    FeatureLoadProc:=features.GetLoadFeature(_Name);
    if assigned(FeatureLoadProc) then begin
      Result:=FeatureLoadProc(_Name,_Value,ptu,drawing,@self);
    end;
  end;
end;

initialization
  GDBObjEntityDXFFeatures:=TDXFEntIODataManager.Create;

finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDBObjEntityDXFFeatures.Destroy;
end.
