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
@author(Vladimir Bobrov) <- Created using AI
}
{
  Модуль: uzccommand_explodeblockproxy
  Назначение: Команда ExplodeBlockProxy — расчленение выделенных
              вставок блоков (BlockInsert) и прокси-объектов
              (ProxyEntity/ACAD_PROXY_ENTITY) на составляющие примитивы.
  Алгоритм работы:
    1. Проверяется наличие выделенных объектов. Если их нет — команда
       завершается с соответствующим сообщением.
    2. Проверяется, что ВСЕ выделенные объекты являются BlockInsert или
       ProxyEntity. Если среди выделенных есть другие примитивы,
       выводится сообщение, команда ничего не делает.
    3. Для каждого выделенного объекта его подпримитивы клонируются в
       текущий корень чертежа с применением матрицы трансформации
       (положение, поворот, масштаб) исходного объекта.
    4. Исходные BlockInsert/ProxyEntity удаляются.
    5. Все операции объединяются в одну транзакцию undo.
  Место расположения: cad_source/zcad/velec/newcommand
  Имя команды: ExplodeBlockProxy
  Зависимости:
    uzccommandsabstract   — абстрактные типы команд
    uzccommandsimpl       — реализация регистрации команд
    uzcutils              — вспомогательные процедуры (undo, добавление в чертёж)
    uzeentblockinsert     — GDBObjBlockInsert
    uzeentacdproxy        — GDBObjAcdProxy (ProxyEntity)
    uzcinterface          — взаимодействие с UI (сообщения, перерисовка)
    uzeentity, uzeconsts  — базовый тип примитива, идентификаторы типов
}
{$mode delphi}
unit uzccommand_explodeblockproxy;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzeentity,
  uzeconsts,
  uzeentblockinsert,
  uzeentacdproxy,
  uzeentcomplex,
  uzeblockdef,
  UGDBObjBlockdefArray,
  UGDBSelectedObjArray,
  UGDBVisibleTreeArray,
  uzegeometrytypes,
  uzegeometry,
  uzgldrawcontext,
  uzedrawingdef,
  uzcdrawing,
  uzcdrawings,
  uzcutils,
  uzcinterface,
  uzcstrconsts,
  zcmultiobjectcreateundocommand,
  uzeentsubordinated,
  uzeentgenericsubentry,
  gzctnrVectorTypes;

implementation

resourcestring
  { Сообщение об отсутствии подходящих выделенных объектов.
    Точный текст согласно требованиям issue. }
  RSExplodeSelectOnlyBlocksOrProxy =
    'перед запуском команды выделите только Блоки или Proxy объекты';

{ Проверяет, является ли объект вставкой блока или прокси-объектом.
  Такие объекты поддерживают расчленение через текущую команду.
  Возвращает True, если тип объекта — BlockInsert или ACAD_PROXY_ENTITY. }
function IsBlockOrProxy(Entity: PGDBObjEntity): Boolean;
begin
  Result := (Entity <> nil)
    and ((Entity^.GetObjType = GDBBlockInsertID)
      or (Entity^.GetObjType = GDBAcdProxyID));
end;

{ Проверяет, что все выделенные объекты пригодны для расчленения.
  Возвращает True только если выделение не пустое и каждый объект —
  BlockInsert или ProxyEntity. В противном случае возвращает False.
  В параметре ACount возвращается количество выделенных объектов. }
function AreAllSelectedBlocksOrProxy(Drawing: PTZCADDrawing;
  out ACount: Integer): Boolean;
var
  SelDesc: PSelectedObjDesc;
  IR: itrec;
begin
  ACount := 0;
  Result := False;
  if Drawing = nil then
    Exit;
  if Drawing^.SelObjArray.Count = 0 then
    Exit;
  SelDesc := Drawing^.SelObjArray.beginiterate(IR);
  if SelDesc = nil then
    Exit;
  repeat
    if not IsBlockOrProxy(SelDesc^.objaddr) then
      Exit(False);
    Inc(ACount);
    SelDesc := Drawing^.SelObjArray.iterate(IR);
  until SelDesc = nil;
  Result := ACount > 0;
end;

{ Собирает указатели на все выделенные BlockInsert/ProxyEntity объекты
  в локальный массив. Сбор отдельным проходом нужен потому, что сам
  процесс расчленения меняет состав корневого ObjArray и делает
  небезопасным продолжение итерации по SelObjArray. }
procedure CollectSelectedBlocksOrProxy(Drawing: PTZCADDrawing;
  out AItems: array of PGDBObjEntity; out ACount: Integer);
