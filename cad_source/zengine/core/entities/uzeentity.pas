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

unit uzeentity;
{$INCLUDE def.inc}
interface
uses uzepalette,uzeobjectextender,uzgldrawerabstract,uzgldrawcontext,uzedrawingdef,
     uzecamera,uzeentitiesprop,uzestyleslinetypes,uzbtypesbase,
     uzbgeomtypes,UGDBControlPointArray,uzeentsubordinated,uzbtypes,uzeconsts,
     uzglviewareadata,uzegeometry,uzeffdxfsupport,sysutils,uzbmemman,UGDBOpenArrayOfByte,
     uzestyleslayers,gzctnrvectorpobjects,uzeenrepresentation,LazLogger;
type
taddotrac=procedure (var posr:os_record;const axis:GDBVertex) of object;
{Export+}
PGDBObjEntity=^GDBObjEntity;
{-}TSelect2Stage=procedure(PEntity,PGripsCreator:PGDBObjEntity;var SelectedObjCount:GDBInteger)of object;{//}
{-}TDeSelect2Stage=procedure(PV:PGDBObjEntity;var SelectedObjCount:GDBInteger)of object;{//}
PTExtAttrib=^TExtAttrib;
{REGISTERRECORDTYPE TExtAttrib}
TExtAttrib=record
                 OwnerHandle:GDBQWord;
                 MainFunctionHandle:GDBQWord;
                 dwgHandle:GDBQWord;
                 Handle:GDBQWord;
                 Upgrade:TEntUpgradeInfo;
                 ExtAttrib2:GDBBoolean;
           end;
{REGISTEROBJECTTYPE GDBObjEntity}
GDBObjEntity= object(GDBObjSubordinated)
                    vp:GDBObjVisualProp;(*'General'*)(*saved_to_shd*)
                    Selected:GDBBoolean;(*'Selected'*)(*hidden_in_objinsp*)
                    Visible:TActulity;(*'Visible'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    infrustum:TActulity;(*'In frustum'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    PExtAttrib:PTExtAttrib;(*hidden_in_objinsp*)
                    Representation:TZEntityRepresentation;
                    destructor done;virtual;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    constructor initnul(owner:PGDBObjGenericWithSubordinated);
                    procedure SaveToDXFObjPrefix(var  outhandle:{GDBInteger}GDBOpenArrayOfByte;entname,dbname:GDBString;var IODXFContext:TIODXFContext;notprocessHandle:boolean=false);
                    function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PExtensionData;var drawing:TDrawingDef):GDBBoolean;
                    function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef):GDBBoolean;virtual;
                    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                    procedure FromDXFPostProcessAfterAdd;virtual;
                    function IsHaveObjXData:GDBBoolean;virtual;


                    procedure createfield;virtual;
                    function AddExtAttrib:PTExtAttrib;
                    function CopyExtAttrib:PTExtAttrib;
                    procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;abstract;
                    procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                    procedure DXFOut(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                    procedure SaveToDXFfollow(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                    procedure SaveToDXFPostProcess(var handle:GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);
                    procedure SaveToDXFObjXData(var outhandle:GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);virtual;
                    procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                    procedure FormatFeatures(var drawing:TDrawingDef);virtual;
                    procedure FormatFast(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                    procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;

                    procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;
                    procedure DrawWithOutAttrib({visibleactualy:TActulity;}var DC:TDrawContext{subrender:GDBInteger});virtual;

                    procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;
                    procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;

                    procedure Draw(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;
                    procedure DrawG(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;

                    procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                    procedure RenderFeedbackIFNeed(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                    function CalculateLineWeight(const DC:TDrawContext):GDBInteger;//inline;
                    //function InRect:TInRect;virtual;
                    function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                    procedure SetFromClone(_clone:PGDBObjEntity);virtual;
                    function CalcOwner(own:GDBPointer):GDBPointer;virtual;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                    procedure rtsave(refp:GDBPointer);virtual;
                    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                    procedure getoutbound(var DC:TDrawContext);virtual;
                    procedure getonlyoutbound(var DC:TDrawContext);virtual;
                    function getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;virtual;
                    procedure correctbb(var DC:TDrawContext);virtual;
                    function GetLTCorrectH(GlobalLTScale:GDBDouble):GDBDouble;virtual;
                    function GetLTCorrectL(GlobalLTScale:GDBDouble):GDBDouble;virtual;
                    procedure calcbb(var DC:TDrawContext);virtual;
                    procedure DrawBB(var DC:TDrawContext);
                    function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;

                    function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                    function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;

                    function isonmouse(var popa:TZctnrVectorPGDBaseObjects;mousefrustum:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                    procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;
                    function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                    procedure endsnap(out osp:os_record; var pdata:GDBPointer);virtual;
                    function getintersect(var osp:os_record;pobj:PGDBObjEntity; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                    procedure higlight(var DC:TDrawContext);virtual;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    function select(var SelectedObjCount:GDBInteger;s2s:TSelect2Stage):GDBBoolean;virtual;
                    //procedure Selector(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger);virtual;
                    //procedure DeSelector(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger);virtual;
                    procedure DeSelect(var SelectedObjCount:GDBInteger;ds2s:TDeSelect2Stage);virtual;
                    function SelectQuik:GDBBoolean;virtual;
                    procedure remapcontrolpoints(pp:PGDBControlPointArray;pcount:TActulity;ScrollMode:GDBBoolean;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                    //procedure rtmodify(md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
                    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                    procedure transform(const t_matrix:DMatrix4D);virtual;
                    procedure remaponecontrolpoint(pdesc:PControlPointDesc);virtual;abstract;
                    function beforertmodify:GDBPointer;virtual;
                    procedure afterrtmodify(p:GDBPointer);virtual;
                    function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;
                    procedure clearrtmodify(p:GDBPointer);virtual;
                    function getowner:PGDBObjSubordinated;virtual;
                    function GetMainOwner:PGDBObjSubordinated;virtual;
                    function getmatrix:PDMatrix4D;virtual;
                    function getownermatrix:PDMatrix4D;virtual;
                    function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;
                    function ReturnLastOnMouse(InSubEntry:GDBBoolean):PGDBObjEntity;virtual;
                    procedure YouDeleted(var drawing:TDrawingDef);virtual;
                    procedure YouChanged(var drawing:TDrawingDef);virtual;
                    function GetObjTypeName:GDBString;virtual;
                    function GetObjType:TObjID;virtual;
                    procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                    function GetLineWeight:GDBSmallint;inline;
                    function IsSelected:GDBBoolean;virtual;
                    function IsActualy:GDBBoolean;virtual;
                    function IsHaveLCS:GDBBoolean;virtual;
                    function IsHaveGRIPS:GDBBoolean;virtual;
                    function IsEntity:GDBBoolean;virtual;
                    function GetLayer:PGDBLayerProp;virtual;
                    function GetCenterPoint:GDBVertex;virtual;
                    procedure SetInFrustum(infrustumactualy:TActulity;var totalobj,infrustumobj:GDBInteger);virtual;
                    procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;
                    procedure SetNotInFrustum(infrustumactualy:TActulity;var totalobj,infrustumobj:GDBInteger);virtual;
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                    function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;
                    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
                    procedure AddOnTrackAxis(var posr:os_record; const processaxis:taddotrac);virtual;

                    function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;

                    procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;var drawing:TDrawingDef);virtual;
                    function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;
                    procedure CalcObjMatrix;virtual;
                    procedure ReCalcFromObjMatrix;virtual;
                    procedure correctsublayers(var la:GDBLayerArray);virtual;
                    procedure CopyVPto(var toObj:GDBObjEntity);virtual;
                    function CanSimplyDrawInWCS(const DC:TDrawContext;const ParamSize,TargetSize:GDBDouble):GDBBoolean;inline;
                    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                    procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;
                    class function GetDXFIOFeatures:TDXFEntIODataManager;static;
                    function GetNameInBlockTable:GDBString;virtual;
              end;
{Export-}
var onlygetsnapcount:GDBInteger;
    GDBObjEntityDXFFeatures:TDXFEntIODataManager;
implementation
uses usimplegenerics,uzeentityfactory{,UGDBSelectedObjArray};
procedure GDBObjEntity.IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);
begin
    proc(@self,PCounted,Counter);
end;
function GDBObjEntity.GetNameInBlockTable:GDBString;
begin
    result:='';
end;
procedure GDBObjEntity.FormatAfterDXFLoad;
begin
     //format;
     CalcObjMatrix;
     CalcGeometry;
     calcbb(dc);
end;

function GDBObjEntity.CanSimplyDrawInWCS(const DC:TDrawContext;const ParamSize,TargetSize:GDBDouble):GDBBoolean;
var
   templod:GDBDouble;
begin
     if dc.maxdetail then
                         exit(true);
  templod:=(ParamSize)/(dc.DrawingContext.zoom);
  if templod>TargetSize then
                            exit(true)
                        else
                            exit(false);
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

function GDBObjEntity.IsHaveGRIPS:GDBBoolean;
begin
     result:=true;
end;
function GDBObjEntity.IsEntity:GDBBoolean;
begin
     result:=true;
end;
procedure GDBObjEntity.ReCalcFromObjMatrix;
begin

end;
procedure GDBObjEntity.CalcObjMatrix;
begin

end;
procedure GDBObjEntity.EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;var drawing:TDrawingDef);
begin

end;

function GDBObjEntity.GetTangentInPoint(point:GDBVertex):GDBVertex;
begin
     result:=nulvertex;
end;

function GDBObjEntity.IsHaveLCS:GDBBoolean;
begin
     result:=false;
end;

function GDBObjEntity.CalcObjMatrixWithoutOwner:DMatrix4D;
begin
     result:=onematrix;
end;

procedure GDBObjEntity.SetInFrustumFromTree;
begin
     infrustum:=infrustumactualy;
     if (self.vp.Layer._on) then
     begin
          visible:=visibleactualy;
     end
      else
          visible:=0;
end;
procedure GDBObjEntity.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin

end;
procedure GDBObjEntity.BuildGeometry;
begin

end;
function GDBObjEntity.IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;
begin
     result.isintercept:=false;
end;
procedure GDBObjEntity.Draw;
begin
  if visible=dc.DrawingContext.visibleactualy then
  begin
       DrawGeometry(lw,dc{visibleactualy,subrender});
  end;
end;
procedure GDBObjEntity.Drawg;
begin
  if visible=dc.DrawingContext.visibleactualy then
  begin
       DrawOnlyGeometry(lw,dc{visibleactualy,subrender});
  end;
end;

procedure GDBObjEntity.createfield;
begin
     inherited;
     Selected := false;
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
     vp.LastCameraPos:=-1;
     vp.color:=ClByLayer;
end;
function GDBObjEntity.CalcOwner(own:GDBPointer):GDBPointer;
begin
     if own=nil then
                    result:=bp.ListPos.owner
                else
                    result:=own;
end;
procedure GDBObjEntity.DrawBB;
begin
  if DC.SystmGeometryDraw{and(GDB.GetCurrentDWG.OGLwindow1.param.subrender=0)} then
  begin
  //oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^].RGB);
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
  dc.drawer.DrawAABB3DInModelSpace(vp.BoundingBox,dc.DrawingContext.matrixs);
  end;
end;
function GDBObjEntity.GetCenterPoint;
begin
     result:=nulvertex;
end;
procedure GDBObjEntity.FromDXFPostProcessAfterAdd;
begin
end;
function GDBObjEntity.FromDXFPostProcessBeforeAdd;
var
    EntUpgradeKey:TEntUpgradeKey;
    EntUpgradeData:TEntUpgradeData;
begin
     result:=nil;
     if self.PExtAttrib<>nil then
     if self.PExtAttrib^.Upgrade>0 then
     begin
       EntUpgradeKey.EntityID:={vp.ID}GetObjType;
       EntUpgradeKey.UprradeInfo:=self.PExtAttrib^.Upgrade;
       if EntUpgradeKey2EntUpgradeData.MyGetValue(EntUpgradeKey,EntUpgradeData) then
       if assigned(EntUpgradeData.EntityUpgradeFunc) then
         result:=EntUpgradeData.EntityUpgradeFunc(ptu,@self,drawing);
     end;
end;
function GDBObjEntity.AddExtAttrib;
begin
     if PExtAttrib=nil then
                           begin
                                GDBGetMem({$IFDEF DEBUGBUILD}'{17FE0FF9-EF06-46F4-9E97-58D66E65233B}',{$ENDIF}GDBPointer(PExtAttrib),sizeof(TExtAttrib));
                                fillchar(PExtAttrib^,sizeof(TExtAttrib),0);
                                PExtAttrib^.ExtAttrib2:=false;
                           end;
     result:=PExtAttrib;
end;
function GDBObjEntity.CopyExtAttrib;
begin
     if PExtAttrib<>nil then
                           begin
                                GDBGetMem({$IFDEF DEBUGBUILD}'{17FE0FF9-EF06-46F4-9E97-58D66E65233B}',{$ENDIF}GDBPointer(Result),sizeof(TExtAttrib));
                                fillchar(result^,sizeof(TExtAttrib),0);
                                result^:=PExtAttrib^;
                           end
                        else
                            result:=nil;
end;
function GDBObjEntity.GetLineWeight;
begin
     result:=vp.LineWeight;
end;
function GDBObjEntity.GetLayer;
begin
     result:=vp.Layer;
end;

function GDBObjEntity.IsSelected;
begin
     //result:=selected;
     if selected then
                     result:=selected
                 else
                     begin
                          if bp.ListPos.owner<>nil then
                                            result:=bp.ListPos.owner.IsSelected
                                           else
                                               result:=false;
                     end;
end;
procedure GDBObjEntity.correctobjects;
begin
     bp.ListPos.Owner:=powner;
     bp.ListPos.SelfIndex:=pinownerarray;
end;
function GDBObjEntity.GetObjTypeName;
begin
     result:=ObjN_NotRecognized;
end;
function GDBObjEntity.GetObjType;
begin
     result:={vp.ID}0;
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
     result:=@self;
end;
function GDBObjEntity.ObjToGDBString(prefix,sufix:GDBString):GDBString;
begin
     result:=prefix+'#'+inttohex(GDBPlatformint(@self),10)+sufix;
end;
function GDBObjEntity.GetMainOwner:PGDBObjSubordinated;
begin
     if bp.ListPos.Owner<>nil then
                                  result:=PGDBObjEntity(bp.ListPos.Owner)^.getmainowner
                              else
                                  result:=nil;
end;
function GDBObjEntity.getowner;
begin
     result:=PGDBObjEntity(bp.ListPos.Owner)^.getowner;
end;
function GDBObjEntity.getmatrix;
begin
     result:=PGDBObjEntity(bp.ListPos.Owner)^.GetMatrix;
end;
function GDBObjEntity.getownermatrix;
begin
     result:=PGDBObjEntity(bp.ListPos.Owner)^.GetMatrix;
end;
procedure GDBObjEntity.DrawGeometry;
begin
     drawbb(dc);
end;
procedure GDBObjEntity.DrawOnlyGeometry;
begin
     DrawGeometry(lw,dc{visibleactualy,0});
end;
function GDBObjEntity.CalculateLineWeight;
var lw: GDBInteger;
    minlw: GDBInteger;
begin
  if not dc.drawmode then
                       begin
                            lw := 1;
                            exit;
                       end;

  if dc.LWDisplayScale>14 then
                           minlw:=2
                       else
                           minlw:=1;

  if vp.lineweight < 0 then
  begin
    case vp.lineweight of
      -3: lw := dc.DefaultLW;
      -2: lw := dc.OwnerLineWeight;
      -1: lw := vp.layer^.lineweight;
    end
  end
  else lw := vp.lineweight;

  case lw of
      -3: lw := dc.DefaultLW;
      -2: lw := dc.OwnerLineWeight;
      -1: lw := vp.layer^.lineweight;
  end;

  if lw <= 0 then lw := minlw;
  if lw > 65-2*dc.LWDisplayScale then begin
    lw := (lw div (35-dc.LWDisplayScale))+1;
    if lw>dc.MaxWidth then lw:=dc.MaxWidth;
    result := lw;
  end
  else
  begin
    result := minlw;
  end;
  dc.drawer.setlinewidth(result);
end;
constructor GDBObjEntity.init;
begin
  createfield;
  //vp.ID := 0;
  vp.Layer := layeraddres;
  vp.LineWeight := LW;
  vp.LineType:={''}nil;
  vp.LineTypeScale:=1;
  bp.ListPos.owner:=own;
  Representation.init({$IFDEF DEBUGBUILD}'GDBObjEntity'{$ENDIF});
  GetDXFIOFeatures.RunConstructorFeature(@self);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
constructor GDBObjEntity.initnul;
begin
     createfield;
     if owner<>nil then
                       bp.ListPos.owner:=owner;
     Representation.init({$IFDEF DEBUGBUILD}{$IFNDEF SEPARATEMEMUSAGE}'GDBObjEntity'{$ELSE}pchar(GetObjTypeName){$ENDIF}{$ENDIF});
     GetDXFIOFeatures.RunConstructorFeature(@self);
     GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
procedure GDBObjEntity.DrawWithOutAttrib;
var lw: GDBInteger;
//  sel: GDBBoolean;
begin
  lw := CalculateLineWeight(dc);
  Drawg(lw,dc{visibleactualy,subrender});
  if lw > 1 then
  begin
    dc.drawer.setlinewidth(1);
    {oglsm.myglDisable(GL_LINE_SMOOTH);
    oglsm.mygllinewidth(1);
    oglsm.myglpointsize(1);
    oglsm.myglDisable(gl_point_smooth);}
  end;
end;
procedure GDBObjEntity.DrawWithAttrib;
var lw: GDBInteger;
  sel,_selected: GDBBoolean;
procedure SetEntColor(color:integer;var DC:TDrawContext);
begin
  if color<>7 then
                  dc.drawer.SetColor(palette[color].RGB)
              else
                  dc.drawer.SetColor(palette[DC.DrawingContext.ForeGroundColorIndex].RGB);
end;

begin
  //if visible<>dc.visibleactualy then
  //                               exit;
  //Draw(lw,dc);
  //exit;
  sel := false;
  if not dc.drawmode then
                         lw := 1
                     else
                         lw := CalculateLineWeight(dc);

  if selected or dc.selected then
                                                                    begin
                                                                         _selected:=dc.selected;
                                                                         dc.selected:=true;
                                                                         //oglsm.myglStencilFunc(GL_ALWAYS,0,1);
                                                                         dc.drawer.SetSelectedStencilMode;
                                                                         dc.drawer.SetPenStyle(TPS_Selected);
                                                                         sel := true;
                                                                    end;
  if (dc.subrender = 0)
      then
          begin
               case vp.color of
                               ClByLayer:
                                         SetEntColor(vp.layer^.color,dc);
                               ClByBlock:
                                         SetEntColor(dc.ownercolor,dc);
                               else
                                   SetEntColor(vp.color,dc);

               end;
          end
      else
          if (vp.layer<>dc.DrawingContext.SysLayer) then
                                         begin
                                              case vp.color of
                                                              ClByLayer:
                                                                        SetEntColor(vp.layer^.color,dc);
                                                              ClByBlock:
                                                                        SetEntColor(dc.ownercolor,dc);
                                                              else
                                                                  SetEntColor(vp.color,dc);

                                              end;
                                         end
                                                else
                                                    begin
                                                              case vp.color of
                                                                              ClByLayer:
                                                                                        SetEntColor(bp.ListPos.owner.getlayer^.color,dc);
                                                                              ClByBlock:
                                                                                        SetEntColor(dc.ownercolor,dc);
                                                                              else
                                                                                  SetEntColor(vp.color,dc);

                                                              end;
                                                    end;
  Draw(lw,dc{visibleactualy,subrender});
  //if selected or ((bp.ListPos.owner <> nil) and (bp.ListPos.owner^.isselected)) then
  (*if {selected or dc.selected}sel then
                                                                    begin
                                                                    end
                                                                else
                                                                    begin
                                                                         //oglsm.mytotalglend;
                                                                         oglsm.myglStencilFunc(GL_EQUAL,0,1);
                                                                         //oglsm.myglStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);
                                                                    end;*)

  if lw > 1 then
  begin
    dc.drawer.setlinewidth(1);
    {oglsm.myglDisable(GL_LINE_SMOOTH);
    oglsm.mygllinewidth(1);
    oglsm.myglpointsize(1);
    oglsm.myglDisable(gl_point_smooth);}
  end;
  if sel then
             begin
                  //oglsm.mytotalglend;
                  dc.drawer.SetPenStyle(TPS_Solid);
                  dc.selected:=_selected;
             end;
end;
procedure GDBObjEntity.RenderFeedbackIFNeed;
begin
     if vp.LastCameraPos<>{gdb.GetCurrentDWG.pcamera^.POSCOUNT}pcount then
                                                               Renderfeedback(pcount,camera,ProjectProc,dc);

end;
procedure GDBObjEntity.Renderfeedback;
begin
     vp.LastCameraPos:={gdb.GetCurrentDWG.pcamera^.POSCOUNT}pcount;
  //DrawGeometry;
end;

{procedure GDBObjEntity.format;
begin
end;}
procedure GDBObjEntity.FormatFast;
begin
     FormatEntity(drawing,dc);
end;
procedure GDBObjEntity.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure GDBObjEntity.FormatFeatures(var drawing:TDrawingDef);
begin
     inherited;
     GetDXFIOFeatures.RunFormatProcs(drawing,@self);
end;

procedure GDBObjEntity.FormatAfterEdit;
begin
     formatentity(drawing,dc);
     //AddObjectToObjArray
end;
procedure GDBObjEntity.FormatAfterFielfmod;
begin

end;
procedure GDBObjEntity.higlight;
begin
end;
procedure GDBObjEntity.SetInFrustum;
begin
     //result:=infrustum;
     infrustum:=infrustumactualy;
     inc({gdb.GetCurrentDWG.pcamera^.}totalobj);
     inc({gdb.GetCurrentDWG.pcamera^.}infrustumobj);
end;
procedure GDBObjEntity.SetNotInFrustum;
begin
     //result:=infrustum;
     //infrustum:=false;
     inc({gdb.GetCurrentDWG.pcamera^.}totalobj);
end;
procedure GDBObjEntity.DXFOut;
begin
     SaveToDXF(outhandle,drawing,IODXFContext);
     SaveToDXFPostProcess(outhandle,IODXFContext);
     SaveToDXFFollow(outhandle,drawing,IODXFContext);
end;
procedure GDBObjEntity.SaveToDXF;
begin
end;
procedure GDBObjEntity.SaveToDXFfollow;
begin
end;
procedure GDBObjEntity.SaveToDXFObjXData(var outhandle:GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);
begin
     GetDXFIOFeatures.RunSaveFeatures(outhandle,@self,IODXFContext);
     if assigned(EntExtensions) then
       EntExtensions.RunSaveToDxf(outhandle,@self,IODXFContext);
     inherited;
end;

procedure GDBObjEntity.SaveToDXFPostProcess;
begin
  dxfGDBStringout(handle,1001,ZCADAppNameInDXF);
  dxfGDBStringout(handle,1002,'{');
  self.SaveToDXFObjXData(handle,IODXFContext);
  dxfGDBStringout(handle,1002,'}');
end;
function GDBObjEntity.CalcInFrustum;
begin
     result:=true;
end;
function GDBObjEntity.CalcTrueInFrustum;
begin
     result:=IREmpty;
end;
{function GDBObjEntity.CalcVisibleByTree;
begin

end;}

function GDBObjEntity.calcvisible;
//var i:GDBInteger;
//    tv,tv1:gdbvertex4d;
//    m:DMatrix4D;
begin
      visible:=visibleactualy;
      result:=true;
      //inc(gdb.GetCurrentDWG.pcamera^.totalobj);
      if CalcInFrustum(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor) then
                           begin
                                setinfrustum(infrustumactualy,totalobj,infrustumobj);
                           end
                       else
                           begin
                                setnotinfrustum(infrustumactualy,totalobj,infrustumobj);
                                visible:=0;
                                result:=false;
                           end;
      if self.vp.Layer<>nil then
      if not(self.vp.Layer._on) then
                           begin
                                visible:=0;
                                result:=false;
                           end;

      {if visible then begin
                           m:=gdb.pcamera^.modelmatrix;
                           //matrixtranspose(m);
                           inc(gdb.pcamera^.infrustum);
                           pgdbvertex(@tv)^:=CoordInWCS.lbegin;
                           tv.w:=1;
                           tv1:=VectorTransform(tv,m);
                           CalcZ(tv1.z);
                           //if lbegin.z>=0 then CalcZ(lbegin.z);
                           //if lend.z>=0 then CalcZ(lend.z);
                      end;}
end;
function GDBObjEntity.GetLTCorrectH(GlobalLTScale:GDBDouble):GDBDouble;
var
   LT:PGDBLtypeProp;
begin
      LT:=getLTfromVP(vp);
      if LT<>nil then
      begin
           result:=GlobalLTScale*vp.LineTypeScale*LT.h
      end
         else
         result:=0;

end;
function GDBObjEntity.GetLTCorrectL(GlobalLTScale:GDBDouble):GDBDouble;
var
   LT:PGDBLtypeProp;
begin
      LT:=getLTfromVP(vp);
      if LT<>nil then
      begin
           result:=GlobalLTScale*vp.LineTypeScale*LT.LengthFact
      end
         else
         result:=0;

end;
procedure GDBObjEntity.correctbb;
var cv:gdbvertex;
    d:double;
begin
     {cv:=VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
     cv:=VertexMulOnSc(cv,onedivbasedist);
     if cv.x<minoffsetstart then
                                cv.x:=minoffsetstart;
     if cv.y<minoffsetstart then
                                cv.y:=minoffsetstart;
     if cv.z<minoffsetstart then
                                cv.z:=minoffsetstart;}

      {if self.vp.LineType<>nil then
      begin
           if SysVar.dwg.DWG_LTScale<>nil then
                                              d:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale*self.vp.LineType.len
                                          else
                                              d:=vp.LineTypeScale*self.vp.LineType.len;
      end
         else
             d:=0;}
     d:=GetLTCorrectL(dc.DrawingContext.globalltscale);
     cv:=VertexSUB(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
     if (d>0)and(d*d<cv.x*cv.x+cv.y*cv.y+cv.z*cv.z) then
     begin
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
  result:=vp.BoundingBox;
end;
function GDBObjEntity.IsActualy:GDBBoolean;
begin
     if vp.Layer^._on then
                               result:=true
                           else
                               result:=false;
end;

function GDBObjEntity.isonmouse;
begin
     if IsActualy then
                          result:=onmouse(popa,{GDB.GetCurrentDWG.OGLwindow1.param.}mousefrustum,InSubEntry)
                      else
                          result:=false;
end;
function GDBObjEntity.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
begin
     result:=false;
end;
function GDBObjEntity.onmouse;
begin
     result:=false;
end;
{function GDBObjEntity.InRect:TInRect;
begin
     result:=IREmpty;
end;}
procedure GDBObjEntity.SetFromClone(_clone:PGDBObjEntity);
begin
end;
function GDBObjEntity.Clone;
//var tvo: PGDBObjEntity;
begin
  //GDBGetMem({$IFDEF DEBUGBUILD}'{24859B41-865F-4F60-A06C-05E2127EDCDF}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjEntity));
  //tvo^.init(bp.owner,vp.Layer, vp.LineWeight);
  result := nil;
end;

procedure GDBObjEntity.rtedit;
begin
     if PExtAttrib<>nil then
                            GDBFreeMem(pointer(PExtAttrib));
end;

destructor GDBObjEntity.done;
begin
     inherited;
     if PExtAttrib<>nil then
                            gdbfreemem(pointer(PExtAttrib));
     vp.LineType:={''}nil;
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
procedure GDBObjEntity.endsnap(out osp:os_record; var pdata:GDBPointer);
begin
end;
function GDBObjEntity.getsnap;
begin
     result:=false;
end;
function GDBObjEntity.getintersect;
begin
     result:=false;
end;
function GDBObjEntity.SelectQuik;
begin
     if (vp.Layer._lock)or(not vp.Layer._on) then
                           begin
                                result:=false;
                           end
                       else
                           begin
                                result:=true;
                                selected:=true;
                           end;
end;
(*procedure GDBObjEntity.Selector;
var tdesc:pselectedobjdesc;
begin
     tdesc:=PGDBSelectedObjArray(SelObjArray)^.addobject(@self);
     if tdesc<>nil then
     if IsHaveGRIPS then
     begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{B50BE8C9-E00A-40C0-A051-230877BD3A56}',{$ENDIF}GDBPointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
     addcontrolpoints(tdesc);
     end;
     bp.ListPos.Owner.ImSelected(@self,bp.ListPos.SelfIndex);
     inc(Selectedobjcount);
end;*)
function GDBObjEntity.select;
begin
     result:=false;
     if selected=false then
     begin
       result:=SelectQuik;
       if result then
         if assigned(s2s)then
           s2s(@self,@self,SelectedObjCount);
     end;
end;
{procedure GDBObjEntity.DeSelector;
var tdesc:pselectedobjdesc;
    ir:itrec;
begin
          tdesc:=PGDBSelectedObjArray(SelObjArray)^.beginiterate(ir);
          if tdesc<>nil then
          repeat
                if tdesc^.objaddr=@self then
                                            begin
                                                 PGDBSelectedObjArray(SelObjArray)^.freeelement(tdesc);
                                                 PGDBSelectedObjArray(SelObjArray)^.deleteelementbyp(tdesc);
                                            end;

                tdesc:=PGDBSelectedObjArray(SelObjArray)^.iterate(ir);
          until tdesc=nil;
          dec(Selectedobjcount);
end;}
procedure GDBObjEntity.DeSelect;
{var tdesc:pselectedobjdesc;
    ir:itrec;}
begin
     if selected then
     begin
       if assigned(ds2s)then
         ds2s(@self,SelectedObjCount);
       Selected:=false;
     end;
end;
procedure GDBObjEntity.remapcontrolpoints;
var pdesc:pcontrolpointdesc;
    i:GDBInteger;
begin
          { TODO : В примитивах нахуй ненужна проекция точек, убрать это хозяйство }
          {if ScrollMode then }renderfeedback({gdb.GetCurrentDWG.pcamera^.POSCOUNT}pcount,camera,ProjectProc,dc);
          if pp.count<>0 then
          begin
               pdesc:=pp^.getparrayaspointer;
               for i:=0 to pp.count-1 do
               begin
                    if pdesc.pobject<>nil then
                                              PGDBObjEntity(pdesc.pobject).RenderFeedback({gdb.GetCurrentDWG.pcamera^.POSCOUNT}pcount,camera,ProjectProc,dc);
                    remaponecontrolpoint(pdesc);
                    inc(pdesc);
               end;
          end;
end;
function GDBObjEntity.beforertmodify;
begin
     result:=nil;
end;
(*procedure GDBObjEntity.rtmodify;
var i:GDBInteger;
    point:pcontrolpointdesc;
    p:GDBPointer;
    var m:DMatrix4D;
    t:gdbvertex;
    tt:dvector4d;
begin
     if PSelectedObjDesc(md).pcontrolpoint^.count=0 then exit;
     if PSelectedObjDesc(md).ptempobj=nil then
     begin
          PSelectedObjDesc(md).ptempobj:=Clone(nil);
          //PSelectedObjDesc(md).ptempobj.BuildGeometry;
          PSelectedObjDesc(md).ptempobj^.bp.Owner:=bp.Owner;
          PSelectedObjDesc(md).ptempobj.format;
     end;
     p:=beforertmodify;
     if save then PSelectedObjDesc(md).pcontrolpoint^.SelectedCount:=0;
     point:=PSelectedObjDesc(md).pcontrolpoint^.parray;
     for i:=1 to PSelectedObjDesc(md).pcontrolpoint^.count do
     begin
          if point.selected then
          begin
               if save then
                           save:=save;
               m:=PSelectedObjDesc(md).objaddr^.getownermatrix^;
               tt:=m[3];
               //dist.x:=0;
               MatrixInvert(m);
               m[3,0]:=0;
               m[3,1]:=0;
               m[3,2]:=0;

               {t.x:=m[0,0];
               t.y:=m[0,1];
               t.z:=m[0,2];
               t:=normalizevertex(t);
               m[0,0]:=t.x;
               m[0,1]:=t.y;
               m[0,2]:=t.z;

               t.x:=m[1,0];
               t.y:=m[1,1];
               t.z:=m[1,2];
               t:=normalizevertex(t);
               m[1,0]:=t.x;
               m[1,1]:=t.y;
               m[1,2]:=t.z;

               t.x:=m[2,0];
               t.y:=m[2,1];
               t.z:=m[2,2];
               t:=normalizevertex(t);
               m[2,0]:=t.x;
               m[2,1]:=t.y;
               m[2,2]:=t.z;}







               //uzegeometry.NormalizeVertex(tt)

               t:=VectorTransform3D(dist,m);
               if save then
                           begin
                                rtmodifyonepoint(point,@self,VectorTransform3D(dist,m),VectorTransform3D(wc,m),p);
                                point.selected:=false;
                           end
                       else
                           rtmodifyonepoint(point,PSelectedObjDesc(md).ptempobj,VectorTransform3D(dist,m),VectorTransform3D(wc,m),p);
          end;
          inc(point);
     end;
     if save then
     begin
          //--------------(PSelectedObjDesc(md).ptempobj).rtsave(@self);

          PGDBObjGenericWithSubordinated(bp.owner)^.ImEdited(@self,bp.PSelfInOwnerArray);
          PSelectedObjDesc(md).ptempobj^.done;
          GDBFreeMem(GDBPointer(PSelectedObjDesc(md).ptempobj));
          PSelectedObjDesc(md).ptempobj:=nil;
     end
     else
     begin
          PSelectedObjDesc(md).ptempobj.format;
          //PSelectedObjDesc(md).ptempobj.renderfeedback;
     end;
     afterrtmodify(p);
end;
*)
procedure GDBObjEntity.clearrtmodify(p:GDBPointer);
begin

end;

procedure GDBObjEntity.afterrtmodify;
begin
     if p<>nil then GDBFreeMem(p);
end;
function GDBObjEntity.IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;
begin
     result:=true;
end;

procedure GDBObjEntity.transform;
begin
end;
procedure GDBObjEntity.SaveToDXFObjPrefix;
var
  tmpHandle:TDWGHandle;
begin
  dxfGDBStringout(outhandle,0,entname);
  //TODO: MyGetOrCreateValue можно желать не для всех примитивов, а только для главных функций
  //TODO: это чуток ускорит сохранение с ним 0.35сек, без 0.34~0.33 в тесте
  if notprocessHandle then begin
    tmpHandle:=IODXFContext.handle;
    inc(IODXFContext.handle);
  end else
    begin
      if IODXFContext.currentEntAddrOverrider=nil then
        IODXFContext.p2h.MyGetOrCreateValue(@self,IODXFContext.handle,tmpHandle)
      else begin
        IODXFContext.p2h.MyGetOrCreateValue(IODXFContext.currentEntAddrOverrider,IODXFContext.handle,tmpHandle);
        IODXFContext.currentEntAddrOverrider:=nil;
        inc(IODXFContext.handle);
      end;
    end;
  if $3d=tmpHandle then
    tmpHandle:=tmpHandle;

  dxfGDBStringout(outhandle,5,inttohex(tmpHandle{IODXFContext.handle}, 0));
  dxfGDBStringout(outhandle,100,dxfName_AcDbEntity);
  dxfGDBStringout(outhandle,8,vp.layer^.name);
  if vp.color<>ClByLayer then
                             dxfGDBStringout(outhandle,62,inttostr(vp.color));
  if vp.lineweight<>-1 then dxfGDBIntegerout(outhandle,370,vp.lineweight);
  if dbname<>'' then
                    dxfGDBStringout(outhandle,100,dbname);
  if vp.LineType<>{''}nil then dxfGDBStringout(outhandle,6,vp.LineType^.Name);
  if vp.LineTypeScale<>1 then dxfGDBDoubleout(outhandle,48,vp.LineTypeScale);
end;
function GDBObjEntity.IsHaveObjXData:GDBBoolean;
begin
     result:=false;
end;
function GDBObjEntity.LoadFromDXFObjShared;
var APP_NAME:GDBString;
    XGroup:GDBInteger;
    XValue:GDBString;
    Name,Value{,vn,vt,vv,vun}:GDBString;
    i:integer;
//    vd: vardesk;
begin
     result:=false;
     case dxfcod of
                5:begin
                          {$IFNDEF DELPHI}
                          if not TryStrToQWord('$'+readmystr(f),AddExtAttrib^.dwgHandle)then
                          {$ENDIF}
                          begin
                               //нужно залупиться
                          end;
                          result:=true;
                  end;
                6:begin
                       //vp.LineType:=readmystr(f);
                       vp.LineType:=drawing.GetLTypeTable.getAddres(readmystr(f));
                       result:=true
                  end;
                     8:begin
                          if {vp.layer.name=LNSysLayerName}vp.layer=@DefaultErrorLayer then
                                                   begin
                                                        name:=readmystr(f);
                                                   vp.Layer :=drawing.getlayertable.getAddres(name);
                                                   if vp.Layer=nil then
                                                                        vp.Layer:=vp.Layer;
                                                   end
                                               else
                                                   APP_NAME:=readmystr(f);
                          result:=true
                     end;
                    48:begin
                            vp.LineTypeScale :=readmystrtodouble(f);
                            result:=true
                       end;
                    62:begin
                            vp.color:=readmystrtoint(f);
                            result:=true
                       end;
                 370:begin
                          vp.lineweight :=readmystrtoint(f);
                          result:=true
                     end;
                1001:begin
                          APP_NAME:=readmystr(f);
                          result:=true;
                          if APP_NAME=ZCADAppNameInDXF then
                          begin
                               repeat
                                 XGroup:=readmystrtoint(f);
                                 XValue:=readmystr(f);
                                 if XGroup=1000 then
                                                    begin
                                                         i:=pos('=',Xvalue);
                                                         Name:=copy(Xvalue,1,i-1);
                                                         if name='' then
                                                                        name:='empty';
                                                         Value:=copy(Xvalue,i+1,length(xvalue)-i);
                                                         (*if Name='_OWNERHANDLE' then
                                                                                 begin
                                                                                      {$IFNDEF DELPHI}
                                                                                      if not TryStrToQWord('$'+value,self.AddExtAttrib^.OwnerHandle)then
                                                                                      {$ENDIF}
                                                                                      begin
                                                                                           //нужно залупиться
                                                                                      end;

                                                                                      //self.AddExtAttrib^.OwnerHandle:=StrToInt('$'+value);
                                                                                 end;
                                                         if Name='_HANDLE' then
                                                                               begin
                                                                                    {$IFNDEF DELPHI}
                                                                                    if not TryStrToQWord('$'+value,self.AddExtAttrib^.Handle)then
                                                                                    {$ENDIF}
                                                                                    begin
                                                                                         //нужно залупиться
                                                                                    end;
                                                                                    //self.AddExtAttrib^.Handle:=strtoint('$'+value);
                                                                               end;
                                                         if Name='_UPGRADE' then
                                                                               begin
                                                                                    self.AddExtAttrib^.Upgrade:=strtoint(value);
                                                                               end;
                                                         if Name='_LAYER' then
                                                                               begin
                                                                                    vp.Layer:=drawing.getlayertable.getAddres(value);
                                                                               end;

                                                    //else*)
                                                           ProcessFromDXFObjXData(Name,Value,ptu,drawing);
                                                    end;
                               until (XGroup=1002)and(XValue='}')
                          end;

                     end;
     end;

end;
class function GDBObjEntity.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjEntityDXFFeatures;
end;
function GDBObjEntity.ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef):GDBBoolean;
var
   features:TDXFEntIODataManager;
   FeatureLoadProc:TDXFEntLoadFeature;
begin
     result:=false;
     features:=GetDXFIOFeatures;
     if assigned(features) then
     begin
          FeatureLoadProc:=features.GetLoadFeature(_Name);
          if assigned(FeatureLoadProc)then
          begin
               result:=FeatureLoadProc(_Name,_Value,ptu,drawing,@self);
          end;
     end;
     {if not(result) then
     result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu,drawing);}
end;

initialization
  GDBObjEntityDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  GDBObjEntityDXFFeatures.Destroy;
end.
