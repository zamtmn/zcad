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
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzglgeometry,uzgldrawcontext,uzetextpreprocessor,uzeentityfactory,uzedrawingdef,
  uzbstrproc,uzefont,uzeentabstracttext,UGDBPoint3DArray,uzestyleslayers,SysUtils,
  uzeentity,uzctnrVectorBytes,
  uzbtypes,uzeenttext,uzeconsts,uzegeometry,uzeffdxfsupport,math,uzeentsubordinated,
  gzctnrVectorTypes,uzegeometrytypes,uzestylestexts,StrUtils,gzctnrVector,uzMVReader,
  uzcTextPreprocessorDXFImpl;

const maxdxfmtextlen=250;

type
  PGDBXYZWStringArray=^XYZWStringArray;
  XYZWStringArray=object(GZVector<GDBStrWithPoint>)
  end;
  PGDBObjMText=^GDBObjMText;
  GDBObjMText= object(GDBObjText)
    width:Double;
    linespace:Double;
    linespacef:Double;
    text:XYZWStringArray;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:TDXFEntsInternalStringType;p:GDBvertex;s,o,w,a:Double;j:TTextJustify;wi,l:Double);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
    procedure CalcGabarit(const drawing:TDrawingDef);virtual;
    //procedure getoutbound;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function IsStagedFormatEntity:boolean;virtual;
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

procedure FormatMtext(pfont:pgdbfont;width,size,wfactor:Double;const content:TDXFEntsInternalStringType;var text:XYZWStringArray);
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
  width:=0;
  linespace:=1;
  text.init(10);
end;
constructor GDBObjMText.init;
begin
  inherited init(own,layeraddres, lw, c, p, s, o, w, a, j);
  width:=wi;
  linespacef := l;
  //if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
  if IsNearToZ(Local.basis.oz) then
    Local.basis.ox:=CrossVertex(YWCS,Local.basis.oz)
  else
    Local.basis.ox:=CrossVertex(ZWCS,Local.basis.oz);
  local.basis.OX:=VectorTransform3D(local.basis.OX,uzegeometry.CreateAffineRotationMatrix(Local.basis.oz,{-textprop.angle}{ fixedTODO : removeing angle from text ents }-a));
  text.init(10);
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
  if pswp<>nil then begin
    result:=pswp^.w;
    pswp:=lines.iterate(ir);
    if pswp<>nil then
    repeat
          if result<pswp^.w then
                                result:=pswp^.w;
      pswp:=lines.iterate(ir);
    until pswp=nil
  end else
    result:=0;
end;
procedure FormatMtext(pfont:pgdbfont;width,size,wfactor:Double;const content:TDXFEntsInternalStringType;var text:XYZWStringArray);
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
  _NeedSpaceWidthCalc:boolean;
  _SpaceWidth:double;

  function SpaceWidth:double;inline;
  begin
    if _NeedSpaceWidthCalc then begin
      _NeedSpaceWidthCalc:=false;
      _SpaceWidth:=pgdbfont(pbasefont)^.GetOrReplaceSymbolInfo(32).NextSymX;
    end;
    result:=_SpaceWidth;
  end;

