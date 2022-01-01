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
  GraphType,LCLIntf,LCLType,
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms,Themes,ActnList,Menus,
  sysutils;

type
  generic TPartEnabler<T>=class(TToolBar)
    type
      PT=^T;
      TGetCountFunc=function(const value:T):integer of object;
      TGetStateFunc=function(const value:T;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean of object;
      TSetStateProc=procedure(var value:T;const n:integer;state:boolean) of object;
      TPartsEditFunc=function(var value:T):boolean of object;
   private
    var
      fpvalue:PT;
      actns:array of taction;
      fGetCountFunc:TGetCountFunc;
      fGetStateFunc:TGetStateFunc;
      fSetStateProc:TSetStateProc;
      fOnPartChanged:TNotifyEvent;
      fPartsEditFunc:TPartsEditFunc;

   public
      constructor Create(TheOwner: TComponent); override;
      procedure setup(var value:T);
      function DoGetCountFunc(const value:T):integer;
      function DoGetStateFunc(const value:T;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean;
      procedure DoSetStateProc(var value:T;const n:integer;state:boolean);
      procedure DoButtonClick(Sender: TObject);
      procedure DoPartsEditor(Sender: TObject);
      function ButtonIndex2PartIndex(index:integer):integer;

      property pvalue:PT read fpvalue write fpvalue;
      property PartsEditFunc:TPartsEditFunc read fPartsEditFunc write fPartsEditFunc;
      property GetCountFunc:TGetCountFunc read fGetCountFunc write fGetCountFunc;
      property GetStateFunc:TGetStateFunc read fGetStateFunc write fGetStateFunc;
      property SetStateProc:TSetStateProc read fSetStateProc write fSetStateProc;
      property OnPartChanged:TNotifyEvent read fOnPartChanged write fOnPartChanged;
  end;

implementation
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
constructor TPartEnabler.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ShowCaptions:=true;
  Wrapable:=false;
  Transparent:=true;
  EdgeBorders:=[];
  fPartsEditFunc:=nil;
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
  if assigned(fPartsEditFunc)then
  with TToolButton.create(self) do
  begin
    Caption:='Ed';
    ShowCaption:=false;
    if length(actns)>0 then begin
      _menu:=TPopupMenu.Create(self);
      style:=tbsDropDown;
      for i:=0 to length(actns)-1 do begin
        CreatedMenuItem:=TMenuItem.Create(_menu);
        CreatedMenuItem.Action:=actns[i];
        _menu.items.Add(CreatedMenuItem);
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
    with TToolButton.create(self) do
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

end.
