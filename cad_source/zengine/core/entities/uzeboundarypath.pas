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
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,UGDBPolyline2DArray,gzctnrVector,
  uzctnrVectorBytes,{uzbtypes,uzedrawingdef,}uzeffdxfsupport;
type
{Export+}
PBoundaryPath=^TBoundaryPath;
{REGISTEROBJECTTYPE TZEntityRepresentation}
TBoundaryPath=object
  paths:GZVector<GDBPolyline2DArray>;
  constructor init();
  destructor done;virtual;
  function LoadFromDXF(var f:TZctnrVectorBytes;dxfcod:Integer):Boolean;
  procedure SaveToDXF(var outhandle:TZctnrVectorBytes);
  procedure Clear;virtual;
end;
{Export-}
implementation
constructor TBoundaryPath.init;
begin
  paths.init(10);
end;
destructor TBoundaryPath.done;
begin
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
begin
end.

