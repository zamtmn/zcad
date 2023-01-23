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
unit uzccommand_exampleconstructtomodalspace;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzestyleslayers,uzbtypes,
  uzcstrconsts,uzccommandsmanager,uzcdrawings,uzeentity,uzccominteractivemanipulators,
  uzegeometrytypes,
  uzeentmtext,
  uzegeometry,
  uzcutils,
  uzeentabstracttext,
  uzeentpolyline,uzeconsts;

implementation

function ExampleConstructToModalSpace_com(operands:TCommandOperands):TCommandResult;
var
    pe:T3PointPentity;
const
    createMText='HELLO WORLD!';

//Визуализация многострочный текст
procedure drawMText(pt:GDBVertex;color:integer;rotate:double);
var
    pmtext:PGDBObjMText;
begin
    pmtext := GDBObjMText.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(pmtext); //добавляем дефаултные свойства
    pmtext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют

    pmtext^.Local.P_insert:=pt;                                         //координата вставки
    pmtext^.textprop.justify:=jsmc;                                     //выравнивание текста
    pmtext^.Template:=TDXFEntsInternalStringType(createMText);               //Текст незнаю чем они отличаются
    pmtext^.Content:=TDXFEntsInternalStringType(createMText);                //Текст незнаю чем они отличаются
    pmtext^.vp.LineWeight:=LnWt100;                                     //Толщина линии
    pmtext^.linespacef:=1;                                              //Межстрочный интервал
    rotate:=(rotate*pi)/180;                                            //получаем угол из градуса
    pmtext^.Local.basis.ox.x:=cos(rotate);                                    //поворот по оси икс, почему их два незнаю что то там связоно с отрисовкой
    pmtext^.Local.basis.ox.y:=sin(rotate);                                    //поворот по оси игрик, почему их два незнаю что то там связоно с отрисовкой
    pmtext^.vp.Color:=color;                                            //Цвет текста
    pmtext^.textprop.size:=2.5;                                         //Высота текста
    //zcAddEntToCurrentDrawingConstructRoot(pmtext);                    //добавляем в конструкторскую область
    zcAddEntToCurrentDrawingWithUndo(pmtext);                           //добавляем текст с ундо в пространство модели
end;

//Визуализация полилинии
procedure drawPolyline(pt1,pt2:GDBVertex;color:integer);
var
    polyObj:PGDBObjPolyLine;
begin
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);                         //добавляем дефаултные свойства
     polyObj^.Closed:=true;                                               //полилиния замкнута
     polyObj^.vp.Color:=color;                                            //Цвет линии
     polyObj^.vp.LineWeight:=LnWt050;                                     //Толщина линии
     polyObj^.VertexArrayInOCS.PushBackData(pt1);
     polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt2.x,pt1.y,0));
     polyObj^.VertexArrayInOCS.PushBackData(pt2);
     polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
     //zcAddEntToCurrentDrawingConstructRoot(polyObj);                    //добавляем в конструкторскую область
     zcAddEntToCurrentDrawingWithUndo(polyObj);                           //добавляем полилинию с ундо в пространство модели
end;

begin
    if commandmanager.get3dpoint(rscmSpecifyFirstPoint,pe.p1)=GRNormal then   //Получаем координату ЛКМ-клик
    begin
       drawMText(pe.p1,2,0);                                                  //Рисуем текст
       drawPolyline(uzegeometry.CreateVertex(pe.p1.x-20,pe.p1.y+5,0),uzegeometry.CreateVertex(pe.p1.x+20,pe.p1.y-5,0),3)
    end;
    result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandFastObjectPlugin(@ExampleConstructToModalSpace_com,'ExampleConstructToModalSpace',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
