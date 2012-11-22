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

unit GDBMText;
{$INCLUDE def.inc}

interface
uses strproc,UGDBSHXFont,GDBAbstractText,UGDBPoint3DArray,UGDBLayerArray,SysUtils,gdbasetypes,gdbEntity,UGDBXYZWStringArray,UGDBOutbound2DIArray,UGDBOpenArrayOfByte,varman,varmandef,
gl,ugdbltypearray,
GDBase,UGDBDescriptor,GDBText,gdbobjectsconstdef,geometry,dxflow,strmy,math,memman,GDBSubordinated,UGDBTextStyleArray;
const maxdxfmtextlen=250;
type
//procedure CalcObjMatrix;virtual;
{Export+}
PGDBObjMText=^GDBObjMText;
GDBObjMText=object(GDBObjText)
                 width:GDBDouble;(*saved_to_shd*)
                 linespace:GDBDouble;(*saved_to_shd*)
                 linespacef:GDBDouble;(*saved_to_shd*)
                 text:XYZWGDBGDBStringArray;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:GDBByte;wi,l:GDBDouble);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit;var LayerArray:GDBLayerArray;var LTArray:GDBLtypeArray);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure CalcGabarit;virtual;
                 //procedure getoutbound;virtual;
                 procedure Format;virtual;
                 procedure createpoint;virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 destructor done;virtual;

                 procedure SimpleDrawGeometry;virtual;

                 //procedure CalcObjMatrix;virtual;
            end;
{Export-}
implementation
uses {io,}shared,log;
procedure GDBObjMText.SimpleDrawGeometry;
begin
     if self.text.count=1 then
                              Vertex3D_in_WCS_Array.simpledrawgeometry(1)
                          else
                              Vertex3D_in_WCS_Array.simpledrawgeometry(2);
end;
function GDBObjMText.GetObjTypeName;
begin
     result:=ObjN_GDBObjMText;
end;
destructor GDBObjMText.done;
begin
  text.FreeAndDone;
  inherited done;  
end;
constructor GDBObjMText.initnul;
begin
  inherited initnul(owner);
  vp.ID := GDBMtextID;
  width := 0;
  linespace := 1;
  text.init(10);
end;
constructor GDBObjMText.init;
begin
  inherited init(own,layeraddres, lw, c, p, s, o, w, a, j);
  vp.ID := GDBMtextID;
  width := wi;
  linespacef := l;

//  if angleload then
  begin
     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    Local.basis.ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    Local.basis.ox:=CrossVertex(ZWCS,Local.basis.oz);
  local.basis.OX:=VectorTransform3D(local.basis.OX,geometry.CreateAffineRotationMatrix(Local.basis.oz,-textprop.angle*pi/180));
  end;

  text.init(10);
  format;
end;
procedure GDBObjMText.format;
var
  canbreak: GDBBoolean;
  currsymbol, lastbreak, lastcanbreak, i: GDBInteger;
  linewidth, lastlinewidth, maxlinewidth, {w, }h, angle: GDBDouble;
  currline: GDBString;
  swp:GDBStrWithPoint;
  pswp:pGDBStrWithPoint;
      ir:itrec;
  psyminfo:PGDBsymdolinfo;
  TCP:TCodePage;
  pfont:pgdbfont;

  l:GDBInteger;
  sym:word;
  newline:boolean;
procedure setstartx;
begin
     if length(pswp.str)>0 then
                               begin
                                 if pswp.str[1]=' ' then
                                                         l:=l;
                               sym:=getsymbol(pswp.str,1,l,pgdbfont(pfont)^.unicode);
                               psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
                               pswp^.x:= 0-psyminfo.SymMinX{*textprop.size};
                               end
                           else
                               pswp^.x:= 0;
