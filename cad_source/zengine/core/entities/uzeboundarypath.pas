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
  uzeSplineUtils,uzegluinterface,uzbLogIntf;
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
  zDebugLn('{E}'+GLUIntrf.ErrorString(v));
end;

(*procedure NurbsBeginCallBack(const v: TGLUIntf_GLenum;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
end;

procedure NurbsEndCallBack(const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
end;*)


function TBoundaryPath.LoadFromDXF(var f:TZMemReader;DXFCode:Integer):Boolean;
//type
//  TNotPolyLineEdge=(NPLE_Line,NPLE_CircularArc,NPLE_EllipticArc,NPLE_Spline);

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

  procedure loadPolyWithBulges(var currDXFGroupCode:integer;out currpath:GDBPolyline2DArray;const VertexCount:integer;const Closed:Boolean);//inline;
  var
    p1,pcurr,pnext:GDBVertex2D;
    j:Integer;
    bulge,nextbulge:double;
  begin
    currpath.init(vertexcount*10,true);
    //if dxfdoubleload(f,10,currDXFGroupCode,pcurr.x) then currDXFGroupCode:=f.ParseInteger;
    //if dxfdoubleload(f,20,currDXFGroupCode,pcurr.y) then currDXFGroupCode:=f.ParseInteger;
    pcurr:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
    bulge:=0;
    if dxfdoubleload(f,42,currDXFGroupCode,bulge) then currDXFGroupCode:=f.ParseInteger;
    p1:=pcurr;
    for j:=2 to VertexCount do begin
      //if dxfdoubleload(f,10,currDXFGroupCode,pnext.x) then currDXFGroupCode:=f.ParseInteger;
      //if dxfdoubleload(f,20,currDXFGroupCode,pnext.y) then currDXFGroupCode:=f.ParseInteger;
      pnext:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
      nextbulge:=0;
      if dxfdoubleload(f,42,currDXFGroupCode,nextbulge) then currDXFGroupCode:=f.ParseInteger;

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

  procedure loadPoly(var currDXFGroupCode:integer;out currpath:GDBPolyline2DArray;const VertexCount:integer{;const Closed:Boolean});//inline;
  var
    p:GDBVertex2D;
    j:Integer;
  begin
    currpath.init(vertexcount,true);
    for j:=1 to VertexCount do begin
      //if dxfdoubleload(f,10,currDXFGroupCode,p.x) then currDXFGroupCode:=f.ParseInteger;
      //if dxfdoubleload(f,20,currDXFGroupCode,p.y) then currDXFGroupCode:=f.ParseInteger;
      p:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
      currpath.PushBackData(p);
    end;
  end;

  procedure loadPolyBoundary(var currDXFGroupCode:integer;out currpath:GDBPolyline2DArray);//inline;
  var
    hasBulge:integer=0;
    isClosed:integer=0;
    vertexcount:integer;
  begin
    if dxfintegerload(f,72,currDXFGroupCode,hasBulge) then currDXFGroupCode:=f.ParseInteger;
    if dxfintegerload(f,73,currDXFGroupCode,isClosed) then currDXFGroupCode:=f.ParseInteger;
    vertexcount:=dxfRequiredInteger(f,93,currDXFGroupCode);
    if hasBulge=0 then
      loadPoly(currDXFGroupCode,currpath,VertexCount{,isClosed<>0})
    else
      loadPolyWithBulges(currDXFGroupCode,currpath,VertexCount,isClosed<>0);
  end;

  procedure loadSplineEdge(var currDXFGroupCode:integer;var currpath:GDBPolyline2DArray);//inline;
  var
    vertexcount,k:integer;
    dummy:integer=0;
    knotcount:integer=0;
    startTg,endTg:GDBVertex2D;
    Knots:TKnotsVector;
    PCurrKnot:TKnotsVector.PT;
    CP:TCPVector;
    PPrevCP,PCurrCP:TCPVector.PT;
    nurbsobj:GLUnurbsObj;
    currL,L:float;
  begin
    if dxfIntegerload(f,94,currDXFGroupCode,dummy) then currDXFGroupCode:=f.ParseInteger;
    if dxfIntegerload(f,73,currDXFGroupCode,dummy) then currDXFGroupCode:=f.ParseInteger;
    if dxfIntegerload(f,74,currDXFGroupCode,dummy) then currDXFGroupCode:=f.ParseInteger;
    if dxfIntegerload(f,95,currDXFGroupCode,knotcount) then currDXFGroupCode:=f.ParseInteger;
    //if dxfIntegerload(f,96,currDXFGroupCode,vertexcount) then currDXFGroupCode:=f.ParseInteger;
    vertexcount:=dxfRequiredInteger(f,96,currDXFGroupCode);
    if knotcount>0 then begin
      Knots.init(knotcount);
      Knots.AllocData(knotcount);
      PCurrKnot:=Knots.GetParray;
      for k:=0 to knotcount-1 do begin
        if dxfFloatload(f,40,currDXFGroupCode,PCurrKnot^) then currDXFGroupCode:=f.ParseInteger;
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
        //if dxfFloatLoad(f,10,currDXFGroupCode,PCurrCP^.x) then currDXFGroupCode:=f.ParseInteger;
        //if dxfFloatLoad(f,20,currDXFGroupCode,PCurrCP^.y) then currDXFGroupCode:=f.ParseInteger;
        PCurrCP^.x:=dxfRequiredDouble(f,10,currDXFGroupCode);
        PCurrCP^.y:=dxfRequiredDouble(f,20,currDXFGroupCode);
        PCurrCP^.z:=0;
        PCurrCP^.w:=1;
        if dxfFloatLoad(f,42,currDXFGroupCode,PCurrCP^.w) then currDXFGroupCode:=f.ParseInteger;
        if PPrevCP<>nil then begin
          L:=vertexlen2df(PPrevCP^.x,PPrevCP^.y,PCurrCP^.x,PCurrCP^.y);
          if L>currL then
            currL:=L;
        end;
        PPrevCP:=PCurrCP;
        inc(PCurrCP);
      end;
    end;
    //if dxfdoubleload(f,42,currDXFGroupCode,p.y) then currDXFGroupCode:=f.ParseInteger;
    startTg:=NulVertex2D;
    endTg:=NulVertex2D;
    if dxfdoubleload(f,12,currDXFGroupCode,startTg.x) then currDXFGroupCode:=f.ParseInteger;
    if dxfdoubleload(f,22,currDXFGroupCode,startTg.y) then currDXFGroupCode:=f.ParseInteger;
    if dxfdoubleload(f,13,currDXFGroupCode,endTg.x) then currDXFGroupCode:=f.ParseInteger;
    if dxfdoubleload(f,23,currDXFGroupCode,endTg.y) then currDXFGroupCode:=f.ParseInteger;


    nurbsobj:=GLUIntrf.NewNurbsRenderer;

    GLUIntrf.SetupNurbsRenderer(nurbsobj,currL/15,
                                nil,nil,@NurbsVertexCallBack,@NurbsErrorCallBack,
                                @currpath);

    GLUIntrf.BeginCurve(nurbsobj);
    GLUIntrf.NurbsCurve(nurbsobj,Knots.Count,Knots.GetParrayAsPointer,{CP.Count}4,CP.GetParrayAsPointer,4,GLUIntf_GL_MAP1_VERTEX_4);
    GLUIntrf.EndCurve(nurbsobj);


    GLUIntrf.DeleteNurbsRenderer(nurbsobj);



    if knotcount>0 then
      Knots.done;
    if vertexcount>0 then
      CP.done;
  end;
  procedure loadArcEdge(var currDXFGroupCode:integer;var currpath:GDBPolyline2DArray);//inline;
  var
    k:integer;
    p,cp:GDBVertex2D;
    r,sa,ea,a:double;
    IsCounterClockWise:integer;
  begin
    //NotPolyLine:=NPLE_CircularArc;
    cp:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
    r:=dxfRequiredDouble(f,40,currDXFGroupCode);
    sa:=dxfRequiredDouble(f,50,currDXFGroupCode);
    ea:=dxfRequiredDouble(f,51,currDXFGroupCode);
    IsCounterClockWise:=0;
    if dxfIntegerload(f,73,currDXFGroupCode,IsCounterClockWise) then
     currDXFGroupCode:=f.ParseInteger;

    sa:=sa*pi/180;
    ea:=ea*pi/180;
    a:=ea-sa;

    if IsCounterClockWise=0 then begin
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

  procedure loadEllipseEdge(var currDXFGroupCode:integer;var currpath:GDBPolyline2DArray);//inline;
  var
    p,axis:GDBVertex2D;
    r,sa,ea,a:double;
    IsCounterClockWise:integer;
  begin
    //NotPolyLine:=NPLE_EllipticArc;
    p:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
    axis:=dxfRequiredVertex2D(f,11,currDXFGroupCode);
    r:=dxfRequiredDouble(f,40,currDXFGroupCode);
    sa:=dxfRequiredDouble(f,50,currDXFGroupCode);
    ea:=dxfRequiredDouble(f,51,currDXFGroupCode);
    IsCounterClockWise:=0;
    if dxfIntegerload(f,73,currDXFGroupCode,IsCounterClockWise) then
      currDXFGroupCode:=f.ParseInteger;
  end;

  procedure loadLineEdge(var currDXFGroupCode:integer;var currpath:GDBPolyline2DArray;EdgeNum,EdgesCount:Integer);//inline;
  var
    p:GDBVertex2D;
  begin
    //if dxfdoubleload(f,10,currDXFGroupCode,p.x) then currDXFGroupCode:=f.ParseInteger;
    //if dxfdoubleload(f,20,currDXFGroupCode,p.y) then currDXFGroupCode:=f.ParseInteger;
    p:=dxfRequiredVertex2D(f,10,currDXFGroupCode);
    if EdgeNum<>1 then begin
      if not(IsPoint2DEqual(p,currpath.getPLast^)) then
        currpath.PushBackData(p);
    end else begin
      currpath.PushBackData(p);
    end;
    //if dxfdoubleload(f,11,currDXFGroupCode,p.x) then currDXFGroupCode:=f.ParseInteger;
    //if dxfdoubleload(f,21,currDXFGroupCode,p.y) then currDXFGroupCode:=f.ParseInteger;
    p:=dxfRequiredVertex2D(f,11,currDXFGroupCode);
    if EdgeNum<>EdgesCount then
      currpath.PushBackData(p)
    else
      if not(IsPoint2DEqual(p,currpath.getPFirst^)) then
        currpath.PushBackData(p);
  end;

var
  currpath:GDBPolyline2DArray;
  pathscount:Integer=0;
  i,EdgeNum,EdgesCount,currDXFGroupCode,EdgeType:integer;
  s:string='';
  isPolyLine:boolean;
  BoundaryPathTypeFlag:Integer;
begin
  result:=dxfIntegerload(f,91,DXFCode,pathscount);
  if result then begin
    isPolyLine:=false;
    currDXFGroupCode:=f.ParseInteger;
    Clear;
    BoundaryPathTypeFlag:=0;
    for i:=1 to pathscount do begin
      while not dxfintegerload(f,92,currDXFGroupCode,BoundaryPathTypeFlag) do
       currDXFGroupCode:=f.ParseInteger;
      isPolyLine:=(BoundaryPathTypeFlag and 2)<>0;
      currDXFGroupCode:=f.ParseInteger;
      if isPolyLine then
       loadPolyBoundary(currDXFGroupCode,currpath)
      else begin
        EdgesCount:=dxfRequiredInteger(f,93,currDXFGroupCode);
        currpath.init(EdgesCount,true);
        for EdgeNum:=1 to EdgesCount do begin
          EdgeType:=dxfRequiredInteger(f,72,currDXFGroupCode);
          case EdgeType of
            1://NotPolyLine:=NPLE_Line;
              loadLineEdge(currDXFGroupCode,currpath,EdgeNum,EdgesCount);
            2://NotPolyLine:=NPLE_CircularArc;
              loadArcEdge(currDXFGroupCode,currpath);
            3://NotPolyLine:=NPLE_EllipticArc;
              loadEllipseEdge(currDXFGroupCode,currpath);
            4://NotPolyLine:=NPLE_Spline;
              loadSplineEdge(currDXFGroupCode,currpath);
            else
              raise EDXFReadException.CreateFmt('Wrong boundary edge type "1".."4" expected, but "%d" found',[EdgeType]);
          end;
        end;
      end;
      if dxfintegerload(f,97,currDXFGroupCode,EdgeType) then
        if EdgeType<>0 then
          currDXFGroupCode:=f.ParseInteger;
      for EdgeNum:=1 to EdgeType do begin
        if (dxfstringload(f,330,currDXFGroupCode,s))and(EdgeNum<>EdgeType) then currDXFGroupCode:=f.ParseInteger;
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

