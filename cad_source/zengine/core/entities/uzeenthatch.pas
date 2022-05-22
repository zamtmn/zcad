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

unit uzeenthatch;
{$INCLUDE zengineconfig.inc}
interface
uses
  math,
    uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,gzctnrVectorTypes,
    uzestyleslayers,uzehelpobj,UGDBSelectedObjArray,
    uzegeometrytypes,uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,uzctnrVectorBytes,
    uzbtypes,uzeentwithlocalcs,uzeconsts,uzegeometry,uzeffdxfsupport,uzecamera,
    UGDBPolyLine2DArray,uzglviewareadata,uzeTriangulator,uzeBoundaryPath;
type
{Export+}
PGDBObjHatch=^GDBObjHatch;
{REGISTEROBJECTTYPE GDBObjHatch}
GDBObjHatch= object(GDBObjWithLocalCS)
                 Path:TBoundaryPath;
                 Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex);
                 constructor initnul;
                 procedure LoadFromDXF(var f:TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext);virtual;
                 function ObjToString(prefix,sufix:String):String;virtual;
                 destructor done;virtual;

                 function GetObjTypeName:String;virtual;

                 procedure createfield;virtual;

                 class function CreateInstance:PGDBObjHatch;static;
                 function GetObjType:TObjID;virtual;

                 procedure createpoint;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;

                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
           end;
{Export-}
implementation

procedure GDBObjHatch.transform;
begin
  inherited;
  Path.transform(t_matrix);
end;

procedure GDBObjHatch.TransformAt;
begin
  inherited;
  Path.Clear;
  Vertex2D_in_OCS_Array.clear;
  pGDBObjHatch(p)^.Path.CloneTo(Path);
  Path.transform(t_matrix^);
end;



procedure GDBObjHatch.createfield;
begin
     inherited;
     Outbound[0]:=nulvertex;
     Outbound[1]:=nulvertex;
     Outbound[2]:=nulvertex;
     Outbound[3]:=nulvertex;
end;
function GDBObjHatch.GetObjTypeName;
begin
     result:=ObjN_GDBObjHatch;
end;
destructor GDBObjHatch.done;
begin
  Vertex3D_in_WCS_Array.Done;
  Vertex2D_in_OCS_Array.Done;
  inherited done;
  if pprojpoint<>nil then begin
    pprojpoint^.done;
    Freemem(pointer(pprojpoint));
  end;
end;
function GDBObjHatch.ObjToString(prefix,sufix:String):String;
begin
     result:=prefix+inherited ObjToString('GDBObjHatch (addr:',')')+sufix;
end;
constructor GDBObjHatch.initnul;
begin
  inherited initnul(nil);
  PProjoutbound:=nil;
  PProjPoint:=nil;
  Vertex3D_in_WCS_Array.init(10);
  Vertex2D_in_OCS_Array.init(10,true);
  Path.init(10);
end;
constructor GDBObjHatch.init;
begin
  inherited init(own,layeraddres, lw);
  Local.p_insert := p;
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  PProjoutbound:=nil;
  PProjPoint:=nil;
  Vertex3D_in_WCS_Array.init(10);
  Vertex2D_in_OCS_Array.init(10,true);
  Path.init(10);
end;
function GDBObjHatch.GetObjType;
begin
     result:=GDBHatchID;
end;
procedure GDBObjHatch.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'HATCH','AcDbHatch',IODXFContext);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfvertexout(outhandle,210,local.basis.oz);
  dxfStringout(outhandle,2,'SOLID');
  dxfIntegerout(outhandle,70,1);
  dxfIntegerout(outhandle,71,1);
  Path.SaveToDXF(outhandle);
  dxfIntegerout(outhandle,75,1);
  dxfIntegerout(outhandle,76,1);
  dxfIntegerout(outhandle,47,10);
  dxfIntegerout(outhandle,98,0);
  SaveToDXFObjPostfix(outhandle);
end;

procedure GDBObjHatch.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var
   hatchTess:TTriangulator.TTesselator;
   i,j: Integer;
   pv:PGDBvertex;
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  calcObjMatrix;
  createpoint;
  calcbb(dc);
  Representation.Clear;
  hatchTess:=Triangulator.NewTesselator;

  pv:=Vertex3D_in_WCS_Array.GetParrayAsPointer;

  Triangulator.BeginPolygon(@Representation,hatchTess);

  for i:=0 to Path.paths.Count-1  do begin
    Triangulator.BeginContour(hatchTess);
    for j:=0 to Path.paths.getData(i).Count-1 do begin
       Triangulator.TessVertex(hatchTess,pv^);
       inc(pv);
    end;
    Triangulator.EndContour(hatchTess);
  end;
  Triangulator.EndPolygon(hatchTess);

  Triangulator.DeleteTess(hatchTess);
  //Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,true,true);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjHatch.createpoint;
