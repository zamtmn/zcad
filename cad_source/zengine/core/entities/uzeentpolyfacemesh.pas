{На базе кода сгенерированного ИИ}


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
unit uzeentpolyfacemesh;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
  uzestyleslayers,uzeentsubordinated,uzeentcurve,UGDBSelectedObjArray,
  uzeentity,uzctnrVectorBytesStream,uzeTypes,uzeconsts,uzglviewareadata,
  uzegeometrytypes,uzegeometry,uzeffdxfsupport,SysUtils,uzesnap,
  uzMVReader,uzCtnrVectorpBaseEntity,uzbLogIntf,uzclog, gzctnrVector,
  uzcinterface;

type
  // Структура для хранения индексов вершин грани
  TFaceIndices = record
    Vertex1: Integer;
    Vertex2: Integer;
    Vertex3: Integer;
    Vertex4: Integer;
    VertexCount: Integer; // Количество вершин в грани (3 или 4)
  end;

  PFaceIndices = ^TFaceIndices;

  // Вспомогательная структура для временного хранения граней (используется в uzeentpolylinegeneric)
  TTempFaceIndices = record
    Vertex1: Integer;
    Vertex2: Integer;
    Vertex3: Integer;
    Vertex4: Integer;
    VertexCount: Integer;
  end;

  PTempFaceIndices = ^TTempFaceIndices;

  // Вектор для хранения граней
  GDBFaceArray = object(GZVector<TFaceIndices>)
  end;

  PGDBObjPolyFaceMesh=^GDBObjPolyFaceMesh;

  TEdgePair = record
    idx1, idx2: Integer;
  end;

  GDBEdgePairArray = object(GZVector<TEdgePair>)
  end;

  GDBObjPolyFaceMesh=object(GDBObjCurve)
  private
    FVertexCount: Integer;    // Количество вершин в сети
    FFaceCount: Integer;      // Количество граней в сети
    FFaces: GDBFaceArray;     // Вектор индексов граней

    // Вспомогательная процедура для формирования уникальных рёбер
    procedure BuildEdgePairs(out edgePairs:GDBEdgePairArray; out edgeCount: Integer);
    
  public
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint);
    
    // Основные методы сущности
    //procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
    //  var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFFollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    function GetObjType:TObjID;virtual;
    destructor done;
    
    // Методы для работы с вершинами и гранями
    function GetVertexCount: Integer;
    function GetFaceCount: Integer;
    function GetFaceVertices(Index: Integer): TFaceIndices;
    procedure AddFace(const Face: TFaceIndices);
    function GetFaceCountReadOnly: Integer; // Только для чтения, для инспектора объектов
    procedure InitFacesFromTempFaces(TempFaces:PTempFaceIndices;Count:Integer);
    
    // Вспомогательные методы
    class function CreateInstance:PGDBObjPolyFaceMesh;static;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
  end;

  function AllocAndInitPolyFaceMesh(owner:PGDBObjGenericWithSubordinated):PGDBObjPolyFaceMesh;

implementation

constructor GDBObjPolyFaceMesh.init(own:Pointer;layeraddres:PGDBLayerProp;
  LW:smallint);
begin
  inherited init(own,layeraddres,lw);
  FVertexCount := 0;
  FFaceCount := 0;
  FFaces.initnul;
end;

procedure GDBObjPolyFaceMesh.BuildEdgePairs(out edgePairs: GDBEdgePairArray;
  out edgeCount: Integer);
var
  i: Integer;
  face: TFaceIndices;
  vertexIndex1, vertexIndex2: Integer;
  absIndex1, absIndex2: Integer;
  edgeKey: string;
  drawnEdges: array of string;
  ep: TEdgePair;

  function EdgeAlreadyDrawn(const key: string): Boolean;
  var
    k: Integer;
  begin
    for k := 0 to High(drawnEdges) do
    begin
      if drawnEdges[k] = key then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

