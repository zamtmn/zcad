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

unit uzcRegFeatures;
{$INCLUDE zengineconfig.inc}

interface

uses uzcsysvars,
     uzcinterface,uzedrawingsimple,uzcdrawings,uzccommandsmanager;

implementation

type

  TDummy=class
    class procedure AutoSaveIdleHandler(var Done:boolean);
  end;


class procedure TDummy.AutoSaveIdleHandler(var Done:boolean);
var
  pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
    if (not pdwg^.GetChangeStampt)or(pdwg.wa=nil) then
      SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;

  if(SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and(commandmanager.CurrCmd.pcommandrunning=nil)then
    if pdwg<>nil then
      if (pdwg.wa.param.SelDesc.Selectedobjcount=0) then begin
        commandmanager.executecommandsilent('QSave(QS)',drawings.GetCurrentDWG,
          drawings.GetCurrentOGLWParam);
        SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
      end;
end;

initialization
  zcUI.RegisterHandlerIdle(TDummy.AutoSaveIdleHandler);

finalization
end.

