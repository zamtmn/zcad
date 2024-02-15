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

unit uzegeometry;

interface
uses LCLProc,uzegeometrytypes,math;
resourcestring
  rsDivByZero='Divide by zero';
const
      RightAngle=pi/2;
      EmptyMatrix: DMatrix4D = ((v:(0,0,0,0)),
                                (v:(0,0,0,0)),
                                (v:(0,0,0,0)),
                                (v:(0,0,0,0)));
        OneMatrix: DMatrix4D = ((x:1;y:0;z:0;w:0),
                                (x:0;y:1;z:0;w:0),
                                (x:0;y:0;z:1;w:0),
                                (x:0;y:0;z:0;w:1));
        TwoMatrix: DMatrix4D = ((x:2;y:0;z:0;w:0),
                                (x:0;y:2;z:0;w:0),
                                (x:0;y:0;z:2;w:0),
                                (x:0;y:0;z:0;w:2));
        DefaultVP:IMatrix4=(x:2;y:0;z:100;w:100);
        IdentityQuaternion: GDBQuaternion = (ImagPart:(x:0;y:0;z:0); RealPart: 1);
      xAxisIndex=0;yAxisIndex=1;zAxisIndex=2;wAxisIndex=3;
      ScaleOne:GDBVertex=(x:1;y:1;z:1);
      OneVertex:GDBVertex=(x:1;y:1;z:1);
      xy_Z_Vertex:GDBVertex=(x:0;y:0;z:1);
      _XY_zVertex:GDBVertex=(x:1;y:1;z:0);
      _MinusXY_zVertex:GDBVertex=(x:-1;y:1;z:0);
      x_Y_zVertex:GDBVertex=(x:0;y:1;z:0);
      _X_yzVertex:GDBVertex=(x:1;y:0;z:0);
      MinusOneVertex:GDBVertex=(x:-1;y:-1;z:-1);
      MinusInfinityVertex:GDBVertex=(x:NegInfinity;y:NegInfinity;z:NegInfinity);
      InfinityVertex:GDBVertex=(x:Infinity;y:Infinity;z:Infinity);
      NulVertex4D:GDBVertex4d=(x:0;y:0;z:0;w:1);
      NulVector4D:DVector4D=(v:(0,0,0,0));
      NulVector4D2:DVector4D=(v:(0,0,0,1));
      NulVertex:GDBVertex=(x:0;y:0;z:0);
      NulVertex3S:GDBVertex3S=(x:0;y:0;z:0);
      XWCS:GDBVertex=(x:1;y:0;z:0);
      YWCS:GDBVertex=(x:0;y:1;z:0);
      ZWCS:GDBVertex=(x:0;y:0;z:1);
      XWCS4D:DVector4D=(v:(1,0,0,1));
      YWCS4D:DVector4D=(v:(0,1,0,1));
      ZWCS4D:DVector4D=(v:(0,0,1,1));
      NulVertex2D:GDBVertex2D=(x:0;y:0);
      XWCS2D:GDBVertex2D=(x:1;y:0);
      YWCS2D:GDBVertex2D=(x:0;y:1);
type Intercept3DProp=record
                           isintercept:Boolean;   //**< Есть это пересение или нет
                           interceptcoord:GDBVertex; //**< Точка пересечения X,Y,Z
                           t1,t2:Double;          //**< позиция на линии 1 и 2 в виде относительных цифр от 0 до 1
                     end;
    Intercept2DProp=record
                           isintercept:Boolean;
                           interceptcoord:GDBvertex2D;
                           t1,t2:Double;
                         end;
     DistAndPoint=record
                           point:gdbvertex;
                           d:Double;
                    end;
     DistAndt=record
                    t,d:Double;
              end;
     TCSDir=(TCSDLeft,TCSDRight);
function ToDVector4F(const m:DVector4D):DVector4F;
function ToDMatrix4F(const m:DMatrix4D):DMatrix4F;
function ToVertex2DI(const V:GDBVertex):GDBVertex2DI;
function CrossVertex(const Vector1, Vector2: GDBVertex): GDBVertex;inline;
function VertexD2S(const Vector1:GDBVertex): GDBVertex3S;inline;
function intercept2d(const x1, y1, x2, y2, x3, y3, x4, y4: Double): Boolean;inline;
function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: Single): Boolean;inline;
function intercept2dmy(const l1begin,l1end,l2begin,l2end:gdbvertex2d):intercept2dprop;//inline;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;inline;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;//inline;

