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

unit uzeentpolyline;
{$INCLUDE zengineconfig.inc}

interface
uses uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
     uzestyleslayers,uzeentsubordinated,uzeentcurve,
     uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,
     uzegeometrytypes,uzegeometry,uzeffdxfsupport,sysutils,uzctnrvectorpgdbaseobjects;
type
{Export+}
PGDBObjPolyline=^GDBObjPolyline;
{REGISTEROBJECTTYPE GDBObjPolyline}
GDBObjPolyline= object(GDBObjCurve)
                 Closed:Boolean;(*saved_to_shd*)
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:Boolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure startsnap(out osp:os_record; out pdata:Pointer);virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:String;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function GetLength:Double;virtual;

                 class function CreateInstance:PGDBObjPolyline;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
implementation
//uses log;
function GDBObjPolyline.GetLength:Double;
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
function GDBObjPolyline.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;
begin
     if VertexArrayInWCS.onpoint(point,closed) then
                                                begin
                                                     result:=true;
                                                     objects.PushBackData(@self);
                                                end
                                            else
                                                result:=false;
end;
procedure GDBObjPolyline.startsnap(out osp:os_record; out pdata:Pointer);
begin
     GDBObjEntity.startsnap(osp,pdata);
     Getmem(pdata,sizeof(GDBVectorSnapArray));
     PGDBVectorSnapArray(pdata).init(VertexArrayInWCS.Max);
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
var
  tpo: PGDBObjPolyLine;
begin
  Getmem(Pointer(tpo), sizeof(GDBObjPolyline));
  tpo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  //tpo^.vertexarray.init(1000);
  tpo^.vertexarrayinocs.SetSize(vertexarrayinocs.Count);
  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);

  result := tpo;
end;
procedure GDBObjPolyline.SaveToDXF;
//var
//    ptv:pgdbvertex;
//    ir:itrec;
begin
  SaveToDXFObjPrefix(outhandle,'POLYLINE','AcDb3dPolyline',IODXFContext);
  dxfIntegerout(outhandle,66,1);
  dxfvertexout(outhandle,10,uzegeometry.NulVertex);
  if closed then
                dxfIntegerout(outhandle,70,9)
            else
                dxfIntegerout(outhandle,70,8);
end;
procedure GDBObjPolyline.LoadFromDXF;
var s{, layername}: String;
  byt{, code}: Integer;
  //p: gdbvertex;
  hlGDBWord: Integer;
  vertexgo: Boolean;
  tv:gdbvertex;
begin
  closed := false;
  vertexgo := false;
  hlGDBWord:=0;
  tv:=NulVertex;

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
                                                                            FastAddVertex(tv);
                                         end
  else if dxfIntegerload(f,70,byt,hlGDBWord) then
                                                   begin
                                                        if (hlGDBWord and 1) = 1 then closed := true;
                                                   end
   else if dxfStringload(f,0,byt,s)then
                                             begin
                                                  if s='VERTEX' then vertexgo := true;
                                                  if s='SEQEND' then system.Break;
                                             end
                                      else s:= f.readString;
    byt:=readmystrtoint(f);
  end;

  vertexarrayinocs.SetSize(curveVertexArrayInWCS.Count);
  curveVertexArrayInWCS.copyto(vertexarrayinocs);
  curveVertexArrayInWCS.Clear;
end;
{procedure GDBObjPolyline.LoadFromDXF;
var s, layername: String;
  byt, code: Integer;
  p: gdbvertex;
  hlGDBWord: LongWord;
  vertexgo: Boolean;
begin
  closed := false;
  vertexgo := false;
  s := f.readString;
  val(s, byt, code);
  while true do
  begin
    case byt of
      0:
        begin
          s := f.readString;
          if s = 'SEQEND' then
            system.break;
          if s = 'VERTEX' then vertexgo := true;
        end;
      8:
        begin
          layername := f.readString;
          vp.Layer := gdb.LayerTable.getLayeraddres(layername);
        end;
      10:
        begin
          s := f.readString;
          val(s, p.x, code);
        end;
      20:
        begin
          s := f.readString;
          val(s, p.y, code);
        end;
      30:
        begin
          s := f.readString;
          val(s, p.z, code);
          if vertexgo then addvertex(p);
        end;
      70:
        begin
          s := f.readString;
          val(s, hlGDBWord, code);
          hlGDBWord := strtoint(s);
          if (hlGDBWord and 1) = 1 then closed := true;
        end;
      370:
        begin
          s := f.readString;
          vp.lineweight := strtoint(s);
        end;
    else
      s := f.readString;
    end;
    s := f.readString;
    val(s, byt, code);
  end;
  vertexarrayinocs.Shrink;
end;}
function AllocPolyline:PGDBObjPolyline;
begin
  Getmem(pointer(result),sizeof(GDBObjPolyline));
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
