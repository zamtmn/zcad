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

  GDBObjPolyFaceMesh=object(GDBObjCurve)
  private
    FVertexCount: Integer;    // Количество вершин в сети
    FFaceCount: Integer;      // Количество граней в сети
    FFaces: GDBFaceArray;     // Вектор индексов граней
    
  public
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint);
    
    // Основные методы сущности
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

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

procedure GDBObjPolyFaceMesh.LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
  var drawing:TDrawingDef;var context:TIODXFLoadContext);
var
  s: string;
  byt: integer;
  polylineFlags: integer;
  currentVertex: TzePoint3d;
  currentFace: TFaceIndices;
  vertexIndex: Integer;
  isProcessingVertex: Boolean;
  isFaceRecord: Boolean;
  isPolyFaceVertex: Boolean;

  procedure AddCurrentFace;
  begin
    if (currentFace.VertexCount >= 3) and
       ((currentFace.Vertex1 <> 0) or (currentFace.Vertex2 <> 0) or
        (currentFace.Vertex3 <> 0) or (currentFace.Vertex4 <> 0)) then begin
      FFaces.PushBackData(currentFace);
      inc(FFaceCount);
      currentFace.VertexCount := 0;
      currentFace.Vertex1 := 0;
      currentFace.Vertex2 := 0;
      currentFace.Vertex3 := 0;
      currentFace.Vertex4 := 0;
    end;
  end;

begin
  //programlog.LogOutStr('uzeentpolyfacemesh: LoadFromDXF START (старый метод, не должен вызываться)',LM_Info);
  FVertexCount := 0;
  FFaceCount := 0;
  FFaces.initnul;
  context.GDBVertexLoadCache.Clear;

  polylineFlags := 0;
  currentVertex := NulVertex;
  isProcessingVertex := False;
  isFaceRecord := False;
  isPolyFaceVertex := False;

  currentFace.VertexCount := 0;
  currentFace.Vertex1 := 0;
  currentFace.Vertex2 := 0;
  currentFace.Vertex3 := 0;
  currentFace.Vertex4 := 0;

  byt := rdr.ParseInteger;
  while not rdr.EOF do begin
    case byt of
      0:
      begin
        s := rdr.ParseString;
        if s = 'VERTEX' then begin
          if isFaceRecord then
            AddCurrentFace;
          isProcessingVertex := True;
          isFaceRecord := False;
          isPolyFaceVertex := False;
          currentVertex := NulVertex;
        end
        else if s = 'SEQEND' then begin
          if isFaceRecord then
            AddCurrentFace;
          system.Break;
        end;
      end;
      10:
      begin
        if isProcessingVertex and not isFaceRecord then begin
          currentVertex.x := rdr.ParseDouble;
          byt := rdr.ParseInteger;
          if byt = 20 then begin
            currentVertex.y := rdr.ParseDouble;
            byt := rdr.ParseInteger;
            if byt = 30 then begin
              currentVertex.z := rdr.ParseDouble;
              if isPolyFaceVertex then
                context.GDBVertexLoadCache.PushBackData(currentVertex);
              byt := rdr.ParseInteger;
              continue;
            end
            else
              currentVertex.z := 0;
          end
          else
            currentVertex.y := 0;
        end
        else
          rdr.ParseDouble;
      end;
      70:
      begin
        polylineFlags := rdr.ParseInteger;
      end;
      71:
      begin
        if isProcessingVertex and isFaceRecord then begin
          vertexIndex := rdr.ParseInteger;
          if vertexIndex <> 0 then begin
            AddCurrentFace;
            currentFace.Vertex1 := vertexIndex;
            currentFace.VertexCount := 1;
          end
          else
            rdr.ParseInteger;
        end
        else if not isProcessingVertex then begin
          rdr.ParseInteger;
        end
        else
          rdr.ParseInteger;
      end;
      72:
      begin
        if isProcessingVertex and isFaceRecord then begin
          vertexIndex := rdr.ParseInteger;
          if vertexIndex <> 0 then begin
            currentFace.Vertex2 := vertexIndex;
            inc(currentFace.VertexCount);
          end;
        end
        else if not isProcessingVertex then begin
          rdr.ParseInteger;
        end
        else
          rdr.ParseInteger;
      end;
      73:
      begin
        if isProcessingVertex and isFaceRecord then begin
          vertexIndex := rdr.ParseInteger;
          if vertexIndex <> 0 then begin
            currentFace.Vertex3 := vertexIndex;
            inc(currentFace.VertexCount);
          end;
        end
        else
          rdr.ParseInteger;
      end;
      74:
      begin
        if isProcessingVertex and isFaceRecord then begin
          vertexIndex := rdr.ParseInteger;
          if vertexIndex <> 0 then begin
            currentFace.Vertex4 := vertexIndex;
            inc(currentFace.VertexCount);
          end;
        end
        else
          rdr.ParseInteger;
      end;
      100:
      begin
        s := rdr.ParseString;
        if isProcessingVertex then begin
          if s = 'AcDbPolyFaceMeshVertex' then begin
            if isFaceRecord then
              AddCurrentFace;
            isPolyFaceVertex := True;
            isFaceRecord := False;
          end
          else if s = 'AcDbFaceRecord' then begin
            if isFaceRecord then
              AddCurrentFace;
            isFaceRecord := True;
            isPolyFaceVertex := False;
            currentFace.VertexCount := 0;
            currentFace.Vertex1 := 0;
            currentFace.Vertex2 := 0;
            currentFace.Vertex3 := 0;
            currentFace.Vertex4 := 0;
          end;
        end;
      end;
      210:
      begin
        rdr.ParseDouble;
      end;
      220:
      begin
        rdr.ParseDouble;
      end;
      230:
      begin
        rdr.ParseDouble;
      end;
      62:
      begin
        rdr.ParseInteger;
      end;
      8:
      begin
        rdr.ParseString;
      end;
    else
      rdr.ParseString;
    end;

    byt := rdr.ParseInteger;
  end;

  vertexarrayinocs.SetSize(context.GDBVertexLoadCache.Count);
  context.GDBVertexLoadCache.copyto(vertexarrayinocs);
  context.GDBVertexLoadCache.Clear;
  FVertexCount := vertexarrayinocs.Count;
