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
uses UGDBOpenArrayOfData,UGDBPoint3DArray,zcadsysvars,geometry,gdbvisualprop,UGDBPolyPoint3DArray,uzglline3darray,uzglpoint3darray,uzgltriangles3darray,ugdbltypearray,ugdbfont,sysutils,gdbase,memman,log,
     gdbasetypes;
type
{Export+}
ZGLGeometry={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 Lines:ZGLLine3DArray;
                                 Points:ZGLpoint3DArray;
                                 SHX:GDBPolyPoint3DArray;
                                 Triangles:ZGLTriangle3DArray;
                procedure DrawGeometry;virtual;
                procedure DrawNiceGeometry;virtual;
                procedure Clear;virtual;
                constructor init;
                destructor done;virtual;
                procedure DrawLineWithLT(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);virtual;
                procedure DrawPolyLineWithLT(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed:GDBBoolean);virtual;
                procedure DrawLineWithoutLT(const p1,p2:GDBVertex);virtual;
                procedure DrawPointWithoutLT(const p:GDBVertex);virtual;
                procedure PlaceNPatterns(StartPatternPoint,FactStartPoint:GDBVertex;num:integer; const vp:GDBObjVisualProp;dir:GDBvertex;scale,length:GDBDouble);
             end;
ZPolySegmentData={$IFNDEF DELPHI}packed{$ENDIF} record
                                                      startpoint,endpoint,dir:GDBVertex;
                                                      length,accumlength:GDBDouble;
                                                end;
{Export-}
implementation
function getlength(const points:GDBPoint3dArray;var sd:GDBOpenArrayOfData; const closed:GDBBoolean):GDBDouble;
var
    ptv,ptvprev,pfirstv: pgdbvertex;
    ir:itrec;
    segment:ZPolySegmentData;
    cl:GDBDouble;

begin
  result:=0;
  ptvprev:=points.beginiterate(ir);
  pfirstv:=ptvprev;
  ptv:=points.iterate(ir);
  if ptv<>nil then
  repeat
        cl:=geometry.Vertexlength(ptv^,ptvprev^);

        segment.startpoint:=ptvprev^;
        segment.endpoint:=ptvprev^;
        segment.length:=cl;
        segment.accumlength:=result;

        result:=result+cl;

        ptvprev:=ptv;
        ptv:=points.iterate(ir);
  until ptv=nil;
  if closed then
                result:=result+geometry.Vertexlength(pfirstv^,ptvprev^);
end;
procedure ZGLGeometry.DrawPolyLineWithLT(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed:GDBBoolean);
var
    ptv,ptvprev,ptvfisrt: pgdbvertex;
    ir:itrec;
    scale,polylength,num,d:GDBDouble;
    sd:GDBOpenArrayOfData;
procedure SetPolyUnLTyped;
begin
      ptv:=Points.beginiterate(ir);
      ptvfisrt:=ptv;
      if ptv<>nil then
      repeat
            ptvprev:=ptv;
            ptv:=Points.iterate(ir);
            if ptv<>nil then
                            DrawLineWithLT(ptv^,ptvprev^,vp);
      until ptv=nil;
      if closed then
                    DrawLineWithLT(ptvprev^,ptvfisrt^,vp);
end;
begin
  if Points.Count>1 then
  begin
       if (vp.LineType=nil) or (vp.LineType.dasharray.Count=0) then
       begin
            SetPolyUnLTyped;
       end
       else
       begin
       if closed then
                     sd.init({$IFDEF DEBUGBUILD}'{A3EC2434-0A87-474E-BDA3-4E6C661C78AF}',{$ENDIF}sizeof(ZPolySegmentData),points.Count+1)
                 else
                     sd.init({$IFDEF DEBUGBUILD}'{A3EC2434-0A87-474E-BDA3-4E6C661C78AF}',{$ENDIF}sizeof(ZPolySegmentData),points.Count);
       polylength:=getlength(points,sd,closed);
       scale:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale;
       num:=polylength/(scale*vp.LineType.len);
       if (num<1)or(num>1000) then
                                  SetPolyUnLTyped
       else
           begin
                SetPolyUnLTyped;
                d:=(polylength-(scale*vp.LineType.len)*trunc(num))/2;
           end;
       sd.done;
       end;
  end;
end;
procedure ZGLGeometry.DrawLineWithoutLT(const p1,p2:GDBVertex);
begin
     lines.Add(@p1);
     lines.Add(@p2);
end;
procedure ZGLGeometry.DrawPointWithoutLT(const p:GDBVertex);
begin
     points.Add(@p);
end;
function creatematrix(PInsert:GDBVertex; //Точка вставки
                      param:shxprop;     //Параметры текста
                      LineAngle,         //Угол линии
                      Scale:GDBDouble)   //Масштаб линии
                      :dmatrix4d;        //Выходная матрица
var
    mrot,mentrot,madd,mtrans,mscale:dmatrix4d;
begin
    mrot:=CreateRotationMatrixZ(Sin(param.Angle*pi/180), Cos(param.Angle*pi/180));
    mentrot:=CreateRotationMatrixZ(Sin(LineAngle), Cos(LineAngle));
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

procedure ZGLGeometry.PlaceNPatterns(StartPatternPoint,FactStartPoint:GDBVertex;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     num:integer;                               //количество паттернов
                                     const vp:GDBObjVisualProp;                 //стиль и прочая лабуда
                                     dir:GDBvertex;scale,length:GDBDouble);     //направление, масштаб, длинна
var i,j:integer;
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    scale_div_length:GDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    ir2,ir3,ir4,ir5:itrec;
    addAllignVector:GDBVertex;
    a:GDBDouble;
    objmatrix,matr:dmatrix4d;
    minx,miny,maxx,maxy:GDBDouble;
    TDInfo:TTrianglesDataInfo;
begin
  scale_div_length:=scale/length;
  a:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(dir.x,dir.y));
  for i:=1 to num do
  begin
    TDI:=vp.LineType^.dasharray.beginiterate(ir2);
    PStroke:=vp.LineType^.strokesarray.beginiterate(ir3);
    PSP:=vp.LineType^.shapearray.beginiterate(ir4);
    PTP:=vp.LineType^.textarray.beginiterate(ir5);
    if PStroke<>nil then
    repeat
    case TDI^ of
        TDIDash:begin
                     if PStroke^<>0 then
                     begin
                          addAllignVector:=geometry.VertexMulOnSc(dir,abs(PStroke^)*scale_div_length);
                          addAllignVector:=geometry.VertexAdd(StartPatternPoint,addAllignVector);
                          if PStroke^>0 then
                          begin
                               DrawLineWithoutLT(FactStartPoint,addAllignVector);
                          end;
                          StartPatternPoint:=addAllignVector;
                          FactStartPoint:=StartPatternPoint;
                     end
                        else
                            DrawPointWithoutLT(StartPatternPoint);

                     PStroke:=vp.LineType^.strokesarray.iterate(ir3);
                end;
       TDIShape:begin
                     { TODO : убрать двойное преобразование номера символа }
                     objmatrix:=creatematrix(StartPatternPoint,PSP^.param,a,scale);
                     matr:=onematrix;
                     minx:=0;miny:=0;maxx:=0;maxy:=0;
                     PSP^.param.PStyle.pfont.CreateSymbol(shx,triangles,PSP.Psymbol.Number,objmatrix,matr,minx,miny,maxx,maxy,1);
                     PSP:=vp.LineType^.shapearray.iterate(ir4);
                end;
        TDIText:begin
                      { TODO : убрать двойное преобразование номера символа }
                     objmatrix:=creatematrix(StartPatternPoint,PTP^.param,a,scale);
                      matr:=onematrix;
                      minx:=0;miny:=0;maxx:=0;maxy:=0;
                      for j:=1 to (system.length(PTP^.Text)) do
                      begin
                      PTP^.param.PStyle.pfont.CreateSymbol(shx,triangles,byte(PTP^.Text[j]),objmatrix,matr,minx,miny,maxx,maxy,1);
                      matr[3,0]:=matr[3,0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j]),tdinfo).NextSymX;
                      end;
                      PTP:=vp.LineType^.textarray.iterate(ir5);
                 end;
          end;
          TDI:=vp.LineType^.dasharray.iterate(ir2);
    until TDI=nil;
  end;
