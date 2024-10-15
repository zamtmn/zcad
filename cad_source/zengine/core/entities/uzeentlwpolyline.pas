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

unit uzeentlwpolyline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses gzctnrVector,uzeentityfactory,uzeentsubordinated,
     uzgldrawcontext,uzedrawingdef,uzecamera,uzglviewareadata,
     uzeentcurve,UGDBVectorSnapArray,uzegeometry,uzestyleslayers,uzeentity,
     UGDBPoint3DArray,UGDBPolyLine2DArray,
     uzctnrVectorBytes,uzbtypes,uzeentwithlocalcs,uzeconsts,math,
     gzctnrVectorTypes,uzegeometrytypes,uzeffdxfsupport,sysutils,
     UGDBSelectedObjArray,uzMVReader,
     uzCtnrVectorpBaseEntity;
type

PGLLWWidth=^GLLWWidth;
GLLWWidth=record
                startw:Double;
                endw:Double;
                hw:Boolean;
                quad:GDBQuad2d;
          end;
GDBLineWidthArray= object(GZVector<GLLWWidth>)
             end;
TWidth3D_in_WCS_Vector= object(GZVector<GDBQuad3d>)
                end;
PGDBObjLWPolyline=^GDBObjLWpolyline;
GDBObjLWPolyline= object(GDBObjWithLocalCS)
                 Closed:Boolean;
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;
                 Vertex3D_in_WCS_Array:GDBPoint3dArray;
                 Width2D_in_OCS_Array:GDBLineWidthArray;
                 Width3D_in_WCS_Array:TWidth3D_in_WCS_Vector;
                 PProjPoint:PGDBpolyline2DArray;
                 Square:Double;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:Boolean);
                 constructor initnul;
                 procedure LoadFromDXF(var f:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 function CalcSquare:Double;virtual;
                 //**попадаетли данная координата внутрь контура
                 function isPointInside(const point:GDBVertex):Boolean;virtual;
                 procedure createpoint;virtual;
                 procedure CalcWidthSegment;virtual;
                 destructor done;virtual;
                 function GetObjTypeName:String;virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 function CalcTrueInFrustum(const frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 //function InRect:TInRect;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 procedure startsnap(out osp:os_record; out pdata:Pointer);virtual;
                 procedure endsnap(out osp:os_record; var pdata:Pointer);virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 function GetTangentInPoint(const point:GDBVertex):GDBVertex;virtual;

                 procedure higlight(var DC:TDrawContext);virtual;


                 class function CreateInstance:PGDBObjLWPolyline;static;
                 function GetObjType:TObjID;virtual;
           end;
implementation
var
   lwtv:GDBpolyline2DArray;
procedure GDBObjLWpolyline.higlight(var DC:TDrawContext);
begin
end;
function GDBObjLWpolyline.GetTangentInPoint(const point:GDBVertex):GDBVertex;
var //tv:gdbvertex;
    ptv,ppredtv:pgdbvertex;
    ir:itrec;
    found:integer;

begin
     if not closed then
                   begin
                        ppredtv:=Vertex3D_in_WCS_Array.beginiterate(ir);
                        ptv:=Vertex3D_in_WCS_Array.iterate(ir);
                   end
                else
                    begin
                           if Vertex3D_in_WCS_Array.Count<3 then
                                                        exit;
                           ptv:=Vertex3D_in_WCS_Array.beginiterate(ir);
                           ppredtv:=Vertex3D_in_WCS_Array.getDataMutable(Vertex3D_in_WCS_Array.Count-1);
                    end;
  found:=0;
  if (ptv<>nil)and(ppredtv<>nil) then
  repeat
        if (abs(ptv^.x-point.x)<eps)
       and (abs(ptv^.y-point.y)<eps)
       and (abs(ptv^.z-point.z)<eps)
                                             then
                                                 begin
                                                      found:=2;
                                                 end
   else if (found=0)and({distance2piece}SQRdist_Point_to_Segment(point,ppredtv^,ptv^)<bigeps) then begin
                                                          found:=1;
                                                     end;

        if found>0 then
                       begin
                            result:=vertexsub(ptv^,ppredtv^);
                            result:=uzegeometry.NormalizeVertex(result);
                            exit;
                            //processaxis(posr,result);
                            //result:=uzegeometry.CrossVertex(tv,zwcs);
                            //processaxis(posr,result);
                            dec(found);
                       end;

        ppredtv:=ptv;
        ptv:=Vertex3D_in_WCS_Array.iterate(ir);
  until ptv=nil;
end;

{function GDBObjLWpolyline.InRect;
var i:Integer;
    ptpv:PGDBPolyVertex2D;
begin
     if pprojoutbound<>nil then if self.pprojoutbound^.inrect=IRFully then
     begin
          result:=IRFully;
          exit;
     end;
     //if POGLWnd^.seldesc.MouseFrameInverse then
     if PProjPoint.inrect=IRPartially then
     begin
          result:=IRPartially;
          exit;
     end;
     result:=IREmpty;
end;}
procedure GDBObjLWpolyline.TransformAt;
begin
    inherited;
    Vertex2D_in_OCS_Array.clear;
    pGDBObjLWpolyline(p)^.Vertex2D_in_OCS_Array.copyto(Vertex2D_in_OCS_Array);
    Vertex2D_in_OCS_Array.transform(t_matrix^);
end;

procedure GDBObjLWpolyline.transform;
//var tv,tv2:GDBVertex4D;
begin
 inherited;
 Vertex2D_in_OCS_Array.transform(t_matrix);
end;
procedure GDBObjLWpolyline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(Vertex3D_in_WCS_Array,posr,processaxis,closed);
end;
procedure GDBObjLWpolyline.startsnap(out osp:os_record; out pdata:Pointer);
begin
     inherited;
     Getmem(pdata,sizeof(GDBVectorSnapArray));
     PGDBVectorSnapArray(pdata).init(Vertex3D_in_WCS_Array.Max);
     BuildSnapArray(Vertex3D_in_WCS_Array,PGDBVectorSnapArray(pdata)^,closed);
end;

procedure GDBObjLWpolyline.endsnap(out osp:os_record; var pdata:Pointer);
begin
     if pdata<>nil then
                       begin
                            PGDBVectorSnapArray(pdata)^.{FreeAnd}Done;
                            Freemem(pdata);
                       end;
     inherited;
end;

function GDBObjLWpolyline.getsnap;
begin
     result:=GDBPoint3dArraygetsnap(Vertex3D_in_WCS_Array,PProjPoint,{snaparray}PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;
function GDBObjLWpolyline.onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;
begin
     if Vertex3D_in_WCS_Array.onpoint(point,closed) then
                                                begin
                                                     result:=true;
                                                     objects.PushBackData(@self);
                                                end
                                            else
                                                result:=false;
end;

function GDBObjLWpolyline.onmouse;
var
   ie,i:Integer;
   q3d:PGDBQuad3d;
   p3d,p3dold:PGDBVertex;
   subresult:TInBoundingVolume;
begin

    result:=false;
  if closed then
                ie:=Width3D_in_WCS_Array.count
            else
                ie:=Width3D_in_WCS_Array.count - 1;


  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  p3d:=Vertex3D_in_WCS_Array.GetParrayAsPointer;
  p3dold:=p3d;
  inc(p3d);
  for i := 1 to ie do
  begin
    begin
            if i=Vertex3D_in_WCS_Array.count then
                                           p3d:=Vertex3D_in_WCS_Array.GetParrayAsPointer;

      subresult:=CalcOutBound4VInFrustum(q3d^,mf);
          if subresult=IRFully then
                                  begin
                                       result:=true;
                                       exit;
                                    end
     else if subresult=IRPartially then
                                        begin
                                             if uzegeometry.CalcTrueInFrustum (q3d^[0],q3d^[1],mf)<>irempty then
                                                                                          begin
                                                                                               result:=true;
                                                                                               exit;
                                                                                          end;
                                             if uzegeometry.CalcTrueInFrustum (q3d^[1],q3d^[2],mf)<>irempty then
                                                                                          begin
                                                                                               result:=true;
                                                                                               exit;
                                                                                          end;
                                             if uzegeometry.CalcTrueInFrustum (q3d^[2],q3d^[3],mf)<>irempty then
                                                                                          begin
                                                                                               result:=true;
                                                                                               exit;
                                                                                          end;
                                             if uzegeometry.CalcTrueInFrustum (q3d^[3],q3d^[0],mf)<>irempty then
                                                                                          begin
                                                                                               result:=true;
                                                                                               exit;
                                                                                          end;
                                        end;
          if uzegeometry.CalcTrueInFrustum (p3d^,p3dold^,mf)<>irempty then
                                                       begin
                                                            result:=true;
                                                            exit;
                                                       end;

      inc(q3d);
      inc(p3dold);
      inc(p3d);
    end;
 end;
    {subresult:=CalcOutBound4VInFrustum(PInWCS,mf);
    if subresult<>IRPartially then
                               if subresult=irempty then
                                                        exit
                                                    else
                                                        begin
                                                             result:=true;
                                                             exit;
                                                        end;
    result:=true;

  if VertexArrayInWCS.count<2 then
                                  begin
                                       result:=false;
                                       exit;
                                  end;
   result:=VertexArrayInWCS.onmouse(mf);}
end;
function GDBObjLWpolyline.CalcTrueInFrustum;
begin
  result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,closed);
end;
procedure GDBObjLWpolyline.getoutbound;
var //tv,tv2:GDBVertex4D;
    t,b,l,r,n,f:Double;
    ptv:pgdbvertex;
    ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  n:=Infinity;
  r:=NegInfinity;
  t:=NegInfinity;
  f:=NegInfinity;
  ptv:=Vertex3D_in_WCS_Array.beginiterate(ir);
  if ptv<>nil then
  begin
  repeat
        if ptv.x<l then
                 l:=ptv.x;
        if ptv.x>r then
                 r:=ptv.x;
        if ptv.y<b then
                 b:=ptv.y;
        if ptv.y>t then
                 t:=ptv.y;
        if ptv.z<n then
                 n:=ptv.z;
        if ptv.z>f then
                 f:=ptv.z;
        ptv:=Vertex3D_in_WCS_Array.iterate(ir);
  until ptv=nil;
  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(r,T,f);

  end
              else
  begin
  vp.BoundingBox.LBN:=CreateVertex(-1,-1,-1);
  vp.BoundingBox.RTF:=CreateVertex(1,1,1);
  end;
end;
procedure GDBObjLWpolyline.rtsave;
var p,pold:pgdbvertex2d;
    i:Integer;
begin
  inherited;
  p:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  pold:=PGDBObjLWPolyline(refp)^.Vertex2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do
  begin
      pold^:=p^;
      inc(pold);
      inc(p);
  end;
  //PGDBObjLWPolyline(refp)^.format;
end;
procedure GDBObjLWpolyline.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:Integer;
    tv,wwc:gdbvertex;

    M: DMatrix4D;
begin
  vertexnumber:=rtmod.point.vertexnum;

  m:=self.ObjMatrix;

  {m[3][0]:=0;
  m[3][1]:=0;
  m[3][2]:=0;}

  uzegeometry.MatrixInvert(m);


  tv:=rtmod.dist;
  wwc:=rtmod.point.worldcoord;

  wwc:=VertexAdd(wwc,tv);

  //tv:=uzegeometry.VectorTransform3D(tv,m);
  wwc:=uzegeometry.VectorTransform3D(wwc,m);


  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].x:=wwc.x{VertexAdd(wwc,tv)};
  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].y:=wwc.y;
