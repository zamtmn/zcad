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
unit uzccommand_examplecreatelayer;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzestyleslayers,uzbtypes,
  uzcstrconsts,uzccommandsmanager,uzcdrawings,uzeentity,uzeconsts;

implementation

function ExampleCreateLayer_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pproglayer:PGDBLayerProp;
    pnevlayer:PGDBLayerProp;
    pe:PGDBObjEntity;
const
    createdlayername='hohoho';
begin
    if commandmanager.getentity(rscmSelectSourceEntity,pe) then
    begin
      pproglayer:=BlockBaseDWG.LayerTable.getAddres(createdlayername);//ищем описание слоя в библиотеке
                                                                      //возможно оно найдется, а возможно вернется nil
      pnevlayer:=drawings.GetCurrentDWG.LayerTable.createlayerifneedbyname(createdlayername,pproglayer);//эта процедура сначала ищет описание слоя в чертеже
                                                                                                        //если нашла - возвращает его
                                                                                                        //не нашла, если pproglayer не nil - создает такойде слой в чертеже
                                                                                                        //и только если слой в чертеже не найден pproglayer=nil то возвращает nil
      if pnevlayer=nil then //предидущие попытки обламались. в чертеже и в библиотеке слоя нет, тогда создаем новый
        pnevlayer:=drawings.GetCurrentDWG.LayerTable.addlayer(createdlayername{имя},ClWhite{цвет},-1{вес},true{on},false{lock},true{print},'???'{описание},TLOLoad{режим создания - в данном случае неважен});
      pe^.vp.Layer:=pnevlayer;
    end;
    result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ExampleCreateLayer_com,'ExampleCreateLayer',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