end;

procedure ZGLGeometry.DrawLineWithLT(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
var
    scale,length:GDBDouble;
    num,d:GDBDouble;
    outPatternPoint,addAllignVector,halfStrokeAllignVector:GDBVertex;
    dir:GDBvertex;
    ir3:itrec;
    PStroke:PGDBDouble;
begin
     if (vp.LineType=nil) or (vp.LineType.dasharray.Count=0) then
     begin
          DrawLineWithoutLT(startpoint,endpoint);
     end
     else
     begin
          length := Vertexlength(startpoint,endpoint);//длина линии
          dir:=geometry.VertexSub(endpoint,startpoint);//направление линии
          scale:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale;//фактический масштаб линии
          num:=Length/(scale*vp.LineType.len);//количество повторений шаблона
          if (num<1)or(num>1000) then
                                     DrawLineWithoutLT(startpoint,endpoint) //не рисуем шаблон при большом количестве повторений
          else
          begin
               d:=(Length-(scale*vp.LineType.len)*trunc(num))/2; //длинна добавки для выравнивания
               d:=d/Length;
               addAllignVector:=VertexMulOnSc(dir,d);//вектор добавки для выравнивания
               outPatternPoint:=VertexSub(endpoint,addAllignVector);//последняя точка шаблонов на линии

               {сдвиг на половину первого штриха}
               PStroke:=vp.LineType^.strokesarray.beginiterate(ir3);//первый штрих
               halfStrokeAllignVector:=VertexMulOnSc(dir,(scale*abs(PStroke^/2))/length);//вектор сдвига на пол первого штриха
               outPatternPoint:=VertexSub(outPatternPoint,halfStrokeAllignVector);//сдвиг последней точки на полпервого штриха

               {добавка в конец линии}
               DrawLineWithoutLT(outPatternPoint,endpoint);

               outPatternPoint:=VertexAdd(startpoint,addAllignVector);//вектор добавки для выравнивания
               outPatternPoint:=geometry.VertexSub(outPatternPoint,halfStrokeAllignVector);//первая точка шаблонов на линии

               PlaceNPatterns(outPatternPoint,startpoint,trunc(num),vp,dir,scale,length);//исуем num паттернов
         end
     end;
     Lines.Shrink;
     Points.Shrink;
     shx.Shrink;
     Triangles.Shrink;
end;

procedure ZGLGeometry.drawgeometry;
begin
  if lines.Count>0 then
  Lines.DrawGeometry;
  if Points.Count>0 then
  Points.DrawGeometry;
  if shx.Count>0 then
  //shx.DrawNiceGeometry;
  shx.DrawGeometry;
  if Triangles.Count>0 then
  Triangles.DrawGeometry;
end;
procedure ZGLGeometry.drawNicegeometry;
begin
  if lines.Count>0 then
  Lines.DrawGeometry;
  if Points.Count>0 then
  Points.DrawGeometry;
  if shx.Count>0 then
  shx.DrawNiceGeometry;
  if Triangles.Count>0 then
  Triangles.DrawGeometry;
end;
procedure ZGLGeometry.Clear;
begin
  Lines.Clear;
  Points.Clear;
  SHX.Clear;
  Triangles.Clear;
end;
constructor ZGLGeometry.init;
begin
Lines.init({$IFDEF DEBUGBUILD}'{261A56E9-FC91-4A6D-A534-695778390843}',{$ENDIF}100);
Points.init({$IFDEF DEBUGBUILD}'{AF4B3440-50B5-4482-A2B7-D38DDE4EC731}',{$ENDIF}100);
SHX.init({$IFDEF DEBUGBUILD}'{93201215-874A-4FC5-8062-103AF05AD930}',{$ENDIF}100);
Triangles.init({$IFDEF DEBUGBUILD}'{EE569D51-8C1D-4AE3-A80F-BBBC565DA372}',{$ENDIF}100);
end;
destructor ZGLGeometry.done;
begin
Lines.done;
Points.done;
SHX.done;
Triangles.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPoint3DArray.initialization');{$ENDIF}
end.
