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

unit uzeenthatch;
{$INCLUDE zengineconfig.inc}
interface
uses
  math,
    uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,gzctnrVectorTypes,
    uzestyleslayers,uzehelpobj,UGDBSelectedObjArray,
    uzegeometrytypes,uzeentity,UGDBPoint3DArray,uzctnrVectorBytes,
    uzbtypes,uzeentwithlocalcs,uzeconsts,uzegeometry,uzeffdxfsupport,uzecamera,
    UGDBPolyLine2DArray,uzglviewareadata,uzeTriangulator,
    uzeBoundaryPath,uzeStylesHatchPatterns,gvector,garrayutils;
type
TLineInContour=record
  C{,L}:integer;
end;
TIntercept2dpropWithLIC=record
  i2dprop:intercept2dprop;
  LIC:TLineInContour;
  constructor create(const Ai2dprop:intercept2dprop;const AC{,AL}:Integer);
end;
TIntercept2dpropWithLICCompate=class
  class function c(a,b:TIntercept2dpropWithLIC):boolean;inline;
end;
TIntercept2dpropWithLICVector=TVector<TIntercept2dpropWithLIC>;
TVSorter=TOrderingArrayUtils<TIntercept2dpropWithLICVector,TIntercept2dpropWithLIC,TIntercept2dpropWithLICCompate>;
{Export+}
THatchIslandDetection=(HID_Normal,Hid_Ignore,HID_Outer);
PGDBObjHatch=^GDBObjHatch;
{REGISTEROBJECTTYPE GDBObjHatch}
GDBObjHatch= object(GDBObjWithLocalCS)
                 Path:TBoundaryPath;
                 PPattern:PTHatchPattern;
                 Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)
                 //Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 PatternName:string;
                 IslandDetection:THatchIslandDetection;
                 Angle,Scale:Double;
                 Origin:GDBvertex2D;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex);
                 constructor initnul;
                 procedure LoadFromDXF(var f:TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure ProcessLine(const c:integer;const l1,l2,c1,c2:GDBvertex2D;var IV:TIntercept2dpropWithLICVector);
                 procedure ProcessLines(const p1,p2:GDBvertex2D;var IV:TIntercept2dpropWithLICVector);
                 procedure ProcessStroke(var Strokes:TPatStrokesArray;var IV:TIntercept2dpropWithLICVector;var DC:TDrawContext);
                 procedure DrawStrokes(var Strokes:TPatStrokesArray;var st:Double;const p1,p2:GDBvertex2D;var DC:TDrawContext);
                 procedure FillPattern(var Strokes:TPatStrokesArray;var DC:TDrawContext);
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
const
  HID2DXF:array[THatchIslandDetection] of integer=(0,2,1);
implementation

class function TIntercept2dpropWithLICCompate.c(a,b:TIntercept2dpropWithLIC):boolean;
begin
  result:=a.i2dprop.t1<b.i2dprop.t1;
end;

constructor TIntercept2dpropWithLIC.create(const Ai2dprop:intercept2dprop;const AC{,AL}:Integer);
begin
  i2dprop:=Ai2dprop;
  LIC.C:=AC;
  //LIC.L:=AL;
end;

procedure GDBObjHatch.transform;
begin
  inherited;
  Path.transform(t_matrix);
end;

procedure GDBObjHatch.TransformAt;
begin
  inherited;
  Path.Clear;
  //Vertex2D_in_OCS_Array.clear;
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
  //Vertex2D_in_OCS_Array.Done;
  inherited done;
  if pprojpoint<>nil then begin
    pprojpoint^.done;
    Freemem(pointer(pprojpoint));
  end;
  Path.done;
  if PPattern<>nil then begin
    PPattern^.done;
    Freemem(PPattern);
  end;
  PatternName:='';
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
  //Vertex2D_in_OCS_Array.init(10,true);
  Path.init(10);
  PPattern:=nil;
  IslandDetection:=HID_Normal;
  Angle:=0;
  Scale:=1;
  Origin:=NulVertex2D;
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
  //Vertex2D_in_OCS_Array.init(10,true);
  Path.init(10);
  PPattern:=nil;
  IslandDetection:=HID_Normal;
  Angle:=0;
  Scale:=1;
  Origin:=NulVertex2D;
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
  dxfStringout(outhandle,2,PatternName);
  if PPattern=nil then
    dxfIntegerout(outhandle,70,1)
  else
    dxfIntegerout(outhandle,70,0);
  dxfIntegerout(outhandle,71,1);
  Path.SaveToDXF(outhandle);
  dxfIntegerout(outhandle,75,HID2DXF[IslandDetection]);
  dxfIntegerout(outhandle,76,1);

  if PPattern<>nil then begin
    dxfDoubleout(outhandle,52,Angle);
    dxfDoubleout(outhandle,41,Scale);
    dxfIntegerout(outhandle,77,0);
  end;

  if PPattern<>nil then
    PPattern^.SaveToDXF(outhandle,Angle,Scale);

  dxfDoubleout(outhandle,47,1.25);
  dxfIntegerout(outhandle,98,0);
  SaveToDXFObjPostfix(outhandle);
end;
procedure GDBObjHatch.ProcessLine(const c:integer;const l1,l2,c1,c2:GDBvertex2D;var IV:TIntercept2dpropWithLICVector);
var
  iprop:intercept2dprop;
begin
  iprop:=intercept2dmy(l1,l2,c1,c2);
  if iprop.isintercept then
    if iprop.t2<1 then
      if iprop.t2>-eps then begin
        IV.PushBack(TIntercept2dpropWithLIC.create(iprop,c{,1}));
      end;
end;

procedure GDBObjHatch.ProcessLines(const p1,p2:GDBvertex2D;var IV:TIntercept2dpropWithLICVector);
var
  i,j:integer;
  ppath:PGDBPolyline2DArray;
  FirstP,PrevP,CurrP:PGDBvertex2D;
begin
  for i:=0 to Path.paths.Count-1 do begin
    ppath:=Path.paths.getDataMutable(i);
    FirstP:=ppath.getDataMutable(0);
    PrevP:=FirstP;
    CurrP:=nil;
    for j:=1 to ppath^.count-1 do begin
      CurrP:=ppath.getDataMutable(j);
      ProcessLine(i,p1,p2,PrevP^,CurrP^,IV);
      PrevP:=CurrP;
    end;
    if PrevP<>FirstP then
      ProcessLine(i,p1,p2,PrevP^,FirstP^,IV);
  end;
end;
function normalizeT(t,plen:Double):Double;
var
  c:double;
begin
  c:=abs(int(t/plen));
  if t>eps then
    result:=t-c*plen
  else if t<eps then
    result:=t+(c+1)*plen
  else
    result:=0;
end;

procedure findInterval(var Strokes:TPatStrokesArray;AScale:Double;t:Double;out cl:double;out c:integer);
var
  i:integer;
  d:double;
begin
  cl:=0;c:=-1;
  for i:=0 to Strokes.Count-1 do begin
    d:=abs(Strokes.getData(i))*AScale;
    if cl+d>t then begin
      c:=i;
      exit;
    end;
    cl:=cl+d;
  end;
  //result:=0;
end;



procedure GDBObjHatch.DrawStrokes(var Strokes:TPatStrokesArray;var st:Double;const p1,p2:GDBvertex2D;var DC:TDrawContext);
var
  t,l,cl,d,drawedlen:double;
  c:integer;
  dir:GDBvertex2D;
  p,pp:GDBvertex2D;
  first:boolean;
  newdrawlen:Double;
begin
  if Strokes.Count=0 then
    Representation.DrawLineWithoutLT(DC,VectorTransform3D(CreateVertex(p1.x,p1.y,0),ObjMatrix),VectorTransform3D(CreateVertex(p2.x,p2.y,0),ObjMatrix))
  else begin
    dir:=(p2-p1).NormalizeVertex;
    t:=Scale*normalizeT(st*Strokes.LengthFact,Strokes.LengthFact);

    l:=Vertexlength2d(p1,p2);
    findInterval(Strokes,Scale,t,cl,c);
    drawedlen:=0;
    p:=p1;
    first:=true;
    while drawedlen<l do begin
      d:=Strokes.getData(c)*Scale;
      if first then begin
        first:=false;
        if d>0 then
          d:=d-(t-cl)
        else
          d:=d+(t-cl)
      end;

      newdrawlen:=drawedlen+abs(d);

      if d=0 then
        Representation.DrawPoint(DC,VectorTransform3D(CreateVertex(p.x,p.y,0),ObjMatrix),vp)
      else if d>0 then begin
        if newdrawlen<=l then begin
          pp.x:=p.x+dir.x*abs(d);
          pp.y:=p.y+dir.y*abs(d);
          Representation.DrawLineWithoutLT(DC,VectorTransform3D(CreateVertex(p.x,p.y,0),ObjMatrix),VectorTransform3D(CreateVertex(pp.x,pp.y,0),ObjMatrix))
        end else begin
          pp.x:=p.x+dir.x*(d-(newdrawlen-l));
          pp.y:=p.y+dir.y*(d-(newdrawlen-l));
          Representation.DrawLineWithoutLT(DC,VectorTransform3D(CreateVertex(p.x,p.y,0),ObjMatrix),VectorTransform3D(CreateVertex(pp.x,pp.y,0),ObjMatrix));
        end;
      end else begin
        pp.x:=p.x-dir.x*d;
        pp.y:=p.y-dir.y*d;
      end;
      p:=pp;

      drawedlen:=newdrawlen;
      inc(c);
      if c>(Strokes.Count-1) then
        c:=0;
    end;

  end;
end;

procedure GDBObjHatch.ProcessStroke(var Strokes:TPatStrokesArray;var IV:TIntercept2dpropWithLICVector;var DC:TDrawContext);
var
  p1,p2:PGDBvertex2D;
  t1:Double;
  i,first,current:integer;
  inside:boolean;
begin
  if IV.Size>1 then begin
    TVSorter.Sort(IV,IV.Size);
    case IslandDetection of
      HID_Normal:begin
                   p1:=@IV.Mutable[0].i2dprop.interceptcoord;
                   t1:=IV.Mutable[0].i2dprop.t1;
                   for i:=1 to IV.Size-1 do begin
                     p2:=@IV.Mutable[i].i2dprop.interceptcoord;
                     if (i and 1)=1 then
                       DrawStrokes(Strokes,t1,p1^,p2^,DC);
                     p1:=p2;
                     t1:=IV.Mutable[i].i2dprop.t1;
                   end;
                 end;
      Hid_Ignore:begin
                   if IV.Size>3 then begin

                   p1:=@IV.Mutable[0].i2dprop.interceptcoord;
                   t1:=IV.Mutable[0].i2dprop.t1;
                   first:=IV.Mutable[0].LIC.C;
                   inside:=true;
                   for i:=1 to IV.Size-1 do begin
                     if first=IV.Mutable[i].LIC.C then begin
                       p2:=@IV.Mutable[i].i2dprop.interceptcoord;
                       if inside then
                         DrawStrokes(Strokes,t1,p1^,p2^,DC);
                       p1:=p2;
                       t1:=IV.Mutable[i].i2dprop.t1;
                       inside:=not inside;
                     end;
                    end;

                    end else begin
                      p1:=@IV.Mutable[0].i2dprop.interceptcoord;
                      p2:=@IV.Mutable[IV.Size-1].i2dprop.interceptcoord;
                      DrawStrokes(Strokes,IV.Mutable[0].i2dprop.t1,p1^,p2^,DC);
                    end;
                 end;
       HID_Outer:begin
                   if IV.Size>3 then begin

                   p1:=@IV.Mutable[0].i2dprop.interceptcoord;
                   t1:=IV.Mutable[0].i2dprop.t1;
                   first:=IV.Mutable[0].LIC.C;
                   inside:=true;
                   current:=-1;
                   for i:=1 to IV.Size-1 do begin
                     p2:=@IV.Mutable[i].i2dprop.interceptcoord;
                     if (current=-1)and inside then
                       DrawStrokes(Strokes,t1,p1^,p2^,DC);
                     p1:=p2;
                     t1:=IV.Mutable[i].i2dprop.t1;
                     if current=-1 then begin
                       if first<>IV.Mutable[i].LIC.C then
                         current:=IV.Mutable[i].LIC.C;
                     end else
                       if current=IV.Mutable[i].LIC.C then
                         current:=-1;

                     if first=IV.Mutable[i].LIC.C then
                       inside:=not inside;
                   end;

                   end else begin
                     p1:=@IV.Mutable[0].i2dprop.interceptcoord;
                     p2:=@IV.Mutable[IV.Size-1].i2dprop.interceptcoord;
                     DrawStrokes(Strokes,IV.Mutable[0].i2dprop.t1,p1^,p2^,DC);
                   end;
               end;
    end;
  end;
end;

procedure GDBObjHatch.FillPattern(var Strokes:TPatStrokesArray;var DC:TDrawContext);
var
  Angl,{LenOffs,}LF,sinA,cosA:Double;
  offs,offs2,dirx,diry,p2,ls:GDBVertex2D;
  pp:PGDBvertex2D;
  i,j:integer;
  iprop:intercept2dprop;
  tmin,tmax:double;
  first:boolean;
  IV:TIntercept2dpropWithLICVector;
begin
  IV:=TIntercept2dpropWithLICVector.Create;
  Angl:=DegToRad(Angle+Strokes.Angle);
  //LenOffs:=oneVertexlength2D(Strokes.Offset);
  if Strokes.LengthFact>0 then
    LF:=Strokes.LengthFact
  else
    LF:=1;
  diry.x:=cos(Angl)*LF*Scale;
  diry.y:=sin(Angl)*LF*Scale;

  Angl:=DegToRad(Angle);
  sinA:=sin(Angl);
  cosA:=cos(Angl);
  dirx.x:=(Strokes.Offset.x*cosA-Strokes.Offset.y*sinA)*Scale;
  dirx.y:=(Strokes.Offset.y*cosA+Strokes.Offset.x*sinA)*Scale;
  //dirx.x:=Strokes.Offset.x*Scale;
  //dirx.y:=Strokes.Offset.y*Scale;

  offs:=Vertex2dMulOnSc(Strokes.Base,Scale);
  offs:=VertexAdd(offs,Vertex2dMulOnSc(Origin,Scale));
  offs2:=VertexAdd(offs,dirx);

  first:=true;
  for i:=0 to Path.paths.Count-1 do
    for j:=0 to Path.paths.getDataMutable(i)^.count-1 do begin
      pp:=Path.paths.getDataMutable(i)^.getDataMutable(j);
      p2:=VertexAdd(pp^,diry);
      iprop:=intercept2dmy(offs,offs2,pp^,p2);
      if iprop.isintercept then
        if first then begin
          first:=false;
          tmin:=iprop.t1;
          tmax:=iprop.t1;
        end else begin
          if tmin>iprop.t1 then
            tmin:=iprop.t1;
          if tmax<iprop.t1 then
            tmax:=iprop.t1;
        end;
    end;
  if not first then begin
    tmin:=int(tmin{+0.5});
    tmax:=int(tmax);
    ls:=VertexAdd(offs,Vertex2dMulOnSc(dirx,tmin));
    while tmin<=tmax do begin
      IV.Clear;
      ProcessLines(ls,VertexAdd(ls,diry),IV);
      ProcessStroke(Strokes,IV,DC);
      ls:=VertexAdd(ls,dirx);
      tmin:=tmin+1;
    end;
  end;
  IV.Free;
end;

procedure GDBObjHatch.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
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
  if not (ESTemp in State)and(DCODrawable in DC.Options) then begin
    Representation.Geometry.Lock;
    hatchTess:=Triangulator.NewTesselator;

    pv:=Vertex3D_in_WCS_Array.GetParrayAsPointer;

    if PPattern=nil then begin
      Triangulator.BeginPolygon(@Representation,hatchTess);
      for i:=0 to Path.paths.Count-1 do begin
        Triangulator.BeginContour(hatchTess);
        for j:=0 to Path.paths.getData(i).Count-1 do begin
           Triangulator.TessVertex(hatchTess,pv^);
           inc(pv);
        end;
        Triangulator.EndContour(hatchTess);
      end;
      Triangulator.EndPolygon(hatchTess);
    end else begin
      for i:=0 to PPattern^.Count-1 do
        FillPattern(PPattern^.getDataMutable(i)^,DC);
    end;

    Representation.Geometry.UnLock;
    Triangulator.DeleteTess(hatchTess);
  end;
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjHatch.createpoint;
var
  i,j: Integer;
  v:GDBvertex4D;
  v3d:GDBVertex;
  ppolyarr:pGDBPolyline2DArray;
begin
  Vertex3D_in_WCS_Array.clear;

  for i:=0 to Path.paths.Count-1  do begin
    ppolyarr:=Path.paths.getDataMutable(i);
    for j:=0 to Path.paths.getData(i).Count-1 do begin
       v.x:=ppolyarr^.getData(j).x;
       v.y:=ppolyarr^.getData(j).y;
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
var
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
  byt,hstyle:Integer;
begin
  hstyle:=100;
  Angle:=0;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not Path.LoadFromDXF (f,byt) then
    if not LoadPatternFromDXF(PPattern,f,byt,Angle,Scale) then
    if not dxfintegerload(f,75,byt,hstyle) then
    if not dxfDoubleload(f,52,byt,Angle) then
    if not dxfDoubleload(f,41,byt,Scale) then
    if not dxfStringload(f,2,byt,PatternName) then
      f.readString;
    byt:=readmystrtoint(f);
  end;
  case hstyle of
    1:IslandDetection:=HID_Outer;
    2:IslandDetection:=Hid_Ignore;
    else IslandDetection:=HID_Normal;
  end;
end;

function GDBObjHatch.Clone;
var
  tvo: PGDBObjHatch;
  i:integer;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjHatch));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert);
  tvo^.local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.PatternName:=PatternName;
  tvo^.IslandDetection:=IslandDetection;
  tvo^.Angle:=Angle;
  tvo^.Scale:=Scale;
  tvo^.Origin:=Origin;
  Path.CloneTo(tvo^.Path);
  if PPattern<>nil then begin
    getmem(tvo^.PPattern,SizeOf(THatchPattern));
    tvo^.PPattern^.init(PPattern^.Count);
    if tvo^.PPattern^.parray=nil then
      tvo^.PPattern^.createarray;
    for i:=0 to PPattern^.Count-1 do begin
      tvo^.PPattern^.getDataMutable(i)^.init(PPattern^.getDataMutable(i)^.count);
      PPattern^.getDataMutable(i)^.copyto(tvo^.PPattern^.getDataMutable(i)^);
    end;
    tvo^.PPattern^.count:=PPattern^.Count;
  end;
  result := tvo;
end;

function GDBObjHatch.CalcTrueInFrustum;
var
  pv1:pgdbvertex;
begin
  pv1:=Vertex3D_in_WCS_Array.getDataMutable(0);
  if pv1<>nil then
    result:=Path.DummyCalcTrueInFrustum(pv1,frustum)
  else
    result:=IRFully;
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
  pv:PGDBvertex2D;
  M:DMatrix4D;
begin
  vertexnumber:=rtmod.point.vertexnum;
  m:=self.ObjMatrix;
  uzegeometry.MatrixInvert(m);

  tv:=rtmod.dist;
  wwc:=rtmod.point.worldcoord;
  wwc:=VertexAdd(wwc,tv);
  wwc:=uzegeometry.VectorTransform3D(wwc,m);

  pv:=Path.getDataMutableByPlainIndex(vertexnumber);
  if pv<>nil then begin
    pv.x:=wwc.x;
    pv.y:=wwc.y;
  end;
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

