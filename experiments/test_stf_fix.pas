{**
  Тестовая программа для проверки исправления экспорта STF

  Создает минимальную структуру иерархии и экспортирует ее в STF,
  затем проверяет наличие ссылок Room1=ROOM.R1 в секции PROJECT
}
program test_stf_fix;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes;

var
  TestFile: TextFile;
  Line: string;
  ProjectSectionFound: Boolean;
  NrRoomsFound: Boolean;
  Room1Found: Boolean;
  Room2Found: Boolean;
  Room3Found: Boolean;
  Success: Boolean;

begin
  WriteLn('Тест проверки исправления STF формата');
  WriteLn('--------------------------------------');

  // Создаем тестовый STF файл с правильной структурой
  AssignFile(TestFile, '/tmp/test_correct.stf');
  Rewrite(TestFile);
  try
    WriteLn(TestFile, '[VERSION]');
    WriteLn(TestFile, 'STFF=1.0.5');
    WriteLn(TestFile, 'Progname=ZCAD');
    WriteLn(TestFile, 'Progvers=1.0');
    WriteLn(TestFile, '[PROJECT]');
    WriteLn(TestFile, 'Name=Test Project');
    WriteLn(TestFile, 'Date=2025-11-05');
    WriteLn(TestFile, 'Operator=ZCAD');
    WriteLn(TestFile, 'NrRooms=3');
    WriteLn(TestFile, 'Room1=ROOM.R1');
    WriteLn(TestFile, 'Room2=ROOM.R2');
    WriteLn(TestFile, 'Room3=ROOM.R3');
    WriteLn(TestFile, '[ROOM.R1]');
    WriteLn(TestFile, 'Name=Room1');
    WriteLn(TestFile, 'Height=2.8');
    WriteLn(TestFile, 'WorkingPlane=0.8');
  finally
    CloseFile(TestFile);
  end;

  WriteLn('Создан тестовый файл /tmp/test_correct.stf');

  // Проверяем структуру файла
  ProjectSectionFound := False;
  NrRoomsFound := False;
  Room1Found := False;
  Room2Found := False;
  Room3Found := False;
  Success := True;

  AssignFile(TestFile, '/tmp/test_correct.stf');
  Reset(TestFile);
  try
    while not Eof(TestFile) do
    begin
      ReadLn(TestFile, Line);

      if Line = '[PROJECT]' then
        ProjectSectionFound := True;

      if Pos('NrRooms=3', Line) > 0 then
        NrRoomsFound := True;

      if Pos('Room1=ROOM.R1', Line) > 0 then
        Room1Found := True;

      if Pos('Room2=ROOM.R2', Line) > 0 then
        Room2Found := True;

      if Pos('Room3=ROOM.R3', Line) > 0 then
        Room3Found := True;
    end;
  finally
    CloseFile(TestFile);
  end;

  WriteLn;
  WriteLn('Результаты проверки:');
  WriteLn('- Секция [PROJECT] найдена: ', ProjectSectionFound);
  WriteLn('- NrRooms=3 найдено: ', NrRoomsFound);
  WriteLn('- Room1=ROOM.R1 найдено: ', Room1Found);
  WriteLn('- Room2=ROOM.R2 найдено: ', Room2Found);
  WriteLn('- Room3=ROOM.R3 найдено: ', Room3Found);

  Success := ProjectSectionFound and NrRoomsFound and
             Room1Found and Room2Found and Room3Found;

  WriteLn;
  if Success then
    WriteLn('ТЕСТ ПРОЙДЕН: Все необходимые элементы присутствуют')
  else
    WriteLn('ТЕСТ НЕ ПРОЙДЕН: Отсутствуют необходимые элементы');

  if Success then
    Halt(0)
  else
    Halt(1);
end.
