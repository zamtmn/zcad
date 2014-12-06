unit ZListView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Graphics, GraphType, Controls, LCLIntf, LCLType,
  usupportgui;

type
  TDrawProc=procedure(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState) of object;
  TIsOnFunc=function(Item: TListItem):boolean of object;
  TOnClick=function(Item: TListItem;r: TRect):boolean of object;
  TOnGetName=function(Item: TListItem):String of object;
  TOnMakeCurrent=procedure(Item: TListItem)of object;

  PTSubItemRec=^TSubItemRec;
  TSubItemRec=packed record
    OnDraw:TDrawProc;
    IsOn:TIsOnFunc;
    OnClick,On2Click:TOnClick;
    OnGetName:TOnGetName;
    OnImageIndex,OffImageIndex:Integer;
  end;

  TSubItemRecArray=array of TSubItemRec;

  TZListView = class(TListView)
  private
    { Private declarations }
    FonMakeCurrent:TOnMakeCurrent;
    function GetMakeCurrent:TOnMakeCurrent;
    procedure SetMakeCurrent(mk:TOnMakeCurrent);
  protected
    { Protected declarations }
    MouseDownItem:TListItem;
    MouseDownSubItem:Integer;
    DoubleClick:Boolean;
    function CustomDrawSubItem(AItem: TListItem; ASubItem: Integer; AState: TCustomDrawState; AStage: TCustomDrawStage): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure DummyOnCDSubItem(Sender: TCustomListView; Item: TListItem;
                               SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
  public
    { Public declarations }
    SubItems:TSubItemRecArray;
    DefaultItemIndex:integer;
    CurrentItem:TListItem;
    constructor Create(AOwner: TComponent); override;
    procedure ProcessClick(ListItem:TListItem;SubItem:Integer;DblClck:Boolean);
    procedure Process(ListItem:TListItem;SubItem:Integer;DblClck:Boolean);
    function GetListItem(x,y:integer;out ListItem:TListItem; out SubItem:Integer):boolean;
    procedure UpdateItem(Item: TListItem;CurrentItemData:Pointer);
  published
    { Published declarations }
    property onMakeCurrent:TOnMakeCurrent read GetMakeCurrent write SetMakeCurrent;
  end;

procedure Register;

implementation
procedure TZListView.DummyOnCDSubItem(Sender: TCustomListView; Item: TListItem;
  SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  DefaultDraw:=true;
end;
function TZListView.GetListItem(x,y:integer;out ListItem:TListItem; out SubItem:Integer):boolean;
var
   pos: integer;
begin
     ListItem:=GetItemAt(x,y);
     if ListItem<>nil then
     begin
       result:=true;
       Pos := -GetScrollPos (Handle, SB_HORZ);
       SubItem := -1;
       while Pos < X do
       begin
         Inc (SubItem);
         Inc (Pos, Columns.Items[SubItem].Width);
       end;
       if SubItem >= Columns.Count then
         SubItem := -1;
     end
     else
       result:=false;
end;
procedure TZListView.UpdateItem(Item: TListItem;CurrentItemData:Pointer);
var
   i:integer;
   psubitem:PTSubItemRec;
begin
     if Item.Data=CurrentItemData then
     begin
      Item.ImageIndex:=DefaultItemIndex;
      CurrentItem:=Item;
     end;
     Item.SubItems.Clear;
     for i:=0 to high(SubItems) do
     begin
          psubitem:=@SubItems[i];
          if assigned(psubitem^.IsOn) then
           begin
            if psubitem^.IsOn(item) then
                                  Item.SubItems.Add('True')
                              else
                                  Item.SubItems.Add('False');
           end
     else if assigned(psubitem^.OnGetName) then
           begin
            Item.SubItems.Add(psubitem^.OnGetName(item));
           end
     else Item.SubItems.Add('');
     end;
     {pdwg:=gdb.GetCurrentDWG;
     plp:=Item.Data;
     Item.SubItems.Clear;
     if plp=pdwg^.LayerTable.GetCurrentLayer then
     begin
      Item.ImageIndex:=II_Ok;
      CurrentLayer:=Item;
     end;
     Item.SubItems.Add(strproc.Tria_AnsiToUtf8(plp^.GetName));
     Item.SubItems.Add('');
     Item.SubItems.Add('');
     Item.SubItems.Add('');
     Item.SubItems.Add(GetColorNameFromIndex(plp^.color));
     Item.SubItems.Add(GetLTName(plp^.LT));
     Item.SubItems.Add(GetLWNameFromLW(plp^.lineweight));
     Item.SubItems.Add('');
     Item.SubItems.Add(strproc.Tria_AnsiToUtf8(plp^.desk));}
end;
constructor TZListView.Create(AOwner: TComponent);
begin
  MouseDownItem:=nil;
  MouseDownSubItem:=-1;
  DoubleClick:=false;
  OnCustomDrawSubItem:=@DummyOnCDSubItem;
  inherited;
end;

procedure TZListView.ProcessClick(ListItem:TListItem;SubItem:Integer;DblClck:Boolean);
var i:integer;
begin
     BeginUpdate;
     process(ListItem,SubItem,DoubleClick);
     for i:=0 to Items.Count-1 do
     begin
          if Items[i].Selected then
          if Items[i]<>ListItem then
             process(Items[i],SubItem,false);
     end;
     EndUpdate;
end;
function TZListView.GetMakeCurrent:TOnMakeCurrent;
begin
     result:=FonMakeCurrent;
end;
procedure TZListView.SetMakeCurrent(mk:TOnMakeCurrent);
begin
     FonMakeCurrent:=mk;
end;

procedure TZListView.Process(ListItem:TListItem;SubItem:Integer;DblClck:Boolean);
var
   PSubItemRec:PTSubItemRec;
   rect: TRect;
   pos,si: integer;
begin
  Pos := -GetScrollPos (Handle, SB_HORZ);
  si := -1;
  while si < (subitem-1) do
  begin
    Inc (Si);
    Inc (Pos, Columns.Items[si].Width);
  end;
  si:=ListItem.DisplayRect(drBounds).Bottom-ListItem.DisplayRect(drBounds).Top-1;
  rect:=Bounds(pos,ListItem.Top,Columns.Items[SubItem].Width,si);

     if SubItem=0 then
     begin
          if DoubleClick then
          if assigned(onMakeCurrent) then
            onMakeCurrent(ListItem);
          exit;
     end;
     if length(SubItems)>0 then
      begin
       PSubItemRec:=@SubItems[SubItem-1];
       if assigned(PSubItemRec)then
       begin
            if DblClck then
             begin
               if assigned(PSubItemRec^.On2Click)then
                PSubItemRec^.On2Click(listitem,rect);
             end
            else
             begin
               if assigned(PSubItemRec^.OnClick)then
                PSubItemRec^.OnClick(listitem,rect);
             end;
             invalidate;
       end;
      end;
end;
procedure TZListView.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
     if Button=mbLeft then
      begin
       GetListItem(x,y,MouseDownItem,MouseDownSubItem);
       if ssDouble in Shift then
         doubleclick:=true
       else
         doubleclick:=false;
      end;
end;

procedure TZListView.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
var
   li:TListItem;
   col: Integer;
begin
     if Button=mbLeft then
     begin
     if GetListItem(x,y,li,col) then
       begin
         if li=MouseDownItem then
          if col=MouseDownSubItem then
            ProcessClick(li,col,DoubleClick);
       end;
     end;
     MouseDownItem:=nil;
     MouseDownSubItem:=-1;
     DoubleClick:=false;
end;

function TZListView.CustomDrawSubItem(AItem: TListItem; ASubItem: Integer; AState: TCustomDrawState; AStage: TCustomDrawStage): Boolean;
var
   PSubItemRec:PTSubItemRec;
   ARect: TRect;
begin
     result:=inherited;
     if result then
     begin
          if (length(SubItems)>0)and(length(SubItems)>=ASubItem) then
          begin
            PSubItemRec:=@SubItems[ASubItem-1];
            if assigned(PSubItemRec)then
            begin
              if assigned(PSubItemRec^.OnDraw) then
                begin
                  PSubItemRec^.OnDraw(canvas,Aitem,ASubItem,AState);
                  result:=false;
                end;
              if assigned(PSubItemRec^.IsOn) then
                begin
                  ARect:=ListViewDrawSubItem(AState,canvas,AItem,ASubItem);
                  if PSubItemRec^.IsOn(Aitem) then
                    begin
                      if PSubItemRec^.OnImageIndex>=0 then
                        SmallImages.Draw(Canvas,ARect.Left+(ARect.Right-ARect.Left)div 2-8,ARect.Top,PSubItemRec^.OnImageIndex,gdeNormal)
                    end
                  else
                    begin
                      if PSubItemRec^.OffImageIndex>=0 then
                        SmallImages.Draw(Canvas,ARect.Left+(ARect.Right-ARect.Left)div 2-8,ARect.Top,PSubItemRec^.OffImageIndex,gdeNormal);
                    end;
                  result:=false;
                end;
            end;
          end;
     end;
end;

procedure Register;
begin
  RegisterComponents('zcadcontrols',[TZListView]);
end;

end.