end;
procedure GDBObjLWpolyline.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:Integer;
begin
     vertexnumber:=pdesc^.vertexnum;
     pdesc.worldcoord:=GDBPoint3dArray.PTArr(Vertex3D_in_WCS_Array.parray)^[vertexnumber];
     pdesc.dispcoord.x:=round(GDBPolyline2DArray.PTArr(PProjPoint.parray)^[vertexnumber].x);
     pdesc.dispcoord.y:=round(GDBPolyline2DArray.PTArr(PProjPoint.parray)^[vertexnumber].y);
end;
procedure GDBObjLWpolyline.AddControlpoints;
var pdesc:controlpointdesc;
    i:Integer;
    //pv2d:pGDBvertex2d;
    pv:pGDBvertex;
begin
          //renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(Vertex3D_in_WCS_Array.count);
          //pv2d:=pprojpoint^.parray;
          pv:=Vertex3D_in_WCS_Array.GetParrayAsPointer;
          pdesc.selected:=false;
          pdesc.PDrawable:=nil;

          for i:=0 to {pprojpoint}Vertex3D_in_WCS_Array.count-1 do
          begin
               pdesc.vertexnum:=i;
               pdesc.attr:=[CPA_Strech];
               pdesc.worldcoord:=pv^;
               {pdesc.dispcoord.x:=round(pv2d^.x);
               pdesc.dispcoord.y:=round(pv2d.y);}
               PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
               inc(pv);
               //inc(pv2d);
          end;
