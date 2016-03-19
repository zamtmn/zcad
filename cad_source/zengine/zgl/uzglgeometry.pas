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
uses uzgldrawergeneral,math,gdbdrawcontext,uzgldrawerabstract,uzgvertex3sarray,
     UGDBOpenArrayOfData,UGDBPoint3DArray,{zcadsysvars,}geometry,gdbvisualprop,
     uzestyleslinetypes,sysutils,gdbase,memman,//log,
     gdbasetypes,strproc,ugdbfont,uzglvectorobject;
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
                                                 procedure draw(var rc:TDrawContext;length:GDBDouble;paint:boolean);
                                           end;
ZGLGeometry={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLVectorObject)
                procedure DrawGeometry(var rc:TDrawContext);virtual;
                procedure DrawNiceGeometry(var rc:TDrawContext);virtual;
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
                destructor done;virtual;
                procedure DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);virtual;
                procedure DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);virtual;
                procedure DrawLineWithoutLT(var rc:TDrawContext;const p1,p2:GDBVertex);virtual;
                procedure DrawPointWithoutLT(var rc:TDrawContext;const p:GDBVertex);virtual;
                {}
                procedure AddLine(var rc:TDrawContext;const p1,p2:GDBVertex);
                procedure AddPoint(var rc:TDrawContext;const p:GDBVertex);
                {Patterns func}
                procedure PlaceNPatterns(var rc:TDrawContext;var Segmentator:ZSegmentator;num:integer; const vp:PGDBLtypeProp;TangentScale,NormalScale,length:GDBDouble;SupressFirstDash:boolean=false);
                procedure PlaceOnePattern(var rc:TDrawContext;var Segmentator:ZSegmentator;const vp:PGDBLtypeProp;TangentScale,NormalScale,length,scale_div_length:GDBDouble;SupressFirstDash:boolean=false);
                procedure PlaceShape(drawer:TZGLAbstractDrawer;const StartPatternPoint:GDBVertex; PSP:PShapeProp;scale,angle:GDBDouble);
                procedure PlaceText(drawer:TZGLAbstractDrawer;const StartPatternPoint:GDBVertex;PTP:PTextProp;scale,angle:GDBDouble);

                procedure DrawTextContent(drawer:TZGLAbstractDrawer;content:gdbstring;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:GDBDouble;var Outbound:OutBound4V);
                //function CanSimplyDrawInOCS(const DC:TDrawContext;const SqrParamSize,TargetSize:GDBDouble):GDBBoolean;
             end;
{Export-}
var
    sysvarDWGRotateTextInLT:boolean=true;
    SysVarRDMaxLTPatternsInEntity:integer=1000;
function getsymbol_fromGDBText(s:gdbstring; i:integer;out l:integer;const fontunicode:gdbboolean):word;
implementation
{function ZGLGeometry.CanSimplyDrawInOCS(const DC:TDrawContext;const SqrParamSize,TargetSize:GDBDouble):GDBBoolean;
//false - не упрощать, true - упрощать. в GDBObjWithLocalCS.CanSimplyDrawInOCS наоборот
begin
     if dc.maxdetail then
                         exit(false);
     if GetSqrParamSizeInOCS(DC,SqrParamSize)>TargetSize then
                               result:=false
                           else
                               result:=true;
end;}

function getsymbol_fromGDBText(s:gdbstring; i:integer;out l:integer;const fontunicode:gdbboolean):word;
var
   ts:gdbstring;
   code:integer;
begin
     if length(s)>=i+6 then
     if s[i]='\' then
     if uppercase(s[i+1])='U' then
     if s[i+2]='+' then
     begin
          ts:='$'+copy(s,i+3,4);
          val(ts,result,code);
          if code=0 then
                        begin
                             l:=7;
                             exit;
                        end;
     end;

     if length(s)>=i+2 then
     if s[i]='%' then
     if s[i+1]='%' then
     begin
          l:=3;
          case (s[i+2]) of
            'D','d':begin
                     result:={35}176;
                     exit;
                end;
            'P','p':begin
                     result:={96}177;
                     exit;
                end;
            'C','c':begin
                     result:={143}8709;
                     exit;
                end;
            'U','u':begin
                     result:=1;
                     exit;
                end;
            '%':begin
                     result:=37;
                     exit;
                end;
            '0'..'9'
                :begin
                     while (s[i+l] in  ['0'..'9'])and(i+l<=length(s))and(l<5) do
                     inc(l);
                     ts:=copy(s,i+2,l-2);
                     val(ts,result,code);
                     if code=0 then
                     begin
                          //inc(l);
                          exit;
                     end;
                 end;

          end;    ;
     end;

     if length(s)>=i+1 then
     if s[i]='\' then
     begin
          l:=2;
          case (s[i+1]) of
            'L','l':begin
                     result:=1;
                     exit;
                end;

          end;
     end;

     l:=1;
     if fontunicode then
                        result:=ach2uch(ord(s[i]))
                    else
                        result:=ord(s[i]);
