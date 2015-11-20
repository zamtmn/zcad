unit ltwnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, Buttons, ExtCtrls, ComCtrls, Spin,

  linetypesloadwnd,zcadsysvars, ugdbsimpledrawing, gdbase, gdbasetypes,
  ugdbltypearray,UGDBDescriptor,imagesmanager,uzcsysinfo,strproc,usupportgui,ugdbutil,
  paths,zcadstrconsts,shared,UGDBNamedObjectsArray;

type

  { TLTWindow }

  TLTWindow = class(TForm)
    DeleteLtBtn: TSpeedButton;
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
    MkCurrentBtn: TSpeedButton;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure MkCurrentBtnClick(Sender: TObject);
    procedure _close(Sender: TObject; var CloseAction: TCloseAction);
    procedure _CreateLT(Sender: TObject);
    procedure _LoadLT(Sender: TObject);
    procedure _LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure _LTChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure _onCDSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure _onCreate(Sender: TObject);
    procedure UpdateItem(Item: TListItem);
    procedure countlt(plt:PGDBLtypeProp;out e,b:GDBInteger);
    procedure _UpdateLT(Sender: TObject);
    procedure _UpDateLV(LV:TListView;SLT:PGDBLtypeProp);
  private
    { private declarations }
  public
     CurrentLType:TListItem;
    { public declarations }
  end;

var
  LTWindow: TLTWindow;

implementation

uses mainwindow;
{$R *.lfm}

{ TLTWindow }

procedure TLTWindow.UpdateItem(Item: TListItem);
var
   pdwg:PTSimpleDrawing;
   pltp:PGDBLtypeProp;
begin
     pdwg:=gdb.GetCurrentDWG;
     pltp:=Item.Data;
     Item.SubItems.Clear;
     if pltp=pdwg^.LTypeStyleTable.GetCurrentLType then
                                                             begin
                                                             Item.ImageIndex:=II_Ok;
                                                             CurrentLType:=Item;
                                                             end;
                 Item.SubItems.Add(strproc.Tria_AnsiToUtf8(pltp^.Name));
                 Item.SubItems.Add('');
                 Item.SubItems.Add(strproc.Tria_AnsiToUtf8(pltp^.desk));
end;
procedure TLTWindow._UpDateLV(LV:TListView;SLT:PGDBLtypeProp);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
   //s:ansistring;
   li:TListItem;
begin
     LV.BeginUpdate;
     LV.Clear;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
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

procedure TLTWindow._onCreate(Sender: TObject);
begin
     ListView1.SmallImages:=IconList;
     IconList.GetBitmap(II_Minus,DeleteLtBtn.Glyph);
     IconList.GetBitmap(II_Ok,MkCurrentBtn.Glyph);
     GScale.Value:=sysvar.DWG.DWG_LTScale^;
     CScale.Value:=sysvar.DWG.DWG_CLTScale^;
     CheckBox1.Checked:=sysvar.DWG.DWG_RotateTextInLT^;
     _UpDateLV(ListView1,nil);
end;

procedure TLTWindow._onCDSubItem(Sender: TCustomListView; Item: TListItem;
  SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
var
   BrushColor,FontColor:TColor;
   ARect: TRect;
begin
     if SubItem<>2 then
                       DefaultDraw:=true
                   else
                       begin
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

procedure TLTWindow._LTChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

end;
procedure TLTWindow.countlt(plt:PGDBLtypeProp;out e,b:GDBInteger);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(plt,e,@LTypeCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(plt,b,@LTypeCounter);
end;

procedure TLTWindow._UpdateLT(Sender: TObject);
var
   pltp:PGDBLtypeProp;
   pdwg:PTSimpleDrawing;
   li:TListItem;
   ltd:tstrings;
   CurrentLine:integer;
   LTName,LTDesk,LTImpl:GDBString;
begin
     li:=ListView1.Selected;
     ltd:=tstringlist.Create;
     ltd.Text:=self.Memo1.Text;
     pdwg:=gdb.GetCurrentDWG;
     if li<>nil then
                    pltp:=li.Data
                else
                    pltp:=nil;
     if pltp<>nil then
                      if pltp^.Mode<>TLTLineType then
                                                     pltp:=nil;
     if (pltp=nil) then
                     begin
                          shared.ShowError('Please select non system layer!!!');
                          exit;
                     end;
     CurrentLine:=1;
     pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
     LTName:=strproc.Tria_Utf8ToAnsi(LTName);
     LTDesk:=strproc.Tria_Utf8ToAnsi(LTDesk);
     LTImpl:=strproc.Tria_Utf8ToAnsi(LTImpl);
     pltp^.Name:=LTName;
     pltp^.desk:=LTDesk;
     pltp^.CreateLineTypeFrom(LTImpl);
     pdwg.AssignLTWithFonts(pltp);
     pltp^.Format;
     _UpDateLV(ListView1,pltp);
     ltd.Free;
end;

procedure TLTWindow._LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
var
   pltp:PGDBLtypeProp;
   pdwg:PTSimpleDrawing;
   inent,inblock:integer;
begin
     if selected then
     begin
          pdwg:=gdb.GetCurrentDWG;
          pltp:=(Item.Data);
          countlt(pltp,inent,inblock);
          LTDescLabel.Caption:=Format(rsLineTypeUsedIn,[Tria_AnsiToUtf8(pltp^.Name),inent,inblock]);
          if pltp^.Mode=TLTLineType then
                                        Memo1.Text:=Format(rsLineTypeDesk,[pltp^.len,Tria_AnsiToUtf8(pltp^.getastext)])
                                    else
                                        Memo1.Text:=rsSysLineTypeWarning;
     end;
end;

procedure TLTWindow._CreateLT(Sender: TObject);
var
   pltp:PGDBLtypeProp;
   pdwg:PTSimpleDrawing;
   ltd:tstrings;
   CurrentLine:integer;
   LTName,LTDesk,LTImpl:GDBString;
begin
     pdwg:=gdb.GetCurrentDWG;
     CurrentLine:=1;
     ltd:=tstringlist.Create;
     ltd.Text:=self.Memo1.Text;
     pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
     LTName:=strproc.Tria_Utf8ToAnsi(LTName);
     LTDesk:=strproc.Tria_Utf8ToAnsi(LTDesk);
     LTImpl:=strproc.Tria_Utf8ToAnsi(LTImpl);

     if (pdwg^.GetLTypeTable.AddItem(LTName,pltp)<>IsCreated) then
                        begin
                             shared.ShowError('Line type name already exist!!!');
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

procedure TLTWindow._LoadLT(Sender: TObject);
begin
     LineWeightSelectWindow:=TLineWeightSelectWindow.Create(nil);
     //SetHeightControl(LineWeightSelectWindow,22);
     if LineWeightSelectWindow.run(FindInSupportPath(SupportPath,'zcad.lin'))=mrok then
        Memo1.Text:=LineWeightSelectWindow.text;
     Freeandnil(LineWeightSelectWindow);
end;

procedure TLTWindow.MkCurrentBtnClick(Sender: TObject);
begin

end;


procedure TLTWindow._close(Sender: TObject; var CloseAction: TCloseAction);
begin
     if self.ModalResult=MrOk then
                                  begin
                                       sysvar.DWG.DWG_LTScale^:=GScale.Value;
                                       sysvar.DWG.DWG_CLTScale^:=CScale.Value;
                                       sysvar.DWG.DWG_RotateTextInLT^:=CheckBox1.Checked;
                                  end;
end;

end.
