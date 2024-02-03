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
  LCLProc,uzgprimitivescreator,uzgprimitives,uzglvectorobject,uzefontbase,
  uzebeziersolver,math,uzgloglstatemanager,uzegluinterface,TTTypes,TTObjs,
  usimplegenerics,EasyLazFreeType,uzbstrproc,sysutils,
  uzegeometrytypes,uzbtypes,uzegeometry,gzctnrSTL,gzctnrVectorTypes,uzbLogIntf;
type
  TTTFSymInfo=record
    GlyphIndex:Integer;
    PSymbolInfo:PGDBSymdolInfo;
  end;
  TMapChar=TMyMapGenOld<integer,TTTFSymInfo{$IFNDEF DELPHI},LessInteger{$ENDIF}>;

  TTTFBackend=class
    private
      function GetHinted:Boolean;virtual;abstract;
      procedure SetHinted(const AValue:Boolean);virtual;abstract;
      function GetFullName:String;virtual;abstract;
      function GetFamily:String;virtual;abstract;
      procedure SetSizeInPoints(const AValue:single);virtual;abstract;
      function GetSizeInPoints:single;virtual;abstract;
      function GetCharIndex(AUnicodeChar:integer):integer;virtual;abstract;

      function GetAscent: single; virtual; abstract;
      function GetDescent: single; virtual; abstract;
      function GetCapHeight: single; virtual; abstract;
      function GetGlyph(Index: integer): TFreeTypeGlyph; virtual; abstract;

    public
      constructor Create;virtual;abstract;
      procedure LoadFile(const AFile:String);virtual;abstract;
      property Hinted:Boolean read GetHinted write SetHinted;
      property FullName:String read GetFullName;
      property Family:String read GetFamily;
      property SizeInPoints:single read GetSizeInPoints write SetSizeInPoints;
      property CharIndex[AUnicodeChar:integer]:integer read GetCharIndex;

      property Ascent: single read GetAscent;
      property Descent: single read GetDescent;
      property CapHeight: single read GetCapHeight;
      property Glyph[Index: integer]: TFreeTypeGlyph read GetGlyph;
  end;

  TLazFreeTypeTTFBackend=Class(TTTFBackend)
    private
      LazFreeTypeTTFImpl:TFreeTypeFont;

      function GetHinted:Boolean;override;
      procedure SetHinted(const AValue:Boolean);override;
      function GetFullName:String;override;
      function GetFamily:String;override;
      procedure SetSizeInPoints(const AValue:single);override;
      function GetSizeInPoints:single;override;
      function GetCharIndex(AUnicodeChar:integer):integer;override;

      function GetAscent: single;override;
      function GetDescent: single;override;
      function GetCapHeight: single;override;
      function GetGlyph(Index: integer): TFreeTypeGlyph;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;
  end;

  TTTFBackends=class of TTTFBackend;

  TZETFFFontImpl=class(TZEBaseFontImpl)
    private
      TTFImplementation:TTTFBackend;
    public
      //TTFImplementation:TFreeTypeFont;
      MapChar:TMapChar;
      function GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;override;
      function GetSymbolInfo(symbol:Integer):PGDBsymdolinfo;virtual;
      procedure ProcessTriangleData(si:PGDBsymdolinfo);
      constructor Create;
      destructor Destroy;override;
      procedure SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);override;

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

  TTFBackend:TTTFBackends;
function TLazFreeTypeTTFBackend.GetGlyph(Index: integer):TFreeTypeGlyph;
begin
  Result:=LazFreeTypeTTFImpl.Glyph[Index];
end;
function TLazFreeTypeTTFBackend.GetCapHeight: single;
begin
  Result:=LazFreeTypeTTFImpl.CapHeight;
end;
function TLazFreeTypeTTFBackend.GetAscent:single;
begin
  Result:=LazFreeTypeTTFImpl.Ascent;
end;
function TLazFreeTypeTTFBackend.GetDescent:single;
begin
  Result:=LazFreeTypeTTFImpl.Descent;
end;
function TLazFreeTypeTTFBackend.GetCharIndex(AUnicodeChar:integer):integer;
begin
  Result:=LazFreeTypeTTFImpl.CharIndex[AUnicodeChar];
end;
procedure TLazFreeTypeTTFBackend.SetSizeInPoints(const AValue:single);
begin
  LazFreeTypeTTFImpl.SizeInPoints:=AValue;
end;
function TLazFreeTypeTTFBackend.GetSizeInPoints:single;
begin
  Result:=LazFreeTypeTTFImpl.SizeInPoints;
end;
function TLazFreeTypeTTFBackend.GetFullName:String;
begin
  Result:=LazFreeTypeTTFImpl.Information[ftiFullName];
end;
function TLazFreeTypeTTFBackend.GetFamily:String;
begin
  Result:=LazFreeTypeTTFImpl.Information[ftiFamily];
end;
procedure TLazFreeTypeTTFBackend.LoadFile(const AFile:String);
begin
   LazFreeTypeTTFImpl.Name:=AFile;
end;
function TLazFreeTypeTTFBackend.GetHinted:Boolean;
begin
  Result:=LazFreeTypeTTFImpl.Hinted;
