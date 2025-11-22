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

unit uzeFontFileFormatTTF;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgprimitivescreator,uzgprimitives,uzglvectorobject,uzefontbase,
  uzebeziersolver,math,uzgloglstatemanager,uzegluinterface,
  usimplegenerics,EasyLazFreeType,uzbstrproc,sysutils,
  uzegeometrytypes,uzbtypes,uzegeometry,gzctnrSTL,gzctnrVectorTypes,uzbLogIntf,
  uzeFontFileFormatTTFBackend,
  {$IFDEF USELAZFREETYPETTFIMPLEMENTATION}uzeFontFileFormatTTFBackendLFT,{$ENDIF}
  {$IFDEF USEFREETYPETTFIMPLEMENTATION}uzeFontFileFormatTTFBackendFT,{$ENDIF}
  Types;
type
  TTTFSymInfo=record
    GlyphIndex:Integer;
    PSymbolInfo:PGDBSymdolInfo;
  end;
  TMapChar=TMyMapGenOld<integer,TTTFSymInfo{$IFNDEF DELPHI},LessInteger{$ENDIF}>;

  TZETFFFontImpl=class(TZEBaseFontImpl)
    private
      TTFImplementation:TTTFBackend;
    public
      MapChar:TMapChar;
      DefaultChar:Integer;
      function GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;override;
      function GetSymbolInfo(symbol:Integer):PGDBsymdolinfo;virtual;
      procedure ProcessTriangleData(si:PGDBsymdolinfo);
      constructor Create;
      destructor Destroy;override;
      procedure SetupSymbolLineParams(const matr:DMatrix4d; var SymsParam:TSymbolSParam);override;

    public
      function IsUnicode:Boolean;override;
      function IsCanSystemDraw:Boolean;override;

      property TTFImpl:TTTFBackend read TTFImplementation;
  end;

procedure cfeatettfsymbol(const chcode:integer;var si:TTTFSymInfo; pttf:TZETFFFontImpl);
implementation
type
  TTriangulationMode=(TM_Triangles,TM_TriangleStrip,TM_TriangleFan);
  TV4P = array [0..3] of Pointer;
  TArray4F = Array [0..3] of Float;
var
  ptrdata:PZGLVectorObject;
  Ptrsize:PInteger;
  trmode:TTriangulationMode;
  CurrentLLentity:TArrayIndex;
  triangle:array[0..2] of integer;
