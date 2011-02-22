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

unit GDBCurve;
{$INCLUDE def.inc}

interface
uses UGDBOpenArrayOfPObjects,UGDBOpenArrayOfByte,UGDBLayerArray,gdbasetypes{,GDBGenericSubEntry},UGDBVectorSnapArray,UGDBSelectedObjArray,GDB3d,gdbEntity,UGDBPolyLine2DArray,UGDBPoint3DArray{,UGDBOpenArrayOfByte,varman},varmandef,
gl,
GDBase,geometry,UGDBDescriptor,gdbobjectsconstdef,oglwindowdef,math,dxflow,sysutils,memman{,OGLSpecFunc},GDBSubordinated;
type
{Export+}
PGDBObjCurve=^GDBObjCurve;
GDBObjCurve=object(GDBObj3d)
                 VertexArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 VertexArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 length:GDBDouble;
                 snaparray:GDBVectorSnapArray;(*hidden_in_objinsp*)
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure Format;virtual;
                 procedure FormatWithoutSnapArray;virtual;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                 function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;
                 procedure AddControlpoint(pcp:popenarrayobjcontrolpoint_GDBWordwm;objnum:GDBInteger);virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 procedure RenderFeedback;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;

                 destructor done;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure getoutbound;virtual;

                 procedure AddVertex(Vertex:GDBVertex);virtual;

                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 procedure feedbackinrect;virtual;

                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 procedure InsertVertex(const PolyData:TPolyData);
                 procedure DeleteVertex(const PolyData:TPolyData);
           end;
{Export-}
procedure BuildSnapArray(const VertexArrayInWCS:GDBPoint3dArray;var snaparray:GDBVectorSnapArray;const closed:GDBBoolean);
function GDBPoint3dArraygetsnap(const VertexArrayInWCS:GDBPoint3dArray; const PProjPoint:PGDBpolyline2DArray; const snaparray:GDBVectorSnapArray; var osp:os_record;const closed:GDBBoolean):GDBBoolean;
procedure GDBPoint3dArrayAddOnTrackAxis(const VertexArrayInWCS:GDBPoint3dArray;var posr:os_record;const processaxis:taddotrac;const closed:GDBBoolean);
implementation
uses
    log;
procedure GDBObjCurve.InsertVertex(const PolyData:TPolyData);
begin
     vertexarrayinocs.InsertElement(PolyData.nearestline,PolyData.dir,@PolyData.wc);
end;

procedure GDBObjCurve.DeleteVertex(const PolyData:TPolyData);
begin
     vertexarrayinocs.deleteelement(PolyData.nearestvertex);
end;
procedure GDBPoint3dArrayAddOnTrackAxis(const VertexArrayInWCS:GDBPoint3dArray;var posr:os_record;const processaxis:taddotrac;const closed:GDBBoolean);
var tv:gdbvertex;
    ptv,ppredtv:pgdbvertex;
    ir:itrec;
    found:integer;

begin
     if not closed then
                   begin
                        ppredtv:=VertexArrayInWCS.beginiterate(ir);
                        ptv:=VertexArrayInWCS.iterate(ir);
                   end
                else
                    begin
                           if VertexArrayInWCS.Count<3 then
                                                        exit;
                           ptv:=VertexArrayInWCS.beginiterate(ir);
                           ppredtv:=VertexArrayInWCS.getelement(VertexArrayInWCS.Count-1);
                    end;
  found:=0;
  if (ptv<>nil)and(ppredtv<>nil) then
  repeat
        if (abs(ptv^.x-posr.worldcoord.x)<eps)
       and (abs(ptv^.y-posr.worldcoord.y)<eps)
       and (abs(ptv^.z-posr.worldcoord.z)<eps)
                                             then
                                                 begin
                                                      found:=2;
                                                 end
   else if (found=0)and({distance2piece}SQRdist_Point_to_Segment(posr.worldcoord,ppredtv^,ptv^)<bigeps) then begin
                                                          found:=1;
                                                     end;

        if found>0 then
                       begin
                            tv:=vertexsub(ptv^,ppredtv^);
                            tv:=geometry.NormalizeVertex(tv);
                            //posr.arrayworldaxis.Add(@tv);
                            processaxis(posr,tv);
                            tv:=geometry.CrossVertex(tv,zwcs);
                            //posr.arrayworldaxis.Add(@tv);
                            processaxis(posr,tv);
                            dec(found);
                       end;

        ppredtv:=ptv;
        ptv:=VertexArrayInWCS.iterate(ir);
  until ptv=nil;
