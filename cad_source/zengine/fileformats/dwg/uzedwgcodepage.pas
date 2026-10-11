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

{ Модуль: uzedwgcodepage
  Назначение: определение кодовой страницы чертежа ZCAD (DXFCodePage)
    по кодовой странице из заголовка DWG/DXF, прочитанного LibreDWG
    (issue #1438).
  Дата создания: 2026-09-27
  Зависимости: uzedwgtext (карта кодовых страниц LibreDWG),
    uzeffdxfsupport (кодовые страницы ZCAD), uzeTypes. }

unit uzedwgcodepage;

{$Mode objfpc}{$H+}

interface

uses
  uzeTypes;

function DWGHeaderCodePageToZCCodePage(DWGCodePage:Integer):TZCCodePage;

implementation

uses
  uzedwgtext,
  uzeffdxfsupport;

{ Преобразует кодовую страницу из заголовка DWG (индекс Dwg_Codepage
  LibreDWG или номер кодовой страницы Windows) в кодовую страницу ZCAD.
  После чтения DWG все строки хранятся в UTF-8, а при сохранении в DXF2000
  перекодируются в DXFCodePage чертежа, поэтому она должна соответствовать
  исходному файлу. Если страница не может быть $DWGCODEPAGE (UTF-8, UTF-16,
  неизвестное значение), берётся кодовая страница для новых чертежей
  SysDWG_CodePage. }
function DWGHeaderCodePageToZCCodePage(DWGCodePage:Integer):TZCCodePage;
var
  SystemCodePage:TSystemCodePage;
begin
  Result:=ZCCPINVALID;
  if DWGLibreCodePageToSystem(DWGCodePage,SystemCodePage) then
    Result:=SysCP2ZCCodePage(SystemCodePage);
  if Result=ZCCPINVALID then
    Result:=sysvarSysDWG_CodePage;
end;

end.
