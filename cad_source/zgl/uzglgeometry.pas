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
                procedure DrawLine(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);virtual;
                procedure DrawLineWithoutLT(const p1,p2:GDBVertex);virtual;
                procedure DrawPolyLine(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed:GDBBoolean);virtual;
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
procedure ZGLGeometry.DrawPolyLine(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed:GDBBoolean);
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
                            DrawLine(ptv^,ptvprev^,vp);
      until ptv=nil;
      if closed then
                    DrawLine(ptvprev^,ptvfisrt^,vp);
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

procedure ZGLGeometry.DrawLine(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
var
    scale,length:GDBDouble;
    num,d,a:GDBDouble;
    outPatternPoint,addAllignVector,halfStrokeAllignVector,FactStartPoint:GDBVertex;
    dir:GDBvertex;
    i,j:integer;

    {ir,}ir2,ir3,ir4,ir5:itrec;
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    //firstloop,scissorstart:boolean;
    mrot,mentrot,madd,mtrans,mscale,objmatrix,matr:dmatrix4d;
    minx,miny,maxx,maxy:GDBDouble;
    TDInfo:TTrianglesDataInfo;
begin
     //Clear;
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
               //if d>eps then
               begin
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
                    (*if (SqrOneVertexlength(halfStrokeAllignVector))<(SqrOneVertexlength(addAllignVector)) then
                    begin
                       //if d>eps then
                       //             DrawLineWithoutLT(startpoint,outPatternPoint);
                       FactStartPoint:=outPatternPoint;
                       //FactStartPoint:=startpoint;
                    end
                    else
                       begin
                       FactStartPoint:=startpoint;
                       end;*)
                    FactStartPoint:=startpoint;

                    for i:=1 to trunc(num) do
                    begin
                                  TDI:=vp.LineType^.dasharray.beginiterate(ir2);
                                  PStroke:=vp.LineType^.strokesarray.beginiterate(ir3);
                                  PSP:=vp.LineType^.shapearray.beginiterate(ir4);
                                  PTP:=vp.LineType^.textarray.beginiterate(ir5);
                                  //laststrokewrited:=false;
                                  if PStroke<>nil then
                                  repeat
                                        case TDI^ of
                                                    TDIDash:begin
                                                                 if PStroke^<>0 then
                                                                 begin
                                                                      addAllignVector:=geometry.VertexMulOnSc(dir,(scale*abs(PStroke^))/length);
                                                                      addAllignVector:=geometry.VertexAdd(outPatternPoint,addAllignVector);
                                                                      if PStroke^>0 then
                                                                      begin
                                                                           DrawLineWithoutLT(FactStartPoint,addAllignVector);
                                                                      end;
                                                                      outPatternPoint:=addAllignVector;
                                                                      FactStartPoint:=addAllignVector;
                                                                 end
                                                                    else
                                                                        points.Add(@outPatternPoint);
                                                                 PStroke:=vp.LineType^.strokesarray.iterate(ir3);
                                                            end;
                                                    TDIShape:begin
                                                                  { TODO : убрать двойное преобразование номера символа }
                                                                 a:=Vertexangle(CreateVertex2D(startpoint.x,startpoint.y),CreateVertex2D(endpoint.x,endpoint.y));
                                                                 //a:=0;
                                                                 mrot:=CreateRotationMatrixZ(Sin(PSP^.param.Angle*pi/180{+a}), Cos(PSP^.param.Angle*pi/180{+a}));
                                                                 mentrot:=CreateRotationMatrixZ(Sin(a), Cos(a));
                                                                 madd:=geometry.CreateTranslationMatrix(createvertex(PSP^.param.x*scale,PSP^.param.y*scale,0));
                                                                 //mminusadd:=geometry.CreateTranslationMatrix(createvertex(-PSP^.param.x*scale,PSP^.param.y*scale,0));
                                                                 mtrans:=CreateTranslationMatrix(createvertex(outPatternPoint.x,outPatternPoint.y,outPatternPoint.z));
                                                                 mscale:=CreateScaleMatrix(geometry.createvertex(PSP^.param.Height*scale,PSP^.param.Height*scale,PSP^.param.Height*scale));
                                                                 objmatrix:=onematrix;
                                                                 objmatrix:=MatrixMultiply(objmatrix,mscale);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mrot);
                                                                 objmatrix:=MatrixMultiply(objmatrix,madd);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mentrot);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mtrans);
                                                                  matr     :=onematrix;
                                                                  minx:=0;
                                                                  miny:=0;
                                                                  maxx:=0;
                                                                  maxy:=0;
                                                                  PSP^.param.PStyle.pfont.CreateSymbol(shx,triangles,PSP.Psymbol.Number,objmatrix,matr,minx,miny,maxx,maxy,1);
                                                                  PSP:=vp.LineType^.shapearray.iterate(ir4);
                                                             end;
                                                    TDIText:begin
                                                                  { TODO : убрать двойное преобразование номера символа }
                                                                 a:=Vertexangle(CreateVertex2D(startpoint.x,startpoint.y),CreateVertex2D(endpoint.x,endpoint.y));
                                                                 //a:=0;
                                                                 mrot:=CreateRotationMatrixZ(Sin(PTP^.param.Angle*pi/180{+a}), Cos(PTP^.param.Angle*pi/180{+a}));
                                                                 mentrot:=CreateRotationMatrixZ(Sin(a), Cos(a));
                                                                 madd:=geometry.CreateTranslationMatrix(createvertex(PTP^.param.x*scale,PTP^.param.y*scale,0));
                                                                 //mminusadd:=geometry.CreateTranslationMatrix(createvertex(-PTP^.param.x*scale,PTP^.param.y*scale,0));
                                                                 mtrans:=CreateTranslationMatrix(createvertex(outPatternPoint.x,outPatternPoint.y,outPatternPoint.z));
                                                                 mscale:=CreateScaleMatrix(geometry.createvertex(PTP^.param.Height*scale,PTP^.param.Height*scale,PTP^.param.Height*scale));
                                                                 objmatrix:=onematrix;
                                                                 objmatrix:=MatrixMultiply(objmatrix,mscale);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mrot);
                                                                 objmatrix:=MatrixMultiply(objmatrix,madd);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mentrot);
                                                                 objmatrix:=MatrixMultiply(objmatrix,mtrans);
                                                                  matr     :=onematrix;
                                                                  for j:=1 to (system.length(PTP^.Text)) do
                                                                  begin
                                                                  PTP^.param.PStyle.pfont.CreateSymbol(shx,triangles,byte(PTP^.Text[j]),objmatrix,matr,minx,miny,maxx,maxy,1);
                                                                  matr[3, 0] := matr[3, 0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j]),tdinfo).NextSymX;

                                                                  end;
                                                                  PTP:=vp.LineType^.textarray.iterate(ir5);
                                                             end;
                                                    //pfont^.CreateSymbol(Vertex3D_in_WCS_Array,sym,objmatrix,matr,minx,miny,maxx,maxy,{pfont,}ln);
                                        end;
                                        TDI:=vp.LineType^.dasharray.iterate(ir2);
                                  until {PStroke}TDI=nil;

                    end;
               end
               {else
                   SetUnLTyped;}

          end;
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
