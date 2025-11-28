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
  uzestyleslayers,uzbtypes,gzctnrVectorTypes,UGDBSelectedObjArray,
  uzcstrconsts,uzccommandsmanager,uzcdrawings,uzeentity,//uzccominteractivemanipulators,
  uzegeometrytypes,
  uzeentmtext,
  uzegeometry,
  uzcutils,
  uzeentabstracttext,
  uzeentpolyline,uzeentline,
  uzeconsts,
  uzgldrawcontext,
  Varman;

resourcestring
  RSHelloWorld='HELLO WORLD!';


implementation

type
  TCmdProp=record
    props:TEntityUnit;
  end;

var
  CmdProp:TCmdProp;

function ExampleConstructToModalSpace_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
  //Визуализация многострочный текст
  function drawMText(const pt:TzePoint3d;color:integer;rotate:double):PGDBObjMText;
  begin
    Result:=GDBObjMText.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(Result);
    //добавляем дефаултные свойства
    //Result^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle;//добавляет тип стиля текста, дефаултные свойства его не добавляют
    Result^.Local.P_insert:=pt;
    //координата вставки
    Result^.textprop.justify:=jsmc;
    //выравнивание текста
    Result^.Template:=TDXFEntsInternalStringType(RSHelloWorld);
    //Текст незнаю чем они отличаются
    //Result^.Content:=TDXFEntsInternalStringType(RSHelloWorld);          //Текст незнаю чем они отличаются
    //Result^.vp.LineWeight:=LnWt100;                                    //Толщина линии
    //Result^.linespacef:=1;                                             //Межстрочный интервал
    //rotate:=(rotate*pi)/180;                                           //получаем угол из градуса
    //Result^.Local.basis.ox.x:=cos(rotate);                             //поворот по оси икс, почему их два незнаю что то там связоно с отрисовкой
    //Result^.Local.basis.ox.y:=sin(rotate);                             //поворот по оси игрик, почему их два незнаю что то там связоно с отрисовкой
    Result^.vp.Color:=color;
    //Цвет текста
    Result^.textprop.size:=2.5;
    //Высота текста
    zcAddEntToCurrentDrawingConstructRoot(Result);
    //добавляем в конструкторскую область
    //zcAddEntToCurrentDrawingWithUndo(Result);                        //добавляем текст с ундо в пространство модели
  end;

  function drawPolyline(pt1,pt2:TzePoint3d;color:integer):PGDBObjPolyLine;
  begin
    Result:=GDBObjPolyline.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(Result);
    //добавляем дефаултные свойства
    Result^.Closed:=True;
    //полилиния замкнута
    Result^.vp.Color:=color;                                         //Цвет линии
    Result^.vp.LineWeight:=LnWt050;
    //Толщина линии
    Result^.VertexArrayInOCS.PushBackData(pt1);
    Result^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt2.x,pt1.y,0));
    Result^.VertexArrayInOCS.PushBackData(pt2);
    Result^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
    zcAddEntToCurrentDrawingConstructRoot(Result);
    //добавляем в конструкторскую область
    //zcAddEntToCurrentDrawingWithUndo(Result);                      //добавляем полилинию с ундо в пространство модели
  end;

begin

  //работа с инспектором
  CmdProp.props.Free;
  CmdProp.props.InterfaceUses.PushBackIfNotPresent(sysunit);
  with CmdProp.props.CreateVariable('F1_test1','boolean') do begin
    username:='тест1';
    pboolean(Data.Addr.GetInstance)^:=True;
  end;
  with CmdProp.props.CreateVariable('test2','integer') do begin
    username:='тест2';
    pinteger(Data.Addr.GetInstance)^:=123;
  end;
  //CmdProp.props.FindVariable();    //получить доступ к измененной переменной
  zcShowCommandParams(SysUnit^.TypeName2PTD('TCmdProp'),@CmdProp);


  //рисование и перенос из конструкторской обласи в область чертежа
  {pt:=}drawMText(NulVertex,2,0);
  //Рисуем текст, и полилинию
  {pp:=}drawPolyline(uzegeometry.CreateVertex(-20,+5,0),
    uzegeometry.CreateVertex(+20,-5,0),3);
  if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=GRNormal then
    //двигаем их
    zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace');
  //если все ок, копируем в чертеж
  Result:=cmd_ok;
end;

function ExampleRandomizeLines_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
const
  ldelta=1000;
  ldelta2=2000;
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count:integer;
  domethod,undomethod:tmethod;
  psd:PSelectedObjDesc;
  rc:TDrawContext;
begin
  rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
    repeat
      pv:=psd^.objaddr;
      if pv^.GetObjType=GDBLineID then begin
        PGDBObjLine(pv)^.CoordInOCS.lBegin.x:=
          PGDBObjLine(pv)^.CoordInOCS.lBegin.x+ldelta-ldelta2*random;
        PGDBObjLine(pv)^.CoordInOCS.lBegin.y:=
          PGDBObjLine(pv)^.CoordInOCS.lBegin.y+ldelta-ldelta2*random;
        PGDBObjLine(pv)^.CoordInOCS.lEnd.x:=
          PGDBObjLine(pv)^.CoordInOCS.lEnd.x+ldelta-ldelta2*random;
        PGDBObjLine(pv)^.CoordInOCS.lEnd.y:=
          PGDBObjLine(pv)^.CoordInOCS.lEnd.y+ldelta-ldelta2*random;
        PGDBObjLine(pv)^.FormatAfterEdit(drawings.GetCurrentDWG^,rc);
      end;
      psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
    until psd=nil;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TCmdProp));
    SysUnit^.SetTypeDesk(TypeInfo(TCmdProp),['параметры']);
  end;
  CmdProp.props.init('test');
  CreateZCADCommand(@ExampleConstructToModalSpace_com,
    'ExampleConstructToModalSpace',CADWG,0);
  CreateZCADCommand(@ExampleRandomizeLines_com,'ExampleRandomizeLines',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  CmdProp.props.Free;
  CmdProp.props.done;
end.