end;
function GDBObjLWpolyline.Clone;
var
  tpo: PGDBObjLWPolyline;
begin
  Getmem(Pointer(tpo), sizeof(GDBObjLWPolyline));
  tpo^.init({bp.owner}own,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  tpo^.Local:=local;
  //tpo^.vertexarray.init(1000);
  tpo^.Vertex2D_in_OCS_Array.SetSize(Vertex2D_in_OCS_Array.Count);
  Vertex2D_in_OCS_Array.copyto(tpo^.Vertex2D_in_OCS_Array);
  tpo^.Width2D_in_OCS_Array.SetSize(Width2D_in_OCS_Array.Count);
  Width2D_in_OCS_Array.copyto(tpo^.Width2D_in_OCS_Array);
  result := tpo;
end;
function GDBObjLWpolyline.GetObjTypeName;
begin
     result:=ObjN_GDBObjLWPolyLine;
end;
destructor GDBObjLWpolyline.done;
begin
     if pprojpoint<>nil then
                            begin
                            pprojpoint^.done;
                            Freemem(pointer(pprojpoint));
                            end;
     Vertex2D_in_OCS_Array.done;
     Width2D_in_OCS_Array.done;
     Vertex3D_in_WCS_Array.done;
     Width3D_in_WCS_Array.done;
     //----------------snaparray.done;
     inherited done;//  error
end;
constructor GDBObjLWpolyline.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.id:=GDBLWPolylineID;
  closed := c;
  Vertex2D_in_OCS_Array.init(4,c);
  Width2D_in_OCS_Array.init(4);
  Vertex3D_in_WCS_Array.init(4);
  Width3D_in_WCS_Array.init(4);
  //----------------snaparray.init(1000);
  PProjPoint:=nil;
end;
constructor GDBObjLWpolyline.initnul;
begin
  inherited initnul(nil);
  //vp.id:=GDBLWPolylineID;
  {убрать в афтердесериализе}
  Vertex2D_in_OCS_Array.init(4,false);
  Width2D_in_OCS_Array.init(4);
  Vertex3D_in_WCS_Array.init(4);
  Width3D_in_WCS_Array.init(4{, sizeof(GDBQuad3d)});
  //----------------snaparray.init(1000);
  PProjPoint:=nil;
end;
function GDBObjLWpolyline.GetObjType;
begin
     result:=GDBLWPolylineID;
end;
procedure GDBObjLWpolyline.DrawGeometry;
var
  i,ie: integer;
  q3d:PGDBQuad3d;
  plw:PGLlwwidth;
  v:gdbvertex;
  simplydraw:boolean;
begin

  if dc.lod=LODCalculatedDetail then begin
    v:=uzegeometry.VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
    simplydraw:=not SqrCanSimplyDrawInWCS(DC,uzegeometry.SqrOneVertexlength(v),49);
  end else
    simplydraw:=dc.lod=LODLowDetail;

  if simplydraw then begin
    q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
    if q3d<>nil then begin
      //if dc.lod=LODLowDetail then
      //  dc.drawer.SetLineWidth(2);

      if Width3D_in_WCS_Array.Count>15 then begin
        if Width3D_in_WCS_Array.parray<>nil then begin
          ie:=(Width3D_in_WCS_Array.Count div 4)+4;
          for i := 0 to (Width3D_in_WCS_Array.Count-2)div ie do begin
            dc.drawer.DrawLine3DInModelSpace(
              q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
            Inc(q3d,ie);
          end;
        end;
      end else if Width3D_in_WCS_Array.Count>2 then begin
        dc.drawer.DrawLine3DInModelSpace(vp.BoundingBox.LBN,vp.BoundingBox.RTF,
                                         dc.DrawingContext.matrixs);
      end else begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],
                                         dc.DrawingContext.matrixs);
      end;
    end;
    exit;
  end;

  //dc.drawer.SetLineWidth(lw);

  if closed then ie:=Width3D_in_WCS_Array.Count - 1
  else
    ie:=Width3D_in_WCS_Array.Count - 2;


  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
  for i := 0 to ie do begin
    begin
      if plw^.hw then
        dc.drawer.DrawQuad3DInModelSpace(q3d^[0],q3d^[1],q3d^[2],
          q3d^[3],dc.DrawingContext.matrixs);
      Inc(plw);
      Inc(q3d);
    end;
  end;

  //oglsm.myglbegin(GL_Lines);
  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
  for i := 0 to ie do begin
    begin
      dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
      if plw^.hw then begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[1],q3d^[2],dc.DrawingContext.matrixs);
        dc.drawer.DrawLine3DInModelSpace(q3d^[2],q3d^[3],dc.DrawingContext.matrixs);
        dc.drawer.DrawLine3DInModelSpace(q3d^[3],q3d^[0],dc.DrawingContext.matrixs);
      end;
      Inc(plw);
      Inc(q3d);
    end;
  end;
  inherited;
