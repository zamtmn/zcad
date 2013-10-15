unit ltwnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, Buttons, ExtCtrls, ComCtrls, Spin,

  zcadsysvars, ugdbsimpledrawing, gdbase, gdbasetypes,ugdbltypearray,UGDBDescriptor,imagesmanager,strproc,usupportgui,ugdbutil,zcadstrconsts;

type

  { TLTWindow }

  TLTWindow = class(TForm)
    B1: TSpeedButton;
    B2: TSpeedButton;
    Bevel1: TBevel;
    ButtonPanel1: TButtonPanel;
    GroupBox1: TGroupBox;
    GScale: TFloatSpinEdit;
    CScale: TFloatSpinEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    MkCurrentBtn: TSpeedButton;
    procedure _LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure _LTChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure _onCDSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure _onCreate(Sender: TObject);
    procedure UpdateItem(Item: TListItem);
    procedure countlt(plt:PGDBLtypeProp;out e,b:GDBInteger);
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
procedure TLTWindow._onCreate(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
   //s:ansistring;
   li:TListItem;
begin
     GScale.Value:=sysvar.DWG.DWG_LTScale^;
     CScale.Value:=sysvar.DWG.DWG_CLTScale^;

     ListView1.BeginUpdate;
     ListView1.SmallImages:=IconList;
     ListView1.Clear;
     //ListView1.OnMouseUp:=@LWMouseUp;
     //ListView1.OnMouseDown:=@LWMouseDown;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            li:=ListView1.Items.Add;

            li.Data:=pltp;

            UpdateItem(li);

            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;
     //ListView1.SortColumn:=1;
     //ListView1.SetFocus;
     ListView1.EndUpdate;
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
procedure TLTWindow._LTSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
var
   pltp:PGDBLtypeProp;
   pdwg:PTSimpleDrawing;
   layername:string;
   counter:integer;
   li:TListItem;
   inent,inblock:integer;
begin
     if selected then
     begin
          pdwg:=gdb.GetCurrentDWG;
          pltp:=(Item.Data);
          countlt(pltp,inent,inblock);
          Label2.Caption:=Format(rsLineTypeUsedIn,[pltp^.Name,inent,inblock]);
          Memo1.Text:=Format(rsLineTypeDesk,[pltp^.len,strproc.Tria_AnsiToUtf8(pltp^.getastext)]);//pltp^.getastext;
     end;
end;

end.

