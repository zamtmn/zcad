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
{$mode objfpc}{$H+}

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzccominteractivemanipulators;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface

uses

 { uses units, the list will vary depending on the required entities
    and actions }
 { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  SysUtils,Math,
  URecordDescriptor,TypeDescriptors,
  uzccommandsabstract,
  Forms,
  uzeutils,
  uzegeometrytypes,
  uzeentblockinsert,      //unit describes blockinsert entity
  //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
  //модуль описывающий примитив линия

  uzeentlwpolyline,             //unit describes line entity
  //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
  //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
  //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,
  uzeentdimdiametric,
  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,
  uzcentcable,
  uzeentdevice,
  uzegeometry,
  uzeentityfactory,    //unit describing a "factory" to create primitives
  //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
  //системные переменные
  uzgldrawcontext,

  //base types
  //описания базовых типов
  //описания базовых констант
  uzccommandsmanager,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
  //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
  //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  gzctnrVectorTypes,
  uzclog;                //log system

  //<**система логирования

type
  PT3PointPentity=^T3PointPentity;

  T3PointPentity=record
    p1,p2,p3:TzePoint3d;
    pentity:PGDBObjEntity;
  end;
  TCircleDrawMode=(TCDM_CR,TCDM_CD,TCDM_2P,TCDM_3P);
  TPolygonDrawMode=(TPDM_CV,TPDM_CC);
  PT3PointCircleModePentity=^T3PointCircleModePentity;

  T3PointCircleModePEntity=record
    p1,p2,p3:TzePoint3d;
    cdm:TCircleDrawMode;
    npoint:integer;
    pentity:PGDBObjEntity;
  end;
  PTPointPolygonDrawModePentity=^TPointPolygonDrawModePentity;

  TPointPolygonDrawModePentity=record
    p1:TzePoint3d;
    cdm:TPolygonDrawMode;
    typeLWPoly:boolean;
    npoint:integer;
    pentity:PGDBObjPolyline;
    plwentity:PGDBObjLWPolyline;
  end;

procedure InteractiveLineEndManipulator(const PInteractiveData:PGDBObjLine;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveADimManipulator(const PInteractiveData:PGDBObjAlignedDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveRDimManipulator(const PInteractiveData:PGDBObjRotatedDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveDDimManipulator(const PInteractiveData:pgdbObjDiametricDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveArcManipulator(const PInteractiveData:PT3PointPentity;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveSmartCircleManipulator(const PInteractiveData:PT3PointCircleModePentity;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveLWRectangleManipulator(const PInteractiveData:PGDBObjLWPolyline;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveRectangleManipulator(const PInteractiveData:PGDBObjPolyline;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractivePolygonManipulator(const PInteractiveData:TPointPolygonDrawModePentity;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
procedure InteractiveConstructRootManipulator(const PInteractiveData:Pointer;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);

implementation

{ Интерактивные процедуры используются совместно с Get3DPointInteractive,
  впоследствии будут вынесены в отдельный модуль }
{ Interactive procedures are used together with Get3DPointInteractive,
  later to be moved to a separate unit }

{Процедура интерактивного "перемещения" конструкторской области}
procedure InteractiveConstructRootManipulator(const PInteractiveData:Pointer;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  ir:itrec;
  p:PGDBObjEntity;
  t_matrix:TzeTypedMatrix4d;
  RC:TDrawContext;
begin
  if click then begin
    t_matrix:=CreateTranslationMatrix(Point);
    drawings.GetCurrentDWG^.ConstructObjRoot.transform(t_matrix);
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
    p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
    if p<>nil then
      repeat
        p^.transform(t_matrix);
        p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
      until p=nil;
  end else begin
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=CreateTranslationMatrix(Point);
    RC:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentDWG^.ConstructObjRoot.FormatEntity(drawings.GetCurrentDWG^,RC);
  end;
end;

{Procedure interactive changes end of the line}
{Процедура интерактивного изменения конца линии}
procedure InteractiveLineEndManipulator(const PInteractiveData:PGDBObjLine;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  ln:PGDBObjLine absolute PInteractiveData;
  dc:TDrawContext;
begin

  // assign general properties from system variables to entity
  //присваиваем примитиву общие свойства из системных переменных
  zcSetEntPropFromCurrentDrawingProp(ln);

  // set the new point to the end of the line
  // устанавливаем новую точку конца линии
  ln^.CoordInOCS.lEnd:=Point;
  //format entity
  //"форматируем" примитив в соответствии с заданными параметрами
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  ln^.FormatEntity(drawings.GetCurrentDWG^,dc);

end;

{Procedure interactive changes third point of aligned dimensions}
{Процедура интерактивного изменения третьей точки выровненного размера}
procedure InteractiveADimManipulator(const PInteractiveData:PGDBObjAlignedDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  ad:PGDBObjAlignedDimension absolute PInteractiveData;
  dc:TDrawContext;
begin

  // assign general properties from system variables to entity
  // присваиваем примитиву общие свойства из системных переменных
  zcSetEntPropFromCurrentDrawingProp(ad);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  with ad^ do begin
    //specify the dimension style
    //указываем стиль размеров
    PDimStyle:=sysvar.dwg.DWG_CDimStyle^;

    //assign the obtained point to the appropriate location primitive
    //присваиваем полученые точки в соответствующие места примитиву
    DimData.P10InWCS:=Point;

     { calculate P10InWCS - she must lie on normal drawn from P14InWCS,
       use the built-in to primitive mechanism }
     { рассчитываем P10InWCS - она должна лежать на нормали проведенной
       из P14InWCS, используем для этого встроенный в примитив механизм }
    CalcDNVectors;

     { calculate P10InWCS - she must lie on normal drawn from P14InWCS,
       use the built-in to primitive mechanism}
     { рассчитываем P10InWCS - она должна лежать на нормали проведенной из
       P14InWCS, используем для этого встроенный в примитив механизм }
    DimData.P10InWCS:=P10ChangeTo(Point);

    //format entity
    //"форматируем" примитив в соответствии с заданными параметрами
    FormatEntity(drawings.GetCurrentDWG^,dc);

  end;
end;

function isRDIMHorisontal(p1,p2,p3,nevp3:TzePoint3d):integer;
var
  minx,maxx,miny,maxy:double;
begin
  minx:=min(p1.x,p2.x);
  maxx:=max(p1.x,p2.x);
  miny:=min(p1.y,p2.y);
  maxy:=max(p1.y,p2.y);
  if (minx<=p3.x)and (p3.x<=maxx) and (miny<=p3.y)and (p3.y<=maxy) then begin
    if (minx<=nevp3.x)and(nevp3.x<=maxx)and(miny<=nevp3.y)and(nevp3.y<=maxy) then
      Result:=0
    else begin
      if (minx>nevp3.x)or(nevp3.x>maxx) then
        Result:=2
      else
        Result:=1;

    end;
  end else
    Result:=0;
end;

procedure InteractiveRDimManipulator(const PInteractiveData:PGDBObjRotatedDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  rd:PGDBObjRotatedDimension absolute PInteractiveData;
  dc:TDrawContext;
begin

  zcSetEntPropFromCurrentDrawingProp(rd);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  with rd^ do begin
    PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
    case isRDIMHorisontal(DimData.P13InWCS,DimData.P14InWCS,
        DimData.P10InWCS,Point)
      of
      1:begin
        vectorD:=XWCS;
        vectorN:=YWCS;
      end;
      2:begin
        vectorD:=YWCS;
        vectorN:=XWCS;
      end;
    end;
    DimData.P10InWCS:=Point;
    DimData.P10InWCS:=P10ChangeTo(Point);
    FormatEntity(drawings.GetCurrentDWG^,dc);
  end;
end;

procedure InteractiveDDimManipulator(const PInteractiveData:pgdbObjDiametricDimension;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  dd:pgdbObjDiametricDimension absolute PInteractiveData;
  dc:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(dd);
  with dd^ do begin
    PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
    DimData.P11InOCS:=Point;
    DimData.P11InOCS:=P11ChangeTo(Point);
    FormatEntity(drawings.GetCurrentDWG^,dc);
  end;
end;

procedure InteractiveArcManipulator(const PInteractiveData:PT3PointPentity;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  PointData:TArcrtModify;
  ad:TArcData;
  dc:TDrawContext;
begin
  PointData.p1.x:=PT3PointPentity(PInteractiveData)^.p1.x;
  PointData.p1.y:=PT3PointPentity(PInteractiveData)^.p1.y;
  PointData.p2.x:=PT3PointPentity(PInteractiveData)^.p2.x;
  PointData.p2.y:=PT3PointPentity(PInteractiveData)^.p2.y;
  PointData.p3.x:=Point.x;
  PointData.p3.y:=Point.y;
  if GetArcParamFrom3Point2D(PointData,ad) then begin
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.x:=ad.p.x;
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.y:=ad.p.y;
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.z:=0;
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.startangle:=ad.startangle;
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.endangle:=ad.endangle;
    PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.r:=ad.r;

    zeSetEntityProp(PT3PointPentity(PInteractiveData)^.pentity,
      sysvar.dwg.DWG_CLayer^,
      sysvar.dwg.DWG_CLType^,
      sysvar.dwg.DWG_CLinew^,
      sysvar.dwg.DWG_CColor^);
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    PT3PointPentity(PInteractiveData)^.pentity^.FormatEntity(
      drawings.GetCurrentDWG^,dc);
  end;
end;

procedure InteractiveSmartCircleManipulator(
  const PInteractiveData:PT3PointCircleModePentity;Point:TzePoint3d;
  Click:boolean;ESP:TEntitySetupProc=nil);
var
  PointData:tarcrtmodify;
  ad:TArcData;
  dc:TDrawContext;
begin
  zcSetEntPropFromCurrentDrawingProp(PT3PointCircleModePentity(
    PInteractiveData)^.pentity);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  case PT3PointCircleModePentity(PInteractiveData)^.npoint of
    0:begin
      PGDBObjCircle(PT3PointCircleModePentity(
        PInteractiveData)^.pentity)^.Local.p_insert:=
        PT3PointCircleModePentity(PInteractiveData)^.p1;
    end;
    1:begin
      case
        PT3PointCircleModePentity(PInteractiveData)^.cdm of
        TCDM_CR:begin
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert:=
            PT3PointCircleModePentity(PInteractiveData)^.p1;
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Radius:=
            uzegeometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point);
        end;
        TCDM_CD:begin
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert:=
            PT3PointCircleModePentity(PInteractiveData)^.p1;
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Radius:=
            uzegeometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point)/2;
        end;
        TCDM_2P,TCDM_3P:begin
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert:=
            VertexMulOnSc(VertexAdd(PT3PointCircleModePentity(PInteractiveData)^.p1,point),0.5);
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Radius:=
            uzegeometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point)/2;
        end;

      end;
    end;
    2:if PT3PointCircleModePentity(PInteractiveData)^.cdm=TCDM_3P then begin
        PointData.p1.x:=PT3PointCircleModePentity(PInteractiveData)^.p1.x;
        PointData.p1.y:=PT3PointCircleModePentity(PInteractiveData)^.p1.y;
        PointData.p2.x:=PT3PointCircleModePentity(PInteractiveData)^.p2.x;
        PointData.p2.y:=PT3PointCircleModePentity(PInteractiveData)^.p2.y;
        PointData.p3.x:=Point.x;
        PointData.p3.y:=Point.y;
        if GetArcParamFrom3Point2D(PointData,ad) then begin
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert.x:=ad.p.x;
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert.y:=ad.p.y;
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Local.p_insert.z:=0;
          PGDBObjCircle(PT3PointCircleModePentity(
            PInteractiveData)^.pentity)^.Radius:=ad.r;
        end;
      end;
  end;
  PT3PointCircleModePentity(PInteractiveData)^.pentity^.FormatEntity(
    drawings.GetCurrentDWG^,dc);
end;

procedure InteractiveLWRectangleManipulator(const PInteractiveData:PGDBObjLWPolyline;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  polyLWObj:PGDBObjLWPolyline absolute PInteractiveData;
  stPoint:TzePoint2d;
begin

  zcSetEntPropFromCurrentDrawingProp(polyLWObj);

  stPoint:=TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(0)^);

  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(1)^).x:=Point.x;
  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(1)^).y:=stPoint.y;

  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(2)^).x:=Point.x;
  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(2)^).y:=Point.y;

  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(3)^).x:=stPoint.x;
  TzePoint2d(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(3)^).y:=Point.y;

  polyLWObj^.YouChanged(drawings.GetCurrentDWG^);

end;


procedure InteractiveRectangleManipulator(const PInteractiveData:PGDBObjPolyline;
  Point:TzePoint3d;Click:boolean;ESP:TEntitySetupProc=nil);
var
  polyObj:PGDBObjPolyline absolute PInteractiveData;
  stPoint:TzePoint3d;
begin

  zcSetEntPropFromCurrentDrawingProp(polyObj);

  stPoint:=TzePoint3d(polyObj^.VertexArrayInOCS.getDataMutable(0)^);

  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(1))^.x:=Point.x;
  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(1))^.y:=stPoint.y;

  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(2))^.x:=Point.x;
  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(2))^.y:=Point.y;

  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(3))^.x:=stPoint.x;
  PzePoint2d(polyObj^.VertexArrayInOCS.getDataMutable(3))^.y:=Point.y;

  if ESP<>nil then
    ESP(ESSSetConstructEntity,polyObj);

  polyObj^.YouChanged(drawings.GetCurrentDWG^);
end;

procedure InteractivePolygonManipulator(
  const PInteractiveData:TPointPolygonDrawModePentity;Point:TzePoint3d;
  Click:boolean;ESP:TEntitySetupProc=nil);
var
  obj:TPointPolygonDrawModePentity absolute PInteractiveData;
  stPoint:TzePoint3d;
  //dc:TDrawContext;
  i,countVert:integer;
  radius,alpha,stalpha,xyline,xline:double;
  sine,cosine:double;
begin

  countVert:=obj.npoint;
  stPoint:=obj.p1;
  xyline:=uzegeometry.Vertexlength(stPoint,Point);

  if xyline<eps then
    exit;

  xline:=uzegeometry.Vertexlength(stPoint,CreateVertex(Point.x,stPoint.y,0));

  radius:=Vertexlength(stPoint,Point);
  stalpha:=0;

  if obj.cdm=TPDM_CC then begin
    stalpha:=pi/countVert;
    radius:=radius/(cos(pi/countVert));
  end;

  alpha:=stalpha+arccos(xline/xyline)-pi;

  if (stPoint.x<=Point.x) and (stPoint.y>=Point.y) then
    alpha:=stalpha-arccos(xline/xyline);

  if (stPoint.x>=Point.x) and (stPoint.y<=Point.y) then
    alpha:=stalpha-arccos(xline/xyline)+pi;

  if (stPoint.x<=Point.x) and (stPoint.y<=Point.y) then
    alpha:=stalpha+arccos(xline/xyline);


  if obj.typeLWPoly then  begin
    zcSetEntPropFromCurrentDrawingProp(obj.plwentity);
    for i:=countVert-1 downto 0 do begin
      SinCos(alpha+(2*pi*i/countVert),sine,cosine);
      TzePoint2d(obj.plwentity^.Vertex2D_in_OCS_Array.getDataMutable(i)^).x:=
        stPoint.x+radius*cosine;
      TzePoint2d(obj.plwentity^.Vertex2D_in_OCS_Array.getDataMutable(i)^).y:=
        stPoint.y+radius*sine;
    end;
    obj.plwentity^.YouChanged(drawings.GetCurrentDWG^);
    //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    //obj.plwentity^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end else begin
    zcSetEntPropFromCurrentDrawingProp(obj.pentity);
    for i:=countVert-1 downto 0 do begin
      SinCos(alpha+(2*pi*i/countVert),sine,cosine);
      PzePoint2d(obj.pentity^.VertexArrayInOCS.getDataMutable(i))^.x:=
        stPoint.x+radius*cosine;
      PzePoint2d(obj.pentity^.VertexArrayInOCS.getDataMutable(i))^.y:=
        stPoint.y+radius*sine;
    end;
    obj.pentity^.YouChanged(drawings.GetCurrentDWG^);
    //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    //obj.pentity^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end;

end;


initialization
end.
