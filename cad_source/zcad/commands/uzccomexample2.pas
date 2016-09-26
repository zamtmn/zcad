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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

unit uzccomexample2;
{$INCLUDE def.inc}
interface
uses uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
     uzbtypesbase,       //базовые типы
     uzccommandsmanager, //менеджер команд
     Varman;             //Зкадовский RTTI

type
TExample_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             procedure DoSomething(pdata:GDBPlatformint); virtual;//реализация какогото действия
             procedure DoSomething2(pdata:GDBPlatformint); virtual;//реализация какогото другого действия
            end;
PTExampleComParams=^TExampleComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель
TExampleComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  option1:gdbinteger;
  option2:gdbboolean;
end;

var
 Example_com:TExample_com;//определяем экземпляр нашей команды
 ExampleComParams:TExampleComParams;//определяем экземпляр параметров нашей команды

implementation

procedure TExample_com.CommandStart(Operands:TCommandOperands);
begin
  //создаем командное меню из 2х пунктов
  commandmanager.DMAddMethod('DoSomething','DoSomething hint',DoSomething);
  commandmanager.DMAddMethod('DoSomething2','DoSomething2 hint)',DoSomething2);
  //показываем командное меню
  commandmanager.DMShow;
  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart('');
end;

procedure TExample_com.DoSomething(pdata:GDBPlatformint);
begin
  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
  //если тут не вызывать Commandmanager.executecommandend;
  //то выполнение команды не завершится и кнопку можно жать много раз
  //для примера просто играем параметрами
  inc(ExampleComParams.option1);
  ExampleComParams.option2:=not ExampleComParams.option2;
end;

procedure TExample_com.DoSomething2(pdata:GDBPlatformint);
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  Commandmanager.executecommandend;
end;

initialization
  //начальные значения параметров
  ExampleComParams.option1:=-1;
  ExampleComParams.option2:=false;

  SysUnit.RegisterType(TypeInfo(PTExampleComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TExampleComParams),['Параметр1','Параметр2']);//Даем человечьи имена параметрам
  Example_com.init('ExampleCom',CADWG,0);//инициализируем команду
  Example_com.SetCommandParam(@ExampleComParams,'PTExampleComParams');//привязываем параметры к команде
end.
