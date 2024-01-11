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

uses uzegeometrytypes,UGDBPolyline2DArray,gzctnrVector,
  uzctnrVectorBytes,gzctnrVectorTypes,uzegeometry,uzeffdxfsupport;
type
PBoundaryPath=^TBoundaryPath;
TBoundaryPath=object
  paths:GZVector<GDBPolyline2DArray>;
  constructor init(m:TArrayIndex);
  destructor done;virtual;
  function LoadFromDXF(var f:TZctnrVectorBytes;dxfcod:Integer):Boolean; {todo: вынести это нафиг из простых типов}
  procedure SaveToDXF(var outhandle:TZctnrVectorBytes);
  procedure CloneTo(var Dest:TBoundaryPath);
  procedure Clear;virtual;

  procedure transform(const t_matrix:DMatrix4D);virtual;
  function getDataMutableByPlainIndex(index:TArrayIndex):PGDBVertex2D;

  function DummyCalcTrueInFrustum(pv1:pgdbvertex;frustum:ClipArray):TInBoundingVolume;virtual;
end;

implementation

function TBoundaryPath.DummyCalcTrueInFrustum(pv1:pgdbvertex;frustum:ClipArray):TInBoundingVolume;
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
   tv:GDBVertex;
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

function TBoundaryPath.LoadFromDXF(var f:TZctnrVectorBytes;dxfcod:Integer):Boolean;
type
  TNotPolyLine=(NPL_Line,NPL_CircularArc,NPL_EllipticArc,NPL_Spline);
var
  currpath:GDBPolyline2DArray;
  i,j,pathscount,vertexcount,byt,bt:integer;
  firstp,prevp,p:GDBVertex2D;
  tmp:double;
  s:string;
  isPolyLine:boolean;
  NotPolyLine:TNotPolyLine;
  isFirst:boolean;
begin
     result:=dxfIntegerload(f,91,dxfcod,pathscount);
     if result then begin
       isPolyLine:=false;
       byt:=readmystrtoint(f);
       Clear;
       for i:=1 to pathscount do begin
         while not dxfintegerload(f,92,byt,bt) do
           byt:=readmystrtoint(f);
         isPolyLine:=(bt and 2)<>0;
         byt:=readmystrtoint(f);
         if isPolyLine then begin
           if dxfintegerload(f,72,byt,bt) then byt:=readmystrtoint(f);
           if dxfintegerload(f,73,byt,bt) then byt:=readmystrtoint(f);
           if dxfintegerload(f,93,byt,vertexcount) then byt:=readmystrtoint(f);
           currpath.init(vertexcount,true);
           for j:=1 to vertexcount do begin
             if dxfdoubleload(f,10,byt,p.x) then byt:=readmystrtoint(f);
             if dxfdoubleload(f,20,byt,p.y) then byt:=readmystrtoint(f);
             if dxfdoubleload(f,42,byt,tmp) then byt:=readmystrtoint(f);
             currpath.PushBackData(p);
           end;
         end else begin
           if dxfintegerload(f,93,byt,vertexcount) then byt:=readmystrtoint(f);
           currpath.init(vertexcount,true);
           isFirst:=true;
           for j:=1 to vertexcount do begin
             if dxfintegerload(f,72,byt,bt) then begin
               byt:=readmystrtoint(f);
               case bt of
                 1:begin
                     if dxfdoubleload(f,10,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,20,byt,p.y) then byt:=readmystrtoint(f);
                     if not isFirst then begin
                       if not(IsPoint2DEqual(p,prevp)) then
                         currpath.PushBackData(p);
                     end else begin
                       currpath.PushBackData(p);
                       firstp:=p;
                     end;
                     isFirst:=false;
                     if dxfdoubleload(f,11,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,21,byt,p.y) then byt:=readmystrtoint(f);
                     if j<>vertexcount then
                       currpath.PushBackData(p)
                     else
                       if not(IsPoint2DEqual(p,firstp)) then
                         currpath.PushBackData(p);
                     prevp:=p;
                   end;
                 2:begin
                     NotPolyLine:=NPL_CircularArc;
                     if dxfdoubleload(f,10,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,20,byt,p.y) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,40,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,50,byt,p.y) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,51,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,73,byt,p.y) then byt:=readmystrtoint(f);
                   end;
                 3:begin
                     NotPolyLine:=NPL_EllipticArc;
                     if dxfdoubleload(f,10,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,20,byt,p.y) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,11,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,21,byt,p.y) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,40,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,50,byt,p.y) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,51,byt,p.x) then byt:=readmystrtoint(f);
                     if dxfdoubleload(f,73,byt,p.y) then byt:=readmystrtoint(f);
                   end;
                 4:begin
                     NotPolyLine:=NPL_Spline;
                   end;
               end;
             end;
           end;
         end;
         if dxfintegerload(f,97,byt,bt) then
           if bt<>0 then
             byt:=readmystrtoint(f);
         for j:=1 to bt do begin
           if (dxfstringload(f,330,byt,s))and(j<>bt) then byt:=readmystrtoint(f);
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