//** Функция позволяет найти пересечение по 2-м координатам одной линии и другой
function intercept3d(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;//inline;


function pointinquad2d(const x1, y1, x2, y2, xp, yp: Single): Boolean;inline;

//**Функция определения длины по двум точкам с учетом 3-х мерного пространства
function Vertexlength(const Vector1, Vector2: GDBVertex): Double;{inline;}

function Vertexlength2d(const Vector1, Vector2: GDBVertex2d): Double;{inline;}

function SqrVertexlength(const Vector1, Vector2: GDBVertex): Double;inline;overload;
function SqrVertexlength(const Vector1, Vector2: GDBVertex2d): Double;inline; overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function Vertexmorph(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;inline;overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function Vertexmorph(const Vector1, Vector2: GDBVertex2D; a: Double): GDBVertex2D;inline;overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function VertexDmorph(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;overload;inline;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function VertexDmorph(const Vector1, Vector2: GDBVertex3S; a: Double): GDBVertex3S;overload;inline;
function Vertexangle(const Vector1, Vector2: GDBVertex2d): Double;inline;
function TwoVectorAngle(const Vector1, Vector2: GDBVertex): Double;inline;
function oneVertexlength(const Vector1: GDBVertex): Double;inline;
function oneVertexlength2D(const Vector1: GDBVertex2D): Double;inline;
function SqrOneVertexlength(const Vector1: GDBVertex): Double;inline;
function vertexlen2df(const x1, y1, x2, y2: Single): Single;inline;
function NormalizeVertex(const Vector1: GDBVertex): GDBVertex;inline;
function NormalizeVertex2D(const Vector1: GDBVertex2D): GDBVertex2D;{inline;}
function VertexMulOnSc(const Vector1:GDBVertex;sc:Double): GDBVertex;inline;
function Vertex2DMulOnSc(const Vector1:GDBVertex2D;sc:Double): GDBVertex2D;inline;

//к первой вершине прибавить вторую по осям Vector1.х + Vector2.х
function VertexAdd(const Vector1, Vector2: GDBVertex): GDBVertex;inline;overload;
function VertexAdd(const Vector1, Vector2: GDBVertex3S): GDBVertex3S;inline;overload;
function VertexAdd(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;inline;overload;
function VertexSub(const Vector1, Vector2: GDBVertex): GDBVertex;overload;inline;
function VertexSub(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;overload;inline;
function VertexSub(const Vector1, Vector2: GDBvertex3S): GDBVertex3S;overload;inline;
//function MinusVertex(const Vector1: GDBVertex): GDBVertex;inline;
function vertexlen2id(const x1, y1, x2, y2: Integer): Double;inline;
function Vertexdmorphabs(const Vector1, Vector2: GDBVertex;a: Double): GDBVertex;inline;
function Vertexmorphabs(const Vector1, Vector2: GDBVertex;a: Double): GDBVertex;inline;
function Vertexmorphabs2(const Vector1, Vector2: GDBVertex;a: Double): GDBVertex;inline;
function MatrixMultiply(const M1, M2: DMatrix4D):DMatrix4D;overload;inline;
function MatrixMultiply(const M1: DMatrix4D; M2: DMatrix4F):DMatrix4D;overload;inline;
function MatrixMultiplyF(const M1, M2: DMatrix4D):DMatrix4F;inline;
function VectorTransform(const V:GDBVertex4D;const M:DMatrix4D):GDBVertex4D;overload;inline;
function VectorTransform(const V:GDBVertex4D;const M:DMatrix4F):GDBVertex4D;overload;inline;
function VectorTransform(const V:GDBVertex4F;const M:DMatrix4F):GDBVertex4F;overload;inline;
procedure normalize4d(var tv:GDBVertex4d);overload;inline;
procedure normalize4F(var tv:GDBVertex4F);overload;inline;
function VectorTransform3D(const V:GDBVertex;const M:DMatrix4D):GDBVertex;overload;inline;
function VectorTransform3D(const V:GDBVertex;const M:DMatrix4F):GDBVertex;overload;inline;
function VectorTransform3D(const V:GDBVertex3S;const M:DMatrix4D):GDBVertex3S;overload;inline;
function VectorTransform3D(const V:GDBVertex3S;const M:DMatrix4F):GDBVertex3S;overload;inline;

function FrustumTransform(const frustum:ClipArray;const M:DMatrix4D; MatrixAlreadyTransposed:Boolean=false):ClipArray;overload;inline;
function FrustumTransform(const frustum:ClipArray;const M:DMatrix4F; MatrixAlreadyTransposed:Boolean=false):ClipArray;overload;inline;

procedure MatrixTranspose(var M: DMatrix4D);overload;inline;
procedure MatrixTranspose(var M: DMatrix4F);overload;inline;
procedure MatrixNormalize(var M: DMatrix4D);inline;
function CreateRotationMatrixX(const Sine, Cosine: Double): DMatrix4D;inline;
function CreateRotationMatrixY(const Sine, Cosine: Double): DMatrix4D;inline;
function CreateRotationMatrixZ(const Sine, Cosine: Double): DMatrix4D;inline;
function CreateRotatedXVector(const angle: Double):GDBVertex;
function CreateRotatedYVector(const angle: Double):GDBVertex;
function CreateAffineRotationMatrix(const anAxis: GDBvertex; angle: double):DMatrix4D;inline;
function distance2piece(var q:GDBvertex2DI;var p1,p2:GDBvertex2D): double;overload;inline;
function distance2piece(q:GDBvertex;var p1,p2:GDBvertex): {DistAndPoint}double;overload;//inline;

function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2D): double;overload;inline;
function distance2piece_2(var q:GDBvertex2DI; p1,p2:GDBvertex2DI): double;overload;inline;
function distance2piece_2Dmy(var q:GDBvertex2D; p1,p2:GDBvertex2D): double;inline;

function distance2piece_2_xy(var q:GDBvertex2DI;const p1,p2:GDBvertex2D):GDBvertex2DI;inline;

function distance2point_2(var p1,p2:GDBvertex2DI):Integer;inline;
function distance2ray(q:GDBvertex;const p1,p2:GDBvertex):DistAndt;
function CreateTranslationMatrix(const V:GDBvertex): DMatrix4D;inline;
function CreateScaleMatrix(const V:GDBvertex): DMatrix4D;inline;
function CreateReflectionMatrix(plane:DVector4D): DMatrix4D;
//**Создать 3D вершину
function CreateVertex(const x,y,z:Double):GDBVertex;inline;
function CreateVertexFromArray(var counter:integer;const args:array of const):GDBVertex;
function CreateVertex2DFromArray(var counter:integer;const args:array of const):GDBVertex2D;
function CreateDoubleFromArray(var counter:integer;const args:array of const):Double;
function CreateStringFromArray(var counter:integer;const args:array of const):String;
function CreateBooleanFromArray(var counter:integer;const args:array of const):Boolean;
//**Создать 2D вершину
function CreateVertex2D(const x,y:Double):GDBVertex2D;inline;
function IsPointInBB(const point:GDBvertex; var fistbb:TBoundingBox):Boolean;inline;
function CreateBBFrom2Point(const p1,p2:GDBvertex):TBoundingBox;
function CreateBBFromPoint(const p:GDBvertex):TBoundingBox;
procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox);inline;
procedure concatBBandPoint(var fistbb:TBoundingBox;const point:GDBvertex);inline;
function IsBBNul(const bb:TBoundingBox):boolean;inline;
function boundingintersect(const bb1,bb2:TBoundingBox):Boolean;inline;
procedure MatrixInvert(var M: DMatrix4D);//inline;
function vectordot(const v1,v2:GDBVertex):GDBVertex;inline;
function scalardot(const v1,v2:GDBVertex):Double;//inline;
function vertexeq(const v1,v2:gdbvertex):Boolean;inline;
function SQRdist_Point_to_Segment(const p:GDBVertex;const s0,s1:GDBvertex):Double;inline;
function NearestPointOnSegment(const p:GDBVertex;const s0,s1:GDBvertex):GDBvertex;inline;
function IsPointEqual(const p1,p2:gdbvertex;const _eps:Double=eps):boolean;inline;
function IsPoint2DEqual(const p1,p2:gdbvertex2D):boolean;inline;
function IsVectorNul(const p2:gdbvertex):boolean;inline;
function IsDoubleNotEqual(const d1,d2:Double;const _eps:Double=eps):boolean;inline;
function IsDoubleEqual(const d1,d2:Double;const _eps:Double=eps):boolean;inline;
function IsFloatNotEqual(const d1,d2:Single;const _floateps:Single=floateps):boolean;inline;

procedure _myGluProject(const objx,objy,objz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:Double);inline;
procedure _myGluProject2(const objcoord:GDBVertex;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out wincoord:GDBVertex);inline;
procedure _myGluUnProject(const winx,winy,winz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4;out objx,objy,objz:Double);inline;

function ortho(const xmin,xmax,ymin,ymax,zmin,zmax:Double;const matrix:PDMatrix4D):DMatrix4D;{inline;}
function Perspective(const fovy,W_H,zmin,zmax:Double;const matrix:PDMatrix4D):DMatrix4D;inline;
function LookAt(point,ex,ey,ez:GDBvertex;const matrix:PDMatrix4D):DMatrix4D;inline;

function calcfrustum(const clip:PDMatrix4D):cliparray;inline;
function PointOf3PlaneIntersect(const P1,P2,P3:DVector4D):GDBVertex;inline;
function PointOfLinePlaneIntersect(const p1,d:GDBVertex;const plane:DVector4D;out point :GDBVertex):Boolean;{inline;}
function PlaneFrom3Pont(const P1,P2,P3:GDBVertex):DVector4D;inline;
procedure NormalizePlane(var plane:DVector4D);{inline;}

function CalcTrueInFrustum (const lbegin,lend:GDBvertex; const frustum:ClipArray):TInBoundingVolume;overload;//inline;
function CalcTrueInFrustum (const lbegin,lend:GDBvertex3S; const frustum:ClipArray):TInBoundingVolume;overload;
function CalcPointTrueInFrustum (const lbegin:GDBvertex; const frustum:ClipArray):TInBoundingVolume;
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:ClipArray):TInBoundingVolume;inline;
function CalcAABBInFrustum (const AABB:TBoundingBox; const frustum:ClipArray):TInBoundingVolume;{inline;}

function GetXfFromZ(oz:GDBVertex):GDBVertex;

function MatrixDeterminant(M: DMatrix4D): Double;
function CreateMatrixFromBasis(const ox,oy,oz:GDBVertex):DMatrix4D;
procedure CreateBasisFromMatrix(const m:DMatrix4D;out ox,oy,oz:GDBVertex);

function QuaternionFromMatrix(const mat : DMatrix4D) : GDBQuaternion;
function QuaternionSlerp(const source, dest: GDBQuaternion; const t: Double): GDBQuaternion;
function QuaternionToMatrix(quat : GDBQuaternion) :  DMatrix4D;

function GetArcParamFrom3Point2D(Const PointData:tarcrtmodify;out ad:TArcData):Boolean;

function isNotReadableAngle(Angle:Double):Boolean;
function CorrectAngleIfNotReadable(Angle:Double):Double;

function GetCSDirFrom0x0y2D(const ox,oy:GDBVertex):TCSDir;

function CalcDisplaySubFrustum(const x,y,w,h:Double;const mm,pm:DMatrix4D;const vp:IMatrix4):ClipArray;
function myPickMatrix(const x,y,deltax,deltay:Double;const vp:IMatrix4): DMatrix4D;

var WorldMatrix{,CurrentCS}:DMatrix4D;
    wx:PGDBVertex;
    wy:PGDBVertex;
    wz:PGDBVertex;
    w0:PGDBVertex;
type
    TLineClipArray=array[0..5]of Double;
implementation
function ToDVector4F(const m:DVector4D):DVector4F;
begin
  result.v[0]:=m.v[0];
  result.v[1]:=m.v[1];
  result.v[2]:=m.v[2];
  result.v[3]:=m.v[3];
end;
function ToDMatrix4F(const m:DMatrix4D):DMatrix4F;
begin
  result[0]:=ToDVector4F(m[0]);
  result[1]:=ToDVector4F(m[1]);
  result[2]:=ToDVector4F(m[2]);
  result[3]:=ToDVector4F(m[3]);
end;
function ToVertex2DI(const V:GDBVertex):GDBVertex2DI;
begin
  result.x:=round(V.x);
  result.y:=round(V.y);
end;
function myPickMatrix(const x,y,deltax,deltay:Double;const vp:IMatrix4): DMatrix4D;
var
  tm,sm: DMatrix4D;
begin
    tm:=CreateTranslationMatrix(createvertex((vp.v[2]-2*(x-vp.v[0]))/deltax,
	                                              (vp.v[3]-2*(y-vp.v[1]))/deltay, 0));
    sm:=CreateScaleMatrix(createvertex(vp.v[2]/deltax,vp.v[3]/deltay, 1.0));
    result:=MatrixMultiply(sm,tm);
end;

(*
{
    if (deltax <= 0 || deltay <= 0) {
	return;
    }

    /* Translate and scale the picked region to the entire window */
    glTranslatef((viewport[2] - 2 * (x - viewport[0])) / deltax,
	    (viewport[3] - 2 * (y - viewport[1])) / deltay, 0);
    glScalef(viewport[2] / deltax, viewport[3] / deltay, 1.0);
}
*)
function CalcDisplaySubFrustum(const x,y,w,h:Double;const mm,pm:DMatrix4D;const vp:IMatrix4):ClipArray;
var
tm: DMatrix4D;
begin
  (*//use glu.gluPickMatrix
  oglsm.myglMatrixMode(GL_Projection);
  oglsm.myglpushmatrix;
  glLoadIdentity;
  gluPickMatrix(x,y,w,h,{$IFNDEF DELPHI}PTViewPortArray(@vp)^{$ELSE}TVector4i(vp){$ENDIF});
  glGetDoublev(GL_PROJECTION_MATRIX, @tm);
  tm := MatrixMultiply(pm, tm);
  tm := MatrixMultiply(mm, tm);
  result := calcfrustum(@tm);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
  *)
    //use glu.gluPickMatrix
    tm := myPickMatrix(x,y,w,h,vp);
    tm := MatrixMultiply(pm, tm);
    tm := MatrixMultiply(mm, tm);
    result := calcfrustum(@tm);
end;
function VertexD2S(const Vector1:GDBVertex): GDBVertex3S;
begin
     result.x:=Vector1.x;
     result.y:=Vector1.y;
     result.z:=Vector1.z;
end;
function GetCSDirFrom0x0y2D(const ox,oy:GDBVertex):TCSDir;
begin
    if vectordot(ox,oy).z>eps then
                                  result:=TCSDLeft
                              else
                                  result:=TCSDRight;
end;

function isNotReadableAngle(Angle:Double):Boolean;
begin
     if (Angle>(pi*0.5+eps))and(Angle<(pi*1.5+eps)) then
                                                                 result:=true
                                                             else
                                                                 result:=false;
end;
function CorrectAngleIfNotReadable(Angle:Double):Double;
begin
     if isNotReadableAngle(Angle) then
                                      result:=angle-pi
                                  else
                                      result:=angle;
end;

function GetXfFromZ(oz:GDBVertex):GDBVertex;
begin
     if (abs (oz.x) < 1/64) and (abs (oz.y) < 1/64) then
                                                                    result:=CrossVertex(YWCS,oz)
                                                                else
                                                                    result:=CrossVertex(ZWCS,oz);
     normalizevertex(oz);
end;

function IsPointEqual(const p1,p2:gdbvertex;const _eps:Double):boolean;
begin
     if SqrVertexlength(p1,p2)>_eps then
                                          result:=false
                                      else
                                          result:=true;

end;
function IsPoint2DEqual(const p1,p2:gdbvertex2D):boolean;
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
function IsDoubleNotEqual(const d1,d2:Double;const _eps:Double=eps):boolean;
begin
     if abs(d1-d2)>_eps then
                           result:=true
                       else
                           result:=false;
end;
function IsDoubleEqual(const d1,d2:Double;const _eps:Double=eps):boolean;
begin
     if abs(d1-d2)>=_eps then
                           result:=false
                       else
                           result:=true;
end;

function IsFloatNotEqual(const d1,d2:Single;const _floateps:Single=floateps):boolean;
begin
     if abs(d1-d2)>_floateps then
                           result:=true
                       else
                           result:=false;
end;
function GetMinAndSwap(var position:integer;size:integer;var ca:TLineClipArray):Double;
var i,hpos:Integer;
    d1{,d2}:Double;
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
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:ClipArray):TInBoundingVolume;
var i,count:Integer;
    d1,d2,d3,d4:Double;
begin
      count:=0;
      for i:=0 to 5 do
      begin
      d1:=frustum[i].v[0] * outbound[0].x + frustum[i].v[1] * outbound[0].y + frustum[i].v[2] * outbound[0].z + frustum[i].v[3];
      d2:=frustum[i].v[0] * outbound[1].x + frustum[i].v[1] * outbound[1].y + frustum[i].v[2] * outbound[1].z + frustum[i].v[3];
      d3:=frustum[i].v[0] * outbound[2].x + frustum[i].v[1] * outbound[2].y + frustum[i].v[2] * outbound[2].z + frustum[i].v[3];
      d4:=frustum[i].v[0] * outbound[3].x + frustum[i].v[1] * outbound[3].y + frustum[i].v[2] * outbound[3].z + frustum[i].v[3];
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
function CalcTrueInFrustum (const lbegin,lend:GDBvertex; const frustum:ClipArray):TInBoundingVolume;
var i,j:Integer;
    d1,d2:Double;
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
      d1:=frustum[i].v[0] * lbegin.x + frustum[i].v[1] * lbegin.y + frustum[i].v[2] * lbegin.z + frustum[i].v[3];
      d2:=frustum[i].v[0] * lend.x +   frustum[i].v[1] * lend.y +   frustum[i].v[2] * lend.z +   frustum[i].v[3];
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
      p:=VertexDmorph(lbegin,d,d1);
      for i:=0 to 5 do
      begin
            if (frustum[i].v[0] * p.x + frustum[i].v[1] * p.y + frustum[i].v[2] * p.z + frustum[i].v[3])>=0
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
end;
function CalcTrueInFrustum (const lbegin,lend:GDBvertex3S; const frustum:ClipArray):TInBoundingVolume;
var i,j:Integer;
    d1,d2:Double;
    bytebegin,byteend,bit:integer;
    ca:TLineClipArray;
    cacount:integer;
    d,p:gdbvertex3S;
begin
      fillchar((@ca)^,sizeof(ca),0);
      result:=IREmpty;
      bit:=1;
      bytebegin:=0;
      byteend:=0;
      cacount:=0;
      for i:=0 to 5 do
      begin
      d1:=frustum[i].v[0] * lbegin.x + frustum[i].v[1] * lbegin.y + frustum[i].v[2] * lbegin.z + frustum[i].v[3];
      d2:=frustum[i].v[0] * lend.x +   frustum[i].v[1] * lend.y +   frustum[i].v[2] * lend.z +   frustum[i].v[3];
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
      p:=VertexDmorph(lbegin,d,d1);
      for i:=0 to 5 do
      begin
            if (frustum[i].v[0] * p.x + frustum[i].v[1] * p.y + frustum[i].v[2] * p.z + frustum[i].v[3])>=0
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
end;
function CalcPointTrueInFrustum (const lbegin:GDBvertex; const frustum:ClipArray):TInBoundingVolume;
var i{,j}:Integer;
    d1{,d2}:Double;
    //bytebegin,byteend,bit:integer;
    //ca:TLineClipArray;
    //cacount:integer;
    //d,p:gdbvertex;
begin
      for i:=0 to 5 do
      begin
      d1:=frustum[i].v[0] * lbegin.x + frustum[i].v[1] * lbegin.y + frustum[i].v[2] * lbegin.z + frustum[i].v[3];
      if d1<0 then
                  begin
                       result:=IREmpty;
                       exit;
                  end;
      end;
      result:=IRFully;
end;

function CalcAABBInFrustum (const AABB:TBoundingBox; const frustum:ClipArray):TInBoundingVolume;
var i,count:Integer;
    p1,p2,p3,p4,p5,p6,p7,p8:Gdbvertex;
    d1,d2,d3,d4,d5,d6,d7,d8:Double;
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
          d1:=frustum[i].v[0] * p1.x + frustum[i].v[1] * p1.y + frustum[i].v[2] * p1.z + frustum[i].v[3];
          d2:=frustum[i].v[0] * p2.x + frustum[i].v[1] * p2.y + frustum[i].v[2] * p2.z + frustum[i].v[3];
          d3:=frustum[i].v[0] * p3.x + frustum[i].v[1] * p3.y + frustum[i].v[2] * p3.z + frustum[i].v[3];
          d4:=frustum[i].v[0] * p4.x + frustum[i].v[1] * p4.y + frustum[i].v[2] * p4.z + frustum[i].v[3];
          d5:=frustum[i].v[0] * p5.x + frustum[i].v[1] * p5.y + frustum[i].v[2] * p5.z + frustum[i].v[3];
          d6:=frustum[i].v[0] * p6.x + frustum[i].v[1] * p6.y + frustum[i].v[2] * p6.z + frustum[i].v[3];
          d7:=frustum[i].v[0] * p7.x + frustum[i].v[1] * p7.y + frustum[i].v[2] * p7.z + frustum[i].v[3];
          d8:=frustum[i].v[0] * p8.x + frustum[i].v[1] * p8.y + frustum[i].v[2] * p8.z + frustum[i].v[3];

          if (d1<0)and(d2<0)and(d3<0)and(d4<0)and(d5<0)and(d6<0)and(d7<0)and(d8<0)
          then
              begin
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
   a4:Double;
begin
     result:=nulvertex;
     n1:=createvertex(p1.v[0],p1.v[1],p1.v[2]);
     n2:=createvertex(p2.v[0],p2.v[1],p2.v[2]);
     n3:=createvertex(p3.v[0],p3.v[1],p3.v[2]);
     n12:=vectordot(n1,n2);
     n23:=vectordot(n2,n3);
     n31:=vectordot(n3,n1);

     a1:=VertexMulOnSc(n23,p1.v[3]);
     a2:=VertexMulOnSc(n31,p2.v[3]);
     a3:=VertexMulOnSc(n12,p3.v[3]);
     a4:=scalardot(n1,n23);
     if abs(a4)<eps then
                   exit;
     a4:=1/a4;

     a1:=VertexAdd(a1,a2);
     a1:=VertexAdd(a1,a3);

     result:=VertexMulOnSc(a1,-a4);

end;
procedure NormalizePlane(var plane:DVector4D);{inline;}
var t:Double;
begin
  t := sqrt( plane.v[0] * plane.v[0] + plane.v[1] * plane.v[1] + plane.v[2] * plane.v[2] );
  plane.v[0] := plane.v[0]/t;
  plane.v[1] := plane.v[1]/t;
  plane.v[2] := plane.v[2]/t;
  plane.v[3] := plane.v[3]/t;
end;

function PlaneFrom3Pont(const P1,P2,P3:GDBVertex):DVector4D;
//var
//   N1,N2,N3,N12,N23,N31,a1,a2,a3:GDBVertex;
//   a4:Double;
begin
      result.v[0]:= P1.y*(P2.z - P3.z) + P2.y* (P3.z - P1.z) + P3.y* (P1.z - P2.z);
      result.v[1]:= P1.z*(P2.x - P3.x) + P2.z* (P3.x - P1.x) + P3.z* (P1.x - P2.x);
      result.v[2]:= P1.x*(P2.y - P3.y) + P2.x* (P3.y - P1.y) + P3.x* (P1.y - P2.y);
      result.v[3]:= -(P1.x*(P2.y*P3.z - P3.y*P2.z) + P2.x*(P3.y*P1.z - P1.y*P3.z) + P3.x*(P1.y*P2.z - P2.y*P1.z));

end;
function PointOfLinePlaneIntersect(const p1,d:GDBVertex;const plane:DVector4D;out point :GDBVertex):Boolean;
var
//   N1,N2,N3,N12,N23,N31,a1,a2,a3:GDBVertex;
   td:Double;
begin
     td:=-plane.v[0]*d.x-plane.v[1]*d.y-plane.v[2]*d.z;
     if abs(td)<eps then
                        begin
                             result:=false;
                             exit;
                        end;
     td:=(plane.v[0]*p1.x+plane.v[1]*p1.y+plane.v[2]*p1.z+plane.v[3])/td;
     point:=VertexDmorph(p1,d,td);
     result:=true;

end;
function calcfrustum(const clip:PDMatrix4D):cliparray;
var t:Double;
begin
   //* Находим A, B, C, D для ПРАВОЙ плоскости */
   result[0].v[0] := clip[0].v[3] - clip[0].v[0];
   result[0].v[1] := clip[1].v[3] - clip[1].v[0];
   result[0].v[2] := clip[2].v[3] - clip[2].v[0];
   result[0].v[3] := clip[3].v[3] - clip[3].v[0];
   t := sqrt( result[0].v[0] * result[0].v[0] + result[0].v[1] * result[0].v[1] + result[0].v[2] * result[0].v[2] );
   result[0].v[0] := result[0].v[0]/t;
   result[0].v[1] := result[0].v[1]/t;
   result[0].v[2] := result[0].v[2]/t;
   result[0].v[3] := result[0].v[3]/t;

   //* Находим A, B, C, D для ЛЕВОЙ плоскости */
   result[1].v[0] := clip[0].v[3] + clip[0].v[0];
   result[1].v[1] := clip[1].v[3] + clip[1].v[0];
   result[1].v[2] := clip[2].v[3] + clip[2].v[0];
   result[1].v[3] := clip[3].v[3] + clip[3].v[0];
   t := sqrt( result[1].v[0] * result[1].v[0] + result[1].v[1] * result[1].v[1] + result[1].v[2] * result[1].v[2] );
   result[1].v[0] := result[1].v[0]/t;
   result[1].v[1] := result[1].v[1]/t;
   result[1].v[2] := result[1].v[2]/t;
   result[1].v[3] := result[1].v[3]/t;

   //* Находим A, B, C, D для НИЖНЕЙ плоскости */
   result[2].v[0] := clip[0].v[3] + clip[0].v[1];
   result[2].v[1] := clip[1].v[3] + clip[1].v[1];
   result[2].v[2] := clip[2].v[3] + clip[2].v[1];
   result[2].v[3] := clip[3].v[3] + clip[3].v[1];
   t := sqrt( result[2].v[0] * result[2].v[0] + result[2].v[1] * result[2].v[1] + result[2].v[2] * result[2].v[2] );
   result[2].v[0] := result[2].v[0]/t;
   result[2].v[1] := result[2].v[1]/t;
   result[2].v[2] := result[2].v[2]/t;
   result[2].v[3] := result[2].v[3]/t;

   //* ВЕРХНЯЯ плоскость */
   result[3].v[0] := clip[0].v[3] - clip[0].v[1];
   result[3].v[1] := clip[1].v[3] - clip[1].v[1];
   result[3].v[2] := clip[2].v[3] - clip[2].v[1];
   result[3].v[3] := clip[3].v[3] - clip[3].v[1];
   t := sqrt( result[3].v[0] * result[3].v[0] + result[3].v[1] * result[3].v[1] + result[3].v[2] * result[3].v[2] );
   result[3].v[0] := result[3].v[0]/t;
   result[3].v[1] := result[3].v[1]/t;
   result[3].v[2] := result[3].v[2]/t;
   result[3].v[3] := result[3].v[3]/t;

   //* ПЕРЕДНЯЯ плоскость */
   result[4].v[0] := clip[0].v[3] + clip[0].v[2];
   result[4].v[1] := clip[1].v[3] + clip[1].v[2];
   result[4].v[2] := clip[2].v[3] + clip[2].v[2];
   result[4].v[3] := clip[3].v[3] + clip[3].v[2];
   t := sqrt( result[4].v[0] * result[4].v[0] + result[4].v[1] * result[4].v[1] + result[4].v[2] * result[4].v[2] );
   result[4].v[0] := result[4].v[0]/t;
   result[4].v[1] := result[4].v[1]/t;
   result[4].v[2] := result[4].v[2]/t;
   result[4].v[3] := result[4].v[3]/t;

   //* ?? плоскость */
   result[5].v[0] := clip[0].v[3] - clip[0].v[2];
   result[5].v[1] := clip[1].v[3] - clip[1].v[2];
   result[5].v[2] := clip[2].v[3] - clip[2].v[2];
   result[5].v[3] := clip[3].v[3] - clip[3].v[2];
   t := sqrt( result[5].v[0] * result[5].v[0] + result[5].v[1] * result[5].v[1] + result[5].v[2] * result[5].v[2] );
   result[5].v[0] := result[5].v[0]/t;
   result[5].v[1] := result[5].v[1]/t;
   result[5].v[2] := result[5].v[2]/t;
   result[5].v[3] := result[5].v[3]/t;
end;


function ortho;
var xmaxminusxmin,ymaxminusymin,zmaxminuszmin,
    xmaxplusxmin,ymaxplusymin,zmaxpluszmin:Double;
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
     m[0].v[0]:=2{/xmaxminusxmin};
     m[1].v[1]:=(2/ymaxminusymin)*xmaxminusxmin;
     m[2].v[2]:=(2/zmaxminuszmin)*xmaxminusxmin;
     m[3].v[0]:=(-xmaxplusxmin/xmaxminusxmin)*xmaxminusxmin;
     m[3].v[1]:=(-ymaxplusymin/ymaxminusymin)*xmaxminusxmin;
     m[3].v[2]:=(zmaxpluszmin/zmaxminuszmin)*xmaxminusxmin;

     m[3].v[3]:=xmaxminusxmin;

     result:=MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);
