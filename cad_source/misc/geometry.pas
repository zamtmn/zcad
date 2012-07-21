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

unit geometry;
{$INCLUDE def.inc}

interface
uses zcadstrconsts,gdbase,gdbasetypes, math;
const
      EmptyMatrix: DMatrix4D = ((0, 0, 0, 0),
                                (0, 0, 0, 0),
                                (0, 0, 0, 0),
                                (0, 0, 0, 0));
        OneMatrix: DMatrix4D = ((1, 0, 0, 0),
                                (0, 1, 0, 0),
                                (0, 0, 1, 0),
                                (0, 0, 0, 1));
        TwoMatrix: DMatrix4D = ((2, 0, 0, 0),
                                (0, 2, 0, 0),
                                (0, 0, 2, 0),
                                (0, 0, 0, 2));
      eps=1e-14;
      sqreps=1e-7;
      bigeps=1e-10;
      x=0;y=1;z=2;w=3;
      ScaleOne:GDBVertex=(x:1;y:1;z:1);
      OneVertex:GDBVertex=(x:1;y:1;z:1);
      xy_Z_Vertex:GDBVertex=(x:0;y:0;z:1);
      x_Y_zVertex:GDBVertex=(x:0;y:1;z:0);
      _X_yzVertex:GDBVertex=(x:1;y:0;z:0);
      MinusOneVertex:GDBVertex=(x:-1;y:-1;z:-1);
      MinusInfinityVertex:GDBVertex=(x:-Infinity;y:-Infinity;z:-Infinity);
      InfinityVertex:GDBVertex=(x:Infinity;y:Infinity;z:Infinity);
      NulVertex4D:GDBVertex4d=(x:0;y:0;z:0;w:1);
      NulVector4D:DVector4D=(0,0,0,0);
      NulVertex:GDBVertex=(x:0;y:0;z:0);
      XWCS:GDBVertex=(x:1;y:0;z:0);
      YWCS:GDBVertex=(x:0;y:1;z:0);
      ZWCS:GDBVertex=(x:0;y:0;z:1);
      XWCS4D:DVector4D=(1,0,0,1);
      YWCS4D:DVector4D=(0,1,0,1);
      ZWCS4D:DVector4D=(0,0,1,1);
      NulVertex2D:GDBVertex2D=(x:0;y:0);
      XWCS2D2D:GDBVertex=(x:1;y:0);
type Intercept3DProp=record
                           isintercept:GDBBoolean;
                           interceptcoord:gdbvertex;
                           t1,t2:GDBDouble;
                     end;
    Intercept2DProp=record
                           isintercept:GDBBoolean;
                           interceptcoord:GDBvertex2D;
                           t1,t2:GDBDouble;
                         end;
     DistAndPoint=record
                           point:gdbvertex;
                           d:GDBDouble;
                    end;
function CrossVertex(const Vector1, Vector2: GDBVertex): GDBVertex;inline;
function intercept2d(const x1, y1, x2, y2, x3, y3, x4, y4: GDBDouble): GDBBoolean;inline;
function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: GDBFloat): GDBBoolean;inline;
function intercept2dmy(const l1begin,l1end,l2begin,l2end:gdbvertex2d):intercept2dprop;//inline;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;inline;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;//inline;

function intercept3d(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;inline;

function pointinquad2d(const x1, y1, x2, y2, xp, yp: GDBFloat): GDBBoolean;inline;
function Vertexlength(const Vector1, Vector2: GDBVertex): GDBDouble;{inline;}
function SqrVertexlength(const Vector1, Vector2: GDBVertex): GDBDouble;inline;overload;
function SqrVertexlength(const Vector1, Vector2: GDBVertex2d): GDBDouble;inline; overload;
function Vertexmorph(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;inline;overload;
function Vertexmorph(const Vector1, Vector2: GDBVertex2D; a: GDBDouble): GDBVertex2D;inline;overload;
function VertexDmorph(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;inline;
function Vertexangle(const Vector1, Vector2: GDBVertex2d): GDBDouble;inline;
function oneVertexlength(const Vector1: GDBVertex): GDBDouble;inline;
function SqrOneVertexlength(const Vector1: GDBVertex): GDBDouble;inline;
function vertexlen2df(const x1, y1, x2, y2: GDBFloat): GDBFloat;inline;
function NormalizeVertex(const Vector1: GDBVertex): GDBVertex;{inline;}
function VertexMulOnSc(const Vector1:GDBVertex;sc:GDBDouble): GDBVertex;inline;
function VertexAdd(const Vector1, Vector2: GDBVertex): GDBVertex;inline;
function Vertex2DAdd(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;inline;
function VertexSub(const Vector1, Vector2: GDBVertex): GDBVertex;inline;
function MinusVertex(const Vector1: GDBVertex): GDBVertex;inline;
function vertexlen2id(const x1, y1, x2, y2: GDBInteger): GDBDouble;inline;
function Vertexdmorphabs(const Vector1, Vector2: GDBVertex;a: GDBDouble): GDBVertex;inline;
function Vertexmorphabs(const Vector1, Vector2: GDBVertex;a: GDBDouble): GDBVertex;inline;
function Vertexmorphabs2(const Vector1, Vector2: GDBVertex;a: GDBDouble): GDBVertex;inline;
function MatrixMultiply(const M1, M2: DMatrix4D):DMatrix4D;inline;
function VectorTransform(const V:GDBVertex4D;const M:DMatrix4D):GDBVertex4D;inline;
procedure normalize4d(var tv:GDBVertex4d);inline;
function VectorTransform3D(const V:GDBVertex;const M:DMatrix4D):GDBVertex;inline;
procedure MatrixTranspose(var M: DMatrix4D);inline;
procedure MatrixNormalize(var M: DMatrix4D);inline;
function CreateRotationMatrixX(const Sine, Cosine: GDBDouble): DMatrix4D;inline;
function CreateRotationMatrixY(const Sine, Cosine: GDBDouble): DMatrix4D;inline;
function CreateRotationMatrixZ(const Sine, Cosine: GDBDouble): DMatrix4D;inline;
function CreateAffineRotationMatrix(const anAxis: GDBvertex; angle: double):DMatrix4D;inline;
function distance2piece(var q:GDBvertex2DI;var p1,p2:GDBvertex2D): double;overload;inline;
function distance2piece(q:GDBvertex;var p1,p2:GDBvertex): {DistAndPoint}double;overload;//inline;

function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2D): double;overload;inline;
function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2DI): double;overload;inline;
function distance2piece_2Dmy(var q:GDBvertex2D; p1,p2:GDBvertex2D): double;inline;

function distance2piece_2_xy(var q:GDBvertex2DI;const p1,p2:GDBvertex2D):GDBvertex2DI;inline;

function distance2point_2(var p1,p2:GDBvertex2DI):GDBInteger;inline;
function CreateTranslationMatrix(const V:GDBvertex): DMatrix4D;inline;
function CreateScaleMatrix(const V:GDBvertex): DMatrix4D;inline;
function CreateReflectionMatrix(plane:DVector4D): DMatrix4D;
function CreateVertex(const x,y,z:GDBDouble):GDBVertex;inline;
function CreateVertex2D(const x,y:GDBDouble):GDBVertex2D;inline;
function IsPointInBB(const point:GDBvertex; var fistbb:GDBBoundingBbox):GDBBoolean;inline;
procedure ConcatBB(var fistbb:GDBBoundingBbox;const secbb:GDBBoundingBbox);inline;
function IsBBNul(const bb:GDBBoundingBbox):boolean;inline;
function boundingintersect(const bb1,bb2:GDBBoundingBbox):GDBBoolean;inline;
procedure MatrixInvert(var M: DMatrix4D);inline;
function vectordot(const v1,v2:GDBVertex):GDBVertex;inline;
function scalardot(const v1,v2:GDBVertex):GDBDouble;//inline;
function vertexeq(const v1,v2:gdbvertex):GDBBoolean;inline;
function SQRdist_Point_to_Segment(const p:GDBVertex;const s0,s1:GDBvertex):gdbdouble;inline;
function NearestPointOnSegment(const p:GDBVertex;const s0,s1:GDBvertex):GDBvertex;inline;
function IsPointEqual(const p1,p2:gdbvertex):boolean;inline;
function IsVectorNul(const p2:gdbvertex):boolean;inline;

function _myGluProject(const objx,objy,objz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:GDBdouble):Integer;inline;
function _myGluProject2(const objcoord:GDBVertex;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out wincoord:GDBVertex):Integer;inline;
function _myGluUnProject(const winx,winy,winz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4;out objx,objy,objz:GDBdouble):Integer;inline;

function ortho(const xmin,xmax,ymin,ymax,zmin,zmax:GDBDouble;const matrix:PDMatrix4D):DMatrix4D;inline;
function Perspective(const fovy,W_H,zmin,zmax:GDBDouble;const matrix:PDMatrix4D):DMatrix4D;inline;
function LookAt(point,ex,ey,ez:GDBvertex;const matrix:PDMatrix4D):DMatrix4D;inline;

function calcfrustum(const clip:PDMatrix4D):cliparray;inline;
function PointOf3PlaneIntersect(const P1,P2,P3:DVector4D):GDBVertex;inline;
function PointOfLinePlaneIntersect(const p1,d:GDBVertex;const plane:DVector4D;out point :GDBVertex):GDBBoolean;{inline;}
function PlaneFrom3Pont(const P1,P2,P3:GDBVertex):DVector4D;inline;
procedure NormalizePlane(var plane:DVector4D);{inline;}

procedure concatBBandPoint(var fistbb:GDBBoundingBbox;const point:GDBvertex);inline;

function CalcTrueInFrustum (const lbegin,lend:GDBvertex; const frustum:ClipArray):TINRect;inline;
function CalcPointTrueInFrustum (const lbegin:GDBvertex; const frustum:ClipArray):TInRect;
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:ClipArray):TINRect;inline;
function CalcAABBInFrustum (const AABB:GDBBoundingBbox; const frustum:ClipArray):TINRect;{inline;}

function GetXfFromZ(oz:GDBVertex):GDBVertex;

function MatrixDeterminant(M: DMatrix4D): GDBDouble;

var WorldMatrix{,CurrentCS}:DMatrix4D;
    wx:PGDBVertex;
    wy:PGDBVertex;
    wz:PGDBVertex;
    w0:PGDBVertex;
type
    TLineClipArray=array[0..5]of gdbdouble;
implementation
uses shared,log;
function GetXfFromZ(oz:GDBVertex):GDBVertex;
begin
     if (abs (oz.x) < 1/64) and (abs (oz.y) < 1/64) then
                                                                    result:=CrossVertex(YWCS,oz)
                                                                else
                                                                    result:=CrossVertex(ZWCS,oz);
     normalizevertex(oz);
end;

function IsPointEqual(const p1,p2:gdbvertex):boolean;
begin
     if SqrVertexlength(p1,p2)>sqreps then
                                          result:=false
                                      else
                                          result:=true;

end;
function IsVectorNul(const p2:gdbvertex):boolean;
begin
     if SqrOneVertexlength(p2)>sqreps then
                                          result:=false
                                      else
                                          result:=true;
end;
function GetMinAndSwap(var position:integer;size:integer;var ca:TLineClipArray):gdbdouble;
var i,hpos:GDBInteger;
    d1{,d2}:gdbdouble;
//    bytebegin,byteend,bit:integer;
//    cacount:integer;
//    d:gdbvertex;
begin
     result:=ca[position];
     hpos:=-1;
     for I := position to size do
       begin
            if ca[i]<=result then
                                begin
                                     result:=ca[i];
                                     hpos:=i;
                                end;
       end;
       if hpos<>-1 then
       begin
           d1:=ca[hpos];
           ca[hpos]:=ca[position];
           ca[position]:=d1;
       end;
       result:=ca[position];
       inc(position);
end;
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:ClipArray):TINRect;
var i,count:GDBInteger;
    d1,d2,d3,d4:gdbdouble;
