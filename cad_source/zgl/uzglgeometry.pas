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
uses geometry,gdbvisualprop,UGDBPolyPoint3DArray,uzglline3darray,uzglpoint3darray,ugdbltypearray,UGDBSHXFont,sysutils,gdbase,memman,log,
     gdbasetypes;
type
{Export+}
ZGLGeometry=object(GDBaseObject)
                                 Lines:ZGLLine3DArray;
                                 Points:ZGLpoint3DArray;
                                 SHX:GDBPolyPoint3DArray;
                procedure DrawGeometry;virtual;
                 procedure DrawNiceGeometry;virtual;
                procedure Clear;virtual;
                constructor init;
                destructor done;virtual;
                procedure DrawLine(const p1,p2:GDBVertex; const vp:GDBObjVisualProp);virtual;
             end;
{Export-}
implementation
procedure ZGLGeometry.DrawLine(const p1,p2:GDBVertex; const vp:GDBObjVisualProp);
var
    scale,length:GDBDouble;
    num,d,a:GDBDouble;
    tv,tv2,tv3:GDBVertex;
    dir:GDBvertex;
    i,j:integer;

    ir,ir2,ir3,ir4,ir5:itrec;
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    firstloop,scissorstart:boolean;
    mrot,mentrot,mminusrot,madd,mminusadd,mtrans,mscale,objmatrix,matr:dmatrix4d;
    minx,miny,maxx,maxy:GDBDouble;
    //lp,tv:gdbvertex;
    //i:integer;

procedure SetUnLTyped;
begin
  lines.Add(@p1);
  lines.Add(@p2);
end;
begin
     //Clear;
     if (vp.LineType=nil) or (vp.LineType.dasharray.Count=0) then
     begin
          SetUnLTyped;
     end
     else
     begin
          length := Vertexlength(p1,p2);

          dir:=geometry.VertexSub(p2,p1);
          dir.x:=p2.x-p1.x;
          dir.y:=p2.y-p1.y;
          dir.z:=p2.z-p1.z;

          scale:=1*vp.LineTypeScale;
          num:=Length/(scale*vp.LineType.len);
          if num<1 then
                       SetUnLTyped
          else
          begin
               d:=(Length-(scale*vp.LineType.len)*trunc(num))/2;
               if d>eps then
               begin
                    d:=d/Length;
                    tv2:=VertexMulOnSc(dir,d);
                    tv:=VertexSub(p2,tv2);

                    PStroke:=vp.LineType^.strokesarray.beginiterate(ir3);
                    tv3:=VertexMulOnSc(dir,(scale*abs(PStroke^/2))/length);
                    tv:=VertexSub(tv,tv3);

                    lines.Add(@tv);
                    lines.Add(@p2);

                    tv:=VertexAdd(p1,tv2);

                    PStroke:=vp.LineType^.strokesarray.beginiterate(ir3);
                    tv3:=geometry.VertexMulOnSc(dir,(scale*abs(PStroke^/2))/length);
                    tv:=geometry.VertexSub(tv,tv3);
                    if (SqrOneVertexlength(tv3))<(SqrOneVertexlength(tv2)) then
                    begin
                       scissorstart:=false;
                       lines.Add(@p1);
                       lines.Add(@tv);
                    end
                    else
                       scissorstart:=true;
                    firstloop:=true;

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
                                                                      tv2:=geometry.VertexMulOnSc(dir,(scale*abs(PStroke^))/length);
                                                                      tv2:=geometry.VertexAdd(tv,tv2);
                                                                      if PStroke^>0 then
                                                                      begin
                                                                           if scissorstart and firstloop then
                                                                               lines.Add(@p1)
                                                                           else
                                                                               lines.Add(@tv);

                                                                      lines.Add(@tv2);
                                                                      end;
                                                                      tv:=tv2;
                                                                      firstloop:=false;
                                                                 end
                                                                    else
                                                                        points.Add(@tv);
                                                                 PStroke:=vp.LineType^.strokesarray.iterate(ir3);
                                                                 //laststrokewrited:=true;
                                                            end;
                                                    TDIShape:begin
                                                                  { TODO : убрать двойное преобразование номера символа }
                                                                 a:=Vertexangle(CreateVertex2D(p1.x,p1.y),CreateVertex2D(p2.x,p2.y));
                                                                 //a:=0;
                                                                 mrot:=CreateRotationMatrixZ(Sin(PSP^.param.Angle*pi/180{+a}), Cos(PSP^.param.Angle*pi/180{+a}));
                                                                 mentrot:=CreateRotationMatrixZ(Sin(a), Cos(a));
                                                                 madd:=geometry.CreateTranslationMatrix(createvertex(PSP^.param.x*scale,PSP^.param.y*scale,0));
                                                                 mminusadd:=geometry.CreateTranslationMatrix(createvertex(-PSP^.param.x*scale,PSP^.param.y*scale,0));
                                                                 mtrans:=CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
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
                                                                  PSP^.param.PStyle.pfont.CreateSymbol(shx,PSP.Psymbol.Number,objmatrix,matr,minx,miny,maxx,maxy,1);
                                                                  PSP:=vp.LineType^.shapearray.iterate(ir4);
                                                             end;
                                                    TDIText:begin
                                                                  { TODO : убрать двойное преобразование номера символа }
                                                                 a:=Vertexangle(CreateVertex2D(p1.x,p1.y),CreateVertex2D(p2.x,p2.y));
                                                                 //a:=0;
                                                                 mrot:=CreateRotationMatrixZ(Sin(PTP^.param.Angle*pi/180{+a}), Cos(PTP^.param.Angle*pi/180{+a}));
                                                                 mentrot:=CreateRotationMatrixZ(Sin(a), Cos(a));
                                                                 madd:=geometry.CreateTranslationMatrix(createvertex(PTP^.param.x*scale,PTP^.param.y*scale,0));
                                                                 mminusadd:=geometry.CreateTranslationMatrix(createvertex(-PTP^.param.x*scale,PTP^.param.y*scale,0));
                                                                 mtrans:=CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
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
                                                                  PTP^.param.PStyle.pfont.CreateSymbol(shx,byte(PTP^.Text[j]),objmatrix,matr,minx,miny,maxx,maxy,1);
                                                                  matr[3, 0] := matr[3, 0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j])).NextSymX;

                                                                  end;
                                                                  PTP:=vp.LineType^.textarray.iterate(ir5);
                                                             end;
                                                    //pfont^.CreateSymbol(Vertex3D_in_WCS_Array,sym,objmatrix,matr,minx,miny,maxx,maxy,{pfont,}ln);
                                        end;
                                        TDI:=vp.LineType^.dasharray.iterate(ir2);
                                  until {PStroke}TDI=nil;

                    end;
               end
               else
                   SetUnLTyped;

          end;
     end;
end;

procedure ZGLGeometry.drawgeometry;
begin
  Lines.DrawGeometry;
  Points.DrawGeometry;
  //shx.DrawNiceGeometry;
  shx.DrawGeometry;
end;
procedure ZGLGeometry.drawNicegeometry;
begin
  Lines.DrawGeometry;
  Points.DrawGeometry;
  shx.DrawNiceGeometry;
end;
procedure ZGLGeometry.Clear;
begin
  Lines.Clear;
  Points.Clear;
  SHX.Clear;
end;
constructor ZGLGeometry.init;
begin
Lines.init(100);
Points.init(100);
SHX.init(100);
end;
destructor ZGLGeometry.done;
begin
Lines.init(100);
Points.init(100);
SHX.init(100);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPoint3DArray.initialization');{$ENDIF}
end.

