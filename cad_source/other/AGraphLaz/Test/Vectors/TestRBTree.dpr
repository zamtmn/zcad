program TestRBTree;

uses
  SysUtils, ExtSys, RBTree;

{$APPTYPE CONSOLE}

type
  TIntegerRBTree = class(TRBTree)
  protected
    procedure WriteIt(const It: Pointer);
  public
    procedure DebugWrite;
  end;

procedure TIntegerRBTree.WriteIt(const It: Pointer);
begin
  write(Integer(It), ' ');
end;

procedure TIntegerRBTree.DebugWrite;
begin
  UpwardTraversal(WriteIt);
  writeln;
end;

procedure Test1;
var
  a, maxnum, ct, amin, amax: Integer;
  RBTree: TRBTree;
begin
  RBTree:=TIntegerRBTree.Create;
  try
    if ParamCount > 0 then maxnum:=StrToInt(ParamStr(1)) else maxnum:=1000;
    for ct:=maxnum - 1 downto 0 do begin
      a:=random(maxnum);
      if RBTree.Find(Pointer(a)) then
        RBTree.Delete(Pointer(a))
      else
        RBTree.Add(Pointer(a));
    end;
    writeln('Count: ', RBTree.Count, ' Depth: ', RBTree.FindDepth);
    amin:=MaxInt;
    amax:=0;
    RBTree.Clear;
    for ct:=maxnum - 1 downto 0 do begin
      a:=random(maxnum);
      if a < amin then amin:=a;
      if a > amax then amax:=a;
      RBTree.Add(Pointer(a));
    end;
    if MaxNum > 0 then
      if (amin <> Integer(RBTree.Min)) or (amax <> Integer(RBTree.Max)) then begin
        write('Error! amin=', amin, ' RBTree.Min=', Integer(RBTree.Min),
          ' amax=', amax, ' RBTree.Max=', Integer(RBTree.Max));
        readln;
      end;
  finally
    RBTree.Free;
  end;
end;

procedure Test2;
var
  RBTree: TIntegerRBTree;
  I, J, Sz: Integer;
begin
  RBTree:=TIntegerRBTree.Create;
  try
    Sz:=AllocMemSize;
    for I:=1 to 1000000 do
      RBTree.Add(Pointer(I));
    writeln(AllocMemSize - Sz);
    writeln('Count: ', RBTree.Count, ' Depth: ', RBTree.FindDepth);
    Sz:=RandSeed;
    for I:=1 to 10000{1000000} do begin
      J:=Random(1000000) + 1;
      if RBTree.Find(Pointer(J)) then RBTree.Delete(Pointer(J{I}));
    end;
    writeln('Count: ', RBTree.Count, ' Depth: ', RBTree.FindDepth);
    RandSeed:=Sz;
    for I:=1 to 10000{1000000} do
      RBTree.Add(Pointer(Random(1000000) + 1{I}));
    writeln('Count: ', RBTree.Count, ' Depth: ', RBTree.FindDepth);
    for I:=-1 downto -10000{1000000} do
      RBTree.Add(Pointer(I));
    writeln('Count: ', RBTree.Count, ' Depth: ', RBTree.FindDepth);
  finally
    RBTree.Free;
  end;
end;

begin
  writeln(AllocMemSize);
  Test1;
  writeln('Test1 Ok');
  Test2;
  writeln('Test2 Ok');
  writeln(AllocMemSize);
  write('Press Return to continue...');
  readln;
end.