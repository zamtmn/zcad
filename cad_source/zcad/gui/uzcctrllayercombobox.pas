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
unit uzcctrllayercombobox;

{$mode objfpc}{$H+}

interface

uses
  StdCtrls,GraphType,{types,}{$IFDEF LCLWIN32}win32proc,windows,{$endif}LCLIntf,LCLType,
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms,Themes;
const
  RightButtonWidth=20;// Ширина правой кнопки-стрелки при "темной" отрисовке

type
  TLayerPropRecord=record                                                       // Запись cписка (данные в памяти)
    _On:boolean;         // Включен/выключен слой
    Freze:boolean;       // Заморозка слоя
    Lock:boolean;        // Блокировка слоя
    Name:string;         // Имя слоя
    PLayer:pointer;
  end;

  TLayerArray=array of TLayerPropRecord;
  TGetLayerPropFunc=function(PLayer:Pointer;out lp:TLayerPropRecord):boolean of object;
  TGetLayersArrayFunc=function(out la:TLayerArray):boolean of object;
  TClickOnLayerPropFunc=function(PLayer:Pointer;NumProp:integer;out newlp:TLayerPropRecord):boolean of object;

  TMyListView=class(TListView)
  public
    property DefaultItemHeight;
  end;
TZCADDropDownForm=class(TCustomForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
end;
  TZCADLayerComboBox=class(TCustomControl)                          // Компонент TZCADLayerComboBox
  private
    Index:integer;
    //AktivItem:TLayerPropRecord;
    M1:boolean; // Маркер
    PoleLista:TZCADDropDownForm;
    sLV:TMyListView;
    sIL:TImageList;
    sListHeight:integer;
    sSostoyanie:integer;
    sIndex_ON:Integer;
    sIndex_OFF:Integer;
    sIndex_Freze:Integer;
    sIndex_UnFreze:Integer;
    sIndex_Lock:Integer;
    sIndex_UnLock:Integer;
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
    procedure _onKeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);
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
    property Index_ON:integer read sIndex_ON write sIndex_ON;
    property Index_OFF:integer read sIndex_OFF write sIndex_OFF;
    property Index_Freze:integer read sIndex_Freze write sIndex_Freze;
    property Index_UnFreze:integer read sIndex_UnFreze write sIndex_UnFreze;
    property Index_Lock:integer read sIndex_Lock write sIndex_Lock;
    property Index_UnLock:integer read sIndex_UnLock write sIndex_UnLock;
  end;

implementation

procedure TZCADDropDownForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
end;

procedure DrawComboBoxButton(ACanvas:TCanvas;ADown,AMouseInControl,ADisabled:Boolean; ARect:TRect);
var
  ComboElem: TThemedComboBox;
  Details: TThemedElementDetails;
begin
  {$IFDEF LCLWIN32}inflaterect(ARect,-1,-1){$ENDIF};
  if ADown then
    ComboElem := tcDropDownButtonPressed
  else if AMouseInControl then
    ComboElem := tcDropDownButtonHot
  else if ADisabled then
    begin
         {$IFNDEF LCLWIN32}
         ComboElem := tcDropDownButtonDisabled
         {$ELSE}
         if WindowsVersion >= wvVista then
           begin
                ThemeServices.DrawElement(ACanvas.Handle, ThemeServices.GetElementDetails(ttbSplitButtonDropDownDisabled),ARect);
                exit;
           end
         else ComboElem := tcDropDownButtonDisabled
         {$ENDIF};
    end
  else
    begin
      {$IFNDEF LCLWIN32}
      ComboElem := tcDropDownButtonNormal;
      {$ELSE}
      if WindowsVersion >= wvVista then
      begin
      ThemeServices.DrawElement(ACanvas.Handle, ThemeServices.GetElementDetails(ttbSplitButtonDropDownNormal),ARect);
      exit;
      end
      else ComboElem := tcDropDownButtonNormal
      {$ENDIF};
    end;
  Details := ThemeServices.GetElementDetails(ComboElem);
  ThemeServices.DrawElement(ACanvas.Handle, Details, ARect);
