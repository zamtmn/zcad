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

unit uzeBoundaryPath;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}

interface

uses
  Math,
  uzegeometrytypes,UGDBPolyline2DArray,gzctnrVector,
  uzctnrVectorBytes,gzctnrVectorTypes,uzegeometry,uzeffdxfsupport,uzMVReader,
  uzeSplineUtils,uzegluinterface,LazLoggerBase;
type
PBoundaryPath=^TBoundaryPath;
TBoundaryPath=object
  paths:GZVector<GDBPolyline2DArray>;
  constructor init(m:TArrayIndex);
  destructor done;virtual;
  function LoadFromDXF(var f:TZMemReader;DXFCode:Integer):Boolean; {todo: вынести это нафиг из простых типов}
  procedure SaveToDXF(var outhandle:TZctnrVectorBytes);
  procedure CloneTo(var Dest:TBoundaryPath);
  procedure Clear;virtual;

  procedure transform(const t_matrix:DMatrix4D);virtual;
  function getDataMutableByPlainIndex(index:TArrayIndex):PGDBVertex2D;

  function DummyCalcTrueInFrustum(pv1:pgdbvertex;const frustum:ClipArray):TInBoundingVolume;virtual;
end;

implementation

function TBoundaryPath.DummyCalcTrueInFrustum(pv1:pgdbvertex;const frustum:ClipArray):TInBoundingVolume;
var i,j:integer;
   ppla:PGDBPolyline2DArray;
   firstp,pv2:pgdbvertex;
   isAllFull,isAllEmpty:boolean;
begin
  pv2:=pv1;
  inc(pv2);
  isAllFull:=true;
  isAllEmpty:=true;
  for i:=0 to paths.count-1 do begin
    firstp:=pv1;
    ppla:=paths.getDataMutable(i);
    for j:=0 to ppla^.count-2 do begin
      result:=uzegeometry.CalcTrueInFrustum(pv1^,pv2^,frustum);
      isAllFull:=isAllFull and (result=IRFully);
      isAllEmpty:=isAllEmpty and (result=IREmpty);
      if (not isAllFull)and(not isAllEmpty) then
        exit(IRPartially);
      inc(pv1);
      inc(pv2);
    end;
    result:=uzegeometry.CalcTrueInFrustum(pv1^,firstp^,frustum);
    isAllFull:=isAllFull and (result=IRFully);
    isAllEmpty:=isAllEmpty and (result=IREmpty);
    if (not isAllFull)and(not isAllEmpty) then
      exit(IRPartially);
    inc(pv1);
    inc(pv2);
  end;
end;

procedure TBoundaryPath.transform(const t_matrix:DMatrix4D);
var i,j:integer;
   ppla:PGDBPolyline2DArray;
   pv:PGDBVertex2D;
   tv:GDBvertex;
begin
  for i:=0 to paths.count-1 do begin
    ppla:=paths.getDataMutable(i);
    for j:=0 to ppla^.count-1 do begin
      pv:=ppla^.getDataMutable(j);
      tv.x:=pv^.x;
      tv.y:=pv^.y;
      tv.z:=0;
      tv:=VectorTransform3D(tv,t_matrix);
      pv^.x:=tv.x;
      pv^.y:=tv.y;
    end;
  end;
end;
function TBoundaryPath.getDataMutableByPlainIndex(index:TArrayIndex):PGDBVertex2D;
var
   i,pln:integer;
   ppla:PGDBPolyline2DArray;
begin
  pln:=0;
  for i:=0 to paths.count-1 do begin
    ppla:=paths.getDataMutable(i);
    pln:=pln+ppla^.count;
    if pln>index then
      exit(ppla^.getDataMutable(index-pln+ppla^.count));
  end;
  result:=nil;
end;
constructor TBoundaryPath.init(m:TArrayIndex);
begin
  paths.init(m);
end;
destructor TBoundaryPath.done;
var
  i:integer;
  ppla:PGDBPolyline2DArray;
begin
  for i:=0 to paths.count-1 do begin
    ppla:=paths.getDataMutable(i);
    //ppla^.free;
    ppla^.done;
  end;
  paths.done;
end;
procedure TBoundaryPath.Clear;
var i:integer;
begin
  for i:=0 to paths.count-1 do
    paths.getData(i).free;
  paths.Clear;
end;


