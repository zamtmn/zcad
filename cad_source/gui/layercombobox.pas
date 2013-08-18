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
@author(Dimitriy P.S. (Моего тут осталось 40 - 50 %))
}
unit layercombobox;

{$mode objfpc}{$H+}

interface

uses
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms,Themes;

type
  TLayerPropRecord=record                                                       // Запись cписка (данные в памяти)
    OnOff:boolean;       // Включение/выключение слоя
    Freze:boolean;       // Заморозка слоя
    Lock:boolean;        // Блокировка слоя
    Name:string;         // Имя слоя
    PLayer:pointer;
  end;

  TLayerArray=array of TLayerPropRecord;
  TGetLayerPropFunc=function(PLayer:Pointer;var lp:TLayerPropRecord):boolean of object;
  TGetLayersArrayFunc=function(var la:TLayerArray):boolean of object;
  TClickOnLayerPropFunc=function(PLayer:Pointer;NumProp:integer;var newlp:TLayerPropRecord):boolean of object;

  TMyListView=class(TListView)
  public
    property DefaultItemHeight;
  end;

  TZCADLayerComboBox=class(TCustomControl)                          // Компонент TZCADLayerComboBox
  private
    Index:integer;
    AktivItem:TLayerPropRecord;
    M1:boolean; // Маркер
    PoleLista:TForm;
    sLV:TMyListView;
    sIL:TImageList;
    sListHeight:integer;
    sSostoyanie:integer;
    sIndex_OnOff_ON:Integer;
    sIndex_OnOff_OFF:Integer;
    sIndex_Freze_ON:Integer;
    sIndex_Freze_OFF:Integer;
    sIndex_Lock_ON:Integer;
    sIndex_Lock_OFF:Integer;
    FNotClose:boolean;
    procedure SetListHeight(AValue:integer);
    function ReadHeight:integer;
    function ReadWidth:integer;
    procedure SetHeight(AValue:integer);
    procedure SetWidth(AValue:integer);
    procedure B1Klac(Sender:TObject);
    procedure PLDeActivate(Sender:TObject);
    procedure asyncfree(Data: PtrInt);
    procedure PLDeActivate2(Data:PtrInt);
    procedure PLDeActivate3(Data:PtrInt);
    procedure LVKlac(Sender:TObject);
    procedure KeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);
    procedure ObnovitSpisok;
  protected
    procedure Paint;override;
  public
    fGetLayerProp:TGetLayerPropFunc;
    fGetLayersArray:TGetLayersArrayFunc;
    fClickOnLayerProp:TClickOnLayerPropFunc;
    constructor Create(AOwner:TComponent);override;
    procedure ObnovitItem(li:TListItem;lp:TLayerPropRecord);
    procedure CompareEvent(Sender: TObject; Item1, Item2: TListItem;Data: Integer; var Compare: Integer);
    procedure MouseEnter;override;
    procedure MouseLeave;override;
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);override;
    procedure MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);override;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property TabOrder;
    property TabStop;
    property Visible;
    property Enabled;
    property Hint;
    property ShowHint;
    property Height:integer read ReadHeight write SetHeight;
    property Width:integer read ReadWidth write SetWidth;
    property ListHeight:integer read sListHeight write SetListHeight;
    property ImageList:TImageList read sIL write sIL;
    property Index_OnOff_ON:integer read sIndex_OnOff_ON write sIndex_OnOff_ON;
    property Index_OnOff_OFF:integer read sIndex_OnOff_OFF write sIndex_OnOff_OFF;
    property Index_Freze_ON:integer read sIndex_Freze_ON write sIndex_Freze_ON;
    property Index_Freze_OFF:integer read sIndex_Freze_OFF write sIndex_Freze_OFF;
    property Index_Lock_ON:integer read sIndex_Lock_ON write sIndex_Lock_ON;
    property Index_Lock_OFF:integer read sIndex_Lock_OFF write sIndex_Lock_OFF;
  end;

implementation

uses
  StdCtrls,GraphType,types;

procedure DrawComboBoxButton(ACanvas:TCanvas;ADown,AMouseInControl,ADisabled:Boolean;const ARect:TRect);
var
  ComboElem: TThemedComboBox;
  Details: TThemedElementDetails;
