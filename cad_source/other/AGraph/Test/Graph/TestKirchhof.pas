unit TestKirchhof;

interface

uses
  ExtType, AttrType, Aliasv, Pointerv, Graphs, VFormat,
  Kirchhof;

const
  RealFormat = '%7.3f';

procedure Test;

implementation

procedure Test;
const
  Resistance = 'KirchhofR';
  ElectromotiveForse = 'KirchhofE';
  Currents = 'KirchhofC';
var
  I: Integer;
  G: TGraph;
  Solution: TFloatVector;
begin
  writeln('*** Kirchhof ***'#10);
  G:=TGraph.Create;
  Solution:=nil;
  try
    { электрическая цепь задается графом, каждое ребро которого соответствует
      участку цепи без разветвлений; сопротивление участка задается атрибутом
      ребра Resistance, электродвижущая сила - атрибутом ElectromotiveForse }
    G.CreateEdgeAttr(Resistance, AttrFloat);
    G.CreateEdgeAttr(ElectromotiveForse, AttrFloat);
    G.AddVertices(3);
    G.AddEdgeI(0, 1).AsFloat[ElectromotiveForse]:=9; { E1 = 9 V }
    G.AddEdgeI(1, 2).AsFloat[Resistance]:=10; { R1 = 10 Om }
    With G.AddEdgeI(1, 2) do begin
      AsFloat[ElectromotiveForse]:=-12; { E2 = -12 V }
      AsFloat[Resistance]:=5; { R2 = 5 Om }
    end;
    G.AddEdgeI(0, 2).AsFloat[Resistance]:=30; { R3 = 30 Om }
    G.AddEdgeI(0, 2).AsFloat[Resistance]:=15; { R4 = 15 Om }

    Solution:=TFloatVector.Create(G.EdgeCount, 0);
    if not FindCurrents(G, Solution) then begin
      writeln('Error!');
      Exit;
    end;
    for I:=0 to G.EdgeCount - 1 do With G.Edges[I] do
      writeln('(', V1.Index, ',', V2.Index, ')',
        ^I'E=', RealToString(AsFloat[ElectromotiveForse], RealFormat),
        ^I'R=', RealToString(AsFloat[Resistance], RealFormat),
        ^I'I', Succ(I), '=', RealToString(Solution[Index], RealFormat));
    writeln;
  finally
    G.Free;
    Solution.Free;
  end;
end;

end.