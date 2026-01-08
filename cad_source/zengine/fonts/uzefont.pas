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

unit uzefont;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses math,uzgldrawerabstract,uzgprimitivescreator,uzgprimitives,
     uzbstrproc,uzctnrVectorBytesStream,sysutils,uzbtypes,
     uzefontbase,uzegeometrytypes,uzegeometry,uzglvectorobject,
     gzctnrVectorTypes,uzeNamedObject;
type

PGDBfont=^GDBfont;
GDBfont= object(GDBNamedObject)
    fontfile:String;
    Internalname:String; // Международное полное имя с описанием авора
    family:String;
    fullname:String;
    font:TZEBaseFontImpl;
    DummyDrawerHandle:ptruint;
    constructor initnul;
    constructor init(const n:String);
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;
    procedure CreateSymbol(drawer:TZGLAbstractDrawer;TxtHeight:double;var geom:ZGLVectorObject;_symbol:Integer;const objmatrix:TzeTypedMatrix4d;matr:TzeTypedMatrix4d;var Bound:TBoundingRect;var LLSymbolLineIndex:TArrayIndex);
  end;

var
   pbasefont: PGDBfont;
procedure initfont(var pf:pgdbfont;name:String);

implementation

procedure initfont(var pf:pgdbfont;name:String);
begin
  pf^.init(name);
end;

procedure GDBfont.CreateSymbol(drawer:TZGLAbstractDrawer;TxtHeight:double;var geom:ZGLVectorObject;_symbol:Integer;const objmatrix:TzeTypedMatrix4d;matr:TzeTypedMatrix4d;var Bound:TBoundingRect;var LLSymbolLineIndex:TArrayIndex);
var
  v,v0,true0Y,fact0y:TzePoint3d;
  sqrsymh:Double;
  psyminfo:PGDBsymdolinfo;
  LLSymbolIndex:TArrayIndex;
  PLLPsymbol:PTLLSymbol;
  LLSymbolLineCreated:boolean;
  PLLSymbolLine:PTLLSymbolLine;
  VDCopyParam:TZGLVectorDataCopyParam;
  symoutbound:TBoundingBox;