end;

procedure GDBObjLWpolyline.LoadFromDXF;
var
  p:gdbvertex2d;
  byt,i:Integer;
  hlGDBWord:LongWord;
  numv:Integer;
  widthload:boolean;
  globalwidth:double;
begin
  hlGDBWord:=0;
  numv:=0;
  globalwidth:=0;
  widthload:=false;
  closed:=false;
  if bp.ListPos.owner<>nil then
    local.p_insert:=PGDBVertex(@bp.ListPos.owner^.GetMatrix^[3])^
  else
    local.P_insert:=nulvertex;

  byt:=f.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
      case byt of
        8  :vp.Layer:=drawing.getlayertable.getAddres(f.ParseShortString);
        62 :vp.color:=f.ParseInteger;
        90 :begin
          numv:=f.ParseInteger;
          Width2D_in_OCS_Array.SetSize(numv);
          hlGDBWord:=0;
        end;
        10 :p.x:=f.ParseDouble;
        20 :begin
          p.y:=f.ParseDouble;
          lwtv.PushBackData(p);
          inc(hlGDBWord);
        end;
        38 :local.p_insert.z:=f.ParseDouble;
        40 :begin
          Width2D_in_OCS_Array.SetCount(numv);
          PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord-1)).startw:=f.ParseDouble;
          widthload:=true;
        end;
        41 :begin
          Width2D_in_OCS_Array.SetCount(numv);
          PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord- 1)).endw:=f.ParseDouble;
          widthload:=true;
        end;
        43 :globalwidth:=f.ParseDouble;
        70 :closed:=(f.ParseInteger and 1)=1;
        210:Local.basis.oz.x:=f.ParseDouble;
        220:Local.basis.oz.y:=f.ParseDouble;
        230:Local.basis.oz.z:=f.ParseDouble;
        370:vp.lineweight:=f.ParseInteger;
      else
        f.SkipString;
    end;
    byt:=f.ParseInteger;
  end;
  if not widthload then begin
    Width2D_in_OCS_Array.SetCount(numv);
    for i := 0 to numv - 1 do begin
      PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).endw := globalwidth;
      PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).startw := globalwidth;
    end;
  end;
  Vertex2D_in_OCS_Array.SetSize(lwtv.Count);
  lwtv.copyto(Vertex2D_in_OCS_Array);
  lwtv.Clear;
  Width2D_in_OCS_Array.Shrink;
