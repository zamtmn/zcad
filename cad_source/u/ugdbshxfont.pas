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

unit ugdbshxfont;
{$INCLUDE def.inc}
interface
uses glu,math,OGLSpecFunc,uzglfonttriangles2darray,TTTypes,TTObjs,gvector,gmap,gutil,EasyLazFreeType,memman,UGDBPolyPoint3DArray,gdbobjectsconstdef,UGDBPoint3DArray,strproc,UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
PTTTFSymInfo=^TTTFSymInfo;
TTTFSymInfo=packed record
                      GlyphIndex:Integer;
                      PSymbolInfo:PGDBSymdolInfo;
                      TrianglesDataInfo:TTrianglesDataInfo;
                end;
{$IFNDEF DELPHI}
TLessInt={specialize }TLess<integer>;
TMapChar={specialize }TMap<integer,{integer}TTTFSymInfo,TLessInt>;
{$ENDIF}
{$IFNDEF DELPHI}
TVector2D={specialize }TVector<GDBvertex2D>;
{$ENDIF}
TPointAttr=(TPA_OnCurve,TPA_NotOnCurve);
TSolverMode=(TSM_WaitStartCountur,TSM_WaitStartPoint,TSM_WaitPoint);
TBezierSolver2D=class
                     FArray:TVector2D;
                     FMode:TSolverMode;
                     BOrder:integer;
                     shx:PGDBOpenArrayOfByte;
                     shxsize:PGDBWord;
                     scontur,truescontur:GDBvertex2D;
                     sconturpa:TPointAttr;
                     constructor create;
                     destructor Destroy;overload;
                     procedure AddPoint(x,y:double;pa:TPointAttr);overload;
                     procedure AddPoint(p:GDBvertex2D;pa:TPointAttr);overload;
                     procedure ChangeMode(Mode:TSolverMode);
                     procedure EndCountur;
                     procedure solve;
                     function getpoint(t:gdbdouble):GDBvertex2D;
                end;
{EXPORT+}
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TSymbolInfoArray=array [0..255] of GDBsymdolinfo;
PBASEFont=^BASEFont;
BASEFont=object(GDBaseObject)
              unicode:GDBBoolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:GDBOpenArrayOfData;
              constructor init;
              destructor done;virtual;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;abstract;
              function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;

              function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;virtual;
              function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;virtual;
              function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
        end;
PSHXFont=^SHXFont;
SHXFont=object(BASEFont)
              compiledsize:GDBInteger;
              h,u:GDBByte;
              SHXdata:GDBOpenArrayOfByte;
              constructor init;
              destructor done;virtual;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;
        end;
PTTFFont=^TTFFont;
TTFFont=object(SHXFont)
              ftFont: TFreeTypeFont;
              MapChar:TMapChar;
              MapCharIterator:TMapChar.TIterator;
              TriangleData:ZGLFontTriangle2DArray;
              function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;virtual;
              function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;
              constructor init;
              destructor done;virtual;
        end;

{EXPORT-}
var
   BS:TBezierSolver2D;
   ttessv:gdbvertex;
   trmode:Cardinal;
   pointcount:integer;
   triangle:array[0..2] of GDBFontVertex2D;
procedure cfeatettfsymbol(const chcode:integer;var si:TTTFSymInfo; pttf:PTTFFont{;var pf:PGDBfont});
implementation
uses {math,}log;
var
   ptrdata:PZGLFontTriangle2DArray;
procedure adddcross(shx:PGDBOpenArrayOfByte;var size:GDBWord;x,y:fontfloat);
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
procedure addline(shx:PGDBOpenArrayOfByte;var size:GDBWord;x,y,x1,y1:fontfloat);
begin
    shx.AddByteByVal(SHXLine);
    shx.AddFontFloat(@x);
    shx.AddFontFloat(@y);

    shx.AddFontFloat(@x1);
    shx.AddFontFloat(@y1);
    inc(size);
end;
procedure addgcross(shx:PGDBOpenArrayOfByte;var size:GDBWord;x,y:fontfloat);
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

end;

