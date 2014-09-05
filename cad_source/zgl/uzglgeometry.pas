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

unit uzglgeometry;
{$INCLUDE def.inc}
interface
uses gdbdrawcontext,uzglabstractdrawer,uzgprimitivessarray,uzgvertex3sarray,UGDBOpenArrayOfData,UGDBPoint3DArray,zcadsysvars,geometry,gdbvisualprop,UGDBPolyPoint3DArray,uzglline3darray,uzglpoint3darray,uzgltriangles3darray,ugdbltypearray,ugdbfont,sysutils,gdbase,memman,log,
     gdbasetypes,strproc;
type
{Export+}
PZGLGeometry=^ZGLGeometry;
PZPolySegmentData=^ZPolySegmentData;
ZPolySegmentData={$IFNDEF DELPHI}packed{$ENDIF} record
                                                      startpoint,endpoint,dir:GDBVertex;
                                                      length,nlength,naccumlength,accumlength:GDBDouble;
                                                end;
ZSegmentator={$IFNDEF DELPHI}packed{$ENDIF}object(GDBOpenArrayOfData)
                                                 dir,cp:GDBvertex;
                                                 cdp,angle:GDBDouble;
                                                 pcurrsegment:PZPolySegmentData;
                                                 ir:itrec;
                                                 PGeom:PZGLGeometry;
                                                 constructor InitFromLine(const startpoint,endpoint:GDBVertex;out length:GDBDouble;PG:PZGLGeometry);
                                                 constructor InitFromPolyline(const points:GDBPoint3dArray;out length:GDBDouble;const closed:GDBBoolean;PG:PZGLGeometry);
                                                 procedure startdraw;
                                                 procedure nextsegment;
                                                 procedure normalize(l:GDBDouble);
                                                 procedure draw(length:GDBDouble;paint:boolean);
                                           end;
