{ Version 010318. Copyright © Alexey A.Chernobaev, 1996-2001 }

unit GraphGML;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, AttrType, AttrMap, AttrSet, Aliasv, Int16v, Int32v,
  Pointerv, IIDic, VectStr, VTxtStrm, Graphs, GMLObj, RWGML;

type
  EInterpretGMLError = class(Exception);

function CreateGraphFromGMLStream(TextStream: TTextStream; SaveGMLAttrs: Bool): TGraph;
{ читает из текстового GML-потока и создает очередной граф (в потоке может быть
  записано более одного графа); если SaveUnknownAttrs = True, то неизвестные
  безопасные GML-атрибуты запоминаются, иначе они игнорируются (атрибут
  считается безопасным, если его ключ начинается со строчной буквы) }

procedure GetGraphFromGMLStream(G: TGraph; TextStream: TTextStream; SaveGMLAttrs: Bool);
{ аналогично, но используется уже существующий объект, принадлежащий к классу
  TGraph или любому порожденному от TGraph классу }

procedure WriteGraphToGMLStream(G: TGraph; TextStream: TTextStream; SaveAllAttrs: Bool);
{ записывает граф G в текстовый поток, используя GML-формат; если SaveAllAttrs
  равно True, то сохраняются все атрибуты графа, имена которых начинаются с
  символов > '.', причем специфичные для библиотеки AGraph данные сохраняются
  под ключом AGraph; иначе сохраняются лишь некоторые атрибуты GML (directed,
  node, node.id, node.graphics.x, node.graphics.y, node.graphics.z, edge,
  edge.source, edge.target) }

implementation

const
  Creator = 'AGraph Library 990824 (C) A.Chernobaev';
  Version = 1;

  SInterpretGMLError = 'Error interpreting GML key ''%s'' on line #%d:'#13#10;
  SExpected = 'expected';
  SIntExpected = 'integer number expected';
  SRealExpected = 'real number expected';
  SStringExpected = 'string expected';
  SListExpected = 'list expected';
  STwoObjectsExpected = 'two objects expected';
  SCharExpected = 'character expected';
  SAttrNotDefined = 'attribute not defined';
  SGlobalAttrTypeMismatch = 'global attribute type mismatch';
  SDuplicateId = 'duplicate id';
  SRedefinedId = 'redefined id';
  SUndefinedId = 'undefined id';
  SIdNotFound = 'id not found';
  SUndefinedSourceOrTarget = 'undefined source or target';

  AttrGMLAttrs = 'GMLAttrs';

  { GML attributes }

  KeyCreator = 'Creator';
  KeyVersion = 'version';

  KeyGraph = 'graph';
  KeyNode = 'node';
  KeyEdge = 'edge';
  KeyDirected = 'directed';
  KeyId = 'id';
  KeySource = 'source';
  KeyTarget = 'target';

  KeyGraphics = 'graphics';
  KeyGraphicsX = 'x';
  KeyGraphicsY = 'y';
  KeyGraphicsZ = 'z';

  { AGraph Library extended attributes key }

  KeyAGraphLib = 'agraph';
  KeyAGraphLib1 = 'AGraph';

  { AGraph Library extended keys }

  KeyLocal = 'local'; { safe }
  KeyGlobal = 'global'; { safe }
  KeyVertexAttrs = 'vertex_attrs'; { safe }
  KeyEdgeAttrs = 'edge_attrs'; { safe }
  KeyName = 'name'; { safe }
  KeyValue = 'value'; { safe }

  KeyTree = 'tree'; { safe }
  KeyRoot = 'root'; { unsafe }
  KeyParent = 'parent'; { unsafe }

  KeyNetwork = 'network'; { safe }
  KeyNetworkSource = 'networksource'; { unsafe }
  KeyNetworkSink = 'networksink'; { unsafe }
  KeyMaxFlow = 'maxflow'; { safe }
  KeyFlow = 'flow'; { safe }

  KeyWeighted = 'weighted'; { safe }
  KeyWeight = 'weight'; { safe }

