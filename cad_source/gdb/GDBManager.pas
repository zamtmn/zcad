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

unit GDBManager;
{$INCLUDE def.inc}


interface
uses GDB3DFace,UGDBLayerArray,sysutils,gdbasetypes,gdbase, {OGLtypes,}
     UGDBDescriptor,varmandef,gdbobjectsconstdef,
     UGDBVisibleOpenArray,GDBGenericSubEntry,gdbEntity,GDBCable,GDBDevice,
     GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMText,GDBLine,
     GDBPolyLine,GDBLWPolyLine,memman;
type
    TSelObjDesk=record
                      PFirstObj:PGDBObjEntity;
                      Count:GDBInteger;
                end;
//procedure addtext(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; h, angle: GDBDouble; s: pansichar; js: GDBByte); export;
//procedure addarc(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; startangle, endangle, r: GDBDouble); export;
function addblockinsert(own:PGDBObjGenericSubEntry;pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: GDBDouble; s: pansichar):pgdbobjblockinsert;export;
//procedure setdefaultproperty(pprop: PGDBProperty);
//procedure reformatmtext(pm: pgdbmtext);
//procedure reformattext(pt: pgdbtext);
//procedure reformatlwpolyline(pp: pgdblwpolyline);
function getgdb: GDBPointer; export;
//procedure reformat(obj:PGDBproperty); export;
//procedure CopyGDBObject(dest,source:PGDBproperty);export;
//procedure GDBFreeMemGDBObject(source:PGDBproperty);export;
//procedure GDBGetMemGDBObject(source:PGDBproperty);export;
function GetSelOjbj:TSelObjDesk;
function CreateInitObjFree(t:GDBByte;owner:PGDBObjGenericSubEntry):PGDBObjEntity;export;
function CreateObjFree(t: GDBByte): PGDBObjEntity;export;
procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;
procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble); export;
var a: GDBObjLine;
  p: gdbvertex;
implementation
uses
    log;
function GetSelOjbj:TSelObjDesk;
var
    pv:pGDBObjEntity;
    ir:itrec;
begin
     result.PFirstObj:=nil;
     result.Count:=0;

     pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);

  if pv<>nil then
  repeat
    if pv^.Selected then
    begin
         if result.Count=0 then
                                result.PFirstObj:=pv;
         inc(result.count);
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
end;
procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;
begin
  pobjline^.init(own,layeraddres, LW, p1, p2);
end;

procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble);
begin
  pobjcircle^.init(gdb.GetCurrentROOT,layeraddres, LW, p, rr);
end;
function CreateInitObjFree(t:GDBByte;owner:PGDBObjGenericSubEntry): PGDBObjEntity;export;
var temp: PGDBObjEntity;
begin
  temp := nil;
  case t of
    GDBLineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.line}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjLine));
        pgdbobjline(temp).initnul(owner);
      end;
    GDBTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.text}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjText));
        pgdbobjtext(temp).initnul(owner);
      end;
    GDBMTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.mtext}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjMText));
        pgdbobjMtext(temp).initnul(owner);
      end;
    GDBPolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.polyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpolyline));
        pgdbobjpolyline(temp).initnul(owner);
      end;
    GDBArcID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.arc}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjArc));
        pgdbobjArc(temp).initnul;
      end;
    GDBCircleID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.circle}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCircle));
        pgdbobjCircle(temp).initnul;
      end;
    GDBlwpolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.lwpolyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjlwpolyline));
        pgdbobjLWPolyLine(temp).initnul;
      end;
    GDBPointID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.point}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpoint));
        pgdbobjpoint(temp).initnul(owner);
      end;
    GDBBlockInsertID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.blockinsert}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjBlockinsert));
        pgdbobjblockinsert(temp).initnul;
        pgdbobjblockinsert(temp).bp.Owner:=owner;
      end;
    GDBDeviceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.device}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
        pgdbobjdevice(temp).initnul;
        pgdbobjdevice(temp).bp.Owner:=owner;
      end;
    GDBCableID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.cable}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
        pgdbobjcable(temp).initnul(owner);
        pgdbobjcable(temp).bp.Owner:=owner;
      end;
    GDB3DfaceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.cable}',{$ENDIF}GDBPointer(temp), sizeof(GDBObj3DFace));
        pGDBObj3DFace(temp).initnul(owner);
        pGDBObj3DFace(temp).bp.Owner:=owner;
      end;
  end;
  result := temp;