end;

procedure GDBObjCurve.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,false);
end;
function GDBObjCurve.CalcTrueInFrustum;
begin
      result:=VertexArrayInWCS.CalcTrueInFrustum(frustum);
end;
procedure GDBObjCurve.feedbackinrect;
begin
     //exit;
     if pprojpoint<>nil then
     if pprojpoint.inrect then
                              select;
end;
procedure GDBObjCurve.SaveToDXFFollow;
var
    ptv:pgdbvertex;
    ir:itrec;
begin
  ptv:=vertexarrayinocs.beginiterate(ir);
  if ptv<>nil then
  repeat
        SaveToDXFObjPrefix(handle,outhandle,'VERTEX','AcDbVertex');
        dxfGDBStringout(outhandle,100,'AcDb3dPolylineVertex');
        dxfvertexout(outhandle,10,ptv^);

        ptv:=vertexarrayinocs.iterate(ir);
  until ptv=nil;
  SaveToDXFObjPrefix(handle,outhandle,'SEQEND','');
end;
procedure GDBObjCurve.AddVertex(Vertex:GDBVertex);
begin
     vertexarrayinocs.add(@vertex);
end;

procedure GDBObjCurve.getoutbound;
var //tv,tv2:GDBVertex4D;
    t,b,l,r,n,f:GDBDouble;
    ptv:pgdbvertex;
    ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  n:=Infinity;
  r:=-Infinity;
  t:=-Infinity;
  f:=-Infinity;
  ptv:=VertexArrayInWCS.beginiterate(ir);
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
        ptv:=VertexArrayInWCS.iterate(ir);
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
function GDBObjCurve.GetObjTypeName;
begin
     result:=ObjN_GDBObjCurve;
end;
destructor GDBObjCurve.done;
begin
          if PProjPoint<>nil then
                            begin
                            PProjPoint^.{FreeAnd}Done;
                            GDBFreeMem(GDBPointer(PProjPoint));
                            end;
          VertexArrayInWCS.done;
          vertexarrayinocs.done;
          snaparray.done;
          inherited;
end;
constructor GDBObjCurve.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBPolylineID;
  VertexArrayInWCS.init({$IFDEF DEBUGBUILD}'{2C1E462A-ED22-4A83-8C88-B3AF70718E5A}',{$ENDIF}1000);
  vertexarrayinocs.init({$IFDEF DEBUGBUILD}'{3DBA1295-54F6-45D1-984C-2C51A585C5C9}',{$ENDIF}1000);
  snaparray.init({$IFDEF DEBUGBUILD}'{13C74F96-05DB-4025-93B1-9599B31912CC}',{$ENDIF}100);
  PProjPoint:=nil;
  //Format;
end;
constructor GDBObjCurve.initnul;
begin
  inherited initnul(nil);
  bp.ListPos.Owner:=owner;
  vp.ID := GDBPolylineID;
  VertexArrayInWCS.init({$IFDEF DEBUGBUILD}'{6662A71B-9321-472D-B3C3-3EBFCA8D610A}',{$ENDIF}1000);
  vertexarrayinocs.init({$IFDEF DEBUGBUILD}'{3DBA1295-54F6-45D1-984C-2C51A585C5C9}',{$ENDIF}1000);
  snaparray.init({$IFDEF DEBUGBUILD}'{0BAF650E-84F9-4851-AC85-53345427B4BE}',{$ENDIF}100);
  PProjPoint:=nil;
