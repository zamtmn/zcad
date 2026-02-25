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
unit uzeentpolylinegeneric;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzeentpolyline,uzeentpolyfacemesh,
  uzestyleslayers,uzedrawingdef,uzctnrVectorBytesStream,
  SysUtils,uzeentity,uzeTypes,uzeconsts,uzeffdxfsupport,uzeentsubordinated,uzegeometrytypes,
  uzMVReader,UGDBPoint3DArray,uzbLogIntf,uzclog,uzeentcurve;

type
  TPolylineSubType=(PST_3DPolyline,PST_PolyFaceMesh);
  PGDBObjGenericPolyline=^GDBObjGenericPolyline;

  // Вспомогательная структура для хранения данных о грани при загрузке
  TTempFaceIndices = record
    Vertex1: Integer;
    Vertex2: Integer;
    Vertex3: Integer;
    Vertex4: Integer;
    VertexCount: Integer;
  end;

  GDBObjGenericPolyline=object(GDBObjCurve)
  private
    PolylineSubType:TPolylineSubType;
    // Данные для 3dpolyline
    Closed3D:boolean;
    // Данные для polyfacemesh
    TempFaces:array of TTempFaceIndices;
    TempFaceCount:Integer;

    procedure AddTempFace(const Face:TTempFaceIndices);
    procedure ClearTempFaces;
  public
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
      const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
    function GetObjType:TObjID;virtual;
    destructor done;virtual;
  end;

implementation

destructor GDBObjGenericPolyline.done;
begin
  ClearTempFaces;
  inherited;
end;

procedure GDBObjGenericPolyline.ClearTempFaces;
begin
  SetLength(TempFaces,0);
  TempFaceCount:=0;
end;

procedure GDBObjGenericPolyline.AddTempFace(const Face:TTempFaceIndices);
var
  NewLen:Integer;
begin
  if TempFaceCount>=system.Length(TempFaces) then begin
    NewLen:=system.Length(TempFaces)+16;
    SetLength(TempFaces,NewLen);
  end;
  TempFaces[TempFaceCount]:=Face;
  inc(TempFaceCount);
end;

function GDBObjGenericPolyline.FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
  const drawing:TDrawingDef):PGDBObjSubordinated;
begin
  result:=inherited;
  if result=nil then
    case PolylineSubType of
      PST_3DPolyline:begin
        // Создаем 3DPolyline и передаем ему данные
        Getmem(PGDBObjPolyline(Result),sizeof(GDBObjPolyline));
        PGDBObjPolyline(Result)^.initnul(bp.ListPos.Owner);
        CopyVPto(PGDBObjPolyline(Result)^);
        CopyExtensionsTo(PGDBObjPolyline(Result)^);
        // Копируем вершины
        PGDBObjPolyline(Result)^.vertexarrayinocs.SetSize(VertexArrayInOCS.Count);
        VertexArrayInOCS.copyto(PGDBObjPolyline(Result)^.vertexarrayinocs);
        PGDBObjPolyline(Result)^.Closed:=Closed3D;
      end;
      PST_PolyFaceMesh:begin
        // Создаем PolyFaceMesh и передаем ему данные
        Getmem(PGDBObjPolyFaceMesh(Result),sizeof(GDBObjPolyFaceMesh));
        PGDBObjPolyFaceMesh(Result)^.initnul(bp.ListPos.Owner);
        CopyVPto(PGDBObjPolyFaceMesh(Result)^);
        CopyExtensionsTo(PGDBObjPolyFaceMesh(Result)^);
        // Копируем вершины
        PGDBObjPolyFaceMesh(Result)^.vertexarrayinocs.SetSize(VertexArrayInOCS.Count);
        VertexArrayInOCS.copyto(PGDBObjPolyFaceMesh(Result)^.vertexarrayinocs);
        // Копируем грани
        if TempFaceCount>0 then begin
          PGDBObjPolyFaceMesh(Result)^.InitFacesFromTempFaces(@TempFaces[0],TempFaceCount);
        end;
      end;
    end;
end;

