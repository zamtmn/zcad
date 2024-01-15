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
{**
@author(Vladimir Bobrov)
}

unit uzvmanemcom;
{$INCLUDE zengineconfig.inc}
interface
uses uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
            //базовые типы
     uzccommandsmanager, //менеджер команд
     uzeentpolyline,
     uzcinterface,
     sysutils,
     uzegeometrytypes,
     uzegeometry,
     uzvmanemparams, //вынесенные параметры
     uzvmanemgetgem,
     uzvagraphsdev,

     //UGDBSelectedObjArray,

     //uzcutils,
     Varman;             //Зкадовский RTTI

type
Tuzvmanem_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure repeatEMShema(pdata:PtrInt); virtual; //Повторяет электрическую модель. Понимание того как программа видит электрическую модель

            end;

var
 uzvmanem_com:Tuzvmanem_com; //определяем экземпляр нашей команды


implementation
//uses
      //uzvagsl;
var
 listFullGraphEM:TListGraphDev;     //Граф со всем чем можно


procedure Tuzvmanem_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  //создаем командное меню из 3х пунктов
  commandmanager.DMAddMethod('Повторить эл.модель','Повторяет электрическую модель. Понимание того как программа видит электрическую модель',repeatEMShema);

  //показываем командное меню
  commandmanager.DMShow;

    //Получить список всех древовидно ориентированных графов из которых состоит модель
  listFullGraphEM:=TListGraphDev.Create;
  listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;

  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart(context,'');
end;

procedure Tuzvmanem_com.repeatEMShema(pdata:PtrInt);
var
 depthVisual:double;
 insertCoordination:GDBVertex;
 graphDev:TGraphDev;
 listStructurGraphEM:TListGraphDev; //граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки
begin
   depthVisual:=15;
   insertCoordination:=uzegeometry.CreateVertex(0,0,0);

   //получаем структурированный граф (граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки)
   listStructurGraphEM:=uzvmanemgetgem.getListStructurGraphEM(listFullGraphEM);

   if uzvmanemComParams.sortGraph then
     uzvmanemgetgem.sortSumChildListGraph(listStructurGraphEM);

   //for graphDev in listFullGraphEM do
   //if uzvmanemComParams.sortGraph then
   for graphDev in listStructurGraphEM do
   begin
      visualGraphTree(graphDev,insertCoordination,3,depthVisual);
   end;
   //else
   //for graphDev in listFullGraphEM do
   //begin
   //   visualGraphTree(graphDev,insertCoordination,3,depthVisual);
   //end;

   Commandmanager.executecommandend;

end;


initialization
  //начальные значения параметров
  //uzvagslComParams.InverseX:=false;
  //uzvagslComParams.InverseY:=true;
  //uzvagslComParams.BaseName:='BTH';
  //uzvagslComParams.DeadDand:=10;
  //uzvagslComParams.NumberVar:='GC_NumberInGroup';
  uzvmanemComParams.sortGraph:=true;
  uzvmanemComParams.settingRepeatEMShema.vizStructureGraphEM:=false; // визуализировать полный граф
  uzvmanemComParams.settingRepeatEMShema.beforeGraphEMSort:=true;    // отсортировать перед отрисовкой

  SysUnit.RegisterType(TypeInfo(PTuzvmanemComParams));//регистрируем тип данных в зкадном RTTI

  SysUnit.SetTypeDesk(TypeInfo(TsettingRepeatEMShema),['Виз.структур граф','Сорт.перед виз']);                                    //Даем человечьи имена параметрам
  SysUnit.SetTypeDesk(TypeInfo(TuzvmanemComParams),['Имя суперлинии','Погрешность','Параметр2','Сортировать граф','Настройки повторить эл.модель']);//Даем человечьи имена параметрам
  uzvmanem_com.init('manem',CADWG,0);//инициализируем команду
  uzvmanem_com.SetCommandParam(@uzvmanemComParams,'PTuzvmanemComParams');//привязываем параметры к команде
end.
