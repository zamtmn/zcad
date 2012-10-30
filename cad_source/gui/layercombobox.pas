{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Dimitriy P.S.)
}
unit layercombobox;

{$mode objfpc}{$H+}

interface

uses
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms;

type
  TLayerPropRecord=record                                                // Запись cписка (данные в памяти)
    OnOff:boolean;       // Включение/выключение слоя
    Freze:boolean;       // Заморозка слоя
    Lock:boolean;        // Блокировка слоя
    Name:string;         // Имя слоя
    PLayer:pointer;
  end;

  //TLayerAction=(TLAGet,TLASet);
  TLayerArray=array of TLayerPropRecord;
  TGetLayerPropFunc=function(PLayer:Pointer;var lp:TLayerPropRecord):boolean of object;
  TGetLayersArrayFunc=function(var la:TLayerArray):boolean of object;
  TClickOnLayerPropFunc=function(PLayer:Pointer;NumProp:integer;var newlp:TLayerPropRecord):boolean of object;

  TControlPole=class(TGraphicControl)                                         // Для вывода выьранного пункта меню
  private
    sBorderColor:TColor;
    sBorderVisible:boolean;
    sBackgroundColor:TColor;
    procedure SetBorderColor(const AValue:TColor);
    procedure SetBorderVisible(const AValue:boolean);
    procedure SetBackgroundColor(const AValue:TColor);
  protected
    procedure Paint;override;
  public
    IL:TImageList;
    Index:integer;
    AktivItem:TLayerPropRecord;
    constructor Create(AOwner:TComponent);override;
  published
    property Align;
    property Anchors;
    property Height;
    property Width;
    property Constraints;
    property BorderColor:TColor read sBorderColor write SetBorderColor;
    property BorderVisible:boolean read sBorderVisible write SetBorderVisible;
    property BackgroundColor:TColor read sBackgroundColor write SetBackgroundColor;
  end;

  TZCADLayerComboBox=class({TWinControl}TCustomPanel)                                        // Компонент TZCADLayerComboBox
  private
    MyItems:TLayerArray;
    M1:boolean; // Маркер
    CP1:TControlPole;
    B1:TBitBtn;
    PoleLista:TForm;
    LV:TListView;
    IL:TImageList;
    sOnChange:TNotifyEvent;
    sListHeight:integer;
    sItemIndex:integer;
    sGlyph_OnOff_ON:TBitmap;
    sGlyph_OnOff_OFF:TBitmap;
    sGlyph_Freze_ON:TBitmap;
    sGlyph_Freze_OFF:TBitmap;
    sGlyph_Lock_ON:TBitmap;
    sGlyph_Lock_OFF:TBitmap;
    procedure SetItemIndex(AValue:integer);
    procedure SetListHeight(AValue:integer);
    function ReadItemsCount:integer;
    function ReadHeight:integer;
    function ReadWidth:integer;
    procedure SetHeight(AValue:integer);
    procedure SetWidth(AValue:integer);
    function ReadFont:TFont;
    procedure SetFont(AValue:TFont);
    function ReadItem(iIndex:integer):TLayerPropRecord;
    procedure B1Klac(Sender:TObject);
    procedure PLDeActivate(Sender:TObject);
    procedure PLDeActivate2(Data:PtrInt);
    procedure PLDeActivate3(Data:PtrInt);
    procedure LVKlac(Sender:TObject);
    procedure KeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);
    procedure ObnovitSpisok;
    function GetOnChange:TNotifyEvent;
    procedure SetOnChange(AValue:TNotifyEvent);
    procedure ListChanged;
  protected
  public
    fGetLayerProp:TGetLayerPropFunc;
    fGetLayersArray:TGetLayersArrayFunc;
    fClickOnLayerProp:TClickOnLayerPropFunc;
    constructor Create(AOwner:TComponent);override;
    procedure UpdateIcon;
    procedure ItemsClear;
    procedure AddItem(OnOff,Freze,Lock:boolean;ItemName:utf8string;lo:pointer);
    procedure DelItem(ItemIndex:integer);
    destructor Destroy;override;
    procedure CompareEvent(Sender: TObject; Item1, Item2: TListItem;
                               Data: Integer; var Compare: Integer);
    property ItemIndex:integer read sItemIndex write SetItemIndex;
    property ItemsCount:integer read ReadItemsCount;
    property Item[iIndex:Integer]:TLayerPropRecord read ReadItem;
    //property GetLayerPropFunc:TGetLayerPropFunc stored fGetLayerProp;
  published
    property Align;
    property Anchors;
    property Constraints;
    property TabOrder;
    property TabStop;
    property Visible;
    property Enabled;
    property Hint;
    property ShowHint;
    property Height:integer read ReadHeight write SetHeight;
    property Width:integer read ReadWidth write SetWidth;
    property Font:TFont read ReadFont write SetFont;
    property ListHeight:integer read sListHeight write SetListHeight;
    property Glyph_OnOff_ON:TBitmap read sGlyph_OnOff_ON write sGlyph_OnOff_ON;
    property Glyph_OnOff_OFF:TBitmap read sGlyph_OnOff_OFF write sGlyph_OnOff_OFF;
    property Glyph_Freze_ON:TBitmap read sGlyph_Freze_ON write sGlyph_Freze_ON;
    property Glyph_Freze_OFF:TBitmap read sGlyph_Freze_OFF write sGlyph_Freze_OFF;
    property Glyph_Lock_ON:TBitmap read sGlyph_Lock_ON write sGlyph_Lock_ON;
    property Glyph_Lock_OFF:TBitmap read sGlyph_Lock_OFF write sGlyph_Lock_OFF;
    property OnChange:TNotifyEvent read GetOnChange write SetOnChange;
  end;

