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
  uzglgeometry,uzgldrawcontext,uzetextpreprocessor,uzeentityfactory,
  uzedrawingdef,uzbstrproc,uzefont,uzeentabstracttext,UGDBPoint3DArray,
  uzestyleslayers,SysUtils,uzeentity,uzctnrVectorBytes,uzbtypes,uzeenttext,
  uzeconsts,uzegeometry,uzeffdxfsupport,Math,uzeentsubordinated,
  gzctnrVectorTypes,uzegeometrytypes,uzestylestexts,StrUtils,gzctnrVector,
  uzMVReader,uzcTextPreprocessorDXFImpl;

type
  PGDBXYZWStringArray=^XYZWStringArray;

  XYZWStringArray=object(GZVector<GDBStrWithPoint>)
  end;
  PGDBObjMText=^GDBObjMText;

  GDBObjMText=object(GDBObjText)
    Width:double;
    linespacef:double;
    Text:XYZWStringArray;
    constructor init(own:Pointer;ALayer:PGDBLayerProp;LW:smallint;
      c:TDXFEntsInternalStringType;p:TzePoint3d;s,o,w,a:double;j:TTextJustify;
      wi,l:double);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure CalcGabarit(const drawing:TDrawingDef);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatContent(var drawing:TDrawingDef);virtual;
    procedure createpoint(const drawing:TDrawingDef;var DC:TDrawContext);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    destructor done;virtual;
    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
    function CreateInstance:PGDBObjMText;static;
    function GetObjType:TObjID;virtual;
    procedure transform(const t_matrix:DMatrix4d);virtual;
    function GetLineSpace:double;
    procedure rtsave(refp:Pointer);virtual;
    property LineSpace:double read GetLineSpace;
  end;

procedure FormatMtext(pfont:pgdbfont;Width,size,wfactor:double;
  const content:TDXFEntsInternalStringType;var Text:XYZWStringArray);
function GetLinesH(linespace,size:double;var Lines:XYZWStringArray):double;
function GetLinesW(var Lines:XYZWStringArray):double;
function GetLineSpaceFromLineSpaceF(linespacef,size:double):double;

implementation

procedure GDBObjMText.rtsave(refp:Pointer);
begin
  inherited;
  PGDBObjMText(refp)^.Width:=Width;
  PGDBObjMText(refp)^.linespacef:=linespacef;
end;


function GDBObjMText.GetLineSpace:double;
begin
  Result:=GetLineSpaceFromLineSpaceF(linespacef,textprop.size);
end;

procedure GDBObjMText.transform;
var
  tv:TzePoint3d;
  m:DMatrix4d;
begin
  tv:=CreateVertex(Width,0,0);
  m:=t_matrix;
  PzePoint3d(@m.mtr[3])^:=NulVertex;
  tv:=VectorTransform3d(tv,m);
  Width:=oneVertexlength(tv);
  inherited;
end;


procedure GDBObjMText.FormatAfterDXFLoad;
begin
  formatcontent(drawing);
  calcobjmatrix;
  CalcGabarit(drawing);
  calcbb(dc);
end;

function GDBObjMText.GetObjTypeName;
begin
  Result:=ObjN_GDBObjMText;
end;

destructor GDBObjMText.done;
begin
  Text.Done;
  inherited done;
end;

constructor GDBObjMText.initnul;
begin
  inherited initnul(owner);
  Width:=0;
  Text.init(10);
end;

constructor GDBObjMText.init;
begin
  inherited init(own,ALayer,lw,c,p,s,o,w,a,j);
  Width:=wi;
  linespacef:=l;
  {TODO: тут расчет AAA ненужен}
  Local.basis.ox:=GetXfFromZ(Local.basis.oz);

  local.basis.OX:=VectorTransform3D(
    local.basis.OX,uzegeometry.CreateAffineRotationMatrix(Local.basis.oz,-a));
  Text.init(10);
end;

function GDBObjMText.GetObjType;
begin
  Result:=GDBMtextID;
end;

function GetLineSpaceFromLineSpaceF(linespacef,size:double):double;
begin
  Result:=size*linespacef*5/3;
end;

function GetLinesH(linespace,size:double;var Lines:XYZWStringArray):double;
begin
  if Lines.Count>0 then
    Result:=(Lines.Count-1)*linespace+size
  else
    Result:=0;