begin
  //if ThemeServices.ThemesEnabled then
  begin
    if ADown then
      ComboElem := tcDropDownButtonPressed
    else if AMouseInControl then
      ComboElem := tcDropDownButtonHot
    else if ADisabled then
      ComboElem := tcDropDownButtonDisabled
    else
      ComboElem := tcDropDownButtonNormal;

   //ComboElem := tcDropDownButtonNormal;

    Details := ThemeServices.GetElementDetails(ComboElem);
    ThemeServices.DrawElement(ACanvas.Handle, Details, ARect);
  end
end;

procedure DrawComboBoxBox(ACanvas:TCanvas;ADown,AMouseInControl,ADisabled:Boolean;const ARect:TRect);
  var
    ComboElem: {$IFDEF LINUX}TThemedButton{$ELSE}TThemedEdit{$ENDIF};
    Details: TThemedElementDetails;
    i:integer;
begin
  if ThemeServices.ThemesEnabled then
  begin
    if AMouseInControl then ComboElem:={$IFDEF LINUX}tbPushButtonHot{$ELSE}teEditTextHot{$ENDIF} else
    begin
      if ADisabled then ComboElem:={$IFDEF LINUX}tbPushButtonDisabled{$ELSE}teEditTextReadOnly{$ENDIF} else ComboElem:={$IFDEF LINUX}tbPushButtonNormal{$ELSE}teEditTextNormal{$ENDIF};
    end;
    //ComboElem := {$IFDEF LINUX}tbPushButtonNormal{$ELSE}teEditTextNormal{$ENDIF};
    Details:=ThemeServices.GetElementDetails(ComboElem);
    ThemeServices.DrawElement(ACanvas.Handle,Details,ARect);
    DrawComboBoxButton(ACanvas,ADown,AMouseInControl,ADisabled,ARect);
  end
  else
  begin
    with ACanvas do
    begin
      // Основа
      Pen.Style:=psSolid;
      Pen.Color:=clWindow;
      for i:=1 to Height-2 do
      begin
        MoveTo(0,i);
        LineTo(Width-30,i);
      end;
      // Кнопка
      Pen.Color:=clForm;
      for i:=0 to Height-1 do
      begin
        MoveTo(Width-30,i);
        LineTo(Width-1,i);
      end;
      if AMouseInControl then Pen.Color:=clActiveBorder else Pen.Color:=clInactiveBorder;
      // Бордюр
      MoveTo(0,0);
      LineTo(Width-1,0);
      LineTo(Width-1,Height-1);
      LineTo(0,Height-1);
      LineTo(0,0);
      MoveTo(Width-29,0);
      LineTo(Width-29,Height-1);
    end;
  end;
  (*
  {$IFDEF LINUX}
  with ACanvas do
  begin
    Pen.Style:=psSolid;
    if AMouseInControl then Pen.Color:=clGrayText else Pen.Color:=clWindowText;
    n:=12;
    for i:=(Height-12) div 2 to (Height-12) div 2+12 do
    begin
      MoveTo(Width-15-(n div 2),i);
      LineTo(Width-15+(n div 2),i);
      n:=n-1;
    end;
  end;
  {$ELSE}
  DrawComboBoxButton(ACanvas,ADown,AMouseInControl,ADisabled,ARect);
  {$ENDIF}
  *)
end;

//============================================================================//

constructor TZCADLayerComboBox.Create(AOwner:TComponent);                       // Создание объекта класса
  var
    n:integer;
    Details:TThemedElementDetails;
    Size:TSize;
begin
  inherited Create(AOwner);
  M1:=false;
  sIL:=nil; // На всякий случай
  sIndex_OnOff_ON:=-1;
  sIndex_OnOff_OFF:=-1;
  sIndex_Freze_ON:=-1;
  sIndex_Freze_OFF:=-1;
  sIndex_Lock_ON:=-1;
  sIndex_Lock_OFF:=-1;
  sListHeight:=-1;
  Index:=-1;
  sSostoyanie:=1;
  FNotClose:=false;
  autosize:=true;
  OnClick:=@B1Klac;
  Application.OnDeactivate:=@PLDeActivate;