begin
      count:=0;
      for i:=0 to 5 do
      begin
      d1:=frustum[i][0] * outbound[0].x + frustum[i][1] * outbound[0].y + frustum[i][2] * outbound[0].z + frustum[i][3];
      d2:=frustum[i][0] * outbound[1].x + frustum[i][1] * outbound[1].y + frustum[i][2] * outbound[1].z + frustum[i][3];
      d3:=frustum[i][0] * outbound[2].x + frustum[i][1] * outbound[2].y + frustum[i][2] * outbound[2].z + frustum[i][3];
      d4:=frustum[i][0] * outbound[3].x + frustum[i][1] * outbound[3].y + frustum[i][2] * outbound[3].z + frustum[i][3];
      if (d1<0)and(d2<0)and(d3<0)and(d4<0)
      then
      begin
           result:=irempty;
           system.exit;
      end;
      if d1>=0 then inc(count);
      if d2>=0 then inc(count);
      if d3>=0 then inc(count);
      if d4>=0 then inc(count);
      end;
      if count=24 then
                      begin
                          result:=irfully;
                          exit;
                      end;

      result:=IRPartially;
end;
function CalcTrueInFrustum (const lbegin,lend:GDBvertex; const frustum:ClipArray):TInRect;
var i,j:GDBInteger;
    d1,d2:gdbdouble;
    bytebegin,byteend,bit:integer;
    ca:TLineClipArray;
    cacount:integer;
    d,p:gdbvertex;
begin
      fillchar((@ca)^,sizeof(ca),0);
      result:=IREmpty;
      bit:=1;
      bytebegin:=0;
      byteend:=0;
      cacount:=0;
      for i:=0 to 5 do
      begin
      d1:=frustum[i][0] * lbegin.x + frustum[i][1] * lbegin.y + frustum[i][2] * lbegin.z + frustum[i][3];
      d2:=frustum[i][0] * lend.x +   frustum[i][1] * lend.y +   frustum[i][2] * lend.z +   frustum[i][3];
      if d1<0 then
                  bytebegin:=bytebegin or bit;
      if d2<0 then
                  byteend:=byteend or bit;
      if ((bytebegin and bit)and(byteend and bit))>0 then
                                                         begin
                                                              result:=IREmpty;
                                                              exit;
                                                         end;
           if((bytebegin and bit)xor(byteend and bit))>0then
            begin
                 d1:=abs(d1);
                 d2:=abs(d2);
                 ca[cacount]:=d1/(d1+d2);
                 inc(cacount);
            end;
      bit:=bit*2;
      end;
      if ((bytebegin)=0)and((byteend)=0) then
                                           begin
                                                result:=IRFully;
                                                exit;
                                           end;

      if  (bytebegin)=0 then
                                        begin
                                             result:=IRPartially;
                                             exit;
                                        end;
      if  (byteend)=0 then
                                        begin
                                             result:=IRPartially;
                                             exit;
                                        end;
      {cacount:=0;
      bit:=1;
      d:=VertexSub(line.lBegin,line.lEnd);
      for i:=0 to 5 do
      begin
           if((bytebegin and bit)xor(byteend and bit))>0then
            begin
                 ca[cacount]:=(
                                frustum[i][3]
                               +frustum[i][0]*d.x
                               +frustum[i][1]*d.y
                               +frustum[i][2]*d.z
                               );
                 ca[cacount]:=(
                                frustum[i][3]
                               +frustum[i][0]*line.lbegin.x
                               +frustum[i][1]*line.lbegin.y
                               +frustum[i][2]*line.lbegin.z
                              )
                              /
                              (ca[cacount]);
                 inc(cacount);
            end;
           bit:=bit*2;
      end;}
      if cacount<2 then
                       begin
                            result:=IREmpty;
                            exit;
                       end;
      dec(cacount);
      d:=VertexSub(lend,lbegin);
      j:=0;
      d1:=GetMinAndSwap(j,cacount,ca);
      while j<=cacount do
      begin
           d2:=GetMinAndSwap(j,cacount,ca);
           d1:=(d1+d2)/2;
      bit:=0;
      p:=geometry.VertexDmorph(lbegin,d,d1);
      for i:=0 to 5 do
      begin
            if (frustum[i][0] * p.x + frustum[i][1] * p.y + frustum[i][2] * p.z + frustum[i][3])>=0
            then
                inc(bit);
      end;
      if bit=6 then
                   begin
                        result:=IRPartially;
                        exit;
                   end;
           d1:=d2;
      end;

      //bit:=bit*2;
end;
function CalcPointTrueInFrustum (const lbegin:GDBvertex; const frustum:ClipArray):TInRect;
var i,j:GDBInteger;
    d1,d2:gdbdouble;
    bytebegin,byteend,bit:integer;
    ca:TLineClipArray;
    cacount:integer;
    d,p:gdbvertex;
