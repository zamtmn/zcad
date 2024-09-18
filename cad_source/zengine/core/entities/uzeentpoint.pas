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

unit uzeentpoint;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses uzeentityfactory,uzgldrawcontext,uzeffdxfsupport,uzedrawingdef,uzecamera,
     uzestyleslayers,UGDBSelectedObjArray,
     uzeentsubordinated,uzeent3d,uzeentity,sysutils,uzctnrVectorBytes,
     uzegeometrytypes,uzbtypes,uzeconsts,uzglviewareadata,uzegeometry,
     uzeSnap,uzMVReader,uzCtnrVectorpBaseEntity;
type
PGDBObjPoint=^GDBObjPoint;
GDBObjPoint= object(GDBObj3d)
                 P_insertInOCS:GDBvertex;
                 P_insertInWCS:GDBvertex;
                 ProjPoint:GDBvertex;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;

                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 function calcinfrustum(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function CalcTrueInFrustum(const frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 function GetObjTypeName:String;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;

                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;

                 function CreateInstance:PGDBObjPoint;static;
                 function GetObjType:TObjID;virtual;
           end;

implementation
//uses
//    log;
procedure GDBObjPoint.TransformAt;
begin
  P_insertInOCS:=uzegeometry.VectorTransform3D(PGDBObjPoint(p)^.P_insertInOCS,t_matrix^);
  //format;
end;
procedure GDBObjPoint.getoutbound;
begin
     vp.BoundingBox.LBN:=P_insertInWCS;
     vp.BoundingBox.RTF:=P_insertInWCS;
     vp.BoundingBox.LBN.x:=vp.BoundingBox.LBN.x-0.1;
     vp.BoundingBox.LBN.y:=vp.BoundingBox.LBN.y-0.1;
     vp.BoundingBox.LBN.z:=vp.BoundingBox.LBN.z-0.1;
     vp.BoundingBox.RTF.x:=vp.BoundingBox.RTF.x+0.1;
     vp.BoundingBox.RTF.y:=vp.BoundingBox.RTF.y+0.1;
     vp.BoundingBox.RTF.z:=vp.BoundingBox.RTF.z+0.1;
end;
procedure GDBObjPoint.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  P_insertInWCS:=VectorTransform3D(P_insertInOCS,{CurrentCS}bp.ListPos.owner^.GetMatrix^);
  calcbb(dc);

  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
function GDBObjPoint.GetObjTypeName;
begin
     result:=ObjN_GDBObjPoint;
end;
constructor GDBObjPoint.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBPointID;
  P_insertInOCS := p;
end;
constructor GDBObjPoint.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  //vp.ID := GDBPointID;
  P_insertInOCS := NulVertex;
end;
function GDBObjPoint.GetObjType;
begin
     result:=GDBPointID;
end;
procedure GDBObjPoint.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'POINT','AcDbPoint',IODXFContext);
  dxfvertexout(outhandle,10,P_insertInOCS);
end;
procedure GDBObjPoint.LoadFromDXF;
var
  byt:Integer;
begin
  P_insertInOCS:=NulVertex;
  byt:=f.ParseInteger;
  while byt <> 0 do
  begin
    case byt of
      8  :vp.Layer :=drawing.GetLayerTable.getaddres(f.ParseString);
      10 :P_insertInOCS.x:=f.ParseDouble;
      20 :P_insertInOCS.y:=f.ParseDouble;
      30 :P_insertInOCS.z:=f.ParseDouble;
      370:vp.lineweight:=f.ParseInteger;
    else
      f.SkipString;
    end;
    byt:=f.ParseInteger;
  end;
end;

procedure GDBObjPoint.DrawGeometry;
begin
  //oglsm.myglbegin(GL_points);
  //oglsm.myglVertex3dV(@P_insertInWCS);
  //oglsm.myglend;
  dc.drawer.DrawPoint3DInModelSpace(P_insertInWCS,dc.DrawingContext.matrixs);
  {oglsm.myglbegin(GL_LINES);
  oglsm.myglVertex(P_insertInWCS.x-0.5,P_insertInWCS.y-0.5,P_insertInWCS.z);
  oglsm.myglVertex(P_insertInWCS.x+0.5,P_insertInWCS.y+0.5,P_insertInWCS.z);
  oglsm.myglVertex(P_insertInWCS.x-0.5,P_insertInWCS.y+0.5,P_insertInWCS.z);
  oglsm.myglVertex(P_insertInWCS.x+0.5,P_insertInWCS.y-0.5,P_insertInWCS.z);
  oglsm.myglend;}
  inherited;
end;
function GDBObjPoint.CalcInFrustum;
var i:Integer;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i].v[0] * P_insertInWCS.x + frustum[i].v[1] * P_insertInWCS.y + frustum[i].v[2] * P_insertInWCS.z + frustum[i].v[3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
procedure GDBObjPoint.RenderFeedback;
begin
  ProjectProc(P_insertInWCS,ProjPoint);
end;
function GDBObjPoint.getsnap;
//var t,d,e:Double;
 //   tv,n,v:gdbvertex;
begin
     if onlygetsnapcount=1 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (SnapMode and osm_point)<>0
            then
            begin
            osp.worldcoord:=P_insertInWCS;
            osp.dispcoord:=projpoint;
            osp.ostype:=os_point;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
function GDBObjPoint.onmouse;
var {t,xx,yy,}d1:Double;
    i:integer;
begin
      for i:=0 to 5 do
      begin
      d1:=MF[i].v[0] * P_insertInWCS.x + MF[i].v[1] * P_insertInWCS.y + MF[i].v[2] * P_insertInWCS.z + MF[i].v[3];
      if d1<0 then
                 begin
                      result:=false;
                      exit;
                 end;
      end;
      result:=true;
end;
function GDBObjPoint.CalcTrueInFrustum;
var {t,xx,yy,}d1:Double;
    i:integer;
begin
      for i:=0 to 5 do
      begin
      d1:=frustum[i].v[0] * P_insertInWCS.x + frustum[i].v[1] * P_insertInWCS.y + frustum[i].v[2] * P_insertInWCS.z + frustum[i].v[3];
      if d1<0 then
                 begin
                      result:=IREmpty;
                      exit;
                 end;
      end;
      result:=IRFully;
end;
procedure GDBObjPoint.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
  if pdesc^.pointtype=os_point then begin
    pdesc.worldcoord:=P_insertInOCS;
    pdesc.dispcoord.x:=round(ProjPoint.x);
    pdesc.dispcoord.y:=round(ProjPoint.y);
  end;
end;
procedure GDBObjPoint.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
          pdesc.selected:=false;
          pdesc.PDrawable:=nil;

          pdesc.pointtype:=os_point;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=P_insertInOCS;
          {pdesc.dispcoord.x:=round(ProjPoint.x);
          pdesc.dispcoord.y:=round(ProjPoint.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
procedure GDBObjPoint.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_point then begin
    P_insertInOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
  end;
end;
function GDBObjPoint.Clone;
var tvo: PGDBObjPoint;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjPoint));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, P_insertInOCS);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  result := tvo;
end;
procedure GDBObjPoint.rtsave;
begin
  pgdbobjpoint(refp)^.P_insertInOCS := P_insertInOCS;
end;
function AllocPoint:PGDBObjPoint;
begin
  Getmem(result,sizeof(GDBObjPoint));
end;
function AllocAndInitPoint(owner:PGDBObjGenericWithSubordinated):PGDBObjPoint;
begin
  result:=AllocPoint;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function GDBObjPoint.CreateInstance:PGDBObjPoint;
begin
  result:=AllocAndInitPoint(nil);
end;
begin
  RegisterDXFEntity(GDBPointID,'POINT','Point',@AllocPoint,@AllocAndInitPoint)
end.