var
  SelDesc: PSelectedObjDesc;
  IR: itrec;
begin
  ACount := 0;
  SelDesc := Drawing^.SelObjArray.beginiterate(IR);
  if SelDesc <> nil then
    repeat
      if IsBlockOrProxy(SelDesc^.objaddr) then
      begin
        AItems[ACount] := SelDesc^.objaddr;
        Inc(ACount);
      end;
      SelDesc := Drawing^.SelObjArray.iterate(IR);
    until SelDesc = nil;
end;

{ Возвращает указатель на определение блока для вставки.
  Гарантирует, что определение построено и содержит подпримитивы.
  Если определение не найдено, возвращает nil. }
function GetBlockDef(Insert: PGDBObjBlockInsert;
  var Drawing: TDrawingDef): PGDBObjBlockdef;
var
  BlockArr: PGDBObjBlockdefArray;
  Idx: Integer;
begin
  Result := nil;
  if Insert = nil then
    Exit;
  BlockArr := PGDBObjBlockdefArray(Drawing.GetBlockDefArraySimple);
  if BlockArr = nil then
    Exit;
  Idx := BlockArr^.getindex(Insert^.Name);
  if (Idx < 0) or (Idx >= BlockArr^.Count) then
    Exit;
  Result := BlockArr^.getDataMutable(Idx);
end;

{ Клонирует одну подсущность из массива ObjArray определения блока
  в корень чертежа с применением трансформации. Возвращает указатель
  на клон или nil, если клонировать не удалось.

  Алгоритм повторяет подход команды Copy (uzccommand_copy.pas):
    1. Клон создаётся с исходным владельцем подсущности (определением
       блока или самим прокси-объектом). Это важно: GDBObjCircle.Clone
       и другие Clone-методы после init имеют objmatrix=OneMatrix
       (мусорное значение, неотражающее фактическое положение подсущности
       внутри контейнера). Если сразу сменить владельца, теряется связь
       с корректным objmatrix источника.
    2. Вызывается TransformAt(source, @matrix): objmatrix клона
       вычисляется как source.objmatrix * matrix, то есть «взять
       мировую матрицу подсущности внутри контейнера и умножить на
       матрицу самого контейнера». В результате клон получает корректную
       мировую матрицу. Затем ReCalcFromObjMatrix (виртуально) обновляет
       Local (p_insert, basis, radius и т.п.) из новой objmatrix.
       Это то же самое, что делает команда Copy.
    3. После TransformAt клон перемещается в корень чертежа:
       меняется bp.ListPos.Owner. Так как Local уже содержит мировые
       координаты, повторный CalcObjMatrix внутри FormatEntity (его
       GetMatrix у корня — единичный) даст ту же мировую матрицу.
    4. FormatEntity форматирует клон для отрисовки в чертеже. }
function CloneSubEntityToRoot(SubEntity: PGDBObjEntity;
  Drawing: PTZCADDrawing;
  const ATransform: TzeTypedMatrix4d;
  var DC: TDrawContext): PGDBObjEntity;
var
  Cloned: PGDBObjEntity;
  LocalTransform: TzeTypedMatrix4d;
begin
  Result := nil;
  if SubEntity = nil then
    Exit;
  { Клонируем с тем же владельцем, что и исходная подсущность —
    так же, как это делает команда Copy. }
  Cloned := SubEntity^.Clone(SubEntity^.bp.ListPos.Owner);
  if Cloned = nil then
    Exit;
  { Применяем матрицу родительского объекта (BlockInsert/Proxy)
    через TransformAt(source, matrix). Это ключевое отличие от
    прямого transform(matrix): TransformAt использует objmatrix
    исходной подсущности, а не objmatrix клона (который после Clone
    содержит OneMatrix или мусор). }
  LocalTransform := ATransform;
  Cloned^.TransformAt(SubEntity, @LocalTransform);
  { Переносим клон в корень чертежа. После TransformAt его Local
    уже содержит мировые координаты, так что повторные вызовы
    CalcObjMatrix при новом владельце дадут корректную матрицу. }
  Cloned^.bp.ListPos.Owner := Drawing^.GetCurrentROOT;
  { Форматируем клон: вычисление objmatrix, BBox и пр.
    Наследуем настройки чертежа — после расчленения должны
    остаться осмысленные значения. }
  Cloned^.FormatEntity(Drawing^, DC);
  Result := Cloned;
end;

{ Расчленяет одну вставку блока. Для каждого элемента из определения
  блока создаётся клон в корневом массиве чертежа с применением
  матрицы исходной вставки. Возвращает количество добавленных
  подсущностей (0 если определение пустое или не найдено). }
