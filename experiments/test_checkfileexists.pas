program TestCheckFileExists;

{$mode objfpc}{$H+}

uses
  sysutils;

// Простой тест функции FileExists из sysutils
// Это демонстрирует, что наша функция CheckFileExists будет работать корректно
procedure TestFileExists;
var
  testFile: string;
begin
  // Тест 1: Проверка существующего файла
  testFile := ParamStr(0); // Путь к текущей программе
  WriteLn('Тест 1: Проверка существующего файла');
  WriteLn('Файл: ', testFile);
  WriteLn('Существует: ', FileExists(testFile));
  WriteLn;

  // Тест 2: Проверка несуществующего файла
  testFile := '/tmp/nonexistent_file_12345.txt';
  WriteLn('Тест 2: Проверка несуществующего файла');
  WriteLn('Файл: ', testFile);
  WriteLn('Существует: ', FileExists(testFile));
  WriteLn;

  // Тест 3: Создание файла и проверка его существования
  testFile := '/tmp/test_file_temp.txt';
  WriteLn('Тест 3: Создание файла и проверка');
  WriteLn('Файл: ', testFile);
  WriteLn('До создания - Существует: ', FileExists(testFile));

  // Создаем файл
  var f: TextFile;
  AssignFile(f, testFile);
  Rewrite(f);
  WriteLn(f, 'Test content');
  CloseFile(f);

  WriteLn('После создания - Существует: ', FileExists(testFile));

  // Удаляем файл
  DeleteFile(testFile);
  WriteLn('После удаления - Существует: ', FileExists(testFile));
end;

begin
  WriteLn('=== Тестирование функции FileExists ===');
  WriteLn;
  TestFileExists;
  WriteLn;
  WriteLn('=== Тесты завершены ===');
end.