end;
begin
  textprop.wfactor:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.prop.wfactor;
  textprop.oblique:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.prop.oblique;
  pfont:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.pfont;
  TCP:=CodePage;
  CodePage:=CP_win;
  if template='' then
                      template:=content;
  swp.str:='';
  content:=textformat(template,@self);
  CodePage:=TCP;
  linespace := textprop.size * linespacef * 5 / 3;
  if content='' then content:=str_empty;
  text.free;
  //freeopenarrayofGDBString(ptext);
  //GDBGetMem(ptext, 10000);
  //ptext.count := 0;

  lod:=0;
  P_drawInOCS:=NulVertex;
  {P_drawInOCS.x := 0;
  P_drawInOCS.y := 0;
  P_drawInOCS.z := 0;}

  canbreak := false;
  currsymbol := 1;
  //psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(ach2uch(integer(content[currsymbol])));
  lastbreak := 1;
  lastcanbreak := 1;
  linewidth := 0;

  //sym:=getsymbol(content,currsymbol,l);
  //psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);
  newline:=true;

  lastlinewidth := 0;
  currline := '';
  maxlinewidth := (width / textprop.size) / textprop.wfactor;
  repeat
    sym:=getsymbol(content,currsymbol,l,pgdbfont(pfont)^.unicode);
    psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);
    if newline then
                   begin
                        linewidth:=linewidth-psyminfo.SymMinX;
                        newline:=false;
                   end;
    if ({content[currsymbol]}sym = {' '}32) and (maxlinewidth > 0) then
    begin
      lastcanbreak := currsymbol;
      canbreak := true;
      lastlinewidth := linewidth;
      linewidth := linewidth + psyminfo.NextSymX
    end
    else
      if copy(content,currsymbol,2)='\P' then          {\P}
      begin
        currline := copy(content, lastbreak, currsymbol - lastbreak);
        lastbreak := currsymbol + 2;
        currsymbol := currsymbol + 1;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch}({integer(content[currsymbol])}sym));
        canbreak := false;

        {GDBPointer(ptext.GDBStringarray[ptext.count].str) := nil;
        ptext.GDBStringarray[ptext.count].str := currline;
        ptext.GDBStringarray[ptext.count].w := linewidth;
        inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pbasefont)^.GetOrReplaceSymbolInfo({ach2uch}(GDBByte(' '))).NextSymX;
        end;
        self.text.add(@swp);
        newline:=true;
        linewidth := 0;
        lastlinewidth := linewidth;
      end
      else
      begin
        linewidth := linewidth + psyminfo.NextSymX;
      end;
    if canbreak then
      if maxlinewidth <= linewidth then
      begin
        currline := copy(content, lastbreak, lastcanbreak - lastbreak);
        linewidth := 0;
        newline:=true;
        lastbreak := lastcanbreak + 1;
        currsymbol := lastcanbreak;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);

        canbreak := false;

        {GDBPointer(ptext.GDBStringarray[ptext.count].str) := nil;
        ptext.GDBStringarray[ptext.count].str := currline;
        ptext.GDBStringarray[ptext.count].w := lastlinewidth;
        inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=lastlinewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(GDBByte(' '))}32).NextSymX;//pgdbfont(pbasefont)^.symbo linfo[GDBByte(' ')].dx;
        end;
        self.text.add(@swp);

      end;
    inc(currsymbol,l);
    psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);
  until currsymbol > length(content);
  if linewidth=0 then
                     linewidth:=1;
  currline := copy(content, lastbreak, currsymbol - lastbreak);
  {GDBPointer(ptext.GDBStringarray[ptext.count].str) := nil;
  ptext.GDBStringarray[ptext.count].str := currline;
  ptext.GDBStringarray[ptext.count].w := linewidth;
  inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(GDBByte(' '))}32).NextSymX;//pgdbfont(pbasefont)^.symbo linfo[GDBByte(' ')].dx;
        end;
        self.text.add(@swp);
  //w := width;
  if self.text.count > 0 then
    h := (self.text.count - 1) * linespace + textprop.size
  else
    h := 0;
     //h:=(PGDBmtext(temp)^.ptext.count-1)*PGDBmtext(temp)^.linespace/PGDBmtext(temp)^.size+1
     //pm^.p_draw:=pm^.p_insert;
  P_drawInOCS:=NulVertex;
  {p_draw.x := 0;
  p_draw.y := 0;
  p_draw.z := 0;}

  //angle:=(90 - textprop.oblique)*(pi/180);
  {if angle<>pi/2 then
                     begin
                          angle:=tan(angle);
                     end
                else}
                    begin
                         angle:=0;
                    end;
  //angle:=0;

  if textprop.justify = 0 then
    textprop.justify := 1;
  case textprop.justify of
    1:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
              setstartx;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := 0;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    2:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x-pswp^.w * textprop.size / 2 / textprop.size;;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size / 2 / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    3:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x -pswp^.w * textprop.size  / textprop.size;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size  / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    4:
      begin
                                //p_draw.y:=p_draw.y+h/2/size-size
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h / 2;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := 0;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;

    5:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h / 2;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x -pswp^.w * textprop.size / 2 / textprop.size;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size / 2 / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    6:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h / 2;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x -pswp^.w * textprop.size  / textprop.size;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size  / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    7:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := 0;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    8:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x -pswp^.w * textprop.size  / 2 / textprop.size;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size  / 2 / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
    9:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size + h;
        i:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:= pswp^.x -pswp^.w * textprop.size  / textprop.size;
          pswp^.y := -(i) * linespace / textprop.size;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          inc(i);
          pswp:=text.iterate(ir);
        until pswp=nil
        {for i := 0 to ptext.count - 1 do
        begin
          ptext.GDBStringarray[i].x := -ptext.GDBStringarray[i].w * textprop.size  / textprop.size;
          ptext.GDBStringarray[i].y := -(i) * linespace / textprop.size;
        end;}
      end;
  end;
    calcobjmatrix;
    CalcGabarit;
    //getoutbound;
    calcbb;
    createpoint;