end;

procedure ZGLGeometry.DrawTextContent(drawer:TZGLAbstractDrawer;content:gdbstring;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:GDBDouble;var Outbound:OutBound4V);
var
  i: GDBInteger;
  matr,m1: DMatrix4D;

  Bound:TBoundingRect;

  plp,plp2:pgdbvertex;
  lp:gdbvertex;
  pl:GDBPoint3DArray;
  ispl:gdbboolean;
  ir:itrec;
  pfont:pgdbfont;
  LLSymbolLineIndex:TArrayIndex;
  symlen:GDBInteger;
  sym:word;
  //-ttf-//TDInfo:TTrianglesDataInfo;
begin
  LLSymbolLineIndex:=-1;
  pfont:=_pfont;

  ispl:=false;
  pl.init({$IFDEF DEBUGBUILD}'{AC324582-5E55-4290-8017-44B8C675198A}',{$ENDIF}10);

  Bound.LB.x:=+infinity;
  Bound.LB.y:=+infinity;
  Bound.RT.x:=NegInfinity;
  Bound.RT.y:=NegInfinity;//-infinity;

  matr:=matrixmultiply(DrawMatrix,objmatrix);
  matr:=DrawMatrix;

  i := 1;
  while i <= length(content) do
  begin
    sym:=getsymbol_fromGDBText(content,i,symlen,pgdbfont(pfont)^.font.unicode);
    if sym=1 then
    begin
         ispl:=not(ispl);
         if ispl then begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end
                   else begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end;
    end
    else
    begin
      pfont^.CreateSymbol(drawer,self,sym,objmatrix,matr,Bound,LLSymbolLineIndex);

    end;
    if sym<>1 then
    begin
      m1:=onematrix;
      m1[3, 0] := pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch}{(ord(content[i]))}sym{//-ttf-//,tdinfo}).NextSymX;
      matr:=MatrixMultiply(m1,matr);
    end;
  inc(i,symlen);
  end;
                       if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                     end;

       if Bound.LB.x=+infinity then Bound.LB.x:=0;
       if Bound.LB.y=+infinity then Bound.LB.y:=0;
       if Bound.RT.x=NegInfinity then Bound.RT.x:=1;
       if Bound.RT.y=NegInfinity then Bound.RT.y:=1;

  outbound[0].x:=Bound.LB.x;
  outbound[0].y:=Bound.RT.y;
  outbound[0].z:=0;
  outbound[0]:=VectorTransform3D(outbound[0],objMatrix);
  outbound[1].x:=Bound.RT.x;
  outbound[1].y:=Bound.RT.y;
  outbound[1].z:=0;
  outbound[1]:=VectorTransform3D(outbound[1],objMatrix);
  outbound[2].x:=Bound.RT.x;
  outbound[2].y:=Bound.LB.y;
  outbound[2].z:=0;
  outbound[2]:=VectorTransform3D(outbound[2],objMatrix);
  outbound[3].x:=Bound.LB.x;
  outbound[3].y:=Bound.LB.y;
  outbound[3].z:=0;
  outbound[3]:=VectorTransform3D(outbound[3],objMatrix);

  plp:=pl.beginiterate(ir);
  plp2:=pl.iterate(ir);
  if plp2<>nil then
  repeat
        Drawer.GetLLPrimitivesCreator.CreateLLLine(LLprimitives,GeomData.Vertex3S.AddGDBVertex(plp^));
        GeomData.Vertex3S.AddGDBVertex(plp2^);

        plp:=pl.iterate(ir);
        plp2:=pl.iterate(ir);
  until plp2=nil;

  pl.done;
  Shrink;
end;

procedure ZGLGeometry.AddPoint(var rc:TDrawContext;const p:GDBVertex);
var
    tv:GDBVertex3S;
begin
     tv:=VertexD2S(p);
     if rc.drawer<>nil then
     rc.drawer.GetLLPrimitivesCreator.CreateLLPoint(LLprimitives,GeomData.Vertex3S.Add(@tv));
end;

procedure ZGLGeometry.AddLine(var rc:TDrawContext;const p1,p2:GDBVertex);
var
    tv1,tv2:GDBVertex3S;
begin
     tv1:=VertexD2S(p1);
     tv2:=VertexD2S(p2);
     if rc.drawer<>nil then
                           rc.drawer.GetLLPrimitivesCreator.CreateLLLine(LLprimitives,GeomData.Vertex3S.Add(@tv1));
                       {else
                           DefaultLLPCreator.CreateLLLine(LLprimitives,GeomData.Vertex3S.Add(@tv1));}
     GeomData.Vertex3S.Add(@tv2);

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
procedure ZGLGeometry.DrawLineWithoutLT(var rc:TDrawContext;const p1,p2:GDBVertex);
{var
   d,a:GDBDouble;
   tv:GDBVertex;
   i:integer;}
begin
     self.AddLine(rc,p1,p2);
end;
procedure ZGLGeometry.DrawPointWithoutLT(var rc:TDrawContext;const p:GDBVertex);
begin
     AddPoint(rc,p);
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

    if sysvarDWGRotateTextInLT then
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
procedure ZGLGeometry.PlaceShape(drawer:TZGLAbstractDrawer;const StartPatternPoint:GDBVertex;PSP:PShapeProp;scale,angle:GDBDouble);
var
    objmatrix,matr:dmatrix4d;
    Bound:TBoundingRect;
    sli:integer;
begin
{ TODO : убрать двойное преобразование номера символа }
objmatrix:=creatematrix(StartPatternPoint,PSP^.param,angle,scale);
matr:=onematrix;
Bound.LB:=NulVertex2D;
Bound.RT:=NulVertex2D;
sli:=-1;
if PSP.Psymbol<> nil then
                    PSP^.param.PStyle.pfont.CreateSymbol(drawer,self,PSP.Psymbol.Number,objmatrix,matr,Bound,sli);
end;
procedure ZGLGeometry.PlaceText(drawer:TZGLAbstractDrawer;const StartPatternPoint:GDBVertex;PTP:PTextProp;scale,angle:GDBDouble);
var
    objmatrix,matr:dmatrix4d;
    Bound:TBoundingRect;
    j:integer;
    //-ttf-//TDInfo:TTrianglesDataInfo;
    sym:integer;
    sli:integer;
begin
{ TODO : убрать двойное преобразование номера символа }
objmatrix:={creatematrix}CreateReadableMatrix(StartPatternPoint,PTP^.param,angle,scale,PTP.txtL,PTP.txtH);
matr:=onematrix;
Bound.LB:=NulVertex2D;
Bound.RT:=NulVertex2D;
sli:=-1;
for j:=1 to (system.length(PTP^.Text)) do
begin
     sym:=byte(PTP^.Text[j]);
          if ptp.param.PStyle.pfont.font.unicode then
                                                     sym:=ach2uch(sym);
PTP^.param.PStyle.pfont.CreateSymbol(drawer,self,sym,objmatrix,matr,Bound,sli);
matr[3,0]:=matr[3,0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j]){//-ttf-//,tdinfo}).NextSymX;
end;
end;
procedure ZGLGeometry.PlaceOnePattern(var rc:TDrawContext;var Segmentator:ZSegmentator;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     const vp:PGDBLtypeProp;                 //стиль и прочая лабуда
                                     TangentScale,NormalScale,length,scale_div_length:GDBDouble;//направление, масштаб, длинна
                                     SupressFirstDash:boolean=false);
var
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    ir2,ir3,ir4,ir5:itrec;
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
                                            Segmentator.draw(rc,abs(PStroke^)*scale_div_length,true)
                                        else
                                            Segmentator.draw(rc,abs(PStroke^)*scale_div_length,false);
                     end
                        else
                            if not SupressFirstDash then
                              DrawPointWithoutLT(rc,Segmentator.cp);
                     //self.DrawLineWithoutLT(nulvertex,Segmentator.cp);
                     PStroke:=vp.strokesarray.iterate(ir3);
                end;
       TDIShape:begin
                     PlaceShape(rc.drawer,Segmentator.cp,PSP,NormalScale,Segmentator.angle);
                     PSP:=vp.shapearray.iterate(ir4);
                end;
        TDIText:begin
                     PlaceText(rc.drawer,Segmentator.cp,PTP,NormalScale,Segmentator.angle);
                     PTP:=vp.textarray.iterate(ir5);
                 end;
          end;
    SupressFirstDash:=false;;
          TDI:=vp.dasharray.iterate(ir2);
    until TDI=nil;
end;
end;

procedure ZGLGeometry.PlaceNPatterns(var rc:TDrawContext;var Segmentator:ZSegmentator;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     num:integer; //кол-во паттернов
                                     const vp:PGDBLtypeProp;                 //стиль и прочая лабуда
                                     TangentScale,NormalScale,length:GDBDouble;//направление, масштаб, длинна
                                     SupressFirstDash:boolean=false);          //подавить пкрвый штрих (пока используется в случае если он точка)
var i:integer;
    scale_div_length:GDBDouble;
begin
  if num<1 then exit;
  scale_div_length:=TangentScale/length;
  PlaceOnePattern(rc,Segmentator,vp,TangentScale,NormalScale,length,scale_div_length,SupressFirstDash);//рисуем один паттерн
  for i:=1 to num-1 do
  PlaceOnePattern(rc,Segmentator,vp,TangentScale,NormalScale,length,scale_div_length);//рисуем один паттерн
end;
procedure ZSegmentator.draw(var rc:TDrawContext;length:GDBDouble;paint:boolean);
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
                                                            self.PGeom.DrawLineWithoutLT(rc,oldcp,cp);
                                               cdp:=tcdp;
                                          end
                                      else
                                          begin
                                               if paint then
                                                            self.PGeom.DrawLineWithoutLT(rc,cp,pcurrsegment^.endpoint);
                                               length:=tcdp-pcurrsegment^.naccumlength;
                                               self.nextsegment;
                                               draw(rc,length,paint);
                                               //tcdp:=cdp;
                                          end;
     end
     else
         cdp:=tcdp;
     end;
end;
procedure ZGLGeometry.DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);
var
    ptv,ptvprev,ptvfisrt: pgdbvertex;
    ir:itrec;
    TangentScale,NormalScale,polylength,TrueNumberOfPatterns,normalizedD,d,halfStroke,dend:GDBDouble;
    Segmentator:ZSegmentator;
    lt:PGDBLtypeProp;
    PStroke:PGDBDouble;
    ir3:itrec;
    minPatternsCount,NumberOfPatterns:integer;
    supressfirstdash:boolean;
