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

unit uzefontttf;
{$INCLUDE zengineconfig.inc}
interface
uses LCLProc,uzgprimitivescreator,uzgprimitives,uzglvectorobject,uzefontbase,
     uzebeziersolver,math,uzgloglstatemanager,uzegluinterface,TTTypes,TTObjs,
  usimplegenerics,EasyLazFreeType,uzbstrproc,sysutils,
  uzegeometrytypes,uzbtypes,uzegeometry,gzctnrSTL,gzctnrVectorTypes,uzbLogIntf;
type
PTTTFSymInfo=^TTTFSymInfo;
TTTFSymInfo=record
                      GlyphIndex:Integer;
                      PSymbolInfo:PGDBSymdolInfo;
                      //-ttf-//TrianglesDataInfo:TTrianglesDataInfo;
                end;

TMapChar=TMyMapGenOld<integer,TTTFSymInfo{$IFNDEF DELPHI},LessInteger{$ENDIF}>;
{EXPORT+}
PTTFFont=^TTFFont;
{REGISTEROBJECTTYPE TTFFont}
TTFFont= object({SHXFont}BASEFont)
              ftFont: TFreeTypeFont;
              MapChar:TMapChar;
              //MapCharIterator:TMapChar.TIterator;
              //-ttf-//TriangleData:ZGLFontTriangle2DArray;
              function GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;virtual;
              //-ttf-//function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;
              procedure ProcessTriangleData(si:PGDBsymdolinfo);
              constructor init;
              destructor done;virtual;
              function IsCanSystemDraw:Boolean;virtual;
              procedure SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);virtual;
        end;

{EXPORT-}
procedure cfeatettfsymbol(const chcode:integer;var si:TTTFSymInfo; pttf:PTTFFont{;var pf:PGDBfont});
implementation
//uses {math,}log;
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
{procedure adddcross(shx:PTZctnrVectorBytes;var size:Word;x,y:fontfloat);
const
     s=0.01;
begin
    shx.AddByteByVal(SHXLine);
    x:=x-1*s;
    y:=y-1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x+2*s;
    y:=y+2*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);

    shx.AddByteByVal(SHXLine);
    x:=x-1*s-1*s;
    y:=y-1*s+1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x+2*s;
    y:=y-2*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);
end;
procedure addgcross(shx:PTZctnrVectorBytes;var size:Word;x,y:fontfloat);
const
     s=0.01;
begin
    shx.AddByteByVal(SHXLine);
    y:=y+1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x+1*s;
    y:=y-1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);

    shx.AddByteByVal(SHXLine);
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x-1*s;
    y:=y-1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);

    shx.AddByteByVal(SHXLine);
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x-1*s;
    y:=y+1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);

    shx.AddByteByVal(SHXLine);
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    x:=x+1*s;
    y:=y+1*s;
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);
    inc(size);

