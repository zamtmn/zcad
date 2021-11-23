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

unit uzeentspline;
{$INCLUDE def.inc}

interface
uses LCLProc,uzegluinterface,uzeentityfactory,uzgldrawcontext,uzgloglstatemanager,gzctnrvectordata,
     UGDBPoint3DArray,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
     gzctnrvectorpobjects,uzestyleslayers,uzeentsubordinated,uzeentcurve,uzbtypesbase,
     uzeentity,UGDBOpenArrayOfByte,uzbtypes,uzeconsts,uzglviewareadata,
     gzctnrvectortypes,uzbgeomtypes,uzegeometry,uzeffdxfsupport,sysutils,uzbmemman;
type
{Export+}
{REGISTEROBJECTTYPE TKnotsVector}
TKnotsVector= object(GZVectorData{-}<GDBFloat>{//})
                             end;
{REGISTEROBJECTTYPE TCPVector}
TCPVector= object(GZVectorData{-}<GDBvertex4S>{//})
                             end;
PGDBObjSpline=^GDBObjSpline;
{REGISTEROBJECTTYPE GDBObjSpline}
GDBObjSpline= object(GDBObjCurve)
                 ControlArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 ControlArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 Knots:{GDBOpenArrayOfData}TKnotsVector;(*saved_to_shd*)(*hidden_in_objinsp*)
                 AproxPointInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 Degree:GDBInteger;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 destructor done;virtual;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;

                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure SaveToDXFfollow(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;

                 function CreateInstance:PGDBObjSpline;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
implementation
var
    parr:PGDBPoint3dArray;
    tv0:gdbvertex;
procedure GDBObjSpline.getoutbound;
begin
  if AproxPointInWCS.Count>0 then
                                 vp.BoundingBox:=AproxPointInWCS.getoutbound
                             else
                                 vp.BoundingBox:=VertexArrayInWCS.getoutbound
end;
procedure GDBObjSpline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,closed);
end;
function GDBObjSpline.onmouse;
begin
  if {VertexArrayInWCS}AproxPointInWCS.count<2 then
                                  begin
                                       result:=false;
                                       exit;
                                  end;
   result:={VertexArrayInWCS}AproxPointInWCS.onmouse(mf,closed);
end;
function GDBObjSpline.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
begin
     if VertexArrayInWCS.onpoint(point,closed) then
                                                begin
                                                     result:=true;
                                                     objects.PushBackData(@self);
                                                end
                                            else
                                                result:=false;
end;
procedure GDBObjSpline.startsnap(out osp:os_record; out pdata:GDBPointer);
begin
     GDBObjEntity.startsnap(osp,pdata);
     gdbgetmem({$IFDEF DEBUGBUILD}'{C37BA022-4629-4E16-BEB6-E8AAB9AC6986}',{$ENDIF}pdata,sizeof(GDBVectorSnapArray));
     PGDBVectorSnapArray(pdata).init({$IFDEF DEBUGBUILD}'{C37BA022-4629-4E16-BEB6-E8AAB9AC6986}',{$ENDIF}VertexArrayInWCS.Max);
     BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,closed);
end;
function GDBObjSpline.getsnap;
begin
     result:=GDBPoint3dArraygetsnap(VertexArrayInWCS,PProjPoint,{snaparray}PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;
procedure NurbsVertexCallBack(const v: PGDBvertex3S);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
    tv: gdbvertex;
begin
     tv.x:=v^.x+tv0.x;
     tv.y:=v^.y+tv0.y;
     tv.z:=v^.z+tv0.z;
     parr^.PushBackData(tv);
     tv.x:=0;
end;

procedure NurbsErrorCallBack(const v: GLenum);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
    //tv: GLenum;
    p:pchar;
begin
     //tv:=v;
     p:=GLUIntrf.ErrorString(v);
     debugln('{E}'+p);
     //log.LogOut(p);
end;

procedure NurbsBeginCallBack(const v: GLenum);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
//var
    //tv: GLenum;
begin
     //tv:=v;
end;

procedure NurbsEndCallBack;{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
//var
//    tv: GLenum;
begin
     //tv:=1;
end;

procedure GDBObjSpline.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var //i,j: GDBInteger;
    ptv: pgdbvertex;
    //tv:gdbvertex;
    //vs:VectorSnap;
        ir:itrec;
    nurbsobj:GLUnurbsObj;
    CP:{GDBOpenArrayOfData}TCPVector;
    tfv{,base}:GDBvertex4D;
    tfvs:GDBvertex4S;
    m:DMatrix4D;
    fm,fp:DMatrix4F;
begin
     if assigned(EntExtensions)then
       EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
     FormatWithoutSnapArray;
     CP.init({$IFDEF DEBUGBUILD}'{4FCFE57E-4000-4535-A086-549DEC959CD4}',{$ENDIF}VertexArrayInOCS.count{,sizeof(GDBvertex4S)});
     ptv:=VertexArrayInOCS.beginiterate(ir);
     tv0:=ptv^;
     if bp.ListPos.owner<>nil then
                                         if bp.ListPos.owner^.GetHandle=H_Root then
                                                                                   begin
                                                                                        m:=onematrix;
                                                                                    end
                                                                               else
                                                                                   begin
                                                                                         m:=bp.ListPos.owner^.GetMatrix^;
                                                                                   end;
     tv0:=uzegeometry.VectorTransform3d(tv0,m);
  if ptv<>nil then
  repeat
        tfv.x:=ptv^.x{-ptv0^.x};
        tfv.y:=ptv^.y{-ptv0^.y};
        tfv.z:=ptv^.z{-ptv0^.z};
        tfv.w:=1;
        tfv:=uzegeometry.VectorTransform(tfv,m);

        tfv.x:=tfv.x-tv0.x;
        tfv.y:=tfv.y-tv0.y;
        tfv.z:=tfv.z-tv0.z;

        tfvs.x:=tfv.x;
        tfvs.y:=tfv.y;
        tfvs.z:=tfv.z;
        tfvs.w:=tfv.w;
        CP.PushBackData(tfvs);
        ptv:=VertexArrayInOCS.iterate(ir);
  until ptv=nil;

  {ptfv:=CP.beginiterate(ir);
  if ptfv<>nil then
  repeat
        ptfv:=CP.iterate(ir);
  until ptfv=nil;}

  {fl:=Knots.beginiterate(ir);
  if fl<>nil then
  repeat
        fl:=Knots.iterate(ir);
  until fl=nil;}

  parr:=@AproxPointInWCS;
  AproxPointInWCS.Clear;

  //glMatrixMode(GL_MODELVIEW);
  //glLoadIdentity;
  //glMatrixMode(GL_PROJECTION);
  //glLoadIdentity;
  //gluOrtho2D(-5.0, 5.0, -5.0, 5.0);

  nurbsobj:=GLUIntrf.NewNurbsRenderer;

  GLUIntrf.NurbsProperty(nurbsobj,GLU_NURBS_MODE_EXT,GLU_NURBS_TESSELLATOR_EXT);
  GLUIntrf.NurbsProperty(nurbsobj,GLU_SAMPLING_TOLERANCE,10);
  GLUIntrf.NurbsProperty(nurbsobj,GLU_DISPLAY_MODE,{GLU_FILL}GLU_POINT);
  GLUIntrf.NurbsProperty(nurbsobj,GLU_AUTO_LOAD_MATRIX, {GL_TRUE}GL_FALSE);
  fm:=ToDMatrix4F(DC.DrawingContext.matrixs.pmodelMatrix^);
  fp:=ToDMatrix4F(DC.DrawingContext.matrixs.pprojMatrix^);
  GLUIntrf.mygluLoadSamplingMatrices(nurbsobj,@fm,
                                              @fp,
                                              @DC.DrawingContext.matrixs.pviewport^);
  GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_BEGIN_EXT,@NurbsBeginCallBack);
  GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_END_EXT,@NurbsEndCallBack);
  GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_VERTEX_EXT,@NurbsVertexCallBack);
  GLUIntrf.NurbsCallback(nurbsobj,GLU_NURBS_ERROR,@NurbsErrorCallBack);

  GLUIntrf.BeginCurve(nurbsobj);
  GLUIntrf.NurbsCurve (nurbsobj,Knots.Count,Knots.GetParrayAsPointer,{CP.Count}4,CP.GetParrayAsPointer,degree+1,GL_MAP1_VERTEX_4);
  GLUIntrf.EndCurve(nurbsobj);


  GLUIntrf.DeleteNurbsRenderer(nurbsobj);

  CP.done;
  //programlog.LogOutFormatStr('AproxPointInWCS: count=%d;max=%d;parray=%p',[AproxPointInWCS.Count,AproxPointInWCS.Max,AproxPointInWCS.PArray],lp_OldPos,LM_Trace);
  AproxPointInWCS.Shrink;

  Representation.Clear;
  Representation.DrawPolyLineWithLT(dc,AproxPointInWCS,vp,false,false);
  calcbb(dc);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjSpline.FromDXFPostProcessBeforeAdd;
begin
     result:=nil;
end;

function GDBObjSpline.GetObjTypeName;
begin
     result:=ObjN_GDBObjSpline;
end;
constructor GDBObjSpline.init;
begin
  closed := c;
  inherited init(own,layeraddres, lw);
  ControlArrayInWCS.init({$IFDEF DEBUGBUILD}'{4213E1EA-8FF1-4E99-AEF5-C1635CB49B5A}',{$ENDIF}1000);
  ControlArrayInOCS.init({$IFDEF DEBUGBUILD}'{F4681C13-46C9-4831-A614-7039A7EB205B}',{$ENDIF}1000);
  Knots.init({$IFDEF DEBUGBUILD}'{BF696899-F624-47EA-8E03-2086912119AE}',{$ENDIF}1000{,sizeof(GDBFloat)});
  AproxPointInWCS.init({$IFDEF DEBUGBUILD}'{D9ECB710-37F2-414F-9CB2-7DE7DBDCD5AE}',{$ENDIF}1000);
  //vp.ID := GDBSplineID;
end;
constructor GDBObjSpline.initnul;
begin
  inherited initnul(owner);
  ControlArrayInWCS.init({$IFDEF DEBUGBUILD}'{4213E1EA-8FF1-4E99-AEF5-C1635CB49B5A}',{$ENDIF}1000);
  ControlArrayInOCS.init({$IFDEF DEBUGBUILD}'{892EA1AE-FB34-47B5-A2D1-18FA6B51A163}',{$ENDIF}1000);
  Knots.init({$IFDEF DEBUGBUILD}'{BF696899-F624-47EA-8E03-2086912119AE}',{$ENDIF}1000{,sizeof(GDBFloat)});
  AproxPointInWCS.init({$IFDEF DEBUGBUILD}'{84E195AD-72EC-43D1-8C37-F6EDDC84E325}',{$ENDIF}1000);
  //vp.ID := GDBSplineID;
end;
function GDBObjSpline.GetObjType;
begin
     result:=GDBSplineID;
end;
destructor GDBObjSpline.done;
begin
          ControlArrayInWCS.done;
          ControlArrayInOCS.done;
          Knots.done;
          AproxPointInWCS.done;
          inherited;
end;
procedure GDBObjSpline.DrawGeometry;
begin
     //vertexarrayInWCS.DrawGeometryWClosed(closed);
     self.Representation.DrawGeometry(DC);
{  if closed then oglsm.myglbegin(GL_line_loop)
            else oglsm.myglbegin(GL_line_strip);
  vertexarrayInWCS.iterategl(@myglVertex3dv);
  oglsm.myglend;}
  //inherited;
  drawbb(dc);
end;
function GDBObjSpline.Clone;
var tpo: PGDBObjSpline;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{8F88CAFB-14F3-4F33-96B5-F493DB8B28B7}',{$ENDIF}GDBPointer(tpo), sizeof(GDBObjSpline));
  tpo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  //tpo^.vertexarray.init({$IFDEF DEBUGBUILD}'{90423E18-2ABF-48A8-8E0E-5D08A9E54255}',{$ENDIF}1000);
  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);
  Knots.copyto(tpo^.Knots);
  tpo^.degree:=degree;
  {p:=vertexarrayinocs.PArray;
  for i:=0 to vertexarrayinocs.Count-1 do
  begin
      tpo^.vertexarrayinocs.add(p);
      inc(p)
  end;}
  //tpo^.snaparray:=nil;
  //tpo^.format;
  result := tpo;
end;
procedure GDBObjSpline.SaveToDXF;
var
//    ptv:pgdbvertex;
    ir:itrec;
    fl:PGDBFloat;
    ptv:pgdbvertex;
begin
  SaveToDXFObjPrefix(outhandle,'SPLINE','AcDbSpline',IODXFContext);
  if closed then
                dxfGDBIntegerout(outhandle,70,9)
            else
                dxfGDBIntegerout(outhandle,70,8);
  dxfGDBIntegerout(outhandle,71,degree);
  dxfGDBIntegerout(outhandle,72,Knots.Count);
  dxfGDBIntegerout(outhandle,73,VertexArrayInOCS.Count);

  dxfGDBDoubleout(outhandle,42,0.0000000001);
  dxfGDBDoubleout(outhandle,43,0.0000000001);

  fl:=Knots.beginiterate(ir);
  if fl<>nil then
  repeat
        dxfGDBDoubleout(outhandle,40,fl^);
        fl:=Knots.iterate(ir);
  until fl=nil;

  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
  repeat
        dxfvertexout(outhandle,10,ptv^);
        ptv:=VertexArrayInOCS.iterate(ir);
  until ptv=nil;

end;

procedure GDBObjSpline.SaveToDXFfollow(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
begin
end;

procedure GDBObjSpline.LoadFromDXF;
var //s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  //p: gdbvertex;
  hlGDBWord: GDBinteger;
  //vertexgo: GDBBoolean;
  tv:gdbvertex;
  tr:gdbfloat;
begin
  closed := false;
  //vertexgo := false;

  //initnul(@gdb.ObjRoot);
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    //s:='';
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if dxfvertexload(f,10,byt,tv) then
                                         begin
                                              if byt=30 then
                                                            addvertex(tv);
                                         end
  else if dxfGDBFloatload(f,40,byt,tr) then
                                      begin
                                           Knots.PushBackData(tr);
                                      end
  else if dxfGDBIntegerload(f,70,byt,hlGDBWord) then
                                                   begin
                                                        if (hlGDBWord and 1) = 1 then closed := true;
                                                   end
  else if dxfGDBIntegerload(f,71,byt,Degree) then
                                                   begin
                                                        Degree:=Degree;
                                                   end

                                      else {s:= }f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
vertexarrayinocs.Shrink;
Knots.Shrink;
  //format;
end;
{procedure GDBObjPolyline.LoadFromDXF;
var s, layername: GDBString;
  byt, code: GDBInteger;
  p: gdbvertex;
  hlGDBWord: GDBLongword;
  vertexgo: GDBBoolean;
begin
  closed := false;
  vertexgo := false;
  s := f.readgdbstring;
  val(s, byt, code);
  while true do
  begin
    case byt of
      0:
        begin
          s := f.readgdbstring;
          if s = 'SEQEND' then
            system.break;
          if s = 'VERTEX' then vertexgo := true;
        end;
      8:
        begin
          layername := f.readgdbstring;
          vp.Layer := gdb.LayerTable.getLayeraddres(layername);
        end;
      10:
        begin
          s := f.readgdbstring;
          val(s, p.x, code);
        end;
      20:
        begin
          s := f.readgdbstring;
          val(s, p.y, code);
        end;
      30:
        begin
          s := f.readgdbstring;
          val(s, p.z, code);
          if vertexgo then addvertex(p);
        end;
      70:
        begin
          s := f.readgdbstring;
          val(s, hlGDBWord, code);
          hlGDBWord := strtoint(s);
          if (hlGDBWord and 1) = 1 then closed := true;
        end;
      370:
        begin
          s := f.readgdbstring;
          vp.lineweight := strtoint(s);
        end;
    else
      s := f.readgdbstring;
    end;
    s := f.readgdbstring;
    val(s, byt, code);
  end;
  vertexarrayinocs.Shrink;
end;}
function AllocSpline:PGDBObjSpline;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocSpline}',{$ENDIF}result,sizeof(GDBObjSpline));
end;
function AllocAndInitSpline(owner:PGDBObjGenericWithSubordinated):PGDBObjSpline;
begin
  result:=AllocSpline;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function GDBObjSpline.CreateInstance:PGDBObjSpline;
begin
  result:=AllocAndInitSpline(nil);
end;
begin
  RegisterDXFEntity(GDBSplineID,'SPLINE','Spline',@AllocSpline,@AllocAndInitSpline);
end.