end;

procedure GDBObjPolyFaceMesh.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  i: Integer;
  face: TFaceIndices;
  vertexIndex1, vertexIndex2: Integer;
  absIndex1, absIndex2: Integer;
  edgeKey: string;
  j: Integer;
  // Для отслеживания нарисованных рёбер используем динамический массив строк
  drawnEdges: array of string;
  edgeExists: Boolean;
  edgePairs: array of record
    idx1, idx2: Integer;
  end;
  edgeCount: Integer;
  tempPoint1, tempPoint2: TzePoint3d;
  //tempArray: TVectorP3D;

  // Внутренняя функция для проверки, существует ли ребро
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

  // Внутренняя функция для добавления ребра в список нарисованных
  procedure AddEdgeToDrawn(const key: string);
  var
    newSize: Integer;
  begin
    newSize := system.Length(drawnEdges);
    system.SetLength(drawnEdges, newSize + 1);
    drawnEdges[newSize] := key;
  end;

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

    // Создаем массив для хранения уникальных рёбер
    edgeCount := 0;
    system.SetLength(edgePairs, 0);
    system.SetLength(drawnEdges, 0);

    // Проходим по всем граням и формируем рёбра
    for i := 0 to FFaces.Count - 1 do
    begin
      face := GetFaceVertices(i);

      if face.VertexCount < 3 then
        Continue; // Пропускаем некорректные грани

      // Определяем индексы вершин с учетом их видимости (знака)
      case face.VertexCount of
        3: // Треугольник: v1-v2, v2-v3, v3-v1
        begin
          // Ребро 1-2: проверяем знак Vertex1 (видимость ребра из вершины 1)
          if face.Vertex1 > 0 then  // Ребро видимо, если первый индекс положительный
          begin
            absIndex1 := abs(face.Vertex1);
            absIndex2 := abs(face.Vertex2);
            if (absIndex1 <= VertexArrayInWCS.Count) and (absIndex2 <= VertexArrayInWCS.Count) then
            begin
              // Нормализуем пару вершин для предотвращения дубликатов
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

              // Проверяем, не было ли это ребро уже нарисовано
              edgeKey := IntToStr(vertexIndex1) + ',' + IntToStr(vertexIndex2);
              if not EdgeAlreadyDrawn(edgeKey) then
              begin
                AddEdgeToDrawn(edgeKey);

                // Увеличиваем размер массива и добавляем новое ребро
                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;

          // Ребро 2-3: проверяем знак Vertex2 (видимость ребра из вершины 2)
          if face.Vertex2 > 0 then  // Ребро видимо, если второй индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;

          // Ребро 3-1: проверяем знак Vertex3 (видимость ребра из вершины 3)
          if face.Vertex3 > 0 then  // Ребро видимо, если третий индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;
        end;

        4: // Четырехугольник: v1-v2, v2-v3, v3-v4, v4-v1
        begin
          // Ребро 1-2: проверяем знак Vertex1 (видимость ребра из вершины 1)
          if face.Vertex1 > 0 then  // Ребро видимо, если первый индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;

          // Ребро 2-3: проверяем знак Vertex2 (видимость ребра из вершины 2)
          if face.Vertex2 > 0 then  // Ребро видимо, если второй индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;

          // Ребро 3-4: проверяем знак Vertex3 (видимость ребра из вершины 3)
          if face.Vertex3 > 0 then  // Ребро видимо, если третий индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;

          // Ребро 4-1: проверяем знак Vertex4 (видимость ребра из вершины 4)
          if face.Vertex4 > 0 then  // Ребро видимо, если четвертый индекс положительный
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
                AddEdgeToDrawn(edgeKey);

                system.SetLength(edgePairs, edgeCount + 1);
                edgePairs[edgeCount].idx1 := vertexIndex1;
                edgePairs[edgeCount].idx2 := vertexIndex2;
                Inc(edgeCount);
              end;
            end;
          end;
        end;
      end;
    end;

    // Теперь рисуем все уникальные рёбра
    for i := 0 to edgeCount - 1 do
    begin
      if (edgePairs[i].idx1 > 0) and (edgePairs[i].idx1 <= VertexArrayInWCS.Count) and
         (edgePairs[i].idx2 > 0) and (edgePairs[i].idx2 <= VertexArrayInWCS.Count) then
      begin
        // Получаем координаты вершин (учитываем, что индексация в DXF начинается с 1)
        tempPoint1 := VertexArrayInWCS.Items[edgePairs[i].idx1 - 1];
        tempPoint2 := VertexArrayInWCS.Items[edgePairs[i].idx2 - 1];

        // Рисуем линию напрямую через drawer
        Representation.DrawLineWithoutLT(dc, tempPoint1, tempPoint2);
      end;
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
begin
  self.Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
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
