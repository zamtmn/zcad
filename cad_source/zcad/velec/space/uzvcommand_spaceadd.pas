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
{$mode delphi}

{**Модуль реализации команды spaceadd для добавления пространств с расширениями}
unit uzvcommand_spaceadd;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,               // String utilities / Утилиты для работы со строками
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcdrawings,
  uzcEnitiesVariablesExtender,
  uzcExtdrIncludingVolume,
  uzccommand_rectangle,
  uzcinterface,           // Interface utilities / Утилиты интерфейса
  uzbtypes,
  varmandef,              // Variable manager definitions / Определения менеджера переменных
  uzestyleslayers,
  uzeconsts,
  uzeentlwpolyline,
  uzeentpolyline,
  uzvcommand_spaceutils;  // Space utilities with shared structures / Утилиты для команд пространств


function AddExtdrToRectangle(
  const AStage: TEntitySetupStage;
  const APEnt: PGDBObjEntity): boolean;




implementation

{**Функция добавления расширений к прямоугольнику на разных стадиях настройки
   Использует глобальную структуру gOperandsStruct для получения параметров.
   @param(AStage - стадия настройки примитива)
   @param(APEnt - указатель на примитив)
   @return(true если обработка успешна)}
function AddExtdrToRectangle(
  const AStage: TEntitySetupStage;
  const APEnt: PGDBObjEntity): boolean;
var
  pLayer: PGDBLayerProp;
begin
  case AStage of
    ESSSuppressCommandParams:
      result := false;

    ESSSetEntity: begin
      if APEnt <> nil then begin
        // Добавляем расширение extdrVariables для хранения переменных
        // Add extdrVariables extension for storing variables
        AddVariablesToEntity(APEnt);

        // Добавляем расширение extdrIncludingVolume для работы с объемом
        // Add extdrIncludingVolume extension for volume operations
        AddVolumeExtenderToEntity(APEnt);

        // Добавляем переменные из структуры операндов
        // Add variables from operands structure
        AddVariablesFromStruct(APEnt, gOperandsStruct);

        // Устанавливаем слой если указан в структуре
        // Set layer if specified in structure
        if gOperandsStruct.namelayer <> '' then begin
          pLayer := GetOrCreateLayer(
            gOperandsStruct.namelayer,
            gOperandsStruct.indexColor
          );

          if pLayer <> nil then
            APEnt^.vp.Layer := pLayer;
        end;

        // Устанавливаем цвет примитива из структуры
        // Set entity color from structure
        APEnt^.vp.Color := gOperandsStruct.indexColor;
        APEnt^.vp.LineWeight := LnWtByLayer;
        if  APEnt^.GetObjType = GDBPolyLineID then
        PGDBObjPolyline(APEnt).Closed:=True;
        //if  APEnt^.GetObjType = GDBLWPolyLineID then
        //PGDBObjLWPolyline(APEnt).Closed:=True;

        result := true;
      end else
        result := False;
    end;
    
    ESSSetConstructEntity:
      begin
        APEnt^.vp.Color := gOperandsStruct.indexColor;
        APEnt^.vp.LineWeight := LnWt200;
        if  APEnt^.GetObjType = GDBPolyLineID then
        PGDBObjPolyline(APEnt).Closed:=True;
        //APEnt^.Closed:=True;
        result:=False;

      end;
    ESSCommandEnd: begin
      // Очищаем структуру операндов после завершения команды
      // Clear operands structure after command ends
      if gOperandsStruct.listParam <> nil then
        gOperandsStruct.listParam.Clear;
      gOperandsStruct.indexColor := 256;  // ByLayer
      gOperandsStruct.namelayer := '';
      //APEnt^.vp.LineWeight := LnWtByLayer;


      // Выделяем созданную полилинию для последующего редактирования в инспекторе
      // Select created polyline for subsequent editing in inspector
      //if APEnt <> nil then
      //   APEnt^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount, drawings.GetCurrentDWG^.Selector);

      result := False;
    end;
  end;
end;

{**Команда добавления пространства с расширениями
   Разбирает операнды в структуру и вызывает интерактивное черчение.
   @param(Context - контекст команды ZCAD)
   @param(operands - операнды команды)
   @return(результат выполнения команды)}
function SpaceAdd_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('Запущена команда spaceadd', TMWOHistoryOut);

  // Инициализируем структуру операндов
  // Initialize operands structure
  gOperandsStruct.listParam := TParamInfoList.Create;  // Создаем экземпляр TVector / Create TVector instance
  gOperandsStruct.indexColor := 256;  // ByLayer
  gOperandsStruct.namelayer := '';

  // Разбираем операнды и заполняем структуру
  // Parse operands and fill structure
  ParseOperandsToStruct(operands, gOperandsStruct);

  // Вызываем интерактивное черчение прямоугольника
  // Call interactive rectangle drawing
  Result := InteractiveDrawRectangle(
    Context,
    rscmSpecifyFirstPoint,
    rscmSpecifySecondPoint,
    AddExtdrToRectangle
  );
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);

  CreateZCADCommand(@SpaceAdd_com,'spaceadd',CADWG,0)^.CEndActionAttr:=[CEGUIRePrepare];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);

  // Освобождаем список параметров
  // Free parameters list
  if gOperandsStruct.listParam <> nil then
    FreeAndNil(gOperandsStruct.listParam);
end.
