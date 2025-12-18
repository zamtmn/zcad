unit uzcflinetypes;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ButtonPanel, Buttons, ExtCtrls, ComCtrls, Spin, ActnList,LCLProc,
  uzcinterface,uzcgui2linetypes,uzcflinetypesload,uzcsysvars,uzedrawingsimple,
  uzestyleslinetypes,uzcdrawings,uzcimagesmanager,uzbstrproc,usupportgui,uzeutils,
  gzctnrVectorTypes,uzbpaths,uzcstrconsts,UGDBNamedObjectsArray,uzcuitypes,
  uzcLog;

type

  { TLineTypesForm }

  TLineTypesForm = class(TForm)
    DelLt: TAction;
    MkCurr: TAction;
    ActionList1: TActionList;
    CoolBar1: TCoolBar;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    GScale: TFloatSpinEdit;
    CScale: TFloatSpinEdit;
    GroupBox2: TGroupBox;
    LTDescLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure MakeCurrentLT(Sender: TObject);
    procedure DeletetLT(Sender: TObject);
    procedure _close(Sender: TObject; var CloseAction: TCloseAction);
    procedure _CreateLT(Sender: TObject);
    procedure _LoadLT(Sender: TObject);
    procedure _LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure _LTChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure _onCDSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure _onCreate(Sender: TObject);
    procedure UpdateItem(Item: TListItem);
    procedure countlt(plt:PGDBLtypeProp;out e,b:Integer);
    procedure _UpdateLT(Sender: TObject);
    procedure _UpDateLV(LV:TListView;SLT:PGDBLtypeProp);
  private
    { private declarations }
  public
     CurrentLType:TListItem;
    { public declarations }
  end;

var
  LineTypesForm: TLineTypesForm;

implementation

{$R *.lfm}

{ TLineTypesForm }

procedure TLineTypesForm.UpdateItem(Item: TListItem);
var
  pdwg:PTSimpleDrawing;
  pltp:PGDBLtypeProp;
begin
  pdwg:=drawings.GetCurrentDWG;
  pltp:=Item.Data;
  Item.SubItems.Clear;
  if pltp=pdwg^.GetCurrentLType then begin
    Item.ImageIndex:=ImagesManager.GetImageIndex('ok');;
    CurrentLType:=Item;
  end;
    Item.SubItems.Add({uzbstrproc.Tria_AnsiToUtf8}(pltp^.Name));
    Item.SubItems.Add('');
    Item.SubItems.Add({uzbstrproc.Tria_AnsiToUtf8}(pltp^.desk));
end;
procedure TLineTypesForm._UpDateLV(LV:TListView;SLT:PGDBLtypeProp);
var
  pdwg:PTSimpleDrawing;
  ir:itrec;
  pltp:PGDBLtypeProp;
  li:TListItem;
begin
  LV.BeginUpdate;
  LV.Clear;
  pdwg:=drawings.GetCurrentDWG;
  if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then begin
    pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
    if pltp<>nil then
    repeat
      li:=LV.Items.Add;
      li.Data:=pltp;
      li.Selected:=false;
      UpdateItem(li);
      if SLT<>nil then
        if pltp=slt then
          LV.Selected:=li;
      pltp:=pdwg^.LTypeStyleTable.iterate(ir);
    until pltp=nil;
  end;
  LV.EndUpdate;
end;

procedure TLineTypesForm._onCreate(Sender: TObject);
begin
  ActionList1.Images:=ImagesManager.IconList;
  ToolBar1.Images:=ImagesManager.IconList;
  MkCurr.ImageIndex:=ImagesManager.GetImageIndex('ok');
  DelLt.ImageIndex:=ImagesManager.GetImageIndex('minus');
  GScale.Value:=sysvar.DWG.DWG_LTScale^;
  CScale.Value:=sysvar.DWG.DWG_CLTScale^;
  CheckBox1.Checked:=sysvar.DWG.DWG_RotateTextInLT^;
  ListView1.SmallImages:=ImagesManager.IconList;
  _UpDateLV(ListView1,nil);
  Panel3.Constraints.MinWidth:=ToolBar1.Left+ToolButton2.Left+ToolButton2.Width+CoolBar1.GrabWidth;
end;