begin
  edgePairs.Clear;
  edgeCount := 0;
  system.SetLength(drawnEdges, 0);

  for i := 0 to FFaces.Count - 1 do
  begin
    face := GetFaceVertices(i);

    if face.VertexCount < 3 then
      Continue;

    case face.VertexCount of
      3: { Треугольник: v1-v2, v2-v3, v3-v1 }
      begin
        { Ребро 1-2 }
        if face.Vertex1 > 0 then
        begin
          absIndex1 := abs(face.Vertex1);
          absIndex2 := abs(face.Vertex2);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;

        { Ребро 2-3 }
        if face.Vertex2 > 0 then
        begin
          absIndex1 := abs(face.Vertex2);
          absIndex2 := abs(face.Vertex3);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;

        { Ребро 3-1 }
        if face.Vertex3 > 0 then
        begin
          absIndex1 := abs(face.Vertex3);
          absIndex2 := abs(face.Vertex1);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;
      end;

      4: { Четырехугольник: v1-v2, v2-v3, v3-v4, v4-v1 }
      begin
        { Ребро 1-2 }
        if face.Vertex1 > 0 then
        begin
          absIndex1 := abs(face.Vertex1);
          absIndex2 := abs(face.Vertex2);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;

        { Ребро 2-3 }
        if face.Vertex2 > 0 then
        begin
          absIndex1 := abs(face.Vertex2);
          absIndex2 := abs(face.Vertex3);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;

        { Ребро 3-4 }
        if face.Vertex3 > 0 then
        begin
          absIndex1 := abs(face.Vertex3);
          absIndex2 := abs(face.Vertex4);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;

        { Ребро 4-1 }
        if face.Vertex4 > 0 then
        begin
          absIndex1 := abs(face.Vertex4);
          absIndex2 := abs(face.Vertex1);
          if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
          begin
            if absIndex1 > absIndex2 then
            begin
              vertexIndex1 := absIndex2;
              vertexIndex2 := absIndex1;
            end
            else
            begin
              vertexIndex1 := absIndex1;
              vertexIndex2 := absIndex2;
            end;

            edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
            if not EdgeAlreadyDrawn(edgeKey) then
            begin
              ep.idx1 := vertexIndex1;
              ep.idx2 := vertexIndex2;
              edgePairs.PushBackData(ep);
              Inc(edgeCount);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure GDBObjPolyFaceMesh.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  i: Integer;
  edgePairs: GDBEdgePairArray;
  edgeCount: Integer;
  tempPoint1, tempPoint2: TzePoint3d;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  // Стадия расчета: только расчеты, необходимые для отображения
  if (Stage = EFAllStages) or (EFCalcEntityCS in Stage) then
  begin
    FormatWithoutSnapArray;
    calcbb(dc);
    CalcActualVisible(dc.DrawingContext.VActuality);
  end;

  // Стадия отрисовки: создание визуального представления
  if ((Stage = EFAllStages) or (EFDraw in Stage)) and (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
    Representation.Clear;

    // Формируем уникальные рёбра через общую процедуру
    edgePairs.initnul;
    try
      BuildEdgePairs(edgePairs, edgeCount);

      // Отрисовываем рёбра в Representation
      for i := 0 to edgeCount - 1 do
      begin
        if (edgePairs.parray^[i].idx1 > 0) and (edgePairs.parray^[i].idx1 <= VertexArrayInWCS.Count) and
           (edgePairs.parray^[i].idx2 > 0) and (edgePairs.parray^[i].idx2 <= VertexArrayInWCS.Count) then
        begin
          tempPoint1 := VertexArrayInWCS.Items[edgePairs.parray^[i].idx1 - 1];
          tempPoint2 := VertexArrayInWCS.Items[edgePairs.parray^[i].idx2 - 1];
          Representation.DrawLineWithoutLT(dc, tempPoint1, tempPoint2);
        end;
      end;
    finally
      edgePairs.done;
    end;
  end;

  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjPolyFaceMesh.SaveToDXF(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
var
  i: Integer;
  face: TFaceIndices;
  tmpHandle: TDWGHandle;
begin
  // Записываем заголовок POLYLINE (без кода 6 - тип линии)
  dxfStringout(outStream,0,'POLYLINE',IODXFContext.header);
  IODXFContext.p2h.MyGetOrCreateValue(@self,IODXFContext.handle,tmpHandle);
  dxfStringout(outStream,5,inttohex(tmpHandle,0),IODXFContext.header);
  dxfStringout(outStream,100,'AcDbEntity',IODXFContext.header);
  dxfStringout(outStream,8,vp.layer^.Name,IODXFContext.header);
  if vp.color<>ClByLayer then
    dxfStringout(outStream,62,IntToStr(vp.color),IODXFContext.header);
  if vp.lineweight<>-1 then
    dxfIntegerout(outStream,370,vp.lineweight);
  dxfStringout(outStream,100,'AcDbPolyFaceMesh',IODXFContext.header);
  dxfIntegerout(outStream,66,1); // Следует за POLYLINE
  dxfvertexout(outStream,10,uzegeometry.NulVertex);
  dxfIntegerout(outStream,70,64); // Флаг Polyface Mesh
  dxfIntegerout(outStream,71,vertexarrayinocs.Count); // Количество вершин
  dxfIntegerout(outStream,72,FFaceCount);   // Количество граней

  // Сохраняем вершины полигональной сетки
  for i := 0 to vertexarrayinocs.Count - 1 do
  begin
    // VERTEX для вершины полигональной сетки
    dxfStringout(outStream,0,'VERTEX',IODXFContext.header);
    dxfStringout(outStream,5,inttohex(IODXFContext.handle, 0),IODXFContext.header);
    inc(IODXFContext.handle);
    dxfStringout(outStream,100,'AcDbEntity',IODXFContext.header);
    dxfStringout(outStream,100,'AcDbVertex',IODXFContext.header);
    dxfStringout(outStream,100,'AcDbPolyFaceMeshVertex',IODXFContext.header);
    
    // Координаты вершины
    dxfDoubleout(outStream,10,vertexarrayinocs.Items[i].x);
    dxfDoubleout(outStream,20,vertexarrayinocs.Items[i].y);
    dxfDoubleout(outStream,30,vertexarrayinocs.Items[i].z);
    
    // Флаг для вершины полигональной сетки (64 + 128 = 192)
    dxfIntegerout(outStream,70,192);
  end;

  // Сохраняем грани (Face Records)
  for i := 0 to FFaces.Count - 1 do
  begin
    face := GetFaceVertices(i);
    
    // VERTEX для Face Record
    dxfStringout(outStream,0,'VERTEX',IODXFContext.header);
    dxfStringout(outStream,5,inttohex(IODXFContext.handle, 0),IODXFContext.header);
    inc(IODXFContext.handle);
    dxfStringout(outStream,100,'AcDbEntity',IODXFContext.header);
    dxfStringout(outStream,100,'AcDbFaceRecord',IODXFContext.header);
    
    // Координаты (не используются для Face Record, но должны быть указаны)
    dxfDoubleout(outStream,10,0.0);
    dxfDoubleout(outStream,20,0.0);
    dxfDoubleout(outStream,30,0.0);
    
    // Флаг для Face Record (128)
    dxfIntegerout(outStream,70,128);
    
    // Индексы вершин (начинаются с 1, а не с 0)
    // Сохраняем оригинальные значения, включая отрицательные (для указания видимости ребер)
    if face.Vertex1 <> 0 then
      dxfIntegerout(outStream,71,face.Vertex1);
    if face.Vertex2 <> 0 then
      dxfIntegerout(outStream,72,face.Vertex2);
    if face.Vertex3 <> 0 then
      dxfIntegerout(outStream,73,face.Vertex3);
    if face.Vertex4 <> 0 then
      dxfIntegerout(outStream,74,face.Vertex4);
  end;

  // SEQEND - конец последовательности
  dxfStringout(outStream,0,'SEQEND',IODXFContext.header);
  dxfStringout(outStream,5,inttohex(IODXFContext.handle, 0),IODXFContext.header);
  inc(IODXFContext.handle);
  dxfStringout(outStream,100,'AcDbEntity',IODXFContext.header);

  //programlog.LogOutFormatStr('uzeentpolyfacemesh: Сохранение PolyFaceMesh с %d вершинами и %d гранями', [vertexarrayinocs.Count, FFaceCount], LM_Info);
end;

procedure GDBObjPolyFaceMesh.SaveToDXFFollow(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
begin
  // Пустая реализация - PolyFaceMesh не должен сохранять дополнительные вершины через SaveToDXFFollow
  // Все вершины и грани сохраняются в SaveToDXF
end;

procedure GDBObjPolyFaceMesh.DrawGeometry(lw:integer;var DC:TDrawContext;
  const inFrustumState:TInBoundingVolume);
var
  i: Integer;
  edgePairs: GDBEdgePairArray;
  edgeCount: Integer;
  tempPoint1, tempPoint2: TzePoint3d;
begin
  { Прямая отрисовка граней из актуальных координат VertexArrayInWCS.
    Это необходимо потому, что при трансформации (перемещении/повороте)
    вершины смещаются правильно, но Representation не перестраивается. }

  edgePairs.initnul;
  try
    { Формируем уникальные рёбра через общую процедуру (как в FormatEntity) }
    BuildEdgePairs(edgePairs, edgeCount);

    { Отрисовка всех уникальных рёбер напрямую через drawer }
    for i := 0 to edgeCount - 1 do
    begin
      if (edgePairs.parray^[i].idx1 > 0) and (edgePairs.parray^[i].idx1 <= VertexArrayInWCS.Count) and
         (edgePairs.parray^[i].idx2 > 0) and (edgePairs.parray^[i].idx2 <= VertexArrayInWCS.Count) then
      begin
        tempPoint1 := VertexArrayInWCS.Items[edgePairs.parray^[i].idx1 - 1];
        tempPoint2 := VertexArrayInWCS.Items[edgePairs.parray^[i].idx2 - 1];
        DC.drawer.DrawLine3DInModelSpace(tempPoint1, tempPoint2, DC.DrawingContext.matrixs);
      end;
    end;
  finally
    edgePairs.done;
  end;
end;
//
//function GDBObjPolyFaceMesh.Clone(own:Pointer):PGDBObjEntity;
//var
//  tpo: PGDBObjPolyFaceMesh;
//  i: Integer;
//  NewFaces: TFaceArray; // временный массив
//begin
//  GetMem(Pointer(tpo), SizeOf(GDBObjPolyFaceMesh));
//  tpo^.init(own, vp.Layer, vp.LineWeight);
//  CopyVPto(tpo^);
//  CopyExtensionsTo(tpo^);
//
//  // Копируем массив вершин
//  tpo^.vertexarrayinocs.SetSize(vertexarrayinocs.Count);
//  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);
//
//  // Копируем данные о гранях
//  tpo^.FVertexCount := FVertexCount;
//  tpo^.FFaceCount := FFaceCount;
//
//  // 👇 ВАЖНО: сначала работаем с локальным массивом
//  SetLength(NewFaces, Length(FFaces));
//  for i := 0 to High(FFaces) do
//    NewFaces[i] := FFaces[i];
//
//  tpo^.FFaces := NewFaces;  // а потом присваиваем целиком
//
//  tpo^.bp.ListPos.owner := own;
//  Result := tpo;
//end;

function GDBObjPolyFaceMesh.Clone(own:Pointer):PGDBObjEntity;
var
  tpo:PGDBObjPolyFaceMesh;
  i: Integer;
begin
  Getmem(Pointer(tpo),sizeof(GDBObjPolyFaceMesh));
  tpo^.init(own,vp.Layer,vp.LineWeight);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);

  // Копируем массив вершин
  tpo^.vertexarrayinocs.SetSize(vertexarrayinocs.Count);
  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);

  // Копируем данные о гранях
  tpo^.FVertexCount := FVertexCount;
  tpo^.FFaceCount := FFaceCount;
  tpo^.FFaces.initnul;
  for i := 0 to FFaces.Count - 1 do
    tpo^.FFaces.PushBackData(FFaces.parray^[i]);

  tpo^.bp.ListPos.owner:=own;
  Result:=tpo;
end;

function GDBObjPolyFaceMesh.GetObjTypeName:string;
begin
  Result:=ObjN_GDBObjPolyFaceMesh;
end;

function GDBObjPolyFaceMesh.GetObjType;
begin
  Result:=GDBPolyFaceMeshID;
end;

function GDBObjPolyFaceMesh.GetVertexCount;
begin
  Result := FVertexCount;
end;

function GDBObjPolyFaceMesh.GetFaceCount;
begin
  Result := FFaces.Count;
end;

function GDBObjPolyFaceMesh.GetFaceCountReadOnly: Integer;
begin
  Result := FFaces.Count;
end;

function GDBObjPolyFaceMesh.GetFaceVertices;
begin
  if (Index >= 0) and (Index < FFaces.Count) and (FFaces.parray <> nil) then
    Result := FFaces.parray^[Index]
  else
    Result := Default(TFaceIndices);
end;

procedure GDBObjPolyFaceMesh.AddFace;
var
  faceNumber: Integer;
begin
  FFaces.PushBackData(Face);
  faceNumber := FFaceCount + 1;  // Номер грани до увеличения счетчика
  inc(FFaceCount);
  //programlog.LogOutFormatStr('uzeentpolyfacemesh: Добавлена грань %d с вершинами: %d,%d,%d,%d', [faceNumber, Face.Vertex1, Face.Vertex2, Face.Vertex3, Face.Vertex4], LM_Info);
end;

function GDBObjPolyFaceMesh.CalcTrueInFrustum(
  const frustum:TzeFrustum):TInBoundingVolume;
begin
  Result := VertexArrayInWCS.CalcTrueInFrustum(frustum,False);
end;

class function GDBObjPolyFaceMesh.CreateInstance;
begin
  Result:=AllocAndInitPolyFaceMesh(nil);
end;

function AllocPolyFaceMesh:Pointer;
begin
  Getmem(pointer(Result),sizeof(GDBObjPolyFaceMesh));
end;

function AllocAndInitPolyFaceMesh(owner:PGDBObjGenericWithSubordinated):PGDBObjPolyFaceMesh;
begin
  Getmem(pointer(Result),sizeof(GDBObjPolyFaceMesh));
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

procedure GDBObjPolyFaceMesh.InitFacesFromTempFaces(TempFaces:PTempFaceIndices;Count:Integer);
var
  i:Integer;
  FaceIndices:TFaceIndices;
  pFace:PTempFaceIndices;
begin
  //programlog.LogOutFormatStr('uzeentpolyfacemesh: InitFacesFromTempFaces START Count=%d',[Count],LM_Info);
  FFaces.initnul; // Инициализация вектора перед использованием
  FFaceCount:=Count;
  for i:=0 to Count-1 do begin
    pFace:=PTempFaceIndices(PtrUInt(TempFaces)+PtrUInt(i*SizeOf(TTempFaceIndices)));
    FaceIndices.Vertex1:=pFace^.Vertex1;
    FaceIndices.Vertex2:=pFace^.Vertex2;
    FaceIndices.Vertex3:=pFace^.Vertex3;
    FaceIndices.Vertex4:=pFace^.Vertex4;
    FaceIndices.VertexCount:=pFace^.VertexCount;
    FFaces.PushBackData(FaceIndices);
    //programlog.LogOutFormatStr('  Грань %d: V1=%d V2=%d V3=%d V4=%d Count=%d',
    //  [i+1,FaceIndices.Vertex1,FaceIndices.Vertex2,FaceIndices.Vertex3,FaceIndices.Vertex4,FaceIndices.VertexCount],LM_Info);
  end;
  //programlog.LogOutFormatStr('uzeentpolyfacemesh: InitFacesFromTempFaces END Faces=%d',[FFaces.Count],LM_Info);
end;

destructor GDBObjPolyFaceMesh.done;
begin
  FFaces.done;
  inherited;
end;

begin
  // Регистрация только для создания через GenericPolyline
  RegisterEntity(GDBPolyFaceMeshID,'PolyFaceMesh',@AllocPolyFaceMesh,@AllocAndInitPolyFaceMesh);
end.
