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
  StdCtrls,GraphType,LCLIntf,LCLType,
  Controls,Classes,Graphics,Buttons,ExtCtrls,ComCtrls,Forms,Themes,
  sysutils;

type
  generic TPartEnabler<T>=class(TToolBar)
    type
      PT=^T;
      TGetCountFunc=function(const value:T):integer of object;
      TGetStateFunc=function(const value:T;const n:integer; out _name:string):boolean of object;
      TSetStateProc=procedure(var value:T;const n:integer;state:boolean) of object;
      TPartsEditFunc=function(var value:T):boolean of object;
   private
    var
      fpvalue:PT;
      fGetCountFunc:TGetCountFunc;
      fGetStateFunc:TGetStateFunc;
      fSetStateProc:TSetStateProc;
      fOnPartChanged:TNotifyEvent;
      fPartsEditFunc:TPartsEditFunc;

   public
      constructor Create(TheOwner: TComponent); override;
      procedure setup(var value:T);
      function DoGetCountFunc(const value:T):integer;
      function DoGetStateFunc(const value:T;const n:integer; out _name:string):boolean;
      procedure DoSetStateProc(var value:T;const n:integer;state:boolean);
      procedure DoButtonClick(Sender: TObject);
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
generic function TPartEnabler<T>.DoGetStateFunc(const value:T;const n:integer; out _name:string):boolean;
begin
  if assigned(fGetStateFunc)then
    result:=fGetStateFunc(value,n,_name)
  else begin
    result:=true;
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
  i:integer;
  _name:string;
  _state:boolean;
begin
  fpvalue:=@value;
  for i:=ButtonCount-1 downto 0 do
    Buttons[i].free;
  if assigned(fPartsEditFunc)then
  with TToolButton.create(self) do
  begin
    Caption:='Ed';
    ShowCaption:=false;
    Visible:=true;
    left:=0;
    parent:=self;
    onClick:=@DoButtonClick;
  end;
  for i:=1 to DoGetCountFunc(value) do begin
    _state:=DoGetStateFunc(value,i,_name);
    with TToolButton.create(self) do
    begin
      Caption:=_name;
      ShowCaption:=false;
      ShowHint:=true;
      Down:=_state;
      style:=tbsCheck;
      Visible:=true;
      left:=30*i;
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

procedure TPartEnabler.DoButtonClick(Sender: TObject);
var
  i:integer;
  st:boolean;
  pts:T;
begin
  if sender is TToolButton then begin
    i:=ButtonIndex2PartIndex((sender as TToolButton).Index);
    if i=0 then begin
      if assigned(PartsEditFunc)then begin
        pts:=fpvalue^;
        if PartsEditFunc(pts) then begin
          fpvalue^:=pts;
          setup(fpvalue^);
        end;
      end;
    end else begin
      st:=(sender as TToolButton).Down;
      DoSetStateProc(fpvalue^,i,st);
    end;
  end;
  if assigned(fOnPartChanged)then
    fOnPartChanged(self);
end;

end.