procedure TessErrorCallBack(error: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
     error:=error;
end;
procedure CombineCallback(const coords:TzePoint3d;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
   ptruint(dataout):=ptrdata^.GeomData.Vertex3S.AddGDBVertex(coords);
end;
procedure TessBeginCallBack(gmode: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  CurrentLLentity:=-1;
  if gmode=GL_TRIANGLES then
    gmode:=gmode;
  pointcount:=0;
  case gmode of
    GL_TRIANGLES:begin
      trmode:=TM_Triangles;
    end;
    GL_TRIANGLE_FAN:begin
      trmode:=TM_TriangleFan;
      CurrentLLentity:=DefaultLLPCreator.CreateLLTriangleFan(ptrdata^.LLprimitives);
      inc(ptrsize^);
    end;
    GL_TRIANGLE_STRIP:begin
      trmode:=TM_TriangleStrip;
      CurrentLLentity:=DefaultLLPCreator.CreateLLTriangleStrip(ptrdata^.LLprimitives);
      inc(ptrsize^);
    end;
    else begin
      zDebugLn('{F}Wrong triangulation mode!!');
      halt(0);
    end;
  end;
end;
procedure TessVertexCallBack(const v,v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
  pts:PTLLTriangleStrip;
  index:TLLVertexIndex;
begin
  if pointcount<3 then begin
    if (trmode=TM_TriangleStrip)or(trmode=TM_TriangleFan) then begin
      pts:=pointer(ptrdata^.LLprimitives.getDataMutable(CurrentLLentity));
      index:=ptruint(v);
      index:=ptrdata^.GeomData.Indexes.PushBackData(index);
      pts^.AddIndex(index);
      exit;
    end;
    triangle[pointcount]:=ptruint(v);
    inc(pointcount);
    if pointcount=3 then begin
      DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
      inc(ptrsize^);
      if trmode=TM_Triangles then
        pointcount:=0;
    end;
  end else begin
    case trmode of
    TM_TriangleFan:begin
      triangle[1]:=triangle[2];
      triangle[2]:=ptruint(v);
      DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
      inc(ptrsize^);
    end;
    TM_TriangleStrip:begin
      triangle[0]:=triangle[1];
      triangle[1]:=triangle[2];
      triangle[2]:=ptruint(v);
      DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
      inc(ptrsize^);
    end;
    else begin
      triangle[1]:=triangle[1];
    end;
    end;
  end;
end;
procedure cfeatettfsymbol(const chcode:integer;var si:TTTFSymInfo; pttf:TZETFFFontImpl{;var pf:PGDBfont});
var
   i,j:integer;
   GenGlyph:TGlyphData;
   cends,lastoncurve:integer;
   startcountur:boolean;
   k:Double;
   tesselator:TessObj;
   lastv:GDBFontVertex2D;
   tparrayindex:integer;
   tv:TzePoint3d;
   p:TzePoint2d;
   glyphBounds:TRect;
procedure CompareAndTess(const v:GDBFontVertex2D);
begin
  if (abs(lastv.x-v.x)>eps)or(abs(lastv.y-v.y)>eps) then begin
    inc(tparrayindex);
    lastv:=v;
  end else
    //v:=v
    ;
end;

procedure EndSymContour;
begin
  bs.EndCountur;
end;
begin
  k:=pttf.TTFImpl.TTFImplDummyGlobalScale/pttf.TTFImpl.CapHeight;
  BS.VectorData:=@pttf.FontData;
  BS.fmode:=TSM_WaitStartCountur;

  si.PSymbolInfo:=pttf.GetOrCreateSymbolInfo(chcode);
  si.PSymbolInfo.LLPrimitiveStartIndex:=pttf.FontData.LLprimitives.Count;
  BS.shxsize:=@si.PSymbolInfo.LLPrimitiveCount;

  GenGlyph:=pttf.TTFImplementation.Glyph[si.GlyphIndex];

  glyphBounds:=pttf.TTFImplementation.GetGlyphBounds(GenGlyph);

  si.PSymbolInfo.w:=glyphBounds.Right*k;
  si.PSymbolInfo.NextSymX:=pttf.TTFImplementation.GetGlyphAdvance(GenGlyph)*k;
  si.PSymbolInfo.SymMaxX:=si.PSymbolInfo.NextSymX;
  si.PSymbolInfo.SymMinX:=0;
  si.PSymbolInfo.h:=glyphBounds.Top*k;
  si.PSymbolInfo.LLPrimitiveCount:=0;
  ptrdata:=@pttf.FontData;
  ptrsize:=@si.PSymbolInfo.LLPrimitiveCount;
  tparrayindex:=0;
  if pttf.TTFImplementation.GetGlyphContoursCount(GenGlyph)>0 then begin
    cends:=0;
    lastoncurve:=0;
    startcountur:=true;
    for j:=0 to pttf.TTFImplementation.GetGlyphPointsCount(GenGlyph)-1{-3} do begin
      if  startcountur then
        bs.StartCountur;
      p:=pttf.TTFImplementation.GetGlyphPoint(GenGlyph,j);
      p:=p*k/64;
      if (TTFPFOnCurve in pttf.TTFImplementation.GetGlyphPointFlag(GenGlyph,j)) then
        bs.AddPoint(p,TPA_OnCurve)
      else
        bs.AddPoint(p,TPA_NotOnCurve);
      if startcountur then
        startcountur:=false
      else begin
        if (TTFPFOnCurve in pttf.TTFImplementation.GetGlyphPointFlag(GenGlyph,j)) then begin
          if j-lastoncurve>3 then
            lastoncurve:=lastoncurve;
          lastoncurve:=j;
        end;
      end;
      if j=pttf.TTFImplementation.GetGlyphConEnd(GenGlyph,cends) then begin
        EndSymContour;
        inc(cends);
        startcountur:=true;
        lastoncurve:=j+1;
        if cends=pttf.TTFImplementation.GetGlyphContoursCount(GenGlyph) then
          break;
        if (pttf.TTFImplementation.GetGlyphPointsCount(GenGlyph)-j)<{5}3 then
          break;
      end;
    end;
    bs.DrawCountur;
    tesselator:=GLUIntrf.NewTess;
    GLUIntrf.TessCallback(tesselator,GLU_TESS_VERTEX_DATA,@TessVertexCallBack);
    GLUIntrf.TessCallback(tesselator,GLU_TESS_BEGIN_DATA,@TessBeginCallBack);
    GLUIntrf.TessCallback(tesselator,GLU_TESS_Error_DATA,@TessErrorCallBack);
    GLUIntrf.TessCallback(tesselator,GLU_TESS_COMBINE,@CombineCallBack);
    GLUIntrf.TessBeginPolygon(tesselator,nil);
    for i:=0 to bs.Conturs.VArray.Size-1 do begin
      zTraceLn('{T+}[TTF_CONTENTS]Contur=%d',[i]);
      GLUIntrf.TessBeginContour(tesselator);
      tv.z:=0;
      for j:=0 to bs.Conturs.VArray[i].Size-1 do begin
        with bs.Conturs.VArray[i][j] do begin
          zTraceLn('[TTF_CONTENTS]x=%f;y=%f',[v.x,v.y]);
          tv.x:=v.x;
          tv.y:=v.y;
          GLUIntrf.TessVertex(tesselator,@tv,index);
        end;
      end;
      GLUIntrf.TessEndContour(tesselator);
      zTraceLn('{T-}[TTF_CONTENTS]End contur');
    end;
    GLUIntrf.TessEndPolygon(tesselator);
    GLUIntrf.DeleteTess(tesselator);
  end;
  bs.ClearConturs;
end;
function TZETFFFontImpl.IsUnicode:Boolean;
begin
  result:=true;
end;
procedure TZETFFFontImpl.SetupSymbolLineParams(const matr:DMatrix4d; var SymsParam:TSymbolSParam);
begin
  if SymsParam.IsCanSystemDraw then begin
    SymsParam.NeededFontHeight:=oneVertexlength(PzePoint3d(@matr.mtr.v[1])^)*((TTFImplementation.Ascent+TTFImplementation.Descent)/(TTFImplementation.CapHeight));
  end
end;
function TZETFFFontImpl.IsCanSystemDraw:Boolean;
begin
  result:=true;
end;
constructor TZETFFFontImpl.Create;
begin
  inherited;
  TTFImplementation:=TTFBackend.create;
  MapChar:=TMapChar.Create;
end;
destructor TZETFFFontImpl.Destroy;
begin
  inherited;
  TTFImplementation.Destroy;
  MapChar.Destroy;
end;
procedure TZETFFFontImpl.ProcessTriangleData(si:PGDBsymdolinfo);
var
  symoutbound:TBoundingBox;
  VDCopyParam:TZGLVectorDataCopyParam;
begin
  if si.LLPrimitiveCount>0 then begin
    VDCopyParam:=FontData.GetCopyParam(si.LLPrimitiveStartIndex,si.LLPrimitiveCount);
    symoutbound:=FontData.GetBoundingBbox(VDCopyParam.EID.GeomIndexMin,VDCopyParam.EID.GeomIndexMax);
    si.SymMaxY:=symoutbound.RTF.y;
    si.SymMinY:=symoutbound.LBN.y;
  end;
end;
function TZETFFFontImpl.GetSymbolInfo(symbol:Integer):PGDBsymdolinfo;
var
  CharIterator:TMapChar.TIterator;
  si:TTTFSymInfo;
begin
  CharIterator:=MapChar.Find(symbol);
  if CharIterator<>nil then begin
    si:=CharIterator.value;
    if si.PSymbolInfo<>nil then
      result:=si.PSymbolInfo
    else  begin
      cfeatettfsymbol(symbol,si,self);
      ProcessTriangleData(si.PSymbolInfo);
      CharIterator.Value:=si;
      result:=si.PSymbolInfo;
    end;
    CharIterator.Destroy;
  end else
    result:=nil;
end;

function TZETFFFontImpl.GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;
var
  CharIterator:TMapChar.TIterator;
  si:TTTFSymInfo;
begin
  result:=GetSymbolInfo(symbol);
  if result=nil then begin
    if symbol=8709 then
      exit(GetOrReplaceSymbolInfo(216));
    if DefaultChar<>-1 then begin
      result:=GetSymbolInfo(DefaultChar);//символ для подстановки оссутствующих глифов
      if result=nil then //не нашли? тогда всетаки нулевой глиф
        result:=GetSymbolInfo(0);//символ 0 с глифом 0 для подстановки оссутствующих глифов подготовлен при загрузке шрифта
    end else
      result:=GetSymbolInfo(0);//символ 0 с глифом 0 для подстановки оссутствующих глифов подготовлен при загрузке шрифта
    if result=nil then begin
      CharIterator:=MapChar.Min;
      if CharIterator<>nil then begin
        si:=CharIterator.value;
        if si.PSymbolInfo<>nil then
          result:=si.PSymbolInfo
        else begin
          cfeatettfsymbol(symbol,si,@self);
          ProcessTriangleData(si.PSymbolInfo);
          CharIterator.Value:=si;
          result:=si.PSymbolInfo;
        end;
        CharIterator.Destroy;
      end;
    end;
  end;
end;

initialization
{$IF DEFINED(USELAZFREETYPETTFIMPLEMENTATION) and DEFINED(USEFREETYPETTFIMPLEMENTATION)}
  if sysvarTTFUseLazFreeTypeImplementation then
    TTFBackend:=TTTFBackendLazFreeType
  else
    TTFBackend:=TTTFBackendFreeType;
{$ELSEIF DEFINED(USELAZFREETYPETTFIMPLEMENTATION)}
  TTFBackend:=TTTFBackendLazFreeType;
{$ELSEIF DEFINED(USEFREETYPETTFIMPLEMENTATION)}
  TTFBackend:=TTTFBackendFreeType;
{$ENDIF}
end.