end;
procedure GDBObjCurve.DrawGeometry;
begin
  inherited;
  VertexArrayInWCS.DrawGeometry;
  {myglbegin(GL_line_strip);
  VertexArrayInWCS.iterategl(@glVertex3dv);
  myglend;}
end;
procedure GDBObjCurve.AddControlpoint;
var i: GDBInteger;
  p: pgdbvertex;
begin
  if (pcp^.max - pcp^.count) >=VertexArrayInWCS.Count then
  begin
    p := VertexArrayInWCS.PArray;
    for i := 0 to VertexArrayInWCS.Count - 1 do
    begin
        pcp^.arraycp[pcp^.count].objnum := objnum;
        pcp^.arraycp[pcp^.count].ostype := os_polymin-i;
        pcp^.arraycp[pcp^.count].worldcoord := p^;;
        inc(p);
        pcp^.arraycp[pcp^.count].selected := false;
        inc(pcp^.count);
    end;
  end
end;
function GDBObjCurve.getosnappoint;
var ptv: pgdbvertex;
    pvsa:PVectotSnap;
    vertexnum,temp,mode:GDBInteger;
begin
  if (ostype<=os_polymin) and (ostype>=os_polymax) then
  begin
    temp:=round(os_polymin-ostype);
    mode:= temp mod 6;
    vertexnum:= (temp div 6);
    {pvsa:=GDBPointer(self.snaparray);
    inc(pvsa,vertexnum);}
    pvsa:=snaparray.getelement(vertexnum);
    ptv:=VertexArrayInWCS.PArray;
    inc(ptv,vertexnum);
    case mode of
                0:
                  result:=ptv^;
                1:
                  result:=pvsa^.l_1_4;
                2:
                  result:=pvsa^.l_1_3;
                3:
                  result:=pvsa^.l_1_2;
                4:
                  result:=pvsa^.l_2_3;
                5:
                  result:=pvsa^.l_3_4;
              end;


  end;
end;
procedure BuildSnapArray(const VertexArrayInWCS:GDBPoint3dArray;var snaparray:GDBVectorSnapArray;const closed:GDBBoolean);
var
    ptv,ptvprev: pgdbvertex;
    tv:gdbvertex;
    vs:VectorSnap;
        ir:itrec;
begin
  snaparray.clear;
  ptvprev:=VertexArrayInWCS.beginiterate(ir);
  ptv:=VertexArrayInWCS.iterate(ir);
  if ptv<>nil then
  repeat
        vs.l_1_4:=vertexmorph(ptvprev^,ptv^,1/4);
        vs.l_1_3:=vertexmorph(ptvprev^,ptv^,1/3);
        vs.l_1_2:=vertexmorph(ptvprev^,ptv^,1/2);
        vs.l_2_3:=vertexmorph(ptvprev^,ptv^,2/3);
        vs.l_3_4:=vertexmorph(ptvprev^,ptv^,3/4);
        snaparray.add(@vs);
        ptvprev:=ptv;
        ptv:=VertexArrayInWCS.iterate(ir);
  until ptv=nil;
  if closed then
  begin
  ptv:=VertexArrayInWCS.beginiterate(ir);
  vs.l_1_4:=vertexmorph(ptvprev^,ptv^,1/4);
  vs.l_1_3:=vertexmorph(ptvprev^,ptv^,1/3);
  vs.l_1_2:=vertexmorph(ptvprev^,ptv^,1/2);
  vs.l_2_3:=vertexmorph(ptvprev^,ptv^,2/3);
  vs.l_3_4:=vertexmorph(ptvprev^,ptv^,3/4);
  snaparray.add(@vs);
  end;




  snaparray.Shrink;
end;
procedure GDBObjCurve.FormatWithoutSnapArray;
var //i,j: GDBInteger;
    ptv,ptvprev: pgdbvertex;
    tv:gdbvertex;
    vs:VectorSnap;
        ir:itrec;
