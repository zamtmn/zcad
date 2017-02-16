unit Main;

{$MODE Delphi}

{

How to use TVirtualTree with your data
already stored somewhere (array or memory)?

You need to solve cross-linked problem between
your data and TVirtualTree record node and avoid
doubling data in TVirtualTree record node?

This example shows one way of what you need
to accomplish.

Additionally, here you can find how to
conditionally color you cell's background
and font foreground and how to sort VST by
clicking on columns.

Also shows which property are initially needed
to be set for comfortable using.

This is my humble contribution for
users who start to use Mike Lischke's
TVirtualTree component.

Thank you Mike for such a beautiful component.

The initial developer of this code is Sasa Zeman.
Mailto: public@szutils.net or sasaz72@mail.ru
Web site: www.szutils.net

Created: 7 Jun 2004

This example is distributed "AS IS", WITHOUT
WARRANTY OF ANY KIND, either express or implied.

You use it at your own risk!
}

interface

uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, StdCtrls, LResources, Buttons;

type

{ Problem description:

 VST is designed to use your own declared record data
 in his nodes, which are automatically created and
 destroying. That is beautiful, easy and fast.

 But, what if you have your data already formated somewhere
 in array or memory and your algorithms are already optimized
 to use it on that way? How to use VST with them?

 Since VST node can consist any data record, that can be only
 a index or pointer to your real data. The only problem left is
 that actions in your data must affect on corespondent VST node.
 One way is to sequentially go through the VST and find the node
 which consists equal index index, which rapidly decrease
 performance...

 To handle this situation the most efficiently, your array data
 record must additionally consist the pointer to the VST
 corespondent node...
}

  TMyRecord = record
    // Point directly from my record to corespondent VST Node
    // That is useful if your action inside
    // the record involve on your VTS node,
    // for example, if disabling mean deletion
    // of corespondent node, etc.

    NodePointer: PVirtualNode;
    Active: Boolean;
    MyText: String;
    RNDNumber: integer;
  end;

  rTreeData = record
    //This point to my index into my array
    //Instead of index, here you can
    //store the pointer to your data.
    //That depend of what is your intentions
    //and your data structure

    IndexInMyData: integer;

  end;

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    btnDelete: TButton;
    Edit1: TEdit;
    btnCleanAll: TButton;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MyTree: TVirtualStringTree;
    procedure MyTreeBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure MyTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure Button1Click(Sender: TObject);
    procedure MyTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    {$if VTMajorVersion < 5}
    procedure MyTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    {$else}
    procedure MyTreeHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    {$endif}
    procedure btnDeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MyTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure MyTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure MyTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCleanAllClick(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

  MyArrayData: array of TMyRecord;

implementation

{$R *.lfm}

uses
  Math;

procedure TMainForm.MyTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: ^rTreeData;

begin
  // To get Node Data
  Data := Sender.GetNodeData(Node);

  with MyArrayData[Data.IndexInMyData] do
  case Column of
  0: CellText := MyText;
  1:
    begin
       CellText := format('Stored %p Actual %p',
      [NodePointer,Node]);
     end;
  2: CellText := inttostr(RNDNumber);

  end;

end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  Node: PVirtualNode;
  Data: ^rTreeData;

  i,Idx: integer;
  Timer: cardinal;
begin

  // Add 100000 new records and corespondent VST nodes

  Timer := GetTickCount;

  MyTree.BeginUpdate;

  Idx := length(MyArrayData);
  SetLength(MyArrayData, length(MyArrayData)+100000);
  for i := 1 to 100000 do
  begin
    // Add a node to the root of the Tree
    Node := MyTree.AddChild(nil);
    Data := MyTree.GetNodeData(Node);

    //Create link to your data record into VST node
    Data.IndexInMyData := Idx;

    // Working with your array data
    with MyArrayData[Data.IndexInMyData] do
    begin

      //Create link into your data record to VST node
      NodePointer := Node;

      RNDNumber := round(Random(1 shl 16));
      MyText := format(' Index %d',[Data.IndexInMyData])

    end;
    inc(Idx)
  end;
  MyTree.EndUpdate;

  Timer := GetTickCount-Timer;
  caption := format('Adding %d ms, Total nodes %d, Total arrays %d',[Timer, MyTree.RootNodeCount,length(MyArrayData)] );

end;

procedure TMainForm.MyTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  n1,n2: ^rTreeData;
  d1,d2: ^TMyRecord;
begin
  n1 := MyTree.GetNodeData(Node1);
  n2 := MyTree.GetNodeData(Node2);

  // Get the pointers where your data are
  // in the array, to speed-up process
  d1 := @MyArrayData[n1.IndexInMyData];
  d2 := @MyArrayData[n2.IndexInMyData];

  case Column of
  0: Result := CompareValue(n1.IndexInMyData,n2.IndexInMyData);
  1: ;
  2: Result := CompareValue(
     d1.RNDNumber,
     d2.RNDNumber
     )
  else
    Result := 0;
  end
end;

{$if VTMajorVersion < 5}
procedure TMainForm.MyTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{$else}
procedure TMainForm.MyTreeHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
{$endif}
var
  Direction : TSortDirection;
  {$if VTMajorVersion >= 5}
  Column: TColumnIndex;
   Shift: TShiftState;
  {$endif}
begin
  {$if VTMajorVersion >= 5}
  Column := HitInfo.Column;
  Shift := HitInfo.Shift;
  {$endif}
  // Descending order with pressed Shift, otherwise Ascending
  // Or you can save Direction or use
  // MyTree.Header.SortDirection and MyTree.Header.SortColumn
  // to get automatically Descending/Ascending sorting
  // by only clicking on header

  if ssShift in Shift
  then
    Direction := sdDescending
  else
    Direction := sdAscending;

  // Sort all columns except the second
  if Column<>1 then
  begin
    // Set direction image on the sorted column
    MyTree.Header.SortColumn := Column;

    // Set the right direction image
    MyTree.Header.SortDirection := Direction;

    // Sorting process
    MyTree.SortTree(Column, Direction);
  end
end;

procedure TMainForm.btnDeleteClick(Sender: TObject);
var
  Timer: cardinal;
begin

  // Delete all selected nodes

  Timer := GetTickCount;

  MyTree.BeginUpdate;
  MyTree.DeleteSelectedNodes;
  MyTree.EndUpdate;

  Timer := GetTickCount-Timer;
  caption := format('Deleting %d ms, Total nodes %d, Total arrays %d',[Timer, MyTree.RootNodeCount,length(MyArrayData)] );

end;

procedure TMainForm.FormCreate(Sender: TObject);
const

  ColumnParams: array[0..2] of
  record
    Name: ShortString;
    Len: integer;
    Alignment:TAlignment;
   end =
  ((Name:'Text'     ; Len:150 ; Alignment: taLeftJustify),
   (Name:'Pointers' ; Len:300 ; Alignment: taLeftJustify),
   (Name:'Random'   ; Len:120 ; Alignment: taLeftJustify)
  );

var
  NewColumn: TVirtualTreeColumn;
  i: integer;
begin
  // Initialize size of node in MyTree
  // This is the most important to be done before any using of VST,
  // because that is the only way how VST can allocate needed
  // space for your node
  MyTree.NodeDataSize := sizeof(rTreeData);

  // When you add data by yourself,
  // be sure that there is no node in tree
  MyTree.RootNodeCount := 0;

  // If you want to manually set necessary events or parameters,
  // without Object Inspector. That will help in case
  // you have accidentally deleted your component
  // and you do not have a time to work with Object Inspector
  // and rearrange the events or other properties

  // First follows the properties you may set it here or with
  // Object Inspector to be more suitable for standard using

  // Shows the header columns
  MyTree.Header.Options :=
    MyTree.Header.Options + [hoVisible];

  // Allows multi selection of nodes
  MyTree.TreeOptions.SelectionOptions :=
    MyTree.TreeOptions.SelectionOptions +[toMultiSelect];

  // Allows that automatic multi selection is possible
  // beyond the screen
  MyTree.TreeOptions.AutoOptions := 
    MyTree.TreeOptions.AutoOptions + [toAutoScroll];

  // If delay of 1000 ms is too slow during
  // automatic multi selection
  MyTree.AutoScrollDelay := 100;

  // Disable automatic deletion of moved data during
  // Drag&Drop operation
  MyTree.TreeOptions.AutoOptions := 
    MyTree.TreeOptions.AutoOptions - [toAutoDeleteMovedNodes];

  // To show the bacground image on VST
  MyTree.TreeOptions.PaintOptions := 
    MyTree.TreeOptions.PaintOptions +[toShowBackground];

  // If you do not want to show the tree lines
  // MyTree.TreeOptions.PaintOptions :=
  //   MyTree.TreeOptions.PaintOptions -[toShowTreeLines];

  // If you do not want to show left margine of the main node
  // MyTree.TreeOptions.PaintOptions := 
  //  MyTree.TreeOptions.PaintOptions -[toShowRoot];

  // If you want to add your columns manually
  MyTree.Header.Columns.Clear;

  for i := 0 to length(ColumnParams)-1 do
  with MyTree.Header, ColumnParams[i] do
  begin

    NewColumn := Columns.Add;

    NewColumn.Text      := Name;
    NewColumn.Width     := Len;
    NewColumn.Alignment := Alignment;

  end;

  // If you want that the second column
  // do not respond on clicking
  MyTree.Header.Columns[1].Options :=
    MyTree.Header.Columns[1].Options - [coAllowClick];


 // Setting used events manually

  MyTree.OnBeforeCellPaint := MyTreeBeforeCellPaint;
  MyTree.OnCompareNodes    := MyTreeCompareNodes;
  MyTree.OnFocusChanged    := MyTreeFocusChanged;
  MyTree.OnFreeNode        := MyTreeFreeNode;
  MyTree.OnGetText         := MyTreeGetText;
  MyTree.OnHeaderClick     := MyTreeHeaderClick;
  MyTree.OnPaintText       := MyTreePaintText;

  // To show headers
  MyTree.Header.Options :=
    MyTree.Header.Options + [hoVisible];

  //To show Direction Glyphs
  MyTree.Header.Options :=
    MyTree.Header.Options + [hoShowSortGlyphs];


end;

procedure TMainForm.MyTreeBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin

  // This is example how to conditionally
  // color the cell's backgrounds

  // Color cell's background only for
  // the first three columns with every second nodes
  if (Column<2) and
     ((Node.Index mod 2)=0)
  then begin
    TargetCanvas.Brush.Color := clYellow;
    TargetCanvas.FillRect(CellRect);
  end
end;

procedure TMainForm.MyTreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  n1: ^rTreeData;
  d1: ^TMyRecord;
begin

  // This is example how to conditionally
  // color the cell's font color foregrounds

  if (Column=1) and
     ((Node.Index mod 2)=0)
  then
    TargetCanvas.Font.Color := clRed;

  if (Column=2)
  then begin
    n1 := MyTree.GetNodeData(Node);
    d1 := @MyArrayData[n1.IndexInMyData];

    // Coloring cell's data depending of your data
    if (d1.RNDNumber mod 2)=0
    then begin
      TargetCanvas.Font.Color := clBlue;
      TargetCanvas.Font.Style := [fsBold];
    end;
  end;
end;

procedure TMainForm.MyTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  n1: ^rTreeData;
  d1: ^TMyRecord;
begin

  // Action when you delete the VST node

  if Node <> nil then
  begin
    n1 := MyTree.GetNodeData(Node);
    d1 := @MyArrayData[n1.IndexInMyData];

    // Deactive record in array
    d1.Active := false;

    // Detach pointer to this node in your data
    d1.NodePointer := nil
  end;

end;

procedure TMainForm.MyTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  n1: ^rTreeData;
  d1: ^TMyRecord;
begin
  // Always be sure that Node exist before you
  // delete VST node and use OnFocusChanged even
  // in your code - they  will be always triggered
  // on node deletion

  if Node<> nil then
  begin
    n1 := MyTree.GetNodeData(Node);
    d1 := @MyArrayData[n1.IndexInMyData];

    // Store MyText from array to TEdit
    // after focused item was changed
    Edit1.Text := d1.MyText+', Number '+ IntToStr(d1.RNDNumber)
  end;

end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  btnCleanAll.Click
end;

procedure TMainForm.btnCleanAllClick(Sender: TObject);
begin
  // Fast deletion of all your data and VST nodes

  MyTree.OnFreeNode := nil;

  MyTree.Clear;
  SetLength(MyArrayData,0);

  MyTree.OnFreeNode := MyTreeFreeNode

end;

procedure TMainForm.Edit2Change(Sender: TObject);
var
  Node: PVirtualNode;
  ind: integer;
begin
  ind := StrToIntDef(Edit2.Text,0);

  if ind<length(MyArrayData) then
  begin
    Node := MyArrayData[ind].NodePointer;

    if Node<> nil then
    begin
      // Show it at center of VST
      MyTree.ScrollIntoView(Node,True);

      // Get text from the array
      Edit1.Text :=
        MyArrayData[ind].MyText+', Number '+ IntToStr(MyArrayData[ind].RNDNumber)
      
    end else
      Edit1.Text := 'Node do not exist!'
  end
end;


end.