end;
procedure GDBObjMText.CalcGabarit;
var
//  i: GDBInteger;
//  j: GDBInteger;
  pswp:pGDBStrWithPoint;
      ir:itrec;
begin
  obj_height:=0;
  obj_width:=0;
  obj_y:=0;
        pswp:=text.beginiterate(ir);
        if pswp<>nil then
        repeat
          if obj_width<pswp^.w then obj_width:=pswp^.w;
          pswp:=text.iterate(ir);
        until pswp=nil;
        if text.count > 0 then
                              obj_height := ((self.text.count-1) * linespace + textprop.size)/textprop.size
                          else
                              obj_height := 0;
        {if text.count=1 then
                        obj_height:=text.count * linespace / textprop.size
                        else
                        obj_height:=(text.count) * linespace / textprop.size;}
  obj_width:=obj_width-1/3;
end;
(*
procedure GDBObjMText.getoutbound;
var  v:GDBvertex4D;
     dm:dmatrix4d;
    t,b,l,r,n,f,xstart,ystart:GDBDouble;
    i:integer;
begin
  //exit;
  xstart:=0;
  ystart:=-1;//obj_height-{linespace}3 / textprop.size;
  case textprop.justify of
    1:
      begin
           xstart:=xstart;
      end;
    2:
      begin
           xstart:=xstart-obj_width/2;
      end;
    3:
      begin
           xstart:=xstart-obj_width;
      end;
    4:
      begin
           xstart:=xstart;
      end;
    5:
      begin
           xstart:=xstart-obj_width/2;
      end;
    6:
      begin
           xstart:=xstart-obj_width;
      end;
    7:
      begin
           xstart:=xstart;
      end;
    8:
      begin
           xstart:=xstart-obj_width/2;
      end;
    9:
      begin
           xstart:=xstart-obj_width;
      end;
  end;

  dm:=DrawMatrix;
  dm[1, 0]:=0;
  v.x:=xstart;
  v.y:=-ystart;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,dm);
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=xstart;
  v.y:=-ystart-obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,dm);
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=xstart+obj_width;
  v.y:=-ystart-obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,dm);
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=xstart+obj_width;
  v.y:=-ystart;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,dm);
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;

  l:=outbound[0].x;
  r:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>r then
                         r:=outbound[i].x;
  if outbound[i].y<b then
                         b:=outbound[i].y;
  if outbound[i].y>t then
                         t:=outbound[i].y;
  if outbound[i].z<n then
                         n:=outbound[i].z;
  if outbound[i].z>f then
                         f:=outbound[i].z;
  end;

  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(r,T,f);




  if PProjoutbound=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{DD80536C-7685-4BEA-B8D8-C65B489D14C0}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{D9B4BF93-80FB-45C8-8C6B-8AB440BB3F72}',{$ENDIF}4);
  end;
end;
*)
procedure GDBObjMText.createpoint;
var
  psymbol: PGDBByte;
  lin,i, j, k{, l}: GDBInteger;

  len: GDBWord;
  matr,m1: DMatrix4D;
  v:GDBvertex4D;
  pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;
  minx,miny,maxx,maxy:GDBDouble;

  lp,tv:gdbvertex;
  plp,plp2:pgdbvertex;
  pswp:pGDBStrWithPoint;
      ir:itrec;
  pl:GDBPoint3DArray;
  ispl:gdbboolean;
  pfont:pgdbfont;
  ln,l:GDBInteger;

  sym:word;
