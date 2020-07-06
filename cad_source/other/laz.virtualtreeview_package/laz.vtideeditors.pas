unit laz.VTIDEEditors;

{$mode objfpc}{$H+}

interface

uses
  ComponentEditors, PropEdits, laz.VirtualTrees;

type

  // The usual trick to make a protected property accessible in the ShowCollectionEditor call below.
  TVirtualTreeCast = class(TBaseVirtualTree);

  { TVirtualTreeEditor }

  TVirtualTreeEditor = class(TComponentEditor)
  public
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;
  TLazVirtualTreeEditor = class(TVirtualTreeEditor);


implementation

{ TVirtualTreeEditor }

procedure TVirtualTreeEditor.Edit;
var
  Tree: TVirtualTreeCast;
begin
  Tree := TVirtualTreeCast(GetComponent);
  TCollectionPropertyEditor.ShowCollectionEditor(Tree.Header.Columns, Tree, 'Columns');
end;

function TVirtualTreeEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TVirtualTreeEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Edit Columns...';
  end;
end;

procedure TVirtualTreeEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: Edit;
  end;
end;

end.

