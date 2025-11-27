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
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit usupportgui;

interface

uses
  StdCtrls,Controls,Classes,LCLType,ComCtrls,ColorBox,Graphics,
  LMessages,LCLIntf,LCLProc,
  Laz2_XMLCfg,Laz2_DOM,sysutils,Masks;

type
  TIsShortcutFunc=function(var Message: TLMKey): boolean of object;
  TCBReadOnlyMode=(CBReadOnly,CBEditable,CBDoNotTouch);
  TShortCutContextCheckMode=(SCCCM_All,SCCCM_One);
  TShortCutContext=record
    EditableInFocus,
    DefaultInFocus,
    NotEmptyInFocus,
    WithSelectionInFocus:boolean;
    ClassNameInFocus,
    ControlNameInFocus:string;
  end;
  TShortCutContextCheckRec=record
    EditableInFocus,
    DefaultInFocus,
    NotEmptyInFocus,
    WithSelectionInFocus:Integer;
    ClassNameInFocus,
    ControlNameInFocus:string;
    ControlNameMask,NotControlNameMask:string;
  end;

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
procedure SetComboSize(cb:TComboBox;ItemH:Integer;ReadOnlyMode:TCBReadOnlyMode);overload;
procedure SetComboSize(cb:TColorBox;ItemH:Integer);overload;
function IsZShortcut(var Message: TLMKey;const ActiveControl,DefaultControl:TWinControl; const OldFunction:TIsShortcutFunc;SuppressedShortcuts:TXMLConfig): boolean;
function MyTextToShortCut(const ShortCutText: string): TShortCut;
function LMKey2ShortCut(var Message: TLMKey):TShortCut;
implementation

function MyTextToShortCut(const ShortCutText: string): TShortCut;
begin
  Result:=TextToShortCutRaw(ShortCutText);
  if Result=0 then
    Result:=TextToShortCut(ShortCutText);
end;

function isEditable(const ActiveControl:TWinControl):boolean;
begin
  if (ActiveControl is TCustomEdit)
  //or (ActiveControl is TEbEdit)  //ненужно, т.к. наследник TCustomEdit
  or ((ActiveControl is TCustomMemo)and((ActiveControl as TCustomMemo).ReadOnly=false))
  or ((ActiveControl is TCustomComboBox)and((ActiveControl as TCustomComboBox).Style.HasEditBox)) then
    result:=true
  else
    result:=false
end;

function isNotEmpty(const ActiveControl:TWinControl):boolean;
begin
  if ((ActiveControl is TEdit)and((ActiveControl as TEdit).Text<>''))
  or ((ActiveControl is TMemo)and((ActiveControl as TMemo).Text<>''))
  or ((ActiveControl is TComboBox)and((ActiveControl as TComboBox).Text<>'')) then
    result:=true
  else
    result:=false
end;

function WithSelection(const ActiveControl:TWinControl):boolean;
begin
  if ((ActiveControl is TEdit)and((ActiveControl as TEdit).SelLength<>0))
  or ((ActiveControl is TMemo)and((ActiveControl as TMemo).SelLength<>0))
  or ((ActiveControl is TComboBox)and((ActiveControl as TComboBox).SelLength<>0)) then
    result:=true
  else
    result:=false
end;

function GetCurrentShortCutContext(const ActiveControl,DefaultControl:TWinControl):TShortCutContext;
begin
  if ActiveControl<>nil then begin
    result.EditableInFocus:=isEditable(ActiveControl);
    result.DefaultInFocus:=(ActiveControl=DefaultControl)and(ActiveControl<>nil);
    result.NotEmptyInFocus:=isNotEmpty(ActiveControl);
    result.WithSelectionInFocus:=WithSelection(ActiveControl);
    result.ClassNameInFocus:=ActiveControl.ClassName;
    result.ControlNameInFocus:=ActiveControl.Name;
  end else begin
    result.EditableInFocus:=false;
    result.DefaultInFocus:=true;
    result.NotEmptyInFocus:=false;
    result.WithSelectionInFocus:=false;
    result.ClassNameInFocus:='';
    result.ControlNameInFocus:='';
  end;
end;

//TODO: эти две getAttrValue есть в uztoolbarsmanager, надо выкинуть в какоето одно место
function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
var
  aNodeAttr:TDomNode;
