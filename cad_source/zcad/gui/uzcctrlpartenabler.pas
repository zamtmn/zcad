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
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
unit uzcctrlpartenabler;

{$mode objfpc}{$H+}

interface

uses
  GraphType,LCLIntf,LCLType,Toolwin,InterfaceBase,
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms,Themes,ActnList,Menus,
  sysutils,Generics.Collections;

const
  PEMenuSeparator:Pointer=nil;
  PEMenuSubMenu:Pointer=Pointer(1);

type
  TDraggedToolButton=class(TToolButton)
   private
    MDown:TPoint;
    waitdrag:boolean;
   public
    constructor Create(TheOwner: TComponent); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;


  TDToolBar=class(TToolBar)
    procedure StartToolButtonDrag(btn:TDraggedToolButton;MDownInBtn:TPoint);virtual;abstract;
  end;

  TMenuItemList=specialize TObjectList<TMenuItem>;
  generic TPartEnabler<T>=class(TDToolBar)
    type
      PT=^T;
      TGetCountFunc=function(const value:T):integer of object;
      TGetStateFunc=function(const value:T;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean of object;
      TSetStateProc=procedure(var value:T;const n:integer;state:boolean) of object;
      TPartsEditFunc=function(var value:T):boolean of object;
      TReorganizePartsFunc=procedure (var parts:string;const AFrom,ATo:integer;ABefore:boolean) of object;
   private
    var
      fpvalue:PT;
      actns:array of taction;
      submenus:TMenuItemList;
      fGetCountFunc:TGetCountFunc;
      fGetStateFunc:TGetStateFunc;
      fSetStateProc:TSetStateProc;
      fOnPartChanged:TNotifyEvent;
      fOnMenuPopup:TNotifyEvent;
      fPartsEditFunc:TPartsEditFunc;
      fReorganizeParts:TReorganizePartsFunc;
      fButtonDrag:boolean;
      fShadowShow:boolean;
      fDraggedBtn:TDraggedToolButton;
      MDInBtn:TPoint;
      Before:boolean;
      InsertTo:integer;
   public
      procedure StartToolButtonDrag(btn:TDraggedToolButton;MDownInBtn:TPoint);override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      procedure Reorganize;
      function CalcShadowPos(X, Y: Integer):TRect;
      function Dummy_ClientToScreen(const ARect: TRect):TRect;//добавлен в транке, в 2.2.0 данного медода нет
      procedure UpdateShadow(sr:TRect);
      constructor Create(TheOwner: TComponent); override;
      destructor Destroy; override;
      procedure setup(var value:T);
      procedure createSubMenus;
      function DoGetCountFunc(const value:T):integer;
      function DoGetStateFunc(const value:T;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean;
      procedure DoSetStateProc(var value:T;const n:integer;state:boolean);
      procedure DoButtonClick(Sender: TObject);
      procedure DoPartsEditor(Sender: TObject);
      procedure DoMenuPopup(Sender: TObject);
      function ButtonIndex2PartIndex(index:integer):integer;

      property pvalue:PT read fpvalue write fpvalue;
      property PartsEditFunc:TPartsEditFunc read fPartsEditFunc write fPartsEditFunc;
      property ReorganizeParts:TReorganizePartsFunc read fReorganizeParts write fReorganizeParts;
      property GetCountFunc:TGetCountFunc read fGetCountFunc write fGetCountFunc;
      property GetStateFunc:TGetStateFunc read fGetStateFunc write fGetStateFunc;
      property SetStateProc:TSetStateProc read fSetStateProc write fSetStateProc;
      property OnPartChanged:TNotifyEvent read fOnPartChanged write fOnPartChanged;
      property OnMenuPopup:TNotifyEvent read fOnMenuPopup write fOnMenuPopup;
  end;

var
  PartsDockManager:TDockManager;

implementation
constructor TDraggedToolButton.Create(TheOwner: TComponent);
begin
  inherited;
  waitdrag:=false;
end;

procedure TDraggedToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button=mbLeft then begin
    MDown:=point(x,y);
    waitdrag:=true;
  end;
  inherited;
end;

procedure TDraggedToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if waitdrag then
    if (abs(x-MDown.x)>DragManager.DragThreshold)or(abs(y-MDown.y)>DragManager.DragThreshold) then begin
    waitdrag:=false;
    if FToolBar is TDToolBar then
      (FToolBar as TDToolBar).StartToolButtonDrag(self,MDown);
  end;
  inherited;
end;

procedure TDraggedToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button=mbLeft then
    waitdrag:=false;
  inherited;
end;

procedure TPartEnabler.DoMenuPopup(Sender: TObject);
begin
  if assigned(fOnMenuPopup) then
    fOnMenuPopup(self);
end;

generic function TPartEnabler<T>.DoGetCountFunc(const value:T):integer;
begin
  if assigned(fGetCountFunc)then
    result:=fGetCountFunc(value)
  else
    result:=10;
end;
generic function TPartEnabler<T>.DoGetStateFunc(const value:T;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean;
begin
  if assigned(fGetStateFunc)then
    result:=fGetStateFunc(value,nmax,n,_name,_enabled)
  else begin
    result:=true;
    _enabled:=true;
    _name:='n'+inttostr(n);
  end;
end;
generic procedure TPartEnabler<T>.DoSetStateProc(var value:T;const n:integer;state:boolean);
begin
  if assigned(fSetStateProc)then
    fSetStateProc(value,n,state);
end;
procedure TPartEnabler.StartToolButtonDrag(btn:TDraggedToolButton;MDownInBtn:TPoint);
begin
  MouseCapture:=true;
  fButtonDrag:=true;
  fDraggedBtn:=btn;
  MDInBtn:=MDownInBtn;
end;

procedure TPartEnabler.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  sr:TRect;
begin
  inherited MouseMove(Shift,X,Y);
  if fButtonDrag then begin
    sr:=CalcShadowPos(x,y);
    UpdateShadow(sr);
  end;
end;

procedure TPartEnabler.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  sr:TRect;
begin
  inherited;
  if fShadowShow then begin
    sr:=CalcShadowPos(x,y);
    WidgetSet.DrawDefaultDockImage(sr,sr,disHide);
    fShadowShow:=false;
  end;
  fButtonDrag:=false;
  if InsertTo>0 then begin
    Reorganize;
    setup(fpvalue^);
    if assigned(fOnPartChanged)then
      fOnPartChanged(self);
  end;
end;

procedure TPartEnabler.Reorganize;
begin
  if assigned(ReorganizeParts) then begin
    ReorganizeParts(fpvalue^,fDraggedBtn.Index,InsertTo,Before)
  end;
  InsertTo:=-1;
end;

{ #todo : Убрать TPartEnabler.Dummy_ClientToScreen когда ClientToScreen(const ARect: TRect): TRect появится в релизе}
function TPartEnabler.Dummy_ClientToScreen(const ARect: TRect): TRect;//добавлен в транке, в 2.2.0 данного медода нет
var
  P : TPoint;
begin
  P := ClientToScreen(Point(0, 0));
  Result := ARect;
  Result.Offset(P);
end;


function TPartEnabler.CalcShadowPos(X, Y: Integer):TRect;

var
  i:integer;
  pnt:TPoint;
  draggedBtnNum:integer;
  prevBtn,currBtn:TDraggedToolButton;
  prv:boolean;
begin
  pnt:=Point(x,y);
  prevBtn:=nil;
  prv:=false;
  draggedBtnNum:=fDraggedBtn.Index;
  if BoundsRect.Contains(pnt) then
    for i:=0 to ButtonCount-1 do begin
      currBtn:=TDraggedToolButton(buttons[i]);
      InsertTo:=i;
      if currBtn is TDraggedToolButton then begin
        if currBtn<>fDraggedBtn then begin
          if ClientRect.Contains(pnt) then
          if currBtn.BoundsRect.Contains(pnt) or prv then begin
            before:=(x-currBtn.BoundsRect.Left)*2<currBtn.BoundsRect.Width;
            if before then begin
              prv:=false;
              if prevBtn<>fDraggedBtn then begin
                if prevBtn<>nil then
                  Result:=Dummy_ClientToScreen(rect(prevBtn.BoundsRect.CenterPoint.X,prevBtn.BoundsRect.Top,currBtn.BoundsRect.CenterPoint.x,currBtn.BoundsRect.Bottom))
                else
                  Result:=Dummy_ClientToScreen(rect(currBtn.BoundsRect.Left,currBtn.BoundsRect.Top,currBtn.BoundsRect.CenterPoint.x,currBtn.BoundsRect.Bottom));
                Result.intersect(Dummy_ClientToScreen(ClientRect));
                exit;
              end else if (currBtn.Index=ButtonCount-1)and(draggedBtnNum<>(ButtonCount-2)) then begin
                Result:=Dummy_ClientToScreen(rect(currBtn.BoundsRect.CenterPoint.X,currBtn.BoundsRect.Top,currBtn.BoundsRect.Right,currBtn.BoundsRect.Bottom));
                exit;
              end;
            end else begin
              {if (currBtn.Index=ButtonCount-1) then begin
                Result:=Dummy_ClientToScreen(rect(currBtn.BoundsRect.CenterPoint.X,currBtn.BoundsRect.Top,currBtn.BoundsRect.Right,currBtn.BoundsRect.Bottom));
                Result.intersect(Dummy_ClientToScreen(ClientRect));
                exit;
              end;}
              prv:=true;
            end;
          end;
          //prevBtn:=currBtn;
        end else
          prv:=false;
        prevBtn:=currBtn;
      end;
    end;
  Result.TopLeft:=ClientToScreen(Point(x,y));
  Result.TopLeft:=Result.TopLeft-MDInBtn;
  Result.BottomRight:=Result.TopLeft+Point(fDraggedBtn.Width,fDraggedBtn.Height);
  InsertTo:=-1;
end;

procedure TPartEnabler.UpdateShadow(sr:TRect);
begin
  if fShadowShow then
    WidgetSet.DrawDefaultDockImage(sr,sr,disMove)
  else begin
    WidgetSet.DrawDefaultDockImage(sr,sr,disShow);
    fShadowShow:=true;
  end;
end;


constructor TPartEnabler.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ShowCaptions:=true;
  Wrapable:=False;
  Transparent:=true;
  EdgeBorders:=[];
  fPartsEditFunc:=nil;
  fButtonDrag:=false;
  fShadowShow:=false;
end;

destructor TPartEnabler.Destroy;
begin
  inherited;
  setlength(actns,0);
  submenus.Free;
end;

procedure TPartEnabler.createSubMenus;
begin
  if not assigned(submenus) then begin
    submenus:=TMenuItemList.Create;
    submenus.OwnsObjects:=False;
  end;
end;

generic procedure TPartEnabler<T>.setup(var value:T);
var
  nmax,i:integer;
  _name:string;
  _state:boolean;
  _enabled:boolean;
  _menu:TPopupMenu;
  CreatedMenuItem:TMenuItem;
begin
  fpvalue:=@value;
  for i:=ButtonCount-1 downto 0 do
    Buttons[i].free;
  if assigned(submenus) then
    submenus.clear;
  if assigned(fPartsEditFunc)then
  with TToolButton.create(self) do
  begin
    Caption:='Ed';
    ShowCaption:=false;
    if length(actns)>0 then begin
      _menu:=TPopupMenu.Create(self);
      _menu.onPopup:=@DoMenuPopup;
      style:=tbsDropDown;
      for i:=0 to length(actns)-1 do begin
        if actns[i]=TObject(PEMenuSeparator) then begin
          _menu.items.AddSeparator;
        end else if actns[i]=TObject(PEMenuSubMenu) then begin
          CreatedMenuItem:=TMenuItem.Create(_menu);
          createSubMenus;
          submenus.Add(CreatedMenuItem);
          _menu.items.add(CreatedMenuItem);
        end else begin
          CreatedMenuItem:=TMenuItem.Create(_menu);
          CreatedMenuItem.Action:=actns[i];
          _menu.items.Add(CreatedMenuItem);
        end;
      end;
    end;
    PopupMenu:=_menu;
    DropDownMenu:=_menu;
    Visible:=true;
    left:=0;
    parent:=self;
    onClick:=@DoButtonClick;
  end;
  nmax:=DoGetCountFunc(value);
  for i:=1 to nmax do begin
    _state:=DoGetStateFunc(value,nmax,i,_name,_enabled);
    with TDraggedToolButton.create(self) do
    begin
      Caption:=_name;
      ShowCaption:=false;
      ShowHint:=true;
      Down:=_state;
      Enabled:=_enabled;
      style:=tbsCheck;
      Visible:=true;
      left:=300*i;
      parent:=self;
      dragKind:=dkDock;
      onClick:=@DoButtonClick;
    end;
  end;
end;

function TPartEnabler.ButtonIndex2PartIndex(index:integer):integer;
begin
  if assigned(fPartsEditFunc)then
   result:=index
  else
   result:=index+1;
end;

procedure TPartEnabler.DoPartsEditor(Sender: TObject);
var
  pts:T;
begin
  if assigned(PartsEditFunc)then begin
    pts:=fpvalue^;
    if PartsEditFunc(pts) then begin
      fpvalue^:=pts;
      setup(fpvalue^);
    end;
  end;
end;

procedure TPartEnabler.DoButtonClick(Sender: TObject);
var
  i:integer;
  st:boolean;
  //pts:T;
begin
  if sender is TToolButton then begin
    i:=ButtonIndex2PartIndex((sender as TToolButton).Index);
    if i=0 then begin
      DoPartsEditor(Sender);
    end else begin
      st:=(sender as TToolButton).Down;
      DoSetStateProc(fpvalue^,i,st);
    end;
  end;
  if assigned(fOnPartChanged)then
    fOnPartChanged(self);
end;

initialization
  PartsDockManager:=DefaultDockManagerClass.Create(nil);
finalization
  FreeAndNil(PartsDockManager);
end.
