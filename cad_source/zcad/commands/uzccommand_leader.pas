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

{
  Модуль: uzccommand_leader
  Назначение:
    Команда LEADER — создаёт выноску (leader/callout), аналогичную команде
    LEADER в AutoCAD.

  Команда реализована по той же схеме, что и uzccommand_rotate.pas:
    - та же архитектура (конечный автомат с режимами CmdMode);
    - тот же способ регистрации команды (CreateZCADCommand);
    - те же механизмы работы с командной строкой
      (SetPrompt/ChangeInputMode/Get3DPoint*/GetInput);
    - тот же стиль взаимодействия с пользователем.
  Интерактивное построение примитива (предпросмотр) выполнено по образцу
  uzccommand_spline.pas (конструкторская область + манипулятор).

  Алгоритм работы:
    1. Запрос первой исходной точки  ("Specify first source point:").
    2. Запрос второй исходной точки   ("Specify second source point:").
    3. Создаётся примитив выноски, две точки попадают в конструкторскую
       область для предпросмотра.
    4. Меню в командной строке:
         Next point or [Annotation Format Undo] <Annotation>:
       - левый клик мышью — добавляет очередную точку выноски;
       - Annotation (A) / правый клик / пустой Enter — завершить построение
         выноски и асинхронно запустить команду MTEXT в конце выноски;
       - Format (F) — подменю настройки формата выноски:
           Specify parameter for leader format
             [Spline Segments Arrow Nothing] <Exit>:
           Spline   (S) — сплайновая выноска (PathType=1), затем возврат
                          в предыдущее меню;
           Segments (G) — выноска отрезками (PathType=0), затем возврат
                          в предыдущее меню;
           Arrow    (A) — со стрелкой (ArrowHeadFlag=1), затем возврат
                          в предыдущее меню;
           Nothing  (N) — без стрелки  (ArrowHeadFlag=0), затем возврат
                          в предыдущее меню;
           Exit     (X) / пустой Enter — вернуться в предыдущее меню;
       - Undo (U) — отменить последнюю введённую точку.
    5. ESC отменяет команду без каких-либо изменений в чертеже.

  Зависимости:
    uzccommandsmanager, uzccommandsimpl, uzccommandsabstract,
    uzcdrawings, uzegeometry, uzegeometrytypes, uzeentity, uzeentityfactory,
    uzeentleader, uzcutils, uzcinterface, uzeparsercmdprompt, uzeconsts,
    UGDBPoint3DArray, Forms.
}

unit uzccommand_leader;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Forms,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,
  uzegeometrytypes,uzegeometry,
  uzccommandsmanager,
  uzeentleader,uzeentity,uzeentityfactory,
  uzcutils,
  uzcdrawings,
  uzcinterface,
  uzeparsercmdprompt,
  UGDBPoint3DArray;

implementation

resourcestring
  RSCLPLeaderFirstPoint  = 'Specify first source point:';
  RSCLPLeaderSecondPoint = 'Specify second source point:';
  RSCLPLeaderNextPoint   =
    'Next point or [${"&[A]nnotation",Keys[a],StrId[CLPIdUser1]}, ' +
    '${"&[F]ormat",Keys[f],StrId[CLPIdUser2]}, ' +
    '${"&[U]ndo",Keys[u],StrId[CLPIdUser3]}] <Annotation>:';
  RSCLPLeaderFormat      =
    'Specify parameter for leader format ' +
    '[${"&[S]pline",Keys[s],Id[10010]}, ' +
    '${"Se&[g]ments",Keys[g],Id[10011]}, ' +
    '${"&[A]rrow",Keys[a],Id[10012]}, ' +
    '${"&[N]othing",Keys[n],Id[10013]}, ' +
    '${"e&[X]it",Keys[x],Id[10014]}] <Exit>:';

const
  // Идентификаторы пунктов подменю "Format"
  LeaderIdSpline   = 10010;
  LeaderIdSegments = 10011;
  LeaderIdArrow    = 10012;
  LeaderIdNothing  = 10013;
  LeaderIdExit     = 10014;

  CommandName = 'Leader';

type
  PLeaderInteractiveData = ^TLeaderInteractiveData;

  TLeaderInteractiveData = record
    PLeader:PGDBObjLeader;
    UserPoints:GDBPoint3dArray;
  end;

{
  Асинхронно запускаемая команда MTEXT.
  Вызывается через Application.QueueAsyncCall после завершения команды LEADER,
  иначе commandmanager.executecommand откажется запускать команду в состоянии
  isBusy. QueueAsyncCall требует метод объекта (of object), поэтому используется
  вспомогательный класс TAsyncMTextRunner (по образцу uzccommand_createblockinsert).
}
type
  TAsyncMTextRunner = class
    Active:boolean;
    procedure RunMText(Data:PtrInt);
  end;

