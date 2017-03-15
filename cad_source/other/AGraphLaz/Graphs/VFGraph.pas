{ Version 030515 }

unit VFGraph;

interface

{$I VCheck.inc}

uses
  ExtType, UInt8v, UInt8sv, UInt16v, UInt16sv, Pointerv, Graphs;

const
  MaxVertices = 65535;
  NULL_NODE = 65535;

type
  TCoreVector = TUInt16Vector;
  TSparseCoreVector = TSparseUInt16Vector;

{$IFDEF BCB}
{$NODEFINE TCoreVector}
{$NODEFINE TSparseCoreVector}
{$ENDIF}

  TGetEdge = function (n1, n2: Integer): TEdge of object;

  TVFGraph = class
  private
    IsCopy: Bool;
  public
    IsDirected: Bool;
    Graph: TGraph;
    Core: TCoreVector;
    NodeFlags: TByteVector;
    InNeighbours, OutNeighbours: TClassList;
    GetEdge: TGetEdge;
    constructor Create(AGraph: TGraph);
    constructor Copy(Source: TVFGraph);
    destructor Destroy; override;
    procedure Pack;
    procedure Unpack;
  end;

implementation

constructor TVFGraph.Create(AGraph: TGraph);
var
  I, J, K, N: Integer;
  V: TVertex;
  T: TCoreVector;
begin
  inherited Create;
  Graph:=AGraph;
  N:=Graph.VertexCount;
  Core:=TCoreVector.Create(N, NULL_NODE);
  NodeFlags:=TByteVector.Create(N, 0);
  InNeighbours:=TClassList.Create;
  InNeighbours.Count:=N;
  IsDirected:=Directed in Graph.Features;
  if IsDirected then begin
    GetEdge:=Graph.GetArcI;
    OutNeighbours:=TClassList.Create;
    OutNeighbours.Count:=N;
    for I:=0 to N - 1 do begin
      V:=Graph.Vertices[I];
      K:=V.InDegree;
      T:=TCoreVector.Create(K, 0);
      for J:=0 to K - 1 do
        T[J]:=V.InNeighbour[J].Index;
      InNeighbours[I]:=T;
      K:=V.OutDegree;
      T:=TCoreVector.Create(K, 0);
      for J:=0 to K - 1 do
        T[J]:=V.OutNeighbour[J].Index;
      OutNeighbours[I]:=T;
    end;
  end
  else begin
    GetEdge:=Graph.GetEdgeI;
    for I:=0 to N - 1 do begin
      V:=Graph.Vertices[I];
      K:=V.Degree;
      T:=TCoreVector.Create(K, 0);
      for J:=0 to K - 1 do
        T[J]:=V.Neighbour[J].Index;
      InNeighbours[I]:=T;
    end;
  end;
end;

constructor TVFGraph.Copy(Source: TVFGraph);
begin
  inherited Create;
  IsCopy:=True;
  Graph:=Source.Graph;
  IsDirected:=Source.IsDirected;
  GetEdge:=Source.GetEdge;
  Core:=TCoreVector.Create(0, NULL_NODE);
  Core.Assign(Source.Core);
  NodeFlags:=TByteVector.Create(0, 0);
  NodeFlags.Assign(Source.NodeFlags);
  InNeighbours:=Source.InNeighbours;
  OutNeighbours:=Source.OutNeighbours;
end;

destructor TVFGraph.Destroy;
begin
  Core.Free;
  NodeFlags.Free;
  if not IsCopy then begin
    InNeighbours.FreeItems;
    InNeighbours.Free;
    if IsDirected then begin
      OutNeighbours.FreeItems;
      OutNeighbours.Free;
    end;
  end;
  inherited Destroy;
end;

procedure TVFGraph.Pack;
var
  PackedCore: TSparseCoreVector;
  PackedNodeFlags: TSparseByteVector;
begin
  PackedCore:=TSparseCoreVector.Create(0, NULL_NODE);
  PackedCore.Assign(Core);
  Core.Free;
  Core:=Pointer(PackedCore);
  PackedNodeFlags:=TSparseByteVector.Create(0, 0);
  PackedNodeFlags.Assign(NodeFlags);
  NodeFlags.Free;
  NodeFlags:=Pointer(PackedNodeFlags);
end;

procedure TVFGraph.Unpack;
var
  UnpackedCore: TCoreVector;
  UnpackedNodeFlags: TByteVector;
begin
  UnpackedCore:=TCoreVector.Create(0, NULL_NODE);
  UnpackedCore.Assign(Core);
  Core.Free;
  Core:=UnpackedCore;
  UnpackedNodeFlags:=TByteVector.Create(0, 0);
  UnpackedNodeFlags.Assign(NodeFlags);
  NodeFlags.Free;
  NodeFlags:=UnpackedNodeFlags;
end;

end.
