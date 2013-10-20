unit selectorwnd;
{$INCLUDE def.inc}
interface

uses
  strproc,UGDBDescriptor,gdbase,zcadstrconsts,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ButtonPanel, StdCtrls, types, lclintf,lcltype, EditBtn, ComCtrls,ugdbsimpledrawing;

type

  { TSelectorWindow }

  TSelectorWindow = class(TForm)
    ButtonPanel1: TButtonPanel;
    ListView1: TListView;
    procedure _oncreate(Sender: TObject);
    function run():integer;
    procedure _onSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure StartAddItems;
    procedure EndAddItems;
    procedure AddItem(Name,Desc:string;data:Pointer);
    procedure _onShow(Sender: TObject);
  private
    { private declarations }
  public
    data:pointer;
    { public declarations }
  end;

var
  SelectorWindow: TSelectorWindow=nil;
implementation

{$R *.lfm}

{ TSelectorWindow }
procedure TSelectorWindow.StartAddItems;
begin
     ListView1.BeginUpdate;
end;
procedure TSelectorWindow.EndAddItems;
begin
     ListView1.EndUpdate;
end;
procedure TSelectorWindow.AddItem(Name,Desc:string;data:Pointer);
var
   li:TListItem;
begin
     li:=ListView1.Items.Add;
     li.Data:=data;
     li.Caption:=Name;
     li.SubItems.Add(Desc);
end;

procedure TSelectorWindow._onShow(Sender: TObject);
var
   textrect:TRect;
   hh,ih,c:integer;
begin
     textrect := ListView1.Items[0].DisplayRect(drBounds);
     textrect := ListView1.Items[0].DisplayRect(drSelectBounds);
     hh:=textrect.top+1;
     ih:=textrect.Bottom-textrect.top;
     c:=ListView1.Items.Count;
     if c>20 then c:=20;
     ListView1.Height:=hh+c*(ih+3)+1+2*ListView1.BorderWidth;
     //ListView1.Width:=ListView1.Column[0].Width+ListView1.Column[1].Width;
end;

procedure TSelectorWindow._onSelect(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if selected then
  begin
       data:=Item.Data;
  end
end;

procedure TSelectorWindow._oncreate(Sender: TObject);
begin
     data:=nil;
end;


function TSelectorWindow.run():integer;
var i:integer;
begin
    result:=showmodal;
    if data=nil then
                    result:=mrcancel;
end;

end.

