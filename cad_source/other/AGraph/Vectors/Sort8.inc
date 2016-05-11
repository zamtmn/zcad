{ Version 050601. Copyright © Alexey A.Chernobaev, 1996-2005 }

{$IFNDEF V_SORT_DESC}
procedure TNumberVector.Sort;
{$ELSE}
procedure TNumberVector.SortDesc;
{$ENDIF}
var
  I, N, Size: Integer;
  T: NumberType;
  P: Pointer;
  NewItems: PRegular;
  C: array [NumberType] of Integer;
begin
  Size:=ItemsSize;
  if (FCount > 20) { for very short vectors quick sort is better }
    and
    (UInt32(Size) <= PhysicalMemorySize div 16)
  then begin
    GetMem(NewItems, Size);
    try
      SetNull(C, SizeOf(C));
      N:=FCount - 1;
      for I:=0 to N do
        Inc(C[PArrayType(FItems)^[I]]);
      for I:=Low(C) + 1 to High(C) do
        Inc(C[I], C[I - 1]);
      for I:=N downto 0 do begin
        T:=PArrayType(FItems)^[I];
        Dec(C[T]);
        PArrayType(NewItems)^[{$IFDEF V_SORT_DESC}N - {$ENDIF}C[T]]:=T;
      end;
      P:=FItems;
      FItems:=NewItems;
      NewItems:=P;
    finally
      FreeMem(NewItems, Size);
    end;
  end
  else
    inherited {$IFNDEF V_SORT_DESC}Sort{$ELSE}SortDesc{$ENDIF};
end;