end;
function CreateObjFree(t:GDBByte): PGDBObjEntity;export;
var temp: PGDBObjEntity;
begin
  temp := nil;
  case t of
    GDBLineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.line}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjLine));
      end;
    GDBTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.text}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjText));
      end;
    GDBMTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.mtext}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjMText));
      end;
    GDBPolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.polyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpolyline));
      end;
    GDBCableID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.cable}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCable));
      end;
    GDBArcID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.arc}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjArc));
      end;
    GDBCircleID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.circle}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCircle));
      end;
    GDBlwpolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.lwpolyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjlwpolyline));
      end;
    GDBPointID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.point}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpoint));
      end;
    GDBBlockInsertID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.blockinsert}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjBlockinsert));
      end;
    GDBDeviceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.device}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
      end;
  end;
  result := temp;
end;
function getgdb: GDBPointer; export;
begin
  result := @gdb;
end;


procedure setdefaultproperty(pvo:pgdbobjEntity);
begin
  pvo^.selected := false;
  pvo^.Visible:=gdb.GetCurrentDWG.pcamera.VISCOUNT;
  pvo^.vp.layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pvo^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
end;

{procedure addtext(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; h, angle: GDBDouble; s: pansichar; js: GDBByte);
var
  temp: PGDBGDBPointer;
  objnum: GDBInteger;
begin
  //exit;
  objnum := popa^.count;
  GDBGetMem(temp, sizeof(GDBText));
  setdefaultproperty(@popa^.propertyarray[objnum]);
  popa^.propertyarray[objnum].id := GDBTextID;
  popa^.propertyarray[objnum].layer := 0;
  popa^.propertyarray[objnum].pobject := temp;
  PGDBtext(temp)^.angle := angle * 180 / pi;
  PGDBtext(temp)^.size := h;
  PGDBtext(temp)^.oblique := 12;
  PGDBtext(temp)^.justify := js;
  PGDBtext(temp)^.wfactor := 0.65;
  GDBPointer(PGDBtext(temp)^.content) := nil;
  PGDBtext(temp)^.content := s;
  PGDBtext(temp)^.p_insert := point;
  PGDBtext(temp)^.p_draw := point;
  reformattext(pgdbtext(temp));
  inc(popa^.count);
end;

procedure addarc(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; startangle, endangle, r: GDBDouble);
var
  temp, temp2: PGDBGDBPointer;
  objnum: GDBInteger;
begin
  //exit;
  objnum := popa^.count;
  GDBGetMem(temp, sizeof(GDBArc));
  setdefaultproperty(@popa^.propertyarray[objnum]);
  popa^.propertyarray[objnum].id := GDBArcID;
  popa^.propertyarray[objnum].layer := 1;
  popa^.propertyarray[objnum].pobject := temp;

  PGDBarc(temp)^.startangle := startangle;
  PGDBarc(temp)^.endangle := endangle;
  PGDBarc(temp)^.r := r;
  PGDBarc(temp)^.x := point.x;
  PGDBarc(temp)^.y := point.y;
  PGDBarc(temp)^.z := point.z;
  inc(popa^.count);
end;}

function addblockinsert(own:PGDBObjGenericSubEntry;pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: GDBDouble; s: pansichar):pgdbobjblockinsert;
var
  //temp, temp2: PGDBByte;
  //i, objnum: GDBInteger;
  pb:pgdbobjblockinsert;
  nam:gdbstring;
