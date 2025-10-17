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

unit uzvmchierarchy;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, gvector,
  uzeentdevice, gzctnrVectorTypes,
  uzcinterface, uzvmcstruct;

type
  // Тип функции сравнения устройств
  // Возвращает: -1 если dev1 < dev2, 0 если dev1 = dev2, 1 если dev1 > dev2
  TDeviceCompareFunc = function(const dev1, dev2: TVElectrDevStruct): Integer;

  THierarchyBuilder = class
  private
    type
      TSortDev = record
        res: Integer;
        LastWord: string;
        NextWord1: string;
        NextWord2: string;
      end;

    function FindFullHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
    function FindOnlyHDHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
    function ProcessStrings(const Str1, Str2: string): TSortDev;
    function GetDeviceIndexByName(const deviceList: TListVElectrDevStruct; const ADevName: string): Integer;

    // Функции сравнения для отдельных полей
    function CompareByPathHD(const dev1, dev2: TVElectrDevStruct): Integer;
    function CompareBySort1(const dev1, dev2: TVElectrDevStruct): Integer;
    function CompareBySort2(const dev1, dev2: TVElectrDevStruct): Integer;
    function CompareBySort3(const dev1, dev2: TVElectrDevStruct): Integer;

    // Цепочка сравнений для гибкой настройки сортировки
    function CompareDevices(const dev1, dev2: TVElectrDevStruct): Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure BuildHierarchyPaths(var deviceList: TListVElectrDevStruct);
    procedure FillSortFields(var deviceList: TListVElectrDevStruct);
    procedure SortDeviceList(var deviceList: TListVElectrDevStruct);
  end;

implementation

constructor THierarchyBuilder.Create;
begin
  inherited Create;
end;

destructor THierarchyBuilder.Destroy;
begin
  inherited Destroy;
end;

function THierarchyBuilder.FindFullHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
  device: TVElectrDevStruct;
begin
  Result := False;

  // Ищем устройство с заданным полным именем
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList[i];
    if device.basename = nodeName then
    begin
      parentNode := device.headdev;

      // Если головное устройство пустое или является корневым, начинаем иерархию
      if (parentNode = '') or (parentNode = 'root') or (parentNode = '???') or (parentNode = '-') then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      // Рекурсивно ищем иерархию для родительского узла
      if FindFullHierarchy(deviceList, parentNode, hierarchy) then
      begin
        hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function THierarchyBuilder.FindOnlyHDHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
  device: TVElectrDevStruct;
begin
  Result := False;

  // Ищем устройство с заданным полным именем
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList[i];
    if device.basename = nodeName then
    begin
      parentNode := device.headdev;

      // Если головное устройство пустое или является корневым, начинаем иерархию
      if (parentNode = '') or (parentNode = 'root') or (parentNode = '???') or (parentNode = '-') then
      begin
        hierarchy := nodeName;
        Result := True;
              //zcUI.TextMessage('FindOnlyHDHierarchy ' + hierarchy, TMWOHistoryOut);
        Exit;
      end;



      // Рекурсивно ищем иерархию для родительского узла
      if FindOnlyHDHierarchy(deviceList, parentNode, hierarchy) then
      begin
        // Добавляем текущий узел только если он может быть головным устройством
        if device.canbehead = 1 then
          hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure THierarchyBuilder.BuildHierarchyPaths(var deviceList: TListVElectrDevStruct);
var
  i: Integer;
  hierarchy: string;
  device: PTVElectrDevStruct;
begin
  // Построение полного пути и пути только для головных устройств
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList.Mutable[i];

    // Построение полного пути иерархии       fullname
    hierarchy := '';
    if FindFullHierarchy(deviceList, device^.headdev, hierarchy) then
      device^.fullpathHD := hierarchy
    else
      device^.fullpathHD := '';

    // Построение пути только для головных устройств
    hierarchy := '';
    if FindOnlyHDHierarchy(deviceList, device^.headdev, hierarchy) then
      device^.pathHD := hierarchy
    else
      device^.pathHD := '';
  end;
end;

function THierarchyBuilder.ProcessStrings(const Str1, Str2: string): TSortDev;
var
  Parts1, Parts2: TStringList;
  LastWordFromStr1: string;
  IndexInStr2, WordsAfter, i: Integer;