ZGLGeometry={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 Vertex3S:ZGLVertex3Sarray;
                                 {Lines:ZGLLine3DArray;}
                                 {Points:ZGLpoint3DArray;}
                                 SHX:GDBPolyPoint3DArray;
                                 Triangles:ZGLTriangle3DArray;
                procedure DrawGeometry(rc:TDrawContext);virtual;
                procedure DrawNiceGeometry(rc:TDrawContext);virtual;
                procedure DrawLLPrimitives(drawer:TZGLAbstractDrawer);
                procedure Clear;virtual;
                constructor init;
                destructor done;virtual;
                procedure DrawLineWithLT(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);virtual;
                procedure DrawPolyLineWithLT(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);virtual;
                procedure DrawLineWithoutLT(const p1,p2:GDBVertex);virtual;
                procedure DrawPointWithoutLT(const p:GDBVertex);virtual;
                {}
                procedure AddLine(const p1,p2:GDBVertex);
                procedure AddPoint(const p:GDBVertex);
                {Patterns func}
                procedure PlaceNPatterns(var Segmentator:ZSegmentator;num:integer; const vp:PGDBLtypeProp;TangentScale,NormalScale,length:GDBDouble);
                procedure PlaceOnePattern(var Segmentator:ZSegmentator;const vp:PGDBLtypeProp;TangentScale,NormalScale,length,scale_div_length:GDBDouble);
                procedure PlaceShape(const StartPatternPoint:GDBVertex; PSP:PShapeProp;scale,angle:GDBDouble);
                procedure PlaceText(const StartPatternPoint:GDBVertex;PTP:PTextProp;scale,angle:GDBDouble);
             end;
{Export-}
implementation
procedure ZGLGeometry.DrawLLPrimitives(drawer:TZGLAbstractDrawer);
var
   PPrimitive:PTLLPrimitivePrefix;
   ProcessedSize:TArrayIndex;
   CurrentSize:TArrayIndex;
begin
     if LLprimitives.count=0 then exit;
     ProcessedSize:=0;
     PPrimitive:=LLprimitives.parray;
     while ProcessedSize<LLprimitives.count do
     begin
     case PPrimitive.LLPType of
                      LLLineId:begin
                                    Drawer.DrawLine(PTLLLine(PPrimitive)^.P1Index);
                                    CurrentSize:=sizeof(TLLLine);
                               end;
                      LLPointId:begin
                                    Drawer.DrawPoint(PTLLPoint(PPrimitive)^.PIndex);
                                    CurrentSize:=sizeof(TLLPoint);
                               end;
     end;
     ProcessedSize:=ProcessedSize+CurrentSize;
     inc(pbyte(PPrimitive),CurrentSize);
     end;
end;
procedure ZGLGeometry.AddPoint(const p:GDBVertex);
var
    tv:GDBVertex3S;
begin
     tv:=VertexD2S(p);
     LLprimitives.AddLLPPoint(Vertex3S.Add(@tv));
end;

procedure ZGLGeometry.AddLine(const p1,p2:GDBVertex);
var
    tv1,tv2:GDBVertex3S;
begin
     tv1:=VertexD2S(p1);
     tv2:=VertexD2S(p2);
     LLprimitives.AddLLPLine(Vertex3S.Add(@tv1));
     Vertex3S.Add(@tv2);

     //lines.Add(@p1);
     //lines.Add(@p2);

     {d:=geometry.Vertexlength(p1,p2)/30;
     a:=d/2;
     for i:=0 to 2 do
     begin
          tv:=geometry.VertexAdd(p1,createvertex(random*d-a,random*d-a,0));
          lines.Add(@tv);
          tv:=geometry.VertexAdd(p2,createvertex(random*d-a,random*d-a,0));
          lines.Add(@tv);
     end;}
end;
function CalcSegment(const startpoint,endpoint:GDBVertex;var segment:ZPolySegmentData;prevlength:GDBDouble):GDBDouble;
begin
     segment.startpoint:=startpoint;
     segment.endpoint:=endpoint;
     segment.dir:=geometry.VertexSub(endpoint,startpoint);
     segment.length:=geometry.Vertexlength(startpoint,endpoint);
     segment.accumlength:=prevlength+segment.length;
     segment.naccumlength:=segment.accumlength;
     result:=segment.accumlength;
end;
constructor ZSegmentator.InitFromLine(const startpoint,endpoint:GDBVertex;out length:GDBDouble;PG:PZGLGeometry);
var
   segment:ZPolySegmentData;
begin
     inherited init({$IFDEF DEBUGBUILD}'{A3EC2434-0A87-474E-BDA3-4E6C661C78AF}',{$ENDIF}1,sizeof(ZPolySegmentData));
     length:=CalcSegment(startpoint,endpoint,segment,0);
     add(@segment);
     normalize(length);
     PGeom:=pg;
end;
{function getlength(const points:GDBPoint3dArray;var sd:GDBOpenArrayOfData; const closed:GDBBoolean):GDBDouble;
var
begin
  result:=0;
  ptvprev:=points.beginiterate(ir);
  pfirstv:=ptvprev;
  ptv:=points.iterate(ir);
  if ptv<>nil then
  repeat
        result:=CalcSegment(ptvprev^,ptv^,segment,result);
        sd.add(@segment);

        ptvprev:=ptv;
        ptv:=points.iterate(ir);
  until ptv=nil;
  if closed then
                begin
                     result:=CalcSegment(ptv^,pfirstv^,segment,result);
                     sd.add(@segment);
                end;
end;}
constructor ZSegmentator.InitFromPolyline(const points:GDBPoint3dArray;out length:GDBDouble;const closed:GDBBoolean;PG:PZGLGeometry);
var
   segment:ZPolySegmentData;
   ptv,ptvprev,pfirstv: pgdbvertex;
   _ir:itrec;
   cl:GDBDouble;
begin
     if closed then
                   inherited init({$IFDEF DEBUGBUILD}'{A3EC2434-0A87-474E-BDA3-4E6C661C78AF}',{$ENDIF}points.Count,sizeof(ZPolySegmentData))
               else
                   inherited init({$IFDEF DEBUGBUILD}'{A3EC2434-0A87-474E-BDA3-4E6C661C78AF}',{$ENDIF}points.Count+1,sizeof(ZPolySegmentData));
    length:=0;
    ptvprev:=points.beginiterate(_ir);
    pfirstv:=ptvprev;
    ptv:=points.iterate(_ir);
    if ptv<>nil then
    repeat
          length:=CalcSegment(ptvprev^,ptv^,segment,length);
          add(@segment);

          ptvprev:=ptv;
          ptv:=points.iterate(_ir);
    until ptv=nil;
    if closed then
                  begin
                       length:=CalcSegment(ptvprev^,pfirstv^,segment,length);
                       add(@segment);
                  end;
    normalize(length);
    PGeom:=pg;
end;

procedure ZSegmentator.normalize(l:GDBDouble);
var
   psegment:PZPolySegmentData;
   _ir:itrec;
begin
     psegment:=beginiterate(_ir);
     if psegment<>nil then
     repeat
           psegment^.naccumlength:=psegment^.naccumlength/l;
           psegment^.nlength:=psegment^.length/l;
           psegment:=iterate(_ir);
     until psegment=nil;
end;
procedure ZSegmentator.nextsegment;
var
   psegment:PZPolySegmentData;
begin
     psegment:=iterate(ir);
     if psegment<>nil then
     begin
     cdp:=pcurrsegment^.naccumlength;
     pcurrsegment:=psegment;
     dir:=pcurrsegment^.dir;
     angle:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(dir.x,dir.y));
     cp:=pcurrsegment^.startpoint;
     end
     else
         pcurrsegment:=pcurrsegment;