end;

procedure GDBObjLWpolyline.SaveToDXF;
var j: Integer;
    tv:gdbvertex;
    //m:DMatrix4D;
begin
  SaveToDXFObjPrefix(outhandle,'LWPOLYLINE','AcDbPolyline',IODXFContext);
  dxfStringout(outhandle,90,inttostr(Vertex2D_in_OCS_Array.Count));
  //WriteString_EOL(outhandle, '90');
  //WriteString_EOL(outhandle, inttostr(Vertex2D_in_OCS_Array.Count));


  //WriteString_EOL(outhandle, '70');
  if closed then //WriteString_EOL(outhandle, '1')
                 dxfStringout(outhandle,70,'1')
            else //WriteString_EOL(outhandle, '0');
                 dxfStringout(outhandle,70,'0');


  dxfDoubleout(outhandle,38,local.p_insert.z);
  //WriteString_EOL(outhandle, '38');
  //WriteString_EOL(outhandle, floattostr(local.p_insert.z));

  {m:=}CalcObjMatrixWithoutOwner;//наверно это ненужно. надо проверить
  //MatrixTranspose(m);

  for j := 0 to (Vertex2D_in_OCS_Array.Count - 1) do
  begin
       tv.x:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].x;
       tv.y:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].y;
       tv.z:=0;
       //tv:=uzegeometry.VectorTransform3D(tv,m);
    dxfvertex2dout(outhandle,10,PGDBVertex2D(@tv)^);
    //dxfvertex2dout(outhandle,10,PGDBArrayVertex2D(Vertex2D_in_OCS_Array.PArray)^[j]);
    dxfDoubleout(outhandle,40,PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(j)).startw);
    dxfDoubleout(outhandle,41,PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(j)).endw);
  end;
  SaveToDXFObjPostfix(outhandle);
