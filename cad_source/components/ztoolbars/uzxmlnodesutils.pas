unit uzxmlnodesutils;

{$mode objfpc}{$H+}

interface

uses
  Laz2_DOM,
  Classes, SysUtils;

function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
function getAttrValue(const aNode:TDomNode;const AttrName:string;const DefValue:integer):integer;overload;


implementation

function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
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

function getAttrValue(const aNode:TDomNode;const AttrName:string;const DefValue:integer):integer;overload;
var
  aNodeAttr:TDomNode;
  value:string;
begin
  value:='';
  aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName);
  if assigned(aNodeAttr) then
                              value:=aNodeAttr.NodeValue;
  if not TryStrToInt(value,result) then
    result:=DefValue;
end;


end.

