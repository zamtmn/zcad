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

{**Модуль реализации команды exdRectangle для черчения прямоугольника с расширениями}
unit uzvcommand_exdRectangle;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,               // String utilities / Утилиты для работы со строками
  Classes,                // TStringList / TStringList
  fgl,                    // Free Pascal Generic Library / Библиотека обобщённых контейнеров
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcEnitiesVariablesExtender,
  uzcExtdrIncludingVolume,
  uzccommand_rectangle,
  uzcinterface,           // Interface utilities / Утилиты интерфейса
  uzcdrawings,            // Drawings manager / Менеджер чертежей
  uzestyleslayers,        // Layer management / Управление слоями
  varmandef;              // Variable manager definitions / Определения менеджера переменных

type
  // Структура для хранения одного параметра команды
  // Structure for storing one command parameter
  TParamInfo = record
    varname: string;      // Имя переменной / Variable name
    username: string;     // Описание для пользователя / User description
    typename: string;     // Тип переменной / Variable type
  end;

  // Список параметров на основе обобщённого списка
  // Parameters list based on generic list
  TParamInfoList = specialize TFPGList<TParamInfo>;

  // Структура для хранения всех операндов команды
  // Structure for storing all command operands
  TOperandsStruct = record
    indexColor: Integer;              // Индекс цвета / Color index
    namelayer: string;                // Имя слоя / Layer name
    listParam: TParamInfoList;        // Список параметров / Parameters list
  end;

implementation

var
  // Структура уровня модуля для хранения разобранных операндов команды
  // Module-level structure to store parsed command operands
  gOperandsStruct: TOperandsStruct;

{**Процедура разбора операндов и заполнения структуры TOperandsStruct
   Разбирает строку операндов и заполняет структуру с цветом, слоем и параметрами.
   Если операнды не указаны, устанавливаются значения "поСлою".
   @param(operands - строка операндов команды)
   @param(outStruct - выходная структура для заполнения)}
procedure ParseOperandsToStruct(
  const operands: TCommandOperands;
  out outStruct: TOperandsStruct);
var
  params: TStringList;
  i: integer;
  varname, username, typename: string;
  paramInfo: TParamInfo;