begin
  if (assigned(aNode) and assigned(aNode.Attributes)) then
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
  if (assigned(aNode) and assigned(aNode.Attributes)) then
    aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName)
  else
    aNodeAttr:=nil;
  //aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName);
  if assigned(aNodeAttr) then
                              value:=aNodeAttr.NodeValue;
  if not TryStrToInt(value,result) then
    result:=DefValue;
end;

function getNodeMode(const aNode:TDomNode):TShortCutContextCheckMode;
var
  //aNodeAttr:TDomNode;
  value:string;
begin
  value:=uppercase(aNode.NodeName);
  if value='IFONE' then
    result:=SCCCM_One
  else if value='IFALL' then
    result:=SCCCM_All
  else ;
end;

function CheckSuppresShortcut(TestedShortCut:TShortCut;ShortCutContext:TShortCutContext;SubNode:TDomNode):boolean;
var
   NodeMode:TShortCutContextCheckMode;
   ShortCutNodeValue:string;
   ShortCutContextRec:TShortCutContextCheckRec;
   ShortCut:TShortCut;
begin
  result:=false;
  ShortCutNodeValue:=getAttrValue(SubNode,'ShortCut','');
  ShortCut:=MyTextToShortCut(ShortCutNodeValue);
  if ShortCut<>TestedShortCut then
    exit;
  NodeMode:=getNodeMode(SubNode);
  ShortCutContextRec.EditableInFocus:=getAttrValue(SubNode,'Editable',-1);
  ShortCutContextRec.DefaultInFocus:=getAttrValue(SubNode,'Default',-1);
  ShortCutContextRec.NotEmptyInFocus:=getAttrValue(SubNode,'NotEmpty',-1);
  ShortCutContextRec.WithSelectionInFocus:=getAttrValue(SubNode,'WithSelection',-1);
  ShortCutContextRec.ClassNameInFocus:=getAttrValue(SubNode,'ClassName','');
  ShortCutContextRec.ControlNameInFocus:=getAttrValue(SubNode,'ControlName','');
  ShortCutContextRec.NotControlNameMask:=getAttrValue(SubNode,'NotControlNameMask','');
  ShortCutContextRec.ControlNameMask:=getAttrValue(SubNode,'ControlNameMask','');
  case NodeMode of
    SCCCM_One:begin
                case ShortCutContextRec.EditableInFocus of
                  0:if not ShortCutContext.EditableInFocus then
                      exit(true);
                  1:if ShortCutContext.EditableInFocus then
                      exit(true);
                end;
                case ShortCutContextRec.DefaultInFocus of
                  0:if not ShortCutContext.DefaultInFocus then
                      exit(true);
                  1:if ShortCutContext.DefaultInFocus then
                      exit(true);
                end;
                case ShortCutContextRec.NotEmptyInFocus of
                  0:if not ShortCutContext.NotEmptyInFocus then
                      exit(true);
                  1:if ShortCutContext.NotEmptyInFocus then
                      exit(true);
                end;
                case ShortCutContextRec.WithSelectionInFocus of
                  0:if not ShortCutContext.WithSelectionInFocus then
                      exit(true);
                  1:if ShortCutContext.WithSelectionInFocus then
                      exit(true);
                end;
                if ShortCutContextRec.NotControlNameMask<>'' then
                  if not MatchesMask(ShortCutContext.ControlNameInFocus,ShortCutContextRec.NotControlNameMask) then
                    exit(true);
                if ShortCutContextRec.ControlNameMask<>'' then
                  if MatchesMask(ShortCutContext.ControlNameInFocus,ShortCutContextRec.ControlNameMask) then
                    exit(true);
              end;
    SCCCM_All:begin
              end;
  end;
end;

function SuppresShortcut(TestedShortCut:TShortCut;ShortCutContext:TShortCutContext;SuppressedShortcuts:TXMLConfig):boolean;
var
  Node,SubNode:TDomNode;
begin
  result:=false;
  if assigned(SuppressedShortcuts)then begin
    Node:=SuppressedShortcuts.FindNode('SUPRESSEDSHORTCUTS',false);
    if assigned(Node)then begin
      if ShortCutContext.DefaultInFocus then
        Node:=Node.FindNode('DEFAULTCONTROLINFOCUS')
      else
        Node:=Node.FindNode('OTHERCONTROLINFOCUS');
      if assigned(Node) then
        SubNode:=Node.FirstChild
      else
        SubNode:=nil;
      if assigned(SubNode) then
      while assigned(SubNode)do
      begin
        result:=CheckSuppresShortcut(TestedShortCut,ShortCutContext,SubNode);
        if result then exit;
        SubNode:=SubNode.NextSibling;
      end;
    end;
  end;