begin
      for i:=0 to 5 do
      begin
      d1:=frustum[i][0] * lbegin.x + frustum[i][1] * lbegin.y + frustum[i][2] * lbegin.z + frustum[i][3];
      if d1<0 then
                  begin
                       result:=IREmpty;
                       exit;
                  end;
      end;
      result:=IRFully;
end;

function CalcAABBInFrustum (const AABB:GDBBoundingBbox; const frustum:ClipArray):TINRect;
var i,count:GDBInteger;
    p1,p2,p3,p4,p5,p6,p7,p8:Gdbvertex;
    d1,d2,d3,d4,d5,d6,d7,d8:gdbdouble;
begin
     //result:=irfully;
     //system.exit;

     p1:=AABB.LBN;
     p2:=CreateVertex(AABB.RTF.x,AABB.LBN.y,AABB.LBN.Z);
     p3:=CreateVertex(AABB.RTF.x,AABB.RTF.y,AABB.LBN.Z);
     p4:=CreateVertex(AABB.LBN.x,AABB.RTF.y,AABB.LBN.Z);
     p5:=CreateVertex(AABB.LBN.x,AABB.LBN.y,AABB.RTF.Z);
     p6:=CreateVertex(AABB.RTF.x,AABB.LBN.y,AABB.RTF.Z);
     p7:=AABB.RTF;
     p8:=CreateVertex(AABB.LBN.x,AABB.RTF.y,AABB.RTF.Z);

      count:=0;
      for i:=0 to 5 do
      begin
          d1:=frustum[i][0] * p1.x + frustum[i][1] * p1.y + frustum[i][2] * p1.z + frustum[i][3];
          d2:=frustum[i][0] * p2.x + frustum[i][1] * p2.y + frustum[i][2] * p2.z + frustum[i][3];
          d3:=frustum[i][0] * p3.x + frustum[i][1] * p3.y + frustum[i][2] * p3.z + frustum[i][3];
          d4:=frustum[i][0] * p4.x + frustum[i][1] * p4.y + frustum[i][2] * p4.z + frustum[i][3];
          d5:=frustum[i][0] * p5.x + frustum[i][1] * p5.y + frustum[i][2] * p5.z + frustum[i][3];
          d6:=frustum[i][0] * p6.x + frustum[i][1] * p6.y + frustum[i][2] * p6.z + frustum[i][3];
          d7:=frustum[i][0] * p7.x + frustum[i][1] * p7.y + frustum[i][2] * p7.z + frustum[i][3];
          d8:=frustum[i][0] * p8.x + frustum[i][1] * p8.y + frustum[i][2] * p8.z + frustum[i][3];

          if (d1<0)and(d2<0)and(d3<0)and(d4<0)and(d5<0)and(d6<0)and(d7<0)and(d8<0)
          then
              begin

                   d1:=d2;
                   if d1>d2 then halt(0);
                   result:=irempty;
                   system.exit;
              end;
          if d1>=0 then inc(count);
          if d2>=0 then inc(count);
          if d3>=0 then inc(count);
          if d4>=0 then inc(count);
          if d5>=0 then inc(count);
          if d6>=0 then inc(count);
          if d7>=0 then inc(count);
          if d8>=0 then inc(count);
      end;
      if count=48 then
                      begin
                          result:=irfully;
                          exit;
                      end;

      result:=IRPartially;
end;
function PointOf3PlaneIntersect(const P1,P2,P3:DVector4D):GDBVertex;
var
   N1,N2,N3,N12,N23,N31,a1,a2,a3:GDBVertex;
   a4:GDBDouble;
begin
     result:=nulvertex;
     n1:=createvertex(p1[0],p1[1],p1[2]);
     n2:=createvertex(p2[0],p2[1],p2[2]);
     n3:=createvertex(p3[0],p3[1],p3[2]);
     n12:=geometry.vectordot(n1,n2);
     n23:=geometry.vectordot(n2,n3);
     n31:=geometry.vectordot(n3,n1);

     a1:=VertexMulOnSc(n23,p1[3]);
     a2:=VertexMulOnSc(n31,p2[3]);
     a3:=VertexMulOnSc(n12,p3[3]);
     a4:=scalardot(n1,n23);
     if abs(a4)<eps then
                   exit;
     a4:=1/a4;

     a1:=VertexAdd(a1,a2);
     a1:=VertexAdd(a1,a3);

     result:=VertexMulOnSc(a1,-a4);

end;
procedure NormalizePlane(var plane:DVector4D);{inline;}
var t:GDBDouble;
begin
  t := sqrt( plane[0] * plane[0] + plane[1] * plane[1] + plane[2] * plane[2] );
  plane[0] := plane[0]/t;
  plane[1] := plane[1]/t;
  plane[2] := plane[2]/t;
  plane[3] := plane[3]/t;
end;

function PlaneFrom3Pont(const P1,P2,P3:GDBVertex):DVector4D;
//var
//   N1,N2,N3,N12,N23,N31,a1,a2,a3:GDBVertex;
//   a4:GDBDouble;
begin
      result[0]:= P1.y*(P2.z - P3.z) + P2.y* (P3.z - P1.z) + P3.y* (P1.z - P2.z);
      result[1]:= P1.z*(P2.x - P3.x) + P2.z* (P3.x - P1.x) + P3.z* (P1.x - P2.x);
      result[2]:= P1.x*(P2.y - P3.y) + P2.x* (P3.y - P1.y) + P3.x* (P1.y - P2.y);
      result[3]:= -(P1.x*(P2.y*P3.z - P3.y*P2.z) + P2.x*(P3.y*P1.z - P1.y*P3.z) + P3.x*(P1.y*P2.z - P2.y*P1.z));

end;
function PointOfLinePlaneIntersect(const p1,d:GDBVertex;const plane:DVector4D;out point :GDBVertex):GDBBoolean;
var
//   N1,N2,N3,N12,N23,N31,a1,a2,a3:GDBVertex;
   td:GDBDouble;
begin
     td:=-plane[0]*d.x-plane[1]*d.y-plane[2]*d.z;
     if abs(td)<eps then
                        begin
                             result:=false;
                             exit;
                        end;
     td:=(plane[0]*p1.x+plane[1]*p1.y+plane[2]*p1.z+plane[3])/td;
     point:=VertexDmorph(p1,d,td);
     result:=true;

end;
function calcfrustum(const clip:PDMatrix4D):cliparray;
var t:GDBDouble;
begin
   //* Находим A, B, C, D для ПРАВОЙ плоскости */
   result[0][0] := clip[0, 3] - clip[0, 0];
   result[0][1] := clip[1, 3] - clip[1, 0];
   result[0][2] := clip[2,3] - clip[2,0];
   result[0][3] := clip[3,3] - clip[3,0];
   t := sqrt( result[0][0] * result[0][0] + result[0][1] * result[0][1] + result[0][2] * result[0][2] );
   result[0][0] := result[0][0]/t;
   result[0][1] := result[0][1]/t;
   result[0][2] := result[0][2]/t;
   result[0][3] := result[0][3]/t;

   //* Находим A, B, C, D для ЛЕВОЙ плоскости */
   result[1][0] := clip[0, 3] + clip[0,0];
   result[1][1] := clip[1, 3] + clip[1,0];
   result[1][2] := clip[2,3] + clip[2,0];
   result[1][3] := clip[3,3] + clip[3,0];
   t := sqrt( result[1][0] * result[1][0] + result[1][1] * result[1][1] + result[1][2] * result[1][2] );
   result[1][0] := result[1][0]/t;
   result[1][1] := result[1][1]/t;
   result[1][2] := result[1][2]/t;
   result[1][3] := result[1][3]/t;

   //* Находим A, B, C, D для НИЖНЕЙ плоскости */
   result[2][0] := clip[ 0,3] + clip[ 0,1];
   result[2][1] := clip[ 1,3] + clip[ 1,1];
   result[2][2] := clip[2,3] + clip[ 2,1];
   result[2][3] := clip[3,3] + clip[3,1];
   t := sqrt( result[2][0] * result[2][0] + result[2][1] * result[2][1] + result[2][2] * result[2][2] );
   result[2][0] := result[2][0]/t;
   result[2][1] := result[2][1]/t;
   result[2][2] := result[2][2]/t;
   result[2][3] := result[2][3]/t;

   //* ВЕРХНЯЯ плоскость */
   result[3][0] := clip[ 0,3] - clip[ 0,1];
   result[3][1] := clip[ 1,3] - clip[ 1,1];
   result[3][2] := clip[2,3] - clip[ 2,1];
   result[3][3] := clip[3,3] - clip[3,1];
   t := sqrt( result[3][0] * result[3][0] + result[3][1] * result[3][1] + result[3][2] * result[3][2] );
   result[3][0] := result[3][0]/t;
   result[3][1] := result[3][1]/t;
   result[3][2] := result[3][2]/t;
   result[3][3] := result[3][3]/t;

   //* ПЕРЕДНЯЯ плоскость */
   result[4][0] := clip[ 0,3] + clip[ 0,2];
   result[4][1] := clip[ 1,3] + clip[ 1,2];
   result[4][2] := clip[2,3] + clip[2,2];
   result[4][3] := clip[3,3] + clip[3,2];
   t := sqrt( result[4][0] * result[4][0] + result[4][1] * result[4][1] + result[4][2] * result[4][2] );
   result[4][0] := result[4][0]/t;
   result[4][1] := result[4][1]/t;
   result[4][2] := result[4][2]/t;
   result[4][3] := result[4][3]/t;

   //* ?? плоскость */
   result[5][0] := clip[ 0,3] - clip[ 0,2];
   result[5][1] := clip[ 1,3] - clip[ 1,2];
   result[5][2] := clip[2,3] - clip[2,2];
   result[5][3] := clip[3,3] - clip[3,2];
   t := sqrt( result[5][0] * result[5][0] + result[5][1] * result[5][1] + result[5][2] * result[5][2] );
   result[5][0] := result[5][0]/t;
   result[5][1] := result[5][1]/t;
   result[5][2] := result[5][2]/t;
   result[5][3] := result[5][3]/t;
