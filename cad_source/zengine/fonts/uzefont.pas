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
{$INCLUDE zengineconfig.inc}
interface
uses math,uzgldrawerabstract,uzgprimitivescreator,uzgprimitives,
     uzbstrproc,uzctnrVectorBytes,sysutils,uzbtypes,
     uzefontbase,uzegeometrytypes,uzegeometry,uzglvectorobject,
     gzctnrVectorTypes,uzeNamedObject;
type
{EXPORT+}
PGDBfont=^GDBfont;
{REGISTEROBJECTTYPE GDBfont}
GDBfont= object(GDBNamedObject)
    fontfile:String;
    Internalname:String; // Международное полное имя с описанием авора
    family:String;
    fullname:String;
    font:PBASEFont;
    DummyDrawerHandle:{THandle}ptruint;
    constructor initnul;
    constructor init(n:String);
    //procedure ItSHX;
    //procedure ItFFT;
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
    procedure CreateSymbol(drawer:TZGLAbstractDrawer;var geom:ZGLVectorObject;_symbol:Integer;const objmatrix:DMatrix4D;matr:DMatrix4D;var Bound:TBoundingRect;var LLSymbolLineIndex:TArrayIndex);
  end;
{EXPORT-}
var
   pbasefont: PGDBfont;
procedure initfont(var pf:pgdbfont;name:String);
implementation
//uses {math,}log;
procedure initfont(var pf:pgdbfont;name:String);
//var i:integer;
begin
     //Getmem(Pointer(pf),sizeof(gdbfont));
     pf^.init(name);
     //pf.ItSHX;
end;

procedure GDBfont.CreateSymbol(drawer:TZGLAbstractDrawer;var geom:ZGLVectorObject;_symbol:Integer;const objmatrix:DMatrix4D;matr:DMatrix4D;var Bound:TBoundingRect;var LLSymbolLineIndex:TArrayIndex);
var
  v,v0,true0Y,fact0y:GDBvertex;
  sqrsymh{,CapHeight}:Double;
  psyminfo:PGDBsymdolinfo;

  LLSymbolIndex:TArrayIndex;
  PLLPsymbol:PTLLSymbol;
  LLSymbolLineCreated:boolean;
  PLLSymbolLine:PTLLSymbolLine;
  VDCopyParam{,VDCopyResultParam}:TZGLVectorDataCopyParam;
  symoutbound:TBoundingBox;
  //offset:TEntIndexesOffsetData;
begin
//  if _symbol=100 then
//                      _symbol:=_symbol;
  {if _symbol<256 then
                    _symbol:=ach2uch(_symbol);}