end;
function GDBObjLWpolyline.isPointInside(const point:GDBVertex):Boolean;
var m: DMatrix4D;
    p:GDBVertex2D;
begin
     m:=self.getmatrix^;
     uzegeometry.MatrixInvert(m);
     with VectorTransform3D(point,m) do
     begin
       p.x:=x;
       p.y:=y;
     end;
     result:=Vertex2D_in_OCS_Array.ispointinside(p);
end;

function GDBObjLWpolyline.CalcSquare:Double;
var
    pv,pvnext:PGDBVertex2D;
    i:integer;

begin
    result:=0;
    if Vertex2D_in_OCS_Array.count<2 then exit;

    pv:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
    pvnext:=pv;
    inc(pvnext);
    for i:=1 to Vertex2D_in_OCS_Array.count do
    begin
       if i=Vertex2D_in_OCS_Array.count then
                                            pvnext:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
       result:=result+(pv.x+pvnext.x)*(pv.y-pvnext.y);
       inc(pv);
       inc(pvnext);
    end;
    result:=result/2;
end;

procedure GDBObjLWpolyline.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
     Vertex2D_in_OCS_Array.Shrink;
     Width2D_in_OCS_Array.Shrink;
     inherited FormatEntity(drawing,dc);
     createpoint;
     CalcWidthSegment;
     Square:=CalcSquare;
     calcbb(dc);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjLWpolyline.createpoint;
var
  i: Integer;
  v:GDBvertex4D;
  v3d:GDBVertex;
  pv:PGDBVertex2D;