end;
{function Perspective;
var w,h,zmaxminuszmin:Double;
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

     result:=uzegeometry.MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);
end;}


function Perspective;
var sine, cotangent, deltaZ, radians:Double;
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

    m[0].v[0] := cotangent / w_h;
    m[1].v[1] := cotangent;
    m[2].v[2] := -(zmax + zmin) / deltaZ;
    m[2].v[3] := -1;
    m[3].v[2] := -2 * zmin * zmax / deltaZ;
    m[3].v[3] := 0;

    result:=MatrixMultiply(m,matrix^);
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

     result:=MatrixMultiply(m,matrix^);
     //glMultMatrixd(@m);

end;
procedure _myGluUnProject(const winx,winy,winz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4;out objx,objy,objz:Double);
var
   _in,_out:GDBVertex4D;
   finalMatrix:DMatrix4D;
begin
     finalMatrix:=MatrixMultiply(modelMatrix^,projMatrix^);
     MatrixInvert(finalMatrix);

     _in.x:=winx;
     _in.y:=winy;
     _in.z:=winz;
     _in.w:=1.0;

     _in.x:= (_in.x - viewport.v[0]) / viewport.v[2];
     _in.y:= (_in.y - viewport.v[1]) / viewport.v[3];

     //* Map to range -1 to 1 */
     _in.x:= _in.x * 2 - 1;
     _in.y:= _in.y * 2 - 1;
     _in.z:= _in.z * 2 - 1;

      _out:=VectorTransform(_in,finalMatrix);

    _out.x:=_out.x/_out.w;
    _out.y:=_out.y/_out.w;
    _out.z:=_out.z/_out.w;
     objx:= _out.x;
     objy:= _out.y;
     objz:= _out.z;
