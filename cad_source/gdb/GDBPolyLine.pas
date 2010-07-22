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

unit GDBPolyLine;
{$INCLUDE def.inc}

interface
uses UGDBLayerArray,GDBSubordinated,GDBCurve,gdbasetypes{,GDBGenericSubEntry,UGDBVectorSnapArray,UGDBSelectedObjArray,GDB3d},gdbEntity{,UGDBPolyLine2DArray,UGDBPoint3DArray},UGDBOpenArrayOfByte,varman{,varmandef},
gl,
GDBase{,UGDBDescriptor},gdbobjectsconstdef{,oglwindowdef},geometry,dxflow,sysutils,memman,OGLSpecFunc;
type
{Export+}
PGDBObjPolyline=^GDBObjPolyline;
GDBObjPolyline=object(GDBObjCurve)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;

                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;
                 procedure DrawGeometry(lw:GDBInteger);virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;
           end;
{Export-}
implementation
uses gdbcable,log;
function GDBObjPolyline.FromDXFPostProcessBeforeAdd;
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
          Tc^.initnul(pointer(bp.owner));
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

function GDBObjPolyline.GetObjTypeName;
begin
     result:=ObjN_GDBObjPolyLine;
end;
constructor GDBObjPolyline.init;
begin
  vp.ID := GDBPolylineID;
  closed := c;
  inherited init(own,layeraddres, lw);
end;
constructor GDBObjPolyline.initnul;
begin
  inherited initnul(owner);
  vp.ID := GDBPolylineID;
end;

procedure GDBObjPolyline.DrawGeometry;
begin
  if closed then myglbegin(GL_line_loop)
            else myglbegin(GL_line_strip);
  vertexarrayInWCS.iterategl(@myglVertex3dv);
  myglend;
end;
function GDBObjPolyline.Clone;
var tpo: PGDBObjPolyLine;
    p:pgdbvertex;
    i:GDBInteger;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{8F88CAFB-14F3-4F33-96B5-F493DB8B28B7}',{$ENDIF}GDBPointer(tpo), sizeof(GDBObjPolyline));
  tpo^.init(bp.owner,vp.Layer, vp.LineWeight,closed);
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
procedure GDBObjPolyline.SaveToDXF;
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
    if not LoadFromDXFObjShared(f,byt,ptu) then
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
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBPolyline.initialization');{$ENDIF}
end.
