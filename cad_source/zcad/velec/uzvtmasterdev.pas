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
@author(Vladimir Bobrov)
}
{$mode objfpc}{$H+}

unit uzvtmasterdev;
{$INCLUDE zengineconfig.inc}

interface
uses

  sysutils,

  uzeentmtext,
  //
  //uzeconsts, //base constants
             //описания базовых констант
  //uzccommandsabstract,
  //uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  //uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  //gzctnrVectorTypes,

    gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

    //для работы графа
  //ExtType,
  //Pointerv,
  Graphs,
  AttrType,
  //AttrSet,
  //*

  RegExpr;

//const
//  isDev='isDev'

type

TVectorOfInteger=specialize TVector<integer>;

PTDevConnectMethod=^TDevConnectMethod;
 TDevConnectMethod=(
              TDT_CableConnectParallel(*'Параллельно'*),
              TDT_CableConnectSeries(*'Последовательно'*)
             );

//** Создания класса головного устройства
TMasterDevice=class
   type
      //**Создания групп у головного устройства
      TGroupInfo=class
         type
          PTdevConnectInfo=^TdevConnectInfo;
          TdevConnectInfo=record
              HeadDeviceName:string;             //Имя головного устройства. Прокладка кабеля
              ControlUnitName:string;      //Имя контрольного узла. Прокладка кабеля
              NGHeadDevice:string;             //Имя группы подключения. Прокладка кабеля
              SLTypeagen:string;               //Имя суперлинии по которой ведется прокладка. Прокладка кабеля
              NGControlUnit:string;            //Номер группы у узла управлени
              DevConnectMethod:TDevConnectMethod;         //Метод монтажа данной группы
              CabConnectAddLength:double;      //Добавочное количество кабеля к данному подключению
              CabConnectMountingMethod:string; //Метод прокладки кабеля для подключения устройства
              CableName:string; //Желаемое имя кабеля
              numConnect:integer;               //номер подключения
          end;
          PTInfoSubDev=^TInfoSubDev;
          TInfoSubDev=record
              indexMaster:integer;         //номер головного устройства
              indexSub:integer;            //номер подключаемого устройства
              isVertexAdded:boolean;       //Добавлена ли эта вершина в граф
              devConnectInfo:TdevConnectInfo;
              //headName:string;             //Имя головного устройства. Прокладка кабеля
              //controlUnitName:string;      //Имя контрольного узла. Прокладка кабеля
              //GroupNum:string;             //Имя группы подключения. Прокладка кабеля
              //typeSLine:string;            //Имя суперлинии по которой ведется прокладка. Прокладка кабеля
          end;
          TVectorOfSubDev=specialize TVector<TInfoSubDev>;
          //**Дерево устройств
          TVectorOfTreeDev=specialize TVector<TGraph>;
        var

           //список движения пути по вершинам и сбор информации по подключенным устройствам
           //listVertexWayGroup:TListVertexSubGraph;
           //listVertexWayOnlyVertex:TListVertexWayOnlyVertex;
           //listVertexTerminalBox:TListVertexTerminalBox; // список распред коробки, в каких вершинах и сколько кабелей
           LNumSubDevice:TVectorOfSubDev;
           LTreeDev:TVectorOfTreeDev; //список элементов одной группы ; (новый метод)
           AllTreeDev:TGraph; //все разодранные элементы одной группы в одном дереве; (новый метод)
           groupTreeDev:TGraph; //дерево оформляемое по новому для каждой группы свое
           LEasyTreeDev:TVectorOfTreeDev;
           name:String;

           //function getIndexEdge(vt1,vt2:Tvertex):integer;
           public
           constructor Create;
           destructor Destroy;override;
      end;
      TVectorOfGroup=specialize TVector<TGroupInfo>;

     var
     LIndex:TVectorOfInteger; //номера устройства в глобальном графе
     name:String;             //полное имя
     shortName:String;        //короткое имя

     LGroup:TVectorOfGroup;   //список отходящих групп

     //function getNumbyName(name:string):integer;
     public
     constructor Create;
     destructor Destroy;override;