end;

function LMKey2ShortCut(var Message: TLMKey):TShortCut;
var
  KeyCode:word;
  ShiftState:tshiftstate;
begin
  KeyCode:=Message.CharCode;
  ShiftState:=MsgKeyDataToShiftState(Message.KeyData);
  Result:=KeyToShortCut(KeyCode,ShiftState);
end;


function IsZShortcut(var Message: TLMKey;const ActiveControl,DefaultControl:TWinControl; const OldFunction:TIsShortcutFunc;SuppressedShortcuts:TXMLConfig): boolean;
var
  //TestedShortCutText:string;
  //KeyCode:word;
  //ShiftState:tshiftstate;
  TestedShortCut:TShortCut;
  ShortCutContext:TShortCutContext;
begin
  //KeyCode:=Message.CharCode;
  //ShiftState:=MsgKeyDataToShiftState(Message.KeyData);
  //TestedShortCut:=KeyToShortCut(KeyCode,ShiftState);
  TestedShortCut:=LMKey2ShortCut(Message);
  //TestedShortCutText:=ShortCutToText(TestedShortCut);
  ShortCutContext:=GetCurrentShortCutContext(ActiveControl,DefaultControl);
  result:=not SuppresShortcut(TestedShortCut,ShortCutContext,SuppressedShortcuts);
  if result then result:=OldFunction(Message);
end;
procedure SetComboSize(cb:TComboBox;ItemH:Integer;ReadOnlyMode:TCBReadOnlyMode);
begin
     cb.AutoSize:=false;
     {$IFDEF LCLWIN32}
     case ReadOnlyMode of
       CBReadOnly:cb.Style:=csOwnerDrawFixed;
       CBEditable:cb.Style:=csOwnerDrawEditableFixed;
       CBDoNotTouch:;
     end;
     cb.ItemHeight:=ItemH;
     {$ENDIF}
end;

procedure SetComboSize(cb:TColorBox;ItemH:Integer);overload;
begin
     cb.AutoSize:=false;
     {$IFDEF LCLWIN32}
     //case ReadOnlyMode of
     //  CBReadOnly:cb.Style:=csOwnerDrawFixed;
     //  CBEditable:cb.Style:=csOwnerDrawEditableFixed;
     //end;
     cb.ItemHeight:=ItemH;
     {$ENDIF}
end;

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
var
   i:integer;
begin
  //tcombobox(Sender).ItemIndex:=-1;

  //If use  Items.Clear and add items in GTK2 combobox close on mouseup

  //Add items if need
  if cb.Items.Count<ItemsCount then
  begin
        for i:=0 to ItemsCount-cb.Items.Count-1 do
        begin
             cb.AddItem('',nil);
        end;
  end;
  //Remove items if need
  if cb.Items.Count>ItemsCount then
  begin
        for i:=0 to cb.Items.Count-ItemsCount-1 do
        begin
             cb.Items.Delete(0);
        end;
  end;
end;
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
begin
     //if not ({odSelected}{odComboBoxEdit}odDisabled in state) then
     if (state<>[])and(state<>[odHotLight])and(state<>[odBackgroundPainted]) then
     {ifdef windows}
     TComboBox(Control).canvas.FillRect(ARect);
     {endif}
end;

function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
begin
     {$IF not (defined(LCLQt) or defined(LCLQt5))}
     if (cdsSelected in state) {or (cdsFocused in state)}{or Item.Selected} then
     {if (cdsSelected in state) or (cdsGrayed in state) or (cdsDisabled in state)
     or (cdsChecked in state) or (cdsFocused in state) or (cdsDefault in state)
     or (cdsHot in state) or (cdsMarked in state) or (cdsIndeterminate in state)then}
     begin
     canvas.Brush.Color:=clHighlight;
     canvas.Font.Color:=clHighlightText;
     end;
     {$IFNDEF LCLGTK2}
     result := Item.DisplayRectSubItem( SubItem,drBounds);
     canvas.FillRect(result);
     {$ENDIF}
     {$ENDIF}
     result := Item.DisplayRectSubItem( SubItem,drBounds);
end;


end.