begin
  _NeedSpaceWidthCalc:=true;
  _SpaceWidth:=1;
  swp.str:='';
  canbreak:=false;
  currsymbol:=1;
  lastbreak:=1;
  lastcanbreak:=1;
  linewidth:=0;
  lastsymspace:=0;
  newline:=true;
  lastlinewidth := 0;
  currline:='';
  maxlinewidth:=width/(size*wfactor);
  if content<>''then begin
  repeat
    sym:=getsymbol_fromGDBText(content,currsymbol,l,pgdbfont(pfont)^.font.IsUnicode);
    psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
    if newline then begin
      linewidth:=linewidth-psyminfo.SymMinX;
      newline:=false;
    end;
    if (sym=32)and(maxlinewidth>0) then begin
      lastcanbreak := currsymbol;
      canbreak := true;
      lastlinewidth := linewidth;
      linewidth := lastsymspace + linewidth + psyminfo.SymMaxX;
      lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
    end else
      if sym=10 then begin
        {\P теперь уже тут не встретишь, оно заменено препроцессором на 10}
        currline:=copy(content,lastbreak,currsymbol-lastbreak);
        if sym<>10 then begin
          lastbreak:=currsymbol + 2;
          currsymbol:=currsymbol + 1;
        end else begin
          lastbreak:=currsymbol + 1;
        end;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
        canbreak:=false;
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
          swp.str:=copy(swp.str,1,length(swp.str)-1);
          //swp.w:=swp.w-pgdbfont(pbasefont)^.GetOrReplaceSymbolInfo(32).NextSymX;
          //интересно почему тут pbasefont? теперь тут pfont!
          swp.w:=swp.w-SpaceWidth;
        end;
        text.PushBackData(swp);
        newline:=true;
        linewidth:=0;
        lastsymspace:=0;
        lastlinewidth:=linewidth;
      end else begin
        //linewidth:=linewidth+psyminfo.NextSymX;
        linewidth:=lastsymspace+linewidth+psyminfo.SymMaxX;
        lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
      end;
    if canbreak then
      if maxlinewidth <= linewidth then begin
        currline := copy(content, lastbreak, lastcanbreak - lastbreak);
        linewidth := 0;
        lastsymspace:=0;
        newline:=true;
        lastbreak := lastcanbreak + 1;
        currsymbol := lastcanbreak;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch(integer(content[currsymbol]))}sym{//-ttf-//,tdinfo});
        canbreak := false;
        swp.Str:=currline;
        swp.w:=lastlinewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
          swp.str:=copy(swp.str,1,length(swp.str)-1);
          //swp.w:=swp.w-pgdbfont(pfont)^.GetOrReplaceSymbolInfo(32).NextSymX;
          swp.w:=swp.w-SpaceWidth;
        end;
        text.PushBackData(swp);
      end;
    inc(currsymbol,l);
  until currsymbol > length(content);
  end;
  if linewidth=0 then
    linewidth:=1;
  currline:=copy(content,lastbreak,currsymbol-lastbreak);
  swp.Str:=currline;
  swp.w:=linewidth;
  if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
    swp.str:=copy(swp.str,1,length(swp.str)-1);
    //swp.w:=swp.w-pgdbfont(pfont)^.GetOrReplaceSymbolInfo(32).NextSymX;
    swp.w:=swp.w-SpaceWidth;
  end;
  text.PushBackData(swp);
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

  procedure setstartx;
  begin
    if length(pswp.str)>0 then begin
      sym:=getsymbol_fromGDBText(pswp.str,1,l,pgdbfont(pfont)^.font.IsUnicode);
      psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
      pswp^.x:=0-psyminfo.SymMinX;
    end else
      pswp^.x:=0;
  end;

begin
  textprop.wfactor:=TXTStyle^.prop.wfactor;
  textprop.oblique:=TXTStyle^.prop.oblique;
  pfont:=TXTStyle^.pfont;
  if pfont=nil then
    exit;
  TCP:=CodePage;
  CodePage:=CP_win;
  if template='' then
    template:=content;
  content:=textformat(template,SPFSources.GetFull,@self);
  CodePage:=TCP;
  linespace:=textprop.size*linespacef*5 / 3;
  if (content='')and(template='') then
    content:=str_empty;

  text.free;
  lod:=0;

  P_drawInOCS:=NulVertex;

  FormatMtext(pfont,width,textprop.size,textprop.wfactor,content,text);

  h:=GetLinesH(linespace,textprop.size,text);

  P_drawInOCS:=NulVertex;
  angle:=0;

  if textprop.justify=jsbtl then
    textprop.justify:=jsbl
  else if textprop.justify=jsbtc then
    textprop.justify:=jsbc
  else if textprop.justify=jsbtr then
    textprop.justify:=jsbr;

  case textprop.justify of
    jsbtl,
    jsbtc,
    jsbtr:;//у мтекста таких выравниывний нет
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
      begin//p_draw.y:=p_draw.y+h/2/size-size
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
  if EFCalcEntityCS in stage then begin
    calcobjmatrix;
    if assigned(EntExtensions)then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
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
end;
function GDBObjMText.IsStagedFormatEntity:boolean;
begin
  result:=true;
end;
procedure GDBObjMText.CalcGabarit;
var
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
  else begin
    obj_height := 1;
    obj_width := 1;
  end;
end;

procedure GDBObjMText.createpoint;
var
  i:Integer;
  matr,m1: DMatrix4D;
  v:GDBvertex4D;
  Bound:TBoundingRect;
  lp:gdbvertex;
  pswp:pGDBStrWithPoint;
  ir:itrec;
  pl:GDBPoint3DArray;
  ispl:Boolean;
  pfont:pgdbfont;
  ln,l:Integer;
  sym:word;
begin
  ln:=0;
  pfont:=TXTStyle^.pfont;
  pl.init(10);
  ispl:=false;

  Bound.LB.x:=+infinity;
  Bound.LB.y:=+infinity;
  Bound.RT.x:=NegInfinity;
  Bound.RT.y:=NegInfinity;
  pswp:=text.beginiterate(ir);

  if pswp<>nil then
  repeat
    ln:=-1;
    matr:=DrawMatrix;

    m1.CreateRec(OneMtr,CMTShear);
    m1.mtr[3].v[0] := pswp^.x-(pswp^.y)*cotan(pi/2-textprop.oblique)/textprop.wfactor;
    m1.mtr[3].v[1] := pswp^.y;
    matr:=MatrixMultiply(m1,matr);

    i := 1;
    if ispl then begin
      lp:=pgdbvertex(@matr.mtr[3].v[0])^;
      lp.y:=lp.y-0.2*textprop.size;
      lp:=VectorTransform3d(lp,objmatrix);
      pl.PushBackData(lp);
    end;

    while i<=length(pswp^.str) do begin
      m1:=matr;
      sym:=getsymbol_fromGDBText(pswp^.str{[i]},i,l,pgdbfont(pfont)^.font.IsUnicode);
      if sym=1 then begin
        ispl:=not(ispl);
        if ispl then begin
          lp:=pgdbvertex(@matr.mtr[3].v[0])^;
          lp.y:=lp.y-0.2*textprop.size;
          lp:=VectorTransform3d(lp,objmatrix);
          pl.PushBackData(lp);
        end else begin
          lp:=pgdbvertex(@matr.mtr[3].v[0])^;
          lp.y:=lp.y-0.2*textprop.size;
          lp:=VectorTransform3d(lp,objmatrix);
          pl.PushBackData(lp);
        end;
      end else begin
        pfont.CreateSymbol(DC.drawer,Representation.GetGraphix^,sym,objmatrix,matr,Bound,ln);
        {matr:=m1;
        m1:=CreateTranslationMatrix(pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym).NextSymX,0,0);
        matr:=MatrixMultiply(m1,matr);}
        matr:=CreateTranslationMatrix(pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym).NextSymX,0,0);
        matr:=MatrixMultiply(matr,m1);
      end;
      inc(i,l);
    end;

    if ispl then begin
      lp:=pgdbvertex(@matr.mtr[3].v[0])^;
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

  pl.done;
  Representation.Shrink;