begin
  ln:=0;
  pfont:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.pfont;
  pl.init({$IFDEF DEBUGBUILD}'{E44FB0DD-3556-4279-8845-5EA005F302DB}',{$ENDIF}10);
  ispl:=false;
  Vertex3D_in_WCS_Array.clear;

  minx:=+infinity;
  miny:=+infinity;
  maxx:=NegInfinity;
  maxy:=NegInfinity;
  {minx:=+10000000;
  miny:=+10000000;
  maxx:=-10000000;
  maxy:=-10000000;}
  lin:=0;
  {for l:=0 to ptext.count-1 do
  begin}
        pswp:=text.beginiterate(ir);

  //objmatrix:=onematrix;
        if pswp<>nil then
  repeat
  inc(ln);
  matr:=DrawMatrix;
  //matr:=matrixmultiply(DrawMatrix,objmatrix);
  m1:=onematrix;
  m1[0, 0] := 1;
  m1[1, 1] := 1;
  m1[2, 2] := 1;
  m1[3, 3] := 1;
  m1[3, 0] := pswp^.x-(pswp^.y)*cotan(pi/2-textprop.oblique*pi/180)/textprop.wfactor;
  m1[3, 1] := pswp^.y;
  matr:=MatrixMultiply(m1,matr);
  i := 1;
                       if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                     end;

  while i<=length(pswp^.str) do
  begin
    m1:=matr;
    sym:=getsymbol(pswp^.str{[i]},i,l,pgdbfont(pfont)^.unicode);
    if {pswp^.str[i]}sym={#}1 then
    begin
         ispl:=not(ispl);
         if ispl then begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end
                    {оригинал}
                    {begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             lin:=1;
                             pl.Add(@lp);
                        end}
                            {else begin
                             pv3.coord:=lp;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pv3.coord:=lp;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);
                             pl.Add(@lp);
                             lin:=0;
                        end;}
                   else begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end;
    end
    else
    begin
    //matr:=matrixmultiply(matr,objmatrix);

      pfont.CreateSymbol(Vertex3D_in_WCS_Array,sym,objmatrix,matr,minx,miny,maxx,maxy,ln);

      matr:=m1;
      FillChar(m1, sizeof(DMatrix4D), 0);
  m1[0, 0] := 1;
  m1[1, 1] := 1;
  m1[2, 2] := 1;
  m1[3, 3] := 1;
    {if sym<256 then
                    sym:=ach2uch(sym);}
  m1[3, 0] := pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(ord(pswp^.str[i]))}sym).NextSymX;
  m1[3, 1] := 0;
  matr:=MatrixMultiply(m1,matr);
  end;
  inc(i,l);
  end;
                     if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                     end;
            pswp:=text.iterate(ir);
        until pswp=nil;


  v.x:=minx;
  v.y:=maxy;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=maxx;
  v.y:=maxy;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=maxx;
  v.y:=miny;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=minx;
  v.y:=miny;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;
  if PProjoutbound=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{4EE8FCB2-6B54-4F16-83C4-BAD50539EF7E}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{B510A218-FCAB-464A-B97F-F19DF29D0FB0}',{$ENDIF}4);
  end;

  plp:=pl.beginiterate(ir);
  plp2:=pl.iterate(ir);
  if plp2<>nil then
  repeat

                             pv3.coord:=plp^;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);
                             pv3.coord:=plp2^;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);

        plp:=pl.iterate(ir);
        plp2:=pl.iterate(ir);
  until plp2=nil;





  Vertex3D_in_WCS_Array.Shrink;
  pl.done;
end;
{procedure GDBObjMText.CalcObjMatrix;
var rot_matr,oblique_matr,disp_self_matr,disp_matr,size_matr:DMatrix4D;
begin
     inherited;

     Local.oy:=CrossVertex(Local.oz,Local.ox);
     Local.ox:=NormalizeVertex(Local.ox);
     Local.oy:=NormalizeVertex(Local.oy);
     Local.oz:=NormalizeVertex(Local.oz);

     rot_matr:=OneMatrix;
     disp_self_matr:=OneMatrix;
     disp_matr:=OneMatrix;
     oblique_matr:= OneMatrix;
     disp_self_matr:= OneMatrix;
     size_matr:=OneMatrix;

     PGDBVertex(@rot_matr[0])^:=Local.ox;
     PGDBVertex(@rot_matr[1])^:=Local.oy;
     PGDBVertex(@rot_matr[2])^:=Local.oz;

     PGDBVertex(@disp_matr[3])^:=Local.p_insert;

     objmatrix:=MatrixMultiply(rot_matr,disp_matr);
     objmatrix:=MatrixMultiply(vp.owner^.GetMatrix^,objmatrix);

     oblique_matr[1, 0] := cotan(pi / 2 - textprop.oblique * pi / 180);

     Pgdbvertex(@disp_self_matr[3])^:=P_drawInOCS;
     size_matr[0, 0] := textprop.wfactor*textprop.size;
     size_matr[1, 1] := textprop.size;
     size_matr[2, 2] := textprop.size;
     DrawMatrix:=MatrixMultiply(oblique_matr,size_matr);
     DrawMatrix:=MatrixMultiply(DrawMatrix,disp_self_matr);
end;}

