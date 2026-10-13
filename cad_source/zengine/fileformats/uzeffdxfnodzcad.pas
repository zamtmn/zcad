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
  Модуль: uzeffdxfnodzcad
  Назначение: NOD-обработчик собственного ключа ZCAD (этап 7 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  Ключ CNODZCADDataKey ('ZCAD_DATA') зарезервирован: обработчик
  регистрируется в initialization, как обработчики стилей, поэтому ветка
  ZCAD_DATA загружаемого файла не сохраняется как «чужая» (реестр забирает
  её словарь). Наполнение ветки (что ZCAD хранит в DXF) — вне рамок ТЗ:
  LoadProc только пишет содержимое словаря в трассу, при записи ветка не
  выводится (ReserveHandlesProc/SaveProc нет).
}
unit uzeffdxfnodzcad;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzedrawingsimple,
  uzeffdxfnod,
  uzeffdxfnodregistry;

{ Регистрирует обработчик ключа ZCAD_DATA (вызывается в initialization) }
procedure RegisterZCADDataNODHandler;

implementation

uses
  uzeffdxfnodlog;

procedure ZCADDataNODLoad(const AModel: TZNODModel;
  const ADict: TZDXFDictionary; var ADrawing: TSimpleDrawing);
var
  I: Integer;
begin
  for I := 0 to ADict.Count - 1 do
    NODLogTraceFormatStr(
      'uzeffdxfnodzcad: load: key "%s": entry "%s" is ignored',
      [CNODZCADDataKey, ADict[I].Key]);
end;

procedure RegisterZCADDataNODHandler;
var
  h: TZNODHandler;
begin
  h := Default(TZNODHandler);
  h.Key := CNODZCADDataKey;
  h.ObjectType := 'DICTIONARY';
  h.MinVersion := CNODHandlerDefaultMinVersion;
  h.LoadProc := ZCADDataNODLoad;
  RegisterNODHandler(h);
end;

initialization
  RegisterZCADDataNODHandler;
end.
