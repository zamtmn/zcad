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
{Inline off}

interface
uses uzbLogIntf,uzegeometrytypes,math;
resourcestring
  rsDivByZero='Divide by zero';
const
  EmptyMtr:TMatrix4D=((v:(0,0,0,0)),
                      (v:(0,0,0,0)),
                      (v:(0,0,0,0)),
                      (v:(0,0,0,0)));
  OneMtr:TMatrix4D=((v:(1,0,0,0)),
                    (v:(0,1,0,0)),
                    (v:(0,0,1,0)),
                    (v:(0,0,0,1)));
  EmptyMatrix:DMatrix4D=(mtr:((v:(0,0,0,0)),
                              (v:(0,0,0,0)),
                              (v:(0,0,0,0)),
                              (v:(0,0,0,0)));
                         t:[]);
  OneMatrix:DMatrix4D=(mtr:((v:(1,0,0,0)),
                            (v:(0,1,0,0)),
                            (v:(0,0,1,0)),
                            (v:(0,0,0,1)));
                       t:CMTIdentity);
  RightAngle=pi/2;
  DefaultVP:TzeVector4i=(x:2;y:0;z:100;w:100);
  IdentityQuaternion: TzeQuaternion = (ImagPart:(x:0;y:0;z:0); RealPart: 1);
  xAxisIndex=0;yAxisIndex=1;zAxisIndex=2;wAxisIndex=3;
  ScaleOne:TzePoint3d=(x:1;y:1;z:1);
  OneVertex:TzePoint3d=(x:1;y:1;z:1);
  xy_Z_Vertex:TzePoint3d=(x:0;y:0;z:1);
  xy_MinusZ_Vertex:TzePoint3d=(x:0;y:0;z:-1);
  _XY_zVertex:TzePoint3d=(x:1;y:1;z:0);
  _MinusXY_zVertex:TzePoint3d=(x:-1;y:1;z:0);
  x_Y_zVertex:TzePoint3d=(x:0;y:1;z:0);
  _X_yzVertex:TzePoint3d=(x:1;y:0;z:0);
  MinusOneVertex:TzePoint3d=(x:-1;y:-1;z:-1);
  MinusInfinityVertex:TzePoint3d=(x:NegInfinity;y:NegInfinity;z:NegInfinity);
  InfinityVertex:TzePoint3d=(x:Infinity;y:Infinity;z:Infinity);
  NulVertex4D:TzeVector4d=(x:0;y:0;z:0;w:1);
  NulVector4D:TzeVector4d=(v:(0,0,0,0));
  NulVector4D2:TzeVector4d=(v:(0,0,0,1));
  NulVertex:TzePoint3d=(x:0;y:0;z:0);
  NulVertex3S:TzePoint3s=(x:0;y:0;z:0);
  XWCS:TzePoint3d=(x:1;y:0;z:0);
  YWCS:TzePoint3d=(x:0;y:1;z:0);
  ZWCS:TzePoint3d=(x:0;y:0;z:1);
  XWCS4D:TzeVector4d=(v:(1,0,0,1));
  YWCS4D:TzeVector4d=(v:(0,1,0,1));
  ZWCS4D:TzeVector4d=(v:(0,0,1,1));
  NulVertex2D:TzePoint2d=(x:0;y:0);
  XWCS2D:TzePoint2d=(x:1;y:0);
  YWCS2D:TzePoint2d=(x:0;y:1);
  BBNul:TBoundingBox=(LBN:(x:0;y:0;z:0);RTF:(x:0;y:0;z:0));
type
  Intercept3DProp=record
    isintercept:Boolean;   //**< Есть это пересение или нет
    interceptcoord:TzePoint3d; //**< Точка пересечения X,Y,Z
    t1,t2:Double;          //**< позиция на линии 1 и 2 в виде относительных цифр от 0 до 1
  end;
  Intercept2DProp=record
    isintercept:Boolean;
    interceptcoord:TzePoint2d;
    t1,t2:Double;
  end;
  DistAndPoint=record
    point:TzePoint3d;
    d:Double;
  end;
  DistAndt=record
    t,d:Double;
  end;
  TCSDir=(TCSDLeft,TCSDRight);
function ToTzeVector4s(const m:TzeVector4d):TzeVector4s; inline;
function ToDMatrix4f(const m:DMatrix4D):DMatrix4f; inline;
function ToTzePoint2i(const _V:TzePoint3d):TzePoint2i; inline;
function VertexD2S(const Vector1:TzePoint3d): TzePoint3s;inline;
function intercept2d(const x1, y1, x2, y2, x3, y3, x4, y4: Double): Boolean;inline;
function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: Single): Boolean;inline;
function intercept2dmy(const l1begin,l1end,l2begin,l2end:TzePoint2d):intercept2dprop;//inline;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;inline;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;//inline;