end;

function GetLinesW(var Lines:XYZWStringArray):double;
var
  pswp:pGDBStrWithPoint;
  ir:itrec;
begin
  pswp:=Lines.beginiterate(ir);
  if pswp<>nil then begin
    Result:=pswp^.w;
    pswp:=Lines.iterate(ir);
    if pswp<>nil then
      repeat
        if Result<pswp^.w then
          Result:=pswp^.w;
        pswp:=Lines.iterate(ir);
      until pswp=nil;
  end else
    Result:=0;
end;

procedure FormatMtext(pfont:pgdbfont;Width,size,wfactor:double;
  const content:TDXFEntsInternalStringType;var Text:XYZWStringArray);
var
  canbreak:boolean;
  currsymbol,lastbreak,lastcanbreak:integer;
  linewidth,lastlinewidth,maxlinewidth,lastsymspace:double;
  currline:TDXFEntsInternalStringType;
  swp:GDBStrWithPoint;
  psyminfo:PGDBsymdolinfo;
  l:integer;
  sym:word;
  newline:boolean;
  _NeedSpaceWidthCalc:boolean;
  _SpaceWidth:double;

  function SpaceWidth:double;inline;
  begin
    if _NeedSpaceWidthCalc then begin
      _NeedSpaceWidthCalc:=False;
      _SpaceWidth:=pgdbfont(pbasefont)^.GetOrReplaceSymbolInfo(32).NextSymX;
    end;
    Result:=_SpaceWidth;
  end;

begin
  _NeedSpaceWidthCalc:=True;
  _SpaceWidth:=1;
  swp.str:='';
  canbreak:=False;
  currsymbol:=1;
  lastbreak:=1;
  lastcanbreak:=1;
  linewidth:=0;
  lastsymspace:=0;
  newline:=True;
  lastlinewidth:=0;
  currline:='';
  maxlinewidth:=Width/(size*wfactor);
  if content<>'' then begin
    repeat
      sym:=getsymbol_fromGDBText(content,currsymbol,l,pgdbfont(pfont)^.font.IsUnicode);
      psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
      if newline then begin
        linewidth:=linewidth-psyminfo.SymMinX;
        newline:=False;
      end;
      if (sym=32)and(maxlinewidth>0) then begin
        lastcanbreak:=currsymbol;
        canbreak:=True;
        lastlinewidth:=linewidth;
        linewidth:=lastsymspace+linewidth+psyminfo.SymMaxX;
        lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
      end else if sym=10 then begin
        currline:=copy(content,lastbreak,currsymbol-lastbreak);
        if sym<>10 then begin
          lastbreak:=currsymbol+2;
          currsymbol:=currsymbol+1;
        end else begin
          lastbreak:=currsymbol+1;
        end;
        psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
        canbreak:=False;
        swp.Str:=currline;
        swp.w:=linewidth;
        if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
          swp.str:=copy(swp.str,1,length(swp.str)-1);
          swp.w:=swp.w-SpaceWidth;
        end;
        Text.PushBackData(swp);
        newline:=True;
        linewidth:=0;
        lastsymspace:=0;
        lastlinewidth:=linewidth;
      end else begin
        linewidth:=lastsymspace+linewidth+psyminfo.SymMaxX;
        lastsymspace:=psyminfo.NextSymX-psyminfo.SymMaxX;
      end;
      if canbreak then
        if maxlinewidth<=linewidth then begin
          currline:=copy(content,lastbreak,lastcanbreak-lastbreak);
          linewidth:=0;
          lastsymspace:=0;
          newline:=True;
          lastbreak:=lastcanbreak+1;
          currsymbol:=lastcanbreak;
          psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(sym);
          canbreak:=False;
          swp.Str:=currline;
          swp.w:=lastlinewidth;
          if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
            swp.str:=copy(swp.str,1,length(swp.str)-1);
            swp.w:=swp.w-SpaceWidth;
          end;
          Text.PushBackData(swp);
        end;
      Inc(currsymbol,l);
    until currsymbol>length(content);
  end;
  if linewidth=0 then
    linewidth:=1;
  currline:=copy(content,lastbreak,currsymbol-lastbreak);
  swp.Str:=currline;
  swp.w:=linewidth;
  if (length(swp.str)>0)and(swp.str[length(swp.str)]=' ') then begin
    swp.str:=copy(swp.str,1,length(swp.str)-1);
    swp.w:=swp.w-SpaceWidth;
  end;
  Text.PushBackData(swp);