end;
procedure ZSegmentator.startdraw;
begin
     pcurrsegment:=beginiterate(ir);
     dir:=pcurrsegment^.dir;
     angle:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(dir.x,dir.y));
     cdp:=0;
     cp:=pcurrsegment^.startpoint;
end;
procedure ZGLGeometry.DrawLineWithoutLT(const p1,p2:GDBVertex);
{var
   d,a:GDBDouble;
   tv:GDBVertex;
   i:integer;}
begin
     self.AddLine(p1,p2);
end;
procedure ZGLGeometry.DrawPointWithoutLT(const p:GDBVertex);
begin
     AddPoint(p);
     //points.Add(@p);
end;
function creatematrix(PInsert:GDBVertex; //Точка вставки
                      param:shxprop;     //Параметры текста
                      LineAngle,         //Угол линии
                      Scale:GDBDouble)   //Масштаб линии
                      :dmatrix4d;        //Выходная матрица
var
    mrot,mentrot,madd,mtrans,mscale:dmatrix4d;
begin
{case PSP.param.AD of
                    TACAbs:a:=PSP^.param.Angle*pi/180;
                    TACRel:a:=PSP^.param.Angle*pi/180-angle;
                    TACUpRight:a:=0;
                  end;}
    mrot:=CreateRotationMatrixZ(Sin(param.Angle*pi/180), Cos(param.Angle*pi/180));
    if param.AD=TACRel then
                           mentrot:=CreateRotationMatrixZ(Sin(LineAngle), Cos(LineAngle))
                       else
                           mentrot:=onematrix;
    madd:=geometry.CreateTranslationMatrix(createvertex(param.x*Scale,param.y*Scale,0));
    mtrans:=CreateTranslationMatrix(createvertex(PInsert.x,PInsert.y,PInsert.z));
    mscale:=CreateScaleMatrix(geometry.createvertex(param.Height*Scale,param.Height*Scale,param.Height*Scale));
    result:=onematrix;
    result:=MatrixMultiply(result,mscale);
    result:=MatrixMultiply(result,mrot);
    result:=MatrixMultiply(result,madd);
    result:=MatrixMultiply(result,mentrot);
    result:=MatrixMultiply(result,mtrans);
end;
function CreateReadableMatrix(PInsert:GDBVertex; //Точка вставки
                      param:shxprop;     //Параметры текста
                      LineAngle,         //Угол линии
                      Scale:GDBDouble;
                      dx,dy:GDBDouble)   //Масштаб линии
                      :dmatrix4d;        //Выходная матрица
var
    mrot,mrot2,mentrot,madd,madd2,madd3,mtrans,mscale:dmatrix4d;
begin
    mrot:=CreateRotationMatrixZ(Sin(param.Angle*pi/180), Cos(param.Angle*pi/180));
    if (param.AD<>TACAbs) then
                           mentrot:=CreateRotationMatrixZ(Sin(LineAngle), Cos(LineAngle))
                       else
                           mentrot:=onematrix;
    madd:=geometry.CreateTranslationMatrix(createvertex(param.x*Scale,param.y*Scale,0));
    mtrans:=CreateTranslationMatrix(createvertex(PInsert.x,PInsert.y,PInsert.z));
    mscale:=CreateScaleMatrix(geometry.createvertex(param.Height*Scale,param.Height*Scale,param.Height*Scale));
    result:=onematrix;
    result:=MatrixMultiply(result,mscale);

    if sysvar.DWG.DWG_RotateTextInLT^ then
    if (param.AD<>TACAbs) then
    if isNotReadableAngle(LineAngle) then
    begin
    madd2:=geometry.CreateTranslationMatrix(createvertex(dx*Scale,dy*Scale,0));
    madd3:=geometry.CreateTranslationMatrix(createvertex(-dx*Scale,-dy*Scale,0));
    mrot2:=CreateRotationMatrixZ(Sin(pi), Cos(pi));
    result:=MatrixMultiply(result,madd3);
    result:=MatrixMultiply(result,mrot2);
    result:=MatrixMultiply(result,madd2);
    end;

    result:=MatrixMultiply(result,mrot);
    result:=MatrixMultiply(result,madd);

    result:=MatrixMultiply(result,mentrot);
    result:=MatrixMultiply(result,mtrans);
