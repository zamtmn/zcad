{ Version 001019. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit GraphIO;

interface

{$I VCheck.inc}

uses
  ExtType, Boolm, VTxtStrm, Graphs, GraphGML;

function CreateGraphFromGMLFile(const FileName: String; SaveGMLAttrs: Bool): TGraph;
{ читает и создает граф из GML-файла;
  SaveGMLAttrs: см. GraphGML.CreateGraphFromGMLStream }

procedure GetGraphFromGMLFile(G: TGraph; const FileName: String; SaveGMLAttrs: Bool);
{ читает граф из GML-файла }

procedure WriteGraphToGMLFile(G: TGraph; const FileName: String; SaveAllAttrs: Bool);
{ записывает граф G в текстовый файл, использу€ GML-формат;
  SaveAllAttrs: см. GraphGML.WriteGraphToGMLStream }

procedure WriteGraphSimple(G: TGraph; const FileName: String);
{ записывает граф G в текстовый файл, использу€ простой текстовый формат:
  в первой строке записываетс€ количество вершин, далее - матрица смежности
  графа }

implementation

function CreateGraphFromGMLFile(const FileName: String; SaveGMLAttrs: Bool): TGraph;
var
  S: TTextStream;
begin
  S:=TTextStream.Create(FileName, tsRead);
  try
    Result:=CreateGraphFromGMLStream(S, SaveGMLAttrs);
  finally
    S.Free;
  end;
end;

procedure GetGraphFromGMLFile(G: TGraph; const FileName: String; SaveGMLAttrs: Bool);
var
  S: TTextStream;
begin
  S:=TTextStream.Create(FileName, tsRead);
  try
    GetGraphFromGMLStream(G, S, SaveGMLAttrs);
  finally
    S.Free;
  end;
end;

procedure WriteGraphToGMLFile(G: TGraph; const FileName: String; SaveAllAttrs: Bool);
var
  S: TTextStream;
begin
  S:=TTextStream.Create(FileName, tsRewrite);
  try
    WriteGraphToGMLStream(G, S, SaveAllAttrs);
  finally
    S.Free;
  end;
end;

procedure WriteGraphSimple(G: TGraph; const FileName: String);
var
  S: TTextStream;
  M: TBoolMatrix;
begin
  S:=TTextStream.Create(FileName, tsRewrite);
  M:=nil;
  try
    M:=G.CreateConnectionMatrix;
    M.WriteToTextStream(S);
  finally
    S.Free;
    M.Free;
  end;
end;

end.