begin
  //snaparray.clear;
  length:=0;
  VertexArrayInWCS.clear;
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
  repeat
        tv:=VectorTransform3D(ptv^,bp.ListPos.owner^.GetMatrix^);
        VertexArrayInWCS.Add(@tv);
        ptv:=vertexarrayinocs.iterate(ir);
  until ptv=nil;

  ptvprev:=VertexArrayInWCS.beginiterate(ir);
  ptv:=VertexArrayInWCS.iterate(ir);
  if ptv<>nil then
  repeat
        length:=length+geometry.Vertexlength(ptv^,ptvprev^);
        ptvprev:=ptv;
        ptv:=VertexArrayInWCS.iterate(ir);
  until ptv=nil;
  calcbb;
  VertexArrayInOCS.Shrink;
  VertexArrayInWCS.Shrink;
end;

procedure GDBObjCurve.Format;
var //i,j: GDBInteger;
    ptv,ptvprev: pgdbvertex;
    tv:gdbvertex;
    vs:VectorSnap;
        ir:itrec;
begin
  FormatWithoutSnapArray;
  BuildSnapArray(VertexArrayInWCS,snaparray,false);
end;

procedure GDBObjCurve.TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);
var
    ptv,ptv2: pgdbvertex;
    ir,ir2:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  ptv2:=PGDBObjCurve(p)^.VertexArrayInOCS.beginiterate(ir2);
  if (ptv<>nil)and(ptv2<>nil) then
  repeat
        ptv^:=VectorTransform3D(ptv2^,t_matrix^);
        {VertexArrayInWCS.Add(@tv);}
        ptv:=vertexarrayinocs.iterate(ir);
        ptv2:=PGDBObjCurve(p)^.VertexArrayInOCS.iterate(ir2);
  until (ptv=nil)or(ptv2=nil);
end;
procedure GDBObjCurve.transform(const t_matrix:DMatrix4D);
var
    ptv: pgdbvertex;
    ir:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if (ptv<>nil) then
  repeat
        ptv^:=VectorTransform3D(ptv^,t_matrix);
        {VertexArrayInWCS.Add(@tv);}
        ptv:=vertexarrayinocs.iterate(ir);
  until (ptv=nil);
end;
function GDBObjCurve.Clone;
var tpo: PGDBObjCurve;
    p:pgdbvertex;
    i:GDBInteger;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{8F88CAFB-14F3-4F33-96B5-F493DB8B28B7}',{$ENDIF}GDBPointer(tpo), sizeof(GDBObjCurve));
  tpo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  //tpo^.vertexarrayinocs.init({$IFDEF DEBUGBUILD}'{90423E18-2ABF-48A8-8E0E-5D08A9E54255}',{$ENDIF}1000);
  p:=vertexarrayinocs.PArray;
  for i:=0 to VertexArrayInWCS.Count-1 do
  begin
      tpo^.vertexarrayinocs.add(p);
      inc(p)
  end;
  //tpo^.snaparray:=nil;
  tpo^.format;
  result := tpo;
end;
procedure GDBObjCurve.rtedit;
var p,pold:pgdbvertex;
    i:GDBInteger;
begin
  if mode <= os_polymin then
  begin
  i:=round(os_polymin-mode);
  p:=vertexarrayinocs.PArray;
  pold:=pgdbobjcurve(refp)^.vertexarrayinocs.PArray;
  inc(p,i);
  inc(pold,i);
  p^ := VertexAdd(pold^, dist);
  format;
  end;
end;
procedure GDBObjCurve.rtsave;
var p,pold:pgdbvertex;
    i:GDBInteger;
begin
  p:=vertexarrayinocs.PArray;
  pold:=pgdbobjcurve(refp)^.vertexarrayinocs.PArray;
  for i:=0 to vertexarrayinocs.Count-1 do
  begin
      pold^:=p^;
      inc(pold);
      inc(p);
  end;
  pgdbobjcurve(refp)^.format;