function GDBObjMText.Clone;
var tvo: PGDBObjMtext;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{599A7E9B-3DA5-4715-8DFC-0957E8B6FCBF}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjMText));
  tvo^.initnul(own);
  //tvo^.vp:=vp;
  CopyVPto(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.template:=template;
  tvo^.content:=content;
  //tvo^.Format;
  tvo^.width:=width;
  tvo^.linespace:=linespace;
  tvo^.linespacef:=linespacef;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.TXTStyleIndex:=TXTStyleIndex;
  result := tvo;
end;
procedure GDBObjMText.LoadFromDXF;
var s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  ux: gdbvertex;
  angleload: GDBBoolean;
  j:GDBInteger;
  style:GDBString;
begin
  //initnul;
  angleload := false;
  ux.x := 1;
  ux.y := 0;
  ux.z := 0;
  style:='';
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,LayerArray,LTArray) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfvertexload(f,11,byt,ux) then
    if not dxfGDBDoubleload(f,40,byt,textprop.size) then
    if not dxfGDBDoubleload(f,41,byt,width) then
    if not dxfGDBDoubleload(f,44,byt,linespacef) then
    if not dxfGDBDoubleload(f,51,byt,textprop.oblique) then
    if not dxfGDBIntegerload(f,71,byt,j)then
    if not dxfGDBStringload(f,1,byt,template)then
    if not dxfGDBStringload(f,3,byt,template)then
    if dxfGDBDoubleload(f,50,byt,textprop.angle) then angleload := true

    else if     dxfGDBStringload(f,7,byt,style)then
                                                 begin
                                                      TXTStyleIndex :=gdb.GetCurrentDWG.TextStyleTable.FindStyle(Style,false);
                                                      if TXTStyleIndex=-1 then
                                                                          TXTStyleIndex:=0;
                                                 end
    else s := f.readgdbstring;
    byt:=readmystrtoint(f);
  end;
  OldVersTextReplace(Template);
  OldVersTextReplace(Content);  
  textprop.justify:=j;
  P_drawInOCS := Local.p_insert;
  linespace := textprop.size * linespacef * 5 / 3;
  if not angleload then
                       textprop.angle := vertexangle(NulVertex2D,pgdbvertex2d(@ux)^) * 180 / pi;
  Local.basis.ox:=ux;
  //ptext := nil;
  //text.init(10);
  //Vertex2D_in_DCS_Array.init({$IFDEF DEBUGBUILD}'{60EB8545-4D59-48BF-9489-41979066A13F}',{$ENDIF}100);
  PProjoutbound:=nil;
  format;
end;
function z2dxfmtext(s:gdbstring;var ul:boolean):gdbstring;
var i:GDBInteger;
begin
     result:=s;
     repeat
          i:=pos(#1,result);
          if i>0 then
                     begin
                          if not(ul) then
                                         result:=copy(result,1,i-1)+'\L'+copy(result,i+1,length(result)-i)
                                     else
                                         result:=copy(result,1,i-1)+'\l'+copy(result,i+1,length(result)-i);

                          ul:=not(ul);
                     end;
     until i<=0;
end;
procedure GDBObjMText.SaveToDXF(var handle: TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte);
var
//  i, j: GDBInteger;
  bw: GDBByte;
  s: GDBString;
  ul:boolean;
begin
  ul:=false;
  SaveToDXFObjPrefix(handle,outhandle,'MTEXT','AcDbMText');
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfGDBDoubleout(outhandle,40,textprop.size);
  dxfGDBDoubleout(outhandle,41,width);
  dxfGDBIntegerout(outhandle,71,textprop.justify);
  if  convertfromunicode(template)=content then
                                               s := template
                                           else
                                               s := content;
  //s := content;
  if length(s) < maxdxfmtextlen then
  begin
    dxfGDBStringout(outhandle,1,z2dxfmtext(s,ul));
  end
  else
  begin
    dxfGDBStringout(outhandle,1,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
    s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen);
    while length(s) > maxdxfmtextlen+1 do
    begin
      dxfGDBStringout(outhandle,3,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
      s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen)
    end;
    dxfGDBStringout(outhandle,3,z2dxfmtext(s,ul));
  end;
  dxfGDBStringout(outhandle,7,PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.name);
  SaveToDXFObjPostfix(outhandle);
  dxfvertexout(outhandle,11,Local.basis.ox);
  dxfGDBDoubleout(outhandle,44,3 * linespace / (5 * textprop.size));
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBMtext.initialization');{$ENDIF}
end.
