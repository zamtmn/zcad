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
     //uzvnum,
     //uzvagensl,


     //UGDBSelectedObjArray,

     //uzcutils,
     Varman;             //Зкадовский RTTI

type
Tuzvmanem_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure repeatEMShema(pdata:PtrInt); virtual; //Повторяет электрическую модель. Понимание того как программа видит электрическую модель

            end;

var
 uzvmanem_com:Tuzvmanem_com; //определяем экземпляр нашей команды


implementation
//uses
      //uzvagsl;
procedure Tuzvmanem_com.CommandStart(Operands:TCommandOperands);
begin
  //создаем командное меню из 3х пунктов
  commandmanager.DMAddMethod('Повторить эл.модель','Повторяет электрическую модель. Понимание того как программа видит электрическую модель',repeatEMShema);

  //показываем командное меню
  commandmanager.DMShow;
  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart('');
end;

procedure Tuzvmanem_com.repeatEMShema(pdata:PtrInt);
var
 //contourRoom:PGDBObjPolyLine;
 //listDeviceinRoom:TListVertexDevice;
 listGraphEM:TListGraphDev;
 stPoint:gdbvertex;
begin
  stPoint:=uzegeometry.CreateVertex(0,0,0);

  //Получить список всех древовидно ориентированных графов из которых состоит модель
  listGraphEM:=uzvmanemgetgem.getListGrapghEM;


  ////if commandmanager.get3dpoint('Specify insert point:',stPoint)= GRNormal then
  ////     ZCMsgCallBackInterface.TextMessage('координата введена',TMWOHistoryOut)
  ////   else
  ////     ZCMsgCallBackInterface.TextMessage('координаты НЕТ',TMWOHistoryOut);
  //
  // if uzvagsl.getContourRoom(contourRoom) then                  // получить контур помещения
  //    if uzvagsl.isRectangelRoom(contourRoom) then begin        //это прямоугольная комната?
  //       ZCMsgCallBackInterface.TextMessage('проверки пройдены',TMWOHistoryOut);
  //       // if mainElementAutoEmbedSL(contourRoom,contourRoomEmbedSL) then  begin
  //       //  listDeviceinRoom:=uzvagsl.getListDeviceinRoom(contourRoom);  //получен список извещателей внутри помещения
  //       //  ZCMsgCallBackInterface.TextMessage('Количество выделяных извещателей = ' + inttostr(listDeviceinRoom.Size));
  //       //end;
  //       //uzvagsl.autoNumberDevice(uzvagslComParams);
  // end;
   Commandmanager.executecommandend;

end;


initialization
  //начальные значения параметров
  //uzvagslComParams.InverseX:=false;
  //uzvagslComParams.InverseY:=true;
  //uzvagslComParams.BaseName:='BTH';
  //uzvagslComParams.DeadDand:=10;
  //uzvagslComParams.NumberVar:='GC_NumberInGroup';
  //uzvagslComParams.option2:=false;


  SysUnit.RegisterType(TypeInfo(PTuzvmanemComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TuzvmanemComParams),['Имя суперлинии','Погрешность','Параметр2']);//Даем человечьи имена параметрам
  uzvmanem_com.init('manem',CADWG,0);//инициализируем команду
  uzvmanem_com.SetCommandParam(@uzvmanemComParams,'PTuzvmanemComParams');//привязываем параметры к команде
end.
