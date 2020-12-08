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
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{$mode delphi}
unit uzccommand_exampleinsertdevice;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentdevice,uzgldrawcontext,uzbgeomtypes,
  uzccommandsmanager,uzcdrawings,uzeentityfactory,uzeconsts,uzcutils;

implementation

function ExampleInsertDevice_com(operands:TCommandOperands):TCommandResult;
var
    pdev:PGDBObjDevice;
    p1:gdbvertex;
    rc:TDrawContext;
begin
    if commandmanager.get3dpoint('Specify insert point:',p1) then
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ExampleInsertDevice_com,'ExampleInsertDevice',   CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
