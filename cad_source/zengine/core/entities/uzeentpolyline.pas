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

unit uzeentpolyline;
{$INCLUDE def.inc}

interface
uses uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
     gzctnrvectorpobjects,uzestyleslayers,uzeentsubordinated,uzeentcurve,uzbtypesbase,
     uzeentity,UGDBOpenArrayOfByte,uzbtypes,uzeconsts,uzglviewareadata,
     uzbgeomtypes,uzegeometry,uzeffdxfsupport,sysutils,uzbmemman;
type
{Export+}
PGDBObjPolyline=^GDBObjPolyline;
{REGISTEROBJECTTYPE GDBObjPolyline}
GDBObjPolyline= object(GDBObjCurve)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;

                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function GetLength:GDBDouble;virtual;

                 class function CreateInstance:PGDBObjPolyline;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
implementation
//uses log;
function GDBObjPolyline.GetLength:GDBDouble;
var
   ptpv0,ptpv1:PGDBVertex;
begin
  result:=inherited;
  if closed then
  begin
       ptpv0:=VertexArrayInWCS.GetParrayAsPointer;
       ptpv1:=VertexArrayInWCS.getDataMutable(VertexArrayInWCS.Count-1);
       result:=result+uzegeometry.Vertexlength(ptpv0^,ptpv1^);
  end;
end;
procedure GDBObjPolyline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,closed);
end;
function GDBObjPolyline.onmouse;
begin
  if VertexArrayInWCS.count<2 then
                                  begin
                                       result:=false;
                                       exit;
                                  end;
   result:=VertexArrayInWCS.onmouse(mf,closed);
end;
function GDBObjPolyline.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
begin
     if VertexArrayInWCS.onpoint(point,closed) then
                                                begin
                                                     result:=true;
                                                     objects.PushBackData(@self);
                                                end
                                            else
                                                result:=false;
end;
procedure GDBObjPolyline.startsnap(out osp:os_record; out pdata:GDBPointer);
begin
     GDBObjEntity.startsnap(osp,pdata);
     gdbgetmem({$IFDEF DEBUGBUILD}'{C37BA022-4629-4E16-BEB6-E8AAB9AC6986}',{$ENDIF}pdata,sizeof(GDBVectorSnapArray));
     PGDBVectorSnapArray(pdata).init({$IFDEF DEBUGBUILD}'{C37BA022-4629-4E16-BEB6-E8AAB9AC6986}',{$ENDIF}VertexArrayInWCS.Max);
     BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,closed);
end;
function GDBObjPolyline.getsnap;
begin
     result:=GDBPoint3dArraygetsnap(VertexArrayInWCS,PProjPoint,{snaparray}PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;
procedure GDBObjPolyline.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  FormatWithoutSnapArray;
  calcbb(dc);
  //-------------BuildSnapArray(VertexArrayInWCS,snaparray,Closed);
  Representation.Clear;
  if VertexArrayInWCS.Count>1 then
  begin
  {ptv:=VertexArrayInWCS.beginiterate(ir);
  ptvfisrt:=ptv;
  if ptv<>nil then
  repeat
        ptvprev:=ptv;
        ptv:=VertexArrayInWCS.iterate(ir);
        if ptv<>nil then
                        Representation.DrawLineWithLT(ptv^,ptvprev^,vp);
  until ptv=nil;
  if closed then
                Representation.DrawLineWithLT(ptvprev^,ptvfisrt^,vp);
  end;}
  Representation.DrawPolyLineWithLT(dc,VertexArrayInWCS,vp,closed,false);
  end;

  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjPolyline.GetObjTypeName;
begin
     result:=ObjN_GDBObjPolyLine;
end;
constructor GDBObjPolyline.init;
begin
  //vp.ID := GDBPolylineID;
  closed := c;
  inherited init(own,layeraddres, lw);
end;
constructor GDBObjPolyline.initnul;
begin
  inherited initnul(owner);
  //vp.ID := GDBPolylineID;
end;
function GDBObjPolyline.GetObjType;
begin
     result:=GDBPolylineID;
end;
procedure GDBObjPolyline.DrawGeometry;
begin
     //vertexarrayInWCS.DrawGeometryWClosed(closed);
     self.Representation.DrawGeometry(DC);
{  if closed then oglsm.myglbegin(GL_line_loop)
            else oglsm.myglbegin(GL_line_strip);
  vertexarrayInWCS.iterategl(@myglVertex3dv);
  oglsm.myglend;}
  //inherited;
end;
function GDBObjPolyline.Clone;
var tpo: PGDBObjPolyLine;
    p:pgdbvertex;
    i:GDBInteger;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{8F88CAFB-14F3-4F33-96B5-F493DB8B28B7}',{$ENDIF}GDBPointer(tpo), sizeof(GDBObjPolyline));
  tpo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  //tpo^.vertexarray.init({$IFDEF DEBUGBUILD}'{90423E18-2ABF-48A8-8E0E-5D08A9E54255}',{$ENDIF}1000);
  p:=vertexarrayinocs.GetParrayAsPointer;
  for i:=0 to vertexarrayinocs.Count-1 do
  begin
      tpo^.vertexarrayinocs.PushBackData(p^);
      inc(p)
  end;
  //tpo^.snaparray:=nil;
  //tpo^.format;
  result := tpo;
end;
procedure GDBObjPolyline.SaveToDXF;
//var
//    ptv:pgdbvertex;
//    ir:itrec;
begin
  SaveToDXFObjPrefix(outhandle,'POLYLINE','AcDb3dPolyline',IODXFContext);
  dxfGDBIntegerout(outhandle,66,1);
  dxfvertexout(outhandle,10,uzegeometry.NulVertex);
  if closed then
                dxfGDBIntegerout(outhandle,70,9)
            else
                dxfGDBIntegerout(outhandle,70,8);
end;
procedure GDBObjPolyline.LoadFromDXF;
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
  while true do
  begin
    s:='';
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if dxfvertexload(f,10,byt,tv) then
                                         begin
                                              if byt=30 then
                                                            if vertexgo then
                                                                            addvertex(tv);
                                         end
  else if dxfGDBIntegerload(f,70,byt,hlGDBWord) then
                                                   begin
                                                        if (hlGDBWord and 1) = 1 then closed := true;
                                                   end
   else if dxfGDBStringload(f,0,byt,s)then
                                             begin
                                                  if s='VERTEX' then vertexgo := true;
                                                  if s='SEQEND' then system.Break;
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
function AllocPolyline:PGDBObjPolyline;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocLine}',{$ENDIF}pointer(result),sizeof(GDBObjPolyline));
end;
function AllocAndInitPolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjPolyline;
begin
  result:=AllocPolyline;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
class function GDBObjPolyline.CreateInstance:PGDBObjPolyline;
begin
  result:=AllocAndInitPolyline(nil);
end;
begin
  RegisterDXFEntity(GDBPolylineID,'POLYLINE','3DPolyLine',@AllocPolyline,@AllocAndInitPolyline);
end.