procedure TessErrorCallBack(error: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
     error:=error;
end;
procedure TessBeginCallBack(gmode: Cardinal;v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
     if gmode=GL_TRIANGLES then
                               gmode:=gmode;
     pointcount:=0;
     trmode:=gmode;
end;
procedure TessVertexCallBack(const v,v2: Pdouble);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
   k:integer;
   pv:pgdbvertex;
   trp:GDBFontVertex2D;
begin
     if v=nil then exit;
     pv:=pointer(v);
     trp.x:=pv.x;
     trp.y:=pv.y;
     if pointcount<3 then
                         begin
                              triangle[pointcount]:=trp;
                              inc(pointcount);
                              if pointcount=3 then
                                             begin
                                             ptrdata^.Add(@triangle[0]);
                                             ptrdata^.Add(@triangle[1]);
                                             ptrdata^.Add(@triangle[2]);
                                             if trmode=GL_TRIANGLES then
                                                                       pointcount:=0;
                                             end;
                         end
                     else
                         begin
                              case trmode of
                       GL_TRIANGLE_FAN:begin
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=trp;
                                            ptrdata^.Add(@triangle[0]);
                                            ptrdata^.Add(@triangle[1]);
                                            ptrdata^.Add(@triangle[2]);
                                       end;
                     GL_TRIANGLE_STRIP:begin
                                            triangle[0]:=triangle[1];
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=trp;
                                            ptrdata^.Add(@triangle[0]);
                                            ptrdata^.Add(@triangle[1]);
                                            ptrdata^.Add(@triangle[2]);
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
   fe:boolean;
   glyph:TFreeTypeGlyph;
   _glyph:PGlyph;
   //psyminfo,psubsyminfo:PGDBsymdolinfo;

   x,y,x1,y1,scx,scy:fontfloat;
   cends,lastoncurve:integer;
   startcountur:boolean;
   startcounturindex:integer;
   k:gdbdouble;
   Iterator:TMapChar.TIterator;
   done:boolean;
   tesselator:TessObj;
   tv:GDBFontVertex2D;
   lastv:GDBFontVertex2D;
   tparray:array[0..65535] of gdbvertex;
   tparrayindex,oldtparrayindex:integer;
   trp:GDBFontVertex2D;
procedure CompareAndTess(v:GDBFontVertex2D);
begin
     if (abs(lastv.x-v.x)>eps)or(abs(lastv.y-v.y)>eps) then
     begin
          tparray[tparrayindex].x:=v.x;
          tparray[tparrayindex].y:=v.y;
          tparray[tparrayindex].z:=0;
          //OGLSM.TessVertex(tesselator,@tparray[tparrayindex],nil);
          inc(tparrayindex);
          lastv:=v;
     end
        else
            v:=v;
end;

procedure EndSymContour;
var
   psymbol,pendsymbol:GDBPointer;
   v:GDBFontVertex2D;
   len: GDBWord;
   count:integer;
begin
     {v.x:=0;
     v.y:=0;
     OGLSM.TessVertex(tesselator,@v,@ttessv);
     v.x:=1;
     v.y:=0;
     OGLSM.TessVertex(tesselator,@v,@ttessv);
     v.x:=1;
     v.y:=1;
     OGLSM.TessVertex(tesselator,@v,@ttessv);
     v.x:=0;
     v.y:=1;
     OGLSM.TessVertex(tesselator,@v,@ttessv);}
     bs.EndCountur;
     lastv.x:=Infinity;
     lastv.y:=Infinity;
     oldtparrayindex:=tparrayindex;
      if startcounturindex<pttf.SHXdata.Count then
      begin
           psymbol:=pttf.SHXdata.getelement(startcounturindex);
           pendsymbol:=pttf.SHXdata.getelement(pttf.SHXdata.Count);
           while psymbol<pendsymbol do
               begin
                 case GDBByte(psymbol^) of
                   SHXLine:
                     begin
                       inc(pGDBByte(psymbol), sizeof(SHXLine));
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
                       inc(pGDBByte(psymbol), sizeof(SHXPoly));
                       len := GDBWord(psymbol^);
                       inc(pGDBByte(psymbol), sizeof(GDBWord));
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
           //si.TrianglesDataInfo.TrianglesAddr:=pttf^.TriangleData.count;
           //si.TrianglesDataInfo.TrianglesSize:=3;
           for count:=oldtparrayindex to tparrayindex-2 do
           //for count:=tparrayindex-2 downto oldtparrayindex do
           begin
                OGLSM.TessVertex(tesselator,@tparray[count],@tparray[count]);
                //gluTessVertex(tesselator, @tparray[count], @tparray[count]);

                //trp.x:=tparray[count].x;
                //trp.y:=tparray[count].y;
                //ptrdata^.Add(@trp);
                //TessVertexCallBack(@tparray[count],nil);

           end;

           OGLSM.TessEndContour(tesselator);


           //bs.EndCountur;

           (*
           gluTessBeginContour(tesselator);
                   coord[0].x := 0.35337424278259277;
                   coord[0].y := 0;
                   coord[0].z := 0;
                   gluTessVertex(tesselator, @coord[0], @coord[0]);
                   coord[1].x := 0.35337424278259277;
                   coord[1].y := 0.85889571905136108;
                   coord[1].z := 0;
                   gluTessVertex(tesselator, @coord[1], @coord[1]);
                   coord[2].x := 0.032719835638999939;
                   coord[2].y := 0.85889571905136108;
                   coord[2].z := 0;
                   gluTessVertex(tesselator, @coord[2], @coord[2]);
                   coord[3].x := 0.032719835638999939;
                   coord[3].y := 0.97505110502243042;
                   coord[3].z := 0;

                   gluTessVertex(tesselator, @coord[3], @coord[3]);
                   coord[4].x := 0.80490797758102417;
                   coord[4].y := 0.97505110502243042;
                   coord[4].z := 0;
                   gluTessVertex(tesselator, @coord[4], @coord[4]);
                   coord[5].x := 0.80490797758102417;
                   coord[5].y := 0.85889571905136108;
                   coord[5].z := 0;
                   gluTessVertex(tesselator, @coord[5], @coord[5]);
                   coord[6].x := 0.48261758685112;
                   coord[6].y := 0.85889571905136108;
                   coord[6].z := 0;
                   gluTessVertex(tesselator, @coord[6], @coord[6]);
                   coord[7].x := 0.48261758685112;
                   coord[7].y := 0;
                   coord[7].z := 0;
                   gluTessVertex(tesselator, @coord[7], @coord[7]);

                 gluTessEndContour(tesselator);*)
end;
begin
  k:=1;
  {$if FPC_FULlVERSION>=20701}
  k:=1/pttf^.ftFont.CapHeight;
  {$ENDIF}
  BS.shx:=@pttf^.SHXdata;

  BS.fmode:=TSM_WaitStartCountur;
  glyph:=pttf^.ftFont.Glyph[{i}si.GlyphIndex];
  _glyph:=glyph.Data.z;
  //programlog.LogOutStr('TTF: Symbol index='+inttostr(si.GlyphIndex)+'; code='+inttostr(chcode),0);
  //if chcode=56 then
  //                  chcode:=chcode;
  si.PSymbolInfo:=pttf^.GetOrCreateSymbolInfo(chcode);
  BS.shxsize:=@si.PSymbolInfo.size;
  si.PSymbolInfo.addr:=pttf.SHXdata.Count;
  si.PSymbolInfo.w:=glyph.Bounds.Right*k/64;
  si.PSymbolInfo.NextSymX:=glyph.Advance*k;
  si.PSymbolInfo.SymMaxX:=si.PSymbolInfo.NextSymX;
  si.PSymbolInfo.SymMinX:=0;
  si.PSymbolInfo.h:=glyph.Bounds.Top*k/64;
  si.PSymbolInfo.size:=0;
  si.TrianglesDataInfo.TrianglesAddr:=pttf^.TriangleData.count;
  si.TrianglesDataInfo.TrianglesSize:=pttf^.TriangleData.count;
  ptrdata:=@pttf^.TriangleData;
  tparrayindex:=0;
  if _glyph^.outline.n_contours>0 then
  begin
  tesselator:=OGLSM.NewTess;
  OGLSM.TessCallback(tesselator,GLU_TESS_VERTEX_DATA,@TessVertexCallBack);
  OGLSM.TessCallback(tesselator,GLU_TESS_BEGIN_DATA,@TessBeginCallBack);
  OGLSM.TessCallback(tesselator,GLU_TESS_Error_DATA,@TessErrorCallBack);
  //gluTessProperty(tesselator,GLU_TESS_WINDING_RULE,GLU_TESS_WINDING_ODD);
  //gluTessProperty(tesselator, GLU_TESS_BOUNDARY_ONLY, GLU_FALSE);
  //gluTessProperty(tesselator, GLU_TESS_TOLERANCE , 1000.0);
  OGLSM.TessBeginPolygon(tesselator,nil);
  //gluTessNormal( tesselator, 0.0, 0.0, -1.0);
  cends:=0;
  lastoncurve:=0;
  startcountur:=true;
  for j:=0 to _glyph^.outline.n_points do
  begin
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
                            scx:=x1;
                            scy:=y1;
                            startcounturindex:=pttf.SHXdata.Count;
                            startcountur:=false;
                       end
  else
  begin
    if (_glyph^.outline.flags[j] and TT_Flag_On_Curve)<>0 then
    begin
         //shared.HistoryOutStr(inttostr(j-lastoncurve));
         if j-lastoncurve>3 then
                                lastoncurve:=lastoncurve;
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
    end;
  end;
  x:=x1;
  y:=y1;
  end;
  //EndSymContour;
  OGLSM.TessEndPolygon(tesselator);
  si.TrianglesDataInfo.TrianglesSize:=pttf^.TriangleData.count-si.TrianglesDataInfo.TrianglesSize;
  OGLSM.DeleteTess(tesselator);
  end;
end;
constructor TBezierSolver2D.create;
begin
     FArray:=TVector2D.Create;
     FArray.Reserve(10);
     FMode:=TSM_WaitStartCountur;
end;
destructor TBezierSolver2D.Destroy;
begin
     FArray.Destroy;
     inherited;
end;

procedure TBezierSolver2D.AddPoint(x,y:double;pa:TPointAttr);
var
   p:GDBvertex2D;
begin
     p.x:=x;
     p.y:=y;
     AddPoint(p,pa);
end;
procedure TBezierSolver2D.AddPoint(p:GDBvertex2D;pa:TPointAttr);
begin
     case FMode of
     TSM_WaitStartCountur:begin
                             scontur:=p;
                             sconturpa:=pa;
                             if pa=TPA_OnCurve then
                                                   FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitStartPoint:begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitPoint:begin
                        if pa=TPA_OnCurve then
                        begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitStartPoint);
                             AddPoint(p,pa);
                        end
                        else
                            begin
                                 if FArray.Size=0 then
                                 begin
                                      truescontur:=Vertexmorph(scontur,p,0.5);
                                      AddPoint(truescontur,TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                            else if FArray.Size=2 then
                                 begin
                                      AddPoint(Vertexmorph(FArray.Back,p,0.5),TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                                 else
                                 begin
                                      FArray.PushBack(p);
                                 end;
                            end;
                   end;
     end;
end;
procedure TBezierSolver2D.ChangeMode(Mode:TSolverMode);
begin
  case Mode of
  TSM_WaitStartPoint:begin
                          if FMode=TSM_WaitPoint then
                          begin
                               solve;
                               FArray.Clear;
                          end;
                     end;
  end;
  FMode:=mode;
end;
procedure TBezierSolver2D.EndCountur;
begin
  //case fMode of
  //TSM_WaitStartPoint:begin

  if sconturpa=TPA_OnCurve then
                               AddPoint(scontur,TPA_OnCurve)
                           else
                               begin
                                    AddPoint(scontur,TPA_NotOnCurve);
                                    AddPoint(truescontur,TPA_OnCurve);
                               end;
  //                   end;
  //end;
  //solve;
  ChangeMode(TSM_WaitStartCountur);
  farray.Clear;
end;
function TBezierSolver2D.getpoint(t:gdbdouble):GDBvertex2D;
var
   i,j,k,rindex:integer;
begin
     rindex:=BOrder-1;
     j:=BOrder;
     k:=j;
     for i:=0 to round((BOrder+2)*(BOrder-1)/2) do
     begin
          dec(k);
          if k>0 then
          begin
          inc(rindex);
          farray[rindex]:=Vertexmorph(FArray[i],FArray[i+1],t);
          end
          else
          begin
               dec(j);
               k:=j;
          end;
     end;
     result:=farray[rindex];
end;
procedure TBezierSolver2D.solve;
var
   size,i,j,rindex,n:integer;
   p,prevp:GDBvertex2D;
begin
     BOrder:=FArray.Size;
     if border<3 then
     begin
          if border=2 then
          addline(shx,shxsize^,FArray[0].x,FArray[0].y,FArray[1].x,FArray[1].y);
          exit;
     end;
     size:=round((BOrder+2)*(BOrder-1)/2)+1;
     FArray.Resize(size);
     n:=BOrder{*2}-1+2;//<----------------------------
     for j:=1 to n-1 do
     begin
          p:=getpoint(j/n);
          //addgcross(shx,shxsize^,p.x,p.y);
          if j>1 then
                     addline(shx,shxsize^,prevp.x,prevp.y,p.x,p.y)
                 else
                     addline(shx,shxsize^,FArray[0].x,FArray[0].y,p.x,p.y);
          prevp:=p;
     end;
          addline(shx,shxsize^,p.x,p.y,FArray[BOrder-1].x,FArray[BOrder-1].y);
end;
constructor BASEFont.init;
var
   i:integer;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].addr:=0;
      symbolinfo[i].size:=0;
      symbolinfo[i].LatestCreate:=false;
     end;
     unicode:=false;
     unisymbolinfo.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1000,sizeof(GDBUNISymbolInfo));
end;
destructor BASEFont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].Name:='';
     end;

     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.symbolinfo.Name:='';
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     unisymbolinfo.{FreeAnd}Done;
end;
function BASEFont.GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     TrianglesDataInfo.TrianglesAddr:=0;
     TrianglesDataInfo.TrianglesSize:=0;
     if symbol=49 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.addr=0 then
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
                            if result^.addr=0 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;