//** Функция позволяет найти пересечение по 2-м координатам одной линии и другой
function intercept3d(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;//inline;


function pointinquad2d(const x1, y1, x2, y2, xp, yp: Single): Boolean;inline;

//**Функция определения длины по двум точкам с учетом 3-х мерного пространства
function Vertexlength(const Vector1, Vector2: TzePoint3d): Double;inline;

function Vertexlength2d(const Vector1, Vector2: TzePoint2d): Double;inline;

function SqrVertexlength(const Vector1, Vector2: TzePoint3d): Double;inline;overload;
function SqrVertexlength(const Vector1, Vector2: TzePoint2d): Double;inline; overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function Vertexmorph(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;inline;overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function Vertexmorph(const Vector1, Vector2: TzePoint2d; a: Double): TzePoint2d;inline;overload;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function VertexDmorph(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;overload;inline;
//**нахождение точки смещения от одной точки к другой в зависимости от коэффициент а
function VertexDmorph(const Vector1, Vector2: TzePoint3s; a: Double): TzePoint3s;overload;inline;
function Vertexangle(const Vector1, Vector2: TzePoint2d): Double;inline;
function TwoVectorAngle(const Vector1, Vector2: TzePoint3d): Double;inline;
function oneVertexlength(const Vector1: TzePoint3d): Double;inline;
function oneVertexlength2D(const Vector1: TzePoint2d): Double;inline;
function SqrOneVertexlength(const Vector1: TzePoint3d): Double;inline;
function vertexlen2df(const x1, y1, x2, y2: Single): Single;inline;
function NormalizeVertex(const Vector1: TzePoint3d): TzePoint3d;inline;
function NormalizeVertex2D(const Vector1: TzePoint2d): TzePoint2d;inline;
function VertexMulOnSc(const Vector1:TzePoint3d;sc:Double): TzePoint3d;inline;
function Vertex2DMulOnSc(const Vector1:TzePoint2d;sc:Double): TzePoint2d;inline;

//к первой вершине прибавить вторую по осям Vector1.х + Vector2.х
function VertexAdd(const Vector1, Vector2: TzePoint3d): TzePoint3d;inline;overload;
function VertexAdd(const Vector1, Vector2: TzePoint3s): TzePoint3s;inline;overload;
function VertexAdd(const Vector1, Vector2: TzePoint2d): TzePoint2d;inline;overload;
function VertexSub(const Vector1, Vector2: TzePoint3d): TzePoint3d;overload;inline;
function VertexSub(const Vector1, Vector2: TzePoint2d): TzePoint2d;overload;inline;
function VertexSub(const Vector1, Vector2: TzePoint3s): TzePoint3s;overload;inline;
//function MinusVertex(const Vector1: TzePoint3d): TzePoint3d;inline;
function vertexlen2id(const x1, y1, x2, y2: Integer): Double;inline;
function Vertexdmorphabs(const Vector1, Vector2: TzePoint3d;a: Double): TzePoint3d;inline;
function Vertexmorphabs(const Vector1, Vector2: TzePoint3d;a: Double): TzePoint3d;inline;
function Vertexmorphabs2(const Vector1, Vector2: TzePoint3d;a: Double): TzePoint3d;inline;
function MatrixMultiply(const M1, M2: DMatrix4D):DMatrix4D;overload;inline;
function MatrixMultiply(const M1: DMatrix4D; const M2: DMatrix4f):DMatrix4D;overload;inline;
function MatrixMultiplyF(const M1, M2: DMatrix4D):DMatrix4f;inline;
function VectorTransform(const V:TzeVector4d;const M:DMatrix4D):TzeVector4d;overload;inline;
function VectorTransform(const V:TzeVector4d;const M:DMatrix4f):TzeVector4d;overload;inline;
function VectorTransform(const V:TzeVector4s;const M:DMatrix4f):TzeVector4s;overload;inline;
procedure normalize4d(var tv:TzeVector4d);overload;inline;
procedure normalize4F(var tv:TzeVector4s);overload;inline;
function VectorTransform3D(const V:TzePoint3d;const M:DMatrix4D):TzePoint3d;overload;inline;
function VectorTransform3D(const V:TzePoint3d;const M:DMatrix4f):TzePoint3d;overload;inline;
function VectorTransform3D(const V:TzePoint3s;const M:DMatrix4D):TzePoint3s;overload;inline;
function VectorTransform3D(const V:TzePoint3s;const M:DMatrix4f):TzePoint3s;overload;inline;

function FrustumTransform(const frustum:ClipArray;const M:DMatrix4D; MatrixAlreadyTransposed:Boolean=false):ClipArray;overload;inline;
function FrustumTransform(const frustum:ClipArray;const M:DMatrix4f; MatrixAlreadyTransposed:Boolean=false):ClipArray;overload;inline;

procedure MatrixTranspose(var M: DMatrix4D);overload;inline;
procedure MatrixTranspose(var M: DMatrix4f);overload;inline;
procedure MatrixNormalize(var M: DMatrix4D);inline;
function CreateRotationMatrixX(const angle: Double): DMatrix4D;inline;
function CreateRotationMatrixY(const angle: Double): DMatrix4D;inline;
function CreateRotationMatrixZ(const angle: Double): DMatrix4D;inline;
function CreateRotatedXVector(const angle: Double):TzePoint3d;inline;
function CreateRotatedYVector(const angle: Double):TzePoint3d;inline;
function CreateAffineRotationMatrix(const anAxis: TzePoint3d; angle: double):DMatrix4D;inline;
function distance2piece(const q:TzePoint2i;const p1,p2:TzePoint2d): double;overload;inline;
function distance2piece(const q,p1,p2:TzePoint3d): {DistAndPoint}double;overload;inline;

function distance2piece_2(const q:TzePoint2i; const p1,p2:TzePoint2d): double;overload;inline;
function distance2piece_2(const q:TzePoint2i; const p1,p2:TzePoint2i): double;overload;inline;
function distance2piece_2Dmy(const q:TzePoint2d; const p1,p2:TzePoint2d): double;inline;

function distance2piece_2_xy(const q:TzePoint2i;const p1,p2:TzePoint2d):TzePoint2i;inline;

function distance2point_2(const p1,p2:TzePoint2i):Integer;inline;
function distance2ray(const q:TzePoint3d;const p1,p2:TzePoint3d):DistAndt;
function CreateTranslationMatrix(const _V:TzePoint3d):DMatrix4D;inline;overload;
function CreateTranslationMatrix(const tx,ty,tz:Double):DMatrix4D;inline;overload;
function CreateScaleMatrix(const V:TzePoint3d): DMatrix4D;inline;overload;
function CreateScaleMatrix(const s:Double): DMatrix4D;inline;overload;
function CreateScaleMatrix(const sx,sy,sz:Double): DMatrix4D;inline;overload;
function CreateReflectionMatrix(const plane:TzeVector4d): DMatrix4D;
//**Создать 3D вершину
function CreateVertex(const _x,_y,_z:Double):TzePoint3d;inline;
function CreateVertexFromArray(var counter:integer;const args:array of const):TzePoint3d;
function CreateVertex2DFromArray(var counter:integer;const args:array of const):TzePoint2d;
function CreateDoubleFromArray(var counter:integer;const args:array of const):Double; inline;
function CreateStringFromArray(var counter:integer;const args:array of const):String; inline;
function CreateBooleanFromArray(var counter:integer;const args:array of const):Boolean; inline;
//**Создать 2D вершину
function CreateVertex2D(const _x,_y:Double):TzePoint2d;inline;
function IsPointInBB(const point, LBN, RTF:TzePoint3d):Boolean; overload; inline;
function IsPointInBB(const point:TzePoint3d; const fistbb:TBoundingBox):Boolean; overload; inline;
function CreateBBFrom2Point(const p1,p2:TzePoint3d):TBoundingBox;
function CreateBBFromPoint(const p:TzePoint3d):TBoundingBox;inline;
procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox); inline;
procedure concatBBandPoint(var fistbb:TBoundingBox;const point:TzePoint3d);inline;
function IsBBNul(const v1, v2: TzePoint3d): Boolean; overload; inline;
function IsBBNul(const bb:TBoundingBox):boolean; overload; inline;
function boundingintersect(const bb1,bb2:TBoundingBox):Boolean;inline;
function ScaleBB(const bb:TBoundingBox;const k:Double):TBoundingBox;
procedure MatrixInvert(var M: DMatrix4D);inline;
function VectorDot(const v1,v2:TzePoint3d):TzePoint3d;inline;
function scalardot(const v1,v2:TzePoint3d):Double;inline;
function vertexeq(const v1,v2:TzePoint3d):Boolean;inline;
function SQRdist_Point_to_Segment(const p:TzePoint3d;const s0,s1:TzePoint3d):Double;inline;
function NearestPointOnSegment(const p:TzePoint3d;const s0,s1:TzePoint3d):TzePoint3d;inline;
function IsPointEqual(const p1,p2:TzePoint3d;const _eps:Double=eps):boolean;inline;
function IsPoint2DEqual(const p1,p2:TzePoint2d):boolean;inline;
function IsVectorNul(const p2:TzePoint3d):boolean;inline;
function IsDoubleNotEqual(const d1,d2:Double;const _eps:Double=eps):boolean;inline;
function IsDoubleEqual(const d1,d2:Double;const _eps:Double=eps):boolean;inline;
function IsFloatNotEqual(const d1,d2:Single;const _floateps:Single=floateps):boolean;inline;
function IsZero(const d:Double;const _eps:Double=eps):boolean;inline;
function IsNotZero(const d:Double;const _eps:Double=eps):boolean;inline;
//проверка вектора на близость к оси Z (координаты x и y меньше 1/64
//используется для Arbitrary Axis Algorithm (DXF)
//TODO: заменить в коде все проверки на функцию
function IsNearToZ(const v:TzePoint3d):boolean;inline;

procedure _myGluProject(const objx,objy,objz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i; out winx,winy,winz:Double);inline;
procedure _myGluProject2(const objcoord:TzePoint3d;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i; out wincoord:TzePoint3d);inline;
procedure _myGluUnProject(const winx,winy,winz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i;out objx,objy,objz:Double);inline;

function ortho(const xmin,xmax,ymin,ymax,zmin,zmax:Double;const matrix:PDMatrix4D):DMatrix4D;{inline;}
function Perspective(const fovy,W_H,zmin,zmax:Double;const matrix:PDMatrix4D):DMatrix4D;inline;
function LookAt(point,ex,ey,ez:TzePoint3d;const matrix:PDMatrix4D):DMatrix4D;inline;

function calcfrustum(const clip:PDMatrix4D):cliparray;inline;
function PointOf3PlaneIntersect(const P1,P2,P3:TzeVector4d):TzePoint3d;inline;
function PointOfRayPlaneIntersect(const p1,d:TzePoint3d;const plane:TzeVector4d;out point :TzePoint3d):Boolean;overload;inline;
function PointOfRayPlaneIntersect(const p1,d:TzePoint3d;const plane:TzeVector4d;out t :double):Boolean;overload;inline;
function PlaneFrom3Pont(const P1,P2,P3:TzePoint3d):TzeVector4d;inline;
procedure NormalizePlane(var plane:TzeVector4d);inline;

function CalcTrueInFrustum (const lbegin,lend:TzePoint3d; const frustum:ClipArray):TInBoundingVolume;overload;inline;
function CalcTrueInFrustum (const lbegin,lend:TzePoint3s; const frustum:ClipArray):TInBoundingVolume;overload;
function CalcPointTrueInFrustum (const lbegin:TzePoint3d; const frustum:ClipArray):TInBoundingVolume; inline;
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:ClipArray):TInBoundingVolume;inline;
function CalcAABBInFrustum (const AABB:TBoundingBox; const frustum:ClipArray):TInBoundingVolume;inline;

function GetXfFromZ(const oz:TzePoint3d):TzePoint3d;inline;

function MatrixDeterminant(const M: DMatrix4D):Double;
function CreateMatrixFromBasis(const ox,oy,oz:TzePoint3d):DMatrix4D; inline;
procedure CreateBasisFromMatrix(const m:DMatrix4D;out ox,oy,oz:TzePoint3d); inline;

function QuaternionFromMatrix(const mat : DMatrix4D) : TzeQuaternion;
function QuaternionSlerp(const source, dest: TzeQuaternion; const t: Double): TzeQuaternion;
function QuaternionToMatrix(quat : TzeQuaternion) :  DMatrix4D;

function GetArcParamFrom3Point2D(Const PointData:tarcrtmodify;out ad:TArcData):Boolean;

function isNotReadableAngle(Angle:Double):Boolean; inline;
function CorrectAngleIfNotReadable(Angle:Double):Double; inline;

function GetCSDirFrom0x0y2D(const ox,oy:TzePoint3d):TCSDir;

function CalcDisplaySubFrustum(const x,y,w,h:Double;const mm,pm:DMatrix4D;const vp:TzeVector4i):ClipArray;
function myPickMatrix(const x,y,deltax,deltay:Double;const vp:TzeVector4i): DMatrix4D;

function GetPointInOCSByBasis(const ScaledBX,ScaledBY,ScaledBZ:TzePoint3d; const PointInWCS:TzePoint3d; out scale:TzePoint3d):GDBObj2dprop;
function GetPInsertInOCSBymatrix(constref matrix:DMatrix4D;out scale:TzePoint3d):GDBObj2dprop;

var
  WorldMatrix{,CurrentCS}:DMatrix4D;
  wx:PzePoint3d;
  wy:PzePoint3d;
  wz:PzePoint3d;
  w0:PzePoint3d;

type
  TLineClipArray=array[0..5]of Double;

implementation

function GetPointInOCSByBasis(const ScaledBX,ScaledBY,ScaledBZ:TzePoint3d; const PointInWCS:TzePoint3d; out scale:TzePoint3d):GDBObj2dprop;
var
  //tznam,tr:Double;
  BX,BY,BZ:TzePoint3d;
begin
  scale.x:=oneVertexlength(ScaledBX);
  scale.y:=oneVertexlength(ScaledBY);
  scale.z:=oneVertexlength(ScaledBZ);
  if (abs(scale.x)>eps)and(abs(scale.y)>eps)and(abs(scale.z)>eps)then begin

    BX:=ScaledBX/scale.x;
    BY:=ScaledBY/scale.y;
    BZ:=ScaledBZ/scale.z;


    if scalardot(BX,VectorDot(BY,Bz))<0 then
      scale.x:=-scale.x;

    result.Basis.ox:=BX;
    result.Basis.oy:=BY;
    result.Basis.oz:=BZ;

    BX:=NormalizeVertex(GetXfFromZ(BZ));
    BY:=NormalizeVertex(VectorDot(BZ,Bx));

    //вариант из https://ezdxf.readthedocs.io/en/stable/concepts/ocs.html#arbitrary-axis-algorithm
    result.P_insert.x:=PointInWCS.x*BX.x+PointInWCS.y*BX.y+PointInWCS.z*BX.z;
    result.P_insert.y:=PointInWCS.x*BY.x+PointInWCS.y*BY.y+PointInWCS.z*BY.z;
    result.P_insert.z:=PointInWCS.x*BZ.x+PointInWCS.y*BZ.y+PointInWCS.z*BZ.z;

    //вариант расчета без учета что базисные векторы ортогональны
    (*
    //  -((-BY.z*BZ.y*PointInWCS.x+BY.y*BZ.z*PointInWCS.x+BY.z*BZ.x*PointInWCS.y-BY.x*BZ.z*PointInWCS.y-BY.y*BZ.x*PointInWCS.z+BY.x*BZ.y*PointInWCS.z)
    //X=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    //  -((BX.z*BZ.y*PointInWCS.x-BX.y*BZ.z*PointInWCS.x-BX.z*BZ.x*PointInWCS.y+BX.x*BZ.z*PointInWCS.y+BX.y*BZ.x*PointInWCS.z-BX.x*BZ.y*PointInWCS.z)
    //Y=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    //  -((-BX.z*BY.y*PointInWCS.x+BX.y*BY.z*PointInWCS.x+BX.z*BY.x*PointInWCS.y-BX.x*BY.z*PointInWCS.y-BX.y*BY.x*PointInWCS.z+BX.x*BY.y*PointInWCS.z)
    //Z=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    tznam:=BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z;
    if abs(tznam)>eps then begin
      tr:=-BY.z*BZ.y*PointInWCS.x+BY.y*BZ.z*PointInWCS.x+BY.z*BZ.x*PointInWCS.y-BY.x*BZ.z*PointInWCS.y-BY.y*BZ.x*PointInWCS.z+BY.x*BZ.y*PointInWCS.z;
      result.P_insert.x:=-tr/tznam;
      tr:=BX.z*BZ.y*PointInWCS.x-BX.y*BZ.z*PointInWCS.x-BX.z*BZ.x*PointInWCS.y+BX.x*BZ.z*PointInWCS.y+BX.y*BZ.x*PointInWCS.z-BX.x*BZ.y*PointInWCS.z;
      result.P_insert.y:=-tr/tznam;
      tr:=-BX.z*BY.y*PointInWCS.x+BX.y*BY.z*PointInWCS.x+BX.z*BY.x*PointInWCS.y-BX.x*BY.z*PointInWCS.y-BX.y*BY.x*PointInWCS.z+BX.x*BY.y*PointInWCS.z;
      result.P_insert.z:=-tr/tznam;
    end;
    *)
  end;
end;

function GetPInsertInOCSBymatrix(constref matrix:DMatrix4D;out scale:TzePoint3d):GDBObj2dprop;
var
  BX,BY,BZ,T:TzePoint3d;
begin
  BX:=PzePoint3d(@matrix.mtr[0])^;
  BY:=PzePoint3d(@matrix.mtr[1])^;
  BZ:=PzePoint3d(@matrix.mtr[2])^;
  T:=PzePoint3d(@matrix.mtr[3])^;
  result:=GetPointInOCSByBasis(BX,BY,BZ,T,scale);
end;

function VertexSub(const Vector1, Vector2: TzePoint3d): TzePoint3d;
begin
  with TzePoint3d((@Result)^) do
  begin
    X := Vector1.x - Vector2.x;
    Y := Vector1.y - Vector2.y;
    Z := Vector1.z - Vector2.z;
  end;
end;

function VertexSub(const Vector1, Vector2: TzePoint2d): TzePoint2d;
begin
  with TzePoint2d((@Result)^) do
  begin
    X := Vector1.x - Vector2.x;
    Y := Vector1.y - Vector2.y;
  end;
end;

function VertexSub(const Vector1, Vector2: TzePoint3s): TzePoint3s;
begin
  with TzePoint3s((@Result)^) do
  begin
    X := Vector1.x - Vector2.x;
    Y := Vector1.y - Vector2.y;
    Z := Vector1.z - Vector2.z;
  end;
end;

function ToTzeVector4s(const m:TzeVector4d):TzeVector4s; inline;
begin
  with TzeVector4s((@result)^) do // Этот хак убирает по одной лишней инструкции с каждого присвоения
  begin                         // возможно в будущем, это можно будет убрать, когда компилятор
                                // сможет сам это оптимизировать
    v[0]:=m.v[0];
    v[1]:=m.v[1];
    v[2]:=m.v[2];
    v[3]:=m.v[3];
  end;

  //result.v[0]:=m.v[0];
  //result.v[1]:=m.v[1];
  //result.v[2]:=m.v[2];
  //result.v[3]:=m.v[3];
end;
function ToDMatrix4f(const m:DMatrix4D):DMatrix4f;
begin
  result.mtr[0]:=ToTzeVector4s(m.mtr[0]);
  result.mtr[1]:=ToTzeVector4s(m.mtr[1]);
  result.mtr[2]:=ToTzeVector4s(m.mtr[2]);
  result.mtr[3]:=ToTzeVector4s(m.mtr[3]);
  result.t:=m.t;
end;

function ToTzePoint2i(const _V:TzePoint3d):TzePoint2i;
begin
  result.x:=round(_V.x);
  result.y:=round(_V.y);
end;

function VertexD2S(const Vector1:TzePoint3d): TzePoint3s;
begin
     result.x:=Vector1.x;
     result.y:=Vector1.y;
     result.z:=Vector1.z;
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
function IsZero(const d:Double;const _eps:Double=eps):boolean;inline;
begin
  result:=abs(d)<_eps
end;
function IsNotZero(const d:Double;const _eps:Double=eps):boolean;inline;
begin
  result:=abs(d)>=_eps
end;


function IsNearToZ(const v:TzePoint3d):boolean;
const
  tol=1/64;
begin
  result:=(abs(v.x)<tol)and(abs(v.y)<tol);
  //if (abs(v.x)<tol)and(abs(v.y)<tol) then
  //  result:=true
  //else
  //  result:=false;
end;

function GetXfFromZ(const oz:TzePoint3d):TzePoint3d;
begin
  //if (abs (oz.x) < 1/64) and (abs (oz.y) < 1/64) then
  if IsNearToZ(oz)then
    result:=VectorDot(YWCS,oz)
  else
    result:=VectorDot(ZWCS,oz);
  result:=NormalizeVertex(result);
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
//    d:TzePoint3d;
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
        with frustum[i] do
        begin
          d1:=v[0] * outbound[0].x + v[1] * outbound[0].y + v[2] * outbound[0].z + v[3];
          d2:=v[0] * outbound[1].x + v[1] * outbound[1].y + v[2] * outbound[1].z + v[3];
          d3:=v[0] * outbound[2].x + v[1] * outbound[2].y + v[2] * outbound[2].z + v[3];
          d4:=v[0] * outbound[3].x + v[1] * outbound[3].y + v[2] * outbound[3].z + v[3];
        end;
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
function CalcPointTrueInFrustum (const lbegin:TzePoint3d; const frustum:ClipArray):TInBoundingVolume;
var i{,j}:Integer;
    //d1{,d2}:Double;
    //bytebegin,byteend,bit:integer;
    //ca:TLineClipArray;
    //cacount:integer;
    //d,p:TzePoint3d;
begin
      for i:=0 to 5 do
      begin
        with frustum[i] do if (v[0] * lbegin.x + v[1] * lbegin.y + v[2] * lbegin.z + v[3]) < 0 then exit(IREmpty);
      end;
      result:=IRFully;
end;

procedure NormalizePlane(var plane:TzeVector4d);{inline;}
var t:Double;
begin
  with TzeVector4d((@plane)^) do
  begin
    t := sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    v[0] := v[0]/t;
    v[1] := v[1]/t;
    v[2] := v[2]/t;
    v[3] := v[3]/t;
  end;
end;

function PlaneFrom3Pont(const P1,P2,P3:TzePoint3d):TzeVector4d;
//var
//   N1,N2,N3,N12,N23,N31,a1,a2,a3:TzePoint3d;
//   a4:Double;
begin
  with TzePoint3d((@P1)^) do
  begin
    result.v[0]:=   y*(P2.z - P3.z)           + P2.y*(P3.z - z)        + P3.y*(z - P2.z);
    result.v[1]:=   z*(P2.x - P3.x)           + P2.z*(P3.x - x)        + P3.z*(x - P2.x);
    result.v[2]:=   x*(P2.y - P3.y)           + P2.x*(P3.y - y)        + P3.x*(y - P2.y);
    result.v[3]:= -(x*(P2.y*P3.z - P3.y*P2.z) + P2.x*(P3.y*z - y*P3.z) + P3.x*(y*P2.z - P2.y*z));
  end;
end;


function calcfrustum(const clip:PDMatrix4D):cliparray;
var t:Double;
begin
   //* Находим A, B, C, D для ПРАВОЙ плоскости */
   with TzeVector4d((@result[0])^) do
   begin
     v[0] := clip.mtr[0].v[3] - clip.mtr[0].v[0];
     v[1] := clip.mtr[1].v[3] - clip.mtr[1].v[0];
     v[2] := clip.mtr[2].v[3] - clip.mtr[2].v[0];
     v[3] := clip.mtr[3].v[3] - clip.mtr[3].v[0];

     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;

   //* Находим A, B, C, D для ЛЕВОЙ плоскости */
   with TzeVector4d((@result[1])^) do
   begin
     v[0] := clip.mtr[0].v[3] + clip.mtr[0].v[0];
     v[1] := clip.mtr[1].v[3] + clip.mtr[1].v[0];
     v[2] := clip.mtr[2].v[3] + clip.mtr[2].v[0];
     v[3] := clip.mtr[3].v[3] + clip.mtr[3].v[0];
     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;

   //* Находим A, B, C, D для НИЖНЕЙ плоскости */
   with TzeVector4d((@result[2])^) do
   begin
     v[0] := clip.mtr[0].v[3] + clip.mtr[0].v[1];
     v[1] := clip.mtr[1].v[3] + clip.mtr[1].v[1];
     v[2] := clip.mtr[2].v[3] + clip.mtr[2].v[1];
     v[3] := clip.mtr[3].v[3] + clip.mtr[3].v[1];
     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;

   //* ВЕРХНЯЯ плоскость */
   with TzeVector4d((@result[3])^) do
   begin
     v[0] := clip.mtr[0].v[3] - clip.mtr[0].v[1];
     v[1] := clip.mtr[1].v[3] - clip.mtr[1].v[1];
     v[2] := clip.mtr[2].v[3] - clip.mtr[2].v[1];
     v[3] := clip.mtr[3].v[3] - clip.mtr[3].v[1];
     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;

   //* ПЕРЕДНЯЯ плоскость */
   with TzeVector4d((@result[4])^) do
   begin
     v[0] := clip.mtr[0].v[3] + clip.mtr[0].v[2];
     v[1] := clip.mtr[1].v[3] + clip.mtr[1].v[2];
     v[2] := clip.mtr[2].v[3] + clip.mtr[2].v[2];
     v[3] := clip.mtr[3].v[3] + clip.mtr[3].v[2];
     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;

   //* ?? плоскость */
   with TzeVector4d((@result[5])^) do
   begin
     v[0] := clip.mtr[0].v[3] - clip.mtr[0].v[2];
     v[1] := clip.mtr[1].v[3] - clip.mtr[1].v[2];
     v[2] := clip.mtr[2].v[3] - clip.mtr[2].v[2];
     v[3] := clip.mtr[3].v[3] - clip.mtr[3].v[2];
     t := sqrt( v[0] * v[0] + v[1] * v[1] + v[2] * v[2] );
     v[0] := v[0]/t;
     v[1] := v[1]/t;
     v[2] := v[2]/t;
     v[3] := v[3]/t;
   end;
end;

function vertexeq(const v1,v2:TzePoint3d):Boolean;
var x,y,z:Double;
begin
     x:=v2.x-v1.x;
     y:=v2.y-v1.y;
     z:=v2.z-v1.z;
     result:=x*x+y*y+z*z<bigeps;
end;
function distance2point_2(const p1,p2:TzePoint2i):Integer;
var x,y:Integer;
begin
     x:=p2.x-p1.x;
     y:=p2.y-p1.y;
     result:=x*x+y*y;
end;
function MatrixDetInternal(const a1, a2, a3, b1, b2, b3, c1, c2, c3:Double):Double; inline;
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
  with TzeVector4d((@M.mtr[0])^) do begin
    a1 := v[0];  b1 := v[1];  c1 := v[2];  d1 := v[3];
  end;
  with TzeVector4d((@M.mtr[1])^) do begin
    a2 := v[0];  b2 := v[1];  c2 := v[2];  d2 := v[3];
  end;
  with TzeVector4d((@M.mtr[2])^) do begin
    a3 := v[0];  b3 := v[1];  c3 := v[2];  d3 := v[3];
  end;
  with TzeVector4d((@M.mtr[3])^) do begin
    a4 := v[0];  b4 := v[1];  c4 := v[2];  d4 := v[3];
  end;
    //a1 :=  M[0].v[0]; b1 :=  M[0].v[1];
    //c1 :=  M[0].v[2]; d1 :=  M[0].v[3];
    //a2 :=  M[1].v[0]; b2 :=  M[1].v[1];
    //c2 :=  M[1].v[2]; d2 :=  M[1].v[3];
    //a3 :=  M[2].v[0]; b3 :=  M[2].v[1];
    //c3 :=  M[2].v[2]; d3 :=  M[2].v[3];
    //a4 :=  M[3].v[0]; b4 :=  M[3].v[1];
    //c4 :=  M[3].v[2]; d4 :=  M[3].v[3];

    // row column labeling reversed since we transpose rows & columns
    M.mtr[XAxisIndex].v[XAxisIndex] :=  MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    M.mtr[XAxisIndex].v[YAxisIndex] := -MatrixDetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    M.mtr[XAxisIndex].v[ZAxisIndex] :=  MatrixDetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    M.mtr[XAxisIndex].v[WAxisIndex] := -MatrixDetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);

    M.mtr[YAxisIndex].v[XAxisIndex] := -MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    M.mtr[YAxisIndex].v[YAxisIndex] :=  MatrixDetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    M.mtr[YAxisIndex].v[ZAxisIndex] := -MatrixDetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    M.mtr[YAxisIndex].v[WAxisIndex] :=  MatrixDetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);

    M.mtr[ZAxisIndex].v[XAxisIndex] :=  MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    M.mtr[ZAxisIndex].v[YAxisIndex] := -MatrixDetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    M.mtr[ZAxisIndex].v[ZAxisIndex] :=  MatrixDetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    M.mtr[ZAxisIndex].v[WAxisIndex] := -MatrixDetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);

    M.mtr[WAxisIndex].v[XAxisIndex] := -MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
    M.mtr[WAxisIndex].v[YAxisIndex] :=  MatrixDetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);
    M.mtr[WAxisIndex].v[ZAxisIndex] := -MatrixDetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);
    M.mtr[WAxisIndex].v[WAxisIndex] :=  MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;