procedure Register;

implementation

uses
  StdCtrls,GraphType,Themes,types;

//============================================================================//

constructor TControlPole.Create(AOwner:TComponent);                           // Создание объекта класса
begin
  inherited Create(AOwner);
  sBorderColor:=$00969696;
  sBorderVisible:=true;
  sBackgroundColor:=$00FFFFFF;
  Width:=16;
  Height:=16;
end;

procedure TControlPole.Paint;                                                 // Отрисовка
  var
    w,h:integer;
    lp:TLayerPropRecord;
begin
  if Visible=true then
  begin
    h:=Height;
    w:=Width;
    with Canvas do
    begin
      Lock;
      Pen.Color:=sBackgroundColor;
      Brush.Color:=sBackgroundColor;
      Rectangle(0,0,w,h);
      Pen.Color:=sBorderColor;
      Brush.Style:=bsClear;
      if {Index=-1}not TZCADLayerComboBox(parent).fGetLayerProp(nil,lp) then
      begin
        //IL.Draw(Canvas,1,(h-16) div 2,1,gdeNormal);
        //IL.Draw(Canvas,18,(h-16) div 2,2,gdeNormal);
        //IL.Draw(Canvas,35,(h-16) div 2,4,gdeNormal);
        TextOut(56,(h div 2)-(TextHeight(lp.Name) div 2),lp.Name);
      end
      else
      begin
        if lp.OnOff=false then IL.Draw(Canvas,1,(h-16) div 2,1,gdeNormal) else IL.Draw(Canvas,1,(h-16) div 2,0,gdeNormal);
        if lp.Freze=false then IL.Draw(Canvas,18,(h-16) div 2,3,gdeNormal) else IL.Draw(Canvas,18,(h-16) div 2,2,gdeNormal);
        if lp.Lock=false then IL.Draw(Canvas,35,(h-16) div 2,5,gdeNormal) else IL.Draw(Canvas,35,(h-16) div 2,4,gdeNormal);
        TextOut(56,(h div 2)-(TextHeight(lp.Name) div 2),lp.Name);
      end;
      if sBorderVisible=true then
      begin
        {Line (0,0,0,h-1);
        Line (0,0,w-1,0);
        Line (w-1,0,w-1,h-1);
        Line (0,h-1,w-1,h-1);}
      end;
      Unlock;
    end;
  end;
  inherited Paint;
end;

procedure TControlPole.SetBorderColor(const AValue:TColor);                   // Изменить свойство цвета контура
begin
  if AValue=sBorderColor then exit;
  sBorderColor:=AValue;
  Invalidate;
end;

procedure TControlPole.SetBackgroundColor(const AValue:TColor);               // Изменить свойство цвета заливки
begin
  if AValue=sBackgroundColor then exit;
  sBackgroundColor:=AValue;
  Invalidate;
end;

procedure TControlPole.SetBorderVisible(const AValue:boolean);                // Изменить свойство отображения контура
begin
  if AValue=sBorderVisible then exit;
  sBorderVisible:=AValue;
  Invalidate;
end;

//============================================================================//
procedure TZCADLayerComboBox.CompareEvent(Sender: TObject; Item1, Item2: TListItem;
                           Data: Integer; var Compare: Integer);