begin
  Result.res := -1;
  Result.LastWord := '-1';
  Result.NextWord1 := '-1';
  Result.NextWord2 := '-1';

  Parts1 := TStringList.Create;
  Parts2 := TStringList.Create;
  try
    // Разбиваем первую строку на части
    ExtractStrings(['~'], [], PChar(Str1), Parts1);
    if Parts1.Count = 0 then Exit;

    // Получаем последнее слово из первой строки
    LastWordFromStr1 := Parts1[Parts1.Count - 1];

    // Разбиваем вторую строку на части
    ExtractStrings(['~'], [], PChar(Str2), Parts2);
    if Parts2.Count = 0 then Exit;

    // Ищем последнее слово из первой строки во второй строке
    IndexInStr2 := -1;
    for i := 0 to Parts2.Count - 1 do
    begin
      if Parts2[i] = LastWordFromStr1 then
      begin
        IndexInStr2 := i;
        Break;
      end;
    end;

    if IndexInStr2 = -1 then Exit;

    // Определяем сколько слов осталось после найденного слова
    WordsAfter := Parts2.Count - IndexInStr2 - 1;

    // Выбираем вариант в зависимости от количества слов после
    if WordsAfter = 0 then
    begin
      Result.res := 1;
      Result.LastWord := LastWordFromStr1;
      Result.NextWord1 := '';
      Result.NextWord2 := '';
    end
    else if WordsAfter = 1 then
    begin
      Result.res := 2;
      Result.LastWord := LastWordFromStr1;
      Result.NextWord1 := Parts2[IndexInStr2 + 1];
      Result.NextWord2 := '';
    end
    else if WordsAfter >= 2 then
    begin
      Result.res := 3;
      Result.LastWord := LastWordFromStr1;
      Result.NextWord1 := Parts2[IndexInStr2 + 1];
      Result.NextWord2 := Parts2[IndexInStr2 + 2];
    end;

  finally
    Parts1.Free;
    Parts2.Free;
  end;
end;

