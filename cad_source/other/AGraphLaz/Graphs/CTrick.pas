{ Version 991025 experimental (minor changes 050625).
  Adaptation for AGraph: Alexey A.Chernobaev }

unit CTrick;
(*
 * The author of this software is Michael Trick. Copyright (c) 1994 by
 * Michael Trick.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose without fee is hereby granted, provided that this entire notice
 * is included in all copies of any software which is or includes a copy
 * or modification of this software and in all copies of the supporting
 * documentation for such software.
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY. IN PARTICULAR, NEITHER THE AUTHOR DOES NOT MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
*)
(*
   COLOR.C: Easy code for graph coloring
   Author: Michael A. Trick, Carnegie Mellon University, trick+@cmu.edu
   Last Modified: November 2, 1994

   Code is probably insufficiently debugged, but may be useful to some people.

   For more information on this code, see Anuj Mehrotra and Michael A. Trick,
   "A column generation approach to graph coloring", GSIA Technical report series.
*)

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Int16g, Int16v, Aliasm, Int16m, Boolv, Boolm, Graphs,
  VectErr, GraphErr;

function ColorConnectedGraph(G: TGraph; Colors: TGenericIntegerVector): Integer;

implementation

function ColorConnectedGraph(G: TGraph; Colors: TGenericIntegerVector): Integer;
var
  BestColoring, NumNode, LowerBound, BestClique: Integer;
  ColorClass, Order, ColorCount: TIntegerVector;
  Handled: TBoolVector;
  Adj: TBoolMatrix;
  ColorAdj: TIntegerMatrix;

  function Greedy_Clique(Valid, Clique: TBoolVector): Integer;
  var
    I, J, K, Max, Place: Integer;
    Done: Bool;
    Order, Weight: TIntegerVector;
  begin
    Order:=TIntegerVector.Create(NumNode + 1, 0);
    Weight:=nil;
    try
      Weight:=TIntegerVector.Create(NumNode, 0);
      Clique.SetToDefault;
      Place:=0;
      for I:=0 to NumNode - 1 do
        if Valid[I] then begin
          Order[Place]:=I;
          Inc(Place);
        end;
      for I:=0 to NumNode - 1 do
        if Valid[I] then
          for J:=0 to NumNode - 1 do
            if Valid[J] and Adj[I, J] then
              Weight.IncItem(I, 1);
      repeat
        Done:=True;
        for I:=0 to Place - 2 do begin
          J:=Order[I];
          K:=Order[I + 1];
          if Weight[J] < Weight[K] then begin
            Order[I]:=K;
            Order[I + 1]:=J;
            Done:=False;
          end;
        end;
      until Done;
      Clique[Order[0]]:=True;
      for I:=1 to Place - 1 do begin
        J:=Order[I];
        for K:=0 to I - 1 do
          if Clique[Order[K]] and not Adj[J, Order[K]] then
            Break;
        Clique[J]:=K = I;
      end;
      Max:=0;
      for I:=0 to Place - 1 do
        if Clique[Order[I]] then Inc(Max);
    finally
      Order.Free;
      Weight.Free;
    end;
    Result:=Max;
  end; {Greedy_Clique}

  function Max_W_Clique(Valid, Clique: TBoolVector; Lower, Target: Integer): Integer;
  (*
    Target is a goal value: once a Clique is found with value Target
    it is possible to return.

    Lower is a bound representing an already found Clique: once it is
    determined that no Clique exists with value better than Lower, it
    is permitted to return with a suboptimal Clique.

    Note, to find a Clique of value 1, it is not permitted to just set
    the Lower to 1: the recursion will not work. Lower represents a
    value that is the goal for the recursion.
  *)
  var
    I, J, K, Incumb, NewWeight, Place, Place1, Start, Finish, TotalLeft: Integer;
    Done: Bool;
    Order, Value: TIntegerVector;
    Valid1, Clique1: TBoolVector;
  begin {Max_W_Clique}
    { entered with 'Lower', 'Target' }
    Clique.SetToDefault;
    TotalLeft:=Valid.NumTrue;
    if TotalLeft < Lower then begin
      Result:=0;
      Exit;
    end;
    Order:=TIntegerVector.Create(NumNode + 1, 0);
    try
      Value:=TIntegerVector.Create(NumNode, 0);
      try
        Incumb:=Greedy_Clique(Valid, Clique);
        if Incumb >= Target then begin
          Result:=Incumb;
          Exit;
        end;
        if Incumb > BestClique then { Clique of size 'Incumb' found }
          BestClique:=Incumb;
        { greedy gave 'Incumb' }
        Place:=0;
        for I:=0 to NumNode - 1 do begin
          if Clique[I] then begin
            Order[Place]:=I;
            Dec(TotalLeft);
            Inc(Place);
          end;
        end;
        Start:=Place;
        for I:=0 to NumNode - 1 do begin
          if not Clique[I] and Valid[I] then begin
            Order[Place]:=I;
            Inc(Place);
          end;
        end;
        Finish:=Place;
        for Place:=Start to Finish - 1 do begin
          I:=Order[Place];
          Value[I]:=0;
          for J:=0 to NumNode - 1 do
            if Valid[J] and Adj[I, J] then
              Value.IncItem(I, 1);
        end;
        repeat
          Done:=True;
          for Place:=Start to Finish - 2 do begin
            I:=Order[Place];
            J:=Order[Place + 1];
            if Value[I] < Value[J] then begin
              Order[Place]:=J;
              Order[Place + 1]:=I;
              Done:=False;
            end;
          end;
        until Done;
      finally
        Value.Free;
      end;
      Valid1:=TBoolVector.Create(NumNode, False);
      Clique1:=nil;
      try
        Clique1:=TBoolVector.Create(NumNode, False);
        for Place:=Start to Finish - 1 do begin
          if Incumb + TotalLeft < Lower then begin
            Result:=0;
            Exit;
          end;
          J:=Order[Place];
          Dec(TotalLeft);
          if not Clique[J] then begin
            Valid1.SetToDefault;
            Place1:=0;
            while Place1 < Place do begin
              K:=Order[Place1];
              Valid1[K]:=Valid[K] and Adj[J, K];
              Inc(Place1);
            end;
            NewWeight:=Max_W_Clique(Valid1, Clique1, Incumb - 1, Target - 1);
            if NewWeight + 1 > Incumb then begin { taking new }
              Incumb:=NewWeight + 1;
              Clique.Assign(Clique1);
              Clique[J]:=True;
              if Incumb > BestClique then { Clique of size 'Incumb' found }
                BestClique:=Incumb;
            end;
            { taking 'Incumb' }
            if Incumb >=Target then
              Break;
          end;
        end; {for}
      finally
        Valid1.Free;
        Clique1.Free;
      end;
    finally
      Order.Free;
    end;
    Result:=Incumb;
  end; {Max_W_Clique}

  procedure AssignColor(Node, Color: Integer);
  { 'Node' Color + 'Color' }
  var
    Node1: Integer;
  begin
    ColorClass[Node]:=Color;
    for Node1:=0 to NumNode - 1 do
      if (Node <> Node1) and Adj[Node, Node1] then begin
        if ColorAdj[Node1, Color] = 0 then ColorCount.IncItem(Node1, 1);
        ColorAdj.IncItem(Node1, Color, 1);
        ColorAdj.DecItem(Node1, 0, 1);
       {$IFDEF CHECK_GRAPHS}
        if ColorAdj[Node1, 0] < 0 then
          TGraph.Error(SAlgorithmFailure)
       {$ENDIF};
      end;
  end; {AssignColor}

  procedure RemoveColor(Node, Color: Integer);
  { 'Node' Color - 'Color' }
  var
    Node1: Integer;
  begin
    ColorClass[Node]:=0;
    for Node1:=0 to NumNode - 1 do
      if (Node <> Node1) and Adj[Node, Node1] then begin
        if ColorAdj.DecItem(Node1, Color, 1) = 0 then
          ColorCount.DecItem(Node1, 1);
       {$IFDEF CHECK_GRAPHS}
        if ColorAdj[Node1, Color] < 0 then
          TGraph.Error(SAlgorithmFailure)
       {$ENDIF};
        ColorAdj.IncItem(Node1, 0, 1);
      end;
  end; {RemoveColor}

  function Color(I, CurrentColor: Integer): Integer;
  var
    J, Max, Place, NewVal: Integer;
  begin
    if CurrentColor >= BestColoring then begin
      Result:=CurrentColor;
      Exit;
    end;
    if BestColoring <= LowerBound then begin
      Result:=BestColoring;
      Exit;
    end;
    if I >= NumNode then begin
      Result:=CurrentColor;
      Exit;
    end;
    { Node 'I' color 'CurrentColor' }
    { find Node with maximum ColorAdj }
    Max:=-1;
    Place:=-1;
    for J:=0 to NumNode - 1 do
      if not Handled[J] then begin
        if (ColorCount[J] > Max) or
          (ColorCount[J] = Max) and (ColorAdj[J, 0] > ColorAdj[Place, 0]) then
        begin { best now at 'J' }
          Max:=ColorCount[J];
          Place:=J;
        end;
      end;
    Order[I]:=Place;
    Handled[Place]:=True;
    { using Node 'Place' at level 'I' }
    for J:=1 to CurrentColor do begin
      if ColorAdj[Place, J] = 0 then begin
        ColorClass[Place]:=J;
        AssignColor(Place, J);
        NewVal:=Color(I + 1, CurrentColor);
        if NewVal < BestColoring then begin
          BestColoring:=NewVal;
          if Colors <> nil then Colors.Assign(ColorClass);
        end;
        RemoveColor(Place, J);
        if BestColoring <= CurrentColor then begin
          Handled[Place]:=False;
          Result:=BestColoring;
          Exit;
        end;
      end;
    end;
    if CurrentColor + 1 < BestColoring then begin
      ColorClass[Place]:=CurrentColor + 1;
      AssignColor(Place, CurrentColor + 1);
      NewVal:=Color(I + 1, CurrentColor + 1);
      if NewVal < BestColoring then begin
        BestColoring:=NewVal;
        if Colors <> nil then Colors.Assign(ColorClass);
      end;
      RemoveColor(Place, CurrentColor + 1);
    end;
    Handled[Place]:=False;
    Result:=BestColoring;
  end; {Color}