begin
     if Item1.SubItems[2]>Item2.SubItems[2] then
                                                compare:=1
else if Item1.SubItems[2]=Item2.SubItems[2] then
                                                compare:=0
                                            else
                                                compare:=-1;

end;

constructor TZCADLayerComboBox.Create(AOwner:TComponent);                      // Создание объекта класса
  var
    BM:TBitmap;
    n:integer;
    Details:TThemedElementDetails;
    Size:TSize;
begin
  inherited Create(AOwner);
  BorderWidth:=0;
  {self.BevelOuter:=bvLowered;
  self.BevelWidth:=2;}
  //BorderStyle:=bsnone;
  M1:=false;
  SetLength(MyItems,0);
  BM:=TBitMap.Create;
  BM.Width:=16;
  BM.Height:=16;
  BM.Canvas.Pen.Style:=psSolid;
  BM.Canvas.Brush.Style:=bsSolid;
  BM.Canvas.Pen.Color:=$ffffff;
  BM.Canvas.Brush.Color:=$ffffff;
  BM.Canvas.Rectangle(0,0,17,17);


  //IL:=mainformn.IconList;

  IL:=TImageList.Create(self);
  IL.Width:=16;
  IL.Height:=16;
  for n:=0 to 5 do
  begin
    IL.Add(BM,nil);
  end;
  sGlyph_OnOff_ON:=TBitmap.Create;
  sGlyph_OnOff_OFF:=TBitmap.Create;
  sGlyph_Freze_ON:=TBitmap.Create;
  sGlyph_Freze_OFF:=TBitmap.Create;
  sGlyph_Lock_ON:=TBitmap.Create;
  sGlyph_Lock_OFF:=TBitmap.Create;
  sListHeight:=-1;
  sItemIndex:=-1;
  B1:=TBitBtn.Create(self);
  B1.Parent:=self;
  {B1.Anchors:=[akTop,akRight,akBottom];
  B1.AnchorSideTop.Control:=Self;
  B1.AnchorSideRight.Control:=Self;
  B1.AnchorSideRight.Side:=asrBottom;
  B1.AnchorSideBottom.Control:=Self;
  B1.AnchorSideBottom.Side:=asrBottom;
  B1.BorderSpacing.Top:=0;
  B1.BorderSpacing.Right:=0;
  B1.BorderSpacing.Bottom:=0;}
  B1.Align:=alRight;
  B1.Width:=26;
  CP1:=TControlPole.Create(self);
  CP1.Parent:=self;
  CP1.Align:=alClient;
  //CP1.BorderSpacing.Right:=26;
  CP1.IL:=IL;
  CP1.Index:=-1;
  CP1.OnClick:=@B1Klac;
  //inherited Width:=120;
  //inherited Height:=100;
  //self.AutoSize:=true;
  Details:=ThemeServices.GetElementDetails({ttGlyphClosed}tcDropDownButtonNormal);
  Size:=ThemeServices.GetDetailSize(Details);
  BM.Width:=Size.cx;
  BM.Height:=Size.cy;
  ThemeServices.DrawElement(BM.Canvas.Handle,Details,Rect(0,0,Size.cx,Size.cy),nil);
  B1.Glyph.Assign(BM);
  BM.Free;
  B1.OnClick:=@B1Klac;
  B1.Visible:=true;
  Application.OnDeactivate:=@PLDeActivate;
end;

procedure TZCADLayerComboBox.ItemsClear;                                       // Очистить список
  var
    n:integer;
begin
  for n:=0 to length(MyItems)-1 do
  begin
    MyItems[n].Name:='';
  end;
  SetLength(MyItems,0);
  SetItemIndex(-1);
  ObnovitSpisok;
  //ListChanged;
end;

procedure TZCADLayerComboBox.AddItem(OnOff,Freze,Lock:boolean;ItemName:utf8string;lo:pointer); // Создание пункта в списке
begin
  SetLength(MyItems,length(MyItems)+1);
  MyItems[High(MyItems)].Name:=ItemName;
  MyItems[High(MyItems)].OnOff:=OnOff;
  MyItems[High(MyItems)].Freze:=Freze;
  MyItems[High(MyItems)].Lock:=Lock;
  MyItems[High(MyItems)].PLayer:=lo;
  ObnovitSpisok;
  //ListChanged;
end;

procedure TZCADLayerComboBox.DelItem(ItemIndex:integer);                       // Удаление пункта из списка
  var
    ServisMassiv:array of TLayerPropRecord;
    n:integer;
