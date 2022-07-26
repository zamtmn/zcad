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
{$INCLUDE zengineconfig.inc}

interface
uses gzctnrVector,uzeentityfactory,uzeentsubordinated,
     uzgldrawcontext,uzedrawingdef,uzecamera,uzglviewareadata,
     uzeentcurve,UGDBVectorSnapArray,uzegeometry,uzestyleslayers,uzeentity,
     UGDBPoint3DArray,UGDBPolyLine2DArray,
     uzctnrVectorBytes,uzbtypes,uzeentwithlocalcs,uzeconsts,math,
     gzctnrVectorTypes,uzegeometrytypes,uzeffdxfsupport,sysutils,
     UGDBSelectedObjArray,uzctnrvectorpgdbaseobjects;
type
//----------------snaparray:GDBVectorSnapArray;(*hidden_in_objinsp*)
{Export+}
PGLLWWidth=^GLLWWidth;
{REGISTERRECORDTYPE GLLWWidth}
GLLWWidth=record
                startw:Double;(*saved_to_shd*)
                endw:Double;(*saved_to_shd*)
                hw:Boolean;(*saved_to_shd*)
                quad:GDBQuad2d;
          end;
{REGISTEROBJECTTYPE GDBLineWidthArray}
GDBLineWidthArray= object(GZVector{-}<GLLWWidth>{//})(*OpenArrayOfData=GLLWWidth*)
             end;
{REGISTEROBJECTTYPE TWidth3D_in_WCS_Vector}
TWidth3D_in_WCS_Vector= object(GZVector{-}<GDBQuad3d>{//})
                end;
PGDBObjLWPolyline=^GDBObjLWpolyline;
{REGISTEROBJECTTYPE GDBObjLWPolyline}
GDBObjLWPolyline= object(GDBObjWithLocalCS)
                 Closed:Boolean;(*saved_to_shd*)
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*saved_to_shd*)
                 Vertex3D_in_WCS_Array:GDBPoint3dArray;
                 Width2D_in_OCS_Array:GDBLineWidthArray;(*saved_to_shd*)
                 Width3D_in_WCS_Array:{GDBOpenArray}TWidth3D_in_WCS_Vector;
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 Square:Double;(*'Oriented area'*)
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:Boolean);
                 constructor initnul;
                 procedure LoadFromDXF(var f: TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 function CalcSquare:Double;virtual;
                 //**попадаетли данная координата внутрь контура
                 function isPointInside(point:GDBVertex):Boolean;virtual;
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
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 //function InRect:TInRect;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 procedure startsnap(out osp:os_record; out pdata:Pointer);virtual;
                 procedure endsnap(out osp:os_record; var pdata:Pointer);virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;

                 procedure higlight(var DC:TDrawContext);virtual;


                 class function CreateInstance:PGDBObjLWPolyline;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
implementation
procedure GDBObjLWpolyline.higlight(var DC:TDrawContext);
begin
end;
function GDBObjLWpolyline.GetTangentInPoint(point:GDBVertex):GDBVertex;
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
function GDBObjLWpolyline.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;
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
var
pv1,pv2:pgdbvertex;
begin
      result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum);
      if (result=IREmpty)and(Vertex3D_in_WCS_Array.count>3) then
                                          begin
                                               pv1:=Vertex3D_in_WCS_Array.getDataMutable(0);
                                               pv2:=Vertex3D_in_WCS_Array.getDataMutable(Vertex3D_in_WCS_Array.Count-1);
                                               result:=uzegeometry.CalcTrueInFrustum(pv1^,pv2^,frustum);
                                          end;
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
var tpo: PGDBObjLWPolyline;
    p:PGDBVertex2D;
    pw:PGLLWWidth;
    i:Integer;
begin
  Getmem(Pointer(tpo), sizeof(GDBObjLWPolyline));
  tpo^.init({bp.owner}own,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  tpo^.Local:=local;
  //tpo^.vertexarray.init(1000);
  p:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  pw:=Width2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do
  begin
      tpo^.Vertex2D_in_OCS_Array.PushBackData(p^);
      tpo^.Width2D_in_OCS_Array.PushBackData(pw^);
      inc(p);
      inc(pw);
  end;

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
  Vertex2D_in_OCS_Array.init(1000,c);
  Width2D_in_OCS_Array.init(1000);
  Vertex3D_in_WCS_Array.init(1000);
  Width3D_in_WCS_Array.init(1000);
  //----------------snaparray.init(1000);
  PProjPoint:=nil;
end;
constructor GDBObjLWpolyline.initnul;
begin
  inherited initnul(nil);
  //vp.id:=GDBLWPolylineID;
  {убрать в афтердесериализе}
  Vertex2D_in_OCS_Array.init(1000,false);
  Width2D_in_OCS_Array.init(1000);
  Vertex3D_in_WCS_Array.init(1000);
  Width3D_in_WCS_Array.init(1000{, sizeof(GDBQuad3d)});
  //----------------snaparray.init(1000);
  PProjPoint:=nil;
end;
function GDBObjLWpolyline.GetObjType;
begin
     result:=GDBLWPolylineID;
end;
procedure GDBObjLWpolyline.DrawGeometry;
var i,ie: Integer;
    q3d:PGDBQuad3d;
    plw:PGLlwwidth;
    v:gdbvertex;
begin
  {glPolygonMode(GL_FRONT_AND_BACK, GL_fill);
  if closed then
    for i := 0 to vertexarray.count - 1 do
    begin
      begin
                                      //oglsm.myglEnable(GL_LIGHTING);
        myglbegin(GL_QUADS);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[0]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[1]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[2]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[3]);
        myglend();
                                      //oglsm.myglDisable(GL_LIGHTING);
      end;
      begin
        myglbegin(GL_LINEs);
        glVertex2dv(@PGDBArrayVertex2D(vertexarray.parray)^[i]);
        if i <> vertexarray.count - 1 then
          glVertex2dv(@PGDBArrayVertex2D(vertexarray.parray)^[i + 1])
        else
          glVertex2dv(@PGDBArrayVertex2D(vertexarray.parray)^[0]);
        myglend();
      end;
    end
  else
    for i := 0 to vertexarray.count - 2 do
    begin
                                  //if PGDBlwpolyline(temp)^.pwidtharray^.widtharray[i2].hw then
      begin
                                      //oglsm.myglEnable(GL_LIGHTING);
        myglbegin(GL_QUADS);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[0]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[1]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[2]);
        glVertex2dv(@PGDBArrayGLlwwidth(widtharray.PArray)^[i].quad[3]);
        myglend();
                                      //oglsm.myglDisable(GL_LIGHTING);
      end;
                                  //else
      begin
        myglbegin(GL_LINE_STRIP);
        glVertex2dv(@PGDBArrayVertex2D(vertexarray.parray)^[i]);
        glVertex2dv(@PGDBArrayVertex2D(vertexarray.parray)^[i + 1]);
        myglend();
      end;
    end;}
    {if closed then myglbegin(GL_LINE_LOOP)
              else myglbegin(GL_LINE_STRIP);
    Vertex3D_in_WCS_Array.iterategl(@myglVertex3dv);
    myglend();}
    v:=uzegeometry.VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);

    if not CanSimplyDrawInWCS(DC,uzegeometry.oneVertexlength(v),5) then
    if Width3D_in_WCS_Array.parray<>nil then
           begin
                q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
                dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
                {oglsm.myglbegin(GL_Lines);
                oglsm.myglVertex3dv(@q3d^[0]);
                oglsm.myglVertex3dv(@q3d^[1]);
                oglsm.myglend();}
                exit;
           end;

    if closed then ie:=Width3D_in_WCS_Array.count - 1
              else ie:=Width3D_in_WCS_Array.count - 2;


    q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
    plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
    for i := 0 to ie do
    begin
      begin
        if plw^.hw then
        begin
        dc.drawer.DrawQuad3DInModelSpace(q3d^[0],q3d^[1],q3d^[2],q3d^[3],dc.DrawingContext.matrixs);
        {oglsm.myglbegin(GL_QUADS);
        oglsm.myglVertex3dv(@q3d^[0]);
        oglsm.myglVertex3dv(@q3d^[1]);
        oglsm.myglVertex3dv(@q3d^[2]);
        oglsm.myglVertex3dv(@q3d^[3]);
        oglsm.myglend();}
        end;
        inc(plw);
        inc(q3d);
      end;
   end;

    //oglsm.myglbegin(GL_Lines);
    q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
    plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
    for i := 0 to ie do
    begin
      begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
        //oglsm.myglVertex3dv(@q3d^[0]);
        //oglsm.myglVertex3dv(@q3d^[1]);
        if plw^.hw then
        begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[1],q3d^[2],dc.DrawingContext.matrixs);
        //oglsm.myglVertex3dv(@q3d^[1]);
        //oglsm.myglVertex3dv(@q3d^[2]);
        dc.drawer.DrawLine3DInModelSpace(q3d^[2],q3d^[3],dc.DrawingContext.matrixs);
        //oglsm.myglVertex3dv(@q3d^[2]);
        //oglsm.myglVertex3dv(@q3d^[3]);
        dc.drawer.DrawLine3DInModelSpace(q3d^[3],q3d^[0],dc.DrawingContext.matrixs);
        //oglsm.myglVertex3dv(@q3d^[3]);
        //oglsm.myglVertex3dv(@q3d^[0]);
        end;
        inc(plw);
        inc(q3d);
      end;
   end;
   //oglsm.myglend();
   inherited;



    {myglbegin(GL_LINE_STRIP);
    vertexarray.iterate(@glVertex2dv);
    myglend();}