procedure NurbsVertexCallBack(const v: PGDBvertex3S;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
  tv:GDBVertex2D;
begin
  tv.x:=v^.x;
  tv.y:=v^.y;
  PGDBPolyline2DArray(data)^.PushBackData(tv);
end;

procedure NurbsErrorCallBack(const v: TGLUIntf_GLenum);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  debugln('{E}'+GLUIntrf.ErrorString(v));
end;

(*procedure NurbsBeginCallBack(const v: TGLUIntf_GLenum;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
end;

procedure NurbsEndCallBack(const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
end;*)


function TBoundaryPath.LoadFromDXF(var f:TZMemReader;DXFCode:Integer):Boolean;
//type
//  TNotPolyLine=(NPL_Line,NPL_CircularArc,NPL_EllipticArc,NPL_Spline);

  procedure DrawArc(constref p1,p2:GDBVertex2D;const bulge:double;var currpath:GDBPolyline2DArray;divcount:integer);//inline;
  var
    d,pc,pac,n:GDBVertex2D;
    l,h,nextbulge:double;
  begin
    d:=p2-p1;
    l:=d.Length;
    h:=l*bulge/2;
    pc:=(p1+p2)/2;
    n.x:=-d.y;
    n.y:=d.x;
    n:=n.NormalizeVertex;
    pac:=pc-n*h;
    if divcount=-1 then begin
      //пытаемся сделать лод. вариантов не много
      divcount:=min(max(2,abs(round(bulge*2))),5);
      {if abs(h)*2>l then
        divcount:=3
      else
        divcount:=2}
    end;
    if divcount=0 then begin
    currpath.PushBackData(p1);
    currpath.PushBackData(pac);
    end else begin
      dec(divcount);
      nextbulge:=bulge/(1+sqrt(1+bulge*bulge));
      DrawArc(p1,pac,nextbulge,currpath,divcount);
      DrawArc(pac,p2,nextbulge,currpath,divcount);
    end;
  end;

  procedure DrawFullArc(constref p1,p2:GDBVertex2D;const bulge:double;var currpath:GDBPolyline2DArray);//inline;
  begin
    DrawArc(p1,p2,bulge,currpath,-1);
    currpath.PushBackData(p2);
  end;

  procedure loadPolyWithBulges(var byt:integer;var currpath:GDBPolyline2DArray;const VertexCount:integer;const Closed:Boolean);//inline;
  var
    p1,pcurr,pnext:GDBVertex2D;
    j:Integer;
    bulge,nextbulge:double;
  begin
    currpath.init(vertexcount*10,true);
    bulge:=0;
    if dxfdoubleload(f,10,byt,pcurr.x) then byt:=f.ParseInteger;
    if dxfdoubleload(f,20,byt,pcurr.y) then byt:=f.ParseInteger;
    if dxfdoubleload(f,42,byt,bulge) then byt:=f.ParseInteger;
    p1:=pcurr;
    for j:=2 to VertexCount do begin
      nextbulge:=0;
      if dxfdoubleload(f,10,byt,pnext.x) then byt:=f.ParseInteger;
      if dxfdoubleload(f,20,byt,pnext.y) then byt:=f.ParseInteger;
      if dxfdoubleload(f,42,byt,nextbulge) then byt:=f.ParseInteger;

      if IsZero(bulge) then begin
        currpath.PushBackData(pcurr);
        currpath.PushBackData(pnext);
      end else
        DrawFullArc(pcurr,pnext,bulge,currpath);
      pcurr:=pnext;
      bulge:=nextbulge;
    end;
    if closed then
      if IsZero(bulge) then begin
        currpath.PushBackData(pcurr);
        currpath.PushBackData(p1);
      end else
        DrawFullArc(pcurr,p1,bulge,currpath);
  end;

  procedure loadPoly(var byt:integer;var currpath:GDBPolyline2DArray;const VertexCount:integer;const Closed:Boolean);//inline;
  var
    p:GDBVertex2D;
    j:Integer;
  begin
    currpath.init(vertexcount,true);
    for j:=1 to VertexCount do begin
      if dxfdoubleload(f,10,byt,p.x) then byt:=f.ParseInteger;
      if dxfdoubleload(f,20,byt,p.y) then byt:=f.ParseInteger;
      currpath.PushBackData(p);
    end;
  end;

  procedure loadPolyBoundary(var byt:integer;var currpath:GDBPolyline2DArray);//inline;
  var
    hasBulge:integer=0;
    isClosed:integer=0;
    vertexcount:integer=0;
  begin
    if dxfintegerload(f,72,byt,hasBulge) then byt:=f.ParseInteger;
    if dxfintegerload(f,73,byt,isClosed) then byt:=f.ParseInteger;
    if dxfintegerload(f,93,byt,vertexcount) then byt:=f.ParseInteger;
    if hasBulge=0 then
      loadPoly(byt,currpath,VertexCount,isClosed<>0)
    else
      loadPolyWithBulges(byt,currpath,VertexCount,isClosed<>0);
  end;

  procedure loadSplineBoundary(var byt:integer;var currpath:GDBPolyline2DArray);//inline;
  var
    vertexcount,bt,k:integer;
    knotcount:integer=0;
    p:GDBVertex2D;
    Knots:TKnotsVector;
    PCurrKnot:TKnotsVector.PT;
    CP:TCPVector;
    PPrevCP,PCurrCP:TCPVector.PT;
    nurbsobj:GLUnurbsObj;
    currL,L:float;
  begin
    if dxfIntegerload(f,94,byt,bt) then byt:=f.ParseInteger;
    if dxfIntegerload(f,73,byt,bt) then byt:=f.ParseInteger;
    if dxfIntegerload(f,74,byt,bt) then byt:=f.ParseInteger;
    if dxfIntegerload(f,95,byt,knotcount) then byt:=f.ParseInteger;
    if dxfIntegerload(f,96,byt,vertexcount) then byt:=f.ParseInteger;
    if knotcount>0 then begin
      Knots.init(knotcount);
      Knots.AllocData(knotcount);
      PCurrKnot:=Knots.GetParray;
      for k:=0 to knotcount-1 do begin
        if dxfFloatload(f,40,byt,PCurrKnot^) then byt:=f.ParseInteger;
        inc(PCurrKnot);
      end;
    end;
    if vertexcount>0 then begin
      CP.init(vertexcount);
      CP.AllocData(vertexcount);
      PCurrCP:=CP.GetParray;
      PPrevCP:=nil;
      currL:=10;
      for k:=0 to vertexcount-1 do begin
        if dxfFloatLoad(f,10,byt,PCurrCP^.x) then byt:=f.ParseInteger;
        if dxfFloatLoad(f,20,byt,PCurrCP^.y) then byt:=f.ParseInteger;
        PCurrCP^.z:=0;
        PCurrCP^.w:=1;
        if dxfFloatLoad(f,42,byt,PCurrCP^.w) then byt:=f.ParseInteger;
        if PPrevCP<>nil then begin
          L:=vertexlen2df(PPrevCP^.x,PPrevCP^.y,PCurrCP^.x,PCurrCP^.y);
          if L>currL then
            currL:=L;
        end;
        PPrevCP:=PCurrCP;
        inc(PCurrCP);
      end;
    end;
    //if dxfdoubleload(f,42,byt,p.y) then byt:=f.ParseInteger;
    if dxfdoubleload(f,12,byt,p.x) then byt:=f.ParseInteger;
    if dxfdoubleload(f,22,byt,p.y) then byt:=f.ParseInteger;
    if dxfdoubleload(f,13,byt,p.x) then byt:=f.ParseInteger;
    if dxfdoubleload(f,23,byt,p.y) then byt:=f.ParseInteger;


    nurbsobj:=GLUIntrf.NewNurbsRenderer;

    GLUIntrf.NurbsProperty(nurbsobj,GLU_NURBS_MODE_EXT,GLU_NURBS_TESSELLATOR_EXT);
    GLUIntrf.NurbsProperty(nurbsobj,GLU_SAMPLING_TOLERANCE,currL/15);
    GLUIntrf.NurbsProperty(nurbsobj,GLU_DISPLAY_MODE,GLU_POINT);
    GLUIntrf.NurbsProperty(nurbsobj,GLU_AUTO_LOAD_MATRIX,GLUIntf_GL_FALSE{GL_TRUE});

    GLUIntrf.NurbsCallbackData(nurbsobj,@currpath);

    GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_BEGIN_DATA_EXT,nil{@NurbsBeginCallBack});
    GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_END_DATA_EXT,nil{@NurbsEndCallBack});
    GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_VERTEX_DATA_EXT,@NurbsVertexCallBack);
    GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_ERROR,@NurbsErrorCallBack);

    GLUIntrf.BeginCurve(nurbsobj);
    GLUIntrf.NurbsCurve (nurbsobj,Knots.Count,Knots.GetParrayAsPointer,{CP.Count}4,CP.GetParrayAsPointer,4,GLUIntf_GL_MAP1_VERTEX_4);
    GLUIntrf.EndCurve(nurbsobj);


    GLUIntrf.DeleteNurbsRenderer(nurbsobj);



    if knotcount>0 then
      Knots.done;
    if vertexcount>0 then
      CP.done;
  end;