begin
  SetLength(ServisMassiv,0);
  for n:=0 to Length(MyItems)-1 do
  begin
    if n<>ItemIndex then
    begin
      SetLength(ServisMassiv,Length(ServisMassiv)+1);
      ServisMassiv[High(ServisMassiv)]:=MyItems[n];
    end
    else MyItems[n].Name:='';
  end;
  SetLength(MyItems,0);
  MyItems:=Copy(ServisMassiv,0,Length(ServisMassiv));
  SetLength(ServisMassiv,0);
  SetItemIndex(sItemIndex);
  ObnovitSpisok;
  //ListChanged;
end;

procedure TZCADLayerComboBox.SetItemIndex(AValue:integer);                     // Задаёт значение выбранного элемента списка
begin
  if sItemIndex=AValue then exit;
  if (AValue>=0) and (AValue<length(MyItems)) then
  begin
    sItemIndex:=AValue;
    CP1.Index:=AValue;
    CP1.AktivItem:=MyItems[AValue];
  end
  else
  begin
    sItemIndex:=-1;
    CP1.Index:=-1;
  end;
  CP1.Invalidate;
  //ListChanged;
end;

procedure TZCADLayerComboBox.SetListHeight(AValue:integer);                    // Изменение свойства высоты разворачиваемого списка
begin
  sListHeight:=AValue;
  if sListHeight<30 then sListHeight:=30;
end;

function TZCADLayerComboBox.ReadItemsCount:integer;                            // Возвращает длину списка
begin
  result:=length(MyItems);
end;

function TZCADLayerComboBox.ReadHeight:integer;                                // Возвращает значение параметра высоты
begin
  result:=inherited Height;
end;

function TZCADLayerComboBox.ReadWidth:integer;                                 // Возвращает значение параметра ширины
begin
  result:=inherited Width;
end;

procedure TZCADLayerComboBox.SetHeight(AValue:integer);                        // Задаёт значение параметра высоты
begin
  {if AValue<18 then AValue:=18;}
  inherited Height:=AValue;
  CP1.Invalidate;
end;

procedure TZCADLayerComboBox.SetWidth(AValue:integer);                         // Задаёт значение параметра ширины
begin
  {if AValue<120 then AValue:=120;}
  inherited Width:=AValue;
  CP1.Invalidate;
end;

function TZCADLayerComboBox.ReadFont:TFont;                                    // Возвращает параметр шрифта
begin
  result:=CP1.Font;
end;

procedure TZCADLayerComboBox.SetFont(AValue:TFont);                            // Задаёт значение параметра шрифта
begin
  CP1.Font:=AValue;
  CP1.Invalidate;
end;

function TZCADLayerComboBox.ReadItem(iIndex:integer):TLayerPropRecord;    // Возвращает пункт списка по индексу
begin
  result:=MyItems[iIndex];
end;

procedure TZCADLayerComboBox.UpdateIcon;                                       // Обновляет значки
begin
  IL.Replace(0,sGlyph_OnOff_ON,nil);
  IL.Replace(1,sGlyph_OnOff_OFF,nil);
  IL.Replace(2,sGlyph_Freze_ON,nil);
  IL.Replace(3,sGlyph_Freze_OFF,nil);
  IL.Replace(4,sGlyph_Lock_ON,nil);
  IL.Replace(5,sGlyph_Lock_OFF,nil);
  CP1.Invalidate;
end;

procedure TZCADLayerComboBox.B1Klac(Sender:TObject);                           // Открытие развёрнутого списка
  var
    a:TPoint;
    h,hh:integer;
begin
  if (PoleLista=nil) and (M1=false) then
  begin
    PoleLista:=TForm.Create(nil);
    PoleLista.Width:=Width;
    //PoleLista.Show;
    //exit;
    a.X:=0;
    a.Y:=B1.Parent.Height;
    a:=ClientToScreen(a);
    PoleLista.Left:={B1.Parent.ClientToScreen(a).X}a.x;
    PoleLista.Top:={B1.Parent.ClientToScreen(a).Y}a.y;
    PoleLista.BorderStyle:=bsNone;
    PoleLista.OnDeactivate:=@PLDeActivate;
    UpdateIcon;
    LV:=TListView.Create(PoleLista);
    LV.BorderStyle:=bsSingle;
    LV.Parent:=PoleLista;
    LV.Font:=CP1.Font;
    LV.Align:=alClient;
    LV.ReadOnly:=true;
    LV.MultiSelect:=false;
    LV.SmallImages:=IL;
    LV.RowSelect:=true;
    LV.ViewStyle:=vsReport;
    LV.ShowColumnHeaders:=false;
    LV.ScrollBars:=ssAutoVertical;
    LV.Columns.Add;
    LV.Columns.Items[0].Width:=18;
    LV.Columns.Add;
    LV.Columns.Items[1].Width:=18;
    LV.Columns.Add;
    LV.Columns.Items[2].Width:=18;
    LV.Columns.Add;
    LV.Columns.Items[3].Width:=PoleLista.Width-18*3-30;
    LV.OnClick:=@LVKlac;
    LV.OnKeyDown:=@KeyDown;
    LV.OnCompare:=@Compareevent;
    ObnovitSpisok;
    if sListHeight>0 then
                         PoleLista.Height:=sListHeight
                     else
                         begin
                              hh:=screen.WorkAreaHeight-a.y-1;
                              h:=LV.Items.Count*19+4;
                              if h>hh then h:=hh;
                              PoleLista.Height:=h;//{LV..Height*LV.Items.Count}1000;
                         end;

    PoleLista.Show;
  end;
  if (PoleLista=nil) and (M1=true) then M1:=false;
end;

procedure TZCADLayerComboBox.PLDeActivate(Sender:TObject);                     // Закрытие списка
  var
    S,P:TPoint;
begin
  if PoleLista<>nil then
  begin
    PoleLista.Free;
    PoleLista:=nil;
    S.X:=0;
    S.Y:=0;
    P:=B1.ScreenToClient(S);
    S:=Mouse.CursorPos;
    P.X:=P.X+S.X;
    P.Y:=P.Y+S.Y;
    if ((P.Y>0) and (P.Y<B1.Height))and((P.X>0) and (P.X<B1.Width)) then M1:=true;
    S.X:=0;
    S.Y:=0;
    P:=CP1.ScreenToClient(S);
    S:=Mouse.CursorPos;
    P.X:=P.X+S.X;
    P.Y:=P.Y+S.Y;
    if ((P.Y>0) and (P.Y<CP1.Height))and((P.X>0) and (P.X<CP1.Width)) then M1:=true;
  end;
  CP1.Invalidate;
end;

procedure TZCADLayerComboBox.PLDeActivate2(Data:PtrInt);                       // Закрытие списка 2
begin
  PLDeActivate(nil);
end;

procedure TZCADLayerComboBox.PLDeActivate3(Data:PtrInt);                       // Закрытие списка 3
begin
  if PoleLista<>nil then
  begin
    PoleLista.Free;
    PoleLista:=nil;
    M1:=false;
  end;
end;
procedure ObnovitItem(li:TListItem;lp:TLayerPropRecord);
begin
  li.SubItems[2]:=lp.Name;
  li.Data:=lp.PLayer;
  if lp.OnOff=true then li.ImageIndex:=0 else li.ImageIndex:=1;
  if lp.Freze=true then li.SubItemImages[0]:=2 else li.SubItemImages[0]:=3;
  if lp.Lock=true then li.SubItemImages[1]:=4 else li.SubItemImages[1]:=5;

end;

procedure TZCADLayerComboBox.ObnovitSpisok;                                    // Заполнение (обновление) списка развёрнутого листа
  var
    n:integer;
    LayerArray:TLayerArray;
begin
  if PoleLista<>nil then
  if assigned(fGetLayersArray)then
  if fGetLayersArray(LayerArray)then
  begin
    LV.BeginUpdate;
    LV.Items.Clear;
    for n:=low(LayerArray) to high(layerarray) do
    begin
      LV.Items.Add;
      LV.Items.Item[n].SubItems.Add('');
      LV.Items.Item[n].SubItems.Add('');
      LV.Items.Item[n].SubItems.Add(''{LayerArray[n].Name});
      ObnovitItem(LV.Items.Item[n],LayerArray[n]);
      {LV.Items.Item[n].Data:=LayerArray[n].PLayer;
      if LayerArray[n].OnOff=true then LV.Items.Item[n].ImageIndex:=0 else LV.Items.Item[n].ImageIndex:=1;
      if LayerArray[n].Freze=true then LV.Items.Item[n].SubItemImages[0]:=2 else LV.Items.Item[n].SubItemImages[0]:=3;
      if LayerArray[n].Lock=true then LV.Items.Item[n].SubItemImages[1]:=4 else LV.Items.Item[n].SubItemImages[1]:=5;}
    end;
    LV.SortType:=stBoth;
    LV.EndUpdate;
  end;