var
  I, J, Place: Integer;
  Valid, Clique: TBoolVector;
begin { ColorConnectedGraph }
  {$IFDEF CHECK_GRAPHS}
  if (Directed in G.Features) or not G.Connected then
    TGraph.Error(SErrorInParameters);
  {$ENDIF}
  BestColoring:=0;
  NumNode:=G.VertexCount;
  LowerBound:=0;
  BestClique:=0;
  Adj:=G.CreateConnectionMatrix;
  ColorAdj:=nil;
  ColorClass:=nil;
  Order:=nil;
  ColorCount:=nil;
  Handled:=nil;
  try
    ColorAdj:=TIntegerMatrix.Create(NumNode, NumNode + 1, 0);
    ColorClass:=TIntegerVector.Create(NumNode, 0);
    Order:=TIntegerVector.Create(NumNode, 0);
    ColorCount:=TIntegerVector.Create(NumNode, 0);
    Handled:=TBoolVector.Create(NumNode, False);
    for I:=0 to NumNode - 1 do
      for J:=0 to NumNode - 1 do
        if Adj[I, J] then ColorAdj.IncItem(I, 0, 1);
    BestColoring:=NumNode + 1;
    Valid:=TBoolVector.Create(NumNode, True);
    Clique:=nil;
    try
      Clique:=TBoolVector.Create(NumNode, False);
      BestClique:=0;
      LowerBound:=Max_W_Clique(Valid, Clique, 0, NumNode);
      Place:=0;
      for I:=0 to NumNode - 1 do
        if Clique[I] then begin
          Order[Place]:=I;
          Handled[I]:=True;
          Inc(Place);
          AssignColor(I, Place);
        end;
    finally
      Valid.Free;
      Clique.Free;
    end;
    if Colors <> nil then Colors.Assign(ColorClass); { for trivial graph }
    Result:=Color(Place, Place);
    if Colors <> nil then Colors.SubScalar(1);
  finally
    Adj.Free;
    ColorAdj.Free;
    ColorClass.Free;
    Order.Free;
    ColorCount.Free;
    Handled.Free;
  end;
end; { ColorConnectedGraph }

end.
