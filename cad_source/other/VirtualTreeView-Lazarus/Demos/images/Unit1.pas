{

This example shows how to manipulate with imagse for each cell.
Also support sorting by column clicking and
way to drawing in a cell

The initial developer of this code is Sasa Zeman.
Mailto: public@szutils.net or sasaz72@mail.ru
Web site: www.szutils.net

Created: 7 Jun 2004
Modified: 10 March 2005

This example is distributed "AS IS", WITHOUT
WARRANTY OF ANY KIND, either express or implied.

You use it at your own risk!

Adapted for LCL by Luiz Américo
}

unit Unit1;

{$MODE Delphi}

interface

uses
  DelphiCompat, LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, LResources;

type

  { TForm1 }

  TForm1 = class(TForm)
    VST1: TVirtualStringTree;
    ImageList1: TImageList;
    ImageList2: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure VST1BeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure VST1InitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VST1GetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VST1Checking(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var NewState: TCheckState; var Allowed: Boolean);
    {$if VTMajorVersion >= 5}
    procedure VST1HeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    {$else}
    procedure VST1HeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    {$endif}
    procedure VST1CompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  PMyRec = ^TMyRec;
  TMyRec = record
    Main: String;
    One, Two: integer;
    Percent : integer;
    Index: Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses Math;

procedure TForm1.FormCreate(Sender: TObject);
begin

  // Link images in ImageList2 to VST1.StateImages if it
  // not set already in Oject Inspector
  // It is important to link to VST1.StateImages
  // since we need to use images to all cells
  // (in all columns, not only for main column)
  // Otherwise it will not work properly with VST1.Images
  // VST1.StateImages:= ImageList2;

  // Set data size of data record used for each tree
  VST1.NodeDataSize := SizeOf(TMyRec);

  // Number of initial nodes
  VST1.RootNodeCount := 20;

  // Set XP syle for CheckImage
  VST1.CheckImageKind:=ckXP;
  
  //Start random number generator
  Randomize
end;

procedure TForm1.VST1BeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  I, PercentageSize, RndPercent: integer;
  ColorStart: Word;
  Data: PMyRec;
  R,G,B: byte;
begin
  if (Column = 3) then
  begin

    Data := Sender.GetNodeData(Node);
    RndPercent:=Data.Percent;

    InflateRect(CellRect, -1, -1);
    DrawEdge(TargetCanvas.Handle, CellRect, EDGE_SUNKEN, BF_ADJUST or BF_RECT);
    PercentageSize := (CellRect.Right - CellRect.Left) * RndPercent div 100;

    if True then
    //Multi color approach
    begin
      ColorStart :=clYellow;

      R:= GetRValue(ColorStart);
      G:= GetGValue(ColorStart);
      B:= GetBValue(ColorStart);

      for I := CellRect.Right downto CellRect.Left do
      begin
        TargetCanvas.Brush.Color := RGB(R,G,B);

        if CellRect.Right - CellRect.Left <= PercentageSize then
          TargetCanvas.FillRect(CellRect);
        Dec(CellRect.Right);

        Dec(G);
      end;
    end else
    //One color approach
    begin
      CellRect.Right := CellRect.Left + PercentageSize;
      if RndPercent = 100 then
        TargetCanvas.Brush.Color := clRed
      else
        TargetCanvas.Brush.Color := clLime;
      TargetCanvas.FillRect(CellRect);
    end;
  end;
end;

procedure TForm1.VST1InitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Data: PMyRec;
  s: string;
begin
  Data:=Sender.GetNodeData(Node);

  // Data nitialization during node initialization

  s:= Format('Level %3d, Index %3d', [Sender.GetNodeLevel(Node), Node.Index]);
  Data.Main:='Main ' + s;

  Data.One := Random(ImageList2.Count);
  Data.Two := Random(ImageList2.Count);
  Data.Percent :=  Random (101);
  //fpc does not has RandomRange
  //Data.Percent := RandomRange(0,100);
  Data.Index:= Node.Index;

  // Following code can be coded much efficiantly,
  // but than again it works for now
  // and determinate CheckType for each node

  if Data.Index>=0 then
    // Set RadioButton
     Node.CheckType := ctRadioButton;

  if Data.Index>=4 then
    // Set CheckBox
    Node.CheckType:= ctCheckBox;

  if Data.Index>=8 then
    // Set Button
    Node.CheckType:= ctButton;

  if Data.Index>=12 then
    // Set ctTriStateCheckBox
    Node.CheckType:= ctTriStateCheckBox;

  if Data.Index>=16 then
    // Set nothing
    Node.CheckType:= ctNone;

end;

procedure TForm1.VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  Data: PMyRec;
begin
  Data:=Sender.GetNodeData(Node);

  case column of
    0: CellText:=Data.Main;
    1: CellText:=IntToStr(Data.One);
    2: CellText:=IntToStr(Data.Two);
    3: CellText:=IntToStr(Data.Percent)+'%';
  end
end;

procedure TForm1.VST1GetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PMyRec;
begin
  Data := Sender.GetNodeData(Node);

  {

  Kind:=ikNormal;
    ikNormal,
    ikSelected,
    ikState,
    ikOverlay
  }

  // Conditional image index setting for each cell (node and column)
  case Column of
    0: if Data.Index<12 then
          ImageIndex:=3
        else
          ImageIndex:=25;
    1: ImageIndex:=Data.One;
    2: ImageIndex:=Data.Two;
  end;
end;

procedure TForm1.VST1Checking(Sender: TBaseVirtualTree; Node: PVirtualNode;
  var NewState: TCheckState; var Allowed: Boolean);
var
  Data: PMyRec;
  s: string;
begin
  Data := Sender.GetNodeData(Node);

  // Determinate which CheckType is pressed
  // Instead of this, here can be some real action
  case Node.CheckType of
    ctTriStateCheckBox: s:='TriStateCheckBox';
    ctCheckBox        : s:='CheckBox';
    ctRadioButton     : s:='RadioButton';
    ctButton          : s:='Button';
  end;

  caption:=s+' '+Data.Main;
  Allowed:=true
end;

{$if VTMajorVersion >= 5}
procedure TForm1.VST1HeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
var
  Button: TMouseButton;
  Column: TColumnIndex;
{$else}
procedure TForm1.VST1HeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{$endif}
begin
  {$if VTMajorVersion >= 5}
  Button := HitInfo.Button;
  Column := HitInfo.Column;
  {$endif}

  // Determinate sorting direction
  if Button=mbLeft then
  with Sender do
  begin
    if SortColumn <> Column then
       SortColumn := Column
    else begin
      if SortDirection = sdAscending then
        SortDirection := sdDescending
      else
        SortDirection := sdAscending
    end;

    // Initiate sorting
    VST1.SortTree(Column, Sender.SortDirection, False);
  end;
end;

procedure TForm1.VST1CompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  Data1, Data2: PMyRec;
begin
  Data1:=Sender.GetNodeData(Node1);
  Data2:=Sender.GetNodeData(Node2);

  // Depending on column in VST1.SortTree(...)
  // returns comparing result to internal sorting procedure

  Result:=0;
  case column of
     0: Result:=CompareStr(Data1.Main,Data2.Main);
     1: begin
          Result:=CompareValue(Data1.One,Data2.One);
          // If numbers are equal, compare value from next column
          // On this way we product more complex sorting
          if Result=0 then
             Result:=CompareValue(Data1.Two,Data2.Two);
        end;
     2: Result:=CompareValue(Data1.Two,Data2.Two);
     3: Result:=CompareValue(Data1.Percent,Data2.Percent);

  end
end;

end.