end;
procedure ZGLGeometry.PlaceShape(const StartPatternPoint:GDBVertex;PSP:PShapeProp;scale,angle:GDBDouble);
var
    objmatrix,matr:dmatrix4d;
    minx,miny,maxx,maxy:GDBDouble;
begin
{ TODO : убрать двойное преобразование номера символа }
objmatrix:=creatematrix(StartPatternPoint,PSP^.param,angle,scale);
matr:=onematrix;
minx:=0;miny:=0;maxx:=0;maxy:=0;
if PSP.Psymbol<> nil then
                    PSP^.param.PStyle.pfont.CreateSymbol(shx,triangles,PSP.Psymbol.Number,objmatrix,matr,minx,miny,maxx,maxy,1);
end;
procedure ZGLGeometry.PlaceText(const StartPatternPoint:GDBVertex;PTP:PTextProp;scale,angle:GDBDouble);
var
    objmatrix,matr:dmatrix4d;
    minx,miny,maxx,maxy:GDBDouble;
    j:integer;
    TDInfo:TTrianglesDataInfo;
    sym:integer;
begin
{ TODO : убрать двойное преобразование номера символа }
objmatrix:={creatematrix}CreateReadableMatrix(StartPatternPoint,PTP^.param,angle,scale,PTP.txtL,PTP.txtH);
matr:=onematrix;
minx:=0;miny:=0;maxx:=0;maxy:=0;
for j:=1 to (system.length(PTP^.Text)) do
begin
     sym:=byte(PTP^.Text[j]);
          if ptp.param.PStyle.pfont.font.unicode then
                                                     sym:=ach2uch(sym);
PTP^.param.PStyle.pfont.CreateSymbol(shx,triangles,sym,objmatrix,matr,minx,miny,maxx,maxy,1);
matr[3,0]:=matr[3,0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j]),tdinfo).NextSymX;
end;
end;
procedure ZGLGeometry.PlaceOnePattern(var Segmentator:ZSegmentator;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     const vp:PGDBLtypeProp;                 //стиль и прочая лабуда
                                     TangentScale,NormalScale,length,scale_div_length:GDBDouble);     //направление, масштаб, длинна
var
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    ir2,ir3,ir4,ir5:itrec;
    addAllignVector:GDBVertex;
begin
  begin
    TDI:=vp.dasharray.beginiterate(ir2);
    PStroke:=vp.strokesarray.beginiterate(ir3);
    PSP:=vp.shapearray.beginiterate(ir4);
    PTP:=vp.textarray.beginiterate(ir5);
    if PStroke<>nil then
    repeat
    case TDI^ of
        TDIDash:begin
                     if PStroke^<>0 then
                     begin
                          if PStroke^>0 then
                                            Segmentator.draw(abs(PStroke^)*scale_div_length,true)
                                        else
                                            Segmentator.draw(abs(PStroke^)*scale_div_length,false);
                     end
                        else
                            DrawPointWithoutLT(Segmentator.cp);
                     //self.DrawLineWithoutLT(nulvertex,Segmentator.cp);
                     PStroke:=vp.strokesarray.iterate(ir3);
                end;
       TDIShape:begin
                     PlaceShape(Segmentator.cp,PSP,NormalScale,Segmentator.angle);
                     PSP:=vp.shapearray.iterate(ir4);
                end;
        TDIText:begin
                     PlaceText(Segmentator.cp,PTP,NormalScale,Segmentator.angle);
                     PTP:=vp.textarray.iterate(ir5);
                 end;
          end;
          TDI:=vp.dasharray.iterate(ir2);
    until TDI=nil;
end;
end;

procedure ZGLGeometry.PlaceNPatterns(var Segmentator:ZSegmentator;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     num:integer; //кол-во паттернов
                                     const vp:PGDBLtypeProp;                 //стиль и прочая лабуда
                                     TangentScale,NormalScale,length:GDBDouble);     //направление, масштаб, длинна
var i:integer;
    scale_div_length:GDBDouble;