end;
procedure GDBObjCurve.Renderfeedback;
var tv:GDBvertex;
    tpv:GDBVertex2D;
    ptpv:PGDBVertex;
    i:GDBInteger;
begin
  if pprojpoint=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{59A49074-4B98-46F2-AE7E-27F1C520CEE2}',{$ENDIF}GDBPointer(pprojpoint),sizeof(GDBpolyline2DArray));
       pprojpoint^.init({$IFDEF DEBUGBUILD}'{C2BA8485-D361-4FB7-9EA1-74CEE160AE8F}',{$ENDIF}VertexArrayInWCS.count,false);
  end;
  pprojpoint^.clear;
{                    if pprojpoint<>nil then
                     begin
                          pprojpoint^.done;
                          GDBFreeMem(pprojpoint);
                     end;
                    GDBGetMem(PprojPoint,sizeof(GDBpolyline2DArray));
                    PprojPoint^.init(vertexarray.count,closed);}
                    ptpv:=VertexArrayInWCS.parray;
                    for i:=0 to VertexArrayInWCS.count-1 do
                    begin
                         gdb.GetCurrentDWG^.myGluProject2(ptpv^,tv);
                         tpv.x:=tv.x;
                         tpv.y:=tv.y;
                         PprojPoint^.add(@tpv);
                         inc(ptpv);
                    end;

end;
function GDBObjCurve.onmouse;
begin
  if VertexArrayInWCS.count<2 then
                                  begin
                                       result:=false;
                                       exit;
                                  end;
   result:=VertexArrayInWCS.onmouse(mf,false);
end;
function GDBObjCurve.onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;
begin
     if VertexArrayInWCS.onpoint(point,false) then
                                                begin
                                                     result:=true;
                                                     objects.AddRef(self);
                                                end
                                            else
                                                result:=false;
end;

procedure GDBObjCurve.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:GDBInteger;
begin
     vertexnumber:=abs(rtmod.point.pointtype-os_polymin);
     //pdesc.worldcoord:=PGDBArrayVertex(vertexarray.parray)^[vertexnumber];
     //pdesc.dispcoord.x:=round(PGDBArrayVertex2D(PProjPoint.parray)^[vertexnumber].x);
     //pdesc.dispcoord.y:=round(poglwnd^.height-PGDBArrayVertex2D(PProjPoint.parray)^[vertexnumber].y);

     PGDBArrayVertex(vertexarrayinocs.parray)^[vertexnumber]:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
end;
procedure GDBObjCurve.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:GDBInteger;
begin
     vertexnumber:=abs(pdesc^.pointtype-os_polymin);
     pdesc.worldcoord:=PGDBArrayVertex(VertexArrayInWCS.parray)^[vertexnumber];
     pdesc.dispcoord.x:=round(PGDBArrayVertex2D(PProjPoint.parray)^[vertexnumber].x);
     pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.height-PGDBArrayVertex2D(PProjPoint.parray)^[vertexnumber].y);
end;
procedure GDBObjCurve.addcontrolpoints;
var pdesc:controlpointdesc;
    i:GDBInteger;
    pv2d:pGDBvertex2d;
    pv:pGDBvertex;
begin
          renderfeedback;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{48F91543-AAA8-4CF7-A038-D3DDC248BE3E}',{$ENDIF}pprojpoint.count);
          pv2d:=pprojpoint^.parray;
          pv:=VertexArrayInWCS.parray;
          for i:=0 to pprojpoint.count-1 do
          begin
               pdesc.selected:=false;
               pdesc.pointtype:=os_polymin-i;
               pdesc.worldcoord:=pv^;
               pdesc.dispcoord.x:=round(pv2d^.x);
               pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.height-pv2d.y);
               PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
               inc(pv);
               inc(pv2d);
          end;