begin
  result:=nil;
  if pos('DEVICE_', uppercase(s))=1  then
                                         begin
                                         GDBPointer(pb):=pva^.CreateInitObj(GDBDeviceID,gdb.GetCurrentROOT);
                                         //pgdbobjdevice(pb)^.initnul;
                                         nam:=copy(s,8,length(s)-7);
                                         end
                                     else
                                         begin
                                              GDBPointer(pb):=pva^.CreateInitObj(GDBBlockInsertID,gdb.GetCurrentROOT);
                                              //pb.initnul;
                                              nam:=s;
                                         end;
  if pb=nil then exit;
  pb.bp.Owner:={gdb.GetCurrentROOT}own;
  setdefaultproperty(pb);
  pb^.Local.P_insert := point;
  pb^.scale.x := scale;
  pb^.scale.y := scale;
  pb^.scale.z := scale;
  GDBPointer(pb^.name) := nil;
  pb^.name := nam;
  pb.index := -1;
  pb.rotate := angle;
  pb.pattrib := nil;
  pb^.index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(nam));
  //pb^.format;
  //pb^.ObjArray.init(1000);
  pb^.BuildGeometry;
  pb^.BuildVarGeometry;
  pb^.format;
  result:=pb;
  {for i := 0 to GDB.BlockDefArray.count - 1 do
  begin
    if GDB.BlockDefArray.PArray[i].name = s then
      pb^.index := i
  end;}
end;