end;


function ortho;
var xmaxminusxmin,ymaxminusymin,zmaxminuszmin,
    xmaxplusxmin,ymaxplusymin,zmaxpluszmin:GDBDouble;
    m:DMatrix4D;
begin
     xmaxminusxmin:=xmax-xmin;
     ymaxminusymin:=ymax-ymin;
     zmaxminuszmin:=-(zmax-zmin);
     xmaxplusxmin:=xmax+xmin;
     ymaxplusymin:=ymax+ymin;
     zmaxpluszmin:=zmax+zmin;
     m:=OneMatrix;
     if (abs(xmaxminusxmin)<eps) or
        (abs(ymaxminusymin)<eps) or
        (abs(zmaxminuszmin)<eps) then
                                   begin
                                        result:=matrix^;
                                        exit;
                                   end;
     {Все коэффициенты домножены на xmaxminusxmin, воччтановить оригинал - соответственно всё разделить}
     m[0,0]:=2{/xmaxminusxmin};
     m[1,1]:=(2/ymaxminusymin)*xmaxminusxmin;
     m[2,2]:=(2/zmaxminuszmin)*xmaxminusxmin;
     m[3,0]:=(-xmaxplusxmin/xmaxminusxmin)*xmaxminusxmin;
     m[3,1]:=(-ymaxplusymin/ymaxminusymin)*xmaxminusxmin;
     m[3,2]:=(zmaxpluszmin/zmaxminuszmin)*xmaxminusxmin;

     m[3,3]:=xmaxminusxmin;

     result:=geometry.MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);
end;
{function Perspective;
var w,h,zmaxminuszmin:GDBDouble;
    m:DMatrix4D;
begin
     h:=Cotan(fovy*pi/(2*180));
     w:= h/W_H;
     zmaxminuszmin:=-(zmax-zmin);
     m:=EmptyMatrix;
     m[0,0]:=w;
     m[1,1]:=h;
     m[2,2]:=zmax/zmaxminuszmin;
     m[3,2]:=2*zmin*zmax/zmaxminuszmin;
     m[2,3]:=-1;

     result:=geometry.MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);
end;}


function Perspective;
var sine, cotangent, deltaZ, radians:GDBDouble;
    m:DMatrix4D;
begin

    radians:= fovy/2*Pi/180;
    deltaZ:=zmax - zmin;
    sine:=sin(radians);


    {if ((deltaZ == 0) || (sine == 0) || (aspect == 0))
	return;
    }

    cotangent:= COS(radians) / sine;

    m:=OneMatrix;

    m[0,0] := cotangent / w_h;
    m[1,1] := cotangent;
    m[2,2] := -(zmax + zmin) / deltaZ;
    m[2,3] := -1;
    m[3,2] := -2 * zmin * zmax / deltaZ;
    m[3,3] := 0;

    result:=geometry.MatrixMultiply(m,matrix^);
end;

(*

gluPerspective(GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar)
{
    GLdouble m[4][4];
    double sine, cotangent, deltaZ;
    double radians = fovy / 2 * __glPi / 180;

    deltaZ = zFar - zNear;
    sine = sin(radians);
    if ((deltaZ == 0) || (sine == 0) || (aspect == 0)) {
	return;
    }
    cotangent = COS(radians) / sine;

    __gluMakeIdentityd(&m[0][0]);
    m[0][0] = cotangent / aspect;
    m[1][1] = cotangent;
    m[2][2] = -(zFar + zNear) / deltaZ;
    m[2][3] = -1;
    m[3][2] = -2 * zNear * zFar / deltaZ;
    m[3][3] = 0;
    glMultMatrixd(&m[0][0]);
}

*)

function lookat;
var m:DMatrix4D;
    m2:DMatrix4D;
begin
     m:=OneMatrix;
     m2:=OneMatrix;
     ex.x:=-ex.x;
     ex.y:=-ex.y;
     ex.z:=-ex.z;
     ez.x:=-ez.x;
     ez.y:=-ez.y;
     ez.z:=-ez.z;
     PGDBVertex(@m[0])^:=ex;
     PGDBVertex(@m[1])^:=ey;
     PGDBVertex(@m[2])^:=ez;
     MatrixTranspose(m);
     point.x:=point.x;
     point.y:=point.y;
     point.z:=point.z;
     PGDBVertex(@m2[3])^:=point;
     //m2[3][3]:=1/point.y*point.y;

     m:=MatrixMultiply(M2,M);

     result:=geometry.MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);

end;
function _myGluUnProject(const winx,winy,winz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4;out objx,objy,objz:GDBdouble):Integer;
var
   _in,_out:GDBVertex4D;
   finalMatrix:DMatrix4D;
begin
     finalMatrix:=geometry.MatrixMultiply(modelMatrix^,projMatrix^);
     geometry.MatrixInvert(finalMatrix);

     _in.x:=winx;
     _in.y:=winy;
     _in.z:=winz;
     _in.w:=1.0;

     _in.x:= (_in.x - viewport[0]) / viewport[2];
     _in.y:= (_in.y - viewport[1]) / viewport[3];

     //* Map to range -1 to 1 */
     _in.x:= _in.x * 2 - 1;
     _in.y:= _in.y * 2 - 1;
     _in.z:= _in.z * 2 - 1;

      _out:=geometry.VectorTransform(_in,finalMatrix);

    _out.x:=_out.x/_out.w;
    _out.y:=_out.y/_out.w;
    _out.z:=_out.z/_out.w;
     objx:= _out.x;
     objy:= _out.y;
     objz:= _out.z;
end;
function _myGluProject2(const objcoord:GDBVertex;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out wincoord:GDBVertex):Integer;
begin
     _myGluProject(objcoord.x,objcoord.y,objcoord.z,modelMatrix,projMatrix,viewport,wincoord.x,wincoord.y,wincoord.z);
end;
function _myGluProject(const objx,objy,objz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:GDBdouble):Integer;
var
   _in,_out:GDBVertex4D;
begin
    _in.x:=objx;
    _in.y:=objy;
    _in.z:=objz;
    _in.w:=1.0;
    _out:=geometry.VectorTransform(_in,modelMatrix^);
    _in:=geometry.VectorTransform(_out,projMatrix^);

    _in.x:=_in.x/_in.w;
    _in.y:=_in.y/_in.w;
    _in.z:=_in.z/_in.w;

    //* Map x, y and z to range 0-1 */
    _in.x:=_in.x * 0.5 + 0.5;
    _in.y:=_in.y * 0.5 + 0.5;
    _in.z:=_in.z * 0.5 + 0.5;

    //* Map x,y to viewport */
    _in.x:=_in.x * viewport[2] + viewport[0];
    _in.y:=_in.y * viewport[3] + viewport[1];

    winx:=_in.x;
    winy:=_in.y;
    winz:=_in.z;
    //return(GL_TRUE);