end;

procedure GDBObjMText.FormatContent(var drawing:TDrawingDef);
var
  i:integer;
  h,angle:double;
  pswp:pGDBStrWithPoint;
  ir:itrec;
  psyminfo:PGDBsymdolinfo;
  TCP:TCodePage;
  pfont:pgdbfont;
  l:integer;
  sym:word;
  LdivideS:double;
  ActualContent:TDXFEntsInternalStringType;

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
  LdivideS:=linespace/textprop.size;
  if (content='')and(template='') then
    content:=str_empty;

  Text.Free;
  lod:=0;

  P_drawInOCS:=NulVertex;

  //обрезание перевода строки в конце строки
  //странно что в автокаде он обрезается только один
  //https://github.com/zamtmn/zcad/issues/188
  if Length(Content)>0 then begin
    if Content[Length(Content)]=#10 then
      ActualContent:=Content[1..Length(Content)-1]
    else
      ActualContent:=Content;
  end else
    ActualContent:=Content;

  FormatMtext(pfont,Width,textprop.size,textprop.wfactor,ActualContent,Text);

  h:=GetLinesH(linespace,textprop.size,Text);

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
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jstc:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/2/textprop.size;;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jstr:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/textprop.size;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsml:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h/2;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsmc:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h/2;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/2/textprop.size;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsmr:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h/2;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/textprop.size;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsbl:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsbc:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/2/textprop.size;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
    jsbr:
    begin
      P_drawInOCS.y:=P_drawInOCS.y-textprop.size+h;
      i:=0;
      pswp:=Text.beginiterate(ir);
      if pswp<>nil then
        repeat
          setstartx;
          pswp^.x:=pswp^.x-pswp^.w*textprop.size/textprop.size;
          pswp^.y:=-(i)*LdivideS;

          pswp^.x:=pswp^.x-pswp^.y*angle;
          Inc(i);
          pswp:=Text.iterate(ir);
        until pswp=nil;
    end;
  end;
end;

procedure GDBObjMText.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    calcobjmatrix;
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin

    formatcontent(drawing);
    calcobjmatrix;
    CalcGabarit(drawing);
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      Representation.Clear;
      createpoint(drawing,dc);
    end;
    calcbb(dc);

    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

function GDBObjMText.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjMText.CalcGabarit;
var
  pswp:pGDBStrWithPoint;
  ir:itrec;
begin
  obj_height:=0;
  obj_width:=0;
  obj_y:=0;
  pswp:=Text.beginiterate(ir);
  if pswp<>nil then
    repeat
      if obj_width<pswp^.w then
        obj_width:=pswp^.w;
      pswp:=Text.iterate(ir);
    until pswp=nil;
  if Text.Count>0 then
    obj_height:=((self.Text.Count-1)*linespace+textprop.size)/textprop.size
  else begin
    obj_height:=1;
    obj_width:=1;
  end;
end;

procedure GDBObjMText.createpoint;
var
  i:integer;
  matr,m1:DMatrix4d;
  v:TzeVector4d;
  Bound:TBoundingRect;
  lp:TzePoint3d;
  pswp:pGDBStrWithPoint;
  ir:itrec;
  pl:GDBPoint3DArray;
  ispl:boolean;
  pfont:pgdbfont;
  ln,l:integer;
  sym:word;
