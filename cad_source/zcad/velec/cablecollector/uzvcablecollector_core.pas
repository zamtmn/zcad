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

unit uzvcablecollector_core;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcentcable,
  uzcdrawings,
  varmandef,
  uzcenitiesvariablesextender,
  uzcLog,
  gzctnrVectorTypes,
  uzvcablecollector_types,
  uzvcablecollector_utils,
  uzvcablecollector_ui;

type
  // Основной класс для сбора и анализа кабелей
  TCableCollector = class
  private
    FCableList: TCableInfoVector;      // Список всех собранных кабелей
    FGroupedData: TCableGroupInfoVector; // Сгруппированные данные
    FPrimitivesCount: Integer;          // Количество обработанных примитивов

    // Добавление кабеля в список
    procedure AddCable(const CableInfo: TCableInfo);

    // Поиск или создание группы
    function FindOrCreateGroup(const CableName, MountingMethod: String): PTCableGroupInfo;

  public
    constructor Create;
    destructor Destroy; override;

    // Сбор данных из примитивов
    procedure Collect;

    // Группировка по методам монтажа
    procedure Analyze;

    // Вывод результатов в интерфейс ZcUI
    procedure PrintToZcUI;
  end;

implementation

// Конструктор класса
constructor TCableCollector.Create;
begin
  inherited Create;
  FCableList.init(100);
  FGroupedData.init(50);
  FPrimitivesCount := 0;
  programlog.LogOutFormatStr('TCableCollector created', [], LM_Info);
end;

// Деструктор класса
destructor TCableCollector.Destroy;
begin
  FCableList.done;
  FGroupedData.done;
  programlog.LogOutFormatStr('TCableCollector destroyed', [], LM_Info);
  inherited Destroy;
end;

// Добавление информации о кабеле в список
procedure TCableCollector.AddCable(const CableInfo: TCableInfo);
begin
  FCableList.PushBackData(CableInfo);
end;

// Поиск или создание группы для кабеля с определённым методом монтажа
function TCableCollector.FindOrCreateGroup(const CableName,
  MountingMethod: String): PTCableGroupInfo;
var
  I: Integer;
  GroupInfo: PTCableGroupInfo;
  NewGroup: TCableGroupInfo;
begin
  Result := nil;

  // Поиск существующей группы
  for I := 0 to FGroupedData.Count - 1 do
  begin
    GroupInfo := FGroupedData.GetMutable(I);
    if (GroupInfo^.CableName = CableName) and
       (GroupInfo^.MountingMethod = MountingMethod) then
    begin
      Result := GroupInfo;
      Exit;
    end;
  end;

  // Создание новой группы, если не найдена
  if Result = nil then
  begin
    NewGroup.CableName := CableName;
    NewGroup.MountingMethod := MountingMethod;
    NewGroup.TotalLength := 0.0;
    FGroupedData.PushBackData(NewGroup);
    Result := FGroupedData.GetMutable(FGroupedData.Count - 1);
  end;
end;

// Сбор данных о кабелях из примитивов чертежа
procedure TCableCollector.Collect;
var
  pCable: PGDBObjCable;
  ir: itrec;
  pentvarext: TVariablesExtender;
  pvd: pvardesk;
  CableInfo: TCableInfo;
begin
  programlog.LogOutFormatStr('Starting cable collection', [], LM_Info);
  PrintStartMessage;

  // Проверка наличия примитивов на чертеже
  if drawings.GetCurrentROOT.ObjArray.Count = 0 then
  begin
    programlog.LogOutFormatStr('No primitives found on drawing', [], LM_Info);
    Exit;
  end;

  // Перебор всех примитивов на чертеже
  pCable := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pCable <> nil then
  repeat
    Inc(FPrimitivesCount);

    // Обработка только кабельных примитивов
    if pCable^.GetObjType = GDBCableID then
    begin
      // Получаем доступ к расширению с переменными
      pentvarext := pCable^.GetExtension<TVariablesExtender>;

      // Инициализация структуры для хранения данных кабеля
      CableInfo.NMO_Name := '';
      CableInfo.CABLE_Segment := '';
      CableInfo.CABLE_MountingMethod := '';
      CableInfo.AmountD := 0.0;

      // Получение наименования кабеля
      pvd := pentvarext.entityunit.FindVariable('NMO_Name');
      if pvd <> nil then
        CableInfo.NMO_Name := pString(pvd^.data.Addr.Instance)^;

      // Получение номера сегмента
      pvd := pentvarext.entityunit.FindVariable('CABLE_Segment');
      if pvd <> nil then
        CableInfo.CABLE_Segment := IntToStr(PInteger(pvd^.data.Addr.Instance)^);

      // Получение метода монтажа
      pvd := pentvarext.entityunit.FindVariable('CABLE_MountingMethod');
      if pvd <> nil then
        CableInfo.CABLE_MountingMethod := pString(pvd^.data.Addr.Instance)^;

      // Получение длины кабеля
      pvd := pentvarext.entityunit.FindVariable('AmountD');
      if pvd <> nil then
        CableInfo.AmountD := pDouble(pvd^.data.Addr.Instance)^;

      // Добавление кабеля в список (только если есть имя)
      if CableInfo.NMO_Name <> '' then
        AddCable(CableInfo);
    end;

    pCable := drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pCable = nil;

  PrintProcessedCount(FPrimitivesCount);
  programlog.LogOutFormatStr('Cable collection completed, found %d cables',
                             [FCableList.Count], LM_Info);
end;

// Группировка собранных данных по методам монтажа
procedure TCableCollector.Analyze;
var
  I: Integer;
  CableInfo: PTCableInfo;
  GroupInfo: PTCableGroupInfo;
begin
  programlog.LogOutFormatStr('Starting cable analysis', [], LM_Info);

  // Группировка данных
  for I := 0 to FCableList.Count - 1 do
  begin
    CableInfo := FCableList.GetMutable(I);

    // Поиск или создание группы для текущего кабеля
    GroupInfo := FindOrCreateGroup(CableInfo^.NMO_Name,
                                   CableInfo^.CABLE_MountingMethod);

    // Добавление длины к суммарной длине группы
    if GroupInfo <> nil then
      GroupInfo^.TotalLength := GroupInfo^.TotalLength + CableInfo^.AmountD;
  end;

  PrintAnalysisComplete;
  programlog.LogOutFormatStr('Cable analysis completed, created %d groups',
                             [FGroupedData.Count], LM_Info);
end;

// Вывод результатов в интерфейс ZcUI
procedure TCableCollector.PrintToZcUI;
begin
  programlog.LogOutFormatStr('Printing results to ZcUI', [], LM_Info);

  // Вывод таблицы результатов
  PrintResultsTable(FGroupedData);

  // Вывод сообщения о завершении
  PrintCompleteMessage;

  programlog.LogOutFormatStr('Results printed successfully', [], LM_Info);
end;

end.