begin
  scale_div_length:=TangentScale/length;
  for i:=1 to num do
  PlaceOnePattern(Segmentator,vp,TangentScale,NormalScale,length,scale_div_length);//рисуем один паттерн
end;
procedure ZSegmentator.draw(length:GDBDouble;paint:boolean);
var
    tcdp:GDBDouble;
    oldcp,tv:gdbvertex;
begin
     if cdp<1then
     begin
     tcdp:=length+cdp;
     if (cdp<-eps)and(tcdp>eps)then
                                   begin
                                        length:=length+cdp;
                                        cdp:=0;
                                   end;
     if (cdp>=-eps)and(tcdp>eps) then
     begin
     if tcdp<=(pcurrsegment.naccumlength+eps) then
                                          begin
                                               oldcp:=cp;
                                               tv:=VertexMulOnSc(dir,length/pcurrsegment.nlength);
                                               cp:=vertexadd(cp,tv);
                                               if paint then
                                                            self.PGeom.DrawLineWithoutLT(oldcp,cp);
                                               cdp:=tcdp;
                                          end
                                      else
                                          begin
                                               if paint then
                                                            self.PGeom.DrawLineWithoutLT(cp,pcurrsegment^.endpoint);
                                               length:=tcdp-pcurrsegment^.naccumlength;
                                               self.nextsegment;
                                               draw(length,paint);
                                               //tcdp:=cdp;
                                          end;
     end
     else
         cdp:=tcdp;
     end;
end;
procedure ZGLGeometry.DrawPolyLineWithLT(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);
var
    ptv,ptvprev,ptvfisrt: pgdbvertex;
    ir:itrec;
    TangentScale,NormalScale,polylength,TrueNumberOfPatterns,normalizedD,d,halfStroke,dend:GDBDouble;
    Segmentator:ZSegmentator;
    lt:PGDBLtypeProp;
    PStroke:PGDBDouble;
    ir3:itrec;
    minPatternsCount,NumberOfPatterns:integer;
procedure SetPolyUnLTyped;
begin
      ptv:=Points.beginiterate(ir);
      ptvfisrt:=ptv;
      if ptv<>nil then
      repeat
            ptvprev:=ptv;
            ptv:=Points.iterate(ir);
            if ptv<>nil then
                            DrawLineWithoutLT(ptv^,ptvprev^);
      until ptv=nil;
      if closed then
                    DrawLineWithoutLT(ptvprev^,ptvfisrt^);
end;
begin
  if Points.Count>1 then
  begin
       LT:=getLTfromVP(vp);
       if (LT=nil) or (LT.dasharray.Count=0) then
       begin
            SetPolyUnLTyped;
       end
       else
       begin
            //SetPolyUnLTyped;
           polylength:=0;
           Segmentator.InitFromPolyline(points,polylength,closed,@self);
           TangentScale:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale;
           NormalScale:=TangentScale;
           TrueNumberOfPatterns:=polylength/(TangentScale*LT.len);
           if ltgen and closed then
                        begin
                        minPatternsCount:=2;
                        NumberOfPatterns:=round(TrueNumberOfPatterns);
                        TangentScale:=polyLength/(NumberOfPatterns*LT.len);
                        end
                    else
                        begin
                        minPatternsCount:=1;
                        NumberOfPatterns:=trunc(TrueNumberOfPatterns);
                        end;
           if (NumberOfPatterns<minPatternsCount)or(NumberOfPatterns>SysVar.RD.RD_MaxLTPatternsInEntity^) then
                                                                                           SetPolyUnLTyped
           else
               begin
                    Segmentator.startdraw;
                    D:=(polyLength-(TangentScale*LT.len)*NumberOfPatterns)/2; //длинна добавки для выравнивания
                    normalizedD:=D/polyLength;

                    if (not closed)or(not ltgen) then
                    begin
                    PStroke:=LT^.strokesarray.beginiterate(ir3);//первый штрих
                    halfStroke:=(TangentScale*abs(PStroke^/2))/polylength;//первый штрих
                    Segmentator.draw(normalizedD-halfStroke,true);
                    end;


                    PlaceNPatterns(Segmentator,NumberOfPatterns,LT,TangentScale,NormalScale,polylength);//рисуем TrueNumberOfPatterns паттернов
                    dend:=1-Segmentator.cdp;
                    if dend>eps then
                                    Segmentator.draw(dend,true);//дорисовываем окончание если надо
               end;
           Segmentator.done;
       end;
  end;
end;