function MatrixDeterminant(const M: DMatrix4D): Double;
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : Double;
begin
  with TzeVector4d((@M.mtr[0])^) do begin
    a1 := v[0];  b1 := v[1];  c1 := v[2];  d1 := v[3];
  end;
  with TzeVector4d((@M.mtr[1])^) do begin
    a2 := v[0];  b2 := v[1];  c2 := v[2];  d2 := v[3];
  end;
  with TzeVector4d((@M.mtr[2])^) do begin
    a3 := v[0];  b3 := v[1];  c3 := v[2];  d3 := v[3];
  end;
  with TzeVector4d((@M.mtr[3])^) do begin
    a4 := v[0];  b4 := v[1];  c4 := v[2];  d4 := v[3];
  end;
  //a1 := M[0].v[0];  b1 := M[0].v[1];  c1 := M[0].v[2];  d1 := M[0].v[3];
  //a2 := M[1].v[0];  b2 := M[1].v[1];  c2 := M[1].v[2];  d2 := M[1].v[3];
  //a3 := M[2].v[0];  b3 := M[2].v[1];  c3 := M[2].v[2];  d3 := M[2].v[3];
  //a4 := M[3].v[0];  b4 := M[3].v[1];  c4 := M[3].v[3];  d4 := M[3].v[3];

  Result := a1 * MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;
