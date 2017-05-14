unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  TypInfo,Themes, ExtCtrls, Spin,types, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabeledEdit1: TLabeledEdit;
    ListBox1: TListBox;
    ListBox2: TListBox;
    PaintBox1: TPaintBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    procedure PBpaint(Sender: TObject);
    procedure SelectSubItem(Sender: TObject; User: boolean);
    procedure _dtchange(Sender: TObject);
    procedure _onCreate(Sender: TObject);
    procedure _SelectMainItem(Sender: TObject; User: boolean);
    procedure FillListBox(LBox: TListBox; pti: PTypeInfo);
  private
    DetailName: string;
    pti: PTypeInfo;
    td:TThemedElementDetails;
    dsize:TSize;
    selected:boolean;
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.FillListBox(LBox: TListBox; pti: PTypeInfo);
var
  aname: string;
  i: integer;
begin
  LBox.Clear;
  for i:=0 to GetEnumNameCount(pti)-1 do
  begin
       aname := GetEnumName(pti, i);
       LBox.AddItem(aname,tobject(pointer(i)));
  end;
end;

procedure TForm1._onCreate(Sender: TObject);
begin
  selected:=false;
  FillListBox(ListBox1,TypeInfo(TThemedElement));
end;

function GetTI(TypeName:string): PTypeInfo;
begin
     case TypeName of
        'teButton':result:=TypeInfo(TThemedButton);
        'teClock':result:=TypeInfo(TThemedClock);
        'teComboBox':result:=TypeInfo(TThemedComboBox);
        'teEdit':result:=TypeInfo(TThemedEdit);
        'teExplorerBar':result:=TypeInfo(TThemedExplorerBar);
        'teHeader':result:=TypeInfo(TThemedHeader);
        'teListView':result:=TypeInfo(TThemedListView);
        'teMenu':result:=TypeInfo(TThemedMenu);
        'tePage':result:=TypeInfo(TThemedPage);
        'teProgress':result:=TypeInfo(TThemedProgress);
        'teRebar':result:=TypeInfo(TThemedRebar);
        'teScrollBar':result:=TypeInfo(TThemedScrollBar);
        'teSpin':result:=TypeInfo(TThemedSpin);
        'teStartPanel':result:=TypeInfo(TThemedStartPanel);
        'teStatus':result:=TypeInfo(TThemedStatus);
        'teTab':result:=TypeInfo(TThemedTab);
        'teTaskBand':result:=TypeInfo(TThemedTaskBand);
        'teTaskBar':result:=TypeInfo(TThemedTaskBar);
        'teToolBar':result:=TypeInfo(TThemedToolBar);
        'teToolTip':result:=TypeInfo(TThemedToolTip);
        'teTrackBar':result:=TypeInfo(TThemedTrackBar);
        'teTrayNotify':result:=TypeInfo(TThemedTrayNotify);
        'teTreeview':result:=TypeInfo(TThemedTreeview);
        'teWindow':result:=TypeInfo(TThemedWindow);
     end;
end;
function GetTDetail(TypeName:string;Element:integer):TThemedElementDetails;
begin
     case TypeName of
        'teButton':result:=ThemeServices.GetElementDetails(TThemedButton(Element));
        'teClock':result:=ThemeServices.GetElementDetails(TThemedClock(Element));
        'teComboBox':result:=ThemeServices.GetElementDetails(TThemedComboBox(Element));
        'teEdit':result:=ThemeServices.GetElementDetails(TThemedEdit(Element));
        'teExplorerBar':result:=ThemeServices.GetElementDetails(TThemedExplorerBar(Element));
        'teHeader':result:=ThemeServices.GetElementDetails(TThemedHeader(Element));
        'teListView':result:=ThemeServices.GetElementDetails(TThemedListView(Element));
        'teMenu':result:=ThemeServices.GetElementDetails(TThemedMenu(Element));
        'tePage':result:=ThemeServices.GetElementDetails(TThemedPage(Element));
        'teProgress':result:=ThemeServices.GetElementDetails(TThemedProgress(Element));
        'teRebar':result:=ThemeServices.GetElementDetails(TThemedRebar(Element));
        'teScrollBar':result:=ThemeServices.GetElementDetails(TThemedScrollBar(Element));
        'teSpin':result:=ThemeServices.GetElementDetails(TThemedSpin(Element));
        'teStartPanel':result:=ThemeServices.GetElementDetails(TThemedStartPanel(Element));
        'teStatus':result:=ThemeServices.GetElementDetails(TThemedStatus(Element));
        'teTab':result:=ThemeServices.GetElementDetails(TThemedTab(Element));
        'teTaskBand':result:=ThemeServices.GetElementDetails(TThemedTaskBand(Element));
        'teTaskBar':result:=ThemeServices.GetElementDetails(TThemedTaskBar(Element));
        'teToolBar':result:=ThemeServices.GetElementDetails(TThemedToolBar(Element));
        'teToolTip':result:=ThemeServices.GetElementDetails(TThemedToolTip(Element));
        'teTrackBar':result:=ThemeServices.GetElementDetails(TThemedTrackBar(Element));
        'teTrayNotify':result:=ThemeServices.GetElementDetails(TThemedTrayNotify(Element));
        'teTreeview':result:=ThemeServices.GetElementDetails(TThemedTreeview(Element));
        'teWindow':result:=ThemeServices.GetElementDetails(TThemedWindow(Element));
     end;
