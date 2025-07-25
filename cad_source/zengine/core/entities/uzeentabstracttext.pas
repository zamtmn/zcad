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
unit uzeentabstracttext;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses UGDBSelectedObjArray,
     uzgldrawcontext,uzeentity,uzecamera,
     uzbstrproc,sysutils,uzeentplainwithox,
     UGDBOutbound2DIArray,uzegeometrytypes,uzbtypes,uzegeometry,math,
     uzglviewareadata,uzeSnap,uzedrawingdef,
     uzCtnrVectorpBaseEntity;
type

PGDBTextProp=^GDBTextProp;
GDBTextProp=record
                  size:Double;
                  oblique:Double;
                  wfactor:Double;
                  justify:TTextJustify;
                  upsidedown:Boolean;
                  backward:Boolean;
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText= object(GDBObjPlainWithOX)
                         textprop:GDBTextProp;
                         P_drawInOCS:GDBvertex;
                         DrawMatrix:DMatrix4D;
                         procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                         procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                         function CalcInFrustum(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                         function CalcTrueInFrustum(const frustum:ClipArray):TInBoundingVolume;virtual;
                         function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                         procedure addcontrolpoints(tdesc:Pointer);virtual;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);virtual;
                         procedure ReCalcFromObjMatrix;virtual;
                         function CalcRotate:Double;virtual;
                         procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
                         procedure setrot(r:Double);
                         procedure transform(const t_matrix:DMatrix4D);virtual;
                         procedure rtsave(refp:Pointer);virtual;
                   end;
var
   SysVarRDPanObjectDegradation:Boolean=false;

implementation

procedure GDBObjAbstractText.rtsave(refp:Pointer);
begin
  inherited;
  PGDBObjAbstractText(refp)^.textprop:=textprop;
end;


procedure GDBObjAbstractText.transform;
var
  tv:GDBVertex;
  m:DMatrix4D;
begin
  tv:=CreateVertex(0,textprop.size,0);
  m:=t_matrix;
  PGDBVertex(@m.mtr[3])^:=NulVertex;

  tv:=VectorTransform3d(tv,m);
  textprop.size:=oneVertexlength(tv);
  inherited;
end;
procedure GDBObjAbstractText.setrot(r:Double);
var m1:DMatrix4D;
   sine,cosine:double;
begin
{m1:=onematrix;
SinCos(r,sine,cosine);
m1.mtr[0].v[0]:=cosine;
m1.mtr[1].v[1]:=cosine;
m1.mtr[1].v[0]:=-sine;
m1.mtr[0].v[1]:=sine;}
m1:=CreateRotationMatrixZ(r);
objMatrix:=MatrixMultiply(m1,objMatrix);
end;

procedure GDBObjAbstractText.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
(*var
   r:double;
   ox:gdbvertex;
   {m,}m2,m3:DMAtrix4D;*)
begin
     { fixedTODO : removeing angle from text ents }
     (*
     if PField=@textprop.angle then
                                   begin
                                        //m:=self.CalcObjMatrixWithoutOwner;
                                        m2:=self.getownermatrix^;
                                        m3:=m2;
                                        matrixinvert(m3);
                                        objMatrix:=MatrixMultiply(m3,objMatrix);
                                        if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                                                       ox:=VectorDot(YWCS,{PGDBVertex(@m[2])^}Local.basis.oz)
                                                                                                   else
                                                                                                       ox:=VectorDot(ZWCS,{PGDBVertex(@m[2])^}Local.basis.oz);
                                        r:=scalardot({PGDBVertex(@m[0])^}Local.basis.ox,ox);
                                        r:=arccos(r);
                                        setrot(-r);
                                        r:=textprop.angle;
                                        setrot(textprop.angle);
                                        ReCalcFromObjMatrix;
                                        objMatrix:=MatrixMultiply(m2,objMatrix);
                                        textprop.angle:=r;
                                   end;
     inherited;
     *)
end;

