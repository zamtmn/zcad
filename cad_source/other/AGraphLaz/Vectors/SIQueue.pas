{ Version 040419. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit SIQueue;
{
  Очередь индексированных строк (см. ExtSort.dpr).

  Indexed strings queue (see ExtSort.dpr).
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Aliasv, Int16v, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TTreeData = record
    Key: String;
    Indexes: TIntegerVector;
  end;

  {$DEFINE USER_COMPARE_OBJECTS}
  {$I RBTree.def}

  TStrIndexedQueue = class
  protected
    FRBTree: TRBTree;
    procedure FreeIndex(const Item: TTreeData);
    function CMP(const a, b: TTreeData): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    class function Compare(const S1, S2: String): Integer; virtual;
    function IsEmpty: Bool;
    procedure Add(AValue: String; Index: Integer);
    { добавляет строку AValue с индексом Index в очередь }
    { adds the string AValue with the index Index to the queue }
    function DeleteMin(var Index: Integer): String;
    { возвращает наименьшую строку вместе с ее индексом (в переменной Index) и
      удаляет их из очереди }
    { returns minimum string along with it's index (in the variable Index) and
      removes them from the queue }
  end;

  TCaseSensStrIndexedQueue = class(TStrIndexedQueue)
  public
    class function Compare(const S1, S2: String): Integer; override;
  end;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I RBTree.imp}

constructor TStrIndexedQueue.Create;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
  inherited Create;
  FRBTree:=TRBTree.Create(CMP);
end;

destructor TStrIndexedQueue.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  FRBTree.Traversal(FreeIndex);
  FRBTree.Free;
  inherited Destroy;
end;

procedure TStrIndexedQueue.FreeIndex(const Item: TTreeData);
begin
  Item.Indexes.Free;
end;

function TStrIndexedQueue.CMP(const a, b: TTreeData): Integer;
begin
  Result:=Compare(a.Key, b.Key);
end;

class function TStrIndexedQueue.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareText(S1, S2);
end;

function TStrIndexedQueue.IsEmpty: Bool;
begin
  Result:=FRBTree.IsEmpty;
end;

procedure TStrIndexedQueue.Add(AValue: String; Index: Integer);
var
  Node: PNode;
  TreeData: TTreeData;
begin
  TreeData.Key:=AValue;
  Node:=FRBTree.FindNode(TreeData);
  if Node = nil then begin
    TreeData.Indexes:=TIntegerVector.Create(1, 0);
    TreeData.Indexes[0]:=Index;
    FRBTree.Add(TreeData);
  end
  else
    Node^.data.Indexes.Add(Index);
end;

function TStrIndexedQueue.DeleteMin(var Index: Integer): String;
var
  Node: PNode;
begin
  Node:=FRBTree.MinNode;
  Result:=Node^.data.Key;
  Index:=Node^.data.Indexes.Pop;
  if Node^.data.Indexes.Count = 0 then begin
    Node^.data.Indexes.Free;
    FRBTree.DeleteNode(Node);
  end;
end;

{ TCaseSensStrIndexedQueue }

class function TCaseSensStrIndexedQueue.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareStr(S1, S2);
end;

end.
