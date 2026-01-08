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
{$mode objfpc}{$H+}

{**Модуль бизнес-логики для управления подключениями устройств}
unit uzvconnect_logic;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzeentdevice,
  uzcenitiesvariablesextender,
  uzsbVarmanDef,
  UUnitManager,
  uzbpaths,
  uzctranslations,
  uzcinterface,
  uzvconsts,
  Varman,
  gzctnrVectorTypes,
  uzvconnect_struct;

{**Добавить новое подключение к устройству
   @param ADevice - устройство, к которому добавляется подключение
   @return True если подключение успешно добавлено, False в случае ошибки}
function AddConnectionToDevice(ADevice: PGDBObjDevice): Boolean;

{**Найти следующий доступный номер подключения для устройства
   @param ADevice - устройство для поиска номера подключения
   @return номер следующего доступного подключения}
function FindNextConnectionNumber(ADevice: PGDBObjDevice): Integer;

{**Найти номер подключения для устройства по индексу в ConnectList
   @param ADevice - устройство
   @param AConnectListIndex - индекс в глобальном списке подключений
   @return номер подключения (1, 2, 3...) или 0 если не найдено}
function FindConnectionIndexForDevice(
  ADevice: PGDBObjDevice;
  AConnectListIndex: Integer
): Integer;

{**Загрузить модуль переменных подключения
   @return указатель на загруженный модуль или nil в случае ошибки}
function LoadConnectionModule: PTSimpleUnit;

implementation

const
  {**Имя модуля с определениями переменных подключений}
  CONNECTION_MODULE_NAME = 'slcabagenmodul';

{**Загрузить модуль переменных подключения}
function LoadConnectionModule: PTSimpleUnit;
begin
  // Ищем модуль и загружаем его
  Result := units.findunit(
    GetSupportPaths,      // пути по которым будет искаться юнит
    @InterfaceTranslate,  // процедура локализации
    CONNECTION_MODULE_NAME
  );
end;

{**Найти следующий доступный номер подключения для устройства}
function FindNextConnectionNumber(ADevice: PGDBObjDevice): Integer;
var
  Varext: TVariablesExtender;
  pvd: pvardesk;
  connectionNumber: Integer;
  varName: String;
begin
  Result := 1;

  if ADevice = nil then
    Exit;

  // Получаем расширение с переменными у устройства
  Varext := ADevice^.specialize GetExtension<TVariablesExtender>;

  if Varext = nil then
    Exit;

  // Ищем первый свободный номер подключения
  connectionNumber := 1;
  repeat
    // Формируем имя переменной для проверки существования
    varName := velec_VarNameForConnectBefore +
               IntToStr(connectionNumber) +
               '_' +
               velec_VarNameForConnectAfter_SLTypeagen;

    pvd := Varext.entityunit.FindVariable(varName);

    if pvd = nil then
    begin
      Result := connectionNumber;
      Exit;
    end;

    Inc(connectionNumber);
  until False;
end;

{**Найти номер подключения для устройства по индексу в ConnectList}
function FindConnectionIndexForDevice(
  ADevice: PGDBObjDevice;
  AConnectListIndex: Integer
): Integer;
var
  i: Integer;
  currentConnectionNum: Integer;
begin
  Result := 0;

  if ADevice = nil then
    Exit;

  if (AConnectListIndex < 0) or (AConnectListIndex >= ConnectList.Size) then
    Exit;

  // Подсчитываем, какой по счету номер подключения у данного устройства
  currentConnectionNum := 0;

  for i := 0 to AConnectListIndex do
  begin
    if ConnectList[i].Device = ADevice then
      Inc(currentConnectionNum);
  end;

  Result := currentConnectionNum;
end;

{**Создать переменную подключения в устройстве
   @param AVarext - расширение переменных устройства
   @param ATemplateUnit - модуль с шаблонами переменных
   @param ATemplateName - имя переменной в шаблоне
   @param AConnectionNumber - номер подключения
   @return True если переменная успешно создана}
function CreateConnectionVariable(
  AVarext: TVariablesExtender;
  ATemplateUnit: PTSimpleUnit;
  const ATemplateName: String;
  AConnectionNumber: Integer
): Boolean;
var
  pvdTemplate: pvardesk;
  pvd: pvardesk;
  vd: vardesk;
  newVarName: String;
begin
  Result := False;

  // Находим переменную в шаблоне
  pvdTemplate := ATemplateUnit^.FindVariable(ATemplateName, True);

  if pvdTemplate = nil then
    Exit;

  // Формируем новое имя переменной с учетом номера подключения
  newVarName := StringReplace(
    pvdTemplate^.name,
    velec_VarNameForConnectBefore + '1',
    velec_VarNameForConnectBefore + IntToStr(AConnectionNumber),
    [rfReplaceAll, rfIgnoreCase]
  );

  // Создаем новую переменную
  vd := AVarext.entityunit.CreateVariable(
    newVarName,
    pvdTemplate^.data.PTD^.TypeName
  );

  // Находим созданную переменную
  pvd := AVarext.entityunit.FindVariable(newVarName);

  if pvd = nil then
    Exit;

  // Копируем пользовательское имя
  pvd^.username := pvdTemplate^.username;

  // Копируем значение из шаблона
  pvdTemplate^.data.PTD^.CopyValueToInstance(
    pvdTemplate^.data.Addr.Instance,
    pvd^.data.Addr.Instance
  );

  Result := True;
end;

{**Добавить новое подключение к устройству}
function AddConnectionToDevice(ADevice: PGDBObjDevice): Boolean;
var
  connectionModule: PTSimpleUnit;
  Varext: TVariablesExtender;
  connectionNumber: Integer;
  pvdTemplate: pvardesk;
  iradd: itrec;
begin
  Result := False;

  if ADevice = nil then
    Exit;

  // Загружаем модуль с определениями переменных
  connectionModule := LoadConnectionModule;

  if connectionModule = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: не удалось загрузить модуль ' + CONNECTION_MODULE_NAME,
      TMWOHistoryOut
    );
    Exit;
  end;

  // Получаем расширение с переменными у устройства
  Varext := ADevice^.specialize GetExtension<TVariablesExtender>;

  if Varext = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: устройство не имеет расширения переменных',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Находим следующий доступный номер подключения
  connectionNumber := FindNextConnectionNumber(ADevice);

  // Перебираем все переменные из шаблона
  pvdTemplate := connectionModule^.InterfaceVariables.vardescarray.
                 beginiterate(iradd);

  if pvdTemplate = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: модуль ' + CONNECTION_MODULE_NAME + ' не содержит переменных',
      TMWOHistoryOut
    );
    Exit;
  end;

  repeat
    // Создаем каждую переменную подключения
    CreateConnectionVariable(
      Varext,
      connectionModule,
      pvdTemplate^.name,
      connectionNumber
    );

    pvdTemplate := connectionModule^.InterfaceVariables.vardescarray.
                   iterate(iradd);
  until pvdTemplate = nil;

  // Регистрируем категорию переменных для инспектора
  RegisterVarCategory(
    velec_VarNameForConnectBefore + IntToStr(connectionNumber),
    velec_VarNameForConnectBeforeName + IntToStr(connectionNumber),
    @InterfaceTranslate
  );

  Result := True;
end;

end.
