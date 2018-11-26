unit uzceltechtreeprop;

{$mode objfpc}{$H+}

interface

uses
  LCLType,ImgList,
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,ActnList,
  Laz2_XMLCfg,Laz2_DOM,
  gvector, gtree;
const
  NameSeparator='|';

type
  TTranslateFunction=function (const Identifier, OriginalValue: String): String;
  TNodeData=record
    Name,LocalizedName,FullName:string;
  end;

  TBlobTree=specialize TTree<TNodeData>;

  TTreePropManager=class
    BlobTree:TBlobTree;
    constructor Create;
    destructor Destroy;
    procedure LoadTree(FileName:string;TranslateFunc:TTranslateFunction);
  end;

var
  FunctionsTree,RepresentationsTree:TTreePropManager;

implementation

constructor TTreePropManager.Create;
begin
  BlobTree:=TBlobTree.Create;
end;

destructor TTreePropManager.Destroy;
begin
  BlobTree.Destroy;
end;

function FindChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:string):TBlobTree.TTreeNodeType;
var
  i:integer;
begin
  if Assigned(CurrentBlobNode) then begin
    for i:=0 to CurrentBlobNode.Children.Size-1 do
      if CurrentBlobNode.Children.Mutable[i]^.ClassName=NodeName then
        exit(CurrentBlobNode.Children[i])
  end;
  result:=nil;
end;

function FindOrCreateChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:string;TranslateFunc:TTranslateFunction):TBlobTree.TTreeNodeType;
var
  InitData:TNodeData;
begin
  if Assigned(CurrentBlobNode) then begin
    result:=FindChildrenNode(CurrentBlobNode,NodeName);
    if Assigned(Result) then begin
      {InitData:=Result.Data;
      InitData.FullName:=NodeName;
      InitData.LocalizedName:='';
      InitData.Name:=NodeName;
      Result.Data:=InitData;}
    end else begin
      Result:=TBlobTree.TTreeNodeType.Create;
      InitData.FullName:=CurrentBlobNode.Data.FullName+NameSeparator+NodeName;
      if Assigned(TranslateFunc)then
        InitData.LocalizedName:=TranslateFunc(InitData.FullName,NodeName)
      else
        InitData.LocalizedName:=NodeName;
      InitData.Name:=NodeName;
      Result.Data:=InitData;
      CurrentBlobNode.Children.PushBack(Result);
    end;
  end else begin
    CurrentBlobNode:=TBlobTree.TTreeNodeType.Create;
    InitData.LocalizedName:='Root';
    InitData.FullName:='Root';
    InitData.Name:='';
    CurrentBlobNode.Data:=InitData;
    Result:=TBlobTree.TTreeNodeType.Create;
    InitData.FullName:=NodeName;
    if Assigned(TranslateFunc)then
      InitData.LocalizedName:=TranslateFunc(InitData.FullName,NodeName)
    else
      InitData.LocalizedName:=NodeName;
    InitData.Name:=NodeName;
    Result.Data:=InitData;
    CurrentBlobNode.Children.PushBack(Result);
  end;
end;

procedure ProcessNode(CurrentXmlNode:TDomNode;var CurrentBlobNode:TBlobTree.TTreeNodeType;TranslateFunc:TTranslateFunction);
var
  SubXMLNode:TDomNode;
  SubBlobNode:TBlobTree.TTreeNodeType;
begin
  SubXMLNode:=CurrentXmlNode.FirstChild;
  while assigned(SubXMLNode)do
  begin
    SubBlobNode:=FindOrCreateChildrenNode(CurrentBlobNode,SubXMLNode.NodeName,TranslateFunc);
    //SubBlobNode:=TBlobTree.TTreeNodeType.Create;
    //CurrentBlobNode.Children.PushBack(SubBlobNode);
    ProcessNode(SubXMLNode,SubBlobNode,TranslateFunc);
    SubXMLNode:=SubXMLNode.NextSibling;
  end;
end;
procedure TTreePropManager.LoadTree(FileName:string;TranslateFunc:TTranslateFunction);
var
  XMLFile:TXMLConfig;
  RootXMLNode,SubXMLNode:TDomNode;
  root:TBlobTree.TTreeNodeType;
begin
  XMLFile:=TXMLConfig.Create(nil);
  XMLFile.Filename:=FileName;

  RootXMLNode:=XMLFile.FindNode('STRINGTREE',false);
  root:=BlobTree.Root;

  SubXMLNode:=RootXMLNode.FirstChild;
  while assigned(SubXMLNode)do
  begin
    ProcessNode(SubXMLNode,root,TranslateFunc);
    SubXMLNode:=SubXMLNode.NextSibling;
  end;

  BlobTree.Root:=root;
  XMLFile.Free;
end;

initialization
  FunctionsTree:=TTreePropManager.Create;
  RepresentationsTree:=TTreePropManager.Create;

finalization;
  FunctionsTree.Destroy;
  RepresentationsTree.Destroy;
end.