end;
(*
procedure GDBObjPolyline.Renderfeedback;
var tv:GDBvertex;
    tpv:GDBVertex2D;
    ptpv:PGDBVertex;
    i:GDBInteger;
begin
  if pprojpoint=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{59A49074-4B98-46F2-AE7E-27F1C520CEE2}',{$ENDIF}GDBPointer(pprojpoint),sizeof(GDBpolyline2DArray));
       pprojpoint^.init({$IFDEF DEBUGBUILD}'{C2BA8485-D361-4FB7-9EA1-74CEE160AE8F}',{$ENDIF}vertexarray.count,closed);
  end;
  pprojpoint^.clear;
{                    if pprojpoint<>nil then
                     begin
                          pprojpoint^.done;
                          GDBFreeMem(pprojpoint);
                     end;
                    GDBGetMem(PprojPoint,sizeof(GDBpolyline2DArray));
                    PprojPoint^.init(vertexarray.count,closed);}
                    ptpv:=vertexarray.parray;
                    for i:=0 to vertexarray.count-1 do
                    begin
                         myGluProject(ptpv^.x,ptpv^.y,ptpv^.z,@gdb.GetCurrentDWG.pcamera^.modelMatrix,@gdb.GetCurrentDWG.pcamera^.projMatrix,@gdb.GetCurrentDWG.pcamera^.viewport,tv.x,tv.y,tv.z);
                         tpv.x:=tv.x;
                         tpv.y:=tv.y;
                         PprojPoint^.add(@tpv);
                         inc(ptpv);
                    end;

end;
*)
function GDBPoint3dArraygetsnap(const VertexArrayInWCS:GDBPoint3dArray; const PProjPoint:PGDBpolyline2DArray; const snaparray:GDBVectorSnapArray; var osp:os_record;const closed:GDBBoolean):GDBBoolean;
const pnum=8;
var t,d,e:GDBDouble;
    tv,n,v,dir:gdbvertex;
    mode,vertexnum,tc:GDBInteger;
    pv1:PGDBVertex;
    pv2:PGDBVertex;

