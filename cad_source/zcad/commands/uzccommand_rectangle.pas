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
unit uzccommand_rectangle;

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
  //uzbtypes,
  uzegeometry,
  uzccommand_polygon,
  URecordDescriptor,typedescriptors,Varman,varmandef;

type
  //** Тип данных для отображения в инспекторе опций команды Rectangle
  TRectangParam=record
    ET:TRectangEntType;
    (*'Entity type'*)
    //**< Выбор типа примитива, которым будет создан прямоугольник - 3Dolyline или LWPolyline
    //VNum:Integer;(*'Number of vertices'*)  //**< Определение количества вершин
    PolyWidth:double;
    (*'Polyline width'*)
    //**< Ширина полилинии (если в качестве примитива выбран RET_LWPoly)
  end;

function InteractiveDrawRectangle(const Context:TZCADCommandContext;
  APrompt1,APrompt2:string;ESP:TEntitySetupProc):TCommandResult;

implementation

var
  RectangParam:TRectangParam;
  //**< Переменная содержащая опции команды Rectangle

function InteractiveDrawRectangle(const Context:TZCADCommandContext;
  APrompt1,APrompt2:string;ESP:TEntitySetupProc):TCommandResult;    //< Чертим прямоугольник
var
  vertexLWObj:TzePoint2d;
  //переменная для добавления вершин в полилинию
  vertexObj:TzePoint3d;
  widthObj:GLLWWidth;
  //переменная для добавления веса линии в начале и конце пути
  polyLWObj:PGDBObjLWPolyline;
  polyObj:PGDBObjPolyline;
  pe:T3PointPentity;
  PInternalRTTITypeDesk:PRecordDescriptor;
  //**< Доступ к панели упр в инспекторе
  pf:PfieldDescriptor;
  //**< Управление нашей панелью в инспекторе
  CommandParamsShowed:boolean;
begin
  if not (assigned(ESP) and ESP(ESSSuppressCommandParams,nil))then begin
    PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD('TRectangParam'));
    //находим описание типа TRectangParam, мы сразу знаем что это описание записи, поэтому нужно привести тип
    pf:=PInternalRTTITypeDesk^.FindField('ET');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes-[fldaReadOnly];
    //сбрасываем ему флаг ридонли
    pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
    //находим описание поля ET
    //pf^.base.Attributes:=pf^.base.Attributes and (not fldaReadOnly);//сбрасываем ему флаг ридонли
    //pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
    //pf^.base.Attributes:=pf^.base.Attributes or fldaHidden;//устанавливаем ему флаг cкрытности
    //pf^.base.Attributes:=pf^.base.Attributes and (not fldaReadOnly);//сбрасываем ему флаг ридонли
    zcShowCommandParams(PInternalRTTITypeDesk,@RectangParam);
    CommandParamsShowed:=true;
  end else
    CommandParamsShowed:=false;

  if commandmanager.get3dpoint(APrompt1,pe.p1)=GRNormal then begin
    pf:=PInternalRTTITypeDesk^.FindField('ET');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
    //устанавливаем ему флаг ридонли
    pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
    //находим описание поля ET
    pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
    //устанавливаем ему флаг ридонли

    //Создаем сразу 4-е точки прямоугольника, что бы в манипуляторе только управльть их координатами
    widthObj.endw:=RectangParam.PolyWidth;
    widthObj.startw:=RectangParam.PolyWidth;
    if RectangParam.ET=RET_LWPoly then begin
      polyLWObj:=GDBObjLWPolyline.CreateInstance;
      polyLWObj^.Closed:=True;
      //drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyLWObj);//было, теперь стало, не @указатель, а просто указатель
      zcAddEntToCurrentDrawingConstructRoot(polyLWObj);
      vertexLWObj.x:=pe.p1.x;
      vertexLWObj.y:=pe.p1.y;
      polyLWObj^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
      polyLWObj^.Width2D_in_OCS_Array.PushBackData(widthObj);

      polyLWObj^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
      polyLWObj^.Width2D_in_OCS_Array.PushBackData(widthObj);

      polyLWObj^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
      polyLWObj^.Width2D_in_OCS_Array.PushBackData(widthObj);

      polyLWObj^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
      polyLWObj^.Width2D_in_OCS_Array.PushBackData(widthObj);

      InteractiveLWRectangleManipulator(polyLWObj,pe.p1,False);
      if commandmanager.Get3DPointInteractive(
        APrompt2,pe.p2,@InteractiveLWRectangleManipulator,polyLWObj)=GRNormal then
      begin
        if assigned(ESP) then
          ESP(ESSSetEntity,polyLWObj);
        zcAddEntToCurrentDrawingWithUndo(polyLWObj);
        //Добавить объект из конструкторской области в чертеж через ундо//
                  {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                  нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
        //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
        zcClearCurrentDrawingConstructRoot;
      end;
    end else begin
      polyObj:=GDBObjPolyline.CreateInstance;
      polyObj^.Closed:=True;
      //drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyObj);
      zcAddEntToCurrentDrawingConstructRoot(polyObj);
      vertexObj:=pe.p1;
      polyObj^.VertexArrayInOCS.PushBackData(vertexObj);
      polyObj^.VertexArrayInOCS.PushBackData(vertexObj);
      polyObj^.VertexArrayInOCS.PushBackData(vertexObj);
      polyObj^.VertexArrayInOCS.PushBackData(vertexObj);
      InteractiveRectangleManipulator(polyObj,pe.p1,False);
      if commandmanager.Get3DPointInteractive(
        rscmSpecifySecondPoint,pe.p2,@InteractiveRectangleManipulator,polyObj)=GRNormal then
      begin
        zcAddEntToCurrentDrawingWithUndo(polyObj);
        //Добавить объект из конструкторской области в чертеж через ундо//
                  {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                  нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
        //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
        zcClearCurrentDrawingConstructRoot;
      end;
    end;
  end;
  //< Возвращает инспектор в значение по умолчанию
  //< если показ команды не был подавлен
  if CommandParamsShowed then
    zcHideCommandParams;
  if assigned(ESP) then
    ESP(ESSCommandEnd,nil);
  Result:=cmd_ok;
end;

function DrawRectangle_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  Result:=InteractiveDrawRectangle(Context,rscmSpecifyFirstPoint,rscmSpecifySecondPoint,nil);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit.RegisterType(TypeInfo(TRectangParam));
    //регистрируем тип данных в зкадном RTTI
    SysUnit.SetTypeDesk(TypeInfo(TRectangParam),['ET','PolyWidth'],[FNProgram]);
    //Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
    SysUnit.SetTypeDesk(TypeInfo(TRectangParam),
      ['Entity type','Polyline width'],[FNUser]);
    //Даем человечьи имена параметрам
  end;

  CreateZCADCommand(@DrawRectangle_com,'Rectangle',CADWG,0);
  RectangParam.ET:=RET_3DPoly;
  RectangParam.PolyWidth:=0;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