begin
  // Устанавливаем значения по умолчанию (поСлою)
  // Set default values (by layer)
  outStruct.indexColor := 256;  // 256 = ByLayer / 256 = поСлою
  outStruct.namelayer := '';    // Empty means use current layer / Пустое значит текущий слой

  // Создаём список параметров если его ещё нет
  // Create parameters list if it doesn't exist yet
  if outStruct.listParam = nil then
    outStruct.listParam := TParamInfoList.Create
  else
    outStruct.listParam.Clear;

  // Проверяем наличие операндов
  // Check if we have operands
  if Trim(operands) = '' then
    exit;

  // Разделяем операнды по запятой
  // Split operands by comma
  params := TStringList.Create;
  try
    params.Delimiter := ',';
    params.StrictDelimiter := True;
    params.DelimitedText := operands;

    // Извлекаем индекс цвета (первый параметр)
    // Extract color index (first parameter)
    if params.Count >= 1 then begin
      try
        outStruct.indexColor := StrToInt(Trim(params[0]));
        // Проверяем что цвет в допустимом диапазоне (0-256)
        // Ensure color is in valid range (0-256)
        if (outStruct.indexColor < 0) or (outStruct.indexColor > 256) then
          outStruct.indexColor := 256;  // ByLayer / поСлою
      except
        outStruct.indexColor := 256;  // ByLayer on error / поСлою при ошибке
      end;
    end;

    // Извлекаем имя слоя (второй параметр)
    // Extract layer name (second parameter)
    if params.Count >= 2 then begin
      outStruct.namelayer := Trim(params[1]);
      // Удаляем кавычки если есть
      // Remove quotes if present
      if (Length(outStruct.namelayer) >= 2) and
         (outStruct.namelayer[1] = '''') and
         (outStruct.namelayer[Length(outStruct.namelayer)] = '''') then
        outStruct.namelayer := Copy(outStruct.namelayer, 2, Length(outStruct.namelayer) - 2);
    end;

    // Обрабатываем переменные в триплетах начиная с индекса 2
    // Process variables in triplets starting from index 2
    i := 2;  // Начинаем после параметров цвета и слоя
             // Start after color and layer parameters
    while i + 2 < params.Count do begin
      varname := Trim(params[i]);
      username := Trim(params[i + 1]);
      typename := Trim(params[i + 2]);

      // Удаляем кавычки если есть
      // Remove quotes if present
      if (Length(username) >= 2) and (username[1] = '''') and (username[Length(username)] = '''') then
        username := Copy(username, 2, Length(username) - 2);

      // Заполняем структуру параметра
      // Fill parameter structure
      paramInfo.varname := varname;
      paramInfo.username := username;
      paramInfo.typename := typename;

      // Добавляем параметр в список
      // Add parameter to list
      outStruct.listParam.Add(paramInfo);

      Inc(i, 3);  // Переходим к следующему триплету / Move to next triplet
    end;
  finally
    params.Free;
  end;
end;

{**Процедура добавления переменных к примитиву из структуры операндов
   @param(APEnt - указатель на примитив)
   @param(operandsStruct - структура с разобранными операндами)}
procedure AddVariablesFromStruct(
  APEnt: PGDBObjEntity;
  const operandsStruct: TOperandsStruct);
var
  VarExt: TVariablesExtender;
  i: integer;
  vd: vardesk;
  paramInfo: TParamInfo;
begin
  // Получаем расширение переменных
  // Get variables extension
  VarExt := APEnt^.GetExtension<TVariablesExtender>;
  if VarExt = nil then
    exit;

  // Проверяем что список параметров существует
  // Check that parameters list exists
  if operandsStruct.listParam = nil then
    exit;

  // Добавляем все переменные из структуры
  // Add all variables from structure
  for i := 0 to operandsStruct.listParam.Count - 1 do begin
    paramInfo := operandsStruct.listParam[i];

    // Проверяем существует ли уже переменная
    // Check if variable already exists
    if VarExt.entityunit.FindVariable(paramInfo.varname) = nil then begin
      // Создаем и добавляем переменную
      // Create and add the variable
      VarExt.entityunit.setvardesc(
        vd,
        paramInfo.varname,
        paramInfo.username,
        paramInfo.typename
      );
      VarExt.entityunit.InterfaceVariables.createvariable(vd.Name, vd);

      zcUI.TextMessage(
        'Добавлена переменная / Variable added: ' +
        paramInfo.varname +
        ' (' + paramInfo.username + ') : ' +
        paramInfo.typename,
        TMWOHistoryOut
      );
    end;
  end;
end;

{**Процедура создания или получения слоя по имени
   Создает слой если он не существует, используя слой из библиотеки как шаблон.
   @param(layerName - имя слоя)
   @param(colorIndex - индекс цвета для нового слоя)
   @return(указатель на свойства слоя)}
function GetOrCreateLayer(
  const layerName: string;
  colorIndex: Integer): PGDBLayerProp;
var
  pproglayer: PGDBLayerProp;
begin
  Result := nil;

  if layerName = '' then
    exit;

  // Ищем описание слоя в библиотеке
  // Search for layer description in library
  pproglayer := BlockBaseDWG^.LayerTable.getAddres(layerName);

  // Пытаемся создать слой используя слой из библиотеки как шаблон
  // Try to create layer using library layer as template
  Result := drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(
    layerName,
    pproglayer
  );

  // Если слой все еще не существует, создаем его с параметрами по умолчанию
  // If layer still doesn't exist, create it with default parameters
  if Result = nil then begin
    Result := drawings.GetCurrentDWG^.LayerTable.addlayer(
      layerName,           // name / имя
      colorIndex,          // color / цвет
      -1,                  // line weight / толщина линии
      True,                // on / включен
      False,               // lock / заблокирован
      True,                // print / печатать
      'Rectangle layer',   // description / описание
      TLOLoad              // load mode / режим загрузки
    );
    zcUI.TextMessage('Создан слой / Layer created: ' + layerName, TMWOHistoryOut);
  end;
end;

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

        result := true;
      end else
        result := False;
    end;

    ESSCommandEnd: begin
      // Очищаем структуру операндов после завершения команды
      // Clear operands structure after command ends
      if gOperandsStruct.listParam <> nil then
        gOperandsStruct.listParam.Clear;
      gOperandsStruct.indexColor := 256;  // ByLayer
      gOperandsStruct.namelayer := '';
      result := False;
    end;
  end;
end;

{**Команда черчения прямоугольника с расширениями
   Разбирает операнды в структуру и вызывает интерактивное черчение.
   @param(Context - контекст команды ZCAD)
   @param(operands - операнды команды)
   @return(результат выполнения команды)}
function ExdRectangle_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда exdRectangle', TMWOHistoryOut);

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

  // Инициализируем структуру операндов
  // Initialize operands structure
  gOperandsStruct.listParam := TParamInfoList.Create;
  gOperandsStruct.indexColor := 256;  // ByLayer
  gOperandsStruct.namelayer := '';

  CreateZCADCommand(@ExdRectangle_com,'exdRectangle',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);

  // Освобождаем список параметров
  // Free parameters list
  if gOperandsStruct.listParam <> nil then
    gOperandsStruct.listParam.Free;
end.