end;
TVectorOfMasterDevice=specialize TVector<TMasterDevice>;

implementation



constructor TMasterDevice.Create;
begin
  LGroup:=TVectorOfGroup.Create;
  LIndex:=TVectorOfInteger.Create;
end;
destructor TMasterDevice.Destroy;
begin
  LGroup.Destroy;
  LIndex.Destroy;
end;

constructor TMasterDevice.TGroupInfo.Create;
begin
  LNumSubDevice:=TVectorOfSubDev.Create;
  LTreeDev:=TVectorOfTreeDev.Create;
  LEasyTreeDev:=TVectorOfTreeDev.Create;
end;
destructor TMasterDevice.TGroupInfo.Destroy;
begin
  LNumSubDevice.Destroy;
  LTreeDev.Destroy;
  LEasyTreeDev.Destroy;
end;
//function TMasterDevice.getNumbyName(name:string):integer;
//var
//i:integer;
//begin
//    //self.
//end;
//function TMasterDevice.TGroupInfo.getIndexEdge(vt1,vt2:Tvertex):integer;
//var
//i:integer;
//begin
//    self.LTreeDev;
//end;
//**Очистка текста на чертеже
//function stripMtext_com(operands:TCommandOperands):TCommandResult;
//var
//
//  pobj: PGDBObjMText;
//  pmtext:PGDBObjMText;
//  ir:itrec;
//  newText:ansistring;
//
//  UCoperands:string;
//  function clearText(a:ansistring):ansistring;
//    var
//      re: TRegExpr;
//    begin
//       clearText:=a;
//       re := TRegExpr.Create;
//       re.Expression := '(\\P)';
//       clearText:= re.Replace(clearText, '#nachaloNovoyStroki#', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(\\{)';
//       clearText:= re.Replace(clearText, '#figurSkobkaOtkr#', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(\\})';
//       clearText:= re.Replace(clearText, '#figurSkobkaZakr#', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(\\\\)';
//       clearText:= re.Replace(clearText, '#levoeNaklonnayCherta#', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '\\[^\\]*?;';
//       clearText:= re.Replace(clearText, '', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '[\\][\\]';
//       clearText:= re.Replace(clearText, '\', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '[{}]';
//       clearText:= re.Replace(clearText, '', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(\\(L|O))';
//       clearText:= re.Replace(clearText, '', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(#figurSkobkaOtkr#)';
//       clearText:= re.Replace(clearText, '\{', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(#figurSkobkaZakr#)';
//       clearText:= re.Replace(clearText, '\}', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(#nachaloNovoyStroki#)';
//       clearText:= re.Replace(clearText, '\P', false);
//       //HistoryOutStr(clearText);
//
//       re.Expression := '(#levoeNaklonnayCherta#)';
//       clearText:= re.Replace(clearText, '\\\\', false);
//       //HistoryOutStr(clearText);
//
//       re.free;
//    end;
//begin
//
//  UCoperands:=uppercase(operands);
//   if UCoperands='ALL' then
//   begin
//   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
//     if pobj<>nil then
//     repeat                                                   //перебор всех элементов чертежа
//           if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
//           begin
//            pmtext:=PGDBObjMText(pobj);
//            newText:=clearText(pmtext^.Template);
//
//            pmtext^.Template:=newText;
//            pmtext^.Content:=newText;
//           end;
//    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
//    until pobj=nil;
//   end
//   else
//   begin
//     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
//     if pobj<>nil then
//     repeat                                                   //перебор всех элементов чертежа
//       if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
//         if pobj^.selected then
//           begin
//              //pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
//              pmtext:=PGDBObjMText(pobj);
//              newText:=clearText(pmtext^.Template);
//
//              pmtext^.Template:=newText;
//              pmtext^.Content:=newText;
//           end;
//    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
//    until pobj=nil;
//
//    end;
//    Regen_com(EmptyCommandOperands);   //выполнитть регенирацию всего листа
//    result:=cmd_ok;
//end;

//initialization
//  CreateCommandFastObjectPlugin(@stripMtext_com,'stripmtext',CADWG,0);
end.