end;
procedure _myGluProject2(const objcoord:GDBVertex;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out wincoord:GDBVertex);
begin
     _myGluProject(objcoord.x,objcoord.y,objcoord.z,modelMatrix,projMatrix,viewport,wincoord.x,wincoord.y,wincoord.z);
end;
procedure _myGluProject(const objx,objy,objz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:Double);
var
   _in,_out:GDBVertex4D;
begin
    _in.x:=objx;
    _in.y:=objy;
    _in.z:=objz;
    _in.w:=1.0;
    _out:=VectorTransform(_in,modelMatrix^);
    _in:=VectorTransform(_out,projMatrix^);

    _in.x:=_in.x/_in.w;
    _in.y:=_in.y/_in.w;
    _in.z:=_in.z/_in.w;

    //* Map x, y and z to range 0-1 */
    _in.x:=_in.x * 0.5 + 0.5;
    _in.y:=_in.y * 0.5 + 0.5;
    _in.z:=_in.z * 0.5 + 0.5;

    //* Map x,y to viewport */
    _in.x:=_in.x * viewport.v[2] + viewport.v[0];
    _in.y:=_in.y * viewport.v[3] + viewport.v[1];

    winx:=_in.x;
    winy:=_in.y;
    winz:=_in.z;
    //return(GL_TRUE);
end;
function vertexeq(const v1,v2:gdbvertex):Boolean;
var x,y,z:Double;
begin
     x:=v2.x-v1.x;
     y:=v2.y-v1.y;
     z:=v2.z-v1.z;
     if x*x+y*y+z*z<bigeps then result:=true
                        else result:=false;
end;
function distance2point_2(var p1,p2:GDBvertex2DI):Integer;
var x,y:Integer;
begin
     x:=p2.x-p1.x;
     y:=p2.y-p1.y;
     result:=x*x+y*y;
end;
function MatrixDetInternal(var a1, a2, a3, b1, b2, b3, c1, c2, c3:Double):Double;
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;
procedure MatrixAdjoint(var M: DMatrix4D);
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: Double;
begin
    a1 :=  M[0].v[0]; b1 :=  M[0].v[1];
    c1 :=  M[0].v[2]; d1 :=  M[0].v[3];
    a2 :=  M[1].v[0]; b2 :=  M[1].v[1];
    c2 :=  M[1].v[2]; d2 :=  M[1].v[3];
    a3 :=  M[2].v[0]; b3 :=  M[2].v[1];
    c3 :=  M[2].v[2]; d3 :=  M[2].v[3];
    a4 :=  M[3].v[0]; b4 :=  M[3].v[1];
    c4 :=  M[3].v[2]; d4 :=  M[3].v[3];

    // row column labeling reversed since we transpose rows & columns
    M[XAxisIndex].v[XAxisIndex] :=  MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    M[YAxisIndex].v[XAxisIndex] := -MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    M[ZAxisIndex].v[XAxisIndex] :=  MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    M[WAxisIndex].v[XAxisIndex] := -MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);

    M[XAxisIndex].v[YAxisIndex] := -MatrixDetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    M[YAxisIndex].v[YAxisIndex] :=  MatrixDetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    M[ZAxisIndex].v[YAxisIndex] := -MatrixDetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    M[WAxisIndex].v[YAxisIndex] :=  MatrixDetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);

    M[XAxisIndex].v[ZAxisIndex] :=  MatrixDetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    M[YAxisIndex].v[ZAxisIndex] := -MatrixDetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    M[ZAxisIndex].v[ZAxisIndex] :=  MatrixDetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    M[WAxisIndex].v[ZAxisIndex] := -MatrixDetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);

    M[XAxisIndex].v[WAxisIndex] := -MatrixDetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);
    M[YAxisIndex].v[WAxisIndex] :=  MatrixDetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);
    M[ZAxisIndex].v[WAxisIndex] := -MatrixDetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);
    M[WAxisIndex].v[WAxisIndex] :=  MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;
function MatrixDeterminant(M: DMatrix4D): Double;
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : Double;

