{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Vladimir Bobrov)
}
{$mode objfpc}{$H+}

unit uzvsetting;
{$INCLUDE zengineconfig.inc}
interface
uses

  sysutils,

  uzeentmtext,
  
  uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  uzcdrawings,     //Drawings manager, all open drawings are processed him
  uzccombase,
  gzctnrVectorTypes,
  uzcinterface,

  //uzvsettingform,
  //LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  //             StdCtrls, VirtualTrees, ExtCtrls, LResources, LMessages,
  DOM,XMLRead,XMLWrite,XMLCfg,
  RegExpr;
 procedure xmlCreate();

implementation

//**Очистка текста на чертеже
function loadSetting_com(operands:TCommandOperands):TCommandResult;
var

  pobj: PGDBObjMText;
  pmtext:PGDBObjMText;
  ir:itrec;
  newText:ansistring;

  UCoperands:string;

begin

  xmlCreate();
  //uzvsettingform.RunTestForm('sdsfsdfsdf');
    result:=cmd_ok;
end;


procedure xmlCreate();
var
  Doc: TXMLDocument;
  RootNode, ElementNode,ItemNode,TextNode: TDOMNode;
  i: integer;
begin
  try
    // Create a document
    Doc := TXMLDocument.Create;
    // Create a root node
    RootNode := Doc.CreateElement('velec');
    TDOMElement(RootNode).SetAttribute('caption', 'Мои настройки');

    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;
    // Create nodes
    ElementNode:=Doc.CreateElement('SLcable');
    TDOMElement(ElementNode).SetAttribute('caption', 'Кабель набор кабельных суперлиний');

    for i := 1 to 20 do
    begin

      ItemNode:=Doc.CreateElement('Item' + IntToStr(i));

      TDOMElement(ItemNode).SetAttribute('hotkey', '');
      TDOMElement(ItemNode).SetAttribute('caption', 'Кабель №' + IntToStr(i));
      TDOMElement(ItemNode).SetAttribute('name', 'PS');
      //TDOMElement(ItemNode).SetAttribute('color', '');
      //TDOMElement(ItemNode).SetAttribute('typeline', '');

      ElementNode.AppendChild(ItemNode);

    end;

     ElementNode:=Doc.CreateElement('SLcable');

     RootNode.AppendChild(ElementNode);

    // Save XML
    WriteXMLFile(Doc,'c:\TestXML_v3.xml');
  finally
    Doc.Free;
  end;
end;


initialization
  CreateCommandFastObjectPlugin(@loadSetting_com,'osett',CADWG,0);
end.