procedure SetPolyUnLTyped;
begin
      ptv:=Points.beginiterate(ir);
      ptvfisrt:=ptv;
      if ptv<>nil then
      repeat
            ptvprev:=ptv;
            ptv:=Points.iterate(ir);
            if ptv<>nil then
                            DrawLineWithoutLT(rc,ptv^,ptvprev^);
      until ptv=nil;
      if closed then
                    DrawLineWithoutLT(rc,ptvprev^,ptvfisrt^);
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
           TangentScale:={SysVar.dwg.DWG_LTScale^}rc.DrawingContext.GlobalLTScale*vp.LineTypeScale;
           NormalScale:=TangentScale;
           TrueNumberOfPatterns:=polylength/(TangentScale*LT.len);
           if ltgen and closed then
                        begin
                        minPatternsCount:=2;
                        NumberOfPatterns:=round(TrueNumberOfPatterns);
                        if NumberOfPatterns=0 then
                                                  TangentScale:=NormalScale
                                              else
                                                  TangentScale:=polyLength/(NumberOfPatterns*LT.len);
                        end
                    else
                        begin
                        minPatternsCount:=1;
                        NumberOfPatterns:=trunc(TrueNumberOfPatterns);
                        end;
           if ((NumberOfPatterns<minPatternsCount)and(not LT^.WithoutLines))or(NumberOfPatterns>SysVarRDMaxLTPatternsInEntity) then
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
                    //Segmentator.draw(rc,normalizedD-halfStroke,true);
                    supressfirstdash:=false;
                    dend:=normalizedD-halfStroke;
                    if dend>eps then
                    case LT.FirstStroke of
                                 TODILine:Segmentator.draw(rc,dend,true);
                                TODIPoint:
                                          begin
                                               DrawPointWithoutLT(rc,Segmentator.cp);
                                               Segmentator.draw(rc,dend,false);
                                               supressfirstdash:=true;
                                          end;
                    end;
                    end;


                    PlaceNPatterns(rc,Segmentator,NumberOfPatterns,LT,TangentScale,NormalScale,polylength,supressfirstdash);//рисуем TrueNumberOfPatterns паттернов
                    dend:=1-Segmentator.cdp;
                    if (dend>eps) or (LT.WithoutLines) then
                                    begin
                                    //Segmentator.draw(rc,dend,true);
                                    //дорисовываем окончание если надо
                                    case LT.FirstStroke of
                                                 TODILine:Segmentator.draw(rc,dend,true);
                                                TODIPoint:
                                                          begin
                                                               Segmentator.draw(rc,dend,false);
                                                               DrawPointWithoutLT(rc,Segmentator.cp);
                                                          end;
                                    end;
                                    end;
               end;
           Segmentator.done;
       end;
  end;
  Shrink;
