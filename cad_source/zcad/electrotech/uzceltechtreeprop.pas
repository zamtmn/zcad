unit uzceltechtreeprop;

{$mode objfpc}{$H+}

interface

uses
  LCLType,ImgList,
  Classes,SysUtils,ComCtrls,Controls,Graphics,Menus,Forms,ActnList,
  Laz2_XMLCfg,Laz2_DOM,
  gvector,gtree,uzeTypes;

type
  TTranslateFunction=function (const Identifier, OriginalValue: String): String;
  TNodeData=record
    Name,LocalizedName,FullName:TStringTreeType;
  end;

  TBlobTree=specialize TTree<TNodeData>;

  TTreePropManager=class
    BlobTree:TBlobTree;
    NameSeparator,TreeRootName:string;
    constructor Create(_NameSeparator,_TreeRootName:string);
    destructor Destroy;override;
    procedure LoadTree(FileName:ansistring;TranslateFunc:TTranslateFunction);
    function FindOrCreateChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;SubXMLNode:TDomNode;TranslateFunc:TTranslateFunction):TBlobTree.TTreeNodeType;
    procedure ProcessNode(CurrentXmlNode:TDomNode;var CurrentBlobNode:TBlobTree.TTreeNodeType;TranslateFunc:TTranslateFunction);
    function FindChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:ansistring):TBlobTree.TTreeNodeType;
    function FindChildrenNodeBy(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:ansistring):TBlobTree.TTreeNodeType;
    function GetDecaratedPard(AFullName:TStringTreeType):TStringTreeType;
  end;

var
  FunctionsTree,RepresentationsTree:TTreePropManager;

implementation

constructor TTreePropManager.Create(_NameSeparator,_TreeRootName:string);
var
  InitData:TNodeData;
begin
  NameSeparator:=_NameSeparator;
  TreeRootName:=_TreeRootName;
  BlobTree:=TBlobTree.Create;
  BlobTree.root:=TBlobTree.TTreeNodeType.Create;
  InitData.LocalizedName:=TreeRootName;
  InitData.FullName:=''{TreeRootName};
  InitData.Name:=TreeRootName;
  BlobTree.root.Data:=InitData;
end;

destructor TTreePropManager.Destroy;
begin
  BlobTree.Destroy;
end;

function TTreePropManager.FindChildrenNodeBy(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:ansistring):TBlobTree.TTreeNodeType;
var
  i:integer;
begin
  if Assigned(CurrentBlobNode) then begin
    for i:=0 to CurrentBlobNode.Children.Size-1 do
      if CurrentBlobNode.Children.Mutable[i]^.data.Name=NodeName then
        exit(CurrentBlobNode.Children[i])
  end;
  result:=nil;
end;


function TTreePropManager.FindChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;NodeName:ansistring):TBlobTree.TTreeNodeType;
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

function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;
var
  aNodeAttr:TDomNode;
begin
  if assigned(aNode)then
    aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName)
  else
    aNodeAttr:=nil;
  if assigned(aNodeAttr) then
                              result:=aNodeAttr.NodeValue
                          else
                              result:=DefValue;
end;
function TTreePropManager.FindOrCreateChildrenNode(var CurrentBlobNode:TBlobTree.TTreeNodeType;SubXMLNode:TDomNode;TranslateFunc:TTranslateFunction):TBlobTree.TTreeNodeType;
var
  InitData:TNodeData;
  Identifier:string;