end;
procedure TForm1._SelectMainItem(Sender: TObject; User: boolean);
var
  i: integer;
begin
     DetailName:=GetEnumName(TypeInfo(TThemedElement),ListBox1.ItemIndex);
     pti:=GetTI(DetailName);
     FillListBox(ListBox2,pti);
end;
procedure TForm1.SelectSubItem(Sender: TObject; User: boolean);
begin
    td:=GetTDetail(DetailName,ListBox2.ItemIndex);
    dsize:=ThemeServices.GetDetailSize(td);
    LabeledEdit1.Caption:='cx='+inttostr(dsize.cx)+'; cy='+inttostr(dsize.cy);
    selected:=true;
    self.PaintBox1.Invalidate;
end;

procedure TForm1._dtchange(Sender: TObject);
begin
     self.PaintBox1.Invalidate;
end;

procedure TForm1.PBpaint(Sender: TObject);
var
   ARect:TRect;
   dt:boolean;
   tc:tcolor;
begin
     if CheckBox2.Checked then
     begin
          tc:=PaintBox1.Canvas.Brush.Color;
          PaintBox1.Canvas.Brush.Color:=clWhite;
          PaintBox1.Canvas.FillRect(PaintBox1.BoundsRect);
          PaintBox1.Canvas.Brush.Color:=tc;
     end;
     if selected then
     begin
          dt:=CheckBox1.State=cbChecked;
          ARect:=rect(10,10,10+dsize.cx,10+dsize.cy);
          ThemeServices.DrawElement(PaintBox1.Canvas.Handle,td, ARect);
          if dt then
          ThemeServices.DrawText(PaintBox1.Canvas.Handle,td,'preferred',ARect,DT_CENTER or DT_VCENTER,0);
          ARect:=rect(100,10,100+16,10+16);
          ThemeServices.DrawElement(PaintBox1.Canvas.Handle,td, ARect);
          if dt then
          ThemeServices.DrawText(PaintBox1.Canvas.Handle,td,'16x16',ARect,DT_CENTER or DT_VCENTER,0);
          ARect:=rect(200,10,200+32,10+32);
          ThemeServices.DrawElement(PaintBox1.Canvas.Handle,td, ARect);
          if dt then
          ThemeServices.DrawText(PaintBox1.Canvas.Handle,td,'32x32',ARect,DT_CENTER or DT_VCENTER,0);
          ARect:=rect(300,10,300+64,10+64);
          ThemeServices.DrawElement(PaintBox1.Canvas.Handle,td, ARect);
          if dt then
          ThemeServices.DrawText(PaintBox1.Canvas.Handle,td,'64x64',ARect,DT_CENTER or DT_VCENTER,0);

          ARect:=rect(400,10,400+SpinEdit1.Value,10+SpinEdit2.Value);
          ThemeServices.DrawElement(PaintBox1.Canvas.Handle,td, ARect);
          if dt then
          ThemeServices.DrawText(PaintBox1.Canvas.Handle,td,inttostr(SpinEdit1.Value)+'x'+inttostr(SpinEdit2.Value),ARect,DT_CENTER or DT_VCENTER,0);

     end;
end;


end.