begin
  Vertex3D_in_WCS_Array.clear;
  pv:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.count-1 do
  begin
       v.x:=pv.x;
       v.y:=pv.y;
       v.z:=0;
       v.w:=1;
       v:=VectorTransform(v,objMatrix);
       v3d:=PGDBvertex(@v)^;
       Vertex3D_in_WCS_Array.PushBackData(v3d);
       inc(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
  //----------------BuildSnapArray(Vertex3D_in_WCS_Array,snaparray,closed);
end;
procedure GDBObjLWpolyline.Renderfeedback;
var tv:GDBvertex;
    tpv:GDBVertex2D;
    ptpv:PGDBVertex;
    i:Integer;
begin
  if pprojpoint=nil then
  begin
       Getmem(Pointer(pprojpoint),sizeof(GDBpolyline2DArray));
       pprojpoint^.init(Vertex3D_in_WCS_Array.count,closed);
  end;
  pprojpoint^.clear;
                    ptpv:=Vertex3D_in_WCS_Array.GetParrayAsPointer;
                    for i:=0 to Vertex3D_in_WCS_Array.count-1 do
                    begin
                         ProjectProc(ptpv^,tv);
                         tpv.x:=tv.x;
                         tpv.y:=tv.y;
                         PprojPoint^.PushBackData(tpv);
                         inc(ptpv);
                    end;

end;
procedure GDBObjLWpolyline.CalcWidthSegment;
var
  i, j, k: Integer;
  dx, dy, nx, ny, l: Double;
  v2di,v2dj:PGDBVertex2D;
  plw,plw2:PGLlwwidth;
  //q2d:GDBQuad2d;
  q3d:GDBQuad3d;
  pq3d,pq3dnext:pGDBQuad3d;
  v:GDBvertex4D;
  v2:PGDBvertex;
  ip,ip2:Intercept3DProp;
begin
  //Width2D_in_OCS_Array.clear;
  Width3D_in_WCS_Array.clear;
  for i := 0 to Vertex2D_in_OCS_Array.count - 1 do
  begin
    if i <> Vertex2D_in_OCS_Array.count - 1 then j := i + 1
                                            else j := 0;
    v2dj:=Vertex2D_in_OCS_Array.getDataMutable(j);
    v2di:=Vertex2D_in_OCS_Array.getDataMutable(i);
    dx := v2dj^.x - v2di^.x;
    dy := v2dj^.y - v2di^.y;
    nx := -dy;
    ny := dx;
    l := sqrt(nx * nx + ny * ny);
    if abs(l)>eps then
                      begin
                            nx := nx / l;
                            ny := ny / l;
                      end
                  else
                      begin
                            nx :=0;
                            ny :=0;
                      end;

    plw:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(i));

    if (plw^.startw = 0) and (plw^.endw = 0) then plw^.hw := false
                                             else plw^.hw := true;
      plw^.quad[0].x := v2di^.x + nx * plw^.startw / 2;
      plw^.quad[0].y := v2di^.y + ny * plw^.startw / 2;

      plw^.quad[1].x := v2dj^.x + nx * plw^.endw / 2;
      plw^.quad[1].y := v2dj^.y + ny * plw^.endw / 2;

      plw^.quad[2].x := v2dj^.x - nx * plw^.endw / 2;
      plw^.quad[2].y := v2dj^.y - ny * plw^.endw / 2;

      plw^.quad[3].x := v2di^.x - nx * plw^.startw / 2;
      plw^.quad[3].y := v2di^.y - ny * plw^.startw / 2;

      for k:=0 to 3 do
      begin
           v.x:=plw^.quad[k].x;
           v.y:=plw^.quad[k].y;
           v.z:=0;
           v.w:=1;
           v:=VectorTransform(v,objMatrix);
           q3d[k]:=PGDBvertex(@v)^;
      end;
      Width3D_in_WCS_Array.PushBackData(q3d);
  end;
  Width2D_in_OCS_Array.Shrink;
  Width3D_in_WCS_Array.Shrink;

  if closed then k:=Width3D_in_WCS_Array.count - 1
            else k:=Width3D_in_WCS_Array.count - 2;
  for i := 0 to k do
  if (i<>k)or closed then
  begin
    if i <> Width3D_in_WCS_Array.count - 1 then j := i + 1
                                           else j := 0;
    plw:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(i));
    plw2:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(j));
    if plw.hw and plw2.hw then
    begin
    if plw.endw>plw2.startw then l:=plw.endw
                            else l:=plw2.startw;
    l:=4*l*l;
    pq3d:=Width3D_in_WCS_Array.getDataMutable(i);
    pq3dnext:=Width3D_in_WCS_Array.getDataMutable(j);
    ip:=intercept3dmy2(pq3d^[0] ,pq3d^[1],pq3dnext^[1] ,pq3dnext^[0]);
    ip2:=intercept3dmy2(pq3d^[3] ,pq3d^[2],pq3dnext^[2] ,pq3dnext^[3]);

    if ip.isintercept and ip2.isintercept then
    if (ip.t1>0) and (ip.t2>0) then
    if (ip2.t1>0) and (ip2.t2>0) then
    {if (ip.t1<2) and (ip.t2<2) then
    if (ip2.t1<2) and (ip2.t2<2) then}
    begin
         v2:=Pgdbvertex(Vertex3D_in_WCS_Array.getDataMutable(j));
         if SqrVertexlength(v2^,ip.interceptcoord)<l then
         if SqrVertexlength(v2^,ip2.interceptcoord)<l then
         begin
         pq3d^[1]:=ip.interceptcoord;
         pq3d^[2]:=ip2.interceptcoord;
         pq3dnext^[0]:=ip.interceptcoord;
         pq3dnext^[3]:=ip2.interceptcoord;
         end;
    end;
    end;

  end;