procedure GDBObjAbstractText.ReCalcFromObjMatrix;
{var
    ox:gdbvertex;}
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix.mtr[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix.mtr[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix.mtr[3])^;

     {scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x;
     scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;}

     {if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=VectorDot(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=VectorDot(ZWCS,Local.basis.oz);
     normalizevertex(ox);}
     { fixedTODO : removeing angle from text ents }
     (*
     textprop.angle:=scalardot(Local.basis.ox,ox);
     textprop.angle:=arccos(textprop.angle);
     if local.basis.OX.y<-eps then textprop.angle:=2*pi-textprop.angle;
     *)
     //Local.basis.ox:=ox;
end;

function GDBObjAbstractText.CalcRotate:Double;
(*var
    ox:gdbvertex;
begin
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     {scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x;
     scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;}

     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=VectorDot(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=VectorDot(ZWCS,Local.basis.oz);
     normalizevertex(ox);
     result:=scalardot(Local.basis.ox,ox);
     result:=arccos(result);
     if local.basis.OX.y<-eps then result:=2*pi-result;
end;*)
var
    v1,v2:GDBVertex;
    l1,l0:Double;
    //a0,a1,a:double;
begin

     if bp.ListPos.owner<>nil then begin
       V1:=PGDBvertex(@bp.ListPos.owner^.GetMatrix^.mtr[0])^;
       l0:=scalardot(NormalizeVertex(V1),_X_yzVertex);
       l0:=arccos(l0);
       if v1.y<-eps then l0:=2*pi-l0;
       //a0:=l0*180/pi
     end else
       l0:=0;

     V1:=Local.basis.ox;
     V2:=GetXfFromZ(Local.basis.oz);
     l1:=scalardot(v1,v2);
     l1:=arccos(l1);
     if v1.y<-eps then l1:=2*pi-l1;
     //a1:=l0*180/pi;
     l1:=l1+L0;
     if l1>2*pi then l1:=l1-2*pi;
     result:=l1;
end;
procedure GDBObjAbstractText.remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);
var
  tv:GDBvertex;
begin
  if pdesc^.pointtype=os_point then begin
    pdesc.worldcoord:=P_insert_in_WCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end;
end;
procedure GDBObjAbstractText.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
          pdesc.selected:=false;
          pdesc.PDrawable:=nil;
          pdesc.pointtype:=os_point;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=P_insert_in_WCS;//Local.P_insert;
          {pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(ProjP_insert.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
(*function GDBObjAbstractText.InRect;
//var i:Integer;
//    ptpv:PGDBPolyVertex2D;
begin
     if pprojoutbound<>nil then
     if self.pprojoutbound^.inrect=IRFully then
     begin
          result:=IRFully;
          exit;
     end;
     //if POGLWnd^.seldesc.MouseFrameInverse then
     {if Vertex2D_in_DCS_Array.inrect=IRPartially then
     begin
          result:=IRPartially;
          exit;
     end;}
     result:=IREmpty;
end;*)
function GDBObjAbstractText.onmouse;
var //i,counter:Integer;
    //d:Double;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInBoundingVolume;
begin
  result:=false;
  {if pprojoutbound^.count<4 then exit;
  i:=pprojoutbound^.onmouse;
  if i=2 then
     begin
          result:=true;
          exit;
     end;
   if i=0 then
              exit;}
    subresult:=CalcOutBound4VInFrustum(outbound,mf);
    if subresult<>IRPartially then
                               if subresult=irempty then
                                                        exit
                                                    else
                                                        begin
                                                             result:=true;
                                                             exit;
                                                        end;

    if Representation.CalcTrueInFrustum (mf,false)<>IREmpty then
                                                 result:=true
                                             else
                                                 result:=false;

   {if Vertex3D_in_WCS_Array.count<2 then exit;
   ptpv0:=Vertex3D_in_WCS_Array.parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   while i<(Vertex3D_in_WCS_Array.count-1) do
   begin
     if counter<=0 then counter:=ptpv0^.count;
     if uzegeometry.CalcTrueInFrustum (ptpv1^.coord,ptpv0^.coord,mf)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
     if result then
                   exit;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                       end
                   else
                       begin
                            inc(i);
                            dec(counter);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;}
end;
function GDBObjAbstractText.CalcInFrustum;
var i:Integer;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i].v[0] * outbound[0].x + frustum[i].v[1] * outbound[0].y + frustum[i].v[2] * outbound[0].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[1].x + frustum[i].v[1] * outbound[1].y + frustum[i].v[2] * outbound[1].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[2].x + frustum[i].v[1] * outbound[2].y + frustum[i].v[2] * outbound[2].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[3].x + frustum[i].v[1] * outbound[3].y + frustum[i].v[2] * outbound[3].z + frustum[i].v[3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjAbstractText.CalcTrueInFrustum;
//var i,count:Integer;
//    d1,d2,d3,d4:Double;
begin
      result:=CalcOutBound4VInFrustum(outbound,frustum);
      if result<>IRPartially then
                                 exit;
      result:=Representation.CalcTrueInFrustum(frustum,true);
end;
procedure GDBObjAbstractText.CalcObjMatrix;
var m1,m2,m3:DMatrix4D;
    angle:Double;
begin
  inherited CalcObjMatrix;
  if textprop.upsidedown then
  begin
        PGDBVertex(@objmatrix.mtr[1])^.x:=-Local.basis.oy.x;
        PGDBVertex(@objmatrix.mtr[1])^.y:=-Local.basis.oy.y;
        PGDBVertex(@objmatrix.mtr[1])^.z:=-Local.basis.oy.z;
  end;
  if textprop.backward then
  begin
        PGDBVertex(@objmatrix.mtr[0])^.x:=-Local.basis.ox.x;
        PGDBVertex(@objmatrix.mtr[0])^.y:=-Local.basis.ox.y;
        PGDBVertex(@objmatrix.mtr[0])^.z:=-Local.basis.ox.z;
  end;
  m1:= OneMatrix;

  {m1[0,0]:=cos(self.textprop.angle*pi/180);
  m1[1,1]:=cos(self.textprop.angle*pi/180);
  m1[1,0]:=-sin(self.textprop.angle*pi/180);
  m1[0,1]:=sin(self.textprop.angle*pi/180);}
  objMatrix:=MatrixMultiply(m1,objMatrix);




  //m1 := OneMatrix;

  angle:=(pi/2-textprop.oblique);
  if abs(angle-pi/2)>eps then begin
    m1.CreateRec(OneMtr,CMTShear);
    m1.mtr[1].v[0]:=cotan(angle);
  end else
    m1:=OneMatrix;

  //m2:= OneMatrix;
  //Pgdbvertex(@m2.mtr[3])^:=P_drawInOCS;
  m2:=CreateTranslationMatrix(P_drawInOCS);

  //m3:=OneMatrix;
  //m3.mtr[0].v[0] := textprop.wfactor*textprop.size;
  //m3.mtr[1].v[1] := textprop.size;
  //m3.mtr[2].v[2] := textprop.size;
  m3:=CreateScaleMatrix(textprop.wfactor*textprop.size,textprop.size,textprop.size);

  DrawMatrix:=MatrixMultiply(m3,m1);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);
end;

procedure GDBObjAbstractText.DrawGeometry;
var
   PanObjectDegradation:boolean;
begin
  dc.subrender := dc.subrender + 1;
  PanObjectDegradation:=SysVarRDPanObjectDegradation;
  if(not dc.scrollmode)or(not PanObjectDegradation)then
    Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState)
  else begin
    DC.Drawer.DrawLine3DInModelSpace(outbound[0],outbound[1],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[1],outbound[2],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[2],outbound[3],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[3],outbound[0],DC.DrawingContext.matrixs);
  end;
  dc.subrender := dc.subrender - 1;
  inherited;
end;
begin
end.