begin
  a1 := M[0].v[0];  b1 := M[0].v[1];  c1 := M[0].v[2];  d1 := M[0].v[3];
  a2 := M[1].v[0];  b2 := M[1].v[1];  c2 := M[1].v[2];  d2 := M[1].v[3];
  a3 := M[2].v[0];  b3 := M[2].v[1];  c3 := M[2].v[2];  d3 := M[2].v[3];
  a4 := M[3].v[0];  b4 := M[3].v[1];  c4 := M[3].v[3];  d4 := M[3].v[3];

  Result := a1 * MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;
procedure MatrixScale(var M: DMatrix4D; Factor: Double);
var I, J: Integer;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do M[I].v[J] := M[I].v[J] * Factor;
end;

procedure MatrixInvert(var M: DMatrix4D);
var Det: Double;
begin
  Det := MatrixDeterminant(M);
  if Abs(Det) < eps then M := onematrix
                        else
  begin
    MatrixAdjoint(M);
    MatrixScale(M, 1 / Det);
  end;
end;

function SQRdist_Point_to_Segment(const p:GDBVertex;const s0,s1:GDBvertex):Double;
var
   v,w,pb:gdbvertex;
   c1,c2,b:Double;
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
   c1,c2,b:Double;
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
function distance2ray(q:GDBvertex;const p1,p2:GDBvertex):DistAndt;
var w,v:gdbvertex;
    c1,c2:double;
begin
     v:=VertexSub(p2,p1);
     w:=VertexSub(q,p1);
     c1:=scalardot(w,v);
     c2:=scalardot(v,v);
     if abs(c2)>eps then
                        begin
                             result.t:=c1/c2;
                             result.d:=Vertexlength(q,VertexDmorph(p1,v,result.t));
                        end
                    else
                        begin
                             result.t:=0;
                             result.d:=Vertexlength(q,p1);
                        end;
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
  Result[3].v[0] := V.x;
  Result[3].v[1] := V.y;
  Result[3].v[2] := V.z;
  Result[3].v[3] := 1;
end;
function CreateReflectionMatrix(plane:DVector4D): DMatrix4D;
begin
  result[0].v[0] :=-2 * plane.v[0] * plane.v[0] + 1;
  result[1].v[0] :=-2 * plane.v[0] * plane.v[1];
  result[2].v[0] :=-2 * plane.v[0] * plane.v[2];
  result[3].v[0] :=-2 * plane.v[0] * plane.v[3];

  result[0].v[1] :=-2 * plane.v[1] * plane.v[0];
  result[1].v[1] :=-2 * plane.v[1] * plane.v[1] + 1;
  result[2].v[1] :=-2 * plane.v[1] * plane.v[2];
  result[3].v[1] :=-2 * plane.v[1] * plane.v[3];

  result[0].v[2] :=-2 * plane.v[2] * plane.v[0];
  result[1].v[2] :=-2 * plane.v[2] * plane.v[1];
  result[2].v[2] :=-2 * plane.v[2] * plane.v[2] + 1;
  result[3].v[2] :=-2 * plane.v[2] * plane.v[3];

  result[0].v[3]:=0;
  result[1].v[3]:=0;
  result[2].v[3]:=0;
  result[3].v[3]:=1;
end;

function CreateScaleMatrix(const V:GDBvertex): DMatrix4D;
begin
  Result := onematrix;
  Result[0].v[0] := V.x;
  Result[1].v[1] := V.y;
  Result[2].v[2] := V.z;
  Result[3].v[3] := 1;
end;

function CreateRotationMatrixX(const Sine, Cosine: Double): DMatrix4D;
begin
  Result := EmptyMatrix;
  Result[0].v[0] := 1;
  Result[1].v[1] := Cosine;
  Result[1].v[2] := Sine;
  Result[2].v[1] := -Sine;
  Result[2].v[2] := Cosine;
  Result[3].v[3] := 1;
end;
function CreateRotationMatrixY(const Sine, Cosine: Double): DMatrix4D;
begin
  Result := EmptyMatrix;
  Result[0].v[0] := Cosine;
  Result[0].v[2] := -Sine;
  Result[1].v[1] := 1;
  Result[2].v[0] := Sine;
  Result[2].v[2] := Cosine;
  Result[3].v[3] := 1;
end;
function CreateRotatedXVector(const angle: Double):GDBVertex;
begin
  Result.x:=cos(angle);
  Result.y:=sin(angle);
  Result.z:=0;
end;
function CreateRotatedYVector(const angle: Double):GDBVertex;
begin
  Result:=CreateRotatedXVector(angle+pi/2);
end;
function CreateRotationMatrixZ(const Sine, Cosine: Double): DMatrix4D;
begin
  Result := Onematrix;
  Result[0].v[0] := Cosine;
  Result[1].v[1] := Cosine;
  Result[1].v[0] := -Sine;
  Result[0].v[1] := Sine;

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
   Result[XAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Sqr(Axis.x)) + Cosine;
   Result[XAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Axis.x * Axis.y) - (Axis.z * Sine);
   Result[XAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Axis.z * Axis.x) + (Axis.y * Sine);

   Result[YAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Axis.x * Axis.y) + (Axis.z * Sine);
   Result[YAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Sqr(Axis.y)) + Cosine;
   Result[YAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Axis.y * Axis.z) - (Axis.x * Sine);

   Result[ZAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Axis.z * Axis.x) - (Axis.y * Sine);
   Result[ZAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Axis.y * Axis.z) + (Axis.x * Sine);
   Result[ZAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Sqr(Axis.z)) + Cosine;
end;

function MatrixMultiply(const M1, M2: DMatrix4D): DMatrix4D;

var I, J: Integer;
    TM: DMatrix4D;

begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      TM[I].v[J] := M1[I].v[0] * M2[0].v[J] +
                  M1[I].v[1] * M2[1].v[J] +
                  M1[I].v[2] * M2[2].v[J] +
                  M1[I].v[3] * M2[3].v[J];
  Result := TM;
end;
function MatrixMultiply(const M1: DMatrix4D; M2: DMatrix4F):DMatrix4D;

var I, J: Integer;
    TM: DMatrix4D;

begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      TM[I].v[J] := M1[I].v[0] * M2[0].v[J] +
                  M1[I].v[1] * M2[1].v[J] +
                  M1[I].v[2] * M2[2].v[J] +
                  M1[I].v[3] * M2[3].v[J];
  Result := TM;
end;
function MatrixMultiplyF(const M1, M2: DMatrix4D):DMatrix4F;

var I, J: Integer;
    TM: DMatrix4F;

begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      TM[I].v[J] := M1[I].v[0] * M2[0].v[J] +
                  M1[I].v[1] * M2[1].v[J] +
                  M1[I].v[2] * M2[2].v[J] +
                  M1[I].v[3] * M2[3].v[J];
  Result := TM;
end;
procedure MatrixTranspose(var M: DMatrix4D);
var I, J: Integer;
    TM: DMatrix4D;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do TM[J].v[I] := M[I].v[J];
  M := TM;
end;
procedure MatrixTranspose(var M: DMatrix4F);
var I, J: Integer;
    TM: DMatrix4F;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do TM[J].v[I] := M[I].v[J];
  M := TM;
end;
procedure MatrixNormalize(var M: DMatrix4D);
var I, J: Integer;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do
      M[I].v[J]:=M[I].v[J]/M[3].v[3];
end;

function VectorTransform(const V:GDBVertex4D;const M:DMatrix4D):GDBVertex4D;
var TV: GDBVertex4D;
begin
  TV.X := V.X * M[0].v[0] + V.y * M[1].v[0] + V.z * M[2].v[0] + V.w * M[3].v[0];
  TV.Y := V.X * M[0].v[1] + V.y * M[1].v[1] + V.z * M[2].v[1] + V.w * M[3].v[1];
  TV.z := V.x * M[0].v[2] + V.y * M[1].v[2] + V.z * M[2].v[2] + V.w * M[3].v[2];
  TV.W := V.x * M[0].v[3] + V.y * M[1].v[3] + V.z * M[2].v[3] + V.w * M[3].v[3];

  Result := TV
end;
function VectorTransform(const V:GDBVertex4D;const M:DMatrix4F):GDBVertex4D;
var TV: GDBVertex4D;
begin
  TV.X := V.X * M[0].v[0] + V.y * M[1].v[0] + V.z * M[2].v[0] + V.w * M[3].v[0];
  TV.Y := V.X * M[0].v[1] + V.y * M[1].v[1] + V.z * M[2].v[1] + V.w * M[3].v[1];
  TV.z := V.x * M[0].v[2] + V.y * M[1].v[2] + V.z * M[2].v[2] + V.w * M[3].v[2];
  TV.W := V.x * M[0].v[3] + V.y * M[1].v[3] + V.z * M[2].v[3] + V.w * M[3].v[3];

  Result := TV
end;
function VectorTransform(const V:GDBVertex4F;const M:DMatrix4F):GDBVertex4F;
var TV: GDBVertex4F;
begin
  TV.X := V.X * M[0].v[0] + V.y * M[1].v[0] + V.z * M[2].v[0] + V.w * M[3].v[0];
  TV.Y := V.X * M[0].v[1] + V.y * M[1].v[1] + V.z * M[2].v[1] + V.w * M[3].v[1];
  TV.z := V.x * M[0].v[2] + V.y * M[1].v[2] + V.z * M[2].v[2] + V.w * M[3].v[2];
  TV.W := V.x * M[0].v[3] + V.y * M[1].v[3] + V.z * M[2].v[3] + V.w * M[3].v[3];

  Result := TV
end;
procedure normalize4F(var tv:GDBVertex4F);
begin
  if abs(tv.w)>eps then
  if abs(abs(tv.w)-1)>eps then
  begin
  tv.x:=tv.x/tv.w;
  tv.y:=tv.y/tv.w;
  tv.z:=tv.z/tv.w;
  end;
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
function VectorTransform3D(const V:GDBVertex;const M:DMatrix4F):GDBVertex;
var TV: GDBVertex4D;
begin
  pgdbvertex(@tv)^:=v;
  tv.w:=1;
  tv:=VectorTransform(tv,m);

  normalize4d(tv);

  Result := pgdbvertex(@tv)^