end;
procedure TLazFreeTypeTTFBackend.SetHinted(const AValue:Boolean);
begin
  LazFreeTypeTTFImpl.Hinted:=AValue;
end;
constructor TLazFreeTypeTTFBackend.Create;
begin
  LazFreeTypeTTFImpl:=TFreeTypeFont.Create;
end;
destructor TLazFreeTypeTTFBackend.Destroy;
begin
  FreeAndNil(LazFreeTypeTTFImpl);
end;
procedure TessErrorCallBack(error: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
     error:=error;
end;
procedure CombineCallback(const coords:GDBvertex;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
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
      debugln('{F}Wrong triangulation mode!!');
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
   glyph:TFreeTypeGlyph;
   _glyph:PGlyph;
   x1,y1:fontfloat;
   cends,lastoncurve:integer;
   startcountur:boolean;
   k:Double;
   tesselator:TessObj;
   lastv:GDBFontVertex2D;
   tparrayindex:integer;
   tv:gdbvertex;
procedure CompareAndTess(v:GDBFontVertex2D);
begin
  if (abs(lastv.x-v.x)>eps)or(abs(lastv.y-v.y)>eps) then begin
    inc(tparrayindex);
    lastv:=v;
  end else
    v:=v;
end;

procedure EndSymContour;
begin
  bs.EndCountur;
end;
begin
  k:=1/pttf.TTFImpl.CapHeight;
  BS.VectorData:=@pttf.FontData;

  BS.fmode:=TSM_WaitStartCountur;
  glyph:=pttf.TTFImplementation.Glyph[{i}si.GlyphIndex];
  _glyph:=glyph.Data.z;
  si.PSymbolInfo:=pttf.GetOrCreateSymbolInfo(chcode);
  si.PSymbolInfo.LLPrimitiveStartIndex:=pttf.FontData.LLprimitives.Count;
  BS.shxsize:=@si.PSymbolInfo.LLPrimitiveCount;
  si.PSymbolInfo.w:=glyph.Bounds.Right*k;
  si.PSymbolInfo.NextSymX:=glyph.Bounds.Right*k;
  si.PSymbolInfo.NextSymX:=glyph.Advance*k;
  si.PSymbolInfo.SymMaxX:=si.PSymbolInfo.NextSymX;
  si.PSymbolInfo.SymMinX:=0;
  si.PSymbolInfo.h:=glyph.Bounds.Top*k;
  si.PSymbolInfo.LLPrimitiveCount:=0;
  ptrdata:=@pttf.FontData;
  ptrsize:=@si.PSymbolInfo.LLPrimitiveCount;
  tparrayindex:=0;
  if _glyph^.outline.n_contours>0 then begin
    cends:=0;
    lastoncurve:=0;
    startcountur:=true;
    for j:=0 to _glyph^.outline.n_points-3 do begin
      if  startcountur then
        bs.StartCountur;
      x1:=_glyph^.outline.points^[j].x*k/64;
      y1:=_glyph^.outline.points^[j].y*k/64;
      if (_glyph^.outline.flags[j] and TT_Flag_On_Curve)<>0 then begin
        bs.AddPoint(x1,y1,TPA_OnCurve);
      end else begin
       bs.AddPoint(x1,y1,TPA_NotOnCurve);
      end;
      if  startcountur then begin
        startcountur:=false;
      end else begin
        if (_glyph^.outline.flags[j] and TT_Flag_On_Curve)<>0 then begin
          if j-lastoncurve>3 then
            lastoncurve:=lastoncurve;
          lastoncurve:=j;
        end;
      end;
      if j=_glyph^.outline.conEnds[cends] then begin
        EndSymContour;
        inc(cends);
        startcountur:=true;
        lastoncurve:=j+1;
        if cends=_glyph^.outline.n_contours then
          break;
        if (_glyph^.outline.n_points-j)<5 then
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
      for j:=0 to bs.Conturs.VArray[i].Size-1 do begin
        zTraceLn('[TTF_CONTENTS]x=%f;y=%f',[(bs.Conturs.VArray[i][j].v.x),(bs.Conturs.VArray[i][j].v.y)]);
        tv.x:=bs.Conturs.VArray[i][j].v.x;
        tv.y:=bs.Conturs.VArray[i][j].v.y;
        tv.z:=0;
        GLUIntrf.TessVertex(tesselator,@tv,pointer(bs.Conturs.VArray[i][j].index));
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
procedure TZETFFFontImpl.SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);
begin
  if SymsParam.IsCanSystemDraw then begin
    SymsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr[1])^)*((TTFImplementation.Ascent+TTFImplementation.Descent)/(TTFImplementation.CapHeight));
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

function TZETFFFontImpl.GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
var
  CharIterator:TMapChar.TIterator;
  si:TTTFSymInfo;
begin
  result:=GetSymbolInfo(symbol);
  if result=nil then begin
    if symbol=8709 then
      exit(GetOrReplaceSymbolInfo(216));
    result:=GetSymbolInfo(ord('?'));
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
 TTFBackend:=TLazFreeTypeTTFBackend;
end.
