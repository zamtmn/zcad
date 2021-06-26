unit AppExploreFrm;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, Buttons, RTTIGrids, TypInfo;

{ TAppExplorerForm is a form that presents a tree of all component
  instances recursively owned by the Application variable }

type
  TAppExplorerForm = class(TForm)
    ButtonImages: TImageList;
    ComponentEdit: TEdit;
    ComponentPanel: TPanel;
    EditSheet: TTabSheet;
    ComponentMemo: TMemo;
    PageControl: TPageControl;
    ComponentGrid: TTIPropertyGrid;
    SearchEdit: TEdit;
    SearchLabel: TLabel;
    Panel: TPanel;
    PriorButton: TSpeedButton;
    NextButton: TSpeedButton;
    ClearButton: TSpeedButton;
    SearchResults: TLabel;
    Splitter: TSplitter;
    FlashTimer: TTimer;
    TextSheet: TTabSheet;
    TreeImages: TImageList;
    RefreshButton: TButton;
    CloseButton: TButton;
    TreeView: TTreeView;
    procedure ClearButtonClick(Sender: TObject);
    procedure FlashTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MoveButtonClick(Sender: TObject);
    procedure SearchEditChange(Sender: TObject);
    procedure SpeedButtonPaint(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    { Flash when a tree node is double clicked }
    procedure TreeViewDblClick(Sender: TObject);
    { Or when the spacebar is pressed }
    procedure TreeViewKeyPress(Sender: TObject; var Key: char);
  protected
    procedure Loaded; override;
  private
    FSearchList: TList;
    FFilterList: TList;
    FSearchTerm: string;
    FSearchIndex: Integer;
    FFlashWindow: THintWindow;
    { The Flash method breifly positions FFlashWindow over a control }
    procedure Flash(Instance: TControl);
    { The Pack method aligns the search controls at the bottom of the form }
    procedure Pack;
    { The RefreshSelection method repopulates the ComponentMemo text }
    procedure RefreshView;
    { The RefreshView method repopulates the component tree view }
    procedure RefreshSelection(Node: TTreeNode);
  end;

{ The ShowAppExplorer procedure creates and shows an application explorer form }

procedure ShowAppExplorer;

implementation

{$R *.lfm}

var
  InternalAppExplorerForm: TObject;

procedure ShowAppExplorer;
begin
  if InternalAppExplorerForm = nil then
    InternalAppExplorerForm := TAppExplorerForm.Create(Application);
  TForm(InternalAppExplorerForm).Show;
  TForm(InternalAppExplorerForm).BringToFront;
end;

{ TClassImage is used to lookup the image index of a class }

type
  TClassImage = record
    ClassName: string;
    Image: Integer;
  end;

var
  ClassImages: array[0..31] of TClassImage = (
    (ClassName: 'TMENUITEM'; Image: 19),
    (ClassName: 'TMENU'; Image: 19),
    (ClassName: 'TBASICACTION'; Image: 0),
    (ClassName: 'TDATAMODULE'; Image: 1),
    (ClassName: 'TCUSTOMFORM'; Image: 1),
    (ClassName: 'TSCROLLINGWINCONTROL'; Image: 2),
    (ClassName: 'TCUSTOMFRAME'; Image: 2),
    (ClassName: 'TCONTROLSCROLLBAR'; Image: 3),
    (ClassName: 'TSCROLLBAR'; Image: 4),
    (ClassName: 'TCUSTOMSTATUSBAR'; Image: 5),
    (ClassName: 'TCUSTOMTABCONTROL'; Image: 6),
    (ClassName: 'TCUSTOMGROUPBOX'; Image: 7),
    (ClassName: 'TCUSTOMLISTBOX'; Image: 8),
    (ClassName: 'TCUSTOMCOMBOBOX'; Image: 8),
    (ClassName: 'TPROGRESSBAR'; Image: 9),
    (ClassName: 'TCUSTOMCHECKBOX'; Image: 10),
    (ClassName: 'TRADIOBUTTON'; Image: 11),
    (ClassName: 'TBUTTONCONTROL'; Image: 12),
    (ClassName: 'TCUSTOMRICHEDIT'; Image: 14),
    (ClassName: 'TCUSTOMMEMO'; Image: 15),
    (ClassName: 'TCUSTOMPANEL'; Image: 19),
    (ClassName: 'TCUSTOMEDIT'; Image: 16),
    (ClassName: 'TCUSTOMCONTROL'; Image: 18),
    (ClassName: 'TWINCONTROL'; Image: 17),
    (ClassName: 'TCUSTOMCONTROL'; Image: 17),
    (ClassName: 'TCUSTOMLABEL'; Image: 20),
    (ClassName: 'TIMAGE'; Image: 21),
    (ClassName: 'TGRAPHICCONTROL'; Image: 22),
    (ClassName: 'TCUSTOMIMAGELIST'; Image: 23),
    (ClassName: 'TCOMMONDIALOG'; Image: 24),
    (ClassName: 'TCONTROL'; Image: 25),
    (ClassName: 'TCOMPONENT'; Image: 26)
  );

function GetClassImageIndex(Instance: TObject): Integer;
var
  C: TClass;
  S: string;
  I: Integer;
begin
  Result := ClassImages[High(ClassImages)].Image;
  C := Instance.ClassType;
  while C.ClassType <> TComponent.ClassType do
  begin
    S := UpperCase(C.ClassName);
    for I := Low(ClassImages) to High(ClassImages) do
      if S = ClassImages[I].ClassName then
        Exit(ClassImages[I].Image);
    C := C.ClassParent;
  end;
end;

{ TAppExplorerForm }

procedure TAppExplorerForm.FormCreate(Sender: TObject);
const
  Margin = 8;
begin
  FSearchList := TList.Create;
  FFilterList := TList.Create;
  ClientWidth := CloseButton.Left + CloseButton.Width + Margin;
  ClientHeight := CloseButton.Top + CloseButton.Height + Margin;
  Panel.Anchors := [akLeft, akTop, akRight, akBottom];
  RefreshButton.Anchors := [akRight, akBottom];
  CloseButton.Anchors := [akRight, akBottom];
  RefreshView;
end;

procedure TAppExplorerForm.FormDestroy(Sender: TObject);
begin
  FFilterList.Free;
  FSearchList.Free;
  InternalAppExplorerForm := nil;
end;

procedure TAppExplorerForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TAppExplorerForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAppExplorerForm.SpeedButtonPaint(Sender: TObject);
var
  Button: TSpeedButton absolute Sender;
  I: Integer;
begin
  I := 1;
  if csClicked in Button.ControlState then
    Inc(I);
  ButtonImages.Draw(Button.Canvas, I, I, Button.Tag, Button.Enabled);
end;

procedure TAppExplorerForm.FormShow(Sender: TObject);
begin
  { Pack is needed OnShow because some control dimensions differ
    based on widgetset, and this size difference is not realized
    until they are first presented }
  Pack;
end;

procedure TAppExplorerForm.MoveButtonClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  if sender = NextButton then
  begin
    FSearchIndex := FSearchIndex + 1;
    FSearchIndex := FSearchIndex mod FFilterList.Count;
  end
  else
  begin
    if FSearchIndex = -1 then
      FSearchIndex := 0;
    FSearchIndex := FSearchIndex - 1;
    if FSearchIndex < 0 then
      FSearchIndex := FFilterList.Count - 1;
  end;
  Node := TTreeNode(FFilterList[FSearchIndex]);
  TreeView.Selected := Node;
  if FFilterList.Count = 1 then
    SearchResults.Caption := 'Match 1 of 1'
  else
    SearchResults.Caption := 'Match ' + IntToStr(FSearchIndex + 1) + ' of ' +
      IntToStr(FFilterList.Count) ;
end;

procedure TAppExplorerForm.ClearButtonClick(Sender: TObject);
begin
  SearchEdit.Text := '';
end;

procedure TAppExplorerForm.SearchEditChange(Sender: TObject);
var
  Node: TTreeNode;
  S: string;
  I: Integer;
begin
  S := Trim(SearchEdit.Text);
  S := UpperCase(S);
  if S = FSearchTerm then
    Exit;
  FSearchTerm := S;
  FSearchIndex := -1;
  FFilterList.Clear;
  for I := 0 to FSearchList.Count - 1 do
  begin
    Node := TTreeNode(FSearchList[I]);
    S := UpperCase(Node.Text);
    if Pos(FSearchTerm, S) > 0 then
      FFilterList.Add(Node);
  end;
  ClearButton.Enabled := FSearchTerm <> '';
  PriorButton.Enabled := FFilterList.Count > 0;
  NextButton.Enabled := FFilterList.Count > 0;
  if FFilterList.Count > 0 then
    MoveButtonClick(NextButton)
  else
    SearchResults.Caption := '';
  { Pack also hides and shows controls based on their enabled state }
  Pack;
end;

procedure TAppExplorerForm.RefreshButtonClick(Sender: TObject);
begin
  RefreshView;
end;

procedure TAppExplorerForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  RefreshSelection(Node);
end;

{ TFlashWindow displays a red highlight over a visible control }

type
  TFlashWindow = class(THintWindow)
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TFlashWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := clRed;
  Width := 100;
  Height := 100;
  AlphaBlend := True;
  AlphaBlendValue := 100;
end;

procedure TAppExplorerForm.FlashTimerTimer(Sender: TObject);
begin
  FFlashWindow.Free;
  FFlashWindow := nil;
  FlashTimer.Enabled := False;
end;

procedure TAppExplorerForm.Flash(Instance: TControl);
var
  WinParent: TControl;
  P: TPoint;
  R: TRect;
begin
  FlashTimer.Enabled := False;
  FFlashWindow.Free;
  FFlashWindow := nil;
  WinParent := Instance;
  while WinParent <> nil do
  begin
    { If any parent of Instance is not visible then do not flash }
    if not WinParent.Visible then
      Exit;
    WinParent := WinParent.Parent;
  end;
  P := Instance.ClientToScreen(Point(0, 0));
  R := Instance.BoundsRect;
  R.Right := R.Right - R.Left + P.X;
  R.Bottom := R.Bottom - R.Top + P.Y;
  R.Left := P.X;
  R.Top := P.Y;
  FFlashWindow := TFlashWindow.Create(Application);
  FFlashWindow.BoundsRect := R;
  FFlashWindow.Show;
  FlashTimer.Enabled := True;
end;

procedure TAppExplorerForm.TreeViewDblClick(Sender: TObject);
var
  Key: Char;
begin
  Key := ' ';
  TreeViewKeyPress(TreeView, Key);
end;

procedure TAppExplorerForm.TreeViewKeyPress(Sender: TObject; var Key: char);
var
  Instance: TObject;
  Node: TTreeNode;
begin
  if Key = ' ' then
  begin
    Node := TreeView.Selected;
    if Node = nil then
      Exit;
    Instance := TObject(Node.Data);
    if Instance is TControl then
      Flash(Instance as TControl);
  end;
end;

procedure TAppExplorerForm.Loaded;
begin
  inherited Loaded;
  ComponentGrid.SplitterX := ComponentGrid.Width div 2;
end;

procedure TAppExplorerForm.Pack;

  procedure PackControls(const Controls: array of TControl; Middle: Integer);
  const
    Margin = 8;
  var
    Left: Integer;
    C: TControl;
  begin
    Left := Margin;
    for C in Controls do
    begin
      C.Anchors := [akLeft, akBottom];
      C.Visible := C.Enabled;
      if C.Visible then
      begin
        C.Left := Left;
        Left := Left + C.Width + Margin div 2;
        C.Top := Middle - C.Height div 2;
      end;
    end;
  end;

begin
  PackControls([ClearButton, SearchLabel, SearchEdit, PriorButton, NextButton,
    SearchResults], CloseButton.Top + CloseButton.Height div 2);
end;

procedure TAppExplorerForm.RefreshView;
var
  ComponentList: TList;

  function AttachComponent(Parent: TTreeNode; Component: TComponent): TTreeNode;
  var
    S: string;
  begin
    ComponentList.Add(Component);
    if Component.Name <> '' then
      S := Component.Name + ': ' + Component.ClassName
    else
      S := Component.ClassName;
    Result := TreeView.Items.AddChild(Parent, S);
    Result.Data := Component;
    Result.ImageIndex := GetClassImageIndex(Component);
    FSearchList.Add(Result);
  end;

  procedure AddNode(Parent: TTreeNode; Component: TComponent);
  var
    Container: TWinControl;
    SubComponent: TComponent;
    Item: TTreeNode;
    I: Integer;
  begin
    Item := AttachComponent(Parent, Component);
    if Component is TWinControl then
    begin
      Container := Component as TWinControl;
      for I := 0 to Container.ControlCount - 1 do
        AddNode(Item, Container.Controls[I]);
    end;
    for I := 0 to Component.ComponentCount - 1 do
    begin
      SubComponent := Component.Components[I];
      if ComponentList.IndexOf(SubComponent) < 0 then
        AddNode(Item, SubComponent);
    end;
  end;

begin
  SearchEdit.Text := '';
  ComponentList := TList.Create;
  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;
    FSearchList.Clear;
    AddNode(nil, Application);
    TreeView.Items.GetFirstNode.Expand(False);
  finally
    TreeView.Items.EndUpdate;
    ComponentList.Free;
  end;
  RefreshSelection(nil);
end;

procedure TAppExplorerForm.RefreshSelection(Node: TTreeNode);

  procedure AddClassInfo(Instance: TComponent);
  var
    TypeInfo: PTypeInfo;
    TypeData: PTypeData;
    S: string;
  begin
    TypeInfo := PTypeInfo(Instance.ClassInfo);
    TypeData := GetTypeData(TypeInfo);
    S := TypeData.ClassType.ClassName + ' declared in ' + TypeData.UnitName;
    ComponentMemo.Lines.Add(S);
    ComponentMemo.Lines.Add('');
  end;

  procedure AddParentOwner(Instance: TComponent);

    function Name: string;
    begin
      if Instance.Name = '' then
        Result := Instance.ClassName
      else
        Result := Instance.ClassName + '(' + Instance.Name + ')';
      Result := '  ' + Result;
    end;

  var
    Parent: TWinControl;
    S: string;
  begin
    ComponentMemo.Lines.Add('Hierarchy:');
    S := Name;
    while Instance <> nil do
    begin
      if Instance is TControl then
        Parent := (Instance as TControl).Parent
      else
        Parent := nil;
      if Parent <> nil then
        Instance := Parent
      else
        Instance := Instance.Owner;
      if Instance = nil then
        Break;
      ComponentMemo.Lines.Add(S);
      S := Name;
    end;
    ComponentMemo.Lines.Add(S);
    ComponentMemo.Lines.Add('');
  end;

  procedure AddInheritance(Instance: TComponent);
  var
    S: string;
    C: TClass;
  begin
    ComponentMemo.Lines.Add('ComponentState:');
    S := SetToString(PTypeInfo(TypeInfo(TComponentState)), Integer(Instance.ComponentState), True);
    ComponentMemo.Lines.Add(S);
    ComponentMemo.Lines.Add('');
    ComponentMemo.Lines.Add('Inheritance:');
    C := Instance.ClassType;
    while C <> nil do
    begin
      ComponentMemo.Lines.Add('  ' + C.ClassName);
      C := C.ClassParent;
    end;
    ComponentMemo.Lines.Add('');
  end;

  procedure AddPropertyList(Instance: TComponent);
  var
    Info: PTypeInfo;
    Data: PTypeData;
    List: PPropList;
    Prop: PPropInfo;
    StrProp: string;
    IntProp: Int64;
    FloatProp: Double;
    ObjProp: IntPtr;
    S: string;
    I: Integer;
  begin
    ComponentMemo.Lines.Add('Properties:');
    Info := PTypeInfo(Instance.ClassInfo);
    Data := GetTypeData(Info);
    if Data.PropCount < 1 then
      Exit;
    List := GetMem(Data.PropCount * SizeOf(Pointer));
    try
      GetPropList(Info, tkAny, List);
      for I := 0 to Data.PropCount - 1 do
      begin
        Prop := List^[I];
        S := '';
        case Prop.PropType.Kind of
          tkSString, tkLString, tkAString, tkWString, tkUString:
            begin
              StrProp := GetStrProp(Instance, Prop);
              if StrProp <> '' then
                S := Prop.Name + ': ' + StrProp;
            end;
          tkBool:
            begin
              IntProp := GetOrdProp(Instance, Prop);
              S := Prop.Name + ': ' + BooleanIdents[IntProp <> 0];
            end;
          tkChar, tkWChar, tkUChar:
            begin
              IntProp := GetOrdProp(Instance, Prop);
              if IntProp <= Ord(' ') then
                S := Prop.Name + ': #' + IntToStr(IntProp)
              else
                S := Prop.Name + ': ' + Chr(IntProp);
            end;
          tkInteger, tkInt64, tkQWord:
            begin
              IntProp := GetOrdProp(Instance, Prop);
              if Prop.PropType = TypeInfo(TColor) then
                S := Prop.Name + ': ' + ColorToString(IntProp)
              else if Prop.PropType = TypeInfo(TCursor) then
                S := Prop.Name + ': ' + CursorToString(IntProp)
              else
                S := Prop.Name + ': ' + IntToStr(IntProp);
            end;
          tkEnumeration:
            begin
              IntProp := GetOrdProp(Instance, Prop);
              S := Prop.Name + ': ' + GetEnumName(Prop.PropType, IntProp);
            end;
          tkSet:
            begin
              StrProp := GetSetProp(Instance, Prop, True);
              S := Prop.Name + ': ' + StrProp;
            end;
          tkFloat:
            begin
              FloatProp := GetFloatProp(Instance, Prop);
              if Prop.PropType = TypeInfo(TDateTime) then
                S := Prop.Name + ': ' + DateTimeToStr(FloatProp)
              else
                S := Prop.Name + ': ' + FloatToStr(FloatProp);
            end;
          tkClass:
            begin
              if Copy(Prop.Name, 1, 10) = 'AnchorSide' then
                Continue;
              if Prop.Name = 'BorderSpacing' then
                Continue;
              if Prop.Name = 'Constraints' then
                Continue;
              if Prop.Name = 'ChildSizing' then
                Continue;
              if Prop.Name = 'Font' then
                Continue;
              ObjProp := GetOrdProp(Instance, Prop);
              if ObjProp <> 0 then
                S := Prop.Name + ': (' + TObject(ObjProp).ClassName + ')';
            end
        else
          S := '';
        end;
        if S <> '' then
          ComponentMemo.Lines.Add('  ' + S);
      end;
      ComponentMemo.Lines.Add('');
    finally
      FreeMem(List);
    end;
  end;

  procedure AddProperties(Instance: TComponent);
  var
    Input: TMemoryStream;
    Output: TStringStream;
  begin
    Input := TMemoryStream.Create;
    Output := TStringStream.Create('');
    try
      Input.WriteComponent(Instance);
      Input.Seek(0, 0);
      ObjectBinaryToText(Input, Output);
      ComponentMemo.Lines.Add(Output.DataString);
      ComponentMemo.Lines.Add('');
    finally
      Output.Free;
      Input.Free;
    end;
  end;

var
  Component: TComponent;
  S: string;
begin
  ComponentMemo.Lines.BeginUpdate;
  try
    ComponentMemo.Lines.Clear;
    ComponentEdit.Text := '';
    ComponentGrid.TIObject := nil;
    if Node = nil then
      Exit;
    Component := TComponent(Node.Data);
    S := Component.Name;
    if S = '' then
      S := '(unnamed)';
    ComponentEdit.Text := S + ': ' + Component.ClassName;
    ComponentGrid.TIObject := nil;
    ComponentGrid.TIObject := Component;
    ComponentGrid.SplitterX := ComponentGrid.Width div 2;
    AddClassInfo(Component);
    AddParentOwner(Component);
    AddInheritance(Component);
    AddPropertyList(Component);
    ComponentMemo.SelStart := 0;
  finally
    ComponentMemo.Lines.EndUpdate;
  end;
end;

end.