end;
function VectorTransform3D(const V:GDBVertex3S;const M:DMatrix4D):GDBVertex3S;
var tv: GDBVertex4D;
begin
  tv.x:=v.x;
  tv.y:=v.y;
  tv.z:=v.z;
  tv.w:=1;
  tv:=VectorTransform(tv,m);
  normalize4d(tv);
  result.x:=tv.x;
  result.y:=tv.y;
  result.z:=tv.z;
end;
function VectorTransform3D(const V:GDBVertex3S;const M:DMatrix4F):GDBVertex3S;
var tv: GDBVertex4F;
begin
  tv.x:=v.x;
  tv.y:=v.y;
  tv.z:=v.z;
  tv.w:=1;
  tv:=VectorTransform(tv,m);
  normalize4f(tv);
  result.x:=tv.x;
  result.y:=tv.y;
  result.z:=tv.z;
end;
function FrustumTransform(const frustum:ClipArray;const M:DMatrix4D; MatrixAlreadyTransposed:Boolean=false):ClipArray;
var
   m1:DMatrix4D;
begin
     if MatrixAlreadyTransposed
      then
        begin
          PGDBVertex4D(@result[0])^:=VectorTransform(PGDBVertex4D(@frustum[0])^,M);
          PGDBVertex4D(@result[1])^:=VectorTransform(PGDBVertex4D(@frustum[1])^,M);
          PGDBVertex4D(@result[2])^:=VectorTransform(PGDBVertex4D(@frustum[2])^,M);
          PGDBVertex4D(@result[3])^:=VectorTransform(PGDBVertex4D(@frustum[3])^,M);
          PGDBVertex4D(@result[4])^:=VectorTransform(PGDBVertex4D(@frustum[4])^,M);
          PGDBVertex4D(@result[5])^:=VectorTransform(PGDBVertex4D(@frustum[5])^,M);
        end
      else
        begin
          m1:=M;
          MatrixTranspose(m1);
          PGDBVertex4D(@result[0])^:=VectorTransform(PGDBVertex4D(@frustum[0])^,m1);
          PGDBVertex4D(@result[1])^:=VectorTransform(PGDBVertex4D(@frustum[1])^,m1);
          PGDBVertex4D(@result[2])^:=VectorTransform(PGDBVertex4D(@frustum[2])^,m1);
          PGDBVertex4D(@result[3])^:=VectorTransform(PGDBVertex4D(@frustum[3])^,m1);
          PGDBVertex4D(@result[4])^:=VectorTransform(PGDBVertex4D(@frustum[4])^,m1);
          PGDBVertex4D(@result[5])^:=VectorTransform(PGDBVertex4D(@frustum[5])^,m1);
        end;
end;
function FrustumTransform(const frustum:ClipArray;const M:DMatrix4F; MatrixAlreadyTransposed:Boolean=false):ClipArray;
var
   m1:DMatrix4F;
begin
     if MatrixAlreadyTransposed
      then
        begin
          PGDBVertex4D(@result[0])^:=VectorTransform(PGDBVertex4D(@frustum[0])^,M);
          PGDBVertex4D(@result[1])^:=VectorTransform(PGDBVertex4D(@frustum[1])^,M);
          PGDBVertex4D(@result[2])^:=VectorTransform(PGDBVertex4D(@frustum[2])^,M);
          PGDBVertex4D(@result[3])^:=VectorTransform(PGDBVertex4D(@frustum[3])^,M);
          PGDBVertex4D(@result[4])^:=VectorTransform(PGDBVertex4D(@frustum[4])^,M);
          PGDBVertex4D(@result[5])^:=VectorTransform(PGDBVertex4D(@frustum[5])^,M);
        end
      else
        begin
          m1:=M;
          MatrixTranspose(m1);
          PGDBVertex4D(@result[0])^:=VectorTransform(PGDBVertex4D(@frustum[0])^,m1);
          PGDBVertex4D(@result[1])^:=VectorTransform(PGDBVertex4D(@frustum[1])^,m1);
          PGDBVertex4D(@result[2])^:=VectorTransform(PGDBVertex4D(@frustum[2])^,m1);
          PGDBVertex4D(@result[3])^:=VectorTransform(PGDBVertex4D(@frustum[3])^,m1);
          PGDBVertex4D(@result[4])^:=VectorTransform(PGDBVertex4D(@frustum[4])^,m1);
          PGDBVertex4D(@result[5])^:=VectorTransform(PGDBVertex4D(@frustum[5])^,m1);
        end;
end;
function Vertexlength(const Vector1, Vector2: GDBVertex): Double;
begin
  result := sqrt(sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y) + sqr(vector1.z - vector2.z));
end;
function Vertexlength2d(const Vector1, Vector2: GDBVertex2d): Double;
begin
  result := sqrt(sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y));
end;
function SqrVertexlength(const Vector1, Vector2: GDBVertex): Double;
begin
  result := (sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y) + sqr(vector1.z - vector2.z));
end;
function SqrVertexlength(const Vector1, Vector2: GDBVertex2d): Double;
begin
  result := (sqr(vector1.x - vector2.x) + sqr(vector1.y - vector2.y));
end;

function oneVertexlength(const Vector1: GDBVertex): Double;
begin
  result := sqrt(sqr(vector1.x) + sqr(vector1.y) + sqr(vector1.z));
end;

function oneVertexlength2D(const Vector1: GDBVertex2D): Double;
begin
  result := sqrt(sqr(vector1.x) + sqr(vector1.y));
end;

function SqrOneVertexlength(const Vector1: GDBVertex): Double;
begin
  result := (sqr(vector1.x) + sqr(vector1.y) + sqr(vector1.z));
end;

function vertexlen2df(const x1, y1, x2, y2: Single): Single;
begin
  result := sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
end;

function vertexlen2id(const x1, y1, x2, y2: Integer): Double;
var a,b:Double;
begin
  a:=x1 - x2;
  b:=y1 - y2;
  result := sqrt(a*a + b*b);
end;

function Vertexangle(const Vector1, Vector2: GDBVertex2d): Double;
var
  dx, dy, temp: Double;
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
function TwoVectorAngle(const Vector1, Vector2: GDBVertex): Double;inline;
var
  dx, dy, temp: Double;
begin
  temp:=scalardot(Vector1, Vector2);
  Result:=ArcCos(temp);
