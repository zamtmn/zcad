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

unit GDBEntity;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBControlPointArray{,UGDBOutbound2DIArray},GDBSubordinated,
     {UGDBPolyPoint2DArray,}varman,varmandef,
     gl,
     GDBase,gdbobjectsconstdef,
     oglwindowdef,geometry,dxflow,sysutils,memman,OGLSpecFunc,UGDBOpenArrayOfByte,UGDBLayerArray;
type
//Owner:{-}PGDBObjEntity{/GDBPointer/};(*'Владелец'*)
{Export+}
PTExtAttrib=^TExtAttrib;
TExtAttrib=record
                 FreeObject:GDBBoolean;
                 OwnerHandle:GDBQWord;
                 Handle:GDBQWord;
                 Upgrade:GDBLongword;
                 ExtAttrib2:GDBBoolean;
           end;
PGDBObjEntity=^GDBObjEntity;
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=record
                      Layer:PGDBLayerProp;(*'Слой'*)(*saved_to_shd*)
                      LineWeight:GDBSmallint;(*'Вес линий'*)(*saved_to_shd*)
                      ID:GDBWord;(*'ТипОбъекта'*)(*oi_readonly*)
                      BoundingBox:GDBBoundingBbox;(*'Габарит'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      LastCameraPos:TActulity;(*oi_readonly*)
                 end;
GDBObjEntity=object(GDBObjSubordinated)
                    vp:GDBObjVisualProp;(*'Общее'*)(*saved_to_shd*)
                    Selected:GDBBoolean;(*'Выбран'*)(*hidden_in_objinsp*)
                    Visible:TActulity;(*'Видимый'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    infrustum:TActulity;(*'В камере'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    PExtAttrib:PTExtAttrib;(*hidden_in_objinsp*)
                    destructor done;virtual;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    constructor initnul(owner:PGDBObjGenericWithSubordinated);
                    procedure SaveToDXFObjPrefix(var handle:longint;var  outhandle:{GDBInteger}GDBOpenArrayOfByte;entname,dbname:GDBString);
                    function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTUnit):GDBBoolean;
                    function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;
                    procedure FromDXFPostProcessAfterAdd;virtual;
                    function IsHaveObjXData:GDBBoolean;virtual;


                    procedure createfield;virtual;
                    function AddExtAttrib:PTExtAttrib;
                    function CopyExtAttrib:PTExtAttrib;
                    procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                    procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                    procedure DXFOut(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                    procedure SaveToDXFfollow(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                    procedure SaveToDXFPostProcess(var handle:{GDBInteger}GDBOpenArrayOfByte);
                    procedure Format;virtual;
                    procedure FormatAfterEdit;virtual;

                    procedure DrawWithAttrib(visibleactualy:TActulity);virtual;
                    procedure DrawWithOutAttrib(visibleactualy:TActulity);virtual;

                    procedure DrawGeometry(lw:GDBInteger;visibleactualy:TActulity);virtual;
                    procedure DrawOnlyGeometry(lw:GDBInteger;visibleactualy:TActulity);virtual;

                    procedure Draw(lw:GDBInteger;visibleactualy:TActulity);virtual;
                    procedure DrawG(lw:GDBInteger;visibleactualy:TActulity);virtual;

                    procedure RenderFeedback;virtual;
                    procedure RenderFeedbackIFNeed;virtual;
                    function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;
                    procedure FeedbackDraw;virtual;abstract;
                    function CalculateLineWeight:GDBInteger;virtual;
                    procedure feedbackinrect;virtual;
                    function InRect:TInRect;virtual;
                    function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                    function CalcOwner(own:GDBPointer):GDBPointer;virtual;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                    procedure rtsave(refp:GDBPointer);virtual;
                    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                    procedure getoutbound;virtual;
                    procedure getonlyoutbound;virtual;
                    procedure correctbb;virtual;
                    procedure calcbb;virtual;
                    procedure DrawBB;
                    function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                    function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;
                    function isonmouse(popa:GDBPointer):GDBBoolean;virtual;
                    procedure startsnap(var osp:os_record);virtual;
                    function getsnap(var osp:os_record):GDBBoolean;virtual;
                    function getintersect(var osp:os_record;pobj:PGDBObjEntity):GDBBoolean;virtual;
                    procedure higlight;virtual;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    procedure select;virtual;
                    procedure remapcontrolpoints(pp:PGDBControlPointArray);virtual;
                    procedure rtmodify(md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
                    procedure rtmodifyonepoint(point:PControlPointDesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                    procedure transform(t_matrix:PDMatrix4D);virtual;
                    procedure remaponecontrolpoint(pdesc:PControlPointDesc);virtual;abstract;
                    function beforertmodify:GDBPointer;virtual;
                    procedure afterrtmodify(p:GDBPointer);virtual;
                    function getowner:PGDBObjSubordinated;virtual;
                    function getmatrix:PDMatrix4D;virtual;
                    function getownermatrix:PDMatrix4D;virtual;
                    function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;
                    function ReturnLastOnMouse:PGDBObjEntity;virtual;
                    function DeSelect:GDBInteger;virtual;
                    function YouDeleted:GDBInteger;virtual;
                    function GetObjTypeName:GDBString;virtual;
                    function GetObjType:GDBWord;virtual;
                    procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                    function GetLineWeight:GDBSmallint;virtual;
                    function IsSelected:GDBBoolean;virtual;
                    function GetLayer:PGDBLayerProp;virtual;
                    function GetCenterPoint:GDBVertex;virtual;
                    procedure SetInFrustum(infrustumactualy:TActulity);virtual;
                    procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;
                    procedure SetNotInFrustum(infrustumactualy:TActulity);virtual;
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                    function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;
                    procedure BuildGeometry;virtual;
                    procedure AddOnTrackAxis(posr:pos_record);virtual;
              end;
{Export-}
var onlygetsnapcount:GDBInteger;
implementation
uses UGDBEntTree,GDBGenericSubEntry,UGDBDescriptor,UGDBSelectedObjArray{,UGDBOpenArrayOfPV},UBaseTypeDescriptor,TypeDescriptors,URecordDescriptor,log;
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
procedure GDBObjEntity.AddOnTrackAxis(posr:pos_record);
begin

end;
{function GDBObjEntity.ProcessFromDXFObjXData(_Name,_Value:GDBString):GDBBoolean;
begin
     result:=inherited ProcessFromDXFObjXData(_Name,_Value);
     if not result then
     if _Name='_HANDLE' then
                           begin
                                self.AddExtAttrib^.Handle:=strtoint('$'+_value);
                           end;
     if _Name='_UPGRADE' then
                           begin
                                self.AddExtAttrib^.Upgrade:=strtoint(_value);
                           end;
end;}
procedure GDBObjEntity.BuildGeometry;
begin

end;
function GDBObjEntity.IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;
begin
     result.isintercept:=false;
end;
procedure GDBObjEntity.Draw;
begin
  if visible=visibleactualy then
  begin
       DrawGeometry(lw,visibleactualy);
  end;
end;
procedure GDBObjEntity.Drawg;
begin
  if visible=visibleactualy then
  begin
       DrawOnlyGeometry(lw,visibleactualy);
  end;
end;

procedure GDBObjEntity.createfield;
begin
     inherited;
     Selected := false;
     self.Visible:=0;
     vp.lineweight:=-1;
     if gdb.GetCurrentDWG<>nil then
                                   vp.layer:=gdb.GetCurrentDWG.LayerTable.GetSystemLayer
                               else
                                   vp.layer:=nil;
     self.PExtAttrib:=nil;
     vp.LastCameraPos:=-1;
end;
function GDBObjEntity.CalcOwner(own:GDBPointer):GDBPointer;
begin
     if own=nil then
                    result:=bp.owner
                else
                    result:=own;
end;
procedure GDBObjEntity.DrawBB;
begin
  if (sysvar.DWG.DWG_SystmGeometryDraw^){and(GDB.GetCurrentDWG.OGLwindow1.param.subrender=0)} then
  begin
  glcolor3ubv(@palette[sysvar.SYS.SYS_SystmGeometryColor^]);
  DrawAABB(vp.BoundingBox);
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
begin
     result:=nil;
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
                          if bp.owner<>nil then
                                            result:=bp.owner.IsSelected
                                           else
                                               result:=false;
                     end;
end;
procedure GDBObjEntity.correctobjects;
begin
     bp.Owner:=powner;
     bp.PSelfInOwnerArray:=pinownerarray;
end;
function GDBObjEntity.GetObjTypeName;
begin
     result:=ObjN_NotRecognized;
end;
function GDBObjEntity.GetObjType;
begin
     result:=vp.ID;
end;
function GDBObjEntity.YouDeleted;
begin
     pgdbobjgenericsubentry(bp.owner)^.EraseMi(@self,bp.PSelfInOwnerArray);
end;
function GDBObjEntity.ReturnLastOnMouse;
begin
     result:=@self;
end;
function GDBObjEntity.ObjToGDBString(prefix,sufix:GDBString):GDBString;
begin
     result:=prefix+'#'+inttohex(GDBPlatformint(@self),10)+sufix;
end;
function GDBObjEntity.getowner;
begin
     result:=PGDBObjEntity(bp.Owner)^.getowner;
end;
function GDBObjEntity.getmatrix;
begin
     result:=PGDBObjEntity(bp.Owner)^.GetMatrix;
end;
function GDBObjEntity.getownermatrix;
begin
     result:=PGDBObjEntity(bp.Owner)^.GetMatrix;
end;
procedure GDBObjEntity.DrawGeometry;
begin
     drawbb;
end;
procedure GDBObjEntity.DrawOnlyGeometry;
begin
     DrawGeometry(lw,visibleactualy);
end;
function GDBObjEntity.CalculateLineWeight;
var lw: GDBInteger;
begin
  if vp.lineweight < 0 then
  begin
    case vp.lineweight of
      -3: lw := 1;
      -2: lw := bp.owner^.{vp.lineweight}GetLineWeight;
      -1: lw := vp.layer^.lineweight;
    end
  end
  else lw := vp.lineweight;
  if sysvar.dwg.DWG_DrawMode^ = 0 then lw := 1;
  if lw <= 0 then lw := 1;
  if lw > 19 then begin
    lw := lw div 10;
    if lw>sysvar.RD.RD_MaxWidth^ then lw:=sysvar.RD.RD_MaxWidth^;
    result := lw;
    gllinewidth(lw);
    glenable(GL_LINE_SMOOTH);
    glpointsize(lw);
    glenable(gl_point_smooth);
  end
  else
  begin
    result := 1
  end;
end;
constructor GDBObjEntity.init;
begin
  createfield;
  //vp.ID := 0;
  vp.Layer := layeraddres;
  vp.LineWeight := LW;
  bp.owner:=own;
end;
constructor GDBObjEntity.initnul;
begin
     createfield;
     if owner<>nil then
                       bp.owner:=owner;
end;
procedure GDBObjEntity.DrawWithOutAttrib;
var lw: GDBInteger;
//  sel: GDBBoolean;
begin
  lw := CalculateLineWeight;
  Drawg(lw,visibleactualy);
  if lw > 1 then
  begin
    gldisable(GL_LINE_SMOOTH);
    gllinewidth(1);
    glpointsize(1);
    gldisable(gl_point_smooth);
  end;
end;
procedure GDBObjEntity.DrawWithAttrib;
var lw: GDBInteger;
  sel: GDBBoolean;
begin
  sel := false;
  lw := CalculateLineWeight;
  if bp.owner=nil then
                      bp.owner:=nil;
  if selected or ((bp.owner <> nil) and (bp.owner^.isselected)) then
                                                                    begin
                                                                      glLineStipple(3, ls);
                                                                      glEnable(GL_LINE_STIPPLE);
                                                                      sel := true;
                                                                      glStencilFunc(GL_ALWAYS,0,1);

                                                                      glPolygonStipple(@ps);
                                                                      glEnable(GL_POLYGON_STIPPLE);

                                                                      {if bp.TreePos.Owner<>nil then
                                                                                          PTEntTreeNode(bp.TreePos.Owner).draw;}
                                                                    end
                                                                else
                                                                    begin
                                                                         glStencilFunc(GL_EQUAL,0,1);
                                                                    end;
  {if (POGLWnd.subrender = 0) or
     (PGDBLayerPropArray(GDB.layertable.parray)^[vp.layer].name <> '0')
      then glcolor3ubv(@palette[PGDBLayerPropArray(GDB.layertable.parray)^[vp.layer].color])
      else glcolor3ubv(@palette[PGDBLayerPropArray(GDB.layertable.parray)^[owner.vp.layer].color]);}
  self:=self;
  if (GDB.GetCurrentDWG.OGLwindow1.param.subrender = 0)
      then
          begin
                                                    if vp.layer^.color<>7 then
                                                                              glcolor3ubv(@palette[vp.layer^.color])
                                                                          else
                                                                              begin
                                                                                   glcolor3ub(not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b))
                                                                              end;
          end
      else
          if (vp.layer^.name <> LNSysLayerName) then
                                                    begin
                                                    if vp.layer^.color<>7 then
                                                                              glcolor3ubv(@palette[vp.layer^.color])
                                                                          else
                                                                              begin
                                                                                   glcolor3ub(not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b))
                                                                              end;
                                                    end
                                                else
                                                    begin
                                                    if bp.owner.getlayer^.color<>7 then
                                                                              glcolor3ubv(@palette[bp.owner.getlayer^.color])
                                                                          else
                                                                              begin
                                                                                   glcolor3ub(not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b))
                                                                              end;
                                                         //glcolor3ubv(@palette[bp.owner.getlayer^.color]);
                                                    end;



  Draw(lw,visibleactualy);

  if lw > 1 then
  begin
    gldisable(GL_LINE_SMOOTH);
    gllinewidth(1);
    glpointsize(1);
    gldisable(gl_point_smooth);
  end;
  if sel then
             begin
                  gldisable(GL_LINE_STIPPLE);
                  gldisable(GL_POLYGON_STIPPLE);
             end;
end;
procedure GDBObjEntity.RenderFeedbackIFNeed;
begin
     if vp.LastCameraPos<>gdb.GetCurrentDWG.pcamera^.POSCOUNT then
                                                               Renderfeedback;

end;
procedure GDBObjEntity.Renderfeedback;
begin
     vp.LastCameraPos:=gdb.GetCurrentDWG.pcamera^.POSCOUNT;
  //DrawGeometry;
end;

procedure GDBObjEntity.format;
begin
end;
procedure GDBObjEntity.FormatAfterEdit;
begin
     format;
end;
procedure GDBObjEntity.higlight;
begin
end;
procedure GDBObjEntity.SetInFrustum;
begin
     //result:=infrustum;
     infrustum:=infrustumactualy;
     inc(gdb.GetCurrentDWG.pcamera^.totalobj);
     inc(gdb.GetCurrentDWG.pcamera^.infrustum);
end;
procedure GDBObjEntity.SetNotInFrustum;
begin
     //result:=infrustum;
     //infrustum:=false;
     inc(gdb.GetCurrentDWG.pcamera^.totalobj);
end;
procedure GDBObjEntity.DXFOut;
begin
     SaveToDXF(handle, outhandle);
     SaveToDXFPostProcess(outhandle);
     SaveToDXFFollow(handle, outhandle);
end;
procedure GDBObjEntity.SaveToDXF;
begin
end;
procedure GDBObjEntity.SaveToDXFfollow;
begin
end;
procedure GDBObjEntity.SaveToDXFPostProcess;
var
   isvarobject,ishavevars{,ishavex}:boolean;
   pvd:pvardesk;
   pfd:PFieldDescriptor;
   pvu:PTUnit;
   ir,ir2:itrec;
   str,sv:gdbstring;
   i:integer;
   tp:pointer;
begin
     isvarobject:=false;
     ishavevars:=false;
     //ishavex:=IsHaveObjXData;
     if ou.InterfaceVariables.vardescarray.Count>0 then
                                                       ishavevars:=true;
     if self.PExtAttrib<>nil then
       if self.PExtAttrib^.FreeObject  then
                                           isvarobject:=true;

    //if (isvarobject or ishavevars)or ishavex then
    begin
         dxfGDBStringout(handle,1001,'DSTP_XDATA');
         dxfGDBStringout(handle,1002,'{');
         if isvarobject then
                            dxfGDBStringout(handle,1000,'VAROBJECT=');
         if ishavevars then
                           begin
                                pvu:=ou.InterfaceUses.beginiterate(ir);
                                if pvu<>nil then
                                repeat
                                      str:='USES='+pvu^.Name;
                                      dxfGDBStringout(handle,1000,str);
                                pvu:=ou.InterfaceUses.iterate(ir);
                                until pvu=nil;

                                i:=0;
                                pvd:=ou.InterfaceVariables.vardescarray.beginiterate(ir);
                                if pvd<>nil then
                                repeat
                                      if (pvd^.data.PTD.GetTypeAttributes and TA_COMPOUND)=0 then
                                      begin
                                           sv:=PBaseTypeDescriptor(pvd^.data.ptd)^.GetValueAsString(pvd^.data.Instance);
                                           str:='#'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName;
                                           str:=str+'|'+sv+'|'+pvd^.username;
                                           dxfGDBStringout(handle,1000,str);
                                      end
                                      else
                                      begin
                                           str:='&'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName+'|'+pvd^.username;
                                           dxfGDBStringout(handle,1000,str);
                                           inc(i);
                                           tp:=pvd^.data.Instance;
                                           pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.beginiterate(ir2);
                                           if pfd<>nil then
                                           repeat
                                                 str:='$'+inttostr(i)+'='+pvd^.name+'|'+pfd^.FieldName+'|'+pfd^.PFT^.GetValueAsString(tp);
                                                 dxfGDBStringout(handle,1000,str);
                                                 GDBPlatformint(tp):=GDBPlatformint(tp)+pfd^.PFT^.SizeInGDBBytes; { TODO : сделать на оффсете }
                                                 inc(i);
                                                 pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.iterate(ir2);
                                           until pfd=nil;
                                           str:='&'+inttostr(i)+'=END';
                                           //dxfGDBStringout(handle,1000,str);
                                           inc(i);
                                      end;

                                inc(i);
                                pvd:=ou.InterfaceVariables.vardescarray.iterate(ir);
                                until pvd=nil;

                           end;
         //if ishavex then

         self.SaveToDXFObjXData(handle);
         dxfGDBStringout(handle,1002,'}');

    end;
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
      if CalcInFrustum(frustum,infrustumactualy,visibleactualy) then
                           begin
                                setinfrustum(infrustumactualy);
                           end
                       else
                           begin
                                setnotinfrustum(infrustumactualy);
                                visible:=0;
                                result:=false;
                           end;
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

procedure GDBObjEntity.correctbb;
var cv:gdbvertex;
const minoffsetstart=0.5;
      basedist=100;
      onedivbasedist=1/basedist;
begin
     cv:=VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
     cv:=VertexMulOnSc(cv,onedivbasedist);
     if cv.x<minoffsetstart then
                                cv.x:=minoffsetstart;
     if cv.y<minoffsetstart then
                                cv.y:=minoffsetstart;
     if cv.z<minoffsetstart then
                                cv.z:=minoffsetstart;

     vp.BoundingBox.LBN:=VertexSUB(vp.BoundingBox.LBN,cv);
     vp.BoundingBox.RTF:=VertexAdd(vp.BoundingBox.RTF,cv);
end;
procedure GDBObjEntity.calcbb;
begin
     getoutbound;
     correctbb;
end;
procedure GDBObjEntity.getoutbound;
begin
end;
procedure GDBObjEntity.getonlyoutbound;
begin
     getoutbound;
end;
function GDBObjEntity.GetOsnapPoint;
begin
end;
function GDBObjEntity.isonmouse;
begin
     if vp.Layer^._on then
                          result:=onmouse(popa,GDB.GetCurrentDWG.OGLwindow1.param.mousefrustum)
                      else
                          result:=false;
end;
function GDBObjEntity.onmouse;
begin
     result:=false;
end;
procedure GDBObjEntity.feedbackinrect;
begin
     if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse
     then
     begin
          if inrect<>IREmpty then
              begin
                   select;
              end;
     end
     else
     begin
          if inrect=IRFully then
              begin
                   select;
              end;
     end;
end;
function GDBObjEntity.InRect:TInRect;
begin
     result:=IREmpty;
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
end;

procedure GDBObjEntity.rtsave;
begin
end;
procedure GDBObjEntity.startsnap;
begin
     onlygetsnapcount:=0;
     osp.PGDBObject:=@self;
end;
function GDBObjEntity.getsnap;
begin
     result:=false;
end;
function GDBObjEntity.getintersect;
begin
     result:=false;
end;
procedure GDBObjEntity.select;
var tdesc:pselectedobjdesc;
begin
     if selected=false then
     begin
          selected:=true;
          tdesc:=gdb.GetCurrentDWG.SelObjArray.addobject(@self);
          if tdesc<>nil then
          begin
          GDBGetMem({$IFDEF DEBUGBUILD}'{B50BE8C9-E00A-40C0-A051-230877BD3A56}',{$ENDIF}GDBPointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
          addcontrolpoints(tdesc);
          bp.Owner.ImSelected(@self,bp.PSelfInOwnerArray);
          inc(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
          end;
     end;
end;
function GDBObjEntity.DeSelect;
var tdesc:pselectedobjdesc;
    ir:itrec;
begin
     if selected then
     begin
          tdesc:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
          if tdesc<>nil then
          repeat
                if tdesc^.objaddr=@self then
                                            begin
                                                 gdb.GetCurrentDWG.SelObjArray.freeelement(tdesc);
                                                 {tdesc:=}gdb.GetCurrentDWG.SelObjArray.deleteelementbyp(tdesc);
                                            end;

                tdesc:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
          until tdesc=nil;
          Selected:=false;
          dec(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
     end;
end;
procedure GDBObjEntity.remapcontrolpoints;
var pdesc:pcontrolpointdesc;
    i:GDBInteger;
begin
          if GDB.GetCurrentDWG.OGLwindow1.param.scrollmode then renderfeedback;
          if pp.count<>0 then
          begin
               pdesc:=pp^.parray;
               for i:=0 to pp.count-1 do
               begin
                    remaponecontrolpoint(pdesc);
                    inc(pdesc);
               end;
          end;
end;
function GDBObjEntity.beforertmodify;
begin
     result:=nil;
end;
procedure GDBObjEntity.rtmodify;
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







               //geometry.NormalizeVertex(tt)
               t:=VectorTransform3D(dist,m);
               rtmodifyonepoint(point,PSelectedObjDesc(md).ptempobj,VectorTransform3D(dist,m),VectorTransform3D(wc,m),p);
               if save then
                           point.selected:=false;
          end;
          inc(point);
     end;
     if save then
     begin
          (PSelectedObjDesc(md).ptempobj).rtsave(@self);
          //format;
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
procedure GDBObjEntity.afterrtmodify;
begin
     if p<>nil then GDBFreeMem(p);
end;
procedure GDBObjEntity.transform;
begin
end;
procedure GDBObjEntity.SaveToDXFObjPrefix;
begin
  dxfGDBStringout(outhandle,0,entname);
  dxfGDBStringout(outhandle,5,inttohex(handle, 0));
  inc(handle);
  dxfGDBStringout(outhandle,100,'AcDbEntity');
  dxfGDBStringout(outhandle,8,vp.layer^.name);
  if vp.lineweight<>-1 then dxfGDBIntegerout(outhandle,370,vp.lineweight);
  if dbname<>'' then
                    dxfGDBStringout(outhandle,100,dbname);
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
                   8:begin
                          if vp.layer.name='0' then
                                                   vp.Layer :=gdb.GetCurrentDWG.LayerTable.getAddres(readmystr(f))
                                               else
                                                   APP_NAME:=readmystr(f);
                          result:=true
                     end;
                 370:begin
                          vp.lineweight :=readmystrtoint(f);
                          result:=true
                     end;
                1001:begin
                          APP_NAME:=readmystr(f);
                          result:=true;
                          if APP_NAME='DSTP_XDATA'then
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
                                                         {if Name='VAROBJECT' then
                                                                                 begin
                                                                                      self.AddExtAttrib^.FreeObject:=true;
                                                                                 end;}
                                                         if Name='_OWNERHANDLE' then
                                                                                 begin
                                                                                      if not TryStrToQWord('$'+value,self.AddExtAttrib^.OwnerHandle)then
                                                                                      begin
                                                                                           //нужно залупиться
                                                                                      end;

                                                                                      //self.AddExtAttrib^.OwnerHandle:=StrToInt('$'+value);
                                                                                 end;
                                                         if Name='_HANDLE' then
                                                                               begin

                                                                                    if not TryStrToQWord('$'+value,self.AddExtAttrib^.Handle)then
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
                                                                                    vp.Layer:=gdb.GetCurrentDWG.LayerTable.getAddres(value);
                                                                               end;

                                                    //else
                                                           ProcessFromDXFObjXData(Name,Value,ptu);
                                                    end;
                               until (XGroup=1002)and(XValue='}')
                          end;

                     end;
     end;

end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBEntity.initialization');{$ENDIF}
end.
