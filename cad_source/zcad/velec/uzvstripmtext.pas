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
@author(Vladimir Bobrov)
}
{$mode objfpc}

unit uzvstripmtext;
{$INCLUDE def.inc}

interface
uses

   sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, //uzcfblockinsert,
   uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия


  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния
  uzeenttext,             //unit describes line entity
                       //модуль описывающий примитив текст
  uzeentmtext,

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,
  uzbgeomtypes,


  gvector,garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,
  uzeentitiesmanager,

  uzcshared,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
  uzbtypesbase,uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzedrawingsimple,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzclog,                //log system
                      //<**система логирования
  uzcvariablesutils, // для работы с ртти

   gzctnrvectortypes,                  //itrec

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,

  uzvcom,
  uzccombase,
  RegExpr;


implementation

//**Очистка текста на чертеже
function stripMtext_com(operands:TCommandOperands):TCommandResult;
var

  pobj: PGDBObjMText;
  pmtext:PGDBObjMText;
  ir:itrec;
  newText:ansistring;

  UCoperands:string;
  function clearText(a:ansistring):ansistring;
    var
      re: TRegExpr;
    begin
       clearText:=a;
       re := TRegExpr.Create;
       re.Expression := '(\\P)';
       clearText:= re.Replace(clearText, '#nachaloNovoyStroki#', false);
       //HistoryOutStr(clearText);

       re.Expression := '(\\{)';
       clearText:= re.Replace(clearText, '#figurSkobkaOtkr#', false);
       //HistoryOutStr(clearText);

       re.Expression := '(\\})';
       clearText:= re.Replace(clearText, '#figurSkobkaZakr#', false);
       //HistoryOutStr(clearText);

       re.Expression := '(\\\\)';
       clearText:= re.Replace(clearText, '#levoeNaklonnayCherta#', false);
       //HistoryOutStr(clearText);

       re.Expression := '\\[^\\]*?;';
       clearText:= re.Replace(clearText, '', false);
       //HistoryOutStr(clearText);

       re.Expression := '[\\][\\]';
       clearText:= re.Replace(clearText, '\', false);
       //HistoryOutStr(clearText);

       re.Expression := '[{}]';
       clearText:= re.Replace(clearText, '', false);
       //HistoryOutStr(clearText);

       re.Expression := '(\\(L|O))';
       clearText:= re.Replace(clearText, '', false);
       //HistoryOutStr(clearText);

       re.Expression := '(#figurSkobkaOtkr#)';
       clearText:= re.Replace(clearText, '\{', false);
       //HistoryOutStr(clearText);

       re.Expression := '(#figurSkobkaZakr#)';
       clearText:= re.Replace(clearText, '\}', false);
       //HistoryOutStr(clearText);

       re.Expression := '(#nachaloNovoyStroki#)';
       clearText:= re.Replace(clearText, '\P', false);
       //HistoryOutStr(clearText);

       re.Expression := '(#levoeNaklonnayCherta#)';
       clearText:= re.Replace(clearText, '\\\\', false);
       //HistoryOutStr(clearText);

       re.free;
    end;
begin

  UCoperands:=uppercase(operands);

   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
           if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
           begin
                 if UCoperands='ALL' then
                 begin
                      pmtext:=PGDBObjMText(pobj);
                      newText:=clearText(pmtext^.Template);

                      pmtext^.Template:=newText;
                      pmtext^.Content:=newText;
                 end
                 else
                 if pobj^.selected then
                   begin
                      pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
                      pmtext:=PGDBObjMText(pobj);
                      newText:=clearText(pmtext^.Template);

                      pmtext^.Template:=newText;
                      pmtext^.Content:=newText;
                   end;
               end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

    Regen_com(EmptyCommandOperands);   //выполнитть регенирацию всего листа

end;

initialization
  CreateCommandFastObjectPlugin(@stripMtext_com,'stripmtext',CADWG,0);
end.