end;
function Vertexmorph(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;
var
  temp: GDBVertex;
begin
  temp.x := vector1.x + (vector2.x - vector1.x) * a;
  temp.y := vector1.y + (vector2.y - vector1.y) * a;
  temp.z := vector1.z + (vector2.z - vector1.z) * a;
  result := temp;
end;
function Vertexmorph(const Vector1, Vector2: GDBVertex2D; a: Double): GDBVertex2d;
begin
  result.x := vector1.x + (vector2.x - vector1.x) * a;
  result.y := vector1.y + (vector2.y - vector1.y) * a;
end;

function VertexDmorph(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;
var
  temp: GDBVertex;
begin
  temp.x := vector1.x + (vector2.x) * a;
  temp.y := vector1.y + (vector2.y) * a;
  temp.z := vector1.z + (vector2.z) * a;
  result := temp;
end;
function VertexDmorph(const Vector1, Vector2: GDBVertex3S; a: Double): GDBVertex3S;
var
  temp: GDBVertex3S;
begin
  temp.x := vector1.x + (vector2.x) * a;
  temp.y := vector1.y + (vector2.y) * a;
  temp.z := vector1.z + (vector2.z) * a;
  result := temp;
end;

function Vertexdmorphabs(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;
var
  temp: GDBVertex;
  l: Double;
begin
  l := oneVertexlength(Vector2);
  if a > 0 then a := a / l
  else a := 1 + a / l;
  temp.x := vector1.x + (vector2.x) * a;
  temp.y := vector1.y + (vector2.y) * a;
  temp.z := vector1.z + (vector2.z) * a;
  result := temp;
end;

function Vertexmorphabs(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;
var
  temp: GDBVertex;
  l: Double;
begin
  l := Vertexlength(Vector1, Vector2);
  if a > 0 then a := 1+a / l
  else a := 1 + a / l;
  temp.x := vector1.x + (vector2.x - vector1.x) * a;
  temp.y := vector1.y + (vector2.y - vector1.y) * a;
  temp.z := vector1.z + (vector2.z - vector1.z) * a;
  result := temp;
end;
function Vertexmorphabs2(const Vector1, Vector2: GDBVertex; a: Double): GDBVertex;
var
  temp: GDBVertex;
  l: Double;
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
var len:Double;
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
                 DebugLn('{EH}'+rsDivByZero);
                 len:=len+2;
                 end;
end;
function NormalizeVertex2D(const Vector1: GDBVertex2D): GDBVertex2D;
var len:Double;
begin
  len:=oneVertexlength2D(Vector1);
  if abs(len)>eps then
                 begin
                      Result.X := Vector1.x / len;
                      Result.Y := Vector1.y / len;
                 end
             else
                 begin
                 DebugLn('{EH}'+rsDivByZero);
                 len:=len+2;
                 end;
end;
function VertexMulOnSc(const Vector1:GDBVertex;sc:Double): GDBVertex;
begin
  Result.X := Vector1.x*sc;
  Result.Y := Vector1.y*sc;
  Result.Z := Vector1.z*sc;
end;
function Vertex2DMulOnSc(const Vector1:GDBVertex2D;sc:Double): GDBVertex2D;
begin
  Result.X := Vector1.x*sc;
  Result.Y := Vector1.y*sc;
end;
function VertexAdd(const Vector1, Vector2: GDBVertex): GDBVertex;
begin
  Result.X := Vector1.x + Vector2.x;
  Result.Y := Vector1.y + Vector2.y;
  Result.Z := Vector1.z + Vector2.z;
end;
function VertexAdd(const Vector1, Vector2: GDBVertex3S): GDBVertex3s;
begin
  Result.X := Vector1.x + Vector2.x;
  Result.Y := Vector1.y + Vector2.y;
  Result.Z := Vector1.z + Vector2.z;
end;
function VertexAdd(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;
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
function VertexSub(const Vector1, Vector2: GDBVertex2D): GDBVertex2D;
begin
  Result.X := Vector1.x - Vector2.x;
  Result.Y := Vector1.y - Vector2.y;
end;
function VertexSub(const Vector1, Vector2: GDBvertex3S): GDBVertex3S;
begin
  Result.X := Vector1.x - Vector2.x;
  Result.Y := Vector1.y - Vector2.y;
  Result.Z := Vector1.z - Vector2.z;
end;
{function MinusVertex(const Vector1: GDBVertex): GDBVertex;
begin
  Result.X := -Vector1.x;
  Result.Y := -Vector1.y;
  Result.Z := -Vector1.z;
end;}
function CrossVertex;
begin
  Result.X := (Vector1.Y * Vector2.Z) - (Vector1.Z * Vector2.Y);
  Result.Y := (Vector1.Z * Vector2.X) - (Vector1.X * Vector2.Z);
  Result.Z := (Vector1.X * Vector2.Y) - (Vector1.Y * Vector2.X);
end;

function intercept2d(const x1, y1, x2, y2, x3, y3, x4, y4: Double): Boolean;
var
  z1, z2: Double;
begin
  z1 := (x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1);
  z2 := (x4 - x1) * (y2 - y1) - (y4 - y1) * (x2 - x1);
  if z1 * z2 > 0 then
    result := false
  else
    result := true;
end;

function pointinquad2d(const x1, y1, x2, y2, xp, yp: Single): Boolean;
begin
  if (x1 <= xp) and (x2 >= xp) and (y1 <= yp) and (y2 >= yp) then result := true
  else result := false;
end;
function intercept2dmy(const l1begin,l1end,l2begin,l2end:gdbvertex2d):intercept2dprop;
var
  {z,} {t,} t1, t2, d, d1, d2: Double;
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
  z, {t,} t1, t2, d, d1, d2: Double;
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
  {z, t, }t1{, t2, d, d1, d2}: Double;
  p13,p43,p21{,pp}:gdbvertex;
  d1343,d4321,d1321,d4343,d2121,numer,denom:Double;
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
   //t2:=result.t2;

   {if abs(result.t1-1)<bigeps then result.t1:=1;
   if abs(result.t1)<bigeps then result.t1:=0;
   if abs(result.t2-1)<bigeps then result.t2:=1;
   if abs(result.t2)<bigeps then result.t2:=0;}

   //if ((result.t1 <= 1) and (result.t1 >= 0) and (result.t2 >= 0) and (result.t2 <= 1)) then
   begin
   result.interceptcoord.x:= l1begin.x + t1 * p21.x;
   result.interceptcoord.y:= l1begin.y + t1 * p21.y;
   result.interceptcoord.z:= l1begin.z + t1 * p21.z;
   //pp.x:= l2begin.x + t2 * p43.x;
   //pp.y:= l2begin.y + t2 * p43.y;
   //pp.z:= l2begin.z + t2 * p43.z;

   {if (ABS(pp.x-result.interceptcoord.x)>bigEPS) or
      (ABS(pp.y-result.interceptcoord.y)>bigEPS) or
      (ABS(pp.z-result.interceptcoord.z)>bigEPS)
   then exit;}

   result.isintercept:=true;
   end;
end;
function intercept3d(const l1begin,l1end,l2begin,l2end:gdbvertex):intercept3dprop;
var
  {z, t, }t1, t2{, d, d1, d2}: Double;
  p13,p43,p21,pp:gdbvertex;
  d1343,d4321,d1321,d4343,d2121,numer,denom:Double;
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
   if (ABS(denom) < {EPS}sqreps)  then begin
     //бывают случаи соприкосновения линий концами, их надо обработать
     if IsPointEqual(l1begin,l2begin)then begin
       result.isintercept:=true;
       result.t1:=0;
       result.t2:=0;
       result.interceptcoord:=l1begin;
       exit;
     end else if IsPointEqual(l1begin,l2end)then begin
       result.isintercept:=true;
       result.t1:=0;
       result.t2:=1;
       result.interceptcoord:=l1begin;
       exit;
     end else if IsPointEqual(l1end,l2begin)then begin
       result.isintercept:=true;
       result.t1:=1;
       result.t2:=0;
       result.interceptcoord:=l1end;
       exit;
     end else if IsPointEqual(l1end,l2end)then begin
       result.isintercept:=true;
       result.t1:=1;
       result.t2:=1;
       result.interceptcoord:=l1end;
       exit;
     end;
     exit;
   end;

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















function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: Single): Boolean;
var
  {x, y, t,} t1, t2, d, d1, d2: Double;
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
function scalardot(const v1,v2:GDBVertex):Double;
begin
     result:=v1.x * v2.x + v1.y * v2.y +v1.z*v2.z;
end;
function CreateVertex(const x,y,z:Double):GDBVertex;
begin
     result.x:=x;
     result.y:=y;
     result.z:=z;
end;
function CreateDoubleFromArray(var counter:integer;const args:array of const):Double;
begin
  case args[counter].VType of
    vtInteger:result:=args[counter].VInteger;
    vtExtended:result:=args[counter].VExtended^;
  else
      DebugLn('{E}CreateDoubleFromArray: not Integer, not Extended');
  end;{case}
  inc(counter);
end;
function CreateBooleanFromArray(var counter:integer;const args:array of const):Boolean;
begin
  case args[counter].VType of
    vtBoolean:result:=args[counter].VBoolean;
  else
    DebugLn('{E}CreateStrinBooleanFromArray: not boolean');
  end;{case}
  inc(counter);
end;

function CreateStringFromArray(var counter:integer;const args:array of const):String;
begin
  case args[counter].VType of
    vtString:result:=args[counter].VString^;
    vtAnsiString:result:=ansistring(args[counter].VAnsiString);
  else
    DebugLn('{E}CreateStringFromArray: not String');
  end;{case}
  inc(counter);
end;
function CreateVertexFromArray(var counter:integer;const args:array of const):GDBVertex;
var
  len:integer;
begin
     len:=high(args);
     if (counter+2)<=(high(args)) then
                                 begin
                                      result.x:=CreateDoubleFromArray(counter,args);
                                      result.y:=CreateDoubleFromArray(counter,args);
                                      result.z:=CreateDoubleFromArray(counter,args);
                                 end
                             else
                                 begin
                                      DebugLn('{E}CreateVertexFromArray: no enough params in args');
                                      //programlog.LogOutStr('CreateVertexFromArray: no enough params in args',lp_OldPos,LM_Error);
                                 end;

end;

function CreateVertex2DFromArray(var counter:integer;const args:array of const):GDBVertex2D;
var
  len:integer;
begin
  len:=high(args);
  if (counter+1)<=(high(args)) then begin
    result.x:=CreateDoubleFromArray(counter,args);
    result.y:=CreateDoubleFromArray(counter,args);
  end else begin
    DebugLn('{E}CreateVertex2DFromArray: no enough params in args');
  end;
end;

function CreateVertex2D(const x,y:Double):GDBVertex2D;
begin
     result.x:=x;
     result.y:=y;
end;

procedure concatBBandPoint(var fistbb:TBoundingBox;const point:GDBvertex);
begin
  if fistbb.LBN.x>point.x then fistbb.LBN.x:=point.x;
  if fistbb.LBN.y>point.y then fistbb.LBN.y:=point.y;
  if fistbb.LBN.z>point.z then fistbb.LBN.z:=point.z;

  if fistbb.RTF.x<point.x then fistbb.RTF.x:=point.x;
  if fistbb.RTF.y<point.y then fistbb.RTF.y:=point.y;
  if fistbb.RTF.z<point.z then fistbb.RTF.z:=point.z;

end;
function CreateBBFrom2Point(const p1,p2:GDBvertex):TBoundingBox;
var
    t,b,l,r,n,f:Double;
begin
  if p1.x<p2.x then
                                               begin
                                                    l:=p1.x;
                                                    r:=p2.x;
                                               end
                                           else
                                               begin
                                                    l:=p2.x;
                                                    r:=p1.x;
                                               end;
  if p1.y<p2.y then
                                               begin
                                                    b:=p1.y;
                                                    t:=p2.y;
                                               end
                                           else
                                               begin
                                                    b:=p2.y;
                                                    t:=p1.y;
                                               end;
  if p1.z<p2.z then
                                               begin
                                                    n:=p1.z;
                                                    f:=p2.z;
                                               end
                                           else
                                               begin
                                                    n:=p2.z;
                                                    f:=p1.z;
                                               end;
  result.LBN:=CreateVertex(l,B,n);
  result.RTF:=CreateVertex(r,T,f);
end;
function CreateBBFromPoint(const p:GDBvertex):TBoundingBox;
begin
   result.LBN:=p;
   result.RTF:=p;
end;

procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox);
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
function IsBBNul(const bb:TBoundingBox):boolean;
begin
     if (abs(bb.LBN.x-bb.RTF.x)<eps)
    and (abs(bb.LBN.y-bb.RTF.y)<eps)
    and (abs(bb.LBN.z-bb.RTF.z)<eps) then
                                         result:=true
                                     else
                                         result:=false;
end;
function IsPointInBB(const point:GDBvertex; var fistbb:TBoundingBox):Boolean;
begin
  result:=false;
  if (fistbb.LBN.x<=point.x+eps)and(fistbb.RTF.x>=point.x-eps) then
  if (fistbb.LBN.y<=point.y+eps)and(fistbb.RTF.y>=point.y-eps) then
  if (fistbb.LBN.z<=point.z+eps)and(fistbb.RTF.z>=point.z-eps) then result:=true
end;
{function boundingintersect(var bb1,bb2:GDBBoundingBbox):Boolean;
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
function boundingintersect(const bb1,bb2:TBoundingBox):Boolean;
var
  b1,b2,b1c,b2c,dist:gdbvertex;
begin
  //половина диагонали первого бокса
  b1.x:=(bb1.RTF.x-bb1.LBN.x)/2;
  b1.y:=(bb1.RTF.y-bb1.LBN.y)/2;
  b1.z:=(bb1.RTF.z-bb1.LBN.z)/2;
  //половина диагонали второго бокса
  b2.x:=(bb2.RTF.x-bb2.LBN.x)/2;
  b2.y:=(bb2.RTF.y-bb2.LBN.y)/2;
  b2.z:=(bb2.RTF.z-bb2.LBN.z)/2;
  //центры боксов
  b1c:=VertexAdd(bb1.LBN,b1);
  b2c:=VertexAdd(bb2.LBN,b2);
  //расстояние между центрами
  dist:=VertexSub(b1c,b2c);
  dist.x:=abs(dist.x);
  dist.y:=abs(dist.y);
  dist.z:=abs(dist.z);
  //пересечение боксов
  result:=false;
  if (((b1.x+b2.x)-dist.x)>-bigeps)
     and(((b1.y+b2.y)-dist.y)>-bigeps)
     and(((b1.z+b2.z)-dist.z)>-bigeps) then
    result:=true
end;
function CreateMatrixFromBasis(const ox,oy,oz:GDBVertex):DMatrix4D;
begin
     result:=onematrix;
     PGDBVertex(@result[0])^:=ox;
     PGDBVertex(@result[1])^:=oy;
     PGDBVertex(@result[2])^:=oz;
end;
procedure CreateBasisFromMatrix(const m:DMatrix4D;out ox,oy,oz:GDBVertex);
begin
     ox:=PGDBVertex(@m[0])^;
     oy:=PGDBVertex(@m[1])^;
     oz:=PGDBVertex(@m[2])^;
end;
function QuaternionMagnitude(const q : GDBQuaternion) : Double;
begin
   Result:=Sqrt(SqrOneVertexlength(q.ImagPart)+Sqr(q.RealPart));
end;
procedure NormalizeQuaternion(var q : GDBQuaternion);
var
   m, f : Double;
begin
   m:=QuaternionMagnitude(q);
   if m>EPSILON2 then begin
      f:=1/m;
      q.ImagPart:=VertexMulOnSc(q.ImagPart, f);
      q.RealPart:=q.RealPart*f;
   end else q:=IdentityQuaternion;
end;
function QuaternionFromMatrix(const mat : DMatrix4D) : GDBQuaternion;
// the matrix must be a rotation matrix!
var
   traceMat, s, invS : Double;
begin
   traceMat := 1 + mat[0].v[0] + mat[1].v[1] + mat[2].v[2];
   if traceMat>EPSILON2 then begin
      s:=Sqrt(traceMat)*2;
      invS:=1/s;
      Result.ImagPart.x:=(mat[1].v[2]-mat[2].v[1])*invS;
      Result.ImagPart.y:=(mat[2].v[0]-mat[0].v[2])*invS;
      Result.ImagPart.z:=(mat[0].v[1]-mat[1].v[0])*invS;
      Result.RealPart   :=0.25*s;
   end else if (mat[0].v[0]>mat[1].v[1]) and (mat[0].v[0]>mat[2].v[2]) then begin  // Row 0:
      s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat[0].v[0]-mat[1].v[1]-mat[2].v[2]))*2;
      invS:=1/s;
      Result.ImagPart.x:=0.25*s;
      Result.ImagPart.y:=(mat[0].v[1]+mat[1].v[0])*invS;
      Result.ImagPart.z:=(mat[2].v[0]+mat[0].v[2])*invS;
      Result.RealPart   :=(mat[1].v[2]-mat[2].v[1])*invS;
   end else if (mat[1].v[1]>mat[2].v[2]) then begin  // Row 1:
      s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat[1].v[1]-mat[0].v[0]-mat[2].v[2]))*2;
      invS:=1/s;
      Result.ImagPart.x:=(mat[0].v[1]+mat[1].v[0])*invS;
      Result.ImagPart.y:=0.25*s;
      Result.ImagPart.z:=(mat[1].v[2]+mat[2].v[1])*invS;
      Result.RealPart   :=(mat[2].v[0]-mat[0].v[2])*invS;
   end else begin  // Row 2:
      s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat[2].v[2]-mat[0].v[0]-mat[1].v[1]))*2;
      invS:=1/s;
      Result.ImagPart.x:=(mat[2].v[0]+mat[0].v[2])*invS;
      Result.ImagPart.y:=(mat[1].v[2]+mat[2].v[1])*invS;
      Result.ImagPart.z:=0.25*s;
      Result.RealPart   :=(mat[0].v[1]-mat[1].v[0])*invS;
   end;
   NormalizeQuaternion(Result);
