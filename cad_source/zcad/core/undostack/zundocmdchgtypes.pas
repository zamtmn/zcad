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
{$MODE OBJFPC}{$H+}
{$ModeSwitch advancedrecords}
{$INCLUDE zengineconfig.inc}
unit zUndoCmdChgTypes;
interface
uses
  zeundostack,zebaseundocommands,uzeentity,uzsbVarmanDef,
  uzcEnitiesVariablesExtender,gzUndoCmdChgData2,uzedrawingdef,
  uzestyleslayers,uzbBaseUtils,uzeExtdrAbstractEntityExtender,
  uzeExtdrBaseEntityExtender;

type
  TEmpty=record
    {todo: убрать после выхода нового fpc}
    {3.2.2 компилятор виснет с пустой записью}
    {$IF FPC_FULlVERSION<=30202}Dummy:Integer;{$ENDIF}
  end;
  TSharedEmpty=specialize GSharedData<TEmpty>;
  TAfterChangeDoNothing=class;
  TAfterChangeEmpty=specialize GAfterChangeData<TEmpty,TSharedEmpty,TAfterChangeDoNothing>;

  TSharedPEntityData=specialize GSharedData<PGDBObjEntity>;
  TAfterEntChangeDo=class;
  TAfterChangePDrawing=specialize GAfterChangeData<PTDrawingDef,TSharedPEntityData,TAfterEntChangeDo>;
  TAfterEntChangeDo=class
    class procedure AfterDo(SD:TSharedPEntityData;ADD:TAfterChangePDrawing);
  end;



  TAfterChangeDoNothing=class
    class procedure AfterDo(SD:TSharedEmpty;ADD:TAfterChangeEmpty);
  end;

implementation

class procedure TAfterEntChangeDo.AfterDo(SD:TSharedPEntityData;ADD:TAfterChangePDrawing);
begin
  if IsObjectIt(typeof(SD.Data^),typeof(GDBObjEntity)) then
    SD.Data^.YouChanged(ADD.Data^)
  else if TBaseEntityExtender(SD.Data) is TBaseEntityExtender then
    TBaseEntityExtender(SD.Data).pThisEntity^.YouChanged(ADD.Data^);
end;

class procedure TAfterChangeDoNothing.AfterDo(SD:TSharedEmpty;ADD:TAfterChangeEmpty);
begin
end;

end.