end;

procedure TZCADLayerComboBox.Paint;                                             // Отрисовка
  var
    i:integer;
    lp:TLayerPropRecord;
    TxRect:TRect;
    MD,MIC:boolean;
begin
  inherited Paint;
  if Visible=true then
  begin
    with Canvas do
    begin
      Lock;
      if sSostoyanie<3 then MD:=false else MD:=true;
      if sSostoyanie<2 then MIC:=false else MIC:=true;
      DrawComboBoxBox(Canvas,MD,MIC,not Enabled,Bounds(0,0,clientwidth,clientheight));
      Brush.Style:=bsClear;
      if fGetLayerProp(nil,lp) then
      begin
        // Отрисовываем иконки состояния выбранного слоя и надпись (имя выбранного слоя)
        if sIL<>nil then
        begin
          if (sIndex_OnOff_OFF>=0) and (sIndex_OnOff_ON>=0) and (sIndex_OnOff_OFF<sIL.Count) and (sIndex_OnOff_ON<sIL.Count) then
          begin
            if lp.OnOff=false then sIL.Draw(Canvas,1,(Height-16) div 2,sIndex_OnOff_OFF,gdeNormal) else sIL.Draw(Canvas,1,(Height-16) div 2,sIndex_OnOff_ON,gdeNormal);
          end;
          if (sIndex_Freze_OFF>=0) and (sIndex_Freze_ON>=0) and (sIndex_Freze_OFF<sIL.Count) and (sIndex_Freze_ON<sIL.Count) then
          begin
            if lp.Freze=false then sIL.Draw(Canvas,18,(Height-16) div 2,sIndex_Freze_OFF,gdeNormal) else sIL.Draw(Canvas,18,(Height-16) div 2,sIndex_Freze_ON,gdeNormal);
          end;
          if (sIndex_Lock_OFF>=0) and (sIndex_Lock_ON>=0) and (sIndex_Lock_OFF<sIL.Count) and (sIndex_Lock_ON<sIL.Count) then
          begin
            if lp.Lock=false then sIL.Draw(Canvas,35,(Height-16) div 2,sIndex_Lock_OFF,gdeNormal) else sIL.Draw(Canvas,35,(Height-16) div 2,sIndex_Lock_ON,gdeNormal);
          end;
        end;
        //TextOut(55,(Height-TextHeight(lp.Name)) div 2,lp.Name);  // Можно использовать эту строку заместо 2 последующих (но может TextRect заработает)
        TxRect:=Rect(55,2,31,2);
        TextRect(TxRect,55,(Height-TextHeight(lp.Name)) div 2,lp.Name);  // Видимо функция TextRect попросту не работает... может когданибудь заработает? (текст не ограничивается по рамке)
      end;
      Unlock;
    end;
  end;
end;

procedure TZCADLayerComboBox.CompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if Item1.SubItems[2]>Item2.SubItems[2] then compare:=1 else
  begin
    if Item1.SubItems[2]=Item2.SubItems[2] then compare:=0 else compare:=-1;
  end;
end;

procedure TZCADLayerComboBox.SetListHeight(AValue:integer);                     // Изменение свойства высоты разворачиваемого списка
begin
  sListHeight:=AValue;
  if sListHeight<30 then sListHeight:=30;
end;

function TZCADLayerComboBox.ReadHeight:integer;                                 // Возвращает значение параметра высоты
begin
  result:=inherited Height;
end;

function TZCADLayerComboBox.ReadWidth:integer;                                  // Возвращает значение параметра ширины
begin
  result:=inherited Width;
end;

procedure TZCADLayerComboBox.SetHeight(AValue:integer);                         // Задаёт значение параметра высоты
begin
  if AValue<18 then AValue:=18;
  inherited Height:=AValue;
  Invalidate;
end;

procedure TZCADLayerComboBox.SetWidth(AValue:integer);                          // Задаёт значение параметра ширины
begin
  if AValue<120 then AValue:=120;
  inherited Width:=AValue;
  Invalidate;
