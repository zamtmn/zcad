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

unit uzeBoundaryPath;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}
interface
uses uzegeometrytypes,UGDBPolyline2DArray,gzctnrVector,
  uzctnrVectorBytes,gzctnrVectorTypes,uzegeometry,uzeffdxfsupport;
type
{Export+}
PBoundaryPath=^TBoundaryPath;
{REGISTEROBJECTTYPE TZEntityRepresentation}
TBoundaryPath=object
  paths:GZVector<GDBPolyline2DArray>;
  constructor init(m:TArrayIndex);
  destructor done;virtual;
  function LoadFromDXF(var f:TZctnrVectorBytes;dxfcod:Integer):Boolean; {todo: вынести это нафиг из простых типов}
  procedure SaveToDXF(var outhandle:TZctnrVectorBytes);
  procedure CloneTo(var Dest:TBoundaryPath);
  procedure Clear;virtual;

  procedure transform(const t_matrix:DMatrix4D);virtual;
end;
{Export-}
implementation

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
  paths.Clear;
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
var
  currpath:GDBPolyline2DArray;
  i,j,pathscount,vertexcount,byt,bt:integer;
  p:GDBVertex2D;
  s:string;
begin
     result:=dxfIntegerload(f,91,dxfcod,pathscount);
     if result then begin
       byt:=readmystrtoint(f);
       Clear;
       for i:=1 to pathscount do begin
         if dxfintegerload(f,92,byt,bt) then byt:=readmystrtoint(f);
         if (bt and 2)<>0 then begin
           if dxfintegerload(f,72,byt,bt) then byt:=readmystrtoint(f);
           if dxfintegerload(f,73,byt,bt) then byt:=readmystrtoint(f);
           if dxfintegerload(f,93,byt,vertexcount) then byt:=readmystrtoint(f);
           currpath.init(10,true);
           for j:=1 to vertexcount do begin
             if dxfdoubleload(f,10,byt,p.x) then byt:=readmystrtoint(f);
             if dxfdoubleload(f,20,byt,p.y) then byt:=readmystrtoint(f);
             currpath.PushBackData(p);
           end;
           if dxfintegerload(f,97,byt,bt) then byt:=readmystrtoint(f);
           for j:=1 to bt do begin
             if dxfstringload(f,330,byt,s) then byt:=readmystrtoint(f);
           end;
           currpath.Shrink;
           paths.PushBackData(currpath);
         end;
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

