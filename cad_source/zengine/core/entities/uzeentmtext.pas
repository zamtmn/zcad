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

unit uzeentmtext;
{$INCLUDE zengineconfig.inc}

interface
uses
    uzglgeometry,uzgldrawcontext,uzetextpreprocessor,uzeentityfactory,uzedrawingdef,
    uzbstrproc,uzefont,uzeentabstracttext,UGDBPoint3DArray,uzestyleslayers,SysUtils,
    uzeentity,UGDBOutbound2DIArray,uzctnrVectorBytes,
    uzbtypes,uzeenttext,uzeconsts,uzegeometry,uzeffdxfsupport,math,uzeentsubordinated,
    gzctnrVectorTypes,uzegeometrytypes,uzestylestexts,StrUtils,gzctnrVector;
const maxdxfmtextlen=250;
type
//procedure CalcObjMatrix;virtual;
{Export+}
PGDBXYZWStringArray=^XYZWStringArray;
{REGISTEROBJECTTYPE XYZWStringArray}
XYZWStringArray=object(GZVector{-}<GDBStrWithPoint>{//})
                end;
PGDBObjMText=^GDBObjMText;
{REGISTEROBJECTTYPE GDBObjMText}
GDBObjMText= object(GDBObjText)
                 width:Double;(*saved_to_shd*)
                 linespace:Double;(*saved_to_shd*)(*oi_readonly*)
                 linespacef:Double;(*saved_to_shd*)
                 text:XYZWStringArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:TDXFEntsInternalStringType;p:GDBvertex;s,o,w,a:Double;j:TTextJustify;wi,l:Double);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure CalcGabarit(const drawing:TDrawingDef);virtual;
                 //procedure getoutbound;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure FormatContent(var drawing:TDrawingDef);virtual;
                 procedure createpoint(const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:String;virtual;
                 destructor done;virtual;

                 procedure SimpleDrawGeometry(var DC:TDrawContext);virtual;
                 procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;

                 function CreateInstance:PGDBObjMText;static;
                 function GetObjType:TObjID;virtual;
            end;
{Export-}
procedure FormatMtext(pfont:pgdbfont;width,size,wfactor:Double;content:TDXFEntsInternalStringType;var text:XYZWStringArray);
function GetLinesH(linespace,size:Double;var lines:XYZWStringArray):Double;
function GetLinesW(var lines:XYZWStringArray):Double;
function GetLineSpaceFromLineSpaceF(linespacef,size:Double):Double;
implementation
procedure GDBObjMText.FormatAfterDXFLoad;
begin
     formatcontent(drawing);

     calcobjmatrix;

     CalcGabarit(drawing);

     calcbb(dc);
end;
procedure GDBObjMText.SimpleDrawGeometry;
begin
     {if self.text.count=1 then
                              Representation.SHX.simpledrawgeometry(dc,1)
                          else
                              Representation.SHX.simpledrawgeometry(dc,2);}
end;
function GDBObjMText.GetObjTypeName;
begin
     result:=ObjN_GDBObjMText;
end;
destructor GDBObjMText.done;
begin
  text.Done;
  inherited done;  
end;
constructor GDBObjMText.initnul;
begin
  inherited initnul(owner);
  //vp.ID := GDBMtextID;
  width := 0;
  linespace := 1;
  text.init(10);
end;
constructor GDBObjMText.init;
begin
  inherited init(own,layeraddres, lw, c, p, s, o, w, a, j);
  //vp.ID := GDBMtextID;
  width := wi;
  linespacef := l;

//  if angleload then
  begin
     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    Local.basis.ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    Local.basis.ox:=CrossVertex(ZWCS,Local.basis.oz);
  local.basis.OX:=VectorTransform3D(local.basis.OX,uzegeometry.CreateAffineRotationMatrix(Local.basis.oz,{-textprop.angle}{ TODO : removeing angle from text ents }-a));
  end;

  text.init(10);
  //format;
end;
function GDBObjMText.GetObjType;
begin
     result:=GDBMtextID;
end;
function GetLineSpaceFromLineSpaceF(linespacef,size:Double):Double;
begin
    result:=size*linespacef*5/3;
end;
function GetLinesH(linespace,size:Double;var lines:XYZWStringArray):Double;
begin
  if lines.count > 0 then
    result := (lines.count - 1) * linespace + size
  else
    result := 0;
end;
function GetLinesW(var lines:XYZWStringArray):Double;
var
  pswp:pGDBStrWithPoint;
  ir:itrec;
begin
  pswp:=lines.beginiterate(ir);
  if pswp<>nil then
                    begin
                          result:=pswp^.w;
                          pswp:=lines.iterate(ir);
                          if pswp<>nil then
                          repeat
                                if result<pswp^.w then
                                                      result:=pswp^.w;
                            pswp:=lines.iterate(ir);
                          until pswp=nil
                    end
               else
                   result:=0;
end;
procedure FormatMtext(pfont:pgdbfont;width,size,wfactor:Double;content:TDXFEntsInternalStringType;var text:XYZWStringArray);
var
  canbreak: Boolean;
  currsymbol, lastbreak, lastcanbreak: Integer;
  linewidth, lastlinewidth, maxlinewidth,lastsymspace: Double;
  currline:TDXFEntsInternalStringType;
  swp:GDBStrWithPoint;
  psyminfo:PGDBsymdolinfo;
  l:Integer;
  sym:word;
  newline:boolean;
  //-ttf-//TDInfo:TTrianglesDataInfo;
begin
  swp.str:='';
  canbreak := false;
  currsymbol := 1;
  //psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(ach2uch(integer(content[currsymbol])));
  lastbreak := 1;
  lastcanbreak := 1;
  linewidth := 0;
  lastsymspace:=0;

  //sym:=getsymbol(content,currsymbol,l);
  //psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);
  newline:=true;

  lastlinewidth := 0;
  currline := '';
  maxlinewidth := (width / size) / wfactor;
  if content<>'' then
  begin
  repeat
    sym:=getsymbol_fromGDBText(content,currsymbol,l,pgdbfont(pfont)^.font.unicode);
    psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym{//-ttf-//,tdinfo});
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
      linewidth := lastsymspace + linewidth + psyminfo.{NextSymX}SymMaxX;
      lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
    end
    else
      if {(copy(content,currsymbol,2)='\P')or}(sym=10) then          {\P теперь уже тут не встретишь, оно заменено препроцессором на 10}
      begin
        currline := copy(content, lastbreak, currsymbol - lastbreak);
        if sym<>10 then begin
          lastbreak := currsymbol + 2;
          currsymbol := currsymbol + 1;
        end else begin
          lastbreak := currsymbol + 1;
        end;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch}({integer(content[currsymbol])}sym){//-ttf-//,tdinfo});
        canbreak := false;

        {Pointer(ptext.Stringarray[ptext.count].str) := nil;
        ptext.Stringarray[ptext.count].str := currline;
        ptext.Stringarray[ptext.count].w := linewidth;
        inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pbasefont)^.GetOrReplaceSymbolInfo({ach2uch}(Byte(' ')){,tdinfo//-ttf-//}).NextSymX;
        end;
        text.PushBackData(swp);
        newline:=true;
        linewidth := 0;
        lastsymspace:=0;
        lastlinewidth := linewidth;
      end
      else
      begin
        //linewidth := linewidth + psyminfo.NextSymX;
        linewidth := lastsymspace + linewidth + psyminfo.{NextSymX}SymMaxX;
        lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
      end;
    if canbreak then
      if maxlinewidth <= linewidth then
      begin
        currline := copy(content, lastbreak, lastcanbreak - lastbreak);
        linewidth := 0;
        lastsymspace:=0;
        newline:=true;
        lastbreak := lastcanbreak + 1;
        currsymbol := lastcanbreak;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym{//-ttf-//,tdinfo});

        canbreak := false;

        {Pointer(ptext.Stringarray[ptext.count].str) := nil;
        ptext.Stringarray[ptext.count].str := currline;
        ptext.Stringarray[ptext.count].w := lastlinewidth;
        inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=lastlinewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(Byte(' '))}32{//-ttf-//,tdinfo}).NextSymX;//pgdbfont(pbasefont)^.symbo linfo[Byte(' ')].dx;
        end;
        text.PushBackData(swp);

      end;
    inc(currsymbol,l);
    //psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym);
  until currsymbol > length(content);
  end;
  if linewidth=0 then
                     linewidth:=1;
  currline := copy(content, lastbreak, currsymbol - lastbreak);
  {Pointer(ptext.Stringarray[ptext.count].str) := nil;
  ptext.Stringarray[ptext.count].str := currline;
  ptext.Stringarray[ptext.count].w := linewidth;
  inc(ptext.count);}
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then
        begin
             swp.str:=copy(swp.str,1,length(swp.str)-1);
             swp.w := swp.w - pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(Byte(' '))}32{//-ttf-//,tdinfo}).NextSymX;//pgdbfont(pbasefont)^.symbo linfo[Byte(' ')].dx;
        end;
        text.PushBackData(swp);
  //w := width;
end;

procedure GDBObjMText.FormatContent(var drawing:TDrawingDef);
var
  i: Integer;
  h, angle: Double;
  pswp:pGDBStrWithPoint;
    ir:itrec;
  psyminfo:PGDBsymdolinfo;
  TCP:TCodePage;
  pfont:pgdbfont;

  l:Integer;
  sym:word;
  //-ttf-//TDInfo:TTrianglesDataInfo;
procedure setstartx;
begin
     if length(pswp.str)>0 then
                               begin
//                                 if pswp.str[1]=' ' then
//                                                         l:=l;
                               sym:=getsymbol_fromGDBText(pswp.str,1,l,pgdbfont(pfont)^.font.unicode);
                               psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym{//-ttf-//,tdinfo});
                               pswp^.x:= 0-psyminfo.SymMinX{*textprop.size};
                               end
                           else
                               pswp^.x:= 0;
end;
begin
  textprop.wfactor:=PGDBTextStyle((TXTStyleIndex))^.prop.wfactor;
  textprop.oblique:=PGDBTextStyle((TXTStyleIndex))^.prop.oblique;
  pfont:=TXTStyleIndex^.pfont;
  TCP:=CodePage;
  CodePage:=CP_win;
  if template='' then
                      template:=content;
  content:=textformat(template,@self);
  CodePage:=TCP;
  linespace := textprop.size * linespacef * 5 / 3;
  if (content='')and(template='') then content:=str_empty;
  text.free;

  lod:=0;
  P_drawInOCS:=NulVertex;

  FormatMtext(pfont,width,textprop.size,textprop.wfactor,content,text);

  h:=GetLinesH(linespace,textprop.size,text);

  P_drawInOCS:=NulVertex;
  angle:=0;

  case textprop.justify of
    jstl:
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
      end;
    jstc:
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
      end;
    jstr:
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
      end;
    jsml:
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
      end;

    jsmc:
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
      end;
    jsmr:
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
      end;
    jsbl:
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
      end;
    jsbc:
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
      end;
    jsbr:
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
      end;
  end;
    {calcobjmatrix;
    CalcGabarit(drawing);
    //getoutbound;
    calcbb;
    createpoint(drawing);}
end;
procedure GDBObjMText.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  calcobjmatrix;
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  Representation.Clear;

  formatcontent(drawing);
  calcobjmatrix;
  CalcGabarit(drawing);
  //getoutbound;
  if (not (ESTemp in State))and(DCODrawable in DC.Options) then
    createpoint(drawing,dc);
  calcbb(dc);

  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjMText.CalcGabarit;
var
//  i: Integer;
//  j: Integer;
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
                              begin
                              obj_height := 1;
                              obj_width := 1;
                              end;
        {if text.count=1 then
                        obj_height:=text.count * linespace / textprop.size
                        else
                        obj_height:=(text.count) * linespace / textprop.size;}
  obj_width:=obj_width{-1/3};
end;
(*
procedure GDBObjMText.getoutbound;
var  v:GDBvertex4D;
     dm:dmatrix4d;
    t,b,l,r,n,f,xstart,ystart:Double;
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
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;
end;
*)
procedure GDBObjMText.createpoint;
var
  //psymbol: PByte;
  {lin,}i{, j, k}{, l}: Integer;

  //len: Word;
  matr,m1: DMatrix4D;
  v:GDBvertex4D;
  //pv:GDBPolyVertex2D;
  //pv3:GDBPolyVertex3D;
  Bound:TBoundingRect;

  lp{,tv}:gdbvertex;
  //plp,plp2:pgdbvertex;
  pswp:pGDBStrWithPoint;
      ir:itrec;
  pl:GDBPoint3DArray;
  ispl:Boolean;
  pfont:pgdbfont;
  ln,l:Integer;

  sym:word;
  //-ttf-//TDInfo:TTrianglesDataInfo;
begin
  ln:=0;
  pfont:=PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.pfont;
  pl.init(10);
  ispl:=false;
  //Representation.SHX.clear;
  //Representation.Triangles.clear;

  Bound.LB.x:=+infinity;
  Bound.LB.y:=+infinity;
  Bound.RT.x:=NegInfinity;
  Bound.RT.y:=NegInfinity;
  {minx:=+10000000;
  miny:=+10000000;
  maxx:=-10000000;
  maxy:=-10000000;}
  //lin:=0;
  {for l:=0 to ptext.count-1 do
  begin}
        pswp:=text.beginiterate(ir);

  //objmatrix:=onematrix;
        if pswp<>nil then
  repeat
  ln:=-1;
  matr:=DrawMatrix;
  //matr:=matrixmultiply(DrawMatrix,objmatrix);
  m1:=onematrix;
  m1[0].v[0] := 1;
  m1[1].v[1] := 1;
  m1[2].v[2] := 1;
  m1[3].v[3] := 1;
  m1[3].v[0] := pswp^.x-(pswp^.y)*cotan(pi/2-textprop.oblique)/textprop.wfactor;
  m1[3].v[1] := pswp^.y;
  matr:=MatrixMultiply(m1,matr);
  i := 1;
                       if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
                     end;

  while i<=length(pswp^.str) do
  begin
    m1:=matr;
    sym:=getsymbol_fromGDBText(pswp^.str{[i]},i,l,pgdbfont(pfont)^.font.unicode);
    if {pswp^.str[i]}sym={#}1 then
    begin
         ispl:=not(ispl);
         if ispl then begin
                             lp:=pgdbvertex(@matr[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
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
                             lp:=pgdbvertex(@matr[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
                        end;
    end
    else
    begin
    //matr:=matrixmultiply(matr,objmatrix);

      pfont.CreateSymbol(DC.drawer,Representation.GetGraphix^,sym,objmatrix,matr,Bound,ln);

      matr:=m1;
      FillChar(m1, sizeof(DMatrix4D), 0);
  m1[0].v[0] := 1;
  m1[1].v[1] := 1;
  m1[2].v[2] := 1;
  m1[3].v[3] := 1;
    {if sym<256 then
                    sym:=ach2uch(sym);}
  m1[3].v[0] := pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(ord(pswp^.str[i]))}sym{//-ttf-//,tdinfo}).NextSymX;
  m1[3].v[1] := 0;
  matr:=MatrixMultiply(m1,matr);
  end;
  inc(i,l);
  end;
                     if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
                     end;
            pswp:=text.iterate(ir);
        until pswp=nil;

       if Bound.LB.x=+infinity then Bound.LB.x:=0;
       if Bound.LB.y=+infinity then Bound.LB.y:=0;
       if Bound.RT.x=NegInfinity then Bound.RT.x:=1;
       if Bound.RT.y=NegInfinity then Bound.RT.y:=1;

  v.x:=Bound.LB.x;
  v.y:=Bound.RT.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=Bound.RT.x;
  v.y:=Bound.RT.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=Bound.RT.x;
  v.y:=Bound.LB.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=Bound.LB.x;
  v.y:=Bound.LB.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;
  if PProjoutbound=nil then
  begin
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;

  {plp:=pl.beginiterate(ir);
  plp2:=pl.iterate(ir);
  if plp2<>nil then
  repeat

                             //pv3.coord:=plp^;
                             //pv3.count:=0;
                             //Representation.SHX.add(@pv3);
                             //pv3.coord:=plp2^;
                             //pv3.count:=0;
                             //Representation.SHX.add(@pv3);

        plp:=pl.iterate(ir);
        plp2:=pl.iterate(ir);
  until plp2=nil;}





  //Representation.SHX.Shrink;
  pl.done;
  Representation.Shrink;
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
  Getmem(Pointer(tvo), sizeof(GDBObjMText));
  tvo^.initnul(own);
  //tvo^.vp:=vp;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
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
var //s{, layername}: String;
  byt{, code}: Integer;
  ux: gdbvertex;
  angleload: Boolean;
  angle:double;
  j:Integer;
  style,ttemplate:String;
begin
  //initnul;
  angleload := false;
  angle:=0;
  ux.x := 1;
  ux.y := 0;
  ux.z := 0;
  style:='';
  ttemplate:='';
  j:=0;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfvertexload(f,11,byt,ux) then
    if not dxfDoubleload(f,40,byt,textprop.size) then
    if not dxfDoubleload(f,41,byt,width) then
    if not dxfDoubleload(f,44,byt,linespacef) then
    if not dxfDoubleload(f,51,byt,textprop.oblique) then
    if not dxfIntegerload(f,71,byt,j)then
    if not dxfStringload(f,1,byt,ttemplate)then
    if not dxfStringload(f,3,byt,ttemplate)then
    if dxfDoubleload(f,50,byt,angle) then angleload := true

    else if     dxfStringload(f,7,byt,style)then
                                                 begin
                                                 TXTStyleIndex :={drawing.GetTextStyleTable^.getDataMutable}(drawing.GetTextStyleTable^.FindStyle(Style,false));
                                                 if TXTStyleIndex=nil then
                                                                     TXTStyleIndex:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
                                                 end
    else {s := }f.readString;
    byt:=readmystrtoint(f);
  end;
  if TXTStyleIndex=nil then
                           begin
                               TXTStyleIndex:=drawing.GetTextStyleTable^.FindStyle('Standard',false);
                               {if TXTStyleIndex=nil then
                                                        TXTStyleIndex:=sysvar.DWG.DWG_CTStyle^;}
                           end;
  OldVersTextReplace(ttemplate);
  OldVersTextReplace(Content);
  Content:=utf8tostring(Tria_AnsiToUtf8(ttemplate));
  //template:=utf8tostring({Tria_AnsiToUtf8}(template));
  textprop.justify:=b2j[j];
  P_drawInOCS := Local.p_insert;
  linespace := textprop.size * linespacef * 5 / 3;
  if not angleload then
                       angle := vertexangle(NulVertex2D,pgdbvertex2d(@ux)^);
  Local.basis.ox:=ux;
  //ptext := nil;
  //text.init(10);
  //Vertex2D_in_DCS_Array.init(100);
  PProjoutbound:=nil;
  //format;
end;
function z2dxfmtext(s:String;var ul:boolean):String;
var count:Integer;
begin
    result:=s;
    repeat
        if not(ul) then
                       result:=StringReplace(result,#1,'\L',[],count)
                   else
                       result:=StringReplace(result,#1,'\l',[],count);
        ul:=not(ul);
    until count=0;
end;
procedure GDBObjMText.SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var
//  i, j: Integer;
  //bw: Byte;
  s: String;
  ul:boolean;
  quotedcontent:TDXFEntsInternalStringType;
begin
  ul:=false;
  SaveToDXFObjPrefix(outhandle,'MTEXT','AcDbMText',IODXFContext);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfDoubleout(outhandle,40,textprop.size);
  dxfDoubleout(outhandle,41,width);
  dxfIntegerout(outhandle,71,j2b[textprop.justify]{ord(textprop.justify)+1});
  quotedcontent:=StringReplace(content,TDXFEntsInternalStringType(#10),TDXFEntsInternalStringType('\P'),[rfReplaceAll]);
  if  convertfromunicode(template)=quotedcontent then
                                               s := Tria_Utf8ToAnsi(UTF8Encode(template))
                                           else
                                               s := Tria_Utf8ToAnsi(UTF8Encode(quotedcontent));
  //s := content;
  if length(s) < maxdxfmtextlen then
  begin
    dxfStringout(outhandle,1,z2dxfmtext(s,ul));
  end
  else
  begin
    dxfStringout(outhandle,1,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
    s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen);
    while length(s) > maxdxfmtextlen+1 do
    begin
      dxfStringout(outhandle,3,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
      s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen)
    end;
    dxfStringout(outhandle,3,z2dxfmtext(s,ul));
  end;
  dxfStringout(outhandle,7,PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.name);
  SaveToDXFObjPostfix(outhandle);
  dxfvertexout(outhandle,11,Local.basis.ox);
  dxfIntegerout(outhandle,73,2);
  dxfDoubleout(outhandle,44,3 * linespace / (5 * textprop.size));
end;
function AllocMText:PGDBObjMText;
begin
  Getmem(result,sizeof(GDBObjMText));
end;
function AllocAndInitMText(owner:PGDBObjGenericWithSubordinated):PGDBObjMText;
begin
  result:=AllocMText;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function GDBObjMText.CreateInstance:PGDBObjMText;
begin
  result:=AllocAndInitMText(nil);
end;
begin
  RegisterDXFEntity(GDBMTextID,'MTEXT','MText',@AllocMText,@AllocAndInitMText);
end.