end;

procedure GDBObjLWpolyline.LoadFromDXF;
var p: gdbvertex2d;
  s: String;
  byt, code, i: Integer;
  hlGDBWord: LongWord;
  tDouble: Double;
  numv: Integer;
begin
  //inherited init(nil,0, -1);
  hlGDBWord:=0;
  numv:=0;
  //vp.id:=GDBLWPolylineID;
  //bp.ListPos.owner:=@drawing;
  if bp.ListPos.owner<>nil then
                               local.p_insert:={w0^}PGDBVertex(@bp.ListPos.owner^.GetMatrix^[3])^
                           else
                               local.P_insert:=nulvertex;;
  closed := false;
  Width2D_in_OCS_Array.createarray;
  (*Vertex2D_in_OCS_Array.init(1000,closed);
  Width2D_in_OCS_Array.init(1000);
  Vertex3D_in_WCS_Array.init(1000);
  Width3D_in_WCS_Array.init(1000, sizeof(GDBQuad3d));
  *)
  s := f.readString;
  val(s, byt, code);
  while byt <> 0 do
  begin
    case byt of
      8:
        begin
          s := f.readString;
          vp.Layer :=drawing.getlayertable.getAddres(s);
        end;
      62:begin
              vp.color:=readmystrtoint(f);
         end;
      90:
        begin
          s := f.readString;
          hlGDBWord := strtoint(s);
          //vertexarray.init(hlGDBWord,closed);
          //vertexarray.init(hlGDBWord, sizeof(gdbvertex2d));
          //normalarray.init(hlGDBWord, sizeof(gdbvertex));
          //widtharray.init(hlGDBWord, sizeof(GLLWWidth));
          numv := hlGDBWord;
          hlGDBWord := 0;
        end;
      10:
        begin
          s := f.readString;
          val(s, p.x, code);
        end;
      20:
        begin
          s := f.readString;
          val(s, p.y, code);
          Vertex2D_in_OCS_Array.PushBackData(p);
          inc(hlGDBWord);
        end;
      38:
        begin
          s := f.readString;
          val(s, local.p_insert.z, code);
          //local.p_insert.z:=-local.p_insert.z;
        end;
      40:
        begin
          s := f.readString;
          //val(s, PGLLWWidth(Width2D_in_OCS_Array.getelement(hlGDBWord-1)).startw, code);
          Width2D_in_OCS_Array.SetCount(hlGDBWord);
          val(s, PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord-1)).startw, code);
        end;
      41:
        begin
          s := f.readString;
          Width2D_in_OCS_Array.SetCount(hlGDBWord);
          val(s, PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord- 1)).endw, code);
          //Width2D_in_OCS_Array.SetCount(hlGDBWord);
        end;
      43:
        begin
          s := f.readString;
          val(s, tDouble, code);
          if Width2D_in_OCS_Array.Max<numv then
                                               Width2D_in_OCS_Array.setsize(numv);
          Width2D_in_OCS_Array.Count := numv;
          for i := 0 to numv - 1 do
          begin
            PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).endw := tDouble;
            PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).startw := tDouble;
          end;
          Width2D_in_OCS_Array.Count := numv;
        end;
      70:
        begin
          s := f.readString;
          if (strtoint(s) and 1) = 1 then closed := true;
        end;
      210:
        begin
          s := f.readString;
          val(s, Local.basis.oz.x, code);
        end;
      220:
        begin
          s := f.readString;
          val(s, Local.basis.oz.y, code);
        end;
      230:
        begin
          s := f.readString;
          val(s, Local.basis.oz.z, code);
        end;
      370:
        begin
          s := f.readString;
          vp.lineweight := strtoint(s);
        end;
    else
      s := f.readString;
    end;
    s := f.readString;
    val(s, byt, code);
  end;
  Vertex2D_in_OCS_Array.Shrink;
  Width2D_in_OCS_Array.Shrink;
  //Vertex3D_in_WCS_Array.Shrink;
  //Width3D_in_WCS_Array.Shrink;
  //format;
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
function GDBObjLWpolyline.isPointInside(point:GDBVertex):Boolean;
var m: DMatrix4D;
    p:GDBVertex2D;
begin
     m:=self.getmatrix^;
     uzegeometry.MatrixInvert(m);
     point:=VectorTransform3D(point,m);
     p.x:=point.x;
     p.y:=point.y;
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

procedure GDBObjLWpolyline.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
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
begin
  RegisterDXFEntity(GDBLWPolylineID,'LWPOLYLINE','LWPolyline',@AllocLWpolyline,@AllocAndInitLWpolyline);
end.