end;
function QuaternionSlerp(const source, dest: GDBQuaternion; const t: Double): GDBQuaternion;
var
   to1: array[0..4] of Single;
   omega, cosom, sinom, scale0, scale1: Extended;
// t goes from 0 to 1
// absolute rotations
begin
   // calc cosine
   cosom:= source.ImagPart.x*dest.ImagPart.x
          +source.ImagPart.y*dest.ImagPart.y
          +source.ImagPart.z*dest.ImagPart.z
	       +source.RealPart   *dest.RealPart;
   // adjust signs (if necessary)
   if cosom<0 then begin
      cosom := -cosom;
      to1[0] := - dest.ImagPart.x;
      to1[1] := - dest.ImagPart.y;
      to1[2] := - dest.ImagPart.z;
      to1[3] := - dest.RealPart;
   end else begin
      to1[0] := dest.ImagPart.x;
      to1[1] := dest.ImagPart.y;
      to1[2] := dest.ImagPart.z;
      to1[3] := dest.RealPart;
   end;
   // calculate coefficients
   if ((1.0-cosom)>EPSILON2) then begin // standard case (slerp)
      omega:={VectorGeometry.}ArcCos(cosom);
      sinom:=1/Sin(omega);
      scale0:=Sin((1.0-t)*omega)*sinom;
      scale1:=Sin(t*omega)*sinom;
   end else begin // "from" and "to" quaternions are very close
	          //  ... so we can do a linear interpolation
      scale0:=1.0-t;
      scale1:=t;
   end;
   // calculate final values
   Result.ImagPart.x := scale0 * source.ImagPart.x + scale1 * to1[0];
   Result.ImagPart.y := scale0 * source.ImagPart.y + scale1 * to1[1];
   Result.ImagPart.z := scale0 * source.ImagPart.z + scale1 * to1[2];
   Result.RealPart := scale0 * source.RealPart + scale1 * to1[3];
   NormalizeQuaternion(Result);
end;
function QuaternionToMatrix(quat : GDBQuaternion) :  DMatrix4D;
var
   w, x, y, z, xx, xy, xz, xw, yy, yz, yw, zz, zw: Double;
begin
   result:=onematrix;
   NormalizeQuaternion(quat);
   w := quat.RealPart;
   x := quat.ImagPart.x;
   y := quat.ImagPart.y;
   z := quat.ImagPart.z;
   xx := x * x;
   xy := x * y;
   xz := x * z;
   xw := x * w;
   yy := y * y;
   yz := y * z;
   yw := y * w;
   zz := z * z;
   zw := z * w;
   Result[0].v[0] := 1 - 2 * ( yy + zz );
   Result[1].v[0] :=     2 * ( xy - zw );
   Result[2].v[0] :=     2 * ( xz + yw );
   Result[3].v[0] := 0;
   Result[0].v[1] :=     2 * ( xy + zw );
   Result[1].v[1] := 1 - 2 * ( xx + zz );
   Result[2].v[1] :=     2 * ( yz - xw );
   Result[3].v[1] := 0;
   Result[0].v[2] :=     2 * ( xz - yw );
   Result[1].v[2] :=     2 * ( yz + xw );
   Result[2].v[2] := 1 - 2 * ( xx + yy );
   Result[3].v[2] := 0;
   Result[0].v[3] := 0;
   Result[1].v[3] := 0;
   Result[2].v[3] := 0;
   Result[3].v[3] := 1;
end;
function GetArcParamFrom3Point2D(Const PointData:tarcrtmodify;out ad:TArcData):Boolean;
var a,b,c,d,e,f,g,rr:Double;
    tv:gdbvertex2d;
    //tv3d:gdbvertex;
begin
  A:= PointData.p2.x - PointData.p1.x;
  B:= PointData.p2.y - PointData.p1.y;
  C:= PointData.p3.x - PointData.p1.x;
  D:= PointData.p3.y - PointData.p1.y;

  E:= A*(PointData.p1.x + PointData.p2.x) + B*(PointData.p1.y + PointData.p2.y);
  F:= C*(PointData.p1.x + PointData.p3.x) + D*(PointData.p1.y + PointData.p3.y);

  G:= 2*(A*(PointData.p3.y - PointData.p2.y)-B*(PointData.p3.x - PointData.p2.x));
  if abs(g)>eps then
  begin
    result:=true;
  ad.p.x:= (D*E - B*F) / G;
  ad.p.y:= (A*F - C*E) / G;
  {rr}ad.r:= sqrt(sqr(PointData.p1.x - ad.p.x) + sqr(PointData.p1.y - ad.p.y));
  //ad.r:=rr;
  {Local.p_insert.x:=p_x;
  Local.p_insert.y:=p_y;
  Local.p_insert.z:=0;}
  tv.x:=ad.p.x;
  tv.y:=ad.p.y;
  ad.startangle:=vertexangle(tv,PointData.p1);
  ad.endangle:=vertexangle(tv,PointData.p3);
  if ad.startangle>ad.endangle then
  begin
                                                                                rr:=ad.startangle;
                                                                                ad.startangle:=ad.endangle;
                                                                                ad.endangle:=rr
  end;
  rr:=vertexangle(tv,PointData.p2);
  if (rr>ad.startangle) and (rr<ad.endangle) then
                                                                           begin
                                                                           end
                                                                       else
                                                                           begin
                                                                                rr:=ad.startangle;
                                                                                ad.startangle:=ad.endangle;
                                                                                ad.endangle:=rr
                                                                           end;
  end
  else
      result:=false;
end;


begin
     WorldMatrix:=oneMatrix;
     //CurrentCS:=OneMatrix;
     //wx:=@CurrentCS[0];
     //wy:=@CurrentCS[1];
     //wz:=@CurrentCS[2];
     //w0:=@CurrentCS[3];
end.