procedure TLineTypesForm._onCDSubItem(Sender: TCustomListView; Item: TListItem;
                                      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  BrushColor,FontColor:TColor;
  ARect: TRect;
begin
  if SubItem<>2 then
    DefaultDraw:=true
  else begin
    BrushColor:=TCustomListView(sender).canvas.Brush.Color;
    FontColor:=TCustomListView(sender).canvas.Font.Color;

    ARect:=ListViewDrawSubItem(state,sender.canvas,Item,SubItem);
    ARect := Item.DisplayRectSubItem( SubItem,drLabel);
    drawLT(TCustomListView(Sender).canvas,ARect,{ll,}'',Item.Data);

    TCustomListView(sender).canvas.Brush.Color:=BrushColor;
    TCustomListView(sender).canvas.Font.Color:=FontColor;
    DefaultDraw:=false;
  end;
end;

procedure TLineTypesForm._LTChange(Sender: TObject; Item: TListItem;
                                   Change: TItemChange);
begin

end;
procedure TLineTypesForm.countlt(plt:PGDBLtypeProp;out e,b:Integer);
var
  pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(plt,e,@LTypeCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(plt,b,@LTypeCounter);
end;

procedure TLineTypesForm._UpdateLT(Sender: TObject);
var
  pltp:PGDBLtypeProp;
  pdwg:PTSimpleDrawing;
  li:TListItem;
  ltd:tstrings;
  CurrentLine:integer;
  LTName,LTDesk,LTImpl:String;
begin
  li:=ListView1.Selected;
  ltd:=tstringlist.Create;
  ltd.Text:=self.Memo1.Text;
  pdwg:=drawings.GetCurrentDWG;
  if li<>nil then
    pltp:=li.Data
  else
    pltp:=nil;
  if pltp<>nil then
    if pltp^.Mode<>TLTLineType then
      pltp:=nil;
  if (pltp=nil) then begin
    zcUI.TextMessage('Please select non system layer!!!',TMWOShowError);
    exit;
  end;
  CurrentLine:=1;
  pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
  LTName:=uzbstrproc.Tria_Utf8ToAnsi(LTName);
  LTDesk:=uzbstrproc.Tria_Utf8ToAnsi(LTDesk);
  LTImpl:=uzbstrproc.Tria_Utf8ToAnsi(LTImpl);
  pltp^.Name:=LTName;
  pltp^.desk:=LTDesk;
  pltp^.CreateLineTypeFrom(LTImpl);
  pdwg.AssignLTWithFonts(pltp);
  pltp^.Format;
  _UpDateLV(ListView1,pltp);
  ltd.Free;
end;

procedure TLineTypesForm._LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  pltp:PGDBLtypeProp;
  inent,inblock:integer;
begin
  if selected then begin
    pltp:=(Item.Data);
    countlt(pltp,inent,inblock);
    LTDescLabel.Caption:=Format(rsLineTypeUsedIn,[{Tria_AnsiToUtf8}(pltp^.Name),inent,inblock]);
    if pltp^.Mode=TLTLineType then
      Memo1.Text:=Format(rsLineTypeDesk,[pltp^.LengthDXF,pltp^.strokesarray.LengthFact,{Tria_AnsiToUtf8}(pltp^.getastext)])
    else
      Memo1.Text:=rsSysLineTypeWarning;
  end;
end;

procedure TLineTypesForm._CreateLT(Sender: TObject);
var
  pltp:PGDBLtypeProp;
  pdwg:PTSimpleDrawing;
  ltd:tstrings;
  CurrentLine:integer;
  LTName,LTDesk,LTImpl:String;
begin
  pdwg:=drawings.GetCurrentDWG;
  CurrentLine:=1;
  ltd:=tstringlist.Create;
  ltd.Text:=self.Memo1.Text;
  pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
  LTName:=uzbstrproc.Tria_Utf8ToAnsi(LTName);
  LTDesk:=uzbstrproc.Tria_Utf8ToAnsi(LTDesk);
  LTImpl:=uzbstrproc.Tria_Utf8ToAnsi(LTImpl);

  if (pdwg^.GetLTypeTable.AddItem(LTName,pltp)<>IsCreated) then begin
    zcUI.TextMessage('Line type name already exist!!!',TMWOShowError);
    exit;
  end;

  pltp^.init(LTName);
  pltp^.desk:=LTDesk;
  pltp^.CreateLineTypeFrom(LTImpl);
  pdwg.AssignLTWithFonts(pltp);
  pltp^.Format;
  _UpDateLV(ListView1,pltp);
  ltd.Free;
end;

procedure TLineTypesForm._LoadLT(Sender: TObject);
begin
  LineTypesLoadForm:=TLineTypesLoadForm.Create(nil);
  if LineTypesLoadForm.run(FindInPaths(GetSupportPaths,'zcad.lin'))=ZCmrok then
    Memo1.Text:=LineTypesLoadForm.text;
  Freeandnil(LineTypesLoadForm);
end;

procedure TLineTypesForm.MakeCurrentLT(Sender: TObject);
begin
  ProgramLog.LogOutStr(rsNotYetImplemented,LM_Warning,1,MO_SH or MO_SM);
end;
procedure TLineTypesForm.DeletetLT(Sender: TObject);
begin
  ProgramLog.LogOutStr(rsNotYetImplemented,LM_Warning,1,MO_SH or MO_SM);
end;

procedure TLineTypesForm._close(Sender: TObject; var CloseAction: TCloseAction);
begin
  if self.ModalResult=MrOk then begin
    sysvar.DWG.DWG_LTScale^:=GScale.Value;
    sysvar.DWG.DWG_CLTScale^:=CScale.Value;
    sysvar.DWG.DWG_RotateTextInLT^:=CheckBox1.Checked;
  end;
end;

end.
