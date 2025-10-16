unit uzvvstdevpopulator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, laz.VirtualTrees, uzvmcstruct, gvector;

type

  PGridNodeData = ^TGridNodeData;
  TGridNodeData = record
    DevName: string;
    HDName: string;
    HDGroup: integer;
    PathHD: string;
    FullPathHD: string;
  end;

  { TVstDevPopulator }
  // Класс для заполнения виртуального дерева устройств (vstDev)
  // Отвечает за формирование записей в TLazVirtualStringTree с группировкой по feedernum
  TVstDevPopulator = class
  private
    FVstDev: TLazVirtualStringTree;          // Ссылка на виртуальное дерево
    FDevicesList: TListVElectrDevStruct;     // Ссылка на список устройств

    // Вспомогательная функция для проверки соответствия путей
    // Возвращает true, если последнее слово из Str1 является последним словом в Str2
    function ProcessStrings(const Str1, Str2: string): boolean;

    // Создает родительский узел группы для feedernum
    function CreateGroupNode(const feederNum: integer): PVirtualNode;

    // Создает дочерний узел устройства под группой
    function CreateDeviceNode(GroupNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;

    // Заполняет данные узла группы
    procedure FillGroupNodeData(Node: PVirtualNode; const feederNum: integer);

    // Заполняет данные узла устройства
    procedure FillDeviceNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);

  public
    // Конструктор класса
    // AVstDev - виртуальное дерево для заполнения
    // ADevicesList - список устройств для отображения
    constructor Create(AVstDev: TLazVirtualStringTree; ADevicesList: TListVElectrDevStruct);

    // Основной метод для заполнения дерева устройств
    // filterPath - путь иерархии для фильтрации (пустая строка = показать все)
    // Группирует устройства по feedernum, создавая родительские узлы для каждой группы
    procedure PopulateTree(const filterPath: string);
  end;

implementation

{ TVstDevPopulator }

constructor TVstDevPopulator.Create(AVstDev: TLazVirtualStringTree; ADevicesList: TListVElectrDevStruct);
begin
  inherited Create;
  FVstDev := AVstDev;
  FDevicesList := ADevicesList;
end;

// Вспомогательная функция для проверки соответствия путей
// Разбивает строки на части по разделителю '~' и проверяет,
// является ли последнее слово из Str1 последним словом в Str2
function TVstDevPopulator.ProcessStrings(const Str1, Str2: string): boolean;
var
  Parts1, Parts2: TStringList;
  LastWordFromStr1: string;
  IndexInStr2, WordsAfter, i: Integer;
begin
  Result := false;

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
      Result := true;

  finally
    Parts1.Free;
    Parts2.Free;
  end;
end;

// Создает родительский узел группы для feedernum
function TVstDevPopulator.CreateGroupNode(const feederNum: integer): PVirtualNode;
begin
  Result := FVstDev.AddChild(nil);
  FillGroupNodeData(Result, feederNum);
  // Устанавливаем флаг vsHasChildren для отображения индикаторов +/-
  Include(Result^.States, vsHasChildren);
end;

// Создает дочерний узел устройства под группой
function TVstDevPopulator.CreateDeviceNode(GroupNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;
begin
  Result := FVstDev.AddChild(GroupNode);
  FillDeviceNodeData(Result, device);
end;

// Заполняет данные узла группы
procedure TVstDevPopulator.FillGroupNodeData(Node: PVirtualNode; const feederNum: integer);
var
  NodeData: PGridNodeData;
begin
  NodeData := FVstDev.GetNodeData(Node);
  NodeData^.DevName := 'ф. ' + IntToStr(feederNum);
  NodeData^.HDName := '';
  NodeData^.HDGroup := 0;
  NodeData^.PathHD := '';
  NodeData^.FullPathHD := '';
end;

// Заполняет данные узла устройства
procedure TVstDevPopulator.FillDeviceNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
var
  NodeData: PGridNodeData;
begin
  NodeData := FVstDev.GetNodeData(Node);
  NodeData^.DevName := device.basename;
  NodeData^.HDName := device.headdev;
  NodeData^.HDGroup := device.feedernum;
  NodeData^.PathHD := device.pathHD;
  NodeData^.FullPathHD := device.fullpathHD;
end;

// Основной метод для заполнения дерева устройств
// Проходит по списку устройств и создает структуру дерева с группировкой по feedernum
procedure TVstDevPopulator.PopulateTree(const filterPath: string);
var
  i: integer;
  GroupNode: PVirtualNode;
  device: TVElectrDevStruct;
  currentFeederNum: integer;
  lastFeederNum: integer;
  isFirstDevice: boolean;
begin
  try
    FVstDev.BeginUpdate;
    try
      FVstDev.Clear;

      // Инициализация переменных для отслеживания групп
      lastFeederNum := -1;
      GroupNode := nil;
      isFirstDevice := True;

      // Проходим по всем устройствам в FDevicesList
      for i := 0 to FDevicesList.Size - 1 do
      begin
        device := FDevicesList[i];

        // Если фильтр задан, проверяем соответствие fullpathHD (не pathHD!)
        if (filterPath = '') or (device.pathHD = filterPath) then
        begin
          if ProcessStrings(filterPath, device.fullpathHD) then
            currentFeederNum := device.feedernum;

          // Если встретили новую группу (новое значение feedernum), создаём родительский узел
          if isFirstDevice or (currentFeederNum <> lastFeederNum) then
          begin
            GroupNode := CreateGroupNode(currentFeederNum);
            lastFeederNum := currentFeederNum;
            isFirstDevice := False;
          end;

          // Создаём дочерний узел устройства под текущей группой
          CreateDeviceNode(GroupNode, device);
        end;
      end;

      // Разворачиваем все группы для удобства просмотра
      FVstDev.FullExpand;
    finally
      FVstDev.EndUpdate;
    end;
  except
    on E: Exception do
      raise Exception.Create('Ошибка загрузки данных: ' + E.Message);
  end;
end;

end.