end;
function vertexeq(const v1,v2:gdbvertex):GDBBoolean;
var x,y,z:GDBDouble;
begin
     x:=v2.x-v1.x;
     y:=v2.y-v1.y;
     z:=v2.z-v1.z;
     if x*x+y*y+z*z<bigeps then result:=true
                        else result:=false;
end;
function distance2point_2(var p1,p2:GDBvertex2DI):GDBInteger;
var x,y:GDBInteger;
begin
     x:=p2.x-p1.x;
     y:=p2.y-p1.y;
     result:=x*x+y*y;
end;
function MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3:GDBDouble):GDBDouble;
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;
procedure MatrixAdjoint(var M: DMatrix4D);
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: GDBDouble;
begin
    a1 :=  M[0, 0]; b1 :=  M[0, 1];
    c1 :=  M[0, 2]; d1 :=  M[0, 3];
    a2 :=  M[1, 0]; b2 :=  M[1, 1];
    c2 :=  M[1, 2]; d2 :=  M[1, 3];
    a3 :=  M[2, 0]; b3 :=  M[2, 1];
    c3 :=  M[2, 2]; d3 :=  M[2, 3];
    a4 :=  M[3, 0]; b4 :=  M[3, 1];
    c4 :=  M[3, 2]; d4 :=  M[3, 3];

    // row column labeling reversed since we transpose rows & columns
    M[X, X] :=  MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    M[Y, X] := -MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    M[Z, X] :=  MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    M[W, X] := -MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);

    M[X, Y] := -MatrixDetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    M[Y, Y] :=  MatrixDetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    M[Z, Y] := -MatrixDetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    M[W, Y] :=  MatrixDetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);

    M[X, Z] :=  MatrixDetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    M[Y, Z] := -MatrixDetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    M[Z, Z] :=  MatrixDetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    M[W, Z] := -MatrixDetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);

    M[X, W] := -MatrixDetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);
    M[Y, W] :=  MatrixDetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);
    M[Z, W] := -MatrixDetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);
    M[W, W] :=  MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;
function MatrixDeterminant(M: DMatrix4D): GDBDouble;
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : GDBDouble;

begin
  a1 := M[0, 0];  b1 := M[0, 1];  c1 := M[0, 2];  d1 := M[0, 3];
  a2 := M[1, 0];  b2 := M[1, 1];  c2 := M[1, 2];  d2 := M[1, 3];
  a3 := M[2, 0];  b3 := M[2, 1];  c3 := M[2, 2];  d3 := M[2, 3];
  a4 := M[3, 0];  b4 := M[3, 1];  c4 := M[3, 3];  d4 := M[3, 3];

  Result := a1 * MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;
procedure MatrixScale(var M: DMatrix4D; Factor: GDBDouble);
var I, J: GDBInteger;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do M[I, J] := M[I, J] * Factor;
end;

procedure MatrixInvert(var M: DMatrix4D);
var Det: GDBDouble;
begin
  Det := MatrixDeterminant(M);
  if Abs(Det) < eps then M := onematrix
                        else
  begin
    MatrixAdjoint(M);
    MatrixScale(M, 1 / Det);
  end;
end;

function SQRdist_Point_to_Segment(const p:GDBVertex;const s0,s1:GDBvertex):gdbdouble;
var
   v,w,pb:gdbvertex;
   c1,c2,b:gdbdouble;
begin
    v:=vertexsub(s1,s0);
    w:=vertexsub(p,s0);

    c1 := scalardot(w,v);
    if c1 <= 0 then
                   begin
                   result:=SqrVertexlength(p,s0);
                   exit;
                   end;

    c2:=scalardot(v,v);
    if c2 <= c1 then
                    begin
                    result:=SqrVertexlength(p,s1);
                    exit;
                    end;

    b:=c1/c2;
    Pb:=vertexadd(s0,VertexMulOnSc(v,b));
    result:=SqrVertexlength(p,pb);
end;
function NearestPointOnSegment(const p:GDBVertex;const s0,s1:GDBvertex):GDBvertex;
var
   v,w,pb:gdbvertex;
   c1,c2,b:gdbdouble;
begin
    v:=vertexsub(s1,s0);
    w:=vertexsub(p,s0);

    c1 := scalardot(w,v);
    if c1 <= 0 then
                   begin
                   result:=s0;
                   exit;
                   end;

    c2:=scalardot(v,v);
    if c2 <= c1 then
                    begin
                    result:=s1;
                    exit;
                    end;

    b:=c1/c2;
    Pb:=vertexadd(s0,VertexMulOnSc(v,b));
    result:=pb;
end;
function distance2piece(q:GDBvertex;var p1,p2:GDBvertex):{DistAndPoint}double;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then
               begin
                    t:= w;
                    //result.point:=p2;
               end
           else
               begin
                    //result.point:=p1;
               end;
  end else
  begin
       t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  end;
  result{.d}:= sqrt(t);
  //result.point:=
end;
function distance2piece(var q:GDBvertex2DI;var p1,p2:GDBvertex2D): double;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then t:= w;
  end else
    t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  result:= sqrt(t);
end;
function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2D): double;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then t:= w;
  end else
    t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  result:= t;
end;
function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2DI): double;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then t:= w;
  end else
    t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  result:= t;
end;
function distance2piece_2dmy(var q:GDBvertex2D; p1,p2:GDBvertex2D): double;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then t:= w;
  end else
    t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  result:= t;
end;

function distance2piece_2_xy(var q:GDBvertex2DI;const p1,p2:GDBvertex2D):GDBvertex2DI;
var t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x,s1,s2: double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  s1:=(qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y);
  s2:=(qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y);
  if(s1)*(s2)>-eps then
  begin
    t:= sqr(qx_p1x)+sqr(qy_p1y);
    w:= sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then
               begin
                    //t:= w;
                    result.x:=round(qx_p2x);
                    result.y:=round(qy_p2y);

               end
           else
               begin
                    result.x:=round(qx_p1x);
                    result.y:=round(qy_p1y);
               end;
  end else
      begin
            s1:=abs(s1/(abs(s1)+abs(s2)));

            result.x:=round(qx_p1x-p2x_p1x*s1);
            result.y:=round(qy_p1y-p2y_p1y*s1);

            {t:= sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
            result:= t;}
      end;
end;

function CreateTranslationMatrix(const V:GDBvertex): DMatrix4D;
begin
  Result := onematrix;
  Result[3, 0] := V.x;
  Result[3, 1] := V.y;
  Result[3, 2] := V.z;
  Result[3, 3] := 1;
end;
function CreateReflectionMatrix(plane:DVector4D): DMatrix4D;
begin
  result[0,0] :=-2 * plane[0] * plane[0] + 1;
  result[1,0] :=-2 * plane[0] * plane[1];
  result[2,0] :=-2 * plane[0] * plane[2];
  result[3,0] :=-2 * plane[0] * plane[3];

  result[0,1] :=-2 * plane[1] * plane[0];
  result[1,1] :=-2 * plane[1] * plane[1] + 1;
  result[2,1] :=-2 * plane[1] * plane[2];
  result[3,1] :=-2 * plane[1] * plane[3];

  result[0,2] :=-2 * plane[2] * plane[0];
  result[1,2] :=-2 * plane[2] * plane[1];
  result[2,2] :=-2 * plane[2] * plane[2] + 1;
  result[3,2] :=-2 * plane[2] * plane[3];

  result[0,3]:=0;
  result[1,3]:=0;
  result[2,3]:=0;
  result[3,3]:=1;
end;

function CreateScaleMatrix(const V:GDBvertex): DMatrix4D;
begin
  Result := onematrix;
  Result[0, 0] := V.x;
  Result[1, 1] := V.y;
  Result[2, 2] := V.z;
  Result[3, 3] := 1;
end;

function CreateRotationMatrixX(const Sine, Cosine: GDBDouble): DMatrix4D;
begin
  Result := EmptyMatrix;
  Result[0, 0] := 1;
  Result[1, 1] := Cosine;
  Result[1, 2] := Sine;
  Result[2, 1] := -Sine;
  Result[2, 2] := Cosine;
  Result[3, 3] := 1;