end;

function GDBObjMText.Clone;
var tvo: PGDBObjMtext;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjMText));
  tvo^.initnul(own);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.template:=template;
  tvo^.content:=content;
  tvo^.width:=width;
  tvo^.linespace:=linespace;
  tvo^.linespacef:=linespacef;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.TXTStyle:=TXTStyle;
  result := tvo;
end;
procedure GDBObjMText.LoadFromDXF;
var
  byt:Integer;
  ux:gdbvertex;
  //angleload: Boolean;
  //angle:double;
  j:Integer;
  style,ttemplate:String;
begin
  //angleload:=false;
  //angle:=0;
  ux.x:=1;
  ux.y:=0;
  ux.z:=0;
  style:='';
  ttemplate:='';
  j:=0;
  byt:=rdr.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing) then
    if not dxfvertexload(rdr,10,byt,Local.P_insert) then
    if not dxfvertexload(rdr,11,byt,ux) then
    if not dxfDoubleload(rdr,40,byt,textprop.size) then
    if not dxfDoubleload(rdr,41,byt,width) then
    if not dxfDoubleload(rdr,44,byt,linespacef) then
    if not dxfDoubleload(rdr,51,byt,textprop.oblique) then
    if not dxfIntegerload(rdr,71,byt,j)then
    if not dxfStringload(rdr,1,byt,ttemplate)then
    if not dxfStringload(rdr,3,byt,ttemplate)then
    {if dxfDoubleload(rdr,50,byt,angle) then angleload := true
    else }if dxfStringload(rdr,7,byt,style)then begin
      TXTStyle:=drawing.GetTextStyleTable^.FindStyle(Style,false);
      if TXTStyle=nil then
        TXTStyle:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
    end else
      rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if TXTStyle=nil then
    TXTStyle:=drawing.GetTextStyleTable^.FindStyle('Standard',false);
  OldVersTextReplace(ttemplate);
  OldVersTextReplace(Content);
  Content:=utf8tostring(Tria_AnsiToUtf8(ttemplate));
  textprop.justify:=b2j[j];
  P_drawInOCS := Local.p_insert;
  linespace := textprop.size * linespacef * 5 / 3;
  {if not angleload then
    angle:=vertexangle(NulVertex2D,pgdbvertex2d(@ux)^);}
  Local.basis.ox:=ux;
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
procedure GDBObjMText.SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var
  s: String;
  ul:boolean;
  quotedcontent:TDXFEntsInternalStringType;
  ASourcesCounter:TSPFSourceSet;