var
  currpath:GDBPolyline2DArray;
  i,j,k,pathscount,vertexcount,byt,bt:integer;
  firstp,{prevp,}p,cp:GDBVertex2D;
  r,sa,ea,a:double;
  s:string;
  isPolyLine:boolean;
  isNegative:integer;
  //NotPolyLine:TNotPolyLine;
  isFirst:boolean;
begin
     result:=dxfIntegerload(f,91,DXFCode,pathscount);
     if result then begin
       isPolyLine:=false;
       byt:=f.ParseInteger;
       Clear;
       for i:=1 to pathscount do begin
         while not dxfintegerload(f,92,byt,bt) do
           byt:=f.ParseInteger;
         isPolyLine:=(bt and 2)<>0;
         byt:=f.ParseInteger;
         if isPolyLine then
           loadPolyBoundary(byt,currpath)
         else begin
           if dxfintegerload(f,93,byt,vertexcount) then byt:=f.ParseInteger;
           currpath.init(vertexcount,true);
           isFirst:=true;
           for j:=1 to vertexcount do begin
             if dxfintegerload(f,72,byt,bt) then begin
               byt:=f.ParseInteger;
               case bt of
                 1:begin
                     if dxfdoubleload(f,10,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,20,byt,p.y) then byt:=f.ParseInteger;
                     if not isFirst then begin
                       if not(IsPoint2DEqual(p,{prevp}currpath.getPLast^)) then
                         currpath.PushBackData(p);
                     end else begin
                       currpath.PushBackData(p);
                       firstp:=p;
                     end;
                     isFirst:=false;
                     if dxfdoubleload(f,11,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,21,byt,p.y) then byt:=f.ParseInteger;
                     if j<>vertexcount then
                       currpath.PushBackData(p)
                     else
                       if not(IsPoint2DEqual(p,firstp)) then
                         currpath.PushBackData(p);
                     //prevp:=p;
                   end;
                 2:begin
                     //NotPolyLine:=NPL_CircularArc;
                     cp:=dxfRequiredVertex2D(f,10,byt);
                     r:=dxfRequiredDouble(f,40,byt);
                     sa:=dxfRequiredDouble(f,50,byt);
                     ea:=dxfRequiredDouble(f,51,byt);
                     isNegative:=0;
                     if dxfIntegerload(f,73,byt,isNegative) then
                       byt:=f.ParseInteger;

                     sa:=sa*pi/180;
                     ea:=ea*pi/180;
                     a:=ea-sa;

                     if isNegative=0 then begin
                       sa:=2*pi-sa;
                       ea:=2*pi-ea;
                       a:=-a;
                     end;

                     for k:=1 to 16 do begin
                       SinCos(sa+k/16*a,p.y,p.x);
                       p:=cp+p*r;
                       currpath.PushBackData(p);
                     end;
                   end;
                 3:begin
                     //NotPolyLine:=NPL_EllipticArc;
                     if dxfdoubleload(f,10,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,20,byt,p.y) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,11,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,21,byt,p.y) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,40,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,50,byt,p.y) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,51,byt,p.x) then byt:=f.ParseInteger;
                     if dxfdoubleload(f,73,byt,p.y) then byt:=f.ParseInteger;
                   end;
                 4://NotPolyLine:=NPL_Spline;
                   loadSplineBoundary(byt,currpath);
               end;
             end;
           end;
         end;
         if dxfintegerload(f,97,byt,bt) then
           if bt<>0 then
             byt:=f.ParseInteger;
         for j:=1 to bt do begin
           if (dxfstringload(f,330,byt,s))and(j<>bt) then byt:=f.ParseInteger;
         end;
         currpath.Shrink;
         paths.PushBackData(currpath);
       end;
     end;