end;
function CreateRotationMatrixY(const Sine, Cosine: GDBDouble): DMatrix4D;
begin
  Result := EmptyMatrix;
  Result[0, 0] := Cosine;
  Result[0, 2] := -Sine;
  Result[1, 1] := 1;
  Result[2, 0] := Sine;
  Result[2, 2] := Cosine;
  Result[3, 3] := 1;
end;
function CreateRotationMatrixZ(const Sine, Cosine: GDBDouble): DMatrix4D;
begin
  Result := Onematrix;
  Result[0, 0] := Cosine;
  Result[1, 1] := Cosine;
  Result[1, 0] := -Sine;
  Result[0, 1] := Sine;

end;
function CreateAffineRotationMatrix(const anAxis: GDBvertex; angle: double):DMatrix4D;
var
   axis : GDBvertex;
   cosine, sine, one_minus_cosine :double;
begin
   SINE:=sin(angle);
   cosine:=cos(angle);
   one_minus_cosine:=1 - cosine;
   axis:=NormalizeVertex(anAxis);
   result:=onematrix;
   Result[X, X]:=(one_minus_cosine * Sqr(Axis.x)) + Cosine;
   Result[X, Y]:=(one_minus_cosine * Axis.x * Axis.y) - (Axis.z * Sine);
   Result[X, Z]:=(one_minus_cosine * Axis.z * Axis.x) + (Axis.y * Sine);

   Result[Y, X]:=(one_minus_cosine * Axis.x * Axis.y) + (Axis.z * Sine);
   Result[Y, Y]:=(one_minus_cosine * Sqr(Axis.y)) + Cosine;
   Result[Y, Z]:=(one_minus_cosine * Axis.y * Axis.z) - (Axis.x * Sine);

   Result[Z, X]:=(one_minus_cosine * Axis.z * Axis.x) - (Axis.y * Sine);
   Result[Z, Y]:=(one_minus_cosine * Axis.y * Axis.z) + (Axis.x * Sine);
   Result[Z, Z]:=(one_minus_cosine * Sqr(Axis.z)) + Cosine;
end;

function MatrixMultiply(const M1, M2: DMatrix4D): DMatrix4D;

var I, J: GDBInteger;
    TM: DMatrix4D;

begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      TM[I, J] := M1[I,0] * M2[0,J] +
                  M1[I,1] * M2[1,J] +
                  M1[I,2] * M2[2,J] +
                  M1[I,3] * M2[3,J];
  Result := TM;
end;
procedure MatrixTranspose(var M: DMatrix4D);
var I, J: GDBInteger;
    TM: DMatrix4D;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do TM[J, I] := M[I, J];
  M := TM;
end;
procedure MatrixNormalize(var M: DMatrix4D);
var I, J: GDBInteger;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      M[I,J]:=M[I,J]/M[3,3];
end;

function VectorTransform(const V:GDBVertex4D;const M:DMatrix4D):GDBVertex4D;
var TV: GDBVertex4D;
begin
  TV.X := V.X * M[0, 0] + V.y * M[1, 0] + V.z * M[2, 0] + V.w * M[3, 0];
  TV.Y := V.X * M[0, 1] + V.y * M[1, 1] + V.z * M[2, 1] + V.w * M[3, 1];
  TV.z := V.x * M[0, 2] + V.y * M[1, 2] + V.z * M[2, 2] + V.w * M[3, 2];
  TV.W := V.x * M[0, 3] + V.y * M[1, 3] + V.z * M[2, 3] + V.w * M[3, 3];

  Result := TV
end;
procedure normalize4d(var tv:GDBVertex4d);
begin
  if abs(tv.w)>eps then
  if abs(abs(tv.w)-1)>eps then
  begin
  tv.x:=tv.x/tv.w;
  tv.y:=tv.y/tv.w;
  tv.z:=tv.z/tv.w;
  end;
end;
function VectorTransform3D(const V:GDBVertex;const M:DMatrix4D):GDBVertex;
var TV: GDBVertex4D;
begin
  pgdbvertex(@tv)^:=v;
  tv.w:=1;
  tv:=VectorTransform(tv,m);

  normalize4d(tv);

  Result := pgdbvertex(@tv)^
end;



function Vertexlength(const Vector1, Vector2: GDBVertex): GDBDouble;
begin
  result := sqrt(sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y) + sqr(vector1.z - vector2.z));
end;
function SqrVertexlength(const Vector1, Vector2: GDBVertex): GDBDouble;
begin
  result := (sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y) + sqr(vector1.z - vector2.z));
end;
function SqrVertexlength(const Vector1, Vector2: GDBVertex2d): GDBDouble;
begin
  result := (sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y));
end;

function oneVertexlength(const Vector1: GDBVertex): GDBDouble;
begin
  result := sqrt(sqr(vector1.x) + sqr(vector1.y) + sqr(vector1.z));
end;

function SqrOneVertexlength(const Vector1: GDBVertex): GDBDouble;
begin
  result := (sqr(vector1.x) + sqr(vector1.y) + sqr(vector1.z));
end;

function vertexlen2df(const x1, y1, x2, y2: GDBFloat): GDBFloat;
begin
  result := sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
end;

function vertexlen2id(const x1, y1, x2, y2: GDBInteger): GDBDouble;
var a,b:GDBDouble;
begin
  a:=x1 - x2;
  b:=y1 - y2;
  result := sqrt(a*a + b*b);
end;

function Vertexangle(const Vector1, Vector2: GDBVertex2d): GDBDouble;
var
  dx, dy, temp: GDBDouble;
begin
  dx := vector2.x - vector1.x;
  dy := vector2.y - vector1.y;
  if dx <> 0 then
    temp := arctan(abs(dy / dx))
  else
    temp := {arcotan(abs(dx / dy))}pi/2;
  if (dx >= 0) and (dy >= 0) then
    result := temp
  else
    if (dx < 0) and (dy >= 0) then
      result := pi - temp
    else
      if (dx <= 0) and (dy <= 0) then
        result := pi + temp
      else
        if (dx > 0) and (dy < 0) then
          result := 2 * pi - temp
end;