procedure TAsyncMTextRunner.RunMText(Data:PtrInt);
begin
  if not Active then
    Exit;
  Active:=False;
  commandmanager.executecommand(
    'Text(MTEXT)',
    drawings.GetCurrentDWG,
    drawings.GetCurrentOGLWParam
  );
end;

var
  clNextPoint:CMDLinePromptParser.TGeneralParsedText=nil;
  clFormat:CMDLinePromptParser.TGeneralParsedText=nil;
  AsyncMTextRunner:TAsyncMTextRunner;

{
  Перестраивает массив вершин выноски из накопленных пользователем точек
  и (опционально) добавляет временную preview-точку, идущую за курсором.
}
procedure RebuildLeaderVertices(PLeader:PGDBObjLeader;
  var UserPoints:GDBPoint3dArray;AddPreview:boolean;
  const PreviewPoint:TzePoint3d);
var
  i:integer;
begin
  PLeader^.VertexArrayInOCS.Clear;
  for i:=0 to UserPoints.Count-1 do
    PLeader^.AddVertex(UserPoints.getDataMutable(i)^);
  if AddPreview then
    PLeader^.AddVertex(PreviewPoint);
end;

{
  Манипулятор предпросмотра (по образцу InteractiveSplineManipulator):
  на каждое перемещение мыши перестраивает выноску из накопленных точек
  плюс текущая точка курсора.
}
procedure InteractiveLeaderManipulator(const PInteractiveData:PLeaderInteractiveData;
  Point:TzePoint3d;Click:boolean);
begin
  if PInteractiveData^.PLeader=nil then
    exit;
  RebuildLeaderVertices(PInteractiveData^.PLeader,PInteractiveData^.UserPoints,
    True,Point);
  zcSetEntPropFromCurrentDrawingProp(PInteractiveData^.PLeader);
  PInteractiveData^.PLeader^.YouChanged(drawings.GetCurrentDWG^);
end;

{
  Обновляет предпросмотр без preview-точки (после Undo либо смены формата).
}
procedure RefreshLeaderPreview(var interactiveData:TLeaderInteractiveData);
begin
  if interactiveData.PLeader=nil then
    exit;
  RebuildLeaderVertices(interactiveData.PLeader,
    interactiveData.UserPoints,False,NulVertex);
  zcSetEntPropFromCurrentDrawingProp(interactiveData.PLeader);
  interactiveData.PLeader^.YouChanged(drawings.GetCurrentDWG^);
  zcRedrawCurrentDrawing;
end;

function Leader_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
type
  TLeaderCmdMode=(LCMWaitNext,LCMWaitFormat);
var
  interactiveData:TLeaderInteractiveData;
  p1,p2,p:TzePoint3d;
  pe:PGDBObjEntity;
  CmdMode:TLeaderCmdMode;
  gr:TzcInteractiveResult;
  inputStr:string;
  finished,cancelled,doMText:boolean;

  procedure SetLeaderCmdMode(ANewMode:TLeaderCmdMode);
  begin
    case ANewMode of
      LCMWaitNext:begin
        if clNextPoint=nil then
          clNextPoint:=CMDLinePromptParser.GetTokens(RSCLPLeaderNextPoint);
        commandmanager.SetPrompt(clNextPoint);
        commandmanager.ChangeInputMode([IPEmpty],[]);
      end;
      LCMWaitFormat:begin
        if clFormat=nil then
          clFormat:=CMDLinePromptParser.GetTokens(RSCLPLeaderFormat);
        commandmanager.SetPrompt(clFormat);
        commandmanager.ChangeInputMode([IPEmpty],[]);
      end;
    end;
    CmdMode:=ANewMode;
  end;

