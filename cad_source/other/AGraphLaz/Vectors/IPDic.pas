{ Version 040212. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit IPDic;
{
  —ловарь integer-pointer.

  Integer-pointer dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = Int32;
  TDicData = Pointer;

  {$I Dic.def}

  TIntPtrDic = class(TDic)
  protected
    procedure FreeItem(const Item: TTreeData);
  public
    procedure FreeItems;
    { освобождает все элементы, интерпретиру€ их как TObject }
    { frees all items interpreting them as TObject }
  end;

  TIntPtrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_d;

{$I Dic.imp}

procedure TIntPtrDic.FreeItem(const Item: TTreeData);
begin
  TObject(Item.Data).Free;
end;

procedure TIntPtrDic.FreeItems;
begin
  if Self <> nil then Traversal(FreeItem);
end;

end.