begin
  ln:=0;
  pfont:=TXTStyle^.pfont;
  pl.init(10);
  ispl:=False;

  Bound.LB.x:=+infinity;
  Bound.LB.y:=+infinity;
  Bound.RT.x:=NegInfinity;
  Bound.RT.y:=NegInfinity;
  pswp:=Text.beginiterate(ir);

  if pswp<>nil then
    repeat
      ln:=-1;
      matr:=DrawMatrix;

      m1.CreateRec(OneMtr,CMTShear);
      m1.mtr[3].v[0]:=pswp^.x-(pswp^.y)*cotan(pi/2-textprop.oblique)/textprop.wfactor;
      m1.mtr[3].v[1]:=pswp^.y;
      matr:=MatrixMultiply(m1,matr);

      i:=1;
      if ispl then begin
        lp:=PzePoint3d(@matr.mtr[3].v[0])^;
        lp.y:=lp.y-0.2*textprop.size;
        lp:=VectorTransform3d(lp,objmatrix);
        pl.PushBackData(lp);
      end;

      while i<=length(pswp^.str) do begin
        m1:=matr;
        sym:=getsymbol_fromGDBText(pswp^.str,i,l,pgdbfont(pfont)^.font.IsUnicode);
        if sym=1 then begin
          ispl:=not(ispl);
          if ispl then begin
            lp:=PzePoint3d(@matr.mtr[3].v[0])^;
            lp.y:=lp.y-0.2*textprop.size;
            lp:=VectorTransform3d(lp,objmatrix);
            pl.PushBackData(lp);
          end else begin
            lp:=PzePoint3d(@matr.mtr[3].v[0])^;
            lp.y:=lp.y-0.2*textprop.size;
            lp:=VectorTransform3d(lp,objmatrix);
            pl.PushBackData(lp);
          end;
        end else begin
          pfont.CreateSymbol(DC.drawer,textprop.size,Representation.GetGraphix^,
            sym,objmatrix,matr,Bound,ln);
          matr:=CreateTranslationMatrix(pgdbfont(pfont)^.GetOrReplaceSymbolInfo(
            sym).NextSymX,0,0);
          matr:=MatrixMultiply(matr,m1);
        end;
        Inc(i,l);
      end;

      if ispl then begin
        lp:=PzePoint3d(@matr.mtr[3].v[0])^;
        lp.y:=lp.y-0.2*textprop.size;
        lp:=VectorTransform3d(lp,objmatrix);
        pl.PushBackData(lp);
      end;
      pswp:=Text.iterate(ir);
    until pswp=nil;

  if Bound.LB.x=+infinity then
    Bound.LB.x:=0;
  if Bound.LB.y=+infinity then
    Bound.LB.y:=0;
  if Bound.RT.x=NegInfinity then
    Bound.RT.x:=1;
  if Bound.RT.y=NegInfinity then
    Bound.RT.y:=1;

  v.x:=Bound.LB.x;
  v.y:=Bound.RT.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=PzePoint3d(@v)^;
  v.x:=Bound.RT.x;
  v.y:=Bound.RT.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=PzePoint3d(@v)^;
  v.x:=Bound.RT.x;
  v.y:=Bound.LB.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=PzePoint3d(@v)^;
  v.x:=Bound.LB.x;
  v.y:=Bound.LB.y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=PzePoint3d(@v)^;

  pl.done;
  Representation.Shrink;
end;

function GDBObjMText.Clone;
var
  tvo:PGDBObjMtext;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjMText));
  tvo^.initnul(own);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.template:=template;
  tvo^.content:=content;
  tvo^.Width:=Width;
  tvo^.linespacef:=linespacef;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.TXTStyle:=TXTStyle;
  Result:=tvo;
end;

procedure GDBObjMText.LoadFromDXF;
var
  byt:integer;
  ux:TzePoint3d;
  j:integer;
  style,ttemplate:string;
begin
  ux.x:=1;
  ux.y:=0;
  ux.z:=0;
  style:='';
  ttemplate:='';
  j:=0;
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,Local.P_insert) then
        if not dxfLoadGroupCodeVertex(rdr,11,byt,ux) then
          if not dxfLoadGroupCodeDouble(rdr,40,byt,textprop.size) then
            if not dxfLoadGroupCodeDouble(rdr,41,byt,Width) then
              if not dxfLoadGroupCodeDouble(rdr,44,byt,linespacef) then
                if not dxfLoadGroupCodeDouble(rdr,51,byt,textprop.oblique) then
                  if not dxfLoadGroupCodeInteger(rdr,71,byt,j) then
                    if not dxfLoadGroupCodeString(
                      rdr,1,byt,ttemplate,context.Header) then
                      if not dxfLoadGroupCodeString(
                        rdr,3,byt,ttemplate,context.Header) then
                        if dxfLoadGroupCodeString(rdr,7,byt,style) then begin
                          TXTStyle:=drawing.GetTextStyleTable^.FindStyle(Style,False);
                          if TXTStyle=nil then
                            TXTStyle:=
                              pointer(drawing.GetTextStyleTable^.getDataMutable(0));
                        end else
                          rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if TXTStyle=nil then
    TXTStyle:=drawing.GetTextStyleTable^.FindStyle('Standard',False);
  if IsZero(linespacef) then
    linespacef:=1;
  OldVersTextReplace(ttemplate);
  OldVersTextReplace(Content);
  Content:=utf8tostring(ttemplate);
  textprop.justify:=b2j[j];
  P_drawInOCS:=Local.p_insert;
  Local.basis.ox:=ux;
