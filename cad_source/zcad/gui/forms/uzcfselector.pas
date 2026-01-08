unit uzcfselector;
{$INCLUDE zengineconfig.inc}
interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ButtonPanel, types, lclintf,lcltype, ComCtrls, uzcuilcl2zc;

type

  { TSelectorForm }

  TSelectorForm = class(TForm)
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
  SelectorForm: TSelectorForm=nil;
implementation

{$R *.lfm}

{ TSelectorForm }
procedure TSelectorForm.StartAddItems;
begin
     ListView1.BeginUpdate;
end;
procedure TSelectorForm.EndAddItems;
begin
     ListView1.EndUpdate;
end;
procedure TSelectorForm.AddItem(Name,Desc:string;data:Pointer);
var
   li:TListItem;
begin
     li:=ListView1.Items.Add;
     li.Data:=data;
     li.Caption:=Name;
     li.SubItems.Add(Desc);
end;

procedure TSelectorForm._onShow(Sender: TObject);
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
     if c<4 then c:=4;
     ListView1.Height:=hh+c*(ih+3)+1+2*ListView1.BorderWidth;
     //ListView1.Width:=ListView1.Column[0].Width+ListView1.Column[1].Width;
end;

procedure TSelectorForm._onSelect(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if selected then
  begin
       data:=Item.Data;
  end
end;

procedure TSelectorForm._oncreate(Sender: TObject);
begin
     data:=nil;
end;


function TSelectorForm.run():integer;
begin
    result:=showmodal;
    if data=nil then
                    result:=mrcancel;
    result:=TLCLModalResult2TZCMsgModalResult.Convert(result);
end;

end.