end;

procedure DrawComboBoxBox(ACanvas:TCanvas;ADown,AMouseInControl,ADisabled:Boolean; ARect:TRect);
  var
    ComboElem: {$IFNDEF LCLWIN32}TThemedButton{$ELSE}TThemedEdit{$ENDIF};
    Details: TThemedElementDetails;
    i,n,h,w,HalfRightButtonWidth:integer;
begin
  if ThemeServices.ThemesEnabled then
  begin
    if AMouseInControl then ComboElem:={$IFNDEF LCLWIN32}tbPushButtonHot{$ELSE}teEditTextHot{$ENDIF} else
    begin
      if ADisabled then ComboElem:={$IFNDEF LCLWIN32}tbPushButtonDisabled{$ELSE}teEditTextReadOnly{teEditTextDisabled}{$ENDIF} else ComboElem:={$IFNDEF LCLWIN32}tbPushButtonNormal{$ELSE}teEditTextNormal{$ENDIF};
    end;
    //ComboElem := {$IFDEF LINUX}tbPushButtonNormal{$ELSE}teEditTextNormal{$ENDIF};
    Details:=ThemeServices.GetElementDetails(ComboElem);
    ThemeServices.DrawElement(ACanvas.Handle,Details,ARect);
    ARect.Left:=ARect.Right-RightButtonWidth;
    DrawComboBoxButton(ACanvas,ADown,AMouseInControl,ADisabled,ARect);
  end
  else
  begin
    h:=ARect.Bottom-ARect.Top;
    w:=ARect.Right-ARect.Left;
    with ACanvas do
    begin
      HalfRightButtonWidth:=RightButtonWidth div 2;
      // Основа
      Pen.Style:=psSolid;
      Pen.Color:=clWindow;
      for i:=1 to w-2 do
      begin
        MoveTo(0,i);
        LineTo(w-RightButtonWidth,i);
      end;
      // Кнопка
      Pen.Color:=clForm;
      for i:=0 to h-1 do
      begin
        MoveTo(w-RightButtonWidth,i);
        LineTo(w-1,i);
      end;
      if AMouseInControl then Pen.Color:=clActiveBorder else Pen.Color:=clInactiveBorder;
      // Бордюр
      MoveTo(0,0);
      LineTo(w-1,0);
      LineTo(w-1,h-1);
      LineTo(0,h-1);
      LineTo(0,0);
      MoveTo(w-RightButtonWidth+1,0);
      LineTo(w-RightButtonWidth+1,h-1);
      // Стрелка?
      Pen.Style:=psSolid;
      if AMouseInControl then Pen.Color:=clGrayText else Pen.Color:=clWindowText;
      n:=12;
      for i:=(h-12) div 2 to (h-12) div 2+12 do
      begin
        MoveTo(w-HalfRightButtonWidth-(n div 2),i);
        LineTo(w-HalfRightButtonWidth+(n div 2),i);
        n:=n-1;
        if n=1 then system.break;// без этого стрелка кривая в qt
      end;
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
begin
  inherited Create(AOwner);
  M1:=false;
  sIL:=nil; // На всякий случай
  sIndex_ON:=-1;
  sIndex_OFF:=-1;
  sIndex_Freze:=-1;
  sIndex_UnFreze:=-1;
  sIndex_Lock:=-1;
  sIndex_UnLock:=-1;
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
      DrawComboBoxBox(Canvas,MD,MIC,not Enabled,ClientRect);
      Brush.Style:=bsClear;
      if fGetLayerProp(nil,lp) then
      begin
        // Отрисовываем иконки состояния выбранного слоя и надпись (имя выбранного слоя)
        if sIL<>nil then
        begin
          //Я заменил Height на ClientHeight, неработало в винде, в лине видимо канвас в абсолютных координатах, поэтому там работало
          //разбил по строкам чтоб при отладке было ясно видно then или else выполняется
          if (sIndex_OFF>=0) and (sIndex_ON>=0) and (sIndex_OFF<sIL.Count) and (sIndex_ON<sIL.Count) then
          begin
            if lp._On then
                          sIL.Draw(Canvas,1,(ClientHeight-16) div 2,sIndex_ON,gdeNormal)
                      else
                          sIL.Draw(Canvas,1,(ClientHeight-16) div 2,sIndex_OFF,gdeNormal);
          end;
          if (sIndex_Freze>=0) and (sIndex_UnFreze>=0) and (sIndex_Freze<sIL.Count) and (sIndex_UnFreze<sIL.Count) then
          begin
            if lp.Freze then
                            sIL.Draw(Canvas,18,(ClientHeight-16) div 2,sIndex_Freze,gdeNormal)
                        else
                            sIL.Draw(Canvas,18,(ClientHeight-16) div 2,sIndex_UnFreze,gdeNormal);
          end;
          if (sIndex_Lock>=0) and (sIndex_UnLock>=0) and (sIndex_Lock<sIL.Count) and (sIndex_UnLock<sIL.Count) then
          begin
            if lp.Lock then
                           sIL.Draw(Canvas,35,(ClientHeight-16) div 2,sIndex_Lock,gdeNormal)
                       else
                           sIL.Draw(Canvas,35,(ClientHeight-16) div 2,sIndex_UnLock,gdeNormal);
          end;
        end;
        TxRect:=ClientRect;//получение клиентской области
        //InflateRect(TxRect,-1,-1);//уменьшение ее на 1 пиксель внутрь по x и y
        TxRect.Left:=TxRect.Left+55;//сдвиг к началу текста
        TxRect.Right:=TxRect.Right-RightButtonWidth;//сдвиг к началу текста
        TextRect(TxRect,55,(ClientHeight-TextHeight(lp.Name)) div 2,lp.Name);  // Видимо функция TextRect попросту не работает... может когданибудь заработает? (текст не ограничивается по рамке)
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
    PoleLista:=TZCADDropDownForm.Create(self);
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
    {$IFDEF LCLWIN32}
    sLV.BorderStyle:={bsSingle}bsNone;
    {$endif}
    {$IFNDEF LCLWIN32}
    sLV.BorderStyle:=bsSingle;
    {$endif}
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
    sLV.OnKeyDown:=@_onKeyDown;
    sLV.OnCompare:=@Compareevent;
    ObnovitSpisok;
    if sListHeight>0 then
                         PoleLista.Height:=sListHeight
                     else
                         begin
                              sLV.DefaultItemHeight:=-1;
                              hh:=sLV.Height-sLV.ClientHeight;
                              hh:=screen.WorkAreaHeight-a.y-1;
                              {$IFNDEF LCLWIN32}h:=sLV.Items.Count*(sLV.DefaultItemHeight+1)+10;
                              {$ELSE}h:=sLV.Items.Count*(sLV.DefaultItemHeight-1)+4;{$ENDIF}
                              if h>hh then h:=hh;
                              PoleLista.ClientHeight:=h;
                         end;

    {$IFDEF LCLWIN32}
    SetWindowLong(PoleLista.Handle,GWL_STYLE,GetWindowLong(PoleLista.Handle,GWL_STYLE) or ws_border);
    SetClassLongPtr(PoleLista.Handle,GCL_STYLE,GetClassLongPtr(PoleLista.Handle,GCL_STYLE) or CS_DROPSHADOW);
    SetWindowPos(PoleLista.Handle,0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    {$endif}
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
    if lp._On then li.ImageIndex:=sIndex_ON else li.ImageIndex:=sIndex_OFF;
    if lp.Freze then li.SubItemImages[0]:=sIndex_Freze else li.SubItemImages[0]:=sIndex_UnFreze;
    if lp.Lock then li.SubItemImages[1]:=sIndex_Lock else li.SubItemImages[1]:=sIndex_UnLock;
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

procedure TZCADLayerComboBox._onKeyDown(Sender:TObject;var Key:Word;Shift:TShiftState); // Отлавливаем эскей
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