procedure GDBObjGenericPolyline.LoadFromDXF;
var
  byt:integer;
  s:string;
  hlGDBWord:integer;
  tv:TzePoint3d;
  currentFace:TTempFaceIndices;
  isProcessingVertex:boolean;
  isFaceRecord:boolean;
  vertexIndex:Integer;
  vertexCount:integer;
  SubClass100:string;
begin
  //programlog.LogOutStr('=== GDBObjGenericPolyline.LoadFromDXF START ===',LM_Info);
  // Инициализация переменных (по образцу GDBObjGenericDimension)
  byt:=rdr.ParseInteger;
  PolylineSubType:=PST_3DPolyline;
  Closed3D:=False;
  TempFaceCount:=0;
  SetLength(TempFaces,16);

  // Переменные для polyfacemesh
  isProcessingVertex:=False;
  isFaceRecord:=False;
  currentFace.VertexCount:=0;
  currentFace.Vertex1:=0;
  currentFace.Vertex2:=0;
  currentFace.Vertex3:=0;
  currentFace.Vertex4:=0;

  SubClass100:='';

  //programlog.LogOutFormatStr('LoadFromDXF: первый байт=%d',[byt],LM_Info);

  while True do begin
    s:=''; // Очищаем s перед каждой итерацией
    SubClass100:=''; // Очищаем SubClass100 перед чтением нового значения
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if dxfLoadGroupCodeString(rdr,100,byt,SubClass100,context.Header) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 100 = %s',[SubClass100],LM_Info);
        if SubClass100='AcDb3dPolyline' then begin
          PolylineSubType:=PST_3DPolyline;
          //programlog.LogOutStr('LoadFromDXF: определен тип 3DPolyline',LM_Info);
        end
        else if SubClass100='AcDbPolyFaceMesh' then begin
          PolylineSubType:=PST_PolyFaceMesh;
          //programlog.LogOutStr('LoadFromDXF: определен тип PolyFaceMesh',LM_Info);
        end
        else if SubClass100='AcDbPolyFaceMeshVertex' then begin
          if isFaceRecord then begin
            if (currentFace.VertexCount>=3)and
               ((currentFace.Vertex1<>0)or(currentFace.Vertex2<>0)or
                (currentFace.Vertex3<>0)or(currentFace.Vertex4<>0)) then begin
              AddTempFace(currentFace);
              currentFace.VertexCount:=0;
              currentFace.Vertex1:=0;
              currentFace.Vertex2:=0;
              currentFace.Vertex3:=0;
              currentFace.Vertex4:=0;
            end;
          end;
          isFaceRecord:=False;
        end
        else if SubClass100='AcDbFaceRecord' then begin
          if isFaceRecord then begin
            if (currentFace.VertexCount>=3)and
               ((currentFace.Vertex1<>0)or(currentFace.Vertex2<>0)or
                (currentFace.Vertex3<>0)or(currentFace.Vertex4<>0)) then begin
              AddTempFace(currentFace);
              currentFace.VertexCount:=0;
              currentFace.Vertex1:=0;
              currentFace.Vertex2:=0;
              currentFace.Vertex3:=0;
              currentFace.Vertex4:=0;
            end;
          end;
          isFaceRecord:=True;
          isProcessingVertex:=False; // Сбрасываем чтобы не добавлять вершину (0,0,0) из Face Record
          currentFace.VertexCount:=0;
          currentFace.Vertex1:=0;
          currentFace.Vertex2:=0;
          currentFace.Vertex3:=0;
          currentFace.Vertex4:=0;
        end;
      end
      // Читаем координаты вершины (код группы 10)
      else if dxfLoadGroupCodeVertex(rdr,10,byt,tv) then begin
        if byt=30 then begin
          // Для 3dpolyline: загружаем вершины когда isProcessingVertex=True
          // Для polyfacemesh: загружаем только вершины сетки (isPolyFaceVertex=True)
          if isProcessingVertex then begin
            context.GDBVertexLoadCache.PushBackData(tv);
            inc(vertexCount);
            //programlog.LogOutFormatStr('LoadFromDXF: добавлена вершина #%d (%.4f,%.4f,%.4f)',[vertexCount,tv.x,tv.y,tv.z],LM_Info);
          end;
        end;
      end
      // Читаем флаг (код группы 70)
      else if dxfLoadGroupCodeInteger(rdr,70,byt,hlGDBWord) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 70 = %d (тип=%d isFaceRecord=%s)',[hlGDBWord,ord(PolylineSubType),BoolToStr(isFaceRecord,'T','F')],LM_Info);
        if PolylineSubType=PST_3DPolyline then begin
          // Для 3dpolyline: бит 0 = closed
          if (hlGDBWord and 1)=1 then begin
            Closed3D:=True;
            //programlog.LogOutStr('LoadFromDXF: установлен флаг Closed',LM_Info);
          end;
        end
        else if PolylineSubType=PST_PolyFaceMesh then begin
          // Для polyfacemesh: флаг 192 = вершина сетки, 128 = грань
          if (hlGDBWord and 128)<>0 then begin
            // Это грань, но мы уже знаем это из AcDbFaceRecord
            //programlog.LogOutStr('LoadFromDXF: флаг Face Record (128)',LM_Info);
          end;
        end;
      end
      // Читаем 0 код (VERTEX/SEQEND)
      else if dxfLoadGroupCodeString(rdr,0,byt,s,context.Header) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 0 = %s isProcessingVertex=%s',[s,BoolToStr(isProcessingVertex,'T','F')],LM_Info);
        if s='VERTEX' then begin
          //programlog.LogOutStr('LoadFromDXF: найден VERTEX - начинаем загрузку вершин',LM_Info);
          if isFaceRecord then begin
            if (currentFace.VertexCount>=3)and
               ((currentFace.Vertex1<>0)or(currentFace.Vertex2<>0)or
                (currentFace.Vertex3<>0)or(currentFace.Vertex4<>0)) then begin
              AddTempFace(currentFace);
              currentFace.VertexCount:=0;
              currentFace.Vertex1:=0;
              currentFace.Vertex2:=0;
              currentFace.Vertex3:=0;
              currentFace.Vertex4:=0;
            end;
          end;
          isProcessingVertex:=True;
          isFaceRecord:=False;
        end
        else if s='SEQEND' then begin
          //programlog.LogOutStr('LoadFromDXF: найден SEQEND - завершение загрузки',LM_Info);
          if isFaceRecord then begin
            //programlog.LogOutFormatStr('LoadFromDXF: SEQEND - currentFace: V1=%d V2=%d V3=%d V4=%d Count=%d',
              //[currentFace.Vertex1,currentFace.Vertex2,currentFace.Vertex3,currentFace.Vertex4,currentFace.VertexCount],LM_Info);
            if (currentFace.VertexCount>=3)and
               ((currentFace.Vertex1<>0)or(currentFace.Vertex2<>0)or
                (currentFace.Vertex3<>0)or(currentFace.Vertex4<>0)) then begin
              AddTempFace(currentFace);
              //programlog.LogOutStr('LoadFromDXF: SEQEND - грань добавлена',LM_Info);
            end
            else begin
              programlog.LogOutStr('LoadFromDXF: SEQEND - грань НЕ добавлена (некорректная)',LM_Info);
            end;
          end;
          system.Break;
        end;
      end
      // Читаем индексы вершин грани (коды 71-74) - только isFaceRecord (как в uzeentpolyfacemesh.pas)
      else if dxfLoadGroupCodeInteger(rdr,71,byt,vertexIndex) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 71 = %d (isProcessingVertex=%s isFaceRecord=%s)',[vertexIndex,BoolToStr(isProcessingVertex,'T','F'),BoolToStr(isFaceRecord,'T','F')],LM_Info);
        if isFaceRecord then begin
          if vertexIndex<>0 then begin
            if currentFace.VertexCount>=3 then begin
              AddTempFace(currentFace);
              currentFace.VertexCount:=0;
              currentFace.Vertex1:=0;
              currentFace.Vertex2:=0;
              currentFace.Vertex3:=0;
              currentFace.Vertex4:=0;
            end;
            currentFace.Vertex1:=vertexIndex;
            currentFace.VertexCount:=1;
            //programlog.LogOutFormatStr('LoadFromDXF: код 71 - установлен V1=%d Count=%d',[vertexIndex,currentFace.VertexCount],LM_Info);
          end;
        end;
      end
      else if dxfLoadGroupCodeInteger(rdr,72,byt,vertexIndex) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 72 = %d (isProcessingVertex=%s isFaceRecord=%s)',[vertexIndex,BoolToStr(isProcessingVertex,'T','F'),BoolToStr(isFaceRecord,'T','F')],LM_Info);
        if isFaceRecord then begin
          if vertexIndex<>0 then begin
            currentFace.Vertex2:=vertexIndex;
            inc(currentFace.VertexCount);
            //programlog.LogOutFormatStr('LoadFromDXF: код 72 - установлен V2=%d Count=%d',[vertexIndex,currentFace.VertexCount],LM_Info);
          end;
        end;
      end
      else if dxfLoadGroupCodeInteger(rdr,73,byt,vertexIndex) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 73 = %d (isProcessingVertex=%s isFaceRecord=%s)',[vertexIndex,BoolToStr(isProcessingVertex,'T','F'),BoolToStr(isFaceRecord,'T','F')],LM_Info);
        if isFaceRecord then begin
          if vertexIndex<>0 then begin
            currentFace.Vertex3:=vertexIndex;
            inc(currentFace.VertexCount);
            //programlog.LogOutFormatStr('LoadFromDXF: код 73 - установлен V3=%d Count=%d',[vertexIndex,currentFace.VertexCount],LM_Info);
          end;
        end;
      end
      else if dxfLoadGroupCodeInteger(rdr,74,byt,vertexIndex) then begin
        //programlog.LogOutFormatStr('LoadFromDXF: код 74 = %d (isProcessingVertex=%s isFaceRecord=%s)',[vertexIndex,BoolToStr(isProcessingVertex,'T','F'),BoolToStr(isFaceRecord,'T','F')],LM_Info);
        if isFaceRecord then begin
          if vertexIndex<>0 then begin
            currentFace.Vertex4:=vertexIndex;
            inc(currentFace.VertexCount);
            //programlog.LogOutFormatStr('LoadFromDXF: код 74 - установлен V4=%d Count=%d',[vertexIndex,currentFace.VertexCount],LM_Info);
          end;
        end;
      end
      else begin
        // Пропускаем неизвестные коды - добавим логирование
        //programlog.LogOutFormatStr('LoadFromDXF: пропуск кода %d',[byt],LM_Info);
        rdr.SkipString;
      end;
    byt:=rdr.ParseInteger;
  end;

  vertexarrayinocs.SetSize(context.GDBVertexLoadCache.Count);
  context.GDBVertexLoadCache.copyto(vertexarrayinocs);
  context.GDBVertexLoadCache.Clear;

  //programlog.LogOutFormatStr('=== GDBObjGenericPolyline.LoadFromDXF END === Тип=%d Вершин=%d Граней=%d Closed=%s',
  //  [ord(PolylineSubType),VertexCache.Count,TempFaceCount,BoolToStr(Closed3D,'True','False')],LM_Info);
end;

constructor GDBObjGenericPolyline.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  PolylineSubType:=PST_3DPolyline;
  Closed3D:=False;
  TempFaceCount:=0;
  SetLength(TempFaces,0);
end;

constructor GDBObjGenericPolyline.init;
begin
  inherited init(own,layeraddres,lw);
  PolylineSubType:=PST_3DPolyline;
  Closed3D:=False;
  TempFaceCount:=0;
  SetLength(TempFaces,0);
end;

function GDBObjGenericPolyline.GetObjType;
begin
  Result:=GDBGenericPolylineID;
end;

function AllocGenericPolyline:PGDBObjGenericPolyline;
begin
  Getmem(Result,sizeof(GDBObjGenericPolyline));
end;

function AllocAndInitGenericPolyline(owner:PGDBObjGenericWithSubordinated):
PGDBObjGenericPolyline;
begin
  Result:=AllocGenericPolyline;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

begin
  RegisterDXFEntity(GDBGenericPolylineID,'POLYLINE','GenericPolyline',@AllocGenericPolyline,@AllocAndInitGenericPolyline);
end.