var
  i,j: Integer;
  v:GDBvertex4D;
  v3d:GDBVertex;
  pv:PGDBVertex2D;
begin
  Vertex3D_in_WCS_Array.clear;

  for i:=0 to Path.paths.Count-1  do begin
    for j:=0 to Path.paths.getData(i).Count-1 do begin
       v.x:=Path.paths.getData(i).getData(j).x;
       v.y:=Path.paths.getData(i).getData(j).y;
       v.z:=0;
       v.w:=1;
       v:=VectorTransform(v,objMatrix);
       v3d:=PGDBvertex(@v)^;
       Vertex3D_in_WCS_Array.PushBackData(v3d);
    end;
  end;

  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjHatch.getoutbound;
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
procedure GDBObjHatch.DrawGeometry;
begin
  Representation.DrawGeometry(DC);
  inherited;
end;
procedure GDBObjHatch.LoadFromDXF;
var
  byt:Integer;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not Path.LoadFromDXF (f,byt) then
      f.readString;
    byt:=readmystrtoint(f);
  end;
end;
function GDBObjHatch.Clone;
var
  tvo: PGDBObjHatch;
  p:PGDBVertex2D;
  i:integer;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjHatch));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert);
  tvo^.local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  Path.CloneTo(tvo^.Path);
  result := tvo;
end;

function GDBObjHatch.CalcTrueInFrustum;
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
procedure GDBObjHatch.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:Integer;
begin
     vertexnumber:=pdesc^.vertexnum;
     pdesc.worldcoord:=GDBPoint3dArray.PTArr(Vertex3D_in_WCS_Array.parray)^[vertexnumber];
     pdesc.dispcoord.x:=round(GDBPolyline2DArray.PTArr(PProjPoint.parray)^[vertexnumber].x);
     pdesc.dispcoord.y:=round(GDBPolyline2DArray.PTArr(PProjPoint.parray)^[vertexnumber].y);
end;
procedure GDBObjHatch.Renderfeedback;
var tv:GDBvertex;
    tpv:GDBVertex2D;
    ptpv:PGDBVertex;
    i:Integer;
begin
  if pprojpoint=nil then
  begin
       Getmem(Pointer(pprojpoint),sizeof(GDBpolyline2DArray));
       pprojpoint^.init(Vertex3D_in_WCS_Array.count,true);
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

procedure GDBObjHatch.AddControlpoints;
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
procedure GDBObjHatch.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  vertexnumber:Integer;
  tv,wwc:gdbvertex;
  M:DMatrix4D;
begin
  vertexnumber:=rtmod.point.vertexnum;
  m:=self.ObjMatrix;
  uzegeometry.MatrixInvert(m);

  tv:=rtmod.dist;
  wwc:=rtmod.point.worldcoord;
  wwc:=VertexAdd(wwc,tv);
  wwc:=uzegeometry.VectorTransform3D(wwc,m);

  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].x:=wwc.x{VertexAdd(wwc,tv)};
  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].y:=wwc.y;
end;

function AllocHatch:PGDBObjHatch;
begin
  Getmem(pointer(result),sizeof(GDBObjHatch));
end;
function AllocAndInitHatch(owner:PGDBObjGenericWithSubordinated):PGDBObjHatch;
begin
  result:=AllocHatch;
  result.initnul;
  result.bp.ListPos.Owner:=owner;
end;
procedure SetHatchGeomProps(Pcircle:PGDBObjHatch;args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pcircle.Local.p_insert:=CreateVertexFromArray(counter,args);
end;
function AllocAndCreateHatch(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjHatch;
begin
  result:=AllocAndInitHatch(owner);
  //owner^.AddMi(@result);
  SetHatchGeomProps(result,args);
end;
class function GDBObjHatch.CreateInstance:PGDBObjHatch;
begin
  result:=AllocAndInitHatch(nil);
end;
begin
  RegisterDXFEntity(GDBHatchID,'HATCH','Hatch',@AllocHatch,@AllocAndInitHatch,@SetHatchGeomProps,@AllocAndCreateHatch);
end.