end;

function AllocLWpolyline:PGDBObjLWpolyline;
begin
  Getmem(pointer(result),sizeof(GDBObjLWpolyline));
end;

function AllocAndInitLWpolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjLWpolyline;
begin
  result:=AllocLWpolyline;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;

class function GDBObjLWpolyline.CreateInstance:PGDBObjLWpolyline;
begin
  result:=AllocAndInitLWpolyline(nil);
end;

procedure SetLWpolylineGeomProps(ALWpolyLine:PGDBObjLWpolyline; const args:array of const);
var
   counter:integer;
   i,c:integer;
   pw:PGLLWWidth;
   pp:PGDBvertex2D;
begin
  counter:=low(args);
  ALWpolyLine.Closed:=CreateBooleanFromArray(counter,args);
  c:=(high(args)-low(args){+1})div 5;
  if ((high(args)-low(args){+1})mod 5)>1 then
    inc(c);
  if ALWpolyLine.Closed then
    ALWpolyLine.Width2D_in_OCS_Array.SetCount(c)
  else
    ALWpolyLine.Width2D_in_OCS_Array.SetCount(c{-1});
  ALWpolyLine.Vertex2D_in_OCS_Array.SetCount(c);
  for i:=0 to c-1 do begin
    pp:=ALWpolyLine.Vertex2D_in_OCS_Array.getDataMutable(i);
    pp^:=CreateVertex2DFromArray(counter,args);
    if (ALWpolyLine.Closed)or(i<(c-1)) then begin
      {bulge:=}CreateDoubleFromArray(counter,args);
      pw:=ALWpolyLine.Width2D_in_OCS_Array.getDataMutable(i);
      pw.startw:=CreateDoubleFromArray(counter,args);
      pw.endw:=CreateDoubleFromArray(counter,args);
      pw.hw:=IsDoubleNotEqual(pw.startw,0) or IsDoubleNotEqual(pw.endw,0);
    end;
  end;
end;

function AllocAndCreateLWpolyline(owner:PGDBObjGenericWithSubordinated; const args:array of const):PGDBObjLWPolyline;
begin
  result:=AllocAndInitLWpolyline(owner);
  SetLWpolylineGeomProps(result,args);
end;

initialization
  lwtv.init(200,false);
  RegisterDXFEntity(GDBLWPolylineID,'LWPOLYLINE','LWPolyline',@AllocLWpolyline,@AllocAndInitLWpolyline,@SetLWpolylineGeomProps,@AllocAndCreateLWpolyline);
  finalization
  lwtv.done;
end.