end;
procedure TBoundaryPath.SaveToDXF(var outhandle:TZctnrVectorBytes);
var
   i,j: Integer;
   pv:PGDBvertex2D;
begin
  dxfIntegerout(outhandle,91,paths.Count);
  for i:=0 to paths.Count-1  do begin
    dxfIntegerout(outhandle,92,7);
    dxfIntegerout(outhandle,72,0);
    dxfIntegerout(outhandle,73,1);
    dxfIntegerout(outhandle,93,paths.getData(i).Count);
    for j:=0 to paths.getData(i).Count-1 do begin
      pv:=paths.getData(i).getDataMutable(j);
      dxfDoubleout(outhandle,10,pv.x);
      dxfDoubleout(outhandle,20,pv.y);
    end;
    dxfIntegerout(outhandle,97,0);
  end;
end;
procedure TBoundaryPath.CloneTo(var Dest:TBoundaryPath);
var i,j:integer;
   ppla:PGDBPolyline2DArray;
begin
  Dest.paths.Clear;
  Dest.paths.SetSize(paths.GetCount);
  if Dest.paths.PArray=nil then
    Dest.paths.CreateArray;
  for i:=0 to paths.count-1 do begin
    ppla:=Dest.paths.getDataMutable(i);
    ppla^.init(paths.getData(i).GetCount,true);
    Dest.paths.Count:=i+1;
    for j:=0 to paths.getData(i).count-1 do
      ppla^.PushBackData(paths.getData(i).getData(j));
  end;
end;
begin
end.