end;

procedure TZCADLayerComboBox.B1Klac(Sender:TObject);                            // Открытие развёрнутого списка
  var
    a:TPoint;
    h,hh:integer;
begin
  if (PoleLista=nil) and (M1=false) then
  begin
    PoleLista:=TForm.Create(self);
    PoleLista.Width:=Width;
    a.X:=0;
    a.Y:=Height;
    a:=ClientToScreen(a);
    PoleLista.Left:=a.x;
    PoleLista.Top:=a.y;
    PoleLista.BorderStyle:=bsNone;
    PoleLista.OnDeactivate:=@PLDeActivate;
    PoleLista.ShowInTaskBar:=stNever;
    sLV:=TmyListView.Create(PoleLista);
    sLV.BorderStyle:=bsSingle;
    sLV.Parent:=PoleLista;
    sLV.Align:=alClient;
    sLV.ReadOnly:=true;
    sLV.MultiSelect:=false;
    sLV.SmallImages:=sIL;
    sLV.RowSelect:=true;
    sLV.ViewStyle:=vsReport;
    sLV.ShowColumnHeaders:=false;
    sLV.SortColumn:=3;
    sLV.ScrollBars:=ssAutoVertical;
    sLV.Columns.Add;
    sLV.Columns.Items[0].Width:=18;
    sLV.Columns.Add;
    sLV.Columns.Items[1].Width:=18;
    sLV.Columns.Add;
    sLV.Columns.Items[2].Width:=18;
    sLV.Columns.Add;
    sLV.Columns.Items[3].Width:=PoleLista.Width-18*3-30;
    sLV.OnClick:=@LVKlac;
    sLV.OnKeyDown:=@KeyDown;
    sLV.OnCompare:=@Compareevent;
    ObnovitSpisok;
    if sListHeight>0 then
                         PoleLista.Height:=sListHeight
                     else
                         begin
                              sLV.DefaultItemHeight:=-1;
                              hh:=sLV.Height-sLV.ClientHeight;
                              hh:=screen.WorkAreaHeight-a.y-1;
                              {$IFDEF LINUX}h:=sLV.Items.Count*(sLV.DefaultItemHeight+1)+10;
                              {$ELSE}h:=sLV.Items.Count*(sLV.DefaultItemHeight-1)+4;{$ENDIF}
                              if h>hh then h:=hh;
                              PoleLista.ClientHeight:=h;
                         end;

    PoleLista.Show;
  end;
  if (PoleLista=nil) and (M1=true) then M1:=false;
end;

procedure TZCADLayerComboBox.asyncfree(Data:PtrInt);
begin
  Tobject(Data).Free;
end;

procedure TZCADLayerComboBox.PLDeActivate(Sender:TObject);                      // Закрытие списка
  var
    S,P:TPoint;
begin
  if FNotClose then exit;
  if PoleLista<>nil then
  begin
    Application.QueueAsyncCall(@asyncfree,PtrInt(PoleLista));
    PoleLista:=nil;
    S.X:=0;
    S.Y:=0;
    P:=ScreenToClient(S);
    S:=Mouse.CursorPos;
    P.X:=P.X+S.X;
    P.Y:=P.Y+S.Y;
    if ((P.Y>0) and (P.Y<Height))and((P.X>0) and (P.X<Width)) then M1:=true;
  end;
  Invalidate;
end;

procedure TZCADLayerComboBox.PLDeActivate2(Data:PtrInt);                        // Закрытие списка 2
begin
  PLDeActivate(nil);
end;

procedure TZCADLayerComboBox.PLDeActivate3(Data:PtrInt);                        // Закрытие списка 3
begin
  if PoleLista<>nil then
  begin
    PoleLista.Free;
    PoleLista:=nil;
    M1:=false;
  end;
end;

