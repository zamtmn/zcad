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

unit gdbspline;
{$INCLUDE def.inc}

interface
uses UGDBPoint3DArray,UGDBDrawingdef,GDBCamera,UGDBVectorSnapArray,UGDBOpenArrayOfPObjects,UGDBLayerArray,GDBSubordinated,GDBCurve,gdbasetypes{,GDBGenericSubEntry,UGDBVectorSnapArray,UGDBSelectedObjArray,GDB3d},GDBEntity{,UGDBPolyLine2DArray,UGDBPoint3DArray},UGDBOpenArrayOfByte,varman{,varmandef},
ugdbltypearray,
GDBase,gdbobjectsconstdef,oglwindowdef,geometry,dxflow,sysutils,memman{,OGLSpecFunc};
type
{Export+}
PGDBObjSpline=^GDBObjSpline;
GDBObjSpline=object(GDBObjCurve)
                 ControlArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 ControlArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit;const drawing:TDrawingDef);virtual;

                 procedure FormatEntity(const drawing:TDrawingDef);virtual;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;

                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function FromDXFPostProcessBeforeAdd(ptu:PTUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;

           end;
{Export-}
implementation
uses GDBCable,log;
procedure GDBObjSpline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,closed);
end;
function GDBObjSpline.onmouse;
begin
  if VertexArrayInWCS.count<2 then
                                  begin
                                       result:=false;
                                       exit;
                                  end;
   result:=VertexArrayInWCS.onmouse(mf,closed);
end;
function GDBObjSpline.onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;
begin
     if VertexArrayInWCS.onpoint(point,closed) then
                                                begin
                                                     result:=true;
                                                     objects.AddRef(self);
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
     result:=GDBPoint3dArraygetsnap(VertexArrayInWCS,PProjPoint,{snaparray}PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc);
end;
procedure GDBObjSpline.FormatEntity(const drawing:TDrawingDef);
var //i,j: GDBInteger;
    ptv,ptvprev,ptvfisrt: pgdbvertex;
    //tv:gdbvertex;
    //vs:VectorSnap;
        ir:itrec;
begin
  FormatWithoutSnapArray;
  //-------------BuildSnapArray(VertexArrayInWCS,snaparray,Closed);
  Geom.Clear;
  if VertexArrayInWCS.Count>1 then
  begin
  ptv:=VertexArrayInWCS.beginiterate(ir);
  ptvfisrt:=ptv;
  if ptv<>nil then
  repeat
        ptvprev:=ptv;
        ptv:=VertexArrayInWCS.iterate(ir);
        if ptv<>nil then
                        Geom.DrawLine(ptv^,ptvprev^,vp);
  until ptv=nil;
  if closed then
                Geom.DrawLine(ptvprev^,ptvfisrt^,vp);
  end;
end;

function GDBObjSpline.FromDXFPostProcessBeforeAdd;
var
    //isdevice:GDBBoolean;
    tc:PGDBObjCable;
    ptv:pgdbvertex;
    ir:itrec;
begin
     result:=nil;
     //isdevice:=false;
     if self.PExtAttrib<>nil then
     if self.PExtAttrib^.Upgrade>0 then
     begin
          GDBGetMem({$IFDEF DEBUGBUILD}'{4C837C43-E018-4307-ADC2-DEB5134AF6D8}',{$ENDIF}GDBPointer(tc),sizeof(GDBObjCable));
          result:=tc;
          Tc^.initnul(pointer(bp.ListPos.owner));
{БЛЯДЬ так делать нельзя!!!!}          if PExtAttrib<>nil then
                                                              begin
                                                                   Tc^.PExtAttrib:=PExtAttrib;
                                                                   PExtAttrib:=nil;
                                                              end;
          tc^.vp:=vp;
          tc^.vp.ID:=GDBCableID;



  ptv:=vertexarrayinocs.beginiterate(ir);
  if ptv<>nil then
  repeat
        tc.AddVertex(ptv^);
        ptv:=vertexarrayinocs.iterate(ir);
  until ptv=nil;
     end;
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
  ControlArrayInOCS.init({$IFDEF DEBUGBUILD}'{A50FF064-FCF0-4A6C-B012-002C7A7BA6F0}',{$ENDIF}1000);
  vp.ID := GDBSplineID;
end;
constructor GDBObjSpline.initnul;
begin
  inherited initnul(owner);
  ControlArrayInWCS.init({$IFDEF DEBUGBUILD}'{4213E1EA-8FF1-4E99-AEF5-C1635CB49B5A}',{$ENDIF}1000);
  ControlArrayInOCS.init({$IFDEF DEBUGBUILD}'{A50FF064-FCF0-4A6C-B012-002C7A7BA6F0}',{$ENDIF}1000);
  vp.ID := GDBSplineID;
end;

procedure GDBObjSpline.DrawGeometry;
begin
     //vertexarrayInWCS.DrawGeometryWClosed(closed);
     self.Geom.DrawGeometry;
{  if closed then oglsm.myglbegin(GL_line_loop)
            else oglsm.myglbegin(GL_line_strip);
  vertexarrayInWCS.iterategl(@myglVertex3dv);
  oglsm.myglend;}
end;
function GDBObjSpline.Clone;
var tpo: PGDBObjSpline;
    p:pgdbvertex;
    i:GDBInteger;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{8F88CAFB-14F3-4F33-96B5-F493DB8B28B7}',{$ENDIF}GDBPointer(tpo), sizeof(GDBObjSpline));
  tpo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  //tpo^.vertexarray.init({$IFDEF DEBUGBUILD}'{90423E18-2ABF-48A8-8E0E-5D08A9E54255}',{$ENDIF}1000);
  p:=vertexarrayinocs.PArray;
  for i:=0 to vertexarrayinocs.Count-1 do
  begin
      tpo^.vertexarrayinocs.add(p);
      inc(p)
  end;
  //tpo^.snaparray:=nil;
  //tpo^.format;
  result := tpo;
end;
procedure GDBObjSpline.SaveToDXF;
//var
//    ptv:pgdbvertex;
//    ir:itrec;
begin
  SaveToDXFObjPrefix(handle,outhandle,'POLYLINE','AcDb3dPolyline');
  dxfGDBIntegerout(outhandle,66,1);
  dxfvertexout(outhandle,10,geometry.NulVertex);
  if closed then
                dxfGDBIntegerout(outhandle,70,9)
            else
                dxfGDBIntegerout(outhandle,70,8);
end;
procedure GDBObjSpline.LoadFromDXF;
var s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  //p: gdbvertex;
  hlGDBWord: GDBinteger;
  vertexgo: GDBBoolean;
  tv:gdbvertex;
begin
  closed := false;
  vertexgo := false;

  //initnul(@gdb.ObjRoot);
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    s:='';
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if dxfvertexload(f,10,byt,tv) then
                                         begin
                                              if byt=30 then
                                                            addvertex(tv);
                                         end
  else if dxfvertexload(f,11,byt,tv) then
                                      begin
                                           if byt=31 then
                                                         Controlarrayinocs.add(@tv);;
                                      end

  else if dxfGDBIntegerload(f,70,byt,hlGDBWord) then
                                                   begin
                                                        if (hlGDBWord and 1) = 1 then closed := true;
                                                   end
                                      else s:= f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
vertexarrayinocs.Shrink;
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
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBPolyline.initialization');{$ENDIF}
end.