function ExplodeOneBlockInsert(Insert: PGDBObjBlockInsert;
  Drawing: PTZCADDrawing; var DC: TDrawContext): Integer;
var
  BlockDef: PGDBObjBlockdef;
  SubEntity, Cloned: PGDBObjEntity;
  IR: itrec;
  Transform: TzeTypedMatrix4d;
begin
  Result := 0;
  BlockDef := GetBlockDef(Insert, Drawing^);
  if BlockDef = nil then
    Exit;
  { Убедимся, что подсущности блока отформатированы — без этого их
    objmatrix может быть устаревшим/единичным, что приведёт к
    неправильной работе TransformAt(source, matrix) при клонировании.
    FormatEntity ставит Formated=True и повторные вызовы безопасны. }
  if not BlockDef^.Formated then
    BlockDef^.FormatEntity(PTDrawingDef(Drawing)^, DC);
  { Убедимся, что матрица вставки актуальна — её подсущности имеют
    относительные координаты внутри определения блока, матрица вставки
    переводит их в координаты чертежа с учётом base-point блока. }
  Insert^.CalcObjMatrix(PTDrawingDef(Drawing));
  Transform := Insert^.objMatrix;
  SubEntity := BlockDef^.ObjArray.beginiterate(IR);
  if SubEntity <> nil then
    repeat
      { Для каждой подсущности предварительно форматируем её
        непосредственно — это гарантирует актуальность objmatrix
        даже у подсущностей, не охваченных общим FormatEntity
        определения блока (например, вложенных BlockInsert). }
      SubEntity^.FormatEntity(PTDrawingDef(Drawing)^, DC);
      Cloned := CloneSubEntityToRoot(SubEntity, Drawing, Transform, DC);
      if Cloned <> nil then
      begin
        zcAddEntToDrawingWithUndo(Cloned, Drawing^);
        Inc(Result);
      end;
      SubEntity := BlockDef^.ObjArray.iterate(IR);
    until SubEntity = nil;
end;

{ Расчленяет один прокси-объект. Подсущности прокси уже лежат в
  ConstObjArray после BuildSubEntities; достаточно клонировать их
  с учётом матрицы прокси-объекта. Если подсущности ещё не построены,
  форматирование прокси их построит. Возвращает число добавленных
  подсущностей.

  Ключевая особенность: после Proxy.FormatEntity подсущности в
  ConstObjArray имеют владельцем сам прокси-объект, поэтому их
  objmatrix уже содержит мировую матрицу (Local * Proxy.objmatrix,
  см. GDBObjWithLocalCS.CalcObjMatrix). Поэтому в качестве матрицы
  трансформации передаётся единичная матрица: TransformAt(source, I)
  присвоит objmatrix клона = source.objmatrix, то есть сохранит
  мировые координаты подсущности в чертеже. }
function ExplodeOneProxyEntity(Proxy: PGDBObjAcdProxy;
  Drawing: PTZCADDrawing; var DC: TDrawContext): Integer;
var
  SubEntity, Cloned: PGDBObjEntity;
  IR: itrec;
  IdentityTransform: TzeTypedMatrix4d;
begin
  Result := 0;
  { Принудительное форматирование гарантирует, что ConstObjArray
    заполнен, матрица objMatrix прокси соответствует текущим
    scale/rotate, и подсущности имеют актуальные objmatrix в
    мировых координатах. }
  Proxy^.FormatEntity(Drawing^, DC);
  IdentityTransform := OneMatrix;
  SubEntity := Proxy^.ConstObjArray.beginiterate(IR);
  if SubEntity <> nil then
    repeat
      Cloned := CloneSubEntityToRoot(SubEntity, Drawing,
        IdentityTransform, DC);
      if Cloned <> nil then
      begin
        zcAddEntToDrawingWithUndo(Cloned, Drawing^);
        Inc(Result);
      end;
      SubEntity := Proxy^.ConstObjArray.iterate(IR);
    until SubEntity = nil;
end;

{ Удаляет оригинальный BlockInsert или ProxyEntity из массива его
  владельца с регистрацией undo-команды. Снимает выделение с объекта
  перед удалением, чтобы счётчики выделенного остались согласованными.
  Логика повторяет команду Erase: Do-метод — удалить из массива,
  Undo-метод — добавить обратно. }
procedure EraseOriginalWithUndo(Entity: PGDBObjEntity;
  Drawing: PTZCADDrawing);
var
  RemoveMethod, AddMethod: TMethod;
  Owner: PGDBObjGenericSubEntry;