begin
     vertexnum:=(VertexArrayInWCS.count)*pnum;
     {if not closed then
                       vertexnum:=vertexnum-pnum;}
     if onlygetsnapcount>vertexnum then
     begin
          result:=false;
          exit;
     end;
     tc:=VertexArrayInWCS.count;
     if not closed then tc:=tc-1;
     result:=true;
     mode:=onlygetsnapcount mod pnum;
     vertexnum:=onlygetsnapcount div pnum;
     osp.ostype:=os_none;
     case mode of
              0:if (sysvar.dwg.DWG_OSMode^ and osm_endpoint)<>0
                then
                begin
                osp.worldcoord:=PGDBArrayVertex(VertexArrayInWCS.parray)^[vertexnum];
                pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_begin;
                end;
             1:begin
                if ((sysvar.dwg.DWG_OSMode^ and osm_4)<>0)and(vertexnum<>tc)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_4;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_1_4;
                end;
               end;
             2:begin
                if ((sysvar.dwg.DWG_OSMode^ and osm_3)<>0)and(vertexnum<>tc)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_3;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_1_3;
                end;
               end;
              3:if ((sysvar.dwg.DWG_OSMode^ and osm_midpoint)<>0)and(vertexnum<>tc)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_2;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_midle;
                end;
             4:begin
                if ((sysvar.dwg.DWG_OSMode^ and osm_3)<>0)and(vertexnum<>tc)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_2_3;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_2_3;
                end;
               end;
             5:begin
                if ((sysvar.dwg.DWG_OSMode^ and osm_4)<>0)and(vertexnum<>tc)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_3_4;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_3_4;
                end;
               end;
             6:begin
                    if ((sysvar.dwg.DWG_OSMode^ and osm_perpendicular)<>0)then
                    if ((vertexnum<(tc))){or((vertexnum=tc-1)and closed)}then
                    begin
                        pv1:=VertexArrayInWCS.getelement(vertexnum);
                        if vertexnum<VertexArrayInWCS.count-1 then
                                              pv2:=VertexArrayInWCS.getelement(vertexnum+1)
                                          else
                                          begin
                                               if not closed then
                                                                 exit;
                                               pv2:=VertexArrayInWCS.getelement(0);
                                          end;
                        dir:=geometry.VertexSub(pv2^,pv1^);
                        tv:=vectordot(dir,GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir);
                        t:= -((pv1.x-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.x)*dir.x+(pv1.y-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.y)*dir.y+(pv1.z-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.z)*dir.z)/
                             ({sqr(dir.x)+sqr(dir.y)+sqr(dir.z)}SqrVertexlength(pv2^,pv1^));
                        if (t>=0) and (t<=1)
                        then
                        begin
                              osp.worldcoord.x:=pv1^.x+t*dir.x;
                              osp.worldcoord.y:=pv1^.y+t*dir.y;
                              osp.worldcoord.z:=pv1^.z+t*dir.z;
                              gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,tv);
                              osp.dispcoord:=tv;
                              osp.ostype:=os_perpendicular;
                        end
                           else osp.ostype:=os_none;
                    end;
               end;
     7:begin
            if ((sysvar.dwg.DWG_OSMode^ and osm_nearest)<>0) then
            if ((vertexnum<(tc)))then
            begin
                        pv1:=VertexArrayInWCS.getelement(vertexnum);
                        if vertexnum<VertexArrayInWCS.count-1 then
                                              pv2:=VertexArrayInWCS.getelement(vertexnum+1)
                                          else
                                          begin
                                               if not closed then
                                                                 exit;
                                               pv2:=VertexArrayInWCS.getelement(0);
                                          end;
            dir:=geometry.VertexSub(pv2^,pv1^);
            tv:=vectordot(dir,GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir);
            n:=vectordot(GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir,tv);
            n:=NormalizeVertex(n);
            v.x:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.x-pv1^.x;
            v.y:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.y-pv1^.y;
            v.z:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.z-pv1^.z;
            d:=scalardot(n,v);
            e:=scalardot(n,dir);
            if e<eps then osp.ostype:=os_none
                     else
                         begin
                              if d<eps then osp.ostype:=os_none
                                       else
                                           begin
                                                t:=d/e;
                                                if (t>1)or(t<0)then osp.ostype:=os_none
                                                else
                                                begin
                                                      osp.worldcoord.x:=pv1^.x+t*dir.x;
                                                      osp.worldcoord.y:=pv1^.y+t*dir.y;
                                                      osp.worldcoord.z:=pv1^.z+t*dir.z;
                                                      gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,tv);
                                                      osp.dispcoord:=tv;
                                                      osp.ostype:=os_nearest;
                                               end;
                                           end;

                         end;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;

function GDBObjCurve.getsnap;
const pnum=8;
var t,d,e:GDBDouble;
    tv,n,v,dir:gdbvertex;
    mode,vertexnum:GDBInteger;
    pv1:PGDBVertex;
    pv2:PGDBVertex;
begin
     result:=GDBPoint3dArraygetsnap(VertexArrayInWCS,PProjPoint,snaparray,osp,false);