//  if _symbol=32 then
//                      _symbol:=_symbol;
  LLSymbolIndex:=-1;
  //trcount:=0;
  LLSymbolLineCreated:=false;

  psyminfo:=self.GetOrReplaceSymbolInfo(integer(_symbol){//-ttf-//,TDInfo});
  {//-ttf-//if tdinfo.TrianglesSize>0 then
  begin
    if LLSymbolLineIndex=-1 then
                                begin
                                  LLSymbolLineIndex:=geom.LLprimitives.AddLLPSymbolLine;
                                  LLSymbolLineCreated:=true;
                                end;
       LLSymbolIndex:=geom.LLprimitives.AddLLPSymbol;
       PTriangles:=self.font.GetTriangleDataAddr(TDInfo.TrianglesAddr);
       for j:=1 to tdinfo.TrianglesSize do
       begin
            v3.x:=PTriangles.x;
            v3.y:=PTriangles.y;
            v3.z:=0;
            v3:=VectorTransform3D(v3,matr);
            v3:=VectorTransform3D(v3,objmatrix);
            //geom.Triangles.Add(@v3);

            if (j mod 3)=1 then
                               begin
                                    geom.LLprimitives.AddLLTriangle(geom.GeomData.Vertex3S.AddGDBVertex(v3));
                                    inc(PrimitivesCount);
                               end
                           else
                               geom.GeomData.Vertex3S.AddGDBVertex(v3);

            inc(PTriangles);
            inc(trcount);
       end;
  end;}
  //psymbol := self.font.GetSymbolDataAddr(psyminfo.addr);
  if psyminfo.LLPrimitiveCount<>0 then
  begin;
       if LLSymbolLineIndex=-1 then
                                   begin
                                        if drawer=nil then
                                                          LLSymbolLineIndex:=DefaultLLPCreator.CreateLLSymbolLine(geom.LLprimitives)
                                                      else
                                                          LLSymbolLineIndex:=drawer.GetLLPrimitivesCreator.CreateLLSymbolLine(geom.LLprimitives);
                                     LLSymbolLineCreated:=true;
                                   end;
       if LLSymbolIndex=-1 then
                               begin
                                    if drawer=nil then
                                                      LLSymbolIndex:={geom.LLprimitives}DefaultLLPCreator.CreateLLSymbol(geom.LLprimitives)
                                                  else
                                                      LLSymbolIndex:=drawer.GetLLPrimitivesCreator.CreateLLSymbol(geom.LLprimitives);
                               end;
    VDCopyParam:=font.FontData.GetCopyParam(psyminfo.LLPrimitiveStartIndex,psyminfo.LLPrimitiveCount);
    //VDCopyResultParam:=font.FontData.CopyTo(geom,VDCopyParam);
    //offset.GeomIndexOffset:=VDCopyResultParam.EID.GeomIndexMin-VDCopyParam.EID.GeomIndexMin;
    //offset.IndexsIndexOffset:=VDCopyResultParam.EID.IndexsIndexMin-VDCopyParam.EID.IndexsIndexMin;
    //geom.CorrectIndexes(VDCopyResultParam.LLPrimitivesStartIndex,psyminfo.LLPrimitiveCount,VDCopyResultParam.EID.IndexsIndexMin,VDCopyResultParam.EID.IndexsIndexMax-VDCopyResultParam.EID.IndexsIndexMin+1,offset);
    //geom.MulOnMatrix(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax,matr);
    symoutbound:=font.FontData.GetTransformedBoundingBbox(VDCopyParam.EID.GeomIndexMin,VDCopyParam.EID.GeomIndexMax,matr);
    ////symoutbound:=geom.GetBoundingBbox(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax);
    //geom.MulOnMatrix(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax,objmatrix);
    if Bound.LB.x>symoutbound.LBN.x then
                                   Bound.LB.x:=symoutbound.LBN.x;
    if Bound.LB.y>symoutbound.LBN.y then
                                   Bound.LB.y:=symoutbound.LBN.y;
    if Bound.RT.x<symoutbound.RTF.x then
                                   Bound.RT.x:=symoutbound.RTF.x;
    if Bound.RT.y<symoutbound.RTF.y then
                                   Bound.RT.y:=symoutbound.RTF.y;

    //PrimitivesCount:=0;
    {for j := 1 to psyminfo.size do
    begin
      case Byte(psymbol^) of
        SHXLine:
          begin
            inc(PByte(psymbol), sizeof(SHXLine));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            //v.w:=1;
            v:=VectorTransform3d(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;

            v:=VectorTransform3d(v,objmatrix);

            pv3.coord:=v;

            geom.LLprimitives.AddLLPLine(geom.GeomData.Vertex3S.AddGDBVertex(v));

            //tv:=pv3.coord;
            pv3.LineNumber:=LLSymbolLineIndex;

            pv3.count:=0;
            //geom.SHX.add(@pv3);

            //inc(PByte(psymbol), 2 * sizeof(Double));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            //v.w:=1;
            v:=VectorTransform3d(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform3d(v,objmatrix);
            pv3.coord:=v;
            pv3.count:=0;

            geom.GeomData.Vertex3S.AddGDBVertex(v);

            pv3.LineNumber:=LLSymbolLineIndex;

            inc(PrimitivesCount);

            //geom.SHX.add(@pv3);


            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;
            //inc(PByte(psymbol), 2 * sizeof(Double));
          end;
        SHXPoly:
          begin
            inc(PByte(psymbol), sizeof(SHXPoly));
            len := Word(psymbol^);
            inc(PByte(psymbol), sizeof(Word));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            //v.w:=1;
            v:=VectorTransform3d(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=len;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform3d(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=len;

            //tv:=pv3.coord;
            pv3.LineNumber:=LLSymbolLineIndex;

            geom.LLprimitives.AddLLPPolyLine(geom.GeomData.Vertex3S.AddGDBVertex(v),len-1);

            //geom.SHX.add(@pv3);


            //inc(PByte(psymbol), 2 * sizeof(Double));
            k := 1;
            while k < len do //for k:=1 to len-1 do
            begin
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            //v.w:=1;

            v:=VectorTransform3d(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform3d(v,objmatrix);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=-1;

            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=k-len+1;

            pv3.LineNumber:=LLSymbolLineIndex;
            //tv:=pv3.coord;

            //geom.SHX.add(@pv3);

            geom.GeomData.Vertex3S.AddGDBVertex(v);


            //inc(PByte(psymbol), 2 * sizeof(Double));
            inc(k);
            inc(PrimitivesCount);
            end;
          end;
      end;
    end;}
  end;
  if LLSymbolIndex<>-1 then
  begin
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
  if ({VDCopyResultParam}VDCopyParam.EID.GeomIndexMax-{VDCopyResultParam}VDCopyParam.EID.GeomIndexMin)>4 then
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
  if LLSymbolLineIndex<>-1 then
  begin
    PLLPsymbol:=pointer(geom.LLprimitives.getDataMutable(LLSymbolIndex));
    PLLPsymbol^.LineIndex:=LLSymbolLineIndex;
    PLLSymbolLine:=pointer(geom.LLprimitives.getDataMutable(LLSymbolLineIndex));
    if LLSymbolLineCreated then
                               begin
                                    PLLSymbolLine^.SymbolsParam.IsCanSystemDraw:=font^.IsCanSystemDraw;
                                    font^.SetupSymbolLineParams(matr,PLLSymbolLine^.SymbolsParam);
                                    PLLSymbolLine^.SymbolsParam.pfont:=@self;
                                    (*if PLLSymbolLine^.SymbolsParam.IsCanSystemDraw then
                                    begin
                                         //CapHeight:=PTTFFont(font)^.ftFont.CapHeight;
                                         //PLLSymbolLine^.SymbolsParam.NeededFontHeight:=psyminfo^.h*psyminfo^.h*sqrsymh/(PTTFFont(font)^.ftFont.DPI / 72)/(PTTFFont(font)^.ftFont.DPI / 72);
                                         PLLSymbolLine^.SymbolsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr[1])^)*((PTTFFont(font)^.ftFont.Ascent+PTTFFont(font)^.ftFont.Descent)/(PTTFFont(font)^.ftFont.CapHeight));

                                         PLLSymbolLine^.SymbolsParam.pfont:=@self;
                                    end;*)

                                    PLLSymbolLine^.FirstOutBoundIndex:=PLLPsymbol^.OutBoundIndex;
                                    PLLSymbolLine^.SymbolsParam.FirstSymMatr:=uzegeometry.MatrixMultiply(matr,objmatrix);
                                    PLLSymbolLine^.SymbolsParam.Rotate:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(PLLSymbolLine^.SymbolsParam.FirstSymMatr[0].v[0],PLLSymbolLine^.SymbolsParam.FirstSymMatr[0].v[1]));

                                    PLLSymbolLine^.SymbolsParam.sx:=oneVertexlength(PGDBVertex(@PLLSymbolLine^.SymbolsParam.FirstSymMatr[0])^)/oneVertexlength(PGDBVertex(@PLLSymbolLine^.SymbolsParam.FirstSymMatr[1])^);

                                    true0Y:=CrossVertex(PGDBVertex(@PLLSymbolLine^.SymbolsParam.FirstSymMatr[2])^,PGDBVertex(@PLLSymbolLine^.SymbolsParam.FirstSymMatr[0])^);

                                    if not IsVectorNul(true0Y) then
                                      true0Y:=NormalizeVertex(true0Y);
                                    fact0y:=PGDBVertex(@PLLSymbolLine^.SymbolsParam.FirstSymMatr[1])^;
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
                      begin
                           font.done;
                           Freemem(pointer(font));
                      end;
     inherited;
end;
(*procedure GDBfont.ItSHX;
begin
     Getmem(font,sizeof(SHXFont));
     PSHXFont(font)^.init;
end;*)
(*procedure GDBfont.ItFFT;
begin
     Getmem(font,sizeof(TTFFont));
     PTTFFont(font)^.init;
end;*)
constructor GDBfont.Init;
begin
     initnul;
     inherited;
     font:=nil;
     {Getmem(font,sizeof(SHXFont));
     font^.init;}
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     result:=font.GetOrReplaceSymbolInfo(symbol{//-ttf-//,TrianglesDataInfo});
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
begin
     result:=font.GetOrCreateSymbolInfo(symbol);
end;
begin
end.