end;}
procedure TessErrorCallBack(error: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
//     error:=error;
end;
procedure CombineCallback(const coords:GDBvertex;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
   ptruint(dataout):=ptrdata^.GeomData.Vertex3S.AddGDBVertex(coords);
end;
procedure TessBeginCallBack(gmode: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
     CurrentLLentity:=-1;
//     if gmode=GL_TRIANGLES then
//                               gmode:=gmode;
     pointcount:=0;
     case gmode of
     GL_TRIANGLES:
                  begin
                       trmode:=TM_Triangles;
                  end;
  GL_TRIANGLE_FAN:begin
                       trmode:=TM_TriangleFan;
                       CurrentLLentity:={ptrdata^.LLprimitives}DefaultLLPCreator.CreateLLTriangleFan(ptrdata^.LLprimitives);
                       inc(ptrsize^);
                  end;
GL_TRIANGLE_STRIP:begin

                       trmode:=TM_TriangleStrip;
                       CurrentLLentity:={ptrdata^.LLprimitives}DefaultLLPCreator.CreateLLTriangleStrip(ptrdata^.LLprimitives);
                       inc(ptrsize^);
                  end;
     else
         begin
           debugln('{F}Wrong triangulation mode!!');
           raise Exception.Create('Wrong triangulation mode!!');
         end;
     end;
end;
procedure TessVertexCallBack(const v,v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
   pts:PTLLTriangleStrip;
   index:TLLVertexIndex;
begin
     if pointcount<3 then
                         begin
                              if (trmode=TM_TriangleStrip)or(trmode=TM_TriangleFan) then
                                                         begin
                                                              pts:=pointer(ptrdata^.LLprimitives.getDataMutable(CurrentLLentity));
                                                              index:=ptruint(v);
                                                              index:=ptrdata^.GeomData.Indexes.PushBackData(index);
                                                              pts^.AddIndex(index);
                                                              exit;
                                                         end;

                              triangle[pointcount]:=ptruint(v);
                              inc(pointcount);
                              if pointcount=3 then
                                             begin
                                                  {ptrdata^.LLprimitives}DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
                                                  inc(ptrsize^);
                                                  {ptrdata^.GeomData.Add2DPoint(triangle[1].x,triangle[1].y);
                                                  ptrdata^.GeomData.Add2DPoint(triangle[2].x,triangle[2].y);}
                                             if trmode=TM_Triangles then
                                                                       pointcount:=0;
                                             end;
                         end
                     else
                         begin
                              case trmode of
                       TM_TriangleFan:begin
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=ptruint(v);
                                            {ptrdata^.LLprimitives}DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
                                            inc(ptrsize^);
                                            //ptrdata^.LLprimitives.AddLLTriangle(ptrdata^.GeomData.Add2DPoint(triangle[0].x,triangle[0].y));
                                            //ptrdata^.GeomData.Add2DPoint(triangle[1].x,triangle[1].y);
                                            //ptrdata^.GeomData.Add2DPoint(triangle[2].x,triangle[2].y);
                                       end;
                     TM_TriangleStrip:begin
                                            triangle[0]:=triangle[1];
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=ptruint(v);
                                            {ptrdata^.LLprimitives}DefaultLLPCreator.CreateLLFreeTriangle(ptrdata^.LLprimitives,triangle[0],triangle[1],triangle[2],ptrdata^.GeomData.Indexes);
                                            inc(ptrsize^);
                                            //ptrdata^.LLprimitives.AddLLTriangle(ptrdata^.GeomData.Add2DPoint(triangle[0].x,triangle[0].y));
                                            //ptrdata^.GeomData.Add2DPoint(triangle[1].x,triangle[1].y);
                                            //ptrdata^.GeomData.Add2DPoint(triangle[2].x,triangle[2].y);
                                       end;
                              else begin
                                        triangle[1]:=triangle[1];
                                   end;
                              end;
                         end;

     //ptrdata^.Add(@trp);
end;
procedure cfeatettfsymbol(const chcode:integer;var si:TTTFSymInfo; pttf:PTTFFont{;var pf:PGDBfont});
var
   i,j:integer;
   glyph:TFreeTypeGlyph;
   _glyph:PGlyph;
   //psyminfo,psubsyminfo:PGDBsymdolinfo;

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
     if (abs(lastv.x-v.x)>eps)or(abs(lastv.y-v.y)>eps) then
     begin
          //OGLSM.TessVertex(tesselator,@tparray[tparrayindex],nil);
          inc(tparrayindex);
          lastv:=v;
     end;
//        else
//            v:=v;
end;

procedure EndSymContour;
begin//----//
     bs.EndCountur;
     exit;
     {
     lastv.x:=Infinity;
     lastv.y:=Infinity;
     oldtparrayindex:=tparrayindex;
      if startcounturindex<pttf.SHXdata.Count then
      begin
           psymbol:=pttf.SHXdata.getDataMutable(startcounturindex);
           pendsymbol:=pttf.SHXdata.getDataMutable(pttf.SHXdata.Count);
           while psymbol<pendsymbol do
               begin
                 case Byte(psymbol^) of
                   SHXLine:
                     begin
                       inc(PByte(psymbol), sizeof(SHXLine));
                       v.x:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       v.y:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));

                       CompareAndTess(v);

                       v.x:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       v.y:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));

                       CompareAndTess(v);
                     end;
                   SHXPoly:
                     begin
                       inc(PByte(psymbol), sizeof(SHXPoly));
                       len := Word(psymbol^);
                       inc(PByte(psymbol), sizeof(Word));
                       v.x:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       v.y:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       CompareAndTess(v);

                       count := 1;
                       while count < len do //for count:=1 to len-1 do
                       begin
                       v.x:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       v.y:=pfontfloat(psymbol)^;
                       inc(pfontfloat(psymbol));
                       CompareAndTess(v);
                       inc(count);
                       end;
                     end;
                 end;
               end;
             end;

           OGLSM.TessBeginContour(tesselator);
           for count:=oldtparrayindex to tparrayindex-2 do
           begin
                OGLSM.TessVertex(tesselator,@tparray[count],@tparray[count]);
           end;

           OGLSM.TessEndContour(tesselator);
end;
}