begin
  if Assigned(CurrentBlobNode) then begin
    result:=FindChildrenNode(CurrentBlobNode,SubXMLNode.NodeName);
    if Assigned(Result) then begin
      {InitData:=Result.Data;
      InitData.FullName:=NodeName;
      InitData.LocalizedName:='';
      InitData.Name:=NodeName;
      Result.Data:=InitData;}
    end else begin
      Result:=TBlobTree.TTreeNodeType.Create;
      if CurrentBlobNode.Data.FullName='' then
         InitData.FullName:=SubXMLNode.NodeName
      else
          InitData.FullName:=CurrentBlobNode.Data.FullName+NameSeparator+SubXMLNode.NodeName;
      Identifier:=TreeRootName+NameSeparator+InitData.FullName;
      //InitData.FullName:=CurrentBlobNode.Data.FullName+NameSeparator+NodeName;
      if Assigned(TranslateFunc)then
        InitData.LocalizedName:=TranslateFunc(Identifier,getAttrValue(SubXMLNode,'Desc',SubXMLNode.NodeName))
      else
        InitData.LocalizedName:=SubXMLNode.NodeName;
      InitData.Name:=SubXMLNode.NodeName;
      Result.Data:=InitData;
      CurrentBlobNode.Children.PushBack(Result);
    end;
  end else begin
    CurrentBlobNode:=TBlobTree.TTreeNodeType.Create;
    InitData.LocalizedName:=TreeRootName;
    InitData.FullName:='';
    InitData.Name:='';
    CurrentBlobNode.Data:=InitData;
    Result:=TBlobTree.TTreeNodeType.Create;
    InitData.FullName:=SubXMLNode.NodeName;
    InitData.LocalizedName:=SubXMLNode.NodeName;
    InitData.Name:=SubXMLNode.NodeName;
    Result.Data:=InitData;
    CurrentBlobNode.Children.PushBack(Result);
  end;
end;

procedure TTreePropManager.ProcessNode(CurrentXmlNode:TDomNode;var CurrentBlobNode:TBlobTree.TTreeNodeType;TranslateFunc:TTranslateFunction);
var
  SubXMLNode:TDomNode;
  SubBlobNode:TBlobTree.TTreeNodeType;
begin
  SubXMLNode:=CurrentXmlNode.FirstChild;
  while assigned(SubXMLNode)do
  begin
    SubBlobNode:=FindOrCreateChildrenNode(CurrentBlobNode,SubXMLNode,TranslateFunc);
    //SubBlobNode:=TBlobTree.TTreeNodeType.Create;
    //CurrentBlobNode.Children.PushBack(SubBlobNode);
    ProcessNode(SubXMLNode,SubBlobNode,TranslateFunc);
    SubXMLNode:=SubXMLNode.NextSibling;
  end;
end;
procedure TTreePropManager.LoadTree(FileName:ansistring;TranslateFunc:TTranslateFunction);
var
  XMLFile:TXMLConfig;
  RootXMLNode,SubXMLNode:TDomNode;
  root:TBlobTree.TTreeNodeType;
begin
  XMLFile:=TXMLConfig.Create(nil);
  XMLFile.Filename:=FileName;

  RootXMLNode:=XMLFile.FindNode('STRINGTREE',false);

  SubXMLNode:=RootXMLNode.FirstChild;
  while assigned(SubXMLNode)do
  begin
    root:=BlobTree.Root;
    root:=FindOrCreateChildrenNode(root,SubXMLNode,TranslateFunc);
    ProcessNode(SubXMLNode,root,TranslateFunc);
    SubXMLNode:=SubXMLNode.NextSibling;
  end;

  //BlobTree.Root:=root;
  XMLFile.Free;
end;

function TTreePropManager.GetDecaratedPard(AFullName:TStringTreeType):TStringTreeType;
var
  NodeName:TStringTreeType;
  StartPos,SeparatorPos:Integer;
  CurrNode:TBlobTree.TTreeNodeType;
begin
  StartPos:=1;
  SeparatorPos:=Pos(NameSeparator,AFullName);
  if SeparatorPos=0 then
    SeparatorPos:=Length(AFullName)+1;
  CurrNode:=BlobTree.Root;
  while SeparatorPos>StartPos do begin
  CurrNode:=FindChildrenNodeBy(CurrNode,AFullName[StartPos..SeparatorPos-1]);
  StartPos:=SeparatorPos+length(NameSeparator);
  SeparatorPos:=Pos(NameSeparator,AFullName,StartPos);
  if SeparatorPos=0 then
    SeparatorPos:=length(AFullName)+1;
  end;
  if CurrNode<>Nil then
    result:=CurrNode.Data.LocalizedName
  else
    result:=AFullName;
end;

initialization
  FunctionsTree:=TTreePropManager.Create('~','FunctionsRoot');
  RepresentationsTree:=TTreePropManager.Create('~','RepresentationsRoot');
finalization;
  FunctionsTree.Destroy;
  RepresentationsTree.Destroy;
end.
