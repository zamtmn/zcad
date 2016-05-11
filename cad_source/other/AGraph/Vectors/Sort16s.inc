{ Version 050601. Copyright © Alexey A.Chernobaev, 1996-2005 }

{$IFNDEF V_SORT_DESC}
procedure TNumberVector.Sort;
{$ELSE}
procedure TNumberVector.SortDesc;
{$ENDIF}
var
  I, N, Size: Integer;
  T: Byte;
  NewItems: PRegular;
  C1: array [Byte] of Integer;
  C2: array [Int8] of Integer absolute C1;
begin
  Size:=ItemsSize;
  if (FCount > 40) { for very short vectors quick sort is better }
    and
    (UInt32(Size) <= PhysicalMemorySize div 16)
  then begin
    GetMem(NewItems, Size);
    try
      SetNull(C1, SizeOf(C1));
      N:=FCount - 1;
      for I:=0 to N do
        Inc(C1[Lo(PArrayType(FItems)^[I])]);
      for I:=Low(C1) + 1 to High(C1) do
        Inc(C1[I], C1[I - 1]);
      for I:=N downto 0 do begin
        T:=Lo(PArrayType(FItems)^[I]);
        Dec(C1[T]);
        PArrayType(NewItems)^[C1[T]]:=PArrayType(FItems)^[I];
      end;
      SetNull(C2, SizeOf(C2));
      for I:=0 to N do
        Inc(C2[Int8(Hi(PArrayType(NewItems)^[I]))]);
      for I:=Low(C2) + 1 to High(C2) do
        Inc(C2[I], C2[I - 1]);
      for I:=N downto 0 do begin
        T:=Hi(PArrayType(NewItems)^[I]);
        Dec(C2[Int8(T)]);
        PArrayType(FItems)^[C2[Int8(T)]]:=PArrayType(NewItems)^[I];
      end;
      {$IFDEF V_SORT_DESC}
      Reverse;
      {$ENDIF}
    finally
      FreeMem(NewItems, Size);
    end;
  end
  else
    inherited {$IFNDEF V_SORT_DESC}Sort{$ELSE}SortDesc{$ENDIF};
end;
