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
@author()
}
{$mode delphi}
unit uzccommand_polygon;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccominteractivemanipulators,
  uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcutils,
  //
  uzegeometry,
  URecordDescriptor,uzsbTypeDescriptors,Varman,uzsbVarmanDef;

type
  //** Перечислимый тип для отображения в инспекторе режима создания прямоугольника (из 3DPolyLine или LWPolyLine, составная часть TRectangParam)
  TRectangEntType=(
    RET_3DPoly(*'3DPoly'*)
    //**< будет использован примитив 3DPolyLine
    ,RET_LWPoly(*'LWPoly'*)
    //**< будет использован примитив LWPolyline
    );
  //** Тип данных для отображения в инспекторе опций команды Rectangle
  TPolygonParam=record
    ET:TRectangEntType;
    (*'Entity type'*)
    //**< Выбор типа примитива, которым будет создан прямоугольник - 3Dolyline или LWPolyline
    VNum:integer;
    (*'Number of vertices'*)//**< Определение количества вершин
    PolyWidth:double;
    (*'Polyline width'*)
    //**< Ширина полилинии (если в качестве примитива выбран RET_LWPoly)
  end;


implementation

var
  PolygonParam:TPolygonParam;
  //**< Переменная содержащая опции команды Polygon

//** Чертим многоугольник центер вершина
function DrawPolygon_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  vertexLWObj:TzePoint2d;
  //переменная для добавления вершин в полилинию
  vertexObj:TzePoint3d;
  widthObj:GLLWWidth;
  //переменная для добавления веса линии в начале и конце пути
  //polyLWObj:PGDBObjLWPolyline;
  //polyObj:PGDBObjPolyline;
  pe:T3PointPentity;
  polygonDrawModePentity:TPointPolygonDrawModePentity;
  i:integer;
  PInternalRTTITypeDesk:PRecordDescriptor;
  //**< Доступ к панели упр в инспекторе
  pf:PfieldDescriptor;
  //**< Управление нашей панелью в инспекторе
  UCoperands:string;