begin
  if Entity = nil then
    Exit;
  Owner := PGDBObjGenericSubEntry(Entity^.bp.ListPos.Owner);
  if Owner = nil then
    Exit;
  { Формируем Do-метод (удаление) и Undo-метод (восстановление).
    PushMultiObjectCreateCommand принимает (dodata, undodata). }
  RemoveMethod.Code := Pointer(Owner^.GoodRemoveMiFromArray);
  RemoveMethod.Data := Owner;
  AddMethod.Code := Pointer(Owner^.GoodAddObjectToObjArray);
  AddMethod.Data := Owner;
  with PushMultiObjectCreateCommand(Drawing^.UndoStack,
    TMethod(RemoveMethod), TMethod(AddMethod), 1) do
  begin
    AddObject(Entity);
    Entity^.Selected := False;
    FreeArray := False;
    comit;
  end;
end;

{ Сбрасывает служебные дескрипторы выделения после удаления
  исходных объектов. Аналогично логике команды Erase. }
procedure ResetSelectionDescriptors(Drawing: PTZCADDrawing);
begin
  Drawing^.wa.param.seldesc.Selectedobjcount := 0;
  Drawing^.wa.param.seldesc.OnMouseObject := nil;
  Drawing^.wa.param.seldesc.LastSelectedObject := nil;
  Drawing^.wa.param.lastonmouseobject := nil;
end;

{ Выполняет расчленение одного объекта: определяет его тип и вызывает
  соответствующий обработчик. После добавления подсущностей удаляет
  исходный объект с регистрацией undo. Возвращает число созданных
  подсущностей. }
function ExplodeOneEntity(Entity: PGDBObjEntity;
  Drawing: PTZCADDrawing; var DC: TDrawContext): Integer;
begin
  Result := 0;
  case Entity^.GetObjType of
    GDBBlockInsertID:
      Result := ExplodeOneBlockInsert(PGDBObjBlockInsert(Entity),
        Drawing, DC);
    GDBAcdProxyID:
      Result := ExplodeOneProxyEntity(PGDBObjAcdProxy(Entity),
        Drawing, DC);
  end;
  if Result > 0 then
    EraseOriginalWithUndo(Entity, Drawing);
end;

{ Основная процедура команды ExplodeBlockProxy.
  Проверяет выделение, собирает список допустимых объектов и расчленяет
  их по одному. Все операции объединяются в одну транзакцию undo. }
function ExplodeBlockProxy_cmd(const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
var
  Drawing: PTZCADDrawing;
  DC: TDrawContext;
  Items: array of PGDBObjEntity;
  ItemCount, SubCount, TotalSubCount, I: Integer;
  UndoStartMarkerPlaced: Boolean;
begin
  Result := cmd_ok;
  Drawing := Context.PDWG;
  if Drawing = nil then
    Exit;
  { Проверка выделения: пусто или содержит посторонние примитивы.
    В обоих случаях команда отказывается работать и выводит
    пояснительное сообщение пользователю. }
  if not AreAllSelectedBlocksOrProxy(Drawing, ItemCount) then
  begin
    zcUI.TextMessage(RSExplodeSelectOnlyBlocksOrProxy, TMWOHistoryOut);
    Exit;
  end;
  SetLength(Items, ItemCount);
  CollectSelectedBlocksOrProxy(Drawing, Items, ItemCount);
  if ItemCount = 0 then
    Exit;
  TotalSubCount := 0;
  UndoStartMarkerPlaced := False;
  DC := Drawing^.CreateDrawingRC;
  for I := 0 to ItemCount - 1 do
  begin
    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,
      'ExplodeBlockProxy');
    SubCount := ExplodeOneEntity(Items[I], Drawing, DC);
    Inc(TotalSubCount, SubCount);
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  if TotalSubCount > 0 then
  begin
    ResetSelectionDescriptors(Drawing);
    zcUI.Do_GUIaction(nil, zcMsgUIReturnToDefaultObject);
    zcRedrawCurrentDrawing;
    zcUI.TextMessage(Format(rscmNEntitiesProcessed, [ItemCount]),
      TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_explodeblockproxy: exploded %d entities into %d parts',
      [ItemCount, TotalSubCount], LM_Info);
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',
    [{$INCLUDE %FILE%}], LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@ExplodeBlockProxy_cmd, 'ExplodeBlockProxy',
    CADWG or CASelEnts, 0);

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization',
    [{$INCLUDE %FILE%}], LM_Info, UnitsFinalizeLMId);
end.