begin
  ul:=false;
  SaveToDXFObjPrefix(outStream,'MTEXT','AcDbMText',IODXFContext);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfDoubleout(outStream,40,textprop.size);
  dxfDoubleout(outStream,41,width);
  dxfIntegerout(outStream,71,j2b[textprop.justify]);
  s:=TxtFormatAndCountSrcs(template,SPFSources.GetFull,ASourcesCounter,@Self);
  if (ASourcesCounter and (not SPFSdxf))<>0 then begin
    quotedcontent:=StringReplace(content,TDXFEntsInternalStringType(#10),TDXFEntsInternalStringType('\P'),[rfReplaceAll]);
    if  {convertfromunicode}(template)=quotedcontent then
      s := Tria_Utf8ToAnsi(UTF8Encode(template))
    else
      s := Tria_Utf8ToAnsi(UTF8Encode(quotedcontent));
  end else begin
    s:=Tria_Utf8ToAnsi(UTF8Encode(template));
    IODXFContext.LocalEntityFlags:=IODXFContext.LocalEntityFlags or CLEFNotNeedSaveTemplate;
  end;
  s:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  //s := content;
  if length(s) < maxdxfmtextlen then
  begin
    dxfStringout(outStream,1,z2dxfmtext(s,ul));
  end
  else
  begin
    dxfStringout(outStream,1,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
    s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen);
    while length(s) > maxdxfmtextlen+1 do
    begin
      dxfStringout(outStream,3,z2dxfmtext(copy(s, 1, maxdxfmtextlen),ul));
      s := copy(s, maxdxfmtextlen+1, length(s) - maxdxfmtextlen)
    end;
    dxfStringout(outStream,3,z2dxfmtext(s,ul));
  end;
  dxfStringout(outStream,7,TXTStyle^.name);
  SaveToDXFObjPostfix(outStream);
  dxfvertexout(outStream,11,Local.basis.ox);
  dxfIntegerout(outStream,73,2);
  dxfDoubleout(outStream,44,3 * linespace / (5 * textprop.size));
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