function THierarchyBuilder.GetDeviceIndexByName(const deviceList: TListVElectrDevStruct; const ADevName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to deviceList.Size - 1 do
  begin
    if deviceList[i].basename = ADevName then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure THierarchyBuilder.FillSortFields(var deviceList: TListVElectrDevStruct);
var
  i: Integer;
  sortWord: TSortDev;
  device: PTVElectrDevStruct;
  idx1, idx2: Integer;
begin
  // Заполнение полей Sort1, Sort2, Sort3 на основе анализа иерархии
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList.Mutable[i];

    // Анализируем пути иерархии
    sortWord := ProcessStrings(device^.pathHD, device^.fullpathHD);
    //zcUI.TextMessage('sortWord1 ' + sortWord.LastWord+' - NextWord1= ' + sortWord.NextWord1+' -NextWord2= ' + sortWord.NextWord2, TMWOHistoryOut);
    if sortWord.res = 1 then
    begin
      // Устройство находится на верхнем уровне иерархии
      device^.Sort1 := deviceList[i].feedernum;
      device^.Sort2 := 0;
      device^.Sort3 := 0;
    end
    else if sortWord.res = 2 then
    begin
      // Устройство на втором уровне - одно устройство выше в иерархии
      idx1 := GetDeviceIndexByName(deviceList, sortWord.NextWord1);
      device^.Sort1 := deviceList[idx1].feedernum;
      device^.Sort2 := deviceList[i].feedernum;
      device^.Sort3 := 0;
    end
    else if sortWord.res >= 3 then
    begin
      // Устройство на третьем или более глубоком уровне
      idx1 := GetDeviceIndexByName(deviceList, sortWord.NextWord2);
      idx2 := GetDeviceIndexByName(deviceList, sortWord.NextWord1);
      device^.Sort1 := deviceList[idx2].feedernum;
      device^.Sort2 := deviceList[idx1].feedernum;
      device^.Sort3 := deviceList[i].feedernum;
    end
    else
    begin
      // Не удалось определить уровень
      device^.Sort1 := 0;
      device^.Sort2 := 0;
      device^.Sort3 := 0;
    end;
  end;
end;

// ============================================================================
// Функции сравнения для отдельных полей устройства
// ============================================================================

// Сравнение устройств по полю pathHD (путь головного устройства)
// Сортировка по алфавиту (лексикографическая)
function THierarchyBuilder.CompareByPathHD(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  if dev1.pathHD < dev2.pathHD then
    Result := -1
  else if dev1.pathHD > dev2.pathHD then
    Result := 1
  else
    Result := 0;
end;

// Сравнение устройств по полю Sort1 (первичная сортировка по номеру)
// Сортировка по возрастанию
function THierarchyBuilder.CompareBySort1(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  if dev1.Sort1 < dev2.Sort1 then
    Result := -1
  else if dev1.Sort1 > dev2.Sort1 then
    Result := 1
  else
    Result := 0;
end;

// Сравнение устройств по полю Sort2 (вторичная сортировка по номеру)
// Сортировка по возрастанию
function THierarchyBuilder.CompareBySort2(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  if dev1.Sort2 < dev2.Sort2 then
    Result := -1
  else if dev1.Sort2 > dev2.Sort2 then
    Result := 1
  else
    Result := 0;
end;

// Сравнение устройств по полю Sort3 (третичная сортировка по номеру)
// Сортировка по возрастанию
function THierarchyBuilder.CompareBySort3(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  if dev1.Sort3 < dev2.Sort3 then
    Result := -1
  else if dev1.Sort3 > dev2.Sort3 then
    Result := 1
  else
    Result := 0;
end;

// ============================================================================
// Цепочка сравнений устройств
// ============================================================================

// Комплексное сравнение устройств по всем критериям в заданном порядке
// Порядок сравнения:
// 1. По полю pathHD (по алфавиту)
// 2. По полю Sort1 (по возрастанию)
// 3. По полю Sort2 (по возрастанию)
// 4. По полю Sort3 (по возрастанию)
//
// Эта функция обеспечивает гибкость для будущих расширений:
// можно легко добавить новые критерии сортировки или изменить их порядок
function THierarchyBuilder.CompareDevices(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  // Сначала сравниваем по pathHD
  Result := CompareByPathHD(dev1, dev2);
  if Result <> 0 then Exit;

  // Если pathHD равны, сравниваем по Sort1
  Result := CompareBySort1(dev1, dev2);
  if Result <> 0 then Exit;

  // Если Sort1 равны, сравниваем по Sort2
  Result := CompareBySort2(dev1, dev2);
  if Result <> 0 then Exit;

  // Если Sort2 равны, сравниваем по Sort3
  Result := CompareBySort3(dev1, dev2);
end;

// ============================================================================
// Процедура сортировки списка устройств
// ============================================================================

// Функция сортировки списка устройств по заданным критериям
// Сортировка выполняется по порядку:
// 1. По полю pathHD (по алфавиту)
// 2. По полю Sort1 (по возрастанию)
// 3. По полю Sort2 (по возрастанию)
// 4. По полю Sort3 (по возрастанию)
//
// Для добавления новых критериев сортировки:
// - Добавьте новую функцию сравнения (например, CompareByFieldName)
// - Добавьте вызов этой функции в цепочку сравнений в CompareDevices
procedure THierarchyBuilder.SortDeviceList(var deviceList: TListVElectrDevStruct);
var
  i, j: Integer;
  temp: TVElectrDevStruct;
  compareResult: Integer;
begin
  // Реализация пузырьковой сортировки для стабильности результатов
  for i := 0 to deviceList.Size - 2 do
  begin
    for j := 0 to deviceList.Size - i - 2 do
    begin
      // Используем функцию CompareDevices для комплексного сравнения
      // Результат: -1 если [j] < [j+1], 0 если равны, 1 если [j] > [j+1]
      compareResult := CompareDevices(deviceList[j], deviceList[j + 1]);

      // Если текущий элемент больше следующего, меняем их местами
      if compareResult > 0 then
      begin
        temp := deviceList[j];
        deviceList.Mutable[j]^ := deviceList[j + 1];
        deviceList.Mutable[j + 1]^ := temp;
      end;
    end;
  end;
end;

end.