function Vertexmorph(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;
var
  temp: GDBVertex;
begin
  temp.x := vector1.x + (vector2.x - vector1.x) * a;
  temp.y := vector1.y + (vector2.y - vector1.y) * a;
  temp.z := vector1.z + (vector2.z - vector1.z) * a;
  result := temp;
end;
function Vertexmorph(const Vector1, Vector2: GDBVertex2D; a: GDBDouble): GDBVertex2d;
begin
  result.x := vector1.x + (vector2.x - vector1.x) * a;
  result.y := vector1.y + (vector2.y - vector1.y) * a;
end;

function VertexDmorph(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;
var
  temp: GDBVertex;
begin
  temp.x := vector1.x + (vector2.x) * a;
  temp.y := vector1.y + (vector2.y) * a;
  temp.z := vector1.z + (vector2.z) * a;
  result := temp;
end;

function Vertexdmorphabs(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;
var
  temp: GDBVertex;
  l: GDBDouble;
begin
  l := oneVertexlength(Vector2);
  if a > 0 then a := a / l
  else a := 1 + a / l;
  temp.x := vector1.x + (vector2.x) * a;
  temp.y := vector1.y + (vector2.y) * a;
  temp.z := vector1.z + (vector2.z) * a;
  result := temp;
end;

function Vertexmorphabs(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;
var
  temp: GDBVertex;
  l: GDBDouble;
begin
  l := Vertexlength(Vector1, Vector2);
  if a > 0 then a := 1+a / l
  else a := 1 + a / l;
  temp.x := vector1.x + (vector2.x - vector1.x) * a;
  temp.y := vector1.y + (vector2.y - vector1.y) * a;
  temp.z := vector1.z + (vector2.z - vector1.z) * a;
  result := temp;
end;
function Vertexmorphabs2(const Vector1, Vector2: GDBVertex; a: GDBDouble): GDBVertex;
var
  temp: GDBVertex;
  l: GDBDouble;
begin
  l := Vertexlength(Vector1, Vector2);
  if a > 0 then a := a / l
  else a := 1 + a / l;
  temp.x := vector1.x + (vector2.x - vector1.x) * a;
  temp.y := vector1.y + (vector2.y - vector1.y) * a;
  temp.z := vector1.z + (vector2.z - vector1.z) * a;
  result := temp;
end;

function NormalizeVertex(const Vector1: GDBVertex): GDBVertex;
var len:GDBDouble;
begin
  len:=oneVertexlength(Vector1);
  if abs(len)>eps then
                 begin
                      Result.X := Vector1.x / len;
                      Result.Y := Vector1.y / len;
                      Result.Z := Vector1.z / len;
                 end
             else
                 begin
                 LogError(rsDivByZero);
                 len:=len+2;
                 end;
end;
function VertexMulOnSc(const Vector1:GDBVertex;sc:GDBDouble): GDBVertex;
begin
  Result.X := Vector1.x*sc;
  Result.Y := Vector1.y*sc;
  Result.Z := Vector1.z*sc;
end;
function VertexAdd(const Vector1, Vector2: GDBVertex): GDBVertex;
begin
  Result.X := Vector1.x + Vector2.x;
  Result.Y := Vector1.y + Vector2.y;
  Result.Z := Vector1.z + Vector2.z;
end;
function Vertex2DAdd(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;
begin
  Result.X := Vector1.x + Vector2.x;
  Result.Y := Vector1.y + Vector2.y;
end;

function VertexSub(const Vector1, Vector2: GDBVertex): GDBVertex;
begin
  Result.X := Vector1.x - Vector2.x;
  Result.Y := Vector1.y - Vector2.y;
  Result.Z := Vector1.z - Vector2.z;
end;
function MinusVertex(const Vector1: GDBVertex): GDBVertex;
begin
  Result.X := -Vector1.x;
  Result.Y := -Vector1.y;
  Result.Z := -Vector1.z;
end;
function CrossVertex;
begin
  Result.X := (Vector1.Y * Vector2.Z) - (Vector1.Z * Vector2.Y);
  Result.Y := (Vector1.Z * Vector2.X) - (Vector1.X * Vector2.Z);
  Result.Z := (Vector1.X * Vector2.Y) - (Vector1.Y * Vector2.X);
end;

function intercept2d(const x1, y1, x2, y2, x3, y3, x4, y4: GDBDouble): GDBBoolean;
var
  z1, z2: GDBDouble;
begin
  z1 := (x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1);
  z2 := (x4 - x1) * (y2 - y1) - (y4 - y1) * (x2 - x1);
  if z1 * z2 > 0 then
    result := false
  else
    result := true;
end;

function pointinquad2d(const x1, y1, x2, y2, xp, yp: GDBFloat): GDBBoolean;
begin
  if (x1 <= xp) and (x2 >= xp) and (y1 <= yp) and (y2 >= yp) then result := true
  else result := false;
end;
function intercept2dmy(const l1begin,l1end,l2begin,l2end:gdbvertex2d):intercept2dprop;
var
  z, {t,} t1, t2, d, d1, d2: GDBDouble;
begin
  //t := 0;
  //t1 := 0;
  //t2 := 0;
  result.isintercept := false;
  D := (l1end.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l1end.x - l1begin.x);
  D1 := (l1end.y - l1begin.y) * (l2begin.x - l1begin.x) - (l2begin.y - l1begin.y) * (l1end.x - l1begin.x);
  D2 := (l2begin.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l2begin.x - l1begin.x);
  if (D <> 0) then
  begin
    t1 := D1 / D;
    t2 := D2 / D;
    //if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      result.interceptcoord.x := l1begin.x + (l1end.x - l1begin.x) * t2;
      result.interceptcoord.y := l1begin.y + (l1end.y - l1begin.y) * t2;
      //if abs(result.interceptcoord.z-z)<eps then
      begin
           result.t1:=t2;
           result.t2:=t1;
           result.isintercept:=true;
      end;
    end;
  end;
end;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;
var
  z, {t,} t1, t2, d, d1, d2: GDBDouble;
begin
  //t := 0;
  //t1 := 0;
  //t2 := 0;
  result.isintercept := false;
  D := (l1end.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l1end.x - l1begin.x);
  D1 := (l1end.y - l1begin.y) * (l2begin.x - l1begin.x) - (l2begin.y - l1begin.y) * (l1end.x - l1begin.x);
  D2 := (l2begin.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l2begin.x - l1begin.x);
  if (D <> 0) then
  begin
    t1 := D1 / D;
    t2 := D2 / D;
    if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      result.interceptcoord.x := l1begin.x + (l1end.x - l1begin.x) * t2;
      result.interceptcoord.y := l1begin.y + (l1end.y - l1begin.y) * t2;
      result.interceptcoord.z := l1begin.z + (l1end.z - l1begin.z) * t2;
      z:=l2begin.z + (l2end.z - l2begin.z) * t1;
      if abs(result.interceptcoord.z-z)<eps then
      begin
           result.t1:=t2;
           result.t2:=t1;
           result.isintercept:=true;
      end;
    end;
  end;
end;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;
var
  {z, t, }t1, t2{, d, d1, d2}: GDBDouble;
  p13,p43,p21,pp:gdbvertex;
  d1343,d4321,d1321,d4343,d2121,numer,denom:GDBDouble;
begin
   result.isintercept := false;
   p13.x:= l1begin.x - l2begin.x;
   p13.y:= l1begin.y - l2begin.y;
   p13.z:= l1begin.z - l2begin.z;
   p43.x:= l2end.x - l2begin.x;
   p43.y:= l2end.y - l2begin.y;
   p43.z:= l2end.z - l2begin.z;
   if (ABS(p43.x)  < EPS) and (ABS(p43.y)  < EPS) and (ABS(p43.z)  < EPS) then exit;
   p21.x:= l1end.x - l1begin.x;
   p21.y:= l1end.y - l1begin.y;
   p21.z:= l1end.z - l1begin.z;
   if (ABS(p21.x)  < EPS) and (ABS(p21.y)  < EPS) and (ABS(p21.z)  < EPS) then exit;

   d1343:= p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
   d4321:= p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
   d1321:= p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
   d4343:= p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
   d2121:= p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

   denom:= d2121 * d4343 - d4321 * d4321;
   if (ABS(denom) < bigEPS)  then exit;
   numer:= d1343 * d4321 - d1321 * d4343;

   result.t1:=numer/denom;
   result.t2:= (d1343 + d4321 * result.t1) / d4343;
   t1:=result.t1;
   t2:=result.t2;

   {if abs(result.t1-1)<bigeps then result.t1:=1;
   if abs(result.t1)<bigeps then result.t1:=0;
   if abs(result.t2-1)<bigeps then result.t2:=1;
   if abs(result.t2)<bigeps then result.t2:=0;}

   //if ((result.t1 <= 1) and (result.t1 >= 0) and (result.t2 >= 0) and (result.t2 <= 1)) then
   begin
   result.interceptcoord.x:= l1begin.x + t1 * p21.x;
   result.interceptcoord.y:= l1begin.y + t1 * p21.y;
   result.interceptcoord.z:= l1begin.z + t1 * p21.z;
   pp.x:= l2begin.x + t2 * p43.x;
   pp.y:= l2begin.y + t2 * p43.y;
   pp.z:= l2begin.z + t2 * p43.z;

   {if (ABS(pp.x-result.interceptcoord.x)>bigEPS) or
      (ABS(pp.y-result.interceptcoord.y)>bigEPS) or
      (ABS(pp.z-result.interceptcoord.z)>bigEPS)
   then exit;}

   result.isintercept:=true;
   end;
end;
function intercept3d(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;
var
  {z, t, }t1, t2{, d, d1, d2}: GDBDouble;
  p13,p43,p21,pp:gdbvertex;
  d1343,d4321,d1321,d4343,d2121,numer,denom:GDBDouble;
begin
   result.isintercept := false;
   p13.x:= l1begin.x - l2begin.x;
   p13.y:= l1begin.y - l2begin.y;
   p13.z:= l1begin.z - l2begin.z;
   p43.x:= l2end.x - l2begin.x;
   p43.y:= l2end.y - l2begin.y;
   p43.z:= l2end.z - l2begin.z;
   if (ABS(p43.x)  < EPS) and (ABS(p43.y)  < EPS) and (ABS(p43.z)  < EPS) then exit;
   p21.x:= l1end.x - l1begin.x;
   p21.y:= l1end.y - l1begin.y;
   p21.z:= l1end.z - l1begin.z;
   if (ABS(p21.x)  < EPS) and (ABS(p21.y)  < EPS) and (ABS(p21.z)  < EPS) then exit;

   d1343:= p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
   d4321:= p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
   d1321:= p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
   d4343:= p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
   d2121:= p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

   denom:= d2121 * d4343 - d4321 * d4321;
   if (ABS(denom) < EPS)  then exit;
   numer:= d1343 * d4321 - d1321 * d4343;

   result.t1:=numer/denom;
   result.t2:= (d1343 + d4321 * result.t1) / d4343;
   t1:=result.t1;
   t2:=result.t2;

   if abs(result.t1-1)<bigeps then result.t1:=1;
   if abs(result.t1)<bigeps then result.t1:=0;
   if abs(result.t2-1)<bigeps then result.t2:=1;
   if abs(result.t2)<bigeps then result.t2:=0;

   if ((result.t1 <= 1) and (result.t1 >= 0) and (result.t2 >= 0) and (result.t2 <= 1)) then
   begin
   result.interceptcoord.x:= l1begin.x + t1 * p21.x;
   result.interceptcoord.y:= l1begin.y + t1 * p21.y;
   result.interceptcoord.z:= l1begin.z + t1 * p21.z;
   pp.x:= l2begin.x + t2 * p43.x;
   pp.y:= l2begin.y + t2 * p43.y;
   pp.z:= l2begin.z + t2 * p43.z;

   if (ABS(pp.x-result.interceptcoord.x)>bigEPS) or
      (ABS(pp.y-result.interceptcoord.y)>bigEPS) or
      (ABS(pp.z-result.interceptcoord.z)>bigEPS)
   then exit;

   result.isintercept:=true;
   end;
end;

{int LineLineIntersect(
   XYZ p1,XYZ p2,XYZ p3,XYZ p4,XYZ *pa,XYZ *pb,
   double *mua, double *mub)

}















function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: GDBFloat): GDBBoolean;
var
  {x, y, t,} t1, t2, d, d1, d2: GDBDouble;
begin
  //x := 0;
  //y := 0;

  //t := 0;
  //t1 := 0;
  //t2 := 0;
  result := false;
  D := (y12 - y11) * (x21 - x22) - (y21 - y22) * (x12 - x11);
  D1 := (y12 - y11) * (x21 - x11) - (y21 - y11) * (x12 - x11);
  D2 := (y21 - y11) * (x21 - x22) - (y21 - y22) * (x21 - x11);
  if (D <> 0) then
  begin
    t1 := D1 / D;
    t2 := D2 / D;
    if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      result := true;
      //x := x11 + (x12 - x11) * t2;
      //y := y11 + (y12 - y11) * t2;
    end;
  end;
end;
function vectordot(const v1,v2:GDBVertex):GDBVertex;
begin
     result.x:=v1.y * v2.z - v1.z * v2.y;
     result.y:=v1.z * v2.x - v1.x * v2.z;
     result.z:=v1.x * v2.y - v1.y * v2.x;
end;
function scalardot(const v1,v2:GDBVertex):GDBDouble;
begin
     result:=v1.x * v2.x + v1.y * v2.y +v1.z*v2.z;
end;
function CreateVertex(const x,y,z:GDBDouble):GDBVertex;
begin
     result.x:=x;
     result.y:=y;
     result.z:=z;
end;
function CreateVertex2D(const x,y:GDBDouble):GDBVertex2D;
begin
     result.x:=x;
     result.y:=y;
end;

procedure concatBBandPoint(var fistbb:GDBBoundingBbox;const point:GDBvertex);
begin
  if fistbb.LBN.x>point.x then fistbb.LBN.x:=point.x;
  if fistbb.LBN.y>point.y then fistbb.LBN.y:=point.y;
  if fistbb.LBN.z>point.z then fistbb.LBN.z:=point.z;

  if fistbb.RTF.x<point.x then fistbb.RTF.x:=point.x;
  if fistbb.RTF.y<point.y then fistbb.RTF.y:=point.y;
  if fistbb.RTF.z<point.z then fistbb.RTF.z:=point.z;

end;
procedure ConcatBB(var fistbb:GDBBoundingBbox;const secbb:GDBBoundingBbox);
begin
     if (fistbb.RTF.x=fistbb.LBN.x)
     and (fistbb.RTF.y=fistbb.LBN.y)
     and (fistbb.RTF.z=fistbb.LBN.z)
        then
            begin
                 fistbb:=secbb;
            end
        else
            begin
                 if(secbb.RTF.x=secbb.LBN.x)
                and (secbb.RTF.y=secbb.LBN.y)
                and (secbb.RTF.z=secbb.LBN.z)
                then
                else
                     begin
                           concatBBandPoint(fistbb,secbb.LBN);
                           concatBBandPoint(fistbb,secbb.RTF);
                           {concatBBandPoint(secbb,fistbb.LBN);
                           concatBBandPoint(secbb,fistbb.RTF);}
                     end;

           end
end;
function IsBBNul(const bb:GDBBoundingBbox):boolean;
begin
     if (abs(bb.LBN.x-bb.RTF.x)<eps)
    and (abs(bb.LBN.y-bb.RTF.y)<eps)
    and (abs(bb.LBN.z-bb.RTF.z)<eps) then
                                         result:=true
                                     else
                                         result:=false;
end;
function IsPointInBB(const point:GDBvertex; var fistbb:GDBBoundingBbox):GDBBoolean;
begin
  result:=false;
  if (fistbb.LBN.x<=point.x)and(fistbb.RTF.x>=point.x) then
  if (fistbb.LBN.y<=point.y)and(fistbb.RTF.y>=point.y) then
  if (fistbb.LBN.z<=point.z)and(fistbb.RTF.z>=point.z) then result:=true
end;
{function boundingintersect(var bb1,bb2:GDBBoundingBbox):GDBBoolean;
begin
     result:=false;
     if IsPointInBB             (bb1.lbn,                       bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.lbn.x,bb1.rtf.y,bb1.lbn.z),bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.rtf.x,bb1.rtf.y,bb1.lbn.z),bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.rtf.x,bb1.lbn.y,bb1.lbn.z),bb2) then begin result:=true; exit end

else if IsPointInBB(CreateVertex(bb1.lbn.x,bb1.lbn.y,bb1.rtf.z),bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.lbn.x,bb1.rtf.y,bb1.rtf.z),bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.rtf.x,bb1.rtf.y,bb1.rtf.z),bb2) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb1.rtf.x,bb1.lbn.y,bb1.rtf.z),bb2) then begin result:=true; exit end