begin
  UCoperands:=uppercase(operands);
  if UCoperands='CV' then
    polygonDrawModePentity.cdm:=TPDM_CV
  else if UCoperands='CC' then
    polygonDrawModePentity.cdm:=TPDM_CC
  else
    polygonDrawModePentity.cdm:=TPDM_CV;

  PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD('TPolygonParam'));
  //находим описание типа TRectangParam, мы сразу знаем что это описание записи, поэтому нужно привести тип
  pf:=PInternalRTTITypeDesk^.FindField('ET');
  //находим описание поля ET
  pf^.base.Attributes:=pf^.base.Attributes-[fldaReadOnly];
  //сбрасываем ему флаг ридонли
  pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
  //находим описание поля ET
  pf^.base.Attributes:=pf^.base.Attributes-[fldaReadOnly];
  //сбрасываем ему флаг ридонли
  pf:=PInternalRTTITypeDesk^.FindField('VNum');
  //находим описание поля ET
  pf^.base.Attributes:=pf^.base.Attributes-[fldaReadOnly];
  //сбрасываем ему флаг ридонли
  //pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
  //pf^.base.Attributes:=pf^.base.Attributes or fldaHidden;//устанавливаем ему флаг cкрытности
  zcShowCommandParams(PInternalRTTITypeDesk,@PolygonParam);

  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,pe.p1)=IRNormal then begin
    pf:=PInternalRTTITypeDesk^.FindField('ET');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
    //устанавливаем ему флаг ридонли
    pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
    //устанавливаем ему флаг ридонли
    pf:=PInternalRTTITypeDesk^.FindField('VNum');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
    //устанавливаем ему флаг ридонли

    polygonDrawModePentity.npoint:=PolygonParam.VNum;
    polygonDrawModePentity.typeLWPoly:=False;
    polygonDrawModePentity.p1:=pe.p1;
    //Создаем сразу 4-е точки прямоугольника, что бы в манипуляторе только управльть их координатами
    if PolygonParam.ET=RET_LWPoly then begin
      polygonDrawModePentity.typeLWPoly:=True;
      polygonDrawModePentity.plwentity:=GDBObjLWPolyline.CreateInstance;
      polygonDrawModePentity.plwentity^.Closed:=True;

      widthObj.endw:=PolygonParam.PolyWidth;
      widthObj.startw:=PolygonParam.PolyWidth;

      ////drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@polygonDrawModePentity.plwentity);//было, теперь стало, не @указатель, а просто указатель
      zcAddEntToCurrentDrawingConstructRoot(polygonDrawModePentity.plwentity);
      vertexLWObj.x:=pe.p1.x;
      vertexLWObj.y:=pe.p1.y;
      for i:=0 to PolygonParam.VNum-1 do begin
        polygonDrawModePentity.plwentity^.Vertex2D_in_OCS_Array.PushBackData(
          vertexLWObj);
        polygonDrawModePentity.plwentity^.Width2D_in_OCS_Array.PushBackData(
          widthObj);
      end;

      InteractivePolygonManipulator(polygonDrawModePentity,pe.p1,False);
      if commandmanager.Get3DPointInteractive(
        rscmSpecifySecondPoint,pe.p2,@InteractivePolygonManipulator,@polygonDrawModePentity)=
        IRNormal then begin
        zcAddEntToCurrentDrawingWithUndo(polygonDrawModePentity.plwentity);
        //Добавить объект из конструкторской области в чертеж через ундо//
                {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
        //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
        zcClearCurrentDrawingConstructRoot;
      end;
    end else begin
      polygonDrawModePentity.typeLWPoly:=False;
      polygonDrawModePentity.pentity:=GDBObjPolyline.CreateInstance;
      polygonDrawModePentity.pentity^.Closed:=True;
      //drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyObj);
      zcAddEntToCurrentDrawingConstructRoot(polygonDrawModePentity.pentity);
      vertexObj:=CreateVertex(pe.p1.x,pe.p1.y,pe.p1.z);
      for i:=0 to PolygonParam.VNum-1 do begin
        polygonDrawModePentity.pentity^.VertexArrayInOCS.PushBackData(
          vertexObj);
      end;

      //zcUI.TextMessage('---' + inttostr(polygonDrawModePentity.pentity^.VertexArrayInOCS.GetRealCount) + ' - ошибка: ',TMWOHistoryOut);
      InteractivePolygonManipulator(polygonDrawModePentity,pe.p1,False);
      if commandmanager.Get3DPointInteractive(
        rscmSpecifySecondPoint,pe.p2,@InteractivePolygonManipulator,@polygonDrawModePentity)=
        IRNormal then begin
        zcAddEntToCurrentDrawingWithUndo(polygonDrawModePentity.pentity);
        //Добавить объект из конструкторской области в чертеж через ундо//
                {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
        //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
        zcClearCurrentDrawingConstructRoot;
      end;
    end;
  end;
  zcHideCommandParams;
  //< Возвращает инспектор в значение по умолчанию
  Result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);

  if SysUnit<>nil then begin
    SysUnit.RegisterType(TypeInfo(TPolygonParam));
    //регистрируем тип данных в зкадном RTTI
    SysUnit.SetTypeDesk(TypeInfo(TPolygonParam),['ET','VNum','PolyWidth'],[FNProgram]);
    //Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
    SysUnit.SetTypeDesk(TypeInfo(TPolygonParam),
      ['Entity type','Number of vertices','Polyline width'],[FNUser]);
    //Даем человечьи имена параметрам
    SysUnit.SetTypeDesk(TypeInfo(TRectangEntType),['3DPoly','LWPoly'],[FNUser]);
    //Даем человечьи имена параметрам
  end;

  CreateZCADCommand(@DrawPolygon_com,'Polygon',CADWG,0);

  PolygonParam.ET:=RET_3DPoly;
  PolygonParam.PolyWidth:=0;
  PolygonParam.VNum:=4;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