end;

function z2dxfmtext(s:string;var ul:boolean):string;
var
  Count:integer;
begin
  Result:=s;
  repeat
    if not(ul) then
      Result:=StringReplace(Result,#1,'\L',[],Count)
    else
      Result:=StringReplace(Result,#1,'\l',[],Count);
    ul:=not(ul);
  until Count=0;
end;

procedure GDBObjMText.SaveToDXF(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;
  var IODXFContext:TIODXFSaveContext);
const
  maxdxfmtextlen=250;
var
  s:string;
  ul:boolean;
  quotedcontent:TDXFEntsInternalStringType;
  ASourcesCounter:TSPFSourceSet;
begin
  ul:=False;
  SaveToDXFObjPrefix(outStream,'MTEXT','AcDbMText',IODXFContext);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfDoubleout(outStream,40,textprop.size);
  dxfDoubleout(outStream,41,Width);
  dxfIntegerout(outStream,71,j2b[textprop.justify]);
  //проверяем есть ли в шаблоне управляющие последовательности
  //отсутствующие в dxf
  s:=TxtFormatAndCountSrcs(template,SPFSources.GetFull,ASourcesCounter,@Self);
  if (ASourcesCounter and (not SPFSdxf))<>0 then begin
    //шаблон dxf НЕсовместим, разворачиваем всё кроме dxf последовательностей
    //пишем dxf совместимое содержимое, шаблом сохраним отдельно
    quotedcontent:=TxtFormatAndCountSrcs(template,SPFSources.GetFull and
      (not SPFSdxf),ASourcesCounter,@Self);
    s:=UTF8Encode(quotedcontent);
  end else begin
    //шаблон dxf совместим, пишем сразу его,
    //отдельно его дописывать в расширенные данные ненадо
    s:=UTF8Encode(template);
    IODXFContext.LocalEntityFlags:=IODXFContext.LocalEntityFlags or
      CLEFNotNeedSaveTemplate;
  end;
  //убираем переносы строки, они портят dxf
  s:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  s:=dxfEnCodeString(s,IODXFContext.Header);
  if length(s)<maxdxfmtextlen then begin
    dxfStringout(outStream,1,z2dxfmtext(s,ul));
  end else begin
    dxfStringout(outStream,1,z2dxfmtext(copy(s,1,maxdxfmtextlen),ul));
    s:=copy(s,maxdxfmtextlen+1,length(s)-maxdxfmtextlen);
    while length(s)>maxdxfmtextlen+1 do begin
      dxfStringout(outStream,3,z2dxfmtext(copy(s,1,maxdxfmtextlen),ul));
      s:=copy(s,maxdxfmtextlen+1,length(s)-maxdxfmtextlen);
    end;
    dxfStringout(outStream,3,z2dxfmtext(s,ul));
  end;
  dxfStringout(outStream,7,TXTStyle^.Name);
  SaveToDXFObjPostfix(outStream);
  dxfvertexout(outStream,11,Local.basis.ox);
  dxfIntegerout(outStream,73,2);
  dxfDoubleout(outStream,44,3*linespace/(5*textprop.size));
end;

function AllocMText:PGDBObjMText;
begin
  Getmem(Result,sizeof(GDBObjMText));
end;

function AllocAndInitMText(owner:PGDBObjGenericWithSubordinated):PGDBObjMText;
begin
  Result:=AllocMText;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

function GDBObjMText.CreateInstance:PGDBObjMText;
begin
  Result:=AllocAndInitMText(nil);
end;

begin
  RegisterDXFEntity(GDBMTextID,'MTEXT','MText',@AllocMText,@AllocAndInitMText);
end.