(*
     if onlygetsnapcount=VertexArrayInWCS.count*pnum then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     mode:=onlygetsnapcount mod pnum;
     vertexnum:=onlygetsnapcount div pnum;
     case mode of
              0:if (sysvar.dwg.DWG_OSMode^ and osm_endpoint)<>0
                then
                begin
                osp.worldcoord:=PGDBArrayVertex(VertexArrayInWCS.parray)^[vertexnum];
                pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_begin;
                end
                else osp.ostype:=os_none;
             1:begin
                if (sysvar.dwg.DWG_OSMode^ and osm_4)<>0
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_4;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_1_4;
                end
                else osp.ostype:=os_none;
               end;
             2:begin
                if (sysvar.dwg.DWG_OSMode^ and osm_3)<>0
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_3;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_1_3;
                end
                else osp.ostype:=os_none;
               end;
              3:if (sysvar.dwg.DWG_OSMode^ and osm_midpoint)<>0
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_1_2;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_midle;
                end
                else osp.ostype:=os_none;
             4:begin
                if (sysvar.dwg.DWG_OSMode^ and osm_3)<>0
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_2_3;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_2_3;
                end
                else osp.ostype:=os_none;
               end;
             5:begin
                if ((sysvar.dwg.DWG_OSMode^ and osm_4)<>0)
                then
                begin
                ///PVectotSnap(snaparray.getelement(vertexnum))^
                osp.worldcoord:=PVectotSnap(snaparray.getelement(vertexnum))^.l_3_4;// PGDBArrayVertex(vertexarray.parray)^[vertexnum];
                gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,osp.dispcoord);
                //pgdbvertex2d(@osp.dispcoord)^:=PGDBArrayVertex2D(PProjPoint.parray)^[vertexnum];
                osp.ostype:=os_3_4;
                end
                else osp.ostype:=os_none;
               end;
             6:begin
                    if ((sysvar.dwg.DWG_OSMode^ and osm_perpendicular)<>0)and(vertexnum<(VertexArrayInWCS.count-1))
                    then
                    begin
                    pv1:=VertexArrayInWCS.getelement(vertexnum);
                    pv2:=VertexArrayInWCS.getelement(vertexnum+1);
                    dir:=geometry.VertexSub(pv2^,pv1^);
                    tv:=vectordot(dir,GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir);
                    t:= -((pv1.x-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.x)*dir.x+(pv1.y-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.y)*dir.y+(pv1.z-GDB.GetCurrentDWG.OGLwindow1.param.lastpoint.z)*dir.z)/
                         ({sqr(dir.x)+sqr(dir.y)+sqr(dir.z)}SqrVertexlength(pv2^,pv1^));
                    if (t>=0) and (t<=1)
                    then
                    begin
                    osp.worldcoord.x:=pv1^.x+t*dir.x;
                    osp.worldcoord.y:=pv1^.y+t*dir.y;
                    osp.worldcoord.z:=pv1^.z+t*dir.z;
                    gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,tv);
                    osp.dispcoord:=tv;
                    osp.ostype:=os_perpendicular;
                    end
                    else osp.ostype:=os_none;
                    end
                    else osp.ostype:=os_none;
               end;
     7:begin
            if ((sysvar.dwg.DWG_OSMode^ and osm_nearest)<>0)and(vertexnum<(VertexArrayInWCS.count-1))
            then
            begin
            pv1:=VertexArrayInWCS.getelement(vertexnum);
            pv2:=VertexArrayInWCS.getelement(vertexnum+1);
            dir:=geometry.VertexSub(pv2^,pv1^);
            tv:=vectordot(dir,GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir);
            n:=vectordot(GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.dir,tv);
            n:=NormalizeVertex(n);
            v.x:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.x-pv1^.x;
            v.y:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.y-pv1^.y;
            v.z:=GDB.GetCurrentDWG.OGLwindow1.param.md.mouseray.lbegin.z-pv1^.z;
            d:=scalardot(n,v);
            e:=scalardot(n,dir);
            if e<eps then osp.ostype:=os_none
                     else
                         begin
                              if d<eps then osp.ostype:=os_none
                                       else
                                           begin
                                                t:=d/e;
                                                if (t>1)or(t<0)then osp.ostype:=os_none
                                                else
                                                begin
                                                      osp.worldcoord.x:=pv1^.x+t*dir.x;
                                                      osp.worldcoord.y:=pv1^.y+t*dir.y;
                                                      osp.worldcoord.z:=pv1^.z+t*dir.z;
                                                      gdb.GetCurrentDWG^.myGluProject2(osp.worldcoord,tv);
                                                      osp.dispcoord:=tv;
                                                      osp.ostype:=os_nearest;
                                               end;
                                           end;

                         end;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
*)
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCurve.initialization');{$ENDIF}
end.
