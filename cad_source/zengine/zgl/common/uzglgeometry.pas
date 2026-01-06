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

unit uzglgeometry;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzgldrawergeneral,math,uzgldrawcontext,uzgldrawerabstract,uzgvertex3sarray,
     uzegeometrytypes,gzctnrVector,UGDBPoint3DArray,uzegeometry,uzeentitiesprop,
     gzctnrVectorTypes,uzestyleslinetypes,sysutils,uzbtypes,uzeTypes,
     uzbstrproc,uzefont,uzglvectorobject,uzgprimitivessarray,uzgprimitives;
type
{Export+}
  PZGLGraphix=^ZGLGraphix;
  PZPolySegmentData=^ZPolySegmentData;
  {REGISTERRECORDTYPE ZPolySegmentData}
  ZPolySegmentData= record
    startpoint,endpoint,dir:TzePoint3d;
    length,nlength,naccumlength,accumlength:Double;
  end;
  {REGISTEROBJECTTYPE ZSegmentator}
  ZSegmentator=object(GZVector{-}<ZPolySegmentData>{//})
    dir,cp:TzePoint3d;
    cdp,angle:Double;
    pcurrsegment:PZPolySegmentData;
    ir:itrec;
    PGeom:PZGLGraphix;
    constructor InitFromLine(const startpoint,endpoint:TzePoint3d;out length:Double;PG:PZGLGraphix);
    constructor InitFromPolyline(const points:GDBPoint3dArray;out length:Double;const closed:Boolean;PG:PZGLGraphix);
    procedure startdraw;
    procedure nextsegment;
    procedure normalize(l:Double);
    procedure draw(var rc:TDrawContext;length:Double;paint:boolean;var dr:TLLDrawResult);
  end;
  {REGISTEROBJECTTYPE ZGLGraphix}
  ZGLGraphix= object(ZGLVectorObject)
    procedure DrawGeometry(var DC:TDrawContext;const inFrustumState:TInBoundingVolume;simplydraw:boolean);virtual;
    constructor init();
    destructor done;virtual;
    function DrawLineWithLT(var DC:TDrawContext;const startpoint,endpoint:TzePoint3d; const vp:GDBObjVisualProp;OnlyOne:Boolean=False):TLLDrawResult;virtual;
    function DrawPolyLineWithLT(var DC:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean):TLLDrawResult;virtual;


    procedure DrawPolyLineWithoutLT(var DC:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp;const closed:Boolean;var dr:TLLDrawResult);virtual;
    procedure DrawLineWithoutLT(var DC:TDrawContext;const p1,p2:TzePoint3d;var dr:TLLDrawResult;OnlyOne:Boolean=False);virtual;
    procedure DrawPointWithoutLT(var DC:TDrawContext;const p:TzePoint3d;var dr:TLLDrawResult);virtual;
    {}
    procedure AddPolyLine(var DC:TDrawContext;const closed:boolean;const pts:array of TzePoint3d);
    procedure AddLine(var DC:TDrawContext;const p1,p2:TzePoint3d;OnlyOne:Boolean=False);
    procedure AddPoint(var DC:TDrawContext;const p:TzePoint3d);
    {Patterns func}
    procedure PlaceNPatterns(var DC:TDrawContext;var Segmentator:ZSegmentator;const pli:TArrayIndex;num:integer; const vp:PGDBLtypeProp;TangentScale,NormalScale,length:Double;var dr:TLLDrawResult;SupressFirstDash:boolean=false);
    procedure PlaceOnePattern(var DC:TDrawContext;var Segmentator:ZSegmentator;const vp:PGDBLtypeProp;TangentScale,NormalScale,length,scale_div_length:Double;var dr:TLLDrawResult;SupressFirstDash:boolean=false);
    procedure PlaceShape(drawer:TZGLAbstractDrawer;const StartPatternPoint:TzePoint3d; PSP:PShapeProp;scale,angle:Double);
    procedure PlaceText(drawer:TZGLAbstractDrawer;const StartPatternPoint:TzePoint3d;PTP:PTextProp;scale,angle:Double);

    procedure DrawTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;_pfont: PGDBfont;const DrawMatrix,objmatrix:TzeTypedMatrix4d;const textprop_size:Double;var Outbound:OutBound4V);
    //function CanSimplyDrawInOCS(const DC:TDrawContext;const SqrParamSize,TargetSize:Double):Boolean;
  end;
{Export-}
var
  sysvarDWGRotateTextInLT:boolean=true;
  SysVarRDMaxLTPatternsInEntity:integer=1000;
function getsymbol_fromGDBText(const s:TDXFEntsInternalStringType; i:integer;out l:integer;const fontunicode:Boolean):word;
implementation
{function ZGLGraphix.CanSimplyDrawInOCS(const DC:TDrawContext;const SqrParamSize,TargetSize:Double):Boolean;
//false - не упрощать, true - упрощать. в GDBObjWithLocalCS.CanSimplyDrawInOCS наоборот
begin
     if dc.maxdetail then
                         exit(false);
     if GetSqrParamSizeInOCS(DC,SqrParamSize)>TargetSize then
                               result:=false
                           else
                               result:=true;
end;}

function getsymbol_fromGDBText(const s:TDXFEntsInternalStringType; i:integer;out l:integer;const fontunicode:Boolean):word;
var
   ts:TDXFEntsInternalStringType;
   code:integer;
begin
     if length(s)>=i+6 then
     if s[i]='\' then
     if s[i+1] in ['U','u'] then
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


     {
     this move to uzctextpreprocessorimpl.EscapeSeq
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
     end;}

     l:=1;
     if fontunicode then
                        result:={ach2uch}(ord(s[i]))
                    else
                        result:=uch2ach(ord(s[i]));
end;

procedure ZGLGraphix.DrawTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;_pfont: PGDBfont;const DrawMatrix,objmatrix:TzeTypedMatrix4d;const textprop_size:Double;var Outbound:OutBound4V);
var
  i: Integer;
  matr,m1: TzeTypedMatrix4d;

  Bound:TBoundingRect;

  plp,plp2:PzePoint3d;
  lp:TzePoint3d;
  pl:GDBPoint3DArray;
  ispl:Boolean;
  ir:itrec;
  pfont:pgdbfont;
  LLSymbolLineIndex:TArrayIndex;
  symlen:Integer;
  sym:word;
  //-ttf-//TDInfo:TTrianglesDataInfo;