begin
  Result:=cmd_ok;
  finished:=False;
  cancelled:=False;
  doMText:=False;
  interactiveData.PLeader:=nil;
  interactiveData.UserPoints.init(100);

  // Шаг 1-2: запрос двух исходных точек (обязательны, пустой Enter запрещён)
  commandmanager.ChangeInputMode([],[IPEmpty]);
  if commandmanager.Get3DPoint(RSCLPLeaderFirstPoint,p1)=IRNormal then
    if commandmanager.Get3DPointWithLineFromBase(RSCLPLeaderSecondPoint,p1,p2)=
      IRNormal then begin

      // Шаг 3: создаём примитив выноски и добавляем его в конструкторскую область
      interactiveData.PLeader:=AllocEnt(GDBLeaderID);
      interactiveData.PLeader^.init(nil,nil,LnWtByLayer);
      interactiveData.UserPoints.PushBackData(p1);
      interactiveData.UserPoints.PushBackData(p2);
      RebuildLeaderVertices(interactiveData.PLeader,interactiveData.UserPoints,
        False,NulVertex);

      pe:=PGDBObjEntity(interactiveData.PLeader);
      zcAddEntToCurrentDrawingConstructRoot(pe);
      interactiveData.PLeader:=PGDBObjLeader(pe);

      // Шаг 4: основной цикл-автомат (по схеме uzccommand_rotate)
      SetLeaderCmdMode(LCMWaitNext);
      repeat
        case CmdMode of
          LCMWaitNext:
            gr:=commandmanager.Get3DPointInteractive('',p,
              @InteractiveLeaderManipulator,@interactiveData);
          LCMWaitFormat:
            gr:=commandmanager.GetInput('',inputStr);
        else
          gr:=IRCancel;
        end;

        case gr of
          IRNormal:
            case CmdMode of
              LCMWaitNext:
                interactiveData.UserPoints.PushBackData(p);
              LCMWaitFormat:
                // Любой ввод текста в подменю формата трактуем как выход
                SetLeaderCmdMode(LCMWaitNext);
            end;
          IRInput:
            case CmdMode of
              LCMWaitNext:begin
                // Пустой Enter = значение по умолчанию <Annotation>
                doMText:=True;
                finished:=True;
              end;
              LCMWaitFormat:
                // Пустой Enter = значение по умолчанию <Exit>
                SetLeaderCmdMode(LCMWaitNext);
            end;
          IRId:
            case CmdMode of
              LCMWaitNext:
                case commandmanager.GetLastId of
                  CLPIdUser1:begin // Annotation
                    doMText:=True;
                    finished:=True;
                  end;
                  CLPIdUser2: // Format
                    SetLeaderCmdMode(LCMWaitFormat);
                  CLPIdUser3:begin // Undo
                    if interactiveData.UserPoints.Count>2 then begin
                      interactiveData.UserPoints.DeleteElement(
                        interactiveData.UserPoints.Count-1);
                      RefreshLeaderPreview(interactiveData);
                    end else
                      zcUI.TextMessage(
                        'Leader must contain at least two points.',
                        TMWOHistoryOut);
                  end;
                end;
              LCMWaitFormat:
                case commandmanager.GetLastId of
                  LeaderIdSpline:begin
                    interactiveData.PLeader^.PathType:=1;
                    RefreshLeaderPreview(interactiveData);
                    // После выбора формата возвращаемся в предыдущее меню
                    SetLeaderCmdMode(LCMWaitNext);
                  end;
                  LeaderIdSegments:begin
                    interactiveData.PLeader^.PathType:=0;
                    RefreshLeaderPreview(interactiveData);
                    // После выбора формата возвращаемся в предыдущее меню
                    SetLeaderCmdMode(LCMWaitNext);
                  end;
                  LeaderIdArrow:begin
                    interactiveData.PLeader^.ArrowHeadFlag:=1;
                    RefreshLeaderPreview(interactiveData);
                    // После выбора формата возвращаемся в предыдущее меню
                    SetLeaderCmdMode(LCMWaitNext);
                  end;
                  LeaderIdNothing:begin
                    interactiveData.PLeader^.ArrowHeadFlag:=0;
                    RefreshLeaderPreview(interactiveData);
                    // После выбора формата возвращаемся в предыдущее меню
                    SetLeaderCmdMode(LCMWaitNext);
                  end;
                  LeaderIdExit:
                    SetLeaderCmdMode(LCMWaitNext);
                end;
            end;
          IRCancel:
            cancelled:=True;
        end;
      until finished or cancelled;

      if cancelled then begin
        // ESC: никаких изменений в чертеже — просто очищаем предпросмотр
        zcClearCurrentDrawingConstructRoot;
        zcRedrawCurrentDrawing;
      end else begin
        // Завершение: фиксируем выноску из накопленных точек (без preview-точки)
        RebuildLeaderVertices(interactiveData.PLeader,
          interactiveData.UserPoints,False,NulVertex);
        zcSetEntPropFromCurrentDrawingProp(interactiveData.PLeader);
        zcAddEntToCurrentDrawingWithUndo(interactiveData.PLeader);
        zcClearCurrentDrawingConstructRoot;
        zcRedrawCurrentDrawing;

        // Annotation/правый клик/Enter: асинхронно запускаем MTEXT в конце выноски
        if doMText then begin
          AsyncMTextRunner.Active:=True;
          Application.QueueAsyncCall(AsyncMTextRunner.RunMText,0);
        end;
      end;
    end;

  interactiveData.UserPoints.done;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  AsyncMTextRunner:=TAsyncMTextRunner.Create;
  CreateZCADCommand(@Leader_com,CommandName,CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  clNextPoint.Free;
  clFormat.Free;
  FreeAndNil(AsyncMTextRunner);
end.
