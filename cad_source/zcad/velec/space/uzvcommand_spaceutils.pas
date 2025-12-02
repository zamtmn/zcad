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

{**Модуль общих утилит для команд работы с пространствами и расширенными примитивами
   Содержит структуры данных и функции для разбора операндов и управления слоями}
unit uzvcommand_spaceutils;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,               // String utilities / Утилиты для работы со строками
  Classes,                // TStringList / TStringList
  gzctnrVector,           // Generic vector container / Обобщённый контейнер вектор
  uzcLog,
  uzccommandsabstract,
  uzcinterface,           // Interface utilities / Утилиты интерфейса
  uzcdrawings,            // Drawings manager / Менеджер чертежей
  uzestyleslayers,        // Layer management / Управление слоями
  uzbtypes;

type
  {** Структура для хранения одного параметра команды
      Содержит имя переменной, описание для пользователя и тип данных}
  TParamInfo = record
    varname: string;      // Имя переменной / Variable name
    username: string;     // Описание для пользователя / User description
    typename: string;     // Тип переменной / Variable type
  end;

  {** Список параметров на основе обобщённого вектора
      Использует GZVector для хранения параметров}
  TParamInfoList = {-}GZVector{-}<TParamInfo>{//};

  {** Структура для хранения всех операндов команды
      Содержит индекс цвета, имя слоя и список параметров}
  TOperandsStruct = record
    indexColor: Integer;              // Индекс цвета / Color index
    namelayer: string;                // Имя слоя / Layer name
    listParam: TParamInfoList;        // Список параметров / Parameters list
  end;

{** Процедура разбора операндов и заполнения структуры TOperandsStruct
    Разбирает строку операндов и заполняет структуру с цветом, слоем и параметрами.
    Если операнды не указаны, устанавливаются значения "поСлою".
    @param(operands - строка операндов команды)
    @param(outStruct - выходная структура для заполнения)}
procedure ParseOperandsToStruct(
  const operands: TCommandOperands;
  out outStruct: TOperandsStruct);

{** Функция создания или получения слоя по имени
    Создает слой если он не существует, используя слой из библиотеки как шаблон.
    @param(layerName - имя слоя)
    @param(colorIndex - индекс цвета для нового слоя)
    @return(указатель на свойства слоя)}
function GetOrCreateLayer(
  const layerName: string;
  colorIndex: Integer): PGDBLayerProp;

implementation

{** Процедура разбора операндов и заполнения структуры TOperandsStruct}
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

  // Очищаем список параметров
  // Clear parameters list
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
      outStruct.listParam.PushBackData(paramInfo);

      Inc(i, 3);  // Переходим к следующему триплету / Move to next triplet
    end;
  finally
    params.Free;
  end;
end;

{** Функция создания или получения слоя по имени}
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
      200,                  // line weight / толщина линии
      True,                // on / включен
      False,               // lock / заблокирован
      True,                // print / печатать
      'Layer created by command',   // description / описание
      TLOLoad              // load mode / режим загрузки
    );
    zcUI.TextMessage('Создан слой / Layer created: ' + layerName, TMWOHistoryOut);
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);

end.