else if IsPointInBB             (bb2.lbn,                       bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.lbn.x,bb2.rtf.y,bb2.lbn.z),bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.rtf.x,bb2.rtf.y,bb2.lbn.z),bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.rtf.x,bb2.lbn.y,bb2.lbn.z),bb1) then begin result:=true; exit end

else if IsPointInBB(CreateVertex(bb2.lbn.x,bb2.lbn.y,bb2.rtf.z),bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.lbn.x,bb2.rtf.y,bb2.rtf.z),bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.rtf.x,bb2.rtf.y,bb2.rtf.z),bb1) then begin result:=true; exit end
else if IsPointInBB(CreateVertex(bb2.rtf.x,bb2.lbn.y,bb2.rtf.z),bb1) then begin result:=true; exit end

end;}
function boundingintersect(const bb1,bb2:GDBBoundingBbox):GDBBoolean;
var
   b1,b2,b1c,b2c,dist:gdbvertex;
   //dist:gdbdouble;
begin
     b1.x:=(bb1.RTF.x-bb1.LBN.x)/2;
     b1.y:=(bb1.RTF.y-bb1.LBN.y)/2;
     b1.z:=(bb1.RTF.z-bb1.LBN.z)/2;
     b2.x:=(bb2.RTF.x-bb2.LBN.x)/2;
     b2.y:=(bb2.RTF.y-bb2.LBN.y)/2;
     b2.z:=(bb2.RTF.z-bb2.LBN.z)/2;
     b1c:=VertexAdd(bb1.LBN,b1);
     b2c:=VertexAdd(bb2.LBN,b2);
     dist:=VertexSub(b1c,b2c);
     dist.x:=abs(dist.x);
     dist.y:=abs(dist.y);
     dist.z:=abs(dist.z);
     result:=false;
     if (((b1.x+b2.x)-dist.x)>-eps)
      and(((b1.y+b2.y)-dist.y)>-eps)
      and(((b1.z+b2.z)-dist.z)>-eps) then
                                 result:=true
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('geometry.initialization');{$ENDIF}
     WorldMatrix:=oneMatrix;
     //CurrentCS:=OneMatrix;
     //wx:=@CurrentCS[0];
     //wy:=@CurrentCS[1];
     //wz:=@CurrentCS[2];
     //w0:=@CurrentCS[3];
end.