end;

procedure ZGLGeometry.DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
var
    scale,length:GDBDouble;
    num,normalizedD,D,halfStroke,dend:GDBDouble;
    ir3:itrec;
    PStroke:PGDBDouble;
    lt:PGDBLtypeProp;
    Segmentator:ZSegmentator;
    supressfirstdash:boolean;
begin
     LT:=getLTfromVP(vp);
     if (LT=nil) or (LT.dasharray.Count=0) then
     begin
          DrawLineWithoutLT(rc,startpoint,endpoint);
     end
     else
     begin
          //LT:=getLTfromVP(vp);
          length := Vertexlength(startpoint,endpoint);//длина линии
          scale:={SysVar.dwg.DWG_LTScale^}rc.DrawingContext.GlobalLTScale*vp.LineTypeScale;//фактический масштаб линии
          num:=Length/(scale*LT.len);//количество повторений шаблона
          if ((num<1)and(not LT^.WithoutLines))or(num>SysVarRDMaxLTPatternsInEntity) then
                                     DrawLineWithoutLT(rc,startpoint,endpoint) //не рисуем шаблон при большом количестве повторений
          else
          begin
               Segmentator.InitFromLine(startpoint,endpoint,length,@self);//длина линии
               Segmentator.startdraw;
               D:=(Length-(scale*LT.len)*trunc(num))/2; //длинна добавки для выравнивания
               normalizedD:=D/Length;

               PStroke:=LT^.strokesarray.beginiterate(ir3);//первый штрих
               halfStroke:=(scale*abs(PStroke^/2))/length;//первый штрих
               supressfirstdash:=false;
               dend:=normalizedD-halfStroke;
               if dend>eps then
               case LT.FirstStroke of
                            TODILine:Segmentator.draw(rc,dend,true);
                           TODIPoint:
                                     begin
                                          DrawPointWithoutLT(rc,Segmentator.cp);
                                          Segmentator.draw(rc,dend,false);
                                          supressfirstdash:=true;
                                     end;
               end;
               PlaceNPatterns(rc,Segmentator,trunc(num),LT,scale,scale,length,supressfirstdash);//рисуем num паттернов
               dend:=1-Segmentator.cdp;
               if dend>eps then
                               begin
                                    //Segmentator.draw(rc,dend,true);
                                    //дорисовываем окончание если надо
                                    case LT.FirstStroke of
                                                 TODILine:Segmentator.draw(rc,dend,true);
                                                TODIPoint:
                                                          begin
                                                               //Segmentator.draw(rc,dend,false);
                                                               DrawPointWithoutLT(rc,{Segmentator.cp}endpoint);
                                                          end;
                                    end;
                               end;
               Segmentator.done;
         end;
     end;
     Shrink;
end;

procedure ZGLGeometry.drawgeometry;
begin
  //rc.drawer.PVertexBuffer:=@GeomData.Vertex3S;
  DrawLLPrimitives(rc,rc.drawer);
end;
procedure ZGLGeometry.drawNicegeometry;
begin
  //rc.drawer.PVertexBuffer:=@GeomData.Vertex3S;
  DrawLLPrimitives(rc,rc.drawer);
end;
constructor ZGLGeometry.init;
begin
  inherited;
end;
destructor ZGLGeometry.done;
begin
  inherited;
end;
begin
end.

