{ Version 040830. Copyright © Alexey A.Chernobaev, 1996-2004 }

{function FindInSortedRange(Value; L, H: Integer): Integer;}
var
  I, C: Integer;
begin
  Result:=-1;
  while L <= H do begin
    I:=(L + H) div 2;
    C:=Compare(I, Value);
    if C < 0 then
      L:=I + 1
    else begin
      H:=I - 1;
      if C = 0 then
        Result:=I;
    end;
  end;
end;