{procedure freeopenarrayofGDBString(var p: PGDBOpenArrayGDBString_GDBWord);
var
  i: GDBWord;
begin
  if p = nil then
    exit;
  if p^.count = 0 then
  begin
    GDBFreeMem(p);
    p := nil;
    exit;
  end;
  for i := 0 to p^.count - 1 do
    p^.GDBStringarray[i].str := '';
  GDBFreeMem(p);
  p := nil;
end;

procedure reformatmtext(pm: pgdbmtext);
var
  canbreak: GDBBoolean;
  currsymbol, lastbreak, lastcanbreak, i: GDBInteger;
  linewidth, lastlinewidth, maxlinewidth, w, h: GDBDouble;
  currline: GDBString;
begin
  freeopenarrayofGDBString(pm^.ptext);
  GDBGetMem(pm^.ptext, 10000);
  pm^.ptext.count := 0;
  if pm^.content = '' then
    exit;
  canbreak := false;
  currsymbol := 1;
  lastbreak := 1;
  lastcanbreak := 1;
  linewidth := 0;
  lastlinewidth := 0;
  currline := '';
  maxlinewidth := (pm^.width / pm^.size) / pm^.wfactor;
  repeat
    if (pm^.content[currsymbol] = ' ') and (maxlinewidth > 0) then
    begin
      lastcanbreak := currsymbol;
      canbreak := true;
      lastlinewidth := linewidth;
      linewidth := linewidth + pgdbfont(pbasefont)^.symbolinfo[GDBByte(pm^.content[currsymbol])].dx
    end
    else
      if pm^.content[currsymbol] = '\' then
      begin
        currline := copy(pm^.content, lastbreak, currsymbol - lastbreak);
        lastbreak := currsymbol + 2;
        currsymbol := currsymbol + 1;
        canbreak := false;

        GDBPointer(pm^.ptext.GDBStringarray[pm^.ptext.count].str) := nil;
        pm^.ptext.GDBStringarray[pm^.ptext.count].str := currline;
        pm^.ptext.GDBStringarray[pm^.ptext.count].w := linewidth;
        linewidth := 0;
        lastlinewidth := linewidth;
        inc(pm^.ptext.count);
      end
      else
      begin
        linewidth := linewidth + pgdbfont(pbasefont)^.symbolinfo[GDBByte(pm^.content[currsymbol])].dx
      end;
    if canbreak then
      if maxlinewidth <= linewidth then
      begin
        currline := copy(pm^.content, lastbreak, lastcanbreak - lastbreak);
        linewidth := 0;
        lastbreak := lastcanbreak + 1;
        currsymbol := lastcanbreak;

        canbreak := false;

        GDBPointer(pm^.ptext.GDBStringarray[pm^.ptext.count].str) := nil;
        pm^.ptext.GDBStringarray[pm^.ptext.count].str := currline;
        pm^.ptext.GDBStringarray[pm^.ptext.count].w := lastlinewidth;
        inc(pm^.ptext.count);
      end;
    inc(currsymbol);
  until currsymbol > length(pm^.content);
  currline := copy(pm^.content, lastbreak, currsymbol - lastbreak);
  GDBPointer(pm^.ptext.GDBStringarray[pm^.ptext.count].str) := nil;
  pm^.ptext.GDBStringarray[pm^.ptext.count].str := currline;
  pm^.ptext.GDBStringarray[pm^.ptext.count].w := linewidth;
  inc(pm^.ptext.count);
  w := pm^.width;
  if pm^.ptext.count > 0 then
    h := (pm^.ptext.count - 1) * pm^.linespace + pm^.size
  else
    h := 0;
  pm^.p_draw.x := 0;
  pm^.p_draw.y := 0;
  pm^.p_draw.z := 0;
  if pm^.justify = 0 then
    pm^.justify := 1;
  case pm^.justify of
    1:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := 0;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    2:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / 2 / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    3:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    4:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h / 2;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := 0;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;

    5:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h / 2;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / 2 / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    6:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h / 2;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    7:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := 0;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    8:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / 2 / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
    9:
      begin
        pm^.p_draw.y := pm^.p_draw.y - pm^.size + h;
        for i := 0 to pm^.ptext.count - 1 do
        begin
          pm^.ptext.GDBStringarray[i].x := -pm^.ptext.GDBStringarray[i].w * pm^.size * pm^.wfactor / pm^.size;
          pm^.ptext.GDBStringarray[i].y := -(i) * pm^.linespace / pm^.size;
        end;
      end;
  end;
end;
procedure CopyGDBObject(dest,source:PGDBproperty);
begin
     dest^:=source^;
     if source^.id=GDBLineID then
                                begin
                                     GDBGetMem(dest^.pobject,sizeof(GDBline));
                                     PGDBline(dest^.pobject)^:=PGDBline(source^.pobject)^;
                                end
     else if source^.id=GDBcircleID then
                                     begin
                                          GDBGetMem(dest^.pobject,sizeof(GDBcircle));
                                          PGDBcircle(dest^.pobject)^:=PGDBcircle(source^.pobject)^;
                                     end
     else if source^.id=GDBmtextID then
                                     begin
                                          GDBGetMem(dest^.pobject,sizeof(GDBmtext));
                                          PGDBmtext(dest^.pobject)^:=PGDBmtext(source^.pobject)^;
                                          GDBPointer(PGDBmtext(dest^.pobject).content):=nil;
                                          PGDBmtext(dest^.pobject).content:=PGDBmtext(source^.pobject).content;
                                          PGDBmtext(dest^.pobject).ptext:=nil;
                                          reformatmtext(dest^.pobject);
                                     end

     else if source^.id=GDBtextID then
                                     begin
                                          GDBGetMem(dest^.pobject,sizeof(GDBtext));
                                          PGDBtext(dest^.pobject)^:=PGDBtext(source^.pobject)^;
                                          GDBPointer(PGDBtext(dest^.pobject).content):=nil;
                                          PGDBtext(dest^.pobject).content:=PGDBtext(source^.pobject).content;
                                     end;

end;
procedure GDBFreeMemGDBObject(source:PGDBproperty);
begin
     if source^.id=GDBLineID then
                                begin

                                end
     else if source^.id=GDBcircleID then
                                     begin

                                     end
     else if source^.id=GDBmtextID then
                                     begin
                                          PGDBmtext(source^.pobject).content:='';
                                     end
     else if source^.id=GDBtextID then
                                     begin
                                          PGDBtext(source^.pobject).content:='';
                                     end;
     GDBFreeMem(source^.pobject);

end;
procedure GDBGetMemGDBObject(source:PGDBproperty);
var
   temp:GDBPointer;
begin
     if source^.id=GDBLineID then
                                begin
                                     GDBGetMem(source^.pobject,sizeof(gdbline));
                                end
     else if source^.id=GDBtextID then
                                     begin
                                          GDBGetMem(source^.pobject,sizeof(gdbtext));
                                          GDBPointer(PGDBtext(source^.pobject).content):=nil;
                                     end
     else if source^.id=GDBmtextID then
                                     begin
                                          GDBGetMem(source^.pobject,sizeof(gdbmtext));
                                          GDBPointer(PGDBmtext(source^.pobject).content):=nil;
                                     end
     else if source^.id=GDBcircleID then
                                     begin
                                          GDBGetMem(source^.pobject,sizeof(gdbcircle));
                                     end;
end;
procedure reformattext(pt: pgdbtext);
var
  canbreak: GDBBoolean;
  currsymbol, lastbreak, lastcanbreak, i: GDBInteger;
  linewidth, lastlinewidth, maxlinewidth, w, h: GDBDouble;
  currline: GDBString;
begin
  pt^.p_draw.x := 0;
  pt^.p_draw.y := 0;
  pt^.p_draw.z := 0;
  linewidth := 0;
  for i := 1 to length(pt^.content) do
    linewidth := linewidth + pgdbfont(pbasefont)^.symbolinfo[GDBByte(pt^.content[i])].dx;
  linewidth := linewidth - 1 / 3;
  if pt^.justify = 0 then
    pt^.justify := 1;
  case pt^.justify of
    1:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size;
        pt^.p_draw.x := 0;
      end;
    2:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size / 2;
      end;
    3:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size;
      end;
    4:
      begin
                                //pm^.p_draw.y:=pm^.p_draw.y+h/2/pm^.size-pm^.size
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size / 2;
        pt^.p_draw.x := 0;
      end;

    5:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size / 2;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size / 2;
      end;
    6:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size / 2;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size;
      end;
    7:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size;
        pt^.p_draw.x := 0;
      end;
    8:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size / 2;
      end;
    9:
      begin
        pt^.p_draw.y := pt^.p_draw.y - pt^.size + pt^.size;
        pt^.p_draw.x := -linewidth * pt^.wfactor * pt^.size;
      end;
  end;
end;



procedure reformatlwpolyline(pp: pgdblwpolyline);
var
  i, j: GDBInteger;
  dx, dy, nx, ny, l: GDBDouble;
begin
  for i := 0 to PGDBlwpolyline(pp)^.pcoordarray^.count - 1 do
  begin
    if i <> PGDBlwpolyline(pp)^.pcoordarray^.count - 1 then
      j := i + 1
    else
      j := 0;
    dx := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].x - PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].x;
    dy := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].y - PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].y;
    nx := -dy;
    ny := dx;
    l := sqrt(nx * nx + ny * ny);
    nx := nx / l;
    ny := ny / l;
    if (PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].startw = 0) and (PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].endw = 0) then
      PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].hw := false
    else
      PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].hw := true;
    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[0].x := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].x + nx * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].startw / 2;
    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[0].y := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].y + ny * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].startw / 2;

    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[1].x := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].x + nx * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].endw / 2;
    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[1].y := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].y + ny * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].endw / 2;

    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[2].x := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].x - nx * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].endw / 2;
    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[2].y := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[j].y - ny * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].endw / 2;

    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[3].x := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].x - nx * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].startw / 2;
    PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].quad[3].y := PGDBlwpolyline(pp)^.pcoordarray^.vertexarray[i].y - ny * PGDBlwpolyline(pp)^.pwidtharray^.widtharray[i].startw / 2;
  end;
end;
procedure reformat(obj:PGDBproperty);
begin
     if obj^.id=GDBtextID then reformattext(pgdbtext(obj^.pobject))
     else if obj^.id=GDBmtextID then reformatmtext(pgdbmtext(obj^.pobject));
end;}
begin
    {$IFDEF DEBUGINITSECTION}LogOut('GDBmanager.initialization');{$ENDIF}
  p.x := 10;
  p.y := 20;
  p.z := 30;
  //a.init(nil,0, 10, p, p);
  //a.init(nil,0, 10, p, p);
end.