procedure InterpretError(const Msg: String; GMLObject: TGMLObject);
{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
          mov     eax, [ebp+4]
  end;
{$ENDIF}
begin
  raise EInterpretGMLError.Create(Format(SInterpretGMLError,
    [GMLObject.Key, GMLObject.Tag]) + Msg){$IFDEF WIN32}at ReturnAddr{$ENDIF};
end;

function GetIntAttr(AGMLObject: TGMLObject): Int32;
begin
  if AGMLObject.GMLType <> GMLInt then
    InterpretError(SIntExpected, AGMLObject);
  Result:=AGMLObject.Data.AsInt;
end;

function GetRealAttr(AGMLObject: TGMLObject): Float64;
begin
  if AGMLObject.GMLType <> GMLReal then
    InterpretError(SRealExpected, AGMLObject);
  Result:=AGMLObject.Data.AsReal;
end;

function GetStringAttr(AGMLObject: TGMLObject): String;
begin
  if AGMLObject.GMLType <> GMLString then
    InterpretError(SStringExpected, AGMLObject);
  Result:=AGMLObject.Data.AsString^;
end;

function GetListAttr(AGMLObject: TGMLObject): TClassList;
begin
  if AGMLObject.GMLType <> GMLList then
    InterpretError(SListExpected, AGMLObject);
  Result:=AGMLObject.Data.AsList;
end;

function CreateGraphFromGMLStream(TextStream: TTextStream; SaveGMLAttrs: Bool): TGraph;
begin
  Result:=TGraph.Create;
  try
    GetGraphFromGMLStream(Result, TextStream, SaveGMLAttrs);
  except
    Result.Free;
    raise;
  end;
end;

procedure GetGraphFromGMLStream(G: TGraph; TextStream: TTextStream; SaveGMLAttrs: Bool);
var
  SubObject: TGMLObject;
  SubObjectList: TClassList;
  NodeIDs: TIntIntDic;

  procedure SetFeature(AGMLObject: TGMLObject; AFeature: TGraphFeature);
  begin
    if GetIntAttr(AGMLObject) <> 0 then
      G.Features:=G.Features + [AFeature]
    else
      G.Features:=G.Features - [AFeature];
  end; {SetFeature}

  {$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
  function GetVertex(AGMLObject: TGMLObject): TVertex;
  var
    Value: Integer;
  begin
    Value:=GetIntAttr(AGMLObject);
    try
      Result:=G[NodeIDs.Data(Value)];
    except
      InterpretError(SIdNotFound, AGMLObject);
    end;
  end; {GetVertex}

  procedure ProcessAttrMap(AGMLObject: TGMLObject; Map: TAttrMap);
  var
    J: Integer;
    AttrType: TAttrType;
    AGraphSubObject: TGMLObject;
  begin
    With GetListAttr(AGMLObject) do
      for J:=0 to Count - 1 do begin
        AGraphSubObject:=Items[J];
        try
          AttrType:=AttrTypeByName(AGraphSubObject.Key);
        except
          on E: Exception do InterpretError(E.Message, AGraphSubObject);
        end;
        Map.SafeCreateAttr(GetStringAttr(AGraphSubObject), AttrType);
      end;
  end; {ProcessAttrMap}

  procedure ProcessLocal(AGMLObject: TGMLObject; AttrSet: TAttrSet);
  var
    J, Offset: Integer;
    AttrType: TExtAttrType;
    AttrName, S: String;
    Sub1Object, Sub2Object: TGMLObject;
  begin {ProcessLocal}
    With GetListAttr(AGMLObject) do
      for J:=0 to Count - 1 do begin
        Sub1Object:=Items[J];
        try
          AttrType:=AttrTypeByName(Sub1Object.Key);
        except
          on E: Exception do InterpretError(E.Message, Sub1Object);
        end;
        With GetListAttr(Sub1Object) do begin
          if Count <> 2 then InterpretError(STwoObjectsExpected, Sub1Object);
          Sub2Object:=Items[0];
          if Sub2Object.Key <> KeyName then
            InterpretError('''' + KeyName + ''' ' + SExpected, Sub2Object);
          AttrName:=GetStringAttr(Sub2Object);
          Sub2Object:=Items[1];
          if Sub2Object.Key <> KeyValue then
            InterpretError('''' + KeyValue + ''' ' + SExpected, Sub2Object);
        end;
        try
          Offset:=AttrSet.Map.CreateAttr(AttrName, AttrType);
          Case AttrType of
            AttrInt8: AttrSet.AsInt8ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrUInt8: AttrSet.AsUInt8ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrBool: AttrSet.AsBoolByOfs[Offset]:=GetIntAttr(Sub2Object) <> 0;
            AttrChar:
              begin
                S:=GetStringAttr(Sub2Object);
                if Length(S) = 1 then AttrSet.AsCharByOfs[Offset]:=S[1]
                else InterpretError(SCharExpected, Sub2Object);
              end;
            AttrInt16: AttrSet.AsInt16ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrUInt16: AttrSet.AsUInt16ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrInt32: AttrSet.AsInt32ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrUInt32: AttrSet.AsUInt32ByOfs[Offset]:=GetIntAttr(Sub2Object);
            AttrString: AttrSet.AsStringByOfs[Offset]:=GetStringAttr(Sub2Object);
            AttrFloat32: AttrSet.AsFloat32ByOfs[Offset]:=GetRealAttr(Sub2Object);
            AttrFloat64: AttrSet.AsFloat64ByOfs[Offset]:=GetRealAttr(Sub2Object);
            AttrFloat80: AttrSet.AsFloat80ByOfs[Offset]:=GetRealAttr(Sub2Object);
          End;
        except
          on E: EInterpretGMLError do raise;
          on E: Exception do InterpretError(E.Message, AGMLObject);
        end;
      end;
  end; {ProcessLocal}

  procedure ProcessGlobal(AGMLObject: TGMLObject; AttrSet: TAttrSet);
  var
    J: Integer;
    AttrType, AttrSetAttrType: TExtAttrType;
    AttrName, S: String;
    Sub1Object, Sub2Object: TGMLObject;
  begin
    With GetListAttr(AGMLObject) do
      for J:=0 to Count - 1 do begin
        Sub1Object:=Items[J];
        try
          AttrType:=AttrTypeByName(Sub1Object.Key);
        except
          on E: Exception do InterpretError(E.Message, Sub1Object);
        end;
        With GetListAttr(Sub1Object) do begin
          if Count <> 2 then InterpretError(STwoObjectsExpected, Sub1Object);
          Sub2Object:=Items[0];
          if Sub2Object.Key <> KeyName then
            InterpretError('''' + KeyName + ''' ' + SExpected, Sub2Object);
          AttrName:=GetStringAttr(Sub2Object);
          AttrSetAttrType:=AttrSet.Map.GetType(AttrName);
          if AttrSetAttrType = AttrNone then
            InterpretError(SAttrNotDefined, Sub2Object);
          Sub2Object:=Items[1];
          if Sub2Object.Key <> KeyValue then
            InterpretError('''' + KeyValue + ''' ' + SExpected, Sub2Object);
        end;
        try
          if AttrType <> AttrSetAttrType then
            InterpretError(SGlobalAttrTypeMismatch, Sub1Object);
          Case AttrType of
            AttrInt8: AttrSet.AsInt8[AttrName]:=GetIntAttr(Sub2Object);
            AttrUInt8: AttrSet.AsUInt8[AttrName]:=GetIntAttr(Sub2Object);
            AttrBool: AttrSet.AsBool[AttrName]:=GetIntAttr(Sub2Object) <> 0;
            AttrChar:
              begin
                S:=GetStringAttr(Sub2Object);
                if Length(S) = 1 then AttrSet.AsChar[AttrName]:=S[1]
                else InterpretError(SCharExpected, Sub2Object);
              end;
            AttrInt16: AttrSet.AsInt16[AttrName]:=GetIntAttr(Sub2Object);
            AttrUInt16: AttrSet.AsUInt16[AttrName]:=GetIntAttr(Sub2Object);
            AttrInt32: AttrSet.AsInt32[AttrName]:=GetIntAttr(Sub2Object);
            AttrUInt32: AttrSet.AsUInt32[AttrName]:=GetIntAttr(Sub2Object);
            AttrString: AttrSet.AsString[AttrName]:=GetStringAttr(Sub2Object);
            AttrFloat32: AttrSet.AsFloat32[AttrName]:=GetRealAttr(Sub2Object);
            AttrFloat64: AttrSet.AsFloat64[AttrName]:=GetRealAttr(Sub2Object);
            AttrFloat80: AttrSet.AsFloat80[AttrName]:=GetRealAttr(Sub2Object);
          End;
        except
          on E: EInterpretGMLError do raise;
          on E: Exception do InterpretError(E.Message, AGMLObject);
        end;
      end;
  end; {ProcessGlobal}
  {$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

  procedure InterpretAGraphLibAttr;
  var
    J: Integer;
    AGraphKey: String;
    AGraphObject: TGMLObject;
    V: TVertex;
  begin
    With GetListAttr(SubObject) do
      for J:=0 to Count - 1 do begin
        AGraphObject:=Items[J];
        AGraphKey:=LowerCase(AGraphObject.Key);
        if AGraphKey = KeyTree then { tree }
          SetFeature(AGraphObject, Tree)
        else if AGraphKey = KeyNetwork then { network }
          SetFeature(AGraphObject, Network)
        else if AGraphKey = KeyWeighted then { weighted }
          SetFeature(AGraphObject, Weighted)
        else if AGraphKey = KeyRoot then begin { root }
          V:=GetVertex(AGraphObject);
          { разделение присваивания G.Root:=GetVertex(AGraphObject) сделано
            для более правильной обработки ошибок }
          try
            G.Root:=V;
          except
            on E: Exception do InterpretError(E.Message, AGraphObject);
          end;
        end
        else if AGraphKey = KeyNetworkSource then begin { networksource }
          V:=GetVertex(AGraphObject);
          try
            G.NetworkSource:=V;
          except
            on E: Exception do InterpretError(E.Message, AGraphObject);
          end;
        end
        else if AGraphKey = KeyNetworkSink then begin { networksink }
          V:=GetVertex(AGraphObject);
          try
            G.NetworkSink:=V;
          except
            on E: Exception do InterpretError(E.Message, AGraphObject);
          end;
        end
        else if AGraphKey = KeyVertexAttrs then { vertexattrs }
          ProcessAttrMap(AGraphObject, G.VertexAttrMap)
        else if AGraphKey = KeyEdgeAttrs then { edgeattrs }
          ProcessAttrMap(AGraphObject, G.EdgeAttrMap)
        else if AGraphKey = KeyLocal then { local }
          ProcessLocal(AGraphObject, G);
        { остальные атрибуты игнорируем }
      end;
  end; {InterpretAGraphLibAttr}

  function SaveUnknownGMLAttrs(GraphObject: TGraphObject;
    ParentGMLObject, ChildGMLObject: TGMLObject): Bool;
  { сохраняет неизвестные безопасные атрибуты при SaveGMLAttrs = True }
  var
    AutoFreeClassList: TClassList;
  begin
    if SaveGMLAttrs and ((ChildGMLObject.Key)[1] in ['a'..'z']) then begin
      AutoFreeClassList:=TClassList(GraphObject.AsAutoFree[AttrGMLAttrs]);
      if AutoFreeClassList = nil then begin
        AutoFreeClassList:=TAutoFreeClassList.Create;
        GraphObject.AsAutoFree[AttrGMLAttrs]:=AutoFreeClassList;
      end;
      { убираем ChildGMLObject из "родительского" списка и переводим его
        во "владение" объекта GraphObject }
      if ParentGMLObject <> nil then
        With ParentGMLObject.Data.AsList do Items[IndexOf(ChildGMLObject)]:=nil;
      ChildGMLObject.Tag:=-1; {!!!}
      AutoFreeClassList.Add(ChildGMLObject);
      Result:=True
    end
    else
      Result:=False;
  end; {SaveUnknownGMLAttrs}

  procedure InterpretNodeId;
  { обрабатываем ключ id вершины графа }
  var
    J, Id: Integer;
    IdFound: Bool;
    NodeKey: String;
    NodeSubObject: TGMLObject;
  begin
    G.AddVertex;
    IdFound:=False;
    for J:=0 to SubObjectList.Count - 1 do begin
      NodeSubObject:=SubObjectList[J];
      NodeKey:=LowerCase(NodeSubObject.Key);
      if NodeKey = KeyId then begin
        if IdFound then
          InterpretError(SRedefinedId, NodeSubObject);
        Id:=GetIntAttr(NodeSubObject);
        if not NodeIDs.Add(Id, NodeIDs.Count) then
          InterpretError(SDuplicateId, NodeSubObject);
        IdFound:=True;
      end;
    end;
    if not IdFound then
      InterpretError(SUndefinedId, SubObject);
  end; {InterpretNodeId}

  procedure InterpretNode;
  { обрабатываем все ключи вершины графа, кроме id (после InterpretNodeId) }
  var
    NodeSubObject: TGMLObject;
    V: TVertex;

    procedure InterpretGraphics;
    var
      J: Integer;
      GraphicsKey: String;
      AList: TClassList;
      GraphicsObject: TGMLObject;
    begin
      AList:=GetListAttr(NodeSubObject);
      With AList do begin
        J:=0;
        while J < Count do begin
          GraphicsObject:=Items[J];
          GraphicsKey:=LowerCase(GraphicsObject.Key);
          if GraphicsKey = KeyGraphicsX then begin { x }
            G.Features:=G.Features + [Geom2D];
            V.X:=GetRealAttr(GraphicsObject);
          end
          else if GraphicsKey = KeyGraphicsY then begin { y }
            G.Features:=G.Features + [Geom2D];
            V.Y:=GetRealAttr(GraphicsObject);
          end
          else if GraphicsKey = KeyGraphicsZ then begin { z }
            G.Features:=G.Features + [Geom3D];
            V.Z:=GetRealAttr(GraphicsObject);
          end
          else begin { unknown graphics attr }
            { атрибут не опознан => оставляем, переходим к следующему }
            GraphicsObject.Tag:=-1; {!!!}
            Inc(J);
            Continue;
          end;
          { атрибут опознан => удаляем }
          GraphicsObject.Free;
          Delete(J);
        end;
      end;
      if AList.Count > 0 then
        SaveUnknownGMLAttrs(V, SubObject, NodeSubObject);
    end; {InterpretGraphics}

    procedure InterpretAGraphLibVertexAttr;
    var
      J: Integer;
      AGraphKey: String;
      AGraphObject: TGMLObject;
      U: TVertex;
    begin
      With GetListAttr(NodeSubObject) do
        for J:=0 to Count - 1 do begin
          AGraphObject:=Items[J];
          AGraphKey:=LowerCase(AGraphObject.Key);
          if AGraphKey = KeyParent then begin { parent }
            U:=GetVertex(AGraphObject);
            try
              V.Parent:=U;
            except
              on E: Exception do InterpretError(E.Message, AGraphObject);
            end;
          end
          else if AGraphKey = KeyGlobal then { global }
            ProcessGlobal(AGraphObject, V)
          else if AGraphKey = KeyLocal then { local }
            ProcessLocal(AGraphObject, V.Local);
        end;
    end; {InterpretAGraphLibVertexAttr}

  var
    J: Integer;
    NodeKey: String;
  begin {InterpretNode}
    With GetListAttr(SubObject) do begin
      { ищем вершину V графа по ключу id (он существует и единственен - иначе
        процедура InterpretNodeId выдала бы ошибку), и сразу освобождаем id }
      for J:=0 to Count - 1 do begin
        NodeSubObject:=Items[J];
        NodeKey:=LowerCase(NodeSubObject.Key);
        if NodeKey = KeyId then begin
          V:=G[NodeIDs.Data(NodeSubObject.Data.AsInt)];
          NodeSubObject.Free;
          Delete(J);
          Break;
        end;
      end;
      { обрабатываем вершину }
      for J:=0 to Count - 1 do begin
        NodeSubObject:=Items[J];
        NodeKey:=LowerCase(NodeSubObject.Key);
        if NodeKey = KeyGraphics then { graphics }
          InterpretGraphics
        else if NodeKey = KeyAGraphLib then { agraph }
          InterpretAGraphLibVertexAttr
        else { unknown attrs }
          SaveUnknownGMLAttrs(V, SubObject, NodeSubObject);
      end;
    end;
  end; {InterpretNode}

  procedure InterpretEdge;
  { обрабатываем все ключи ребра графа }
  var
    EdgeKey: String;
    EdgeSubObject: TGMLObject;
    E: TEdge;

    function Check(const Key: String; var Id: Integer): Bool;
    begin
      if EdgeKey = Key then begin
        if Id >= 0 then
          InterpretError(SRedefinedId, EdgeSubObject);
        Id:=NodeIDs.Data(GetIntAttr(EdgeSubObject));
        Result:=True;
      end
      else
        Result:=False;
    end; {Check}

    procedure InterpretAGraphLibEdgeAttr;
    var
      J: Integer;
      Value: Float64;
      AGraphKey: String;
      AGraphObject: TGMLObject;
    begin
      With GetListAttr(EdgeSubObject) do
        for J:=0 to Count - 1 do begin
          AGraphObject:=Items[J];
          AGraphKey:=LowerCase(AGraphObject.Key);
          if AGraphKey = KeyMaxFlow then begin { maxflow }
            Value:=GetRealAttr(AGraphObject);
            try
              E.MaxFlow:=Value;
            except
              on E: Exception do InterpretError(E.Message, AGraphObject);
            end;
          end
          else if AGraphKey = KeyFlow then begin { flow }
            Value:=GetRealAttr(AGraphObject);
            try
              E.Flow:=Value;
            except
              on E: Exception do InterpretError(E.Message, AGraphObject);
            end;
          end
          else if AGraphKey = KeyWeight then begin { weight }
            Value:=GetRealAttr(AGraphObject);
            try
              E.Weight:=Value;
            except
              on E: Exception do InterpretError(E.Message, AGraphObject);
            end;
          end
          else if AGraphKey = KeyGlobal then { global }
            ProcessGlobal(AGraphObject, E)
          else if AGraphKey = KeyLocal then { local }
            ProcessLocal(AGraphObject, E.Local);
        end;
    end; {InterpretAGraphLibEdgeAttr}

  var
    J, SourceIndex, TargetIndex: Integer;
  begin {InterpretEdge}
    SourceIndex:=-1;
    TargetIndex:=-1;
    { первый проход: обрабатываем ключи source и target, сразу освобождая их }
    With GetListAttr(SubObject) do
      for J:=0 to Count - 1 do begin
        EdgeSubObject:=Items[J];
        EdgeKey:=LowerCase(EdgeSubObject.Key);
        if Check(KeySource, SourceIndex) or Check(KeyTarget, TargetIndex)
        then begin
          EdgeSubObject.Free;
          Items[J]:=nil;
        end;
      end;
    if (SourceIndex < 0) or (TargetIndex < 0) then
      InterpretError(SUndefinedSourceOrTarget, SubObject);
    { добавляем ребро в граф }
    E:=G.AddEdge(G[SourceIndex], G[TargetIndex]);
    { второй проход: сохраняем неизвестные атрибуты и атрибуты библиотеки AGraph }
    With SubObject.Data.AsList do
      for J:=0 to Count - 1 do begin
        EdgeSubObject:=Items[J];
        if EdgeSubObject <> nil then
          if LowerCase(EdgeSubObject.Key) = KeyAGraphLib then { agraph }
            InterpretAGraphLibEdgeAttr
          else
            SaveUnknownGMLAttrs(E, SubObject, EdgeSubObject);
      end;
  end; {InterpretEdge}

var
  GMLReader: TGMLReader;
  B: TTextStreamBookmark;
  Key, LowerKey, Value: String;
begin {CreateGraphFromGMLStream}
  G.Clear;
  GMLReader:=TGMLReader.Create(TextStream);
  try
    { читаем из GML очередной объект верхнего уровня с ключом KeyGraph }
    if GMLReader.FindKey(KeyGraph) then begin
      if GMLReader.GetTerm <> ListOpen then
        raise EInterpretGMLError.Create(Format(SInterpretGMLError,
          [KeyGraph, GMLReader.LineNumber]) + SListExpected);
      B:=TextStream.CreateBookmark;
      try
        NodeIDs:=TIntIntDic.Create;
        try
          { интерпретируем граф }
          if SaveGMLAttrs then begin
            G.Map.SafeCreateAttr(AttrGMLAttrs, AttrAutoFree);
            G.SafeCreateVertexAttr(AttrGMLAttrs, AttrAutoFree);
            G.SafeCreateEdgeAttr(AttrGMLAttrs, AttrAutoFree);
          end;
          { используется три прохода: во-первых, описание вершины в GML может
            находиться после описания инцидентного ей ребра, и, во-вторых, для
            корректной обработки ключа Parent }
          { первый проход: обрабатываем ключи id вершин графа }
          repeat
            Key:=GMLReader.GetTerm;
            if Key = ListClose then Break;
            if LowerCase(Key) = KeyNode then begin
              SubObject:=GMLReader.ReadObject(Key);
              try
                SubObjectList:=GetListAttr(SubObject);
                InterpretNodeId;
              finally
                SubObject.Free;
              end;
            end
            else begin
              Value:=GMLReader.GetTerm;
              if Value = ListOpen then GMLReader.FindKey(ListClose);
            end;
          until False;
          { второй проход: обрабатываем все объекты, кроме вершин графа }
          TextStream.GotoBookmark(B);
          repeat
            Key:=GMLReader.GetTerm;
            if Key = ListClose then Break;
            LowerKey:=LowerCase(Key);
            if LowerKey <> KeyNode then begin
              SubObject:=GMLReader.ReadObject(Key);
              try
                if LowerKey = KeyEdge then { edge }
                  InterpretEdge
                else if LowerKey = KeyAGraphLib then { agraph }
                  InterpretAGraphLibAttr
                else if LowerKey = KeyDirected then { directed }
                  SetFeature(SubObject, Directed)
                else
                  if SaveUnknownGMLAttrs(G, nil, SubObject) then
                    SubObject:=nil;
              finally
                SubObject.Free;
              end;
            end
            else begin
              Value:=GMLReader.GetTerm;
              if Value = ListOpen then GMLReader.FindKey(ListClose);
            end;
          until False;
          { третий проход: завершаем обработку вершин }
          TextStream.GotoBookmark(B);
          repeat
            Key:=GMLReader.GetTerm;
            if Key = ListClose then Break;
            if LowerCase(Key) = KeyNode then begin
              SubObject:=GMLReader.ReadObject(Key);
              try
                SubObjectList:=GetListAttr(SubObject);
                InterpretNode;
              finally
                SubObject.Free;
              end;
            end
            else begin
              Value:=GMLReader.GetTerm;
              if Value = ListOpen then GMLReader.FindKey(ListClose);
            end;
          until False;
        finally
          NodeIDs.Free;
        end;
      finally
        B.Free;
      end;
    end;
  finally
    GMLReader.Free;
  end;
  G.Pack;
end; {CreateGraphFromGMLStream}

procedure WriteGraphToGMLStream(G: TGraph; TextStream: TTextStream; SaveAllAttrs: Bool);
var
  GMLObjects: TClassList;
  HasGMLAttrs, HasAttrs, GraphHasVertexAttrs, GraphHasEdgeAttrs,
    IsTree, IsNetwork, IsWeighted, IsGeom2D, IsGeom3D: Bool;
  V: TVertex;
  Indent: String;

  function UpcaseFirst(const S: String): String;
  { возвращает копию непустой S с прописной первой буквой }
  begin
    Result:=S;
    { ASCII коды прописных и строчных латинских букв отличаются одним битом }
    Result[1]:=Chr(Ord(Result[1]) and not $20);
  end; {UpcaseFirst}

  function HasUserAttrs(Map: TAttrMap): Bool;
  var
    I: Integer;
    AttrName: String;
  begin
    for I:=0 to Map.Count - 1 do begin
      AttrName:=Map.AttrName(I);
      if (AttrName[1] > '.') and (AttrName <> AttrGMLAttrs) then begin
        Result:=True;
        Exit;
      end;
    end;
    Result:=False;
  end; {HasUserAttrs}

  function CreateAttrMapList(Map: TAttrMap): TClassList;
  var
    I: Integer;
    AttrType: TAttrType;
    AttrName: String;
  begin {CreateAttrMapList}
    Result:=TClassList.Create;
    try
      for I:=0 to Map.Count - 1 do begin
        AttrType:=Map.AttrTypeByIndex(I);
        if not (AttrType in [AttrPointer, AttrAutoFree]) then begin
          AttrName:=Map.AttrName(I);
          if AttrName[1] > '.' then
            Result.Add(TGMLObject.CreateString(LowerCase(AttrNames[AttrType]),
              AttrName));
        end;
      end;
    except
      Result.FreeItems;
      Result.Free;
      raise;
    end;
  end; {CreateAttrMapList}

  function CreateGraphObjectAttrsList(AttrSet: TAttrSet): TClassList;
  var
    I, Offset: Integer;
    AttrType: TAttrType;
    AttrTypeName, AttrName: String;
    ObjectAttrsList: TClassList;

    procedure Process(ValueObject: TGMLObject);
    var
      ValList: TClassList;
    begin
      ValList:=TClassList.Create;
      try
        ValList.Add(TGMLObject.CreateString(KeyName, AttrName));
        ValList.Add(ValueObject);
      except
        ValList.FreeItems;
        ValList.Free;
        raise;
      end;
      ObjectAttrsList.Add(TGMLObject.CreateList(AttrTypeName, ValList));
    end; {Process}

    procedure ProcessInt(Value: Integer);
    begin
      Process(TGMLObject.CreateInt(KeyValue, Value));
    end;

    procedure ProcessReal(Value: Float64);
    begin
      Process(TGMLObject.CreateReal(KeyValue, Value));
    end;

    procedure ProcessString(const Value: String);
    begin
      Process(TGMLObject.CreateString(KeyValue, Value));
    end;

  begin {CreateGraphObjectAttrsList}
    ObjectAttrsList:=TClassList.Create;
    try
      for I:=0 to AttrSet.Map.Count - 1 do begin
        AttrType:=AttrSet.Map.AttrTypeByIndex(I);
        if not (AttrType in [AttrPointer, AttrAutoFree]) then begin
          AttrName:=AttrSet.Map.AttrName(I);
          if AttrName[1] > '.' then begin
            AttrTypeName:=LowerCase(AttrNames[AttrType]);
            Offset:=AttrSet.Map.OffsetByIndex(I);
            Case TExtAttrType(AttrType) of
              AttrInt8: ProcessInt(AttrSet.AsInt8ByOfs[Offset]);
              AttrUInt8: ProcessInt(AttrSet.AsUInt8ByOfs[Offset]);
              AttrBool: ProcessInt(Ord(AttrSet.AsBoolByOfs[Offset]));
              AttrChar: ProcessString(AttrSet.AsCharByOfs[Offset]);
              AttrInt16: ProcessInt(AttrSet.AsInt16ByOfs[Offset]);
              AttrUInt16: ProcessInt(AttrSet.AsUInt16ByOfs[Offset]);
              AttrInt32: ProcessInt(AttrSet.AsInt32ByOfs[Offset]);
              AttrUInt32: ProcessInt(AttrSet.AsUInt32ByOfs[Offset]);
              AttrString: ProcessString(AttrSet.AsStringByOfs[Offset]);
              AttrFloat32: ProcessReal(AttrSet.AsFloat32ByOfs[Offset]);
              AttrFloat64: ProcessReal(AttrSet.AsFloat64ByOfs[Offset]);
              AttrFloat80: ProcessReal(AttrSet.AsFloat80ByOfs[Offset]);
            End;
          end;
        end;
      end;
    except
      ObjectAttrsList.FreeItems;
      ObjectAttrsList.Free;
      raise;
    end;
    Result:=ObjectAttrsList;
  end; {CreateGraphObjectAttrsList}

  procedure AddToList(DestinList, SourceList: TClassList);
  begin
    if SourceList <> nil then DestinList.ConcatenateWith(SourceList);
  end;

  function CreateGraphList: TClassList;
  { преобразует граф G в список GML-объектов }
  var
    AGraphLibList: TClassList;
  begin
    Result:=TClassList.Create;
    try
      AGraphLibList:=nil;
      IsGeom2D:=Geom2D in G.Features;
      IsGeom3D:=Geom3D in G.Features;
      if SaveAllAttrs then begin
        IsTree:=Tree in G.Features;
        IsNetwork:=Network in G.Features;
        IsWeighted:=Weighted in G.Features;
        HasAttrs:=HasUserAttrs(G.Map);
        GraphHasVertexAttrs:=HasUserAttrs(G.VertexAttrMap);
        GraphHasEdgeAttrs:=HasUserAttrs(G.EdgeAttrMap);
        if IsTree or IsNetwork or IsWeighted or
          HasAttrs or GraphHasVertexAttrs or GraphHasEdgeAttrs
        then begin
          AGraphLibList:=TClassList.Create;
          try
            if IsTree then begin
              AGraphLibList.Add(TGMLObject.CreateInt(KeyTree, 1));
              V:=G.Root;
              if V <> nil then
                AGraphLibList.Add(TGMLObject.CreateInt(UpcaseFirst(KeyRoot),
                  V.Index + 1));
            end;
            if IsNetwork then begin
              AGraphLibList.Add(TGMLObject.CreateInt(KeyNetwork, 1));
              V:=G.NetworkSource;
              if V <> nil then
                AGraphLibList.Add(TGMLObject.CreateInt(UpcaseFirst(KeyNetworkSource),
                  V.Index + 1));
              V:=G.NetworkSink;
              if V <> nil then
                AGraphLibList.Add(TGMLObject.CreateInt(UpcaseFirst(KeyNetworkSink),
                  V.Index + 1));
            end;
            if IsWeighted then
              AGraphLibList.Add(TGMLObject.CreateInt(KeyWeighted, 1));
            if GraphHasVertexAttrs then
              AGraphLibList.Add(TGMLObject.CreateList(KeyVertexAttrs,
                CreateAttrMapList(G.VertexAttrMap)));
            if GraphHasEdgeAttrs then
              AGraphLibList.Add(TGMLObject.CreateList(KeyEdgeAttrs,
                CreateAttrMapList(G.EdgeAttrMap)));
            if HasAttrs then
              AGraphLibList.Add(TGMLObject.CreateList(KeyLocal,
                CreateGraphObjectAttrsList(G)));
          except
            AGraphLibList.FreeItems;
            AGraphLibList.Free;
            raise;
          end;
        end;
        if HasGMLAttrs then
          AddToList(Result, TClassList(G.AsAutoFree[AttrGMLAttrs]));
      end
      else begin
        IsTree:=False;
        IsNetwork:=False;
        IsWeighted:=False;
        HasAttrs:=False;
        GraphHasVertexAttrs:=False;
        GraphHasEdgeAttrs:=False;
      end;
      if AGraphLibList <> nil then
        Result.Add(TGMLObject.CreateList(KeyAGraphLib1, AGraphLibList));
    except
      Result.FreeItems;
      Result.Free;
      raise;
    end;
  end; {CreateGraphList}

  procedure GetVertexList(GMLList: TClassList; V: TVertex);
  { преобразует вершину V в список GML-объектов }
  var
    I: Integer;
    Parent: TVertex;
    HasParent: Bool;
    AGMLObject: TGMLObject;
    GraphicsList, AGraphLibVertexList, UnknownGraphicsList: TClassList;
  begin {CreateVertexList}
    GMLObjects.Clear;
    GMLList.Add(TGMLObject.CreateInt(KeyId, V.Index + 1));
    if IsTree then Parent:=V.Parent else Parent:=nil;
    HasParent:=Parent <> nil;
    if HasParent or GraphHasVertexAttrs or V.HasLocal then begin
      AGraphLibVertexList:=TClassList.Create;
      try
        if HasParent then
          AGraphLibVertexList.Add(TGMLObject.CreateInt(UpcaseFirst(KeyParent),
            Parent.Index + 1));
        if GraphHasVertexAttrs then
          AGraphLibVertexList.Add(TGMLObject.CreateList(KeyGlobal,
            CreateGraphObjectAttrsList(V)));
        if V.HasLocal then
          AGraphLibVertexList.Add(TGMLObject.CreateList(KeyLocal,
            CreateGraphObjectAttrsList(V.Local)));
        GMLList.Add(TGMLObject.CreateList(KeyAGraphLib1, AGraphLibVertexList));
      except
        AGraphLibVertexList.FreeItems;
        AGraphLibVertexList.Free;
        raise;
      end;
    end;
    { обрабатываем graphics-атрибут, если они существуют }
    UnknownGraphicsList:=nil;
    if HasGMLAttrs then begin
      AGraphLibVertexList:=TClassList(V.AsAutoFree[AttrGMLAttrs]);
      if AGraphLibVertexList <> nil then
        for I:=0 to AGraphLibVertexList.Count - 1 do begin
          AGMLObject:=AGraphLibVertexList[I];
          if LowerCase(AGMLObject.Key) = KeyGraphics then
            UnknownGraphicsList:=AGMLObject.Data.AsList
          else
            GMLList.Add(AGMLObject);
        end;
    end;
    { обрабатываем graphics-атрибуты, если они существуют }
    if IsGeom2D or (UnknownGraphicsList <> nil) then begin
      GraphicsList:=TClassList.Create;
      try
        if IsGeom2D then begin
          GraphicsList.Add(TGMLObject.CreateReal(KeyGraphicsX, V.X));
          GraphicsList.Add(TGMLObject.CreateReal(KeyGraphicsY, V.Y));
          if IsGeom3D then GraphicsList.Add(TGMLObject.CreateReal(KeyGraphicsZ, V.Z));
        end;
        if UnknownGraphicsList <> nil then
          AddToList(GraphicsList, UnknownGraphicsList);
      except
        GraphicsList.FreeItems;
        GraphicsList.Free;
        raise;
      end;
      GMLList.Add(TGMLObject.CreateList(KeyGraphics, GraphicsList));
    end;
  end; {CreateVertexList}

  procedure GetEdgeList(GMLList: TClassList; E: TEdge);
  { преобразует ребро E в список GML-объектов }
  var
    AGraphLibEdgeList: TClassList;
  begin {CreateEdgeList}
    GMLObjects.Clear;
    GMLList.Add(TGMLObject.CreateInt(KeySource, E.V1.Index + 1));
    GMLList.Add(TGMLObject.CreateInt(KeyTarget, E.V2.Index + 1));
    if IsNetwork or IsWeighted or GraphHasEdgeAttrs or E.HasLocal then begin
      AGraphLibEdgeList:=TClassList.Create;
      try
        if IsNetwork then begin
          AGraphLibEdgeList.Add(TGMLObject.CreateReal(KeyMaxFlow, E.MaxFlow));
          AGraphLibEdgeList.Add(TGMLObject.CreateReal(KeyFlow, E.Flow));
        end;
        if IsWeighted then
          AGraphLibEdgeList.Add(TGMLObject.CreateReal(KeyWeight, E.Weight));
        if GraphHasEdgeAttrs then
          AGraphLibEdgeList.Add(TGMLObject.CreateList(KeyGlobal,
            CreateGraphObjectAttrsList(E)));
        if E.HasLocal then
          AGraphLibEdgeList.Add(TGMLObject.CreateList(KeyLocal,
            CreateGraphObjectAttrsList(E.Local)));
        GMLList.Add(TGMLObject.CreateList(KeyAGraphLib1, AGraphLibEdgeList));
      except
        AGraphLibEdgeList.FreeItems;
        AGraphLibEdgeList.Free;
        raise;
      end;
    end;
    if HasGMLAttrs then
      AddToList(GMLList, TClassList(E.AsAutoFree[AttrGMLAttrs]));
  end; {CreateEdgeList}

  procedure ProtectGraphGMLAttrs(GMLObjectsList: TClassList);
  { предохранить GML-объекты, которые принадлежат графу и его элементам, от
    удаления вместе с GMLObjects; для того, чтобы отличить такие объекты от
    созданных во время работы процедуры WriteGraphToGMLStream, используется
    поле Tag: в процессе изменения "хозяина" GML-объектов на графовые объекты,
    этому полю присваивается значение -1 (см. !!!), в то время как у вновь
    созданных объектов оно равно 0. }
  var
    I: Integer;
  begin
    for I:=0 to GMLObjectsList.Count - 1 do
      With TGMLObject(GMLObjectsList[I]) do
        if Tag = -1 then GMLObjectsList[I]:=nil
        else
          if GMLType = GMLList then ProtectGraphGMLAttrs(Data.AsList);
  end; {ProtectGraphGMLAttrs}

  procedure WriteKeyAndValue(const Key, Value: String);
  begin
    TextStream.WriteString(Indent + Key + ' ' + Value);
  end;

var
  I: Integer;
begin {WriteGraphToGMLStream}
  Indent:='';
  HasGMLAttrs:=SaveAllAttrs and (G.Map.GetType(AttrGMLAttrs) <> AttrNone);
  WriteKeyAndValue(KeyGraph, ListOpen);
  Indent:=Indent + GMLIndent;
  WriteKeyAndValue(KeyCreator, StringToLiteral2(Creator));
  WriteKeyAndValue(KeyDirected, IntToStr(Ord(Directed in G.Features)));
  GMLObjects:=CreateGraphList;
  try
    try
      WriteGMLObjectsToStream(Indent, GMLObjects, TextStream);
    finally
      ProtectGraphGMLAttrs(GMLObjects);
      GMLObjects.FreeItems;
    end;
    for I:=0 to G.VertexCount - 1 do begin
      GetVertexList(GMLObjects, G[I]);
      try
        WriteKeyAndValue(KeyNode, ListOpen);
        WriteGMLObjectsToStream(Indent + GMLIndent, GMLObjects, TextStream);
        TextStream.WriteString(Indent + ListClose);
      finally
        ProtectGraphGMLAttrs(GMLObjects);
        GMLObjects.FreeItems;
      end;
    end;
    for I:=0 to G.EdgeCount - 1 do begin
      GetEdgeList(GMLObjects, G.Edges[I]);
      try
        WriteKeyAndValue(KeyEdge, ListOpen);
        WriteGMLObjectsToStream(Indent + GMLIndent, GMLObjects, TextStream);
        TextStream.WriteString(Indent + ListClose);
      finally
        ProtectGraphGMLAttrs(GMLObjects);
        GMLObjects.FreeItems;
      end;
    end;
  finally
    GMLObjects.Free;
  end;
  TextStream.WriteString(ListClose);
end; {WriteGraphToGMLStream}

end.