end;
begin
  k:=1/pttf^.ftFont.CapHeight;
  BS.VectorData:=@pttf^.FontData;//----//

  BS.fmode:=TSM_WaitStartCountur;
  glyph:=pttf^.ftFont.Glyph[{i}si.GlyphIndex];
  _glyph:=glyph.Data.z;
  //programlog.LogOutStr('TTF: Symbol index='+inttostr(si.GlyphIndex)+'; code='+inttostr(chcode),0);
  //if chcode=56 then
  //                  chcode:=chcode;
  si.PSymbolInfo:=pttf^.GetOrCreateSymbolInfo(chcode);
  si.PSymbolInfo.LLPrimitiveStartIndex:=pttf^.FontData.LLprimitives.Count;
  BS.shxsize:=@si.PSymbolInfo.LLPrimitiveCount;
  //----//si.PSymbolInfo.addr:=pttf.SHXdata.Count;
  si.PSymbolInfo.w:=glyph.Bounds.Right*k;
  si.PSymbolInfo.NextSymX:=glyph.Bounds.Right*k;
  si.PSymbolInfo.NextSymX:=glyph.Advance*k;
  si.PSymbolInfo.SymMaxX:=si.PSymbolInfo.NextSymX;
  si.PSymbolInfo.SymMinX:=0;
  si.PSymbolInfo.h:=glyph.Bounds.Top*k;
  si.PSymbolInfo.LLPrimitiveCount:=0;
  //-ttf-//si.TrianglesDataInfo.TrianglesAddr:=pttf^.TriangleData.count;
  //-ttf-//si.TrianglesDataInfo.TrianglesSize:=pttf^.TriangleData.count;
  ptrdata:=@pttf^.FontData;
  ptrsize:=@si.PSymbolInfo.LLPrimitiveCount;
  tparrayindex:=0;
  if _glyph^.outline.n_contours>0 then
  begin
  cends:=0;
  lastoncurve:=0;
  startcountur:=true;
  for j:=0 to _glyph^.outline.n_points-3 do
  begin
       if  startcountur then
                            bs.StartCountur;
  x1:=_glyph^.outline.points^[j].x*k/64;
  y1:=_glyph^.outline.points^[j].y*k/64;
  //programlog.LogOutStr('TTF x='+floattostr(x1)+' y='+floattostr(y1),0);
 if (_glyph^.outline.flags[j] and TT_Flag_On_Curve)<>0 then
 begin
      //adddcross(@pttf.SHXdata,si.PSymbolInfo.size,x1,y1);
      bs.AddPoint(x1,y1,TPA_OnCurve);
 end
 else
     begin
     //addgcross(@pttf.SHXdata,si.PSymbolInfo.size,x1,y1);
     bs.AddPoint(x1,y1,TPA_NotOnCurve);
     end;
  if  startcountur then
                       begin
                            //----//startcounturindex:=pttf.SHXdata.Count;
                            startcountur:=false;
                       end
  else
  begin
    if (_glyph^.outline.flags[j] and TT_Flag_On_Curve)<>0 then
    begin
         //HistoryOutStr(inttostr(j-lastoncurve));
//         if j-lastoncurve>3 then
//                                lastoncurve:=lastoncurve;
         lastoncurve:=j;
    end;
    //programlog.LogOutStr('TTF: flag='+inttostr(_glyph^.outline.flags[j]),0);
    begin
         {PSHXFont(pf^.font).SHXdata.AddByteByVal(SHXLine);
         PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
         PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
         PSHXFont(pf^.font).SHXdata.AddFontFloat(@x);
         PSHXFont(pf^.font).SHXdata.AddFontFloat(@y);
         inc(psyminfo.size);}
    end;
  end;
    if j=_glyph^.outline.conEnds[cends] then
      begin
           EndSymContour;
           inc(cends);
           startcountur:=true;
           lastoncurve:=j+1;
           {PSHXFont(pf^.font).SHXdata.AddByteByVal(SHXLine);
           PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
           PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
           PSHXFont(pf^.font).SHXdata.AddFontFloat(@scx);
           PSHXFont(pf^.font).SHXdata.AddFontFloat(@scy);
           inc(psyminfo.size);}
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
  //gluTessProperty(tesselator,GLU_TESS_WINDING_RULE,GLU_TESS_WINDING_ODD);
  //gluTessProperty(tesselator, GLU_TESS_BOUNDARY_ONLY, GLU_FALSE);
  //gluTessProperty(tesselator, GLU_TESS_TOLERANCE , 1000.0);

  GLUIntrf.TessBeginPolygon(tesselator,nil);
  for i:=0 to bs.Conturs.VArray.Size-1 do
  begin
       zTraceLn('{T+}[TTF_CONTENTS]Contur=%d',[i]);
       GLUIntrf.TessBeginContour(tesselator);
       for j:=0 to bs.Conturs.VArray[i].Size-1 do
       begin
            zTraceLn('[TTF_CONTENTS]x=%f;y=%f',[(bs.Conturs.VArray[i][j].v.x),(bs.Conturs.VArray[i][j].v.y)]);
            tv.x:=bs.Conturs.VArray[i][j].v.x;
            tv.y:=bs.Conturs.VArray[i][j].v.y;
            tv.z:=0;
            GLUIntrf.TessVertex(tesselator,@tv,pointer(bs.Conturs.VArray[i][j].index));
            //VectorData.GeomData.Add2DPoint(Conturs.VArray[i][j].x,Conturs.VArray[i][j].y);
       end;
       GLUIntrf.TessEndContour(tesselator);
       zTraceLn('{T-}[TTF_CONTENTS]End contur');
  end;
  GLUIntrf.TessEndPolygon(tesselator);


  //gluTessNormal( tesselator, 0.0, 0.0, -1.0);

  //GLUIntrf.TessEndPolygon(tesselator);
  //si.TrianglesDataInfo.TrianglesSize:=pttf^.TriangleData.count-si.TrianglesDataInfo.TrianglesSize;
  GLUIntrf.DeleteTess(tesselator);
  //si.PSymbolInfo.LLPrimitiveCount:=pttf^.FontData.LLprimitives.Count-si.PSymbolInfo.LLPrimitiveStartIndex;


  //bs.ClearConturs;
  //EndSymContour;
  end;
  bs.ClearConturs;