begin
  LLSymbolLineIndex:=-1;
  pfont:=_pfont;

  ispl:=false;
  pl.init(10);

  Bound.LB.x:=+infinity;
  Bound.LB.y:=+infinity;
  Bound.RT.x:=NegInfinity;
  Bound.RT.y:=NegInfinity;//-infinity;

  //matr:=matrixmultiply(DrawMatrix,objmatrix);
  matr:=DrawMatrix;

  i := 1;
  while i <= length(content) do
  begin
    sym:=getsymbol_fromGDBText(content,i,symlen,pgdbfont(pfont)^.font.IsUnicode);
    if sym=1 then
    begin
         ispl:=not(ispl);
         if ispl then begin
                             lp:=PzePoint3d(@matr.mtr.v[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
                        end
                   else begin
                             lp:=PzePoint3d(@matr.mtr.v[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
                        end;
    end
    else
    begin
      pfont^.CreateSymbol(drawer,textprop_size,self,sym,objmatrix,matr,Bound,LLSymbolLineIndex);

    end;
    if sym<>1 then
    begin
      m1.CreateRec(OneMtr,CMTTranslate);
      m1.mtr.v[3].v[0] := pgdbfont(pfont)^.GetOrReplaceSymbolInfo({ach2uch}{(ord(content[i]))}sym{//-ttf-//,tdinfo}).NextSymX;
      matr:=MatrixMultiply(m1,matr);
    end;
  inc(i,symlen);
  end;
                       if ispl then

                     begin
                             lp:=PzePoint3d(@matr.mtr.v[3].v[0])^;
                             lp.y:=lp.y-0.2*textprop_size;
                             lp.x:=lp.x-0.1*textprop_size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.PushBackData(lp);
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

procedure ZGLGraphix.AddPoint(var DC:TDrawContext;const p:TzePoint3d);
begin
  if DC.drawer<>nil then
    DC.drawer.GetLLPrimitivesCreator.CreateLLPoint(LLprimitives,GeomData.Vertex3S.AddGDBVertex{PushBackData}({tv}p));
end;

procedure ZGLGraphix.AddLine(var DC:TDrawContext;const p1,p2:TzePoint3d;OnlyOne:Boolean=False);
begin
  if OnlyOne then
    GeomData.Vertex3S.SetSize(GeomData.Vertex3S.GetCount+2);
  if DC.drawer<>nil then
    DC.drawer.GetLLPrimitivesCreator.CreateLLLine(LLprimitives,GeomData.Vertex3S.AddGDBVertex(p1),OnlyOne);
  GeomData.Vertex3S.AddGDBVertex(p2);
end;

procedure ZGLGraphix.AddPolyLine(var DC:TDrawContext;const closed:boolean;const pts:array of TzePoint3d);
var
  i:integer;
begin
  if DC.drawer<>nil then
    DC.drawer.GetLLPrimitivesCreator.CreateLLPolyLine(LLprimitives,GeomData.Vertex3S.Count,Length(pts),closed);
  for i:=low(pts)to High(pts) do
    GeomData.Vertex3S.AddGDBVertex(pts[i]);
end;

function CalcSegment(const startpoint,endpoint:TzePoint3d;out segment:ZPolySegmentData;prevlength:Double):Double;
begin
     segment.startpoint:=startpoint;
     segment.endpoint:=endpoint;
     segment.dir:=VertexSub(endpoint,startpoint);
     segment.length:=Vertexlength(startpoint,endpoint);
     segment.accumlength:=prevlength+segment.length;
     segment.naccumlength:=segment.accumlength;
     result:=segment.accumlength;
end;
constructor ZSegmentator.InitFromLine(const startpoint,endpoint:TzePoint3d;out length:Double;PG:PZGLGraphix);
var
   segment:ZPolySegmentData;
begin
     inherited init(1);
     length:=CalcSegment(startpoint,endpoint,segment,0);
     PushBackData(segment);
     normalize(length);
     PGeom:=pg;
end;
{function getlength(const points:GDBPoint3dArray;var sd:GDBOpenArrayOfData; const closed:Boolean):Double;
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
constructor ZSegmentator.InitFromPolyline(const points:GDBPoint3dArray;out length:Double;const closed:Boolean;PG:PZGLGraphix);
var
   segment:ZPolySegmentData;
   ptv,ptvprev,pfirstv: PzePoint3d;
   _ir:itrec;
begin
     if closed then
                   inherited init(points.Count)
               else
                   inherited init(points.Count+1);
    length:=0;
    ptvprev:=points.beginiterate(_ir);
    pfirstv:=ptvprev;
    ptv:=points.iterate(_ir);
    if ptv<>nil then
    repeat
          length:=CalcSegment(ptvprev^,ptv^,segment,length);
          PushBackData(segment);

          ptvprev:=ptv;
          ptv:=points.iterate(_ir);
    until ptv=nil;
    if closed then
                  begin
                       length:=CalcSegment(ptvprev^,pfirstv^,segment,length);
                       PushBackData(segment);
                  end;
    normalize(length);
    PGeom:=pg;
end;

procedure ZSegmentator.normalize(l:Double);
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
     end;
//     else
//         pcurrsegment:=pcurrsegment;
end;
procedure ZSegmentator.startdraw;
begin
     pcurrsegment:=beginiterate(ir);
     dir:=pcurrsegment^.dir;
     angle:=Vertexangle(CreateVertex2D(0,0),CreateVertex2D(dir.x,dir.y));
     cdp:=0;
     cp:=pcurrsegment^.startpoint;
end;
procedure ZGLGraphix.DrawLineWithoutLT(var DC:TDrawContext;const p1,p2:TzePoint3d;var dr:TLLDrawResult;OnlyOne:Boolean=False);
begin
  if dr.LLPCount=0 then
    dr.BB:=CreateBBFrom2Point(p1,p2)
  else begin
      concatBBandPoint(dr.BB,p1);
      concatBBandPoint(dr.BB,p2);
  end;
  inc(dr.LLPCount);
  self.AddLine(DC,p1,p2,OnlyOne);
end;
procedure ZGLGraphix.DrawPolyLineWithoutLT(var DC:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp;const closed:Boolean;var dr:TLLDrawResult);
var
  i:integer;
begin
  if dr.LLPCount=0 then begin
    dr.BB:=CreateBBFrom2Point(points.getDataMutable(0)^,points.getDataMutable(1)^);
    for i:=2 to points.Count-1 do
      concatBBandPoint(dr.BB,points.getDataMutable(i)^);
  end else
    for i:=0 to points.Count-1 do
      concatBBandPoint(dr.BB,points.getDataMutable(i)^);
  inc(dr.LLPCount);
  AddPolyLine(DC,closed,GDBPoint3dArray.PTArr(points.getDataMutable(0))^[0..points.Count-1]);
end;

procedure ZGLGraphix.DrawPointWithoutLT(var DC:TDrawContext;const p:TzePoint3d;var dr:TLLDrawResult);
begin
     if dr.LLPCount=0 then
                          dr.BB:=CreateBBFromPoint(p)
                      else
                          concatBBandPoint(dr.BB,p);
     inc(dr.LLPCount);
     AddPoint(DC,p);
end;
function creatematrix(const PInsert:TzePoint3d; //Точка вставки
                      param:shxprop;     //Параметры текста
                      LineAngle,         //Угол линии
                      Scale:Double)   //Масштаб линии
                      :TzeTypedMatrix4d;        //Выходная матрица
var
    mrot,mentrot,madd,mtrans,mscale:TzeTypedMatrix4d;
begin
{case PSP.param.AD of
                    TACAbs:a:=PSP^.param.Angle*pi/180;
                    TACRel:a:=PSP^.param.Angle*pi/180-angle;
                    TACUpRight:a:=0;
                  end;}
    mrot:=CreateRotationMatrixZ(param.Angle*pi/180);
    if param.AD=TACRel then
                           mentrot:=CreateRotationMatrixZ(LineAngle)
                       else
                           mentrot:=onematrix;
    madd:=CreateTranslationMatrix(createvertex(param.x*Scale,param.y*Scale,0));
    mtrans:=CreateTranslationMatrix(createvertex(PInsert.x,PInsert.y,PInsert.z));
    mscale:=CreateScaleMatrix(createvertex(param.Height*Scale,param.Height*Scale,param.Height*Scale));
    result:=onematrix;
    result:=MatrixMultiply(result,mscale);
    result:=MatrixMultiply(result,mrot);
    result:=MatrixMultiply(result,madd);
    result:=MatrixMultiply(result,mentrot);
    result:=MatrixMultiply(result,mtrans);
end;
function CreateReadableMatrix(const PInsert:TzePoint3d; //Точка вставки
                      param:shxprop;     //Параметры текста
                      LineAngle,         //Угол линии
                      Scale:Double;
                      dx,dy:Double)   //Масштаб линии
                      :TzeTypedMatrix4d;        //Выходная матрица
var
    mrot,mrot2,mentrot,madd,madd2,madd3,mtrans,mscale:TzeTypedMatrix4d;
begin
    mrot:=CreateRotationMatrixZ(param.Angle*pi/180);
    if (param.AD<>TACAbs) then
                           mentrot:=CreateRotationMatrixZ(LineAngle)
                       else
                           mentrot:=onematrix;
    madd:=CreateTranslationMatrix(createvertex(param.x*Scale,param.y*Scale,0));
    mtrans:=CreateTranslationMatrix(createvertex(PInsert.x,PInsert.y,PInsert.z));
    mscale:=CreateScaleMatrix(createvertex(param.Height*Scale,param.Height*Scale,param.Height*Scale));
    result:=onematrix;
    result:=MatrixMultiply(result,mscale);

    if sysvarDWGRotateTextInLT then
    if (param.AD<>TACAbs) then
    if isNotReadableAngle(LineAngle) then
    begin
    madd2:=CreateTranslationMatrix(createvertex(dx*Scale,dy*Scale,0));
    madd3:=CreateTranslationMatrix(createvertex(-dx*Scale,-dy*Scale,0));
    mrot2:=CreateRotationMatrixZ(pi);
    result:=MatrixMultiply(result,madd3);
    result:=MatrixMultiply(result,mrot2);
    result:=MatrixMultiply(result,madd2);
    end;

    result:=MatrixMultiply(result,mrot);
    result:=MatrixMultiply(result,madd);

    result:=MatrixMultiply(result,mentrot);
    result:=MatrixMultiply(result,mtrans);
end;
procedure ZGLGraphix.PlaceShape(drawer:TZGLAbstractDrawer;const StartPatternPoint:TzePoint3d;PSP:PShapeProp;scale,angle:Double);
var
    objmatrix,matr:TzeTypedMatrix4d;
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
                    PSP^.param.PStyle.pfont.CreateSymbol(drawer,1,self,PSP.Psymbol.Number,objmatrix,matr,Bound,sli);
end;
procedure ZGLGraphix.PlaceText(drawer:TZGLAbstractDrawer;const StartPatternPoint:TzePoint3d;PTP:PTextProp;scale,angle:Double);
var
    objmatrix,matr:TzeTypedMatrix4d;
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
          if ptp.param.PStyle.pfont.font.IsUnicode then
                                                     sym:=ach2uch(sym);
PTP^.param.PStyle.pfont.CreateSymbol(drawer,PTP.txtH,self,sym,objmatrix,matr,Bound,sli);
matr.mtr.v[3].v[0]:=matr.mtr.v[3].v[0]+PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[j]){//-ttf-//,tdinfo}).NextSymX;
matr.t:=matr.t+CMTTranslate;
end;
end;
procedure ZGLGraphix.PlaceOnePattern(
  var DC:TDrawContext;var Segmentator:ZSegmentator;//стартовая точка паттернов,
                                                   //стартовая точка линии
                                                   //(добавка в начало линии)
  const vp:PGDBLtypeProp;//стиль и прочая лабуда
  TangentScale,NormalScale,length,scale_div_length:Double;//направление, масштаб, длинна
  var dr:TLLDrawResult;
  SupressFirstDash:boolean=false);
var
  TDI:PTDashInfo;
  PStroke:PDouble;
  PSP:PShapeProp;
  PTP:PTextProp;
  irDashArray,irStrokesArray,irShapeArray,irTextArray:itrec;
begin
  TDI:=vp.dasharray.beginiterate(irDashArray);
  PStroke:=vp.strokesarray.beginiterate(irStrokesArray);
  PSP:=vp.shapearray.beginiterate(irShapeArray);
  PTP:=vp.textarray.beginiterate(irTextArray);
  if PStroke<>nil then repeat
    case TDI^ of
      TDIDash:begin
        if PStroke^<>0 then begin
          if PStroke^>0 then
            Segmentator.draw(DC,abs(PStroke^)*scale_div_length,true,dr)
          else
            Segmentator.draw(DC,abs(PStroke^)*scale_div_length,false,dr);
        end else
          if not SupressFirstDash then
            DrawPointWithoutLT(DC,Segmentator.cp,dr);
        PStroke:=vp.strokesarray.iterate(irStrokesArray);
      end;
      TDIShape:begin
        PlaceShape(DC.drawer,Segmentator.cp,PSP,NormalScale,Segmentator.angle);
        PSP:=vp.shapearray.iterate(irShapeArray);
      end;
      TDIText:begin
        PlaceText(DC.drawer,Segmentator.cp,PTP,NormalScale,Segmentator.angle);
        PTP:=vp.textarray.iterate(irTextArray);
      end;
    end;
    SupressFirstDash:=false;;
    TDI:=vp.dasharray.iterate(irDashArray);
  until TDI=nil;
end;

procedure ZGLGraphix.PlaceNPatterns(var DC:TDrawContext;var Segmentator:ZSegmentator;//стартовая точка паттернов, стартовая точка линии (добавка в начало линии)
                                     const pli:TArrayIndex;
                                     num:integer; //кол-во паттернов
                                     const vp:PGDBLtypeProp;                 //стиль и прочая лабуда
                                     TangentScale,NormalScale,length:Double;//направление, масштаб, длинна
                                     var dr:TLLDrawResult;
                                     SupressFirstDash:boolean=false);          //подавить пкрвый штрих (пока используется в случае если он точка)
var
  i,nextSegmentOperations:integer;
  ppl:PTLLProxyLine;
  scale_div_length:Double;
begin
  if num>0 then begin
    scale_div_length:=TangentScale/length;
    PlaceOnePattern(DC,Segmentator,vp,TangentScale,NormalScale,length,scale_div_length,dr,SupressFirstDash);//рисуем один паттерн
    nextSegmentOperations:=-1;
    if pli>-1 then begin
      ppl:=pointer(LLprimitives.getDataMutable(pli));
      nextSegmentOperations:=ppl^.NextPatternCountToStore(0);
    end;
    for i:=1 to num-1 do begin
      PlaceOnePattern(DC,Segmentator,vp,TangentScale,NormalScale,length,scale_div_length,dr);//рисуем один паттерн
      if i=nextSegmentOperations then
        if pli>-1 then begin
          ppl:=pointer(LLprimitives.getDataMutable(pli));
          ppl.Process(GeomData,Segmentator.cp,LLprimitives.Count,Segmentator.cdp);
          nextSegmentOperations:=ppl^.NextPatternCountToStore(i);
        end;
    end;
  end;
end;
procedure ZSegmentator.draw(var rc:TDrawContext;length:Double;paint:boolean;var dr:TLLDrawResult);
var
  tcdp:Double;
  oldcp,tv:TzePoint3d;
begin
  if cdp<1 then begin
    tcdp:=length+cdp;
    if (cdp<-eps)and(tcdp>eps)then begin
      length:=length+cdp;
      cdp:=0;
    end;
    if (cdp>=-eps)and(tcdp>eps) then begin
      if tcdp<=(pcurrsegment.naccumlength+eps) then begin
        oldcp:=cp;
        tv:=VertexMulOnSc(dir,length/pcurrsegment.nlength);
        cp:=vertexadd(cp,tv);
        if paint then
          self.PGeom.DrawLineWithoutLT(rc,oldcp,cp,dr);
        cdp:=tcdp;
      end else begin
        if paint then
          self.PGeom.DrawLineWithoutLT(rc,cp,pcurrsegment^.endpoint,dr);
        length:=tcdp-pcurrsegment^.naccumlength;
        self.nextsegment;
        if pcurrsegment<>nil then
         draw(rc,length,paint,dr);
      end;
    end else
      cdp:=tcdp;
  end;
end;
function CreateLLDrawResult(var LLPS:TLLPrimitivesArray):TLLDrawResult;
begin
 result.Appearance:=TANeedProxy;
 result.LLPCount:=0;
 result.LLPEndi:=0;
 result.LLPStart:=LLPS.Count;
end;
procedure FinishLLDrawResult(var LLPS:TLLPrimitivesArray;var dr:TLLDrawResult);
begin
 dr.LLPEndi:=LLPS.Count;
end;
function ZGLGraphix.DrawPolyLineWithLT(var DC:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean):TLLDrawResult;
var
    //ptv,ptvprev,ptvfisrt: PzePoint3d;
    //ir:itrec;
    TangentScale,NormalScale,polylength,TrueNumberOfPatterns,normalizedD,d,halfStroke,dend:Double;
    Segmentator:ZSegmentator;
    lt:PGDBLtypeProp;
    PStroke:PDouble;
    ir3:itrec;
    minPatternsCount,NumberOfPatterns:integer;
    supressfirstdash:boolean;
procedure SetPolyUnLTyped;
begin
  DrawPolyLineWithoutLT(dc,points,vp,closed,result);
  {    ptv:=Points.beginiterate(ir);
      ptvfisrt:=ptv;
      if ptv<>nil then
      repeat
            ptvprev:=ptv;
            ptv:=Points.iterate(ir);
            if ptv<>nil then
                            DrawLineWithoutLT(DC,ptv^,ptvprev^,result);
      until ptv=nil;
      if closed then
                    DrawLineWithoutLT(DC,ptvprev^,ptvfisrt^,result);}
end;
begin
  result:=CreateLLDrawResult(LLprimitives);
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
           TangentScale:={SysVar.dwg.DWG_LTScale^}DC.DrawingContext.GlobalLTScale*vp.LineTypeScale;
           NormalScale:=TangentScale;
           TrueNumberOfPatterns:=polylength/(TangentScale*LT.strokesarray.LengthFact);
           if ltgen and closed then
                        begin
                        minPatternsCount:=2;
                        NumberOfPatterns:=round(TrueNumberOfPatterns);
                        if NumberOfPatterns=0 then
                                                  TangentScale:=NormalScale
                                              else
                                                  TangentScale:=polyLength/(NumberOfPatterns*LT.strokesarray.LengthFact);
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
                    D:=(polyLength-(TangentScale*LT.strokesarray.LengthFact)*NumberOfPatterns)/2; //длинна добавки для выравнивания
                    normalizedD:=D/polyLength;

                    if (not closed)or(not ltgen) then
                    begin
                    PStroke:=LT^.strokesarray.beginiterate(ir3);//первый штрих
                    halfStroke:=(TangentScale*abs(PStroke^/2))/polylength;//первый штрих
                    //Segmentator.draw(DC,normalizedD-halfStroke,true);
                    supressfirstdash:=false;
                    dend:=normalizedD-halfStroke;
                    if dend>eps then
                    case LT.FirstStroke of
                                 TODILine:Segmentator.draw(DC,dend,true,result);
                                TODIPoint:
                                          begin
                                               DrawPointWithoutLT(DC,Segmentator.cp,result);
                                               Segmentator.draw(DC,dend,false,result);
                                               supressfirstdash:=true;
                                          end;
          TODIUnknown,TODIShape,TODIBlank:;//заглушка на варнинг
                    end;
                    end;


                    PlaceNPatterns(DC,Segmentator,-1,NumberOfPatterns,LT,TangentScale,NormalScale,polylength,result,supressfirstdash);//рисуем TrueNumberOfPatterns паттернов
                    dend:=1-Segmentator.cdp;
                    if (dend>eps) or (LT.WithoutLines) then
                                    begin
                                    //Segmentator.draw(DC,dend,true);
                                    //дорисовываем окончание если надо
                                    case LT.FirstStroke of
                                                 TODILine:Segmentator.draw(DC,dend,true,result);
                                                TODIPoint:
                                                          begin
                                                               Segmentator.draw(DC,dend,false,result);
                                                               DrawPointWithoutLT(DC,Segmentator.cp,result);
                                                          end;
                          TODIUnknown,TODIShape,TODIBlank:;//заглушка на варнинг
                                    end;
                                    end;
               end;
           Segmentator.done;
       end;
  end;
  Shrink;
  FinishLLDrawResult(LLprimitives,result);
end;
function ZGLGraphix.DrawLineWithLT(var DC:TDrawContext;const startpoint,endpoint:TzePoint3d; const vp:GDBObjVisualProp;OnlyOne:Boolean=False):TLLDrawResult;
var
  scale,length:Double;
  normalizedD,D,halfStroke,dend:Double;
  num:integer;
  ir3:itrec;
  PStroke:PDouble;
  lt:PGDBLtypeProp;
  Segmentator:ZSegmentator;
  supressfirstdash:boolean;
  pli,FirstLinePrimitiveindex:TArrayIndex;
  ppl:PTLLProxyLine;
begin
  pli:=-1;
  result:=CreateLLDrawResult(LLprimitives);
  LT:=getLTfromVP(vp);
  if (LT=nil) or (LT.dasharray.Count=0) then begin
    DrawLineWithoutLT(DC,startpoint,endpoint,result,OnlyOne);
    result.Appearance:=TAMatching;
  end else begin
    //LT:=getLTfromVP(vp);
    FirstLinePrimitiveindex:=LLprimitives.Count;
    length:=Vertexlength(startpoint,endpoint);//длина линии
    scale:=DC.DrawingContext.GlobalLTScale*vp.LineTypeScale;//фактический масштаб линии
    num:=trunc(Length/(scale*LT.strokesarray.LengthFact));//количество повторений шаблона
    if ((num<1)and(not LT^.WithoutLines))or(num>SysVarRDMaxLTPatternsInEntity) then begin
      DrawLineWithoutLT(DC,startpoint,endpoint,result,OnlyOne); //не рисуем шаблон при большом количестве повторений
      result.Appearance:=TAMatching;
    end else begin
      if DC.drawer<>nil then begin
        pli:=DC.drawer.GetLLPrimitivesCreator.CreateLLProxyLine(LLprimitives);
        ppl:=pointer(LLprimitives.getDataMutable(pli));
        ppl.MaxDashLength:=scale*LT.strokesarray.LengthFact;
        ppl.FirstIndex:=GeomData.Vertex3S.PushBackData(startpoint);
        ppl.LastIndex:=GeomData.Vertex3S.PushBackData(endpoint);
        ppl.FirstLinePrimitiveindex:=FirstLinePrimitiveindex;
        ppl.MakeReadyIndexsVector(num);
      end;
      Segmentator.InitFromLine(startpoint,endpoint,length,@self);//длина линии
      Segmentator.startdraw;
      D:=(Length-(scale*LT.strokesarray.LengthFact)*num)/2; //длинна добавки для выравнивания
      normalizedD:=D/Length;

      PStroke:=LT^.strokesarray.beginiterate(ir3);//первый штрих
      halfStroke:=(scale*abs(PStroke^/2))/length;//первый штрих
      supressfirstdash:=false;
      dend:=normalizedD-halfStroke;
      if lt^.LastStroke<>TODILine then
        case LT.FirstStroke of
          TODILine:
            Segmentator.draw(DC,dend,true,result);
          TODIPoint:begin
            DrawPointWithoutLT(DC,Segmentator.cp,result);
            Segmentator.draw(DC,dend,false,result);
            supressfirstdash:=true;
          end;
          TODIUnknown,
          TODIShape,
          TODIBlank:;//заглушка на варнинг
      end;

      PlaceNPatterns(DC,Segmentator,pli,num,LT,scale,scale,length,result,supressfirstdash);//рисуем num паттернов

      dend:=1-Segmentator.cdp;
      if dend>eps then begin
        //Segmentator.draw(DC,dend,true);
        //дорисовываем окончание если надо
        case LT.FirstStroke of
          TODILine:
            Segmentator.draw(DC,dend,true,result);
          TODIPoint:
            DrawPointWithoutLT(DC,endpoint,result);
          TODIUnknown,
          TODIShape,
          TODIBlank:;//заглушка на варнинг
        end;
      end;

      Segmentator.done;
    end;
  end;
  if pli<>-1 then begin
    ppl:=pointer(LLprimitives.getDataMutable(pli));
    ppl.LastLinePrimitiveindex:=LLprimitives.Count;
  end;
  FinishLLDrawResult(LLprimitives,result);
  Shrink;
end;

procedure ZGLGraphix.drawgeometry;
begin
  //rc.drawer.PVertexBuffer:=@GeomData.Vertex3S;
  DrawLLPrimitives(DC,DC.drawer,inFrustumState,simplydraw);
end;
constructor ZGLGraphix.init;
begin
  inherited;
end;
destructor ZGLGraphix.done;
begin
  inherited;
end;
begin
end.