function BASEFont.GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;
begin
     result:=nil;
end;

function BASEFont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.addr:=0;
                                 usi.symbolinfo.NextSymX:=0;
                                 usi.symbolinfo.SymMaxY:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.size:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo.SymMinY:=0;
                                 usi.symbolinfo.LatestCreate:=false;
                                 killstring(usi.symbolinfo.Name);
                                 unisymbolinfo.Add(@usi);

                                 result:=@(PGDBUNISymbolInfo(unisymbolinfo.getelement(unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
function BASEFont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   //debug:GDBInteger;
begin
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           //debug:=pobj^.symbol;
           //debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
constructor SHXFont.init;
begin
     inherited;
     u:=1;
     h:=1;
     SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
end;
destructor SHXFont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;
begin
     inherited;
     SHXdata.done;
end;
function SHXFont.GetSymbolDataAddr(offset:integer):pointer;
begin
     result:=SHXdata.getelement(offset);
end;
constructor TTFFont.init;
begin
     inherited;
     TriangleData.init({$IFDEF DEBUGBUILD}'{4A97D8DA-8B55-41AA-9287-7F0C842AC2D0}',{$ENDIF}200);
     ftFont:=TFreeTypeFont.create;
     MapChar:=TMapChar.Create;
     MapCharIterator:=TMapChar.TIterator.Create;
end;
destructor TTFFont.done;
begin
     inherited;
     TriangleData.done;
     ftFont.Destroy;
     MapCharIterator.Destroy;
     MapChar.Destroy;
end;
function TTFFont.GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;
begin
     result:=self.TriangleData.getelement(offset);
end;
function TTFFont.GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
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
                                                                   CharIterator.Value:=si;
                                                                   result:=si.PSymbolInfo;
                                                              end;
                              end
                          else
                              begin
                                   //result:=@symbolinfo[ord('?')];
                                   CharIterator:=MapChar.Min;
                                   si:=CharIterator.value;
                                   result:=si.PSymbolInfo;
                              end;
     TrianglesDataInfo:=si.TrianglesDataInfo;
     if CharIterator<>nil then
                              CharIterator.Destroy;
     exit;

     if symbol=49 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.addr=0 then
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
                            if result^.addr=0 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBSHXFont.initialization');{$ENDIF}
  BS:=TBezierSolver2D.create;
finalization
  bs.Destroy;
end.