procedure TZCADLayerComboBox.ObnovitItem(li:TListItem;lp:TLayerPropRecord);
begin
  li.SubItems[2]:=lp.Name;
  li.Data:=lp.PLayer;
  if sIL<>nil then
  begin
    if lp.OnOff then li.ImageIndex:=sIndex_OnOff_OFF else li.ImageIndex:=sIndex_OnOff_ON;
    if lp.Freze then li.SubItemImages[0]:=sIndex_Freze_ON else li.SubItemImages[0]:=sIndex_Freze_OFF;
    if lp.Lock then li.SubItemImages[1]:=sIndex_Lock_ON else li.SubItemImages[1]:=sIndex_Lock_OFF;
  end;
end;

procedure TZCADLayerComboBox.ObnovitSpisok;                                     // Заполнение (обновление) списка развёрнутого листа
  var
    n:integer;
    LayerArray:TLayerArray;
begin
  if PoleLista<>nil then
  if assigned(fGetLayersArray)then
  if fGetLayersArray(LayerArray)then
  begin
    sLV.BeginUpdate;
    sLV.Items.Clear;
    for n:=low(LayerArray) to high(layerarray) do
    begin
      sLV.Items.Add;
      sLV.Items.Item[n].SubItems.Add('');
      sLV.Items.Item[n].SubItems.Add('');
      sLV.Items.Item[n].SubItems.Add('');
      ObnovitItem(sLV.Items.Item[n],LayerArray[n]);
    end;
    sLV.SortType:=stBoth;
    sLV.EndUpdate;
  end;
end;

procedure TZCADLayerComboBox.LVKlac(Sender:TObject);                            // Обработков кликов на развёрнутом списке
  var
    LVItem:TListItem;
    KlacPoint,KlacContrlPoint,S:TPoint;
    NumProp,colwidth,i:integer;
    collapsed:boolean;
    newlp:TLayerPropRecord;
begin
  if sLV.Items.Count>0 then
  begin
    FNotClose:=true;
    S.X:=0;
    S.Y:=0;
    KlacContrlPoint:=sLV.ScreenToClient(S);
    S:=Mouse.CursorPos;
    KlacPoint.X:=S.X+KlacContrlPoint.X;
    KlacPoint.Y:=S.Y+KlacContrlPoint.Y;
    LVItem:=nil;
    LVItem:=sLV.GetItemAt(KlacPoint.X,KlacPoint.Y);
    if LVItem<>nil then
    begin
      sLV.BeginUpdate;
      numprop:=0;
      colwidth:=0;
      for i:=0 to sLV.ColumnCount-1 do
      begin
        colwidth:=colwidth+sLV.column[i].Width;
        if KlacPoint.x>colwidth then inc(numprop) else break;
      end;
      if assigned(fClickOnLayerProp)then collapsed:=fClickOnLayerProp(LVItem.Data,NumProp,newlp);
      LVItem.Focused:=false;
      LVItem.Selected:=false;
      ObnovitItem(LVItem,newlp);
      sLV.EndUpdate;
      if collapsed then Application.QueueAsyncCall(@PLDeActivate2,0);
      FNotClose:=false;
    end;
  end;
end;

procedure TZCADLayerComboBox.KeyDown(Sender:TObject;var Key:Word;Shift:TShiftState); // Отлавливаем эскей
begin
  if Key=27 then Application.QueueAsyncCall(@PLDeActivate3,0);
end;

procedure TZCADLayerComboBox.MouseEnter;                                        // Курсор мышки зашёл на кнопку
begin
  if sSostoyanie=2 then exit;
  sSostoyanie:=2;
  Invalidate;
end;

procedure TZCADLayerComboBox.MouseLeave;                                        // Курсор мыши вышел за кнопку
begin
  if sSostoyanie=1 then exit;
  sSostoyanie:=1;
  Invalidate;
end;

procedure TZCADLayerComboBox.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); // Нажата кнопка мыши
begin
  if sSostoyanie=3 then exit;
  if Button=mbLeft then
  begin
    sSostoyanie:=3;
    Invalidate;
  end;
end;

procedure TZCADLayerComboBox.MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); // Отжата кнопка мыши
begin
  if sSostoyanie<>3 then exit;
  if Button=mbLeft then
  begin
    if ((X>=0)and(X<Width))and((Y>=0)and(Y<=Height)) then sSostoyanie:=2 else sSostoyanie:=1;
    Invalidate;
  end;
end;

//============================================================================//

end.