end;

procedure TZCADLayerComboBox.LVKlac(Sender:TObject);                           // Обработков кликов на развёрнутом списке
  var
    LVItem:TListItem;
    KlacPoint,KlacContrlPoint,S:TPoint;
    NumProp,colwidth,i:integer;
    collapsed:boolean;
    newlp:TLayerPropRecord;
begin
  if LV.Items.Count>0 then
  begin
    S.X:=0;
    S.Y:=0;
    KlacContrlPoint:=LV.ScreenToClient(S);
    S:=Mouse.CursorPos;
    KlacPoint.X:=S.X+KlacContrlPoint.X;
    KlacPoint.Y:=S.Y+KlacContrlPoint.Y;
    LVItem:=nil;
    LVItem:=LV.GetItemAt(KlacPoint.X,KlacPoint.Y);
    if LVItem<>nil then
    begin
      LV.BeginUpdate;
      numprop:=0;
      colwidth:=0;
      for i:=0 to lv.ColumnCount-1 do
      begin
           colwidth:=colwidth+lv.column[i].Width;
           if KlacPoint.x>colwidth then
                                        inc(numprop)
                                    else
                                        break;
      end;
      if assigned(fClickOnLayerProp)then
       collapsed:=fClickOnLayerProp(LVItem.Data,NumProp,newlp);
      {if KlacPoint.X<LV.Column[0].Width then // Изменение Вкл/Выкл слоя
      begin
        if MyItems[LVItem.Index].OnOff=true then
        begin
          MyItems[LVItem.Index].OnOff:=false;
          LVItem.ImageIndex:=1;
        end
        else
        begin
          MyItems[LVItem.Index].OnOff:=true;
          LVItem.ImageIndex:=0;
        end;
      end;
      if (KlacPoint.X>LV.Column[0].Width) and (KlacPoint.X<LV.Column[0].Width+LV.Column[1].Width) then // Изменение заморозки слоя
      begin
        if MyItems[LVItem.Index].Freze=true then
        begin
          MyItems[LVItem.Index].Freze:=false;
          LVItem.SubItemImages[0]:=3;
        end
        else
        begin
          MyItems[LVItem.Index].Freze:=true;
          LVItem.SubItemImages[0]:=2;
        end;
      end;
      if (KlacPoint.X>LV.Column[0].Width+LV.Column[1].Width) and (KlacPoint.X<LV.Column[0].Width+LV.Column[1].Width+LV.Column[2].Width) then // Изменение блокировки слоя
      begin
        if MyItems[LVItem.Index].Lock=true then
        begin
          MyItems[LVItem.Index].Lock:=false;
          LVItem.SubItemImages[1]:=5;
        end
        else
        begin
          MyItems[LVItem.Index].Lock:=true;
          LVItem.SubItemImages[1]:=4;
        end;
      end;
      if KlacPoint.X>LV.Column[0].Width+LV.Column[1].Width+LV.Column[2].Width then // Выбор пункта
      begin
        ItemIndex:=LVItem.Index;
        Application.QueueAsyncCall(@PLDeActivate2,0);
      end;}
      LVItem.Focused:=false;
      LVItem.Selected:=false;
      ObnovitItem(LVItem,newlp);
      LV.EndUpdate;
      if collapsed then
                       Application.QueueAsyncCall(@PLDeActivate2,0);
      //ListChanged;
    end;
  end;
end;

procedure TZCADLayerComboBox.KeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);// Отлавливаем эскей
begin
  if Key=27 then Application.QueueAsyncCall(@PLDeActivate3,0);
end;

function TZCADLayerComboBox.GetOnChange:TNotifyEvent;
begin
  Result:=sOnChange;
end;

procedure TZCADLayerComboBox.SetOnChange(AValue:TNotifyEvent);
begin
  sOnChange:=AValue;
end;

procedure TZCADLayerComboBox.ListChanged;
begin
  if Assigned(sOnChange) then sOnChange(Self);
end;

destructor TZCADLayerComboBox.Destroy;                                         // Уничтожение объекта класса
begin
  sGlyph_OnOff_ON.Free;
  sGlyph_OnOff_OFF.Free;
  sGlyph_Freze_ON.Free;
  sGlyph_Freze_OFF.Free;
  sGlyph_Lock_ON.Free;
  sGlyph_Lock_OFF.Free;
  inherited Destroy;
end;

//============================================================================//

procedure Register;
begin
  RegisterComponents('Misc',[TZCADLayerComboBox]);
end;

initialization

end.