end;
procedure TTFFont.SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);
begin
  if SymsParam.IsCanSystemDraw then
                                      begin
                                           SymsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr[1])^)*((ftFont.Ascent+ftFont.Descent)/(ftFont.CapHeight));
                                           //SymsParam.pfont:=@self;
                                      end
end;
function TTFFont.IsCanSystemDraw:Boolean;
begin
     result:=true;
end;
constructor TTFFont.init;
begin
     inherited;
     //-ttf-//TriangleData.init(200);
     ftFont:=TFreeTypeFont.create;
     MapChar:=TMapChar.Create;
     //MapCharIterator:=TMapChar.TIterator.Create;
end;
destructor TTFFont.done;
begin
     inherited;
     //-ttf-//TriangleData.done;
     ftFont.Destroy;
     //MapCharIterator.Destroy;
     MapChar.Destroy;
end;
//-ttf-//function TTFFont.GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;
//-ttf-//begin
//-ttf-//     result:=self.TriangleData.getDataMutable(offset);
//-ttf-//end;
procedure TTFFont.ProcessTriangleData(si:PGDBsymdolinfo);
var
   symoutbound:TBoundingBox;
   VDCopyParam:TZGLVectorDataCopyParam;
begin
  if si.LLPrimitiveCount>0 then
  begin
       VDCopyParam:=FontData.GetCopyParam(si.LLPrimitiveStartIndex,si.LLPrimitiveCount);
       symoutbound:=FontData.GetBoundingBbox(VDCopyParam.EID.GeomIndexMin,VDCopyParam.EID.GeomIndexMax);
       si.SymMaxY:=symoutbound.RTF.y;
       si.SymMinY:=symoutbound.LBN.y;
  end;
end;
function TTFFont.GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
var
   CharIterator:TMapChar.TIterator;
   si:TTTFSymInfo;
begin
     CharIterator:=MapChar.Find(symbol);
     if CharIterator<>nil then
                              begin
                                   si:=CharIterator.value;
                                   if si.PSymbolInfo<>nil then
                                                              result:=si.PSymbolInfo
                                                          else
                                                              begin
                                                                   cfeatettfsymbol(symbol,si,@self);
                                                                   ProcessTriangleData(si.PSymbolInfo);
                                                                   CharIterator.Value:=si;
                                                                   result:=si.PSymbolInfo;
                                                              end;
                              end
                          else
                              begin
                                   if symbol=8709 then
                                                      begin
                                                           result:=GetOrReplaceSymbolInfo(216{//-ttf-//,TrianglesDataInfo});
                                                           exit;
                                                      end
                                                  else
                                                      begin
                                                           {CharIterator:=MapChar.Min;
                                                           si:=CharIterator.value;
                                                           result:=si.PSymbolInfo;}
                                                           result:=GetOrReplaceSymbolInfo(ord('?'));
                                                      end;
                              end;
     //-ttf-//TrianglesDataInfo:=si.TrianglesDataInfo;
     if CharIterator<>nil then
                              CharIterator.Destroy;
     exit;

//     if symbol=49 then
//                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.LLPrimitiveStartIndex=-1 then
                                        result:=@symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.LLPrimitiveStartIndex=-1 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;

initialization
end.