begin
  LLSymbolIndex:=-1;
  LLSymbolLineCreated:=false;

  psyminfo:=self.GetOrReplaceSymbolInfo(integer(_symbol));
  if psyminfo.LLPrimitiveCount<>0 then begin
    if LLSymbolLineIndex=-1 then begin
      if drawer=nil then
        LLSymbolLineIndex:=DefaultLLPCreator.CreateLLSymbolLine(geom.LLprimitives)
      else
        LLSymbolLineIndex:=drawer.GetLLPrimitivesCreator.CreateLLSymbolLine(geom.LLprimitives);
      LLSymbolLineCreated:=true;
    end;
    if LLSymbolIndex=-1 then begin
      if drawer=nil then
        LLSymbolIndex:=DefaultLLPCreator.CreateLLSymbol(geom.LLprimitives)
      else
        LLSymbolIndex:=drawer.GetLLPrimitivesCreator.CreateLLSymbol(geom.LLprimitives);
    end;
    VDCopyParam:=font.FontData.GetCopyParam(psyminfo.LLPrimitiveStartIndex,psyminfo.LLPrimitiveCount);
    symoutbound:=font.FontData.GetTransformedBoundingBbox(VDCopyParam.EID.GeomIndexMin,VDCopyParam.EID.GeomIndexMax,matr);
    if Bound.LB.x>symoutbound.LBN.x then
      Bound.LB.x:=symoutbound.LBN.x;
    if Bound.LB.y>symoutbound.LBN.y then
      Bound.LB.y:=symoutbound.LBN.y;
    if Bound.RT.x<symoutbound.RTF.x then
      Bound.RT.x:=symoutbound.RTF.x;
    if Bound.RT.y<symoutbound.RTF.y then
      Bound.RT.y:=symoutbound.RTF.y;
  end;
  if LLSymbolIndex<>-1 then begin
    PLLPsymbol:=pointer(geom.LLprimitives.getDataMutable(LLSymbolIndex));
    PLLPsymbol^.SymSize:=geom.LLprimitives.Count-LLSymbolIndex;
    PLLPsymbol^.LineIndex:=-1;
    PLLPsymbol^.PExternalVectorObject:=@font.FontData;
    PLLPsymbol^.ExternalLLPOffset:=VDCopyParam.LLPrimitivesStartIndex;
    PLLPsymbol^.ExternalLLPCount:=psyminfo.LLPrimitiveCount;
    PLLPsymbol^.SymCode:=_symbol;
    PLLPsymbol^.SymMatr:=uzegeometry.MatrixMultiply{F}(matr,objmatrix);
    VDCopyParam:=font.FontData.GetCopyParam(psyminfo.LLPrimitiveStartIndex,psyminfo.LLPrimitiveCount);
    if VDCopyParam.EID.IndexsIndexMax>0 then
      PLLPsymbol^.Attrib:=LLAttrNeedSolid
    else
      PLLPsymbol^.Attrib:=LLAttrNothing;
    if (VDCopyParam.EID.GeomIndexMax-VDCopyParam.EID.GeomIndexMin)>4 then
      PLLPsymbol^.Attrib:=PLLPsymbol^.Attrib or  LLAttrNeedSimtlify;
    v0:=createvertex(psyminfo^.SymMinX,psyminfo^.SymMinY,0);
    v0:=VectorTransform3d(v0,matr);
    v0:=VectorTransform3d(v0,objmatrix);
    PLLPsymbol^.OutBoundIndex:=geom.GeomData.Vertex3S.AddGDBVertex(v0);
    v:=createvertex(psyminfo^.SymMinX,psyminfo^.SymMaxy,0);
    v:=VectorTransform3d(v,matr);
    v:=VectorTransform3d(v,objmatrix);
    geom.GeomData.Vertex3S.AddGDBVertex(v);
    sqrsymh:=SqrOneVertexlength(vertexsub(v,v0));
    v:=createvertex(psyminfo^.SymMaxx,psyminfo^.SymMaxy,0);
    v:=VectorTransform3d(v,matr);
    v:=VectorTransform3d(v,objmatrix);
    geom.GeomData.Vertex3S.AddGDBVertex(v);
    v:=createvertex(psyminfo^.SymMaxx,psyminfo^.SymMiny,0);
    v:=VectorTransform3d(v,matr);
    v:=VectorTransform3d(v,objmatrix);
    geom.GeomData.Vertex3S.AddGDBVertex(v);
    if LLSymbolLineIndex<>-1 then begin
      PLLPsymbol:=pointer(geom.LLprimitives.getDataMutable(LLSymbolIndex));
      PLLPsymbol^.LineIndex:=LLSymbolLineIndex;
      PLLSymbolLine:=pointer(geom.LLprimitives.getDataMutable(LLSymbolLineIndex));
      if LLSymbolLineCreated then begin
        PLLSymbolLine^.SymbolsParam.IsCanSystemDraw:=font.IsCanSystemDraw;
        font.SetupSymbolLineParams(matr,PLLSymbolLine^.SymbolsParam);
        PLLSymbolLine^.SymbolsParam.pfont:=@self;
        PLLSymbolLine^.FirstOutBoundIndex:=PLLPsymbol^.OutBoundIndex;
        PLLSymbolLine^.SymbolsParam.FirstSymMatr:=uzegeometry.MatrixMultiply(matr,objmatrix);
        PLLSymbolLine^.SymbolsParam.Rotate:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[0].v[0],PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[0].v[1]));
        PLLSymbolLine^.SymbolsParam.sx:=oneVertexlength(PzePoint3d(@PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[0])^)/oneVertexlength(PzePoint3d(@PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[1])^);
        true0Y:=VectorDot(PzePoint3d(@PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[2])^,PzePoint3d(@PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[0])^);
        if not IsVectorNul(true0Y) then
          true0Y:=NormalizeVertex(true0Y);
        fact0y:=PzePoint3d(@PLLSymbolLine^.SymbolsParam.FirstSymMatr.mtr.v[1])^;
        if not IsVectorNul(fact0y) then
          fact0y:=NormalizeVertex(fact0y);
        PLLSymbolLine^.SymbolsParam.Oblique:=arccos(scalardot(true0Y,fact0y));
        PLLSymbolLine^.SymbolsParam.NeededFontHeight:=PLLSymbolLine^.SymbolsParam.NeededFontHeight*cos(PLLSymbolLine^.SymbolsParam.Oblique);
        PLLSymbolLine^.SymbolsParam.sx:=PLLSymbolLine^.SymbolsParam.sx/cos(PLLSymbolLine^.SymbolsParam.Oblique);
        if GetCSDirFrom0x0y2D(true0Y,fact0y)=TCSDLeft then
          PLLSymbolLine^.SymbolsParam.Oblique:=-PLLSymbolLine^.SymbolsParam.Oblique;
      end;
      PLLSymbolLine^.LastOutBoundIndex:=PLLPsymbol^.OutBoundIndex;
      if sqrsymh>PLLSymbolLine.MaxSqrSymH then
        PLLSymbolLine.MaxSqrSymH:=sqrsymh;
      PLLSymbolLine.txtHeight:=TxtHeight;
    end;
    DefaultLLPCreator.CreateLLSymbolEnd(geom.LLprimitives);
  end;
end;
constructor GDBfont.initnul;
begin
  inherited;
  pointer(fontfile):=nil;
  DummyDrawerHandle:=0;
end;
destructor GDBfont.done;
begin
  fontfile:='';
  Internalname:='';
  family:='';
  fullname:='';
  if font<>nil then
    freeandnil(font);
  inherited;
end;
constructor GDBfont.Init;
begin
  initnul;
  inherited;
  font:=nil;
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;
begin
  result:=font.GetOrReplaceSymbolInfo(symbol);
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
begin
  result:=font.GetOrCreateSymbolInfo(symbol);
end;
begin
end.
