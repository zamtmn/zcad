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
{$mode delphi}
unit uzccommand_exampleinsertdevice;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentdevice,uzgldrawcontext,uzegeometrytypes,
  uzccommandsmanager,uzcdrawings,uzeentityfactory,uzeconsts,uzcutils;

implementation

function ExampleInsertDevice_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pdev:PGDBObjDevice;
    p1:gdbvertex;
    rc:TDrawContext;
begin
    if commandmanager.get3dpoint('Specify insert point:',p1)=GRNormal then
    begin
      //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
      //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
      //создаем примитив
      pdev:=AllocEnt(GDBDeviceID);
      pdev^.init(nil,nil,0);
      //настраивает
      pdev.Name:='PS_DAT_SMOKE';
      pdev^.Local.P_insert:=p1;
      //строим переменную часть примитива (та что может редактироваться)
      pdev.BuildVarGeometry(drawings.GetCurrentDWG^);
      //строим постоянную часть примитива
      pdev.BuildGeometry(drawings.GetCurrentDWG^);
      //"форматируем"
      rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      pdev.FormatEntity(drawings.GetCurrentDWG^,rc);
      //дальше как обычно
      zcSetEntPropFromCurrentDrawingProp(pdev);
      zcAddEntToCurrentDrawingWithUndo(pdev);
      zcRedrawCurrentDrawing;
    end;
    result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ExampleInsertDevice_com,'ExampleInsertDevice',   CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