procedure MatrixScale(var M: DMatrix4D; const Factor: Double);
//var I, J: Integer;
begin
  with TzeVector4d((@M.mtr[0])^) do begin
    v[0] := v[0] * Factor;
    v[1] := v[1] * Factor;
    v[2] := v[2] * Factor;
    v[3] := v[3] * Factor;
  end;
  with TzeVector4d((@M.mtr[1])^) do begin
    v[0] := v[0] * Factor;
    v[1] := v[1] * Factor;
    v[2] := v[2] * Factor;
    v[3] := v[3] * Factor;
  end;
  with TzeVector4d((@M.mtr[2])^) do begin
    v[0] := v[0] * Factor;
    v[1] := v[1] * Factor;
    v[2] := v[2] * Factor;
    v[3] := v[3] * Factor;
  end;
  with TzeVector4d((@M.mtr[3])^) do begin
    v[0] := v[0] * Factor;
    v[1] := v[1] * Factor;
    v[2] := v[2] * Factor;
    v[3] := v[3] * Factor;
  end;
  //for I := 0 to 3 do
  //  for J := 0 to 3 do M[I].v[J] := M[I].v[J] * Factor;
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

function distance2piece(const q,p1,p2:TzePoint3d):{DistAndPoint}double;
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

function distance2piece(const q:TzePoint2i;const p1,p2:TzePoint2d): double;
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
function distance2piece_2(const q:TzePoint2i; const p1,p2:TzePoint2d): double;
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
function distance2piece_2(const q,p1,p2:TzePoint2i): double;
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
function distance2piece_2dmy(const q,p1,p2:TzePoint2d): double;
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

function distance2piece_2_xy(const q:TzePoint2i;const p1,p2:TzePoint2d):TzePoint2i;
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

function CreateTranslationMatrix(const _V:TzePoint3d): DMatrix4D;
begin
  Result.CreateRec(onemtr,CMTTranslate);
  with TzeVector4d((@Result.mtr[3])^) do
  begin
    v[0] := _V.x;
    v[1] := _V.y;
    v[2] := _V.z;
    v[3] := 1;
  end;
end;
function CreateTranslationMatrix(const tx,ty,tz:Double):DMatrix4D;
begin
  Result.CreateRec(onemtr,CMTTranslate);
  with TzeVector4d((@Result.mtr[3])^) do begin
    v[0]:=tx;
    v[1]:=ty;
    v[2]:=tz;
    v[3]:=1;
  end;
end;
function CreateReflectionMatrix(const plane:TzeVector4d): DMatrix4D;
var
  d: double;
begin
  with TzeVector4d((@plane)^) do
  begin
    d:=v[0];
    result.mtr[0].v[0] :=-2 * d * v[0] + 1;
    result.mtr[1].v[0] :=-2 * d * v[1];
    result.mtr[2].v[0] :=-2 * d * v[2];
    result.mtr[3].v[0] :=-2 * d * v[3];

    d:=v[1];
    result.mtr[0].v[1] :=-2 * d * v[0];
    result.mtr[1].v[1] :=-2 * d * v[1] + 1;
    result.mtr[2].v[1] :=-2 * d * v[2];
    result.mtr[3].v[1] :=-2 * d * v[3];

    d:=v[2];
    result.mtr[0].v[2] :=-2 * d * v[0];
    result.mtr[1].v[2] :=-2 * d * v[1];
    result.mtr[2].v[2] :=-2 * d * v[2] + 1;
    result.mtr[3].v[2] :=-2 * d * v[3];
  end;

  result.mtr[0].v[3]:=0;
  result.mtr[1].v[3]:=0;
  result.mtr[2].v[3]:=0;
  result.mtr[3].v[3]:=1;
  Result.t:=CMTTransform;
end;

