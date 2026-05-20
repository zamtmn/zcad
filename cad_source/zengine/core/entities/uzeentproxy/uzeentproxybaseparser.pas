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
  Модуль: uzeentproxybaseparser
  Назначение: Базовый класс для парсеров Proxy примитивов
  
  Упрощает создание новых парсеров, предоставляя:
  - Реализацию интерфейса IProxyPrimitiveParser
  - Базовую функциональность (валидация, ошибки)
  - Вспомогательные методы для работы с координатами
}

unit uzeentproxybaseparser;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzeentproxytypes,
  uzeentproxymanager,
  uzeentity,
  uzedrawingdef,
  uzeTypes,
  uzeGeometryTypes,
  uzegeometry;

type
  { Базовый класс парсера Proxy примитива }
  TProxyBaseParser = class(TInterfacedObject, IProxyPrimitiveParser)
  protected
    FValid: Boolean;
    FErrorMsg: string;
    FPrimitiveType: TProxyPrimitiveType;
    
    { Преобразование точки в OCS }
    function TransformToOCS(const Point: TzePoint3d; const Normal: TzePoint3d): TzePoint3d;
    
    { Нормализация угла }
    function NormalizeAngle(Angle: Double): Double;
    
    { Проверка близости векторов }
    function VectorIsClose(const V1, V2: TzePoint3d; const Epsilon: Double = 1e-14): Boolean;
    
    { Абстрактные методы - переопределяются в потомках }
    function DoParseFromStream(Stream: TObject; CommandSize: Integer): Boolean; virtual; abstract;
    function DoCreateZCDEntity(const Drawing: TDrawingDef; const State: TProxyGraphicState): PGDBObjEntity; virtual; abstract;
    procedure DoExpandBoundingBox(var MinPt, MaxPt: TzePoint3d); virtual; abstract;
    
  public
    { Реализация интерфейса IProxyPrimitiveParser }
    function ParseFromStream(Stream: TObject; CommandSize: Integer): Boolean; virtual;
    function IsValid: Boolean; virtual;
    function GetErrorMsg: string; virtual;
    function CreateZCDEntity(const Drawing: TDrawingDef; const State: TProxyGraphicState): PGDBObjEntity; virtual;
    procedure ExpandBoundingBox(var MinPt, MaxPt: TzePoint3d); virtual;
    function GetPrimitiveType: TProxyPrimitiveType; virtual;
    
    { Свойства }
    property Valid: Boolean read FValid;
    property ErrorMsg: string read FErrorMsg;
    property PrimitiveType: TProxyPrimitiveType read FPrimitiveType;
  end;

{ Вспомогательные функции }
function VectorIsClose(const V1, V2: TzePoint3d; const Epsilon: Double = 1e-14): Boolean; inline;
function VectorNormalize(const V: TzePoint3d): TzePoint3d; inline;
function CrossProduct(const V1, V2: TzePoint3d): TzePoint3d; inline;

implementation

uses
  Math,
  uzcLog;
  //uzeentproxyparser;

const
  PROXY_X_AXIS: TzePoint3d = (x: 1.0; y: 0.0; z: 0.0);
  PROXY_Y_AXIS: TzePoint3d = (x: 0.0; y: 1.0; z: 0.0);

{ === Вспомогательные функции === }

function VectorIsClose(const V1, V2: TzePoint3d; const Epsilon: Double): Boolean;
begin
  Result := (Abs(V1.x - V2.x) <= Epsilon) and
            (Abs(V1.y - V2.y) <= Epsilon) and
            (Abs(V1.z - V2.z) <= Epsilon);
end;

function VectorNormalize(const V: TzePoint3d): TzePoint3d;
var
  Len: Double;
begin
  Len := Sqrt(V.x * V.x + V.y * V.y + V.z * V.z);
  if Len > 0 then
  begin
    Result.x := V.x / Len;
    Result.y := V.y / Len;
    Result.z := V.z / Len;
  end
  else
    Result := V;
end;

function CrossProduct(const V1, V2: TzePoint3d): TzePoint3d;
begin
  Result.x := V1.y * V2.z - V1.z * V2.y;
  Result.y := V1.z * V2.x - V1.x * V2.z;
  Result.z := V1.x * V2.y - V1.y * V2.x;
end;

{ === TProxyBaseParser === }

function TProxyBaseParser.TransformToOCS(const Point: TzePoint3d; const Normal: TzePoint3d): TzePoint3d;
var
  XAxis, YAxis, ZAxis: TzePoint3d;
begin
  ZAxis := VectorNormalize(Normal);
  
  { Вычисляем оси X и Y используя произвольную ось }
  if Abs(ZAxis.x) < 0.9 then
    XAxis := NormalizeVertex(PROXY_X_AXIS * ZAxis.z - ZAxis * PROXY_X_AXIS.z)
  else
    XAxis := NormalizeVertex(PROXY_Y_AXIS * ZAxis.z - ZAxis * PROXY_Y_AXIS.z);
    
  YAxis := NormalizeVertex(ZAxis * XAxis.x - XAxis * ZAxis.x);
  
  { Преобразование точки из WCS в OCS }
  Result.x := scalarDot(Point, XAxis);
  Result.y := scalarDot(Point, YAxis);
  Result.z := scalarDot(Point, ZAxis);
end;

function TProxyBaseParser.NormalizeAngle(Angle: Double): Double;
begin
  Result := Angle;
  while Result < 0 do
    Result := Result + 2 * Pi;
  while Result >= 2 * Pi do
    Result := Result - 2 * Pi;
end;

function TProxyBaseParser.VectorIsClose(const V1, V2: TzePoint3d; const Epsilon: Double): Boolean;
begin
  Result := uzeentproxybaseparser.VectorIsClose(V1, V2, Epsilon);
end;

function TProxyBaseParser.ParseFromStream(Stream: TObject; CommandSize: Integer): Boolean;
begin
  try
    FValid := False;
    FErrorMsg := '';
    Result := DoParseFromStream(Stream, CommandSize);
    FValid := Result;
  except
    on E: Exception do
    begin
      FValid := False;
      FErrorMsg := 'Parse error: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TProxyBaseParser.IsValid: Boolean;
begin
  Result := FValid;
end;

function TProxyBaseParser.GetErrorMsg: string;
begin
  Result := FErrorMsg;
end;

function TProxyBaseParser.CreateZCDEntity(const Drawing: TDrawingDef; const State: TProxyGraphicState): PGDBObjEntity;
begin
  if FValid then
    Result := DoCreateZCDEntity(Drawing, State)
  else
    Result := nil;
end;

procedure TProxyBaseParser.ExpandBoundingBox(var MinPt, MaxPt: TzePoint3d);
begin
  if FValid then
    DoExpandBoundingBox(MinPt, MaxPt);
end;

function TProxyBaseParser.GetPrimitiveType: TProxyPrimitiveType;
begin
  Result := FPrimitiveType;
end;

end.