procedure ZGLGeometry.DrawLineWithLT(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
var
    scale,length:GDBDouble;
    num,normalizedD,D,halfStroke,dend:GDBDouble;
    ir3:itrec;
    PStroke:PGDBDouble;
    lt:PGDBLtypeProp;
    Segmentator:ZSegmentator;
begin
     LT:=getLTfromVP(vp);
     if (LT=nil) or (LT.dasharray.Count=0) then
     begin
          DrawLineWithoutLT(startpoint,endpoint);
     end
     else
     begin
          //LT:=getLTfromVP(vp);
          length := Vertexlength(startpoint,endpoint);//длина линии
          scale:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale;//фактический масштаб линии
          num:=Length/(scale*LT.len);//количество повторений шаблона
          if (num<1)or(num>SysVar.RD.RD_MaxLTPatternsInEntity^) then
                                     DrawLineWithoutLT(startpoint,endpoint) //не рисуем шаблон при большом количестве повторений
          else
          begin
               Segmentator.InitFromLine(startpoint,endpoint,length,@self);//длина линии
               Segmentator.startdraw;
               D:=(Length-(scale*LT.len)*trunc(num))/2; //длинна добавки для выравнивания
               normalizedD:=D/Length;

               PStroke:=LT^.strokesarray.beginiterate(ir3);//первый штрих
               halfStroke:=(scale*abs(PStroke^/2))/length;//первый штрих
               Segmentator.draw(normalizedD-halfStroke,true);


               PlaceNPatterns(Segmentator,trunc(num),LT,scale,scale,length);//рисуем num паттернов
               dend:=1-Segmentator.cdp;
               if dend>eps then
                               Segmentator.draw(dend,true);//дорисовываем окончание если надо
               Segmentator.done;
         end;
     end;
     //Lines.Shrink;
     //Points.Shrink;
     shx.Shrink;
     Triangles.Shrink;
     Vertex3S.Shrink;
     LLprimitives.Shrink;
end;

procedure ZGLGeometry.drawgeometry;
begin
  rc.drawer.PVertexBuffer:=@Vertex3S;
  DrawLLPrimitives(rc.drawer);
  //if Vertex3S.Count>0 then
  //Vertex3S.DrawGeometry;
  //if lines.Count>0 then
  //Lines.DrawGeometry;
  //if Points.Count>0 then
  //Points.DrawGeometry;
  if shx.Count>0 then
  //shx.DrawNiceGeometry;
  shx.DrawGeometry;
  if Triangles.Count>0 then
  Triangles.DrawGeometry;
end;
procedure ZGLGeometry.drawNicegeometry;
begin
  rc.drawer.PVertexBuffer:=@Vertex3S;
  DrawLLPrimitives(rc.drawer);
  //if Vertex3S.Count>0 then
  //Vertex3S.DrawGeometry;
  //if lines.Count>0 then
  //Lines.DrawGeometry;
  //if Points.Count>0 then
  //Points.DrawGeometry;
  if shx.Count>0 then
  shx.DrawNiceGeometry;
  if Triangles.Count>0 then
  Triangles.DrawGeometry;
end;
procedure ZGLGeometry.Clear;
begin
  Vertex3S.Clear;
  LLprimitives.Clear;
  //Lines.Clear;
  //Points.Clear;
  SHX.Clear;
  Triangles.Clear;
end;
constructor ZGLGeometry.init;
begin
Vertex3S.init({$IFDEF DEBUGBUILD}'{28B96AAC-8AD4-4BC8-85CA-78AAA0700CAF}',{$ENDIF}100);
LLprimitives.init({$IFDEF DEBUGBUILD}'{6326CE08-54B5-404E-B567-C50AFEFBABEE}',{$ENDIF}100);
//Lines.init({$IFDEF DEBUGBUILD}'{261A56E9-FC91-4A6D-A534-695778390843}',{$ENDIF}100);
//Points.init({$IFDEF DEBUGBUILD}'{AF4B3440-50B5-4482-A2B7-D38DDE4EC731}',{$ENDIF}100);
SHX.init({$IFDEF DEBUGBUILD}'{93201215-874A-4FC5-8062-103AF05AD930}',{$ENDIF}100);
Triangles.init({$IFDEF DEBUGBUILD}'{EE569D51-8C1D-4AE3-A80F-BBBC565DA372}',{$ENDIF}100);
end;
destructor ZGLGeometry.done;
begin
Vertex3S.done;
LLprimitives.done;
//Lines.done;
//Points.done;
SHX.done;
Triangles.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPoint3DArray.initialization');{$ENDIF}
end.