function CreateScaleMatrix(const V:TzePoint3d): DMatrix4D;
begin
  Result.mtr:=onemtr;
  Result.mtr[0].v[0]:=V.x;
  Result.mtr[1].v[1]:=V.y;
  Result.mtr[2].v[2]:=V.z;
  Result.mtr[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateScaleMatrix(const s:Double): DMatrix4D;
begin
  Result.mtr:=onemtr;
  Result.mtr[0].v[0]:=S;
  Result.mtr[1].v[1]:=S;
  Result.mtr[2].v[2]:=S;
  Result.mtr[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateScaleMatrix(const sx,sy,sz:Double): DMatrix4D;inline;overload;
begin
  Result.mtr:=onemtr;
  Result.mtr[0].v[0]:=sx;
  Result.mtr[1].v[1]:=sy;
  Result.mtr[2].v[2]:=sz;
  Result.mtr[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateRotationMatrixX(const angle: Double): DMatrix4D;
var
  Sine, Cosine: Double;
begin
  SinCos(angle, Sine, Cosine);
  Result := EmptyMatrix;
  Result.mtr[0].v[0] := 1;
  Result.mtr[1].v[1] := Cosine;
  Result.mtr[1].v[2] := Sine;
  Result.mtr[2].v[1] := -Sine;
  Result.mtr[2].v[2] := Cosine;
  Result.mtr[3].v[3] := 1;
  Result.t:=CMTRotate;
end;
function CreateRotationMatrixY(const angle: Double): DMatrix4D;
var
  Sine, Cosine: Double;
begin
  SinCos(angle, Sine, Cosine);
  Result := EmptyMatrix;
  Result.mtr[0].v[0] := Cosine;
  Result.mtr[0].v[2] := -Sine;
  Result.mtr[1].v[1] := 1;
  Result.mtr[2].v[0] := Sine;
  Result.mtr[2].v[2] := Cosine;
  Result.mtr[3].v[3] := 1;
  Result.t:=CMTRotate;
end;
function CreateRotatedXVector(const angle: Double):TzePoint3d;
begin
  SinCos(angle, Result.y, Result.x);
  Result.z:=0;
end;
function CreateRotatedYVector(const angle: Double):TzePoint3d;
begin
  Result:=CreateRotatedXVector(angle+pi/2);
end;
function CreateRotationMatrixZ(const angle: Double): DMatrix4D;
var
  Sine, Cosine: Double;
begin
  SinCos(angle, Sine, Cosine);
  Result := Onematrix;
  Result.mtr[0].v[0] := Cosine;
  Result.mtr[0].v[1] := Sine;
  Result.mtr[1].v[1] := Cosine;
  Result.mtr[1].v[0] := -Sine;
  Result.t:=CMTRotate;
end;

function MatrixMultiply(const M1, M2: DMatrix4D): DMatrix4D;
var I: Integer;
begin
  for I := 3 downto 0 do
  begin
    with M1.mtr[I] do
    begin
      Result.mtr[I].v[0] := v[0]*M2.mtr[0].v[0] + v[1]*M2.mtr[1].v[0] + v[2]*M2.mtr[2].v[0] + v[3]*M2.mtr[3].v[0];
      Result.mtr[I].v[1] := v[0]*M2.mtr[0].v[1] + v[1]*M2.mtr[1].v[1] + v[2]*M2.mtr[2].v[1] + v[3]*M2.mtr[3].v[1];
      Result.mtr[I].v[2] := v[0]*M2.mtr[0].v[2] + v[1]*M2.mtr[1].v[2] + v[2]*M2.mtr[2].v[2] + v[3]*M2.mtr[3].v[2];
      Result.mtr[I].v[3] := v[0]*M2.mtr[0].v[3] + v[1]*M2.mtr[1].v[3] + v[2]*M2.mtr[2].v[3] + v[3]*M2.mtr[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;
function MatrixMultiply(const M1: DMatrix4D; const M2: DMatrix4f):DMatrix4D;
var I: Integer;
begin
  for I := 3 downto 0 do
  begin
    with M1.mtr[I] do
    begin
      Result.mtr[I].v[0] := v[0]*M2.mtr[0].v[0] + v[1]*M2.mtr[1].v[0] + v[2]*M2.mtr[2].v[0] + v[3]*M2.mtr[3].v[0];
      Result.mtr[I].v[1] := v[0]*M2.mtr[0].v[1] + v[1]*M2.mtr[1].v[1] + v[2]*M2.mtr[2].v[1] + v[3]*M2.mtr[3].v[1];
      Result.mtr[I].v[2] := v[0]*M2.mtr[0].v[2] + v[1]*M2.mtr[1].v[2] + v[2]*M2.mtr[2].v[2] + v[3]*M2.mtr[3].v[2];
      Result.mtr[I].v[3] := v[0]*M2.mtr[0].v[3] + v[1]*M2.mtr[1].v[3] + v[2]*M2.mtr[2].v[3] + v[3]*M2.mtr[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;
function MatrixMultiplyF(const M1, M2: DMatrix4D):DMatrix4f;
var I: Integer;
begin
  for I := 3 downto 0 do
  begin
    with M1.mtr[I] do
    begin
      Result.mtr[I].v[0] := v[0]*M2.mtr[0].v[0] + v[1]*M2.mtr[1].v[0] + v[2]*M2.mtr[2].v[0] + v[3]*M2.mtr[3].v[0];
      Result.mtr[I].v[1] := v[0]*M2.mtr[0].v[1] + v[1]*M2.mtr[1].v[1] + v[2]*M2.mtr[2].v[1] + v[3]*M2.mtr[3].v[1];
      Result.mtr[I].v[2] := v[0]*M2.mtr[0].v[2] + v[1]*M2.mtr[1].v[2] + v[2]*M2.mtr[2].v[2] + v[3]*M2.mtr[3].v[2];
      Result.mtr[I].v[3] := v[0]*M2.mtr[0].v[3] + v[1]*M2.mtr[1].v[3] + v[2]*M2.mtr[2].v[3] + v[3]*M2.mtr[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;
procedure MatrixTranspose(var M: DMatrix4D);
var I: Integer;
    TM: DMatrix4D;
begin
  for I := 3 downto 0 do
  begin
    with M.mtr[I] do
    begin
      TM.mtr[0].v[I] := v[0];
      TM.mtr[1].v[I] := v[1];
      TM.mtr[2].v[I] := v[2];
      TM.mtr[3].v[I] := v[3];
    end;
  end;
  M.mtr:=TM.mtr;
end;
procedure MatrixTranspose(var M: DMatrix4f);
var I: Integer;
    TM: DMatrix4f;
begin
  for I := 3 downto 0 do
  begin
    with M.mtr[I] do
    begin
      TM.mtr[0].v[I] := v[0];
      TM.mtr[1].v[I] := v[1];
      TM.mtr[2].v[I] := v[2];
      TM.mtr[3].v[I] := v[3];
    end;
  end;
  M.mtr:=TM.mtr;
end;
procedure MatrixNormalize(var M: DMatrix4D);
var I{, J}: Integer;
    D: Double;
begin
  D:=M.mtr[3].v[3];
  for I := 3 downto 0 do
  begin
    with M.mtr[I] do
    begin
      v[0]:=v[0]/D;
      v[1]:=v[1]/D;
      v[2]:=v[2]/D;
      v[3]:=v[3]/D;
    end;
  end;
end;

function VectorTransform(const V:TzeVector4d;const M:DMatrix4D):TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4d((@V)^) do
    begin
      Result.X := X * M.mtr[0].v[0] + y * M.mtr[1].v[0] + z * M.mtr[2].v[0] + w * M.mtr[3].v[0];
      Result.Y := X * M.mtr[0].v[1] + y * M.mtr[1].v[1] + z * M.mtr[2].v[1] + w * M.mtr[3].v[1];
      Result.z := x * M.mtr[0].v[2] + y * M.mtr[1].v[2] + z * M.mtr[2].v[2] + w * M.mtr[3].v[2];
      Result.W := x * M.mtr[0].v[3] + y * M.mtr[1].v[3] + z * M.mtr[2].v[3] + w * M.mtr[3].v[3];
    end;
end;
function VectorTransform(const V:TzeVector4d;const M:DMatrix4f):TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4d((@V)^) do
    begin
      Result.X := X * M.mtr[0].v[0] + y * M.mtr[1].v[0] + z * M.mtr[2].v[0] + w * M.mtr[3].v[0];
      Result.Y := X * M.mtr[0].v[1] + y * M.mtr[1].v[1] + z * M.mtr[2].v[1] + w * M.mtr[3].v[1];
      Result.z := x * M.mtr[0].v[2] + y * M.mtr[1].v[2] + z * M.mtr[2].v[2] + w * M.mtr[3].v[2];
      Result.W := x * M.mtr[0].v[3] + y * M.mtr[1].v[3] + z * M.mtr[2].v[3] + w * M.mtr[3].v[3];
    end;
end;
function VectorTransform(const V:TzeVector4s;const M:DMatrix4f):TzeVector4s;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4s((@V)^) do
    begin
      Result.X := X * M.mtr[0].v[0] + y * M.mtr[1].v[0] + z * M.mtr[2].v[0] + w * M.mtr[3].v[0];
      Result.Y := X * M.mtr[0].v[1] + y * M.mtr[1].v[1] + z * M.mtr[2].v[1] + w * M.mtr[3].v[1];
      Result.z := x * M.mtr[0].v[2] + y * M.mtr[1].v[2] + z * M.mtr[2].v[2] + w * M.mtr[3].v[2];
      Result.W := x * M.mtr[0].v[3] + y * M.mtr[1].v[3] + z * M.mtr[2].v[3] + w * M.mtr[3].v[3];
    end;
end;
procedure normalize4F(var tv:TzeVector4s); inline;
begin
  if abs(tv.w)>eps then
  if abs(abs(tv.w)-1)>eps then
  begin
    with TzeVector4s((@tv)^) do
    begin
      x:=x/w;
      y:=y/w;
      z:=z/w;
    end;
  end;
end;
procedure normalize4d(var tv:TzeVector4d); inline;
begin
  if abs(tv.w)>eps then
  if abs(abs(tv.w)-1)>eps then
  begin
    with TzeVector4d((@tv)^) do
    begin
      x:=x/w;
      y:=y/w;
      z:=z/w;
    end;
  end;
end;
function VectorTransform3D(const V:TzePoint3d;const M:DMatrix4D):TzePoint3d;
var TV: TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
    PzePoint3d(@tv)^:=v;
    tv.w:=1;
    tv:=VectorTransform(tv,m);

    normalize4d(tv);

    Result := PzePoint3d(@tv)^
  end;
end;
function VectorTransform3D(const V:TzePoint3d;const M:DMatrix4f):TzePoint3d;
var TV: TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
    PzePoint3d(@tv)^:=v;
    tv.w:=1;
    tv:=VectorTransform(tv,m);

    normalize4d(tv);

    Result := PzePoint3d(@tv)^
  end;
end;
function VectorTransform3D(const V:TzePoint3s;const M:DMatrix4D):TzePoint3s;
var tv: TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
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
end;
function VectorTransform3D(const V:TzePoint3s;const M:DMatrix4f):TzePoint3s;
var tv: TzeVector4s;
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
          PzeVector4d(@result[0])^:=VectorTransform(PzeVector4d(@frustum[0])^,M);
          PzeVector4d(@result[1])^:=VectorTransform(PzeVector4d(@frustum[1])^,M);
          PzeVector4d(@result[2])^:=VectorTransform(PzeVector4d(@frustum[2])^,M);
          PzeVector4d(@result[3])^:=VectorTransform(PzeVector4d(@frustum[3])^,M);
          PzeVector4d(@result[4])^:=VectorTransform(PzeVector4d(@frustum[4])^,M);
          PzeVector4d(@result[5])^:=VectorTransform(PzeVector4d(@frustum[5])^,M);
        end
      else
        begin
          m1:=M;
          MatrixTranspose(m1);
          PzeVector4d(@result[0])^:=VectorTransform(PzeVector4d(@frustum[0])^,m1);
          PzeVector4d(@result[1])^:=VectorTransform(PzeVector4d(@frustum[1])^,m1);
          PzeVector4d(@result[2])^:=VectorTransform(PzeVector4d(@frustum[2])^,m1);
          PzeVector4d(@result[3])^:=VectorTransform(PzeVector4d(@frustum[3])^,m1);
          PzeVector4d(@result[4])^:=VectorTransform(PzeVector4d(@frustum[4])^,m1);
          PzeVector4d(@result[5])^:=VectorTransform(PzeVector4d(@frustum[5])^,m1);
        end;
end;
function FrustumTransform(const frustum:ClipArray;const M:DMatrix4f; MatrixAlreadyTransposed:Boolean=false):ClipArray;
var
   m1:DMatrix4f;
begin
     if MatrixAlreadyTransposed
      then
        begin
          PzeVector4d(@result[0])^:=VectorTransform(PzeVector4d(@frustum[0])^,M);
          PzeVector4d(@result[1])^:=VectorTransform(PzeVector4d(@frustum[1])^,M);
          PzeVector4d(@result[2])^:=VectorTransform(PzeVector4d(@frustum[2])^,M);
          PzeVector4d(@result[3])^:=VectorTransform(PzeVector4d(@frustum[3])^,M);
          PzeVector4d(@result[4])^:=VectorTransform(PzeVector4d(@frustum[4])^,M);
          PzeVector4d(@result[5])^:=VectorTransform(PzeVector4d(@frustum[5])^,M);
        end
      else
        begin
          m1:=M;
          MatrixTranspose(m1);
          PzeVector4d(@result[0])^:=VectorTransform(PzeVector4d(@frustum[0])^,m1);
          PzeVector4d(@result[1])^:=VectorTransform(PzeVector4d(@frustum[1])^,m1);
          PzeVector4d(@result[2])^:=VectorTransform(PzeVector4d(@frustum[2])^,m1);
          PzeVector4d(@result[3])^:=VectorTransform(PzeVector4d(@frustum[3])^,m1);
          PzeVector4d(@result[4])^:=VectorTransform(PzeVector4d(@frustum[4])^,m1);
          PzeVector4d(@result[5])^:=VectorTransform(PzeVector4d(@frustum[5])^,m1);
        end;
end;
function Vertexlength(const Vector1, Vector2: TzePoint3d): Double;
begin
  with TzePoint3d((@vector1)^) do result := sqrt(sqr(x - vector2.x) + sqr(y - vector2.y) + sqr(z - vector2.z));
end;
function Vertexlength2d(const Vector1, Vector2: TzePoint2d): Double;
begin
  with TzePoint2d((@vector1)^) do result := sqrt(sqr(x - vector2.x) + sqr(y - vector2.y));
end;
function SqrVertexlength(const Vector1, Vector2: TzePoint3d): Double;
begin
  with TzePoint3d((@vector1)^) do result := (sqr(x - vector2.x) + sqr(y - vector2.y) + sqr(z - vector2.z));
end;
function SqrVertexlength(const Vector1, Vector2: TzePoint2d): Double;
begin
  with TzePoint2d((@vector1)^) do result := (sqr(x - vector2.x) + sqr(y - vector2.y));
end;

function oneVertexlength(const Vector1: TzePoint3d): Double;
begin
  with TzePoint3d((@vector1)^) do result := sqrt(sqr(x) + sqr(y) + sqr(z));
end;

function oneVertexlength2D(const Vector1: TzePoint2d): Double;
begin
  with TzePoint2d((@vector1)^) do result := sqrt(sqr(x) + sqr(y));
end;

function SqrOneVertexlength(const Vector1: TzePoint3d): Double;
begin
  with TzePoint3d((@vector1)^) do result := (sqr(x) + sqr(y) + sqr(z));
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

function Vertexangle(const Vector1, Vector2: TzePoint2d): Double;
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

function Vertexmorph(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;
begin
  with TzePoint3d((@vector1)^) do
  begin
    result.x := x + (vector2.x - x) * a;
    result.y := y + (vector2.y - y) * a;
    result.z := z + (vector2.z - z) * a;
  end;
end;
function Vertexmorph(const Vector1, Vector2: TzePoint2d; a: Double): TzePoint2d;
begin
  with TzePoint2d((@vector1)^) do
  begin
    result.x := x + (vector2.x - x) * a;
    result.y := y + (vector2.y - y) * a;
  end;
end;

function VertexDmorph(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;
begin
  with TzePoint3d((@vector1)^) do
  begin
    result.x := x + (vector2.x) * a;
    result.y := y + (vector2.y) * a;
    result.z := z + (vector2.z) * a;
  end;
end;
function VertexDmorph(const Vector1, Vector2: TzePoint3s; a: Double): TzePoint3s;
begin
  with TzePoint3s((@vector1)^) do
  begin
    result.x := x + (vector2.x) * a;
    result.y := y + (vector2.y) * a;
    result.z := z + (vector2.z) * a;
  end;
end;

function Vertexdmorphabs(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;
var
  l: Double;
begin
  l := oneVertexlength(Vector2);
  if a > 0 then a := a / l
  else a := 1 + a / l;
  with TzePoint3d((@vector1)^) do
  begin
    result.x := x + (vector2.x) * a;
    result.y := y + (vector2.y) * a;
    result.z := z + (vector2.z) * a;
  end;
end;

function Vertexmorphabs(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;
var
  l: Double;
begin
  l := Vertexlength(Vector1, Vector2);
  if a > 0 then a := 1+a / l
  else a := 1 + a / l;
  with TzePoint3d((@vector1)^) do
  begin
    result.x := x + (vector2.x - x) * a;
    result.y := y + (vector2.y - y) * a;
    result.z := z + (vector2.z - z) * a;
  end;
end;
function Vertexmorphabs2(const Vector1, Vector2: TzePoint3d; a: Double): TzePoint3d;
var
  l: Double;
begin
  l := Vertexlength(Vector1, Vector2);
  if a > 0 then a := a / l
  else a := 1 + a / l;
  with TzePoint3d((@vector1)^) do
  begin
    result.x := x + (vector2.x - x) * a;
    result.y := y + (vector2.y - y) * a;
    result.z := z + (vector2.z - z) * a;
  end;
end;

function NormalizeVertex(const Vector1: TzePoint3d): TzePoint3d;
  procedure dbz;
  begin
    zDebugLn('{EH}'+rsDivByZero);
  end;
var len:Double;
begin
  len:=oneVertexlength(Vector1);
  if abs(len)>eps then begin
    with TzePoint3d((@Result)^) do begin
      X := Vector1.x / len;
      Y := Vector1.y / len;
      Z := Vector1.z / len;
    end;
  end else begin
    dbz;
    Result:=NulVertex;
  end;
end;
function NormalizeVertex2D(const Vector1: TzePoint2d): TzePoint2d;
var len:Double;
begin
  len:=oneVertexlength2D(Vector1);
  if abs(len)>eps then
                 begin
                     with TzePoint2d((@Result)^) do
                     begin
                          X := Vector1.x / len;
                          Y := Vector1.y / len;
                     end;
                 end
             else
                 begin
                 zDebugLn('{EH}'+rsDivByZero);
                 len:=len+2;
                 end;
end;
function VertexMulOnSc(const Vector1:TzePoint3d;sc:Double): TzePoint3d;
begin
  with TzePoint3d((@Result)^) do
  begin
    X := Vector1.x*sc;
    Y := Vector1.y*sc;
    Z := Vector1.z*sc;
  end;
end;
function Vertex2DMulOnSc(const Vector1:TzePoint2d;sc:Double): TzePoint2d;
begin
  with TzePoint2d((@Result)^) do
  begin
    X := Vector1.x*sc;
    Y := Vector1.y*sc;
  end;
end;
function VertexAdd(const Vector1, Vector2: TzePoint3d): TzePoint3d;
begin
  with TzePoint3d((@Result)^) do
  begin
    X := Vector1.x + Vector2.x;
    Y := Vector1.y + Vector2.y;
    Z := Vector1.z + Vector2.z;
  end;
end;
function VertexAdd(const Vector1, Vector2: TzePoint3s): TzePoint3s;
begin
  with TzePoint3s((@Result)^) do
  begin
    X := Vector1.x + Vector2.x;
    Y := Vector1.y + Vector2.y;
    Z := Vector1.z + Vector2.z;
  end;
end;
function VertexAdd(const Vector1, Vector2: TzePoint2d): TzePoint2d;
begin
  with TzePoint2d((@Result)^) do
  begin
    X := Vector1.x + Vector2.x;
    Y := Vector1.y + Vector2.y;
  end;
end;

{function MinusVertex(const Vector1: TzePoint3d): TzePoint3d;
begin
  Result.X := -Vector1.x;
  Result.Y := -Vector1.y;
  Result.Z := -Vector1.z;
end;}

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
function intercept2dmy(const l1begin,l1end,l2begin,l2end:TzePoint2d):intercept2dprop;
var
  {z,} {t,} _t1, _t2, d: Double;
begin
  //t := 0;
  //t1 := 0;
  //t2 := 0;
  result.isintercept := false;
  D := (l1end.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l1end.x - l1begin.x);
  if (D <> 0) then
  begin
    _t1 := ((l1end.y - l1begin.y) * (l2begin.x - l1begin.x) - (l2begin.y - l1begin.y) * (l1end.x - l1begin.x)) / D;
    _t2 := ((l2begin.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l2begin.x - l1begin.x)) / D;
    //if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      with TzePoint2d((@l1begin)^) do
      begin
        result.interceptcoord.x := x + (l1end.x - x) * _t2;
        result.interceptcoord.y := y + (l1end.y - y) * _t2;
      end;
      //if abs(result.interceptcoord.z-z)<eps then
      begin
        with intercept2dprop((@result)^) do
        begin
           t1:=_t2;
           t2:=_t1;
           isintercept:=true;
        end;
      end;
    end;
  end;
end;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  z, {t,} _t1, _t2, d: Double;
begin
  //t := 0;
  //t1 := 0;
  //t2 := 0;
  result.isintercept := false;
  D := (l1end.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l1end.x - l1begin.x);
  if (D <> 0) then
  begin
    _t1 := ((l1end.y - l1begin.y) * (l2begin.x - l1begin.x) - (l2begin.y - l1begin.y) * (l1end.x - l1begin.x)) / D;
    _t2 := ((l2begin.y - l1begin.y) * (l2begin.x - l2end.x) - (l2begin.y - l2end.y) * (l2begin.x - l1begin.x)) / D;
    if ((_t1 <= 1) and (_t1 >= 0) and (_t2 >= 0) and (_t2 <= 1)) then
    begin
      with TzePoint3d((@l1begin)^) do
      begin
        result.interceptcoord.x := x + (l1end.x - x) * _t2;
        result.interceptcoord.y := y + (l1end.y - y) * _t2;
        result.interceptcoord.z := z + (l1end.z - z) * _t2;
      end;
      z:=l2begin.z + (l2end.z - l2begin.z) * _t1;
      if abs(result.interceptcoord.z-z)<eps then
      begin
        with intercept3dprop((@result)^) do
        begin
           t1:=_t2;
           t2:=_t1;
           isintercept:=true;
        end;
      end;
    end;
  end;
end;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  {z, t, }t1{, t2, d, d1, d2}: Double;
  p13,p43,p21{,pp}:TzePoint3d;
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

function intercept2d2(const x11, y11, x12, y12, x21, y21, x22, y22: Single): Boolean;
var
  t1,t2,d,d1,d2:Double;
begin
  result := false;
  D := (y12 - y11) * (x21 - x22) - (y21 - y22) * (x12 - x11);
  D1 := (y12 - y11) * (x21 - x11) - (y21 - y11) * (x12 - x11);
  D2 := (y21 - y11) * (x21 - x22) - (y21 - y22) * (x21 - x11);
  if (D <> 0) then begin
    t1 := D1 / D;
    t2 := D2 / D;
    if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then begin
      result := true;
      //x := x11 + (x12 - x11) * t2;
      //y := y11 + (y12 - y11) * t2;
    end;
  end;
end;
function VectorDot(const v1,v2:TzePoint3d):TzePoint3d;
begin
  with TzePoint3d((@v1)^) do begin
     result.x:=y * v2.z - z * v2.y;
     result.y:=z * v2.x - x * v2.z;
     result.z:=x * v2.y - y * v2.x;
  end;
end;

function scalardot(const v1,v2:TzePoint3d):Double;
begin
  with TzePoint3d((@v1)^) do result:=x * v2.x + y * v2.y +z*v2.z;
end;
function CreateVertex(const _x,_y,_z:Double):TzePoint3d;
begin
  with TzePoint3d((@result)^) do begin
     x:=_x;
     y:=_y;
     z:=_z;
  end;
end;

function CreateStringFromArray(var counter:integer;const args:array of const):String;
begin
  case args[counter].VType of
    vtString:result:=args[counter].VString^;
    vtAnsiString:result:=ansistring(args[counter].VAnsiString);
  else
    zDebugLn('{E}CreateStringFromArray: not String');
  end;{case}
  inc(counter);
end;

function CreateVertex2D(const _x,_y:Double):TzePoint2d;
begin
  with TzePoint2d((@result)^) do begin
     x:=_x;
     y:=_y;
  end;
end;

procedure concatBBandPoint(var fistbb:TBoundingBox;const point:TzePoint3d);
begin
  with TzePoint3d((@fistbb.LBN)^) do begin
    if x>point.x then x:=point.x;
    if y>point.y then y:=point.y;
    if z>point.z then z:=point.z;
  end;

  with TzePoint3d((@fistbb.RTF)^) do begin
    if x<point.x then x:=point.x;
    if y<point.y then y:=point.y;
    if z<point.z then z:=point.z;
  end;
end;
function CreateBBFrom2Point(const p1,p2:TzePoint3d):TBoundingBox;
begin
  if p1.x<p2.x then begin
    result.LBN.x:=p1.x;
    result.RTF.x:=p2.x;
  end else begin
    result.LBN.x:=p2.x;
    result.RTF.x:=p1.x;
  end;
  if p1.y<p2.y then begin
    result.LBN.y:=p1.y;
    result.RTF.y:=p2.y;
  end else begin
    result.LBN.y:=p2.y;
    result.RTF.y:=p1.y;
  end;
  if p1.z<p2.z then begin
    result.LBN.z:=p1.z;
    result.RTF.z:=p2.z;
  end else begin
    result.LBN.z:=p2.z;
    result.RTF.z:=p1.z;
  end;
  //result.LBN:=CreateVertex(l,B,n);
  //result.RTF:=CreateVertex(r,T,f);
end;
function CreateBBFromPoint(const p:TzePoint3d):TBoundingBox;
begin
  result.LBN:=p;
  result.RTF:=p;
end;

function GDBvertexEqual(const v1, v2: TzePoint3d): Boolean; inline;
begin
  result:=(v1.x=v2.x) and (v1.y=v2.y) and (v1.z=v2.z);
end;
function IsBBZero(const bb: TBoundingBox): Boolean; inline;
begin
  with TBoundingBox((@bb)^) do
    result:=GDBvertexEqual(RTF, LBN);
end;
procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox);
begin
  if IsBBZero(fistbb) then begin
    fistbb:=secbb;
  end else
    if not IsBBZero(secbb) then begin
      concatBBandPoint(fistbb,secbb.LBN);
      concatBBandPoint(fistbb,secbb.RTF);
      {concatBBandPoint(secbb,fistbb.LBN);
      concatBBandPoint(secbb,fistbb.RTF);}
    end;
end;

function IsBBNul(const v1, v2: TzePoint3d): Boolean;
begin
  result:=(abs(v1.x-v2.x)<eps) and (abs(v1.y-v2.y)<eps) and (abs(v1.z-v2.z)<eps);
end;
function IsBBNul(const bb:TBoundingBox):boolean;
begin
  with TBoundingBox((@bb)^) do
    result:=IsBBNul(LBN, RTF);
end;
function IsPointInBB(const point, LBN, RTF:TzePoint3d):Boolean;
begin
  with TzePoint3d((@point)^) do
    result:=(LBN.x<=x+eps)and(RTF.x>=x-eps) and
            (LBN.y<=y+eps)and(RTF.y>=y-eps) and
            (LBN.z<=z+eps)and(RTF.z>=z-eps);
end;

function IsPointInBB(const point:TzePoint3d; const fistbb:TBoundingBox):Boolean;
begin
  with TBoundingBox((@fistbb)^) do result:=IsPointInBB(point,LBN,RTF);
end;

function ScaleBB(const bb:TBoundingBox;const k:Double):TBoundingBox;
var
  p,v:TzePoint3d;
begin
  p:=(bb.RTF+bb.LBN)/2;
  v:=(bb.RTF-p)*k;
  result.LBN:=p-v;
  result.RTF:=p+v;
end;

function boundingintersect(const bb1,bb2:TBoundingBox):Boolean;
var
  b1,b2,b1c,b2c,dist:TzePoint3d;
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
function CreateMatrixFromBasis(const ox,oy,oz:TzePoint3d):DMatrix4D;
begin
  Result.CreateRec(OneMtr,CMTRotate);
  //result:=onematrix;
  PzePoint3d(@result.mtr[0])^:=ox;
  PzePoint3d(@result.mtr[1])^:=oy;
  PzePoint3d(@result.mtr[2])^:=oz;
  //result.t:=CMTRotate;
end;
procedure CreateBasisFromMatrix(const m:DMatrix4D;out ox,oy,oz:TzePoint3d);
begin
  ox:=PzePoint3d(@m.mtr[0])^;
  oy:=PzePoint3d(@m.mtr[1])^;
  oz:=PzePoint3d(@m.mtr[2])^;
end;
function QuaternionMagnitude(const q : TzeQuaternion) : Double;
begin
  Result:=Sqrt(SqrOneVertexlength(q.ImagPart)+Sqr(q.RealPart));
end;
procedure NormalizeQuaternion(var q : TzeQuaternion);
var
   m,f:Double;
begin
  m:=QuaternionMagnitude(q);
  if m>EPSILON2 then begin
    f:=1/m;
    q.ImagPart:=VertexMulOnSc(q.ImagPart, f);
    q.RealPart:=q.RealPart*f;
  end else
    q:=IdentityQuaternion;
end;
function QuaternionFromMatrix(const mat : DMatrix4D) : TzeQuaternion;
// the matrix must be a rotation matrix!
var
   traceMat, s, invS : Double;
begin
  traceMat := 1 + mat.mtr[0].v[0] + mat.mtr[1].v[1] + mat.mtr[2].v[2];
  if traceMat>EPSILON2 then begin
    s:=Sqrt(traceMat)*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr[1].v[2]-mat.mtr[2].v[1])*invS;
    Result.ImagPart.y:=(mat.mtr[2].v[0]-mat.mtr[0].v[2])*invS;
    Result.ImagPart.z:=(mat.mtr[0].v[1]-mat.mtr[1].v[0])*invS;
    Result.RealPart  :=0.25*s;
  end else if (mat.mtr[0].v[0]>mat.mtr[1].v[1]) and (mat.mtr[0].v[0]>mat.mtr[2].v[2]) then begin  // Row 0:
    s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat.mtr[0].v[0]-mat.mtr[1].v[1]-mat.mtr[2].v[2]))*2;
    invS:=1/s;
    Result.ImagPart.x:=0.25*s;
    Result.ImagPart.y:=(mat.mtr[0].v[1]+mat.mtr[1].v[0])*invS;
    Result.ImagPart.z:=(mat.mtr[2].v[0]+mat.mtr[0].v[2])*invS;
    Result.RealPart  :=(mat.mtr[1].v[2]-mat.mtr[2].v[1])*invS;
  end else if (mat.mtr[1].v[1]>mat.mtr[2].v[2]) then begin  // Row 1:
    s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat.mtr[1].v[1]-mat.mtr[0].v[0]-mat.mtr[2].v[2]))*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr[0].v[1]+mat.mtr[1].v[0])*invS;
    Result.ImagPart.y:=0.25*s;
    Result.ImagPart.z:=(mat.mtr[1].v[2]+mat.mtr[2].v[1])*invS;
    Result.RealPart  :=(mat.mtr[2].v[0]-mat.mtr[0].v[2])*invS;
  end else begin  // Row 2:
    s:=Sqrt(Max{Float}(EPSILON2, {cOne}1+mat.mtr[2].v[2]-mat.mtr[0].v[0]-mat.mtr[1].v[1]))*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr[2].v[0]+mat.mtr[0].v[2])*invS;
    Result.ImagPart.y:=(mat.mtr[1].v[2]+mat.mtr[2].v[1])*invS;
    Result.ImagPart.z:=0.25*s;
    Result.RealPart  :=(mat.mtr[0].v[1]-mat.mtr[1].v[0])*invS;
  end;
  NormalizeQuaternion(Result);
end;
function QuaternionSlerp(const source, dest: TzeQuaternion; const t: Double): TzeQuaternion;
var
  to1:array[0..4]of Single;
  omega,cosom,sinom,scale0,scale1:Extended;
begin
  // calc cosine
  cosom:= source.ImagPart.x*dest.ImagPart.x
         +source.ImagPart.y*dest.ImagPart.y
         +source.ImagPart.z*dest.ImagPart.z
         +source.RealPart  *dest.RealPart;
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
function QuaternionToMatrix(quat : TzeQuaternion) :  DMatrix4D;
var
  w,x,y,z,xx,xy,xz,xw,yy,yz,yw,zz,zw:Double;
begin
  Result.CreateRec(OneMtr,CMTRotate);
  //result:=onematrix;
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
  Result.mtr[0].v[0] := 1 - 2 * ( yy + zz );
  Result.mtr[1].v[0] :=     2 * ( xy - zw );
  Result.mtr[2].v[0] :=     2 * ( xz + yw );
  Result.mtr[3].v[0] := 0;
  Result.mtr[0].v[1] :=     2 * ( xy + zw );
  Result.mtr[1].v[1] := 1 - 2 * ( xx + zz );
  Result.mtr[2].v[1] :=     2 * ( yz - xw );
  Result.mtr[3].v[1] := 0;
  Result.mtr[0].v[2] :=     2 * ( xz - yw );
  Result.mtr[1].v[2] :=     2 * ( yz + xw );
  Result.mtr[2].v[2] := 1 - 2 * ( xx + yy );
  Result.mtr[3].v[2] := 0;
  Result.mtr[0].v[3] := 0;
  Result.mtr[1].v[3] := 0;
  Result.mtr[2].v[3] := 0;
  Result.mtr[3].v[3] := 1;
  //Result.t:=CMTRotate;
end;
function GetArcParamFrom3Point2D(Const PointData:tarcrtmodify;out ad:TArcData):Boolean;
var
  a,b,c,d,e,f,g,rr:Double;
  tv:TzePoint2d;
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
    if ad.startangle>ad.endangle then begin
      rr:=ad.startangle;
      ad.startangle:=ad.endangle;
      ad.endangle:=rr
    end;
    rr:=vertexangle(tv,PointData.p2);
    if (rr>ad.startangle) and (rr<ad.endangle) then
      begin
      end
    else begin
      rr:=ad.startangle;
      ad.startangle:=ad.endangle;
      ad.endangle:=rr
    end;
  end else
    result:=false;
end;

function myPickMatrix(const x,y,deltax,deltay:Double;const vp:TzeVector4i): DMatrix4D;
var
  tm,sm: DMatrix4D;
begin
  tm:=CreateTranslationMatrix(createvertex((vp.v[2]-2*(x-vp.v[0]))/deltax,
                                           (vp.v[3]-2*(y-vp.v[1]))/deltay, 0));
  sm:=CreateScaleMatrix(createvertex(vp.v[2]/deltax,vp.v[3]/deltay, 1.0));
  result:=MatrixMultiply(sm,tm);
  result.t:=CMTTransform;
end;

function CalcDisplaySubFrustum(const x,y,w,h:Double;const mm,pm:DMatrix4D;const vp:TzeVector4i):ClipArray;
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

function IsPointEqual(const p1,p2:TzePoint3d;const _eps:Double):boolean;
begin
  if SqrVertexlength(p1,p2)>_eps then
    result:=false
  else
    result:=true;
end;
function IsPoint2DEqual(const p1,p2:TzePoint2d):boolean;
begin
  if SqrVertexlength(p1,p2)>sqreps then
    result:=false
  else
    result:=true;
end;
function IsVectorNul(const p2:TzePoint3d):boolean;
begin
  if SqrOneVertexlength(p2)>sqreps then
    result:=false
  else
    result:=true;
end;
function GetCSDirFrom0x0y2D(const ox,oy:TzePoint3d):TCSDir;
begin
  if vectordot(ox,oy).z>eps then
    result:=TCSDLeft
  else
    result:=TCSDRight;
end;
function CalcTrueInFrustum (const lbegin,lend:TzePoint3d; const frustum:ClipArray):TInBoundingVolume;
var
  i,j:Integer;
  d1,d2:Double;
  bytebegin,byteend,bit:integer;
  ca:TLineClipArray;
  cacount:integer;
  d,p:TzePoint3d;
begin
  fillchar((@ca)^,sizeof(ca),0);
  result:=IREmpty;
  bit:=1;
  bytebegin:=0;
  byteend:=0;
  cacount:=0;
  for i:=0 to 5 do begin
    with frustum[i] do
    begin
      d1:=v[0] * lbegin.x + v[1] * lbegin.y + v[2] * lbegin.z + v[3];
      d2:=v[0] * lend.x +   v[1] * lend.y +   v[2] * lend.z +   v[3];
    end;
    if d1<0 then
      bytebegin:=bytebegin or bit;
    if d2<0 then
      byteend:=byteend or bit;
    if ((bytebegin and bit)and(byteend and bit))>0 then begin
      result:=IREmpty;
      exit;
    end;
    if((bytebegin and bit)xor(byteend and bit))>0 then begin
      d1:=abs(d1);
      d2:=abs(d2);
      ca[cacount]:=d1/(d1+d2);
      inc(cacount);
    end;
    bit:=bit*2;
  end;
  if ((bytebegin)=0)and((byteend)=0) then begin
    result:=IRFully;
    exit;
  end;
  if  (bytebegin)=0 then begin
    result:=IRPartially;
    exit;
  end;
  if  (byteend)=0 then begin
    result:=IRPartially;
    exit;
  end;
  if cacount<2 then begin
    result:=IREmpty;
    exit;
  end;
  dec(cacount);
  d:=VertexSub(lend,lbegin);
  j:=0;
  d1:=GetMinAndSwap(j,cacount,ca);
  while j<=cacount do begin
       d2:=GetMinAndSwap(j,cacount,ca);
       d1:=(d1+d2)/2;
    bit:=0;
    p:=VertexDmorph(lbegin,d,d1);
    for i:=0 to 5 do begin
      with frustum[i] do
        if (v[0] * p.x + v[1] * p.y + v[2] * p.z + v[3])>=0 then
          inc(bit);
    end;
    if bit=6 then begin
      result:=IRPartially;
      exit;
    end;
    d1:=d2;
  end;
end;
function CalcTrueInFrustum (const lbegin,lend:TzePoint3s; const frustum:ClipArray):TInBoundingVolume;
var
  i,j:Integer;
  d1,d2:Double;
  bytebegin,byteend,bit:integer;
  ca:TLineClipArray;
  cacount:integer;
  d,p:TzePoint3s;
begin
  fillchar((@ca)^,sizeof(ca),0);
  result:=IREmpty;
  bit:=1;
  bytebegin:=0;
  byteend:=0;
  cacount:=0;
  for i:=0 to 5 do begin
    with frustum[i] do begin
      d1:=v[0] * lbegin.x + v[1] * lbegin.y + v[2] * lbegin.z + v[3];
      d2:=v[0] * lend.x +   v[1] * lend.y +   v[2] * lend.z +   v[3];
    end;
    if d1<0 then
      bytebegin:=bytebegin or bit;
    if d2<0 then
      byteend:=byteend or bit;
    if ((bytebegin and bit)and(byteend and bit))>0 then begin
      result:=IREmpty;
      exit;
    end;
    if((bytebegin and bit)xor(byteend and bit))>0then begin
      d1:=abs(d1);
      d2:=abs(d2);
      ca[cacount]:=d1/(d1+d2);
      inc(cacount);
    end;
    bit:=bit*2;
  end;
  if ((bytebegin)=0)and((byteend)=0) then begin
    result:=IRFully;
    exit;
  end;
  if  (bytebegin)=0 then begin
    result:=IRPartially;
    exit;
  end;
  if  (byteend)=0 then begin
    result:=IRPartially;
    exit;
  end;
  if cacount<2 then begin
    result:=IREmpty;
    exit;
  end;
  dec(cacount);
  d:=VertexSub(lend,lbegin);
  j:=0;
  d1:=GetMinAndSwap(j,cacount,ca);
  while j<=cacount do begin
    d2:=GetMinAndSwap(j,cacount,ca);
    d1:=(d1+d2)/2;
    bit:=0;
    p:=VertexDmorph(lbegin,d,d1);
    for i:=0 to 5 do begin
      with frustum[i] do
        if (v[0] * p.x + v[1] * p.y + v[2] * p.z + v[3])>=0
        then
          inc(bit);
    end;
    if bit=6 then begin
      result:=IRPartially;
      exit;
     end;
    d1:=d2;
  end;
end;

function CalcAABBInFrustum (const AABB:TBoundingBox;const frustum:ClipArray):TInBoundingVolume;
var
  i,Count:integer;
  p1,p2,p3,p4,p5,p6,p7,p8:TzePoint3d;
  d1,d2,d3,d4,d5,d6,d7,d8:double;
begin
  p1:=AABB.LBN;
  p2:=CreateVertex(AABB.RTF.x,AABB.LBN.y,AABB.LBN.Z);
  p3:=CreateVertex(AABB.RTF.x,AABB.RTF.y,AABB.LBN.Z);
  p4:=CreateVertex(AABB.LBN.x,AABB.RTF.y,AABB.LBN.Z);
  p5:=CreateVertex(AABB.LBN.x,AABB.LBN.y,AABB.RTF.Z);
  p6:=CreateVertex(AABB.RTF.x,AABB.LBN.y,AABB.RTF.Z);
  p7:=AABB.RTF;
  p8:=CreateVertex(AABB.LBN.x,AABB.RTF.y,AABB.RTF.Z);

  Count:=0;
  for i:=0 to 5 do begin
    with frustum[i] do begin
      d1:=v[0] * p1.x + v[1] * p1.y + v[2] * p1.z + v[3];
      d2:=v[0] * p2.x + v[1] * p2.y + v[2] * p2.z + v[3];
      d3:=v[0] * p3.x + v[1] * p3.y + v[2] * p3.z + v[3];
      d4:=v[0] * p4.x + v[1] * p4.y + v[2] * p4.z + v[3];
      d5:=v[0] * p5.x + v[1] * p5.y + v[2] * p5.z + v[3];
      d6:=v[0] * p6.x + v[1] * p6.y + v[2] * p6.z + v[3];
      d7:=v[0] * p7.x + v[1] * p7.y + v[2] * p7.z + v[3];
      d8:=v[0] * p8.x + v[1] * p8.y + v[2] * p8.z + v[3];
    end;

    if (d1<0)and(d2<0)and(d3<0)and(d4<0)and(d5<0)and(d6<0)and
      (d7<0)and(d8<0)  then begin
      Result:=IREmpty;
      system.exit;
    end;

    {if (d1<0)or(d2<0)or(d3<0)or(d4<0)or(d5<0)or(d6<0)or
      (d7<0)or(d8<0)  then begin
      Result:=IRPartially;
      system.exit;
    end;}

    if d1>=0 then Inc(Count);
    if d2>=0 then Inc(Count);
    if d3>=0 then Inc(Count);
    if d4>=0 then Inc(Count);
    if d5>=0 then Inc(Count);
    if d6>=0 then Inc(Count);
    if d7>=0 then Inc(Count);
    if d8>=0 then Inc(Count);
  end;
  //Result:=irfully;
  Result:=IRPartially;
  if Count=48 then begin
    Result:=irfully;
  end;
  //Result:=IRPartially;
end;
function PointOf3PlaneIntersect(const P1,P2,P3:TzeVector4d):TzePoint3d;
var
  N1,N2,N3,N12,N23,N31,a1,a2,a3:TzePoint3d;
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

function PointOfRayPlaneIntersect(const p1,d:TzePoint3d;const plane:TzeVector4d;out point :TzePoint3d):Boolean;
var
  td:Double;
begin
  with TzeVector4d((@plane)^) do
     td:=-v[0]*d.x-v[1]*d.y-v[2]*d.z;

  if abs(td)<eps then
    exit(false);

  with TzeVector4d((@plane)^) do
    td:=(v[0]*p1.x+v[1]*p1.y+v[2]*p1.z+v[3])/td;

  point:=VertexDmorph(p1,d,td);
  result:=true;
end;

function PointOfRayPlaneIntersect(const p1,d:TzePoint3d;const plane:TzeVector4d;out t :double):Boolean;
var
  td:Double;
begin
  with TzeVector4d((@plane)^) do
     td:=-v[0]*d.x-v[1]*d.y-v[2]*d.z;

  if abs(td)<eps then
    exit(false);

  with TzeVector4d((@plane)^) do
    t:=(v[0]*p1.x+v[1]*p1.y+v[2]*p1.z+v[3])/td;
  if (t>=0)and(t<=1)then
    result:=true
  else
    result:=false;
end;

function ortho;
var
  xmaxminusxmin,ymaxminusymin,zmaxminuszmin,
  xmaxplusxmin,ymaxplusymin,zmaxpluszmin:Double;
  m:DMatrix4D;
begin
  xmaxminusxmin:=xmax-xmin;
  ymaxminusymin:=ymax-ymin;
  zmaxminuszmin:=-(zmax-zmin);
  xmaxplusxmin:=xmax+xmin;
  ymaxplusymin:=ymax+ymin;
  zmaxpluszmin:=zmax+zmin;
  if (abs(xmaxminusxmin)<eps) or
     (abs(ymaxminusymin)<eps) or
     (abs(zmaxminuszmin)<eps) then
    exit(matrix^);

  m.CreateRec(OneMtr,CMTTransform);
  {Все коэффициенты домножены на xmaxminusxmin, воччтановить оригинал - соответственно всё разделить}
  m.mtr[0].v[0]:=2{/xmaxminusxmin};
  m.mtr[1].v[1]:=(2/ymaxminusymin)*xmaxminusxmin;
  m.mtr[2].v[2]:=(2/zmaxminuszmin)*xmaxminusxmin;
  m.mtr[3].v[0]:=(-xmaxplusxmin/xmaxminusxmin)*xmaxminusxmin;
  m.mtr[3].v[1]:=(-ymaxplusymin/ymaxminusymin)*xmaxminusxmin;
  m.mtr[3].v[2]:=(zmaxpluszmin/zmaxminuszmin)*xmaxminusxmin;
  m.mtr[3].v[3]:=xmaxminusxmin;

  result:=MatrixMultiply(m,matrix^);
  //glMultMatrixd(@m);
end;

function Perspective;
var
  sine,cosine,cotangent,deltaZ,radians:Double;
  m:DMatrix4D;
begin
  radians:= fovy/2*Pi/180;
  deltaZ:=zmax - zmin;
  SinCos(radians, sine, cosine);
  cotangent:= cosine / sine;
  m.CreateRec(OneMtr,CMTTransform);
  m.mtr[0].v[0] := cotangent / w_h;
  m.mtr[1].v[1] := cotangent;
  m.mtr[2].v[2] := -(zmax + zmin) / deltaZ;
  m.mtr[2].v[3] := -1;
  m.mtr[3].v[2] := -2 * zmin * zmax / deltaZ;
  m.mtr[3].v[3] := 0;
  result:=MatrixMultiply(m,matrix^);
end;

function lookat;
var
  m:DMatrix4D;
  m2:DMatrix4D;
begin
  m:=CreateMatrixFromBasis(-ex,ey,-ez);
  MatrixTranspose(m);
  m2:=CreateTranslationMatrix(point);
  m:=MatrixMultiply(m2,m);
  result:=MatrixMultiply(m,matrix^);
end;

procedure _myGluUnProject(const winx,winy,winz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i;out objx,objy,objz:Double);
var
  _in,_out:TzeVector4d;
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

  objx:=_out.x/_out.w;
  objy:=_out.y/_out.w;
  objz:=_out.z/_out.w;
end;

procedure _myGluProject(const objx,objy,objz:Double;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i; out winx,winy,winz:Double);
var
  _in:TzeVector4d;
begin
  _in.x:=objx;
  _in.y:=objy;
  _in.z:=objz;
  _in.w:=1.0;
  _in:=VectorTransform(VectorTransform(_in,modelMatrix^), projMatrix^);

  _in.x:=_in.x/_in.w;
  _in.y:=_in.y/_in.w;
  _in.z:=_in.z/_in.w;

  //* Map x, y and z to range 0-1 */
  _in.x:=_in.x * 0.5 + 0.5;
  _in.y:=_in.y * 0.5 + 0.5;
  _in.z:=_in.z * 0.5 + 0.5;

  //* Map x,y to viewport */
  winx:=_in.x * viewport.v[2] + viewport.v[0];
  winy:=_in.y * viewport.v[3] + viewport.v[1];
  winz:=_in.z;
  //return(GL_TRUE);
end;

procedure _myGluProject2(const objcoord:TzePoint3d;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PzeVector4i; out wincoord:TzePoint3d);
begin
  _myGluProject(objcoord.x,objcoord.y,objcoord.z,modelMatrix,projMatrix,viewport,wincoord.x,wincoord.y,wincoord.z);
end;

function SQRdist_Point_to_Segment(const p,s0,s1:TzePoint3d):Double;
var
  v,w,pb:TzePoint3d;
  c1,c2,b:Double;
begin
  v:=vertexsub(s1,s0);
  w:=vertexsub(p,s0);

  c1 := scalardot(w,v);
  if c1 <= 0 then begin
    result:=SqrVertexlength(p,s0);
    exit;
  end;

  c2:=scalardot(v,v);
  if c2 <= c1 then begin
    result:=SqrVertexlength(p,s1);
    exit;
  end;

  b:=c1/c2;
  Pb:=vertexadd(s0,VertexMulOnSc(v,b));
  result:=SqrVertexlength(p,pb);
end;
function NearestPointOnSegment(const p,s0,s1:TzePoint3d):TzePoint3d;
var
  v,w:TzePoint3d;
  c1,c2:Double;
begin
  v:=vertexsub(s1,s0);
  w:=vertexsub(p,s0);

  c1 := scalardot(w,v);
  if c1 <= 0 then
    exit(s0);

  c2:=scalardot(v,v);
  if c2 <= c1 then
    exit(s1);

  result:=vertexadd(s0,VertexMulOnSc(v, (c1/c2)));
end;

function distance2ray(const q,p1,p2:TzePoint3d):DistAndt;
var
  w,v:TzePoint3d;
  c1,c2:double;
begin
  v:=VertexSub(p2,p1);
  w:=VertexSub(q,p1);
  c1:=scalardot(w,v);
  c2:=scalardot(v,v);
  if abs(c2)>eps then begin
    result.t:=c1/c2;
    result.d:=Vertexlength(q,VertexDmorph(p1,v,result.t));
  end else begin
    result.t:=0;
    result.d:=Vertexlength(q,p1);
  end;
end;

function CreateAffineRotationMatrix(const anAxis: TzePoint3d; angle: double):DMatrix4D;
var
  axis : TzePoint3d;
  cosine, sine, one_minus_cosine :double;
begin
  SinCos(angle, SINE, cosine);
  one_minus_cosine:=1 - cosine;
  axis:=NormalizeVertex(anAxis);

  Result.CreateRec(OneMtr,CMTRotate);
  //result:=onematrix;
  Result.mtr[XAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Sqr(Axis.x)) + Cosine;
  Result.mtr[XAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Axis.x * Axis.y) - (Axis.z * Sine);
  Result.mtr[XAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Axis.z * Axis.x) + (Axis.y * Sine);

  Result.mtr[YAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Axis.x * Axis.y) + (Axis.z * Sine);
  Result.mtr[YAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Sqr(Axis.y)) + Cosine;
  Result.mtr[YAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Axis.y * Axis.z) - (Axis.x * Sine);

  Result.mtr[ZAxisIndex].v[XAxisIndex]:=(one_minus_cosine * Axis.z * Axis.x) - (Axis.y * Sine);
  Result.mtr[ZAxisIndex].v[YAxisIndex]:=(one_minus_cosine * Axis.y * Axis.z) + (Axis.x * Sine);
  Result.mtr[ZAxisIndex].v[ZAxisIndex]:=(one_minus_cosine * Sqr(Axis.z)) + Cosine;
  //Result.t:=CMTRotate;
end;

function TwoVectorAngle(const Vector1, Vector2: TzePoint3d): Double;inline;
begin
  Result:=ArcCos(scalardot(Vector1, Vector2));
end;

function intercept3d(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  {z, t, }t1, t2{, d, d1, d2}: Double;
  p13,p43,p21,pp:TzePoint3d;
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
  if ((result.t1 <= 1) and (result.t1 >= 0) and (result.t2 >= 0) and (result.t2 <= 1)) then begin
    result.interceptcoord.x:= l1begin.x + t1 * p21.x;
    result.interceptcoord.y:= l1begin.y + t1 * p21.y;
    result.interceptcoord.z:= l1begin.z + t1 * p21.z;
    pp.x:= l2begin.x + t2 * p43.x;
    pp.y:= l2begin.y + t2 * p43.y;
    pp.z:= l2begin.z + t2 * p43.z;

    //todo: непомню зачем добавил эту проверку, по сути она не нужна - пересечение
    //всеравно "насчитали". Координаты на линиях могут не совпасть изза
    //погрешности, что собсвенно происходит при пересечении вот этих линий
    //(5865965.88288733,-2925099.80152868)-(5865959.78288733,-2925099.80152868)
    //(5865964.13288733,-2925101.55152868)-(5865964.13288733,-2925098.05152868)
    //пока отодвинуд точность с bigEPS на floateps, но по идее надо убрать
    //если не вспомню зачем добавлял

    if (ABS(pp.x-result.interceptcoord.x)>floateps) or
       (ABS(pp.y-result.interceptcoord.y)>floateps) or
       (ABS(pp.z-result.interceptcoord.z)>floateps)
    then
      exit;
    result.isintercept:=true;
  end;
end;

function CreateDoubleFromArray(var counter:integer;const args:array of const):Double;
begin
  case args[counter].VType of
    vtInteger:result:=args[counter].VInteger;
    vtExtended:result:=args[counter].VExtended^;
    else
      zDebugLn('{E}CreateDoubleFromArray: not Integer, not Extended');
  end;{case}
  inc(counter);
end;
function CreateBooleanFromArray(var counter:integer;const args:array of const):Boolean;
begin
  case args[counter].VType of
    vtBoolean:result:=args[counter].VBoolean;
    else
      zDebugLn('{E}CreateStrinBooleanFromArray: not boolean');
  end;{case}
  inc(counter);
end;

function CreateVertex2DFromArray(var counter:integer;const args:array of const):TzePoint2d;
begin
  if (counter+1)<=(high(args)) then begin
    with TzePoint2d((@result)^) do begin
      x:=CreateDoubleFromArray(counter,args);
      y:=CreateDoubleFromArray(counter,args);
    end;
  end else begin
    zDebugLn('{E}CreateVertex2DFromArray: no enough params in args');
  end;
end;

function CreateVertexFromArray(var counter:integer;const args:array of const):TzePoint3d;
begin
  if (counter+2)<=(high(args)) then begin
    with TzePoint3d((@result)^) do begin
      x:=CreateDoubleFromArray(counter,args);
      y:=CreateDoubleFromArray(counter,args);
      z:=CreateDoubleFromArray(counter,args);
    end;
  end else begin
    zDebugLn('{E}CreateVertexFromArray: no enough params in args');
  end;
end;

begin
  WorldMatrix.CreateRec(OneMtr,CMTIdentity);
end.
