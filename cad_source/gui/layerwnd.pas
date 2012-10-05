unit layerwnd;

{$mode objfpc}{$H+}

interface

uses
  colorwnd,ugdbsimpledrawing,zcadsysvars,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Grids, ComCtrls,LCLIntf,lcltype,

  gdbobjectsconstdef,UGDBLayerArray,UGDBDescriptor,gdbase,gdbasetypes,varmandef,

  zcadinterface,zcadstrconsts,strproc,shared,UBaseTypeDescriptor;

type

  { TLayerWindow }

  TLayerWindow = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    B1: TBitBtn;
    B2: TBitBtn;
    B3: TBitBtn;
    ButtonApplyClose: TBitBtn;
    Button_Apply: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    ListView1: TListView;
    CurrentLayer:TListItem;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure B1Click(Sender: TObject);
    procedure B2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LWMouseUp(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
    procedure LWMouseDown(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
    procedure ProcessClick(ListItem:TListItem;SubItem:Integer);
    procedure Process(ListItem:TListItem;SubItem:Integer);
  private
    MouseDownItem:TListItem;
    MouseDownSubItem: Integer;
    changedstamp:boolean;
    PEditor:TPropEditor;
    { private declarations }
  public
    { public declarations }
  end; 

var
  LayerWindow: TLayerWindow;

implementation
uses mainwindow;
{ TLayerWindow }

procedure TLayerWindow.FormCreate(Sender: TObject); // Процедура выполняется при отрисовке окна
begin
// Отрисовываем картинки на кнопках
MainFormN.IconList.GetBitmap(II_Plus, B1.Glyph);
MainFormN.IconList.GetBitmap(II_Minus, B2.Glyph);
MainFormN.IconList.GetBitmap(II_Ok, B3.Glyph);
ListView1.SmallImages:=MainFormN.IconList;
MouseDownItem:=nil;
MouseDownSubItem:=-1;
changedstamp:=false;
end;
function GetListItem(ListView1:TListView;x,y:integer;out ListItem:TListItem; out SubItem:Integer):boolean;
var
   pos: integer;
begin
     ListItem:=ListView1.GetItemAt(x,y);
     if ListItem<>nil then
     begin
     result:=true;
     Pos := -GetScrollPos (ListView1.Handle, SB_HORZ);
     SubItem := -1;
     while Pos < {Pt.}X do
     begin
       Inc (SubItem);
       Inc (Pos, ListView1.Columns.Items[SubItem].Width);
     end;
     if SubItem >= ListView1.Columns.Count then
       SubItem := -1;
     //showmessage (inttostr(col));
     end
     else
         result:=false;
end;
procedure TLayerWindow.Process(ListItem:TListItem;SubItem:Integer);
var
   pos,si: integer;
   mr:integer;
begin
     {if SubItem>0 then
                  ListItem.SubItemImages[SubItem-1]:=3
              else
                  ListItem.ImageIndex:=3;}
     dec(subitem);
     case subitem of
          -1:begin
                   if CurrentLayer<>ListItem then
                   begin
                   SysVar.dwg.DWG_CLayer^:=gdb.GetCurrentDWG^.LayerTable.GetIndexByPointer(ListItem.Data);
                   ListItem.ImageIndex:=II_Ok;
                   CurrentLayer.ImageIndex:=-1;
                   CurrentLayer:=ListItem;
                   if not PGDBLayerProp(ListItem.Data)^._on then
                                                                 MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
                   changedstamp:=true;
                   end;
            end;
           1:begin
                   PGDBLayerProp(ListItem.Data)^._on:=not PGDBLayerProp(ListItem.Data)^._on;
                   if PGDBLayerProp(ListItem.Data)^._on then
                                    ListItem.SubItemImages[1]:=II_LayerOn
                                else
                                    begin
                                    ListItem.SubItemImages[1]:=II_LayerOff;
                                    MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
                                    end;
                    changedstamp:=true;
             end;
           3:begin
                   PGDBLayerProp(ListItem.Data)^._lock:=not PGDBLayerProp(ListItem.Data)^._lock;
                   if PGDBLayerProp(ListItem.Data)^._lock then
                                    ListItem.SubItemImages[3]:=II_LayerLock
                                else
                                    ListItem.SubItemImages[3]:=II_LayerUnLock;
                    changedstamp:=true;
             end;
           4:begin
                if not assigned(ColorSelectWND)then
                Application.CreateForm(TColorSelectWND, ColorSelectWND);
                mr:=DoShowModal(ColorSelectWND);
                if mr=mrOk then
                               begin
                                    PGDBLayerProp(ListItem.Data)^.color:=ColorSelectWND.ColorInfex;
                                    ListItem.SubItems[4]:=inttostr(ColorSelectWND.ColorInfex);
                               end;
                freeandnil(ColorSelectWND);
                changedstamp:=true;
             end;
           7:begin
                   PGDBLayerProp(ListItem.Data)^._print:=not PGDBLayerProp(ListItem.Data)^._print;
                   if uppercase(PGDBLayerProp(ListItem.Data)^.Name)=LNSysDefpoints then
                   begin
                   if PGDBLayerProp(ListItem.Data)^._print then shared.ShowError(rsLayerDefpaontsCanNotBePrinted);
                   PGDBLayerProp(ListItem.Data)^._print:=false;
                   end;
                   if PGDBLayerProp(ListItem.Data)^._print then
                                    ListItem.SubItemImages[7]:=II_LayerPrint
                                else
                                    ListItem.SubItemImages[7]:=II_LayerUnPrint;
                    changedstamp:=true;
             end;
           8:begin
                Pos := -GetScrollPos (ListView1.Handle, SB_HORZ);
                si := -1;
                while si < subitem do
                begin
                  Inc (Si);
                  Inc (Pos, ListView1.Columns.Items[si].Width);
                end;
                si:=ListItem.DisplayRect(drSelectBounds).Bottom-ListItem.DisplayRect(drSelectBounds).Top-1;
                PEditor:=GDBAnsiStringDescriptorObj.CreateEditor(self.ListView1,pos,ListItem.Top{Position.y},ListView1.Columns.Items[SubItem+1].Width,si,@PGDBLayerProp(ListItem.Data)^.desk,nil);
             end;
     end;
end;
procedure TLayerWindow.ProcessClick(ListItem:TListItem;SubItem:Integer);
var i:integer;
begin
     //ListView1.BeginUpdate;
     process(ListItem,SubItem);
     for i:=0 to ListView1.Items.Count-1 do
     begin
          if ListView1.Items[i].Selected then
          if ListView1.Items[i]<>ListItem then
                                              process(ListView1.Items[i],SubItem);
     end;
     //ListView1.EndUpdate;
end;

procedure TLayerWindow.LWMouseDown(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
begin
     GetListItem(ListView1,x,y,MouseDownItem,MouseDownSubItem);
end;
procedure TLayerWindow.LWMouseUp(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
var
   li:TListItem;
   ht:THitTests;
   //
   //pt: TPoint;
   col: Integer;
   pos: integer;
begin

     if GetListItem(ListView1,x,y,li,col) then
     begin
     if li=MouseDownItem then
     if col=MouseDownSubItem then
                                 ProcessClick(li,col);
     end;
     MouseDownItem:=nil;
     MouseDownSubItem:=-1;
end;

procedure TLayerWindow.FormShow(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
   s:ansistring;
   li:TListItem;
begin
     //ListView1.onconc
     ListView1.BeginUpdate;
     ListView1.Clear;
     ListView1.OnMouseUp:=@LWMouseUp;
     ListView1.OnMouseDown:=@LWMouseDown;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.LayerTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;

            li.Data:=plp;
            if plp=pdwg^.LayerTable.GetCurrentLayer then
                                                        begin
                                                        li.ImageIndex:=2;
                                                        CurrentLayer:=li;
                                                        end;
            li.SubItems.Add(strproc.Tria_AnsiToUtf8(plp^.GetName));
            li.SubItems.Add('');
            li.SubItems.Add('');
            li.SubItems.Add('');
            li.SubItems.Add(inttostr(plp^.color));
            li.SubItems.Add('Continuous');
            li.SubItems.Add(inttostr(plp^.lineweight));
            li.SubItems.Add('');
            li.SubItems.Add(strproc.Tria_AnsiToUtf8(plp^.desk));
            if plp^._on then
                            li.SubItemImages[1]:=II_LayerOn
                        else
                            li.SubItemImages[1]:=II_LayerOff;

            li.SubItemImages[2]:=10;

            if plp^._lock then
                            li.SubItemImages[3]:=II_LayerLock
                        else
                            li.SubItemImages[3]:=II_LayerUnLock;
            if plp^._print then
                            li.SubItemImages[7]:=II_LayerPrint
                        else
                            li.SubItemImages[7]:=II_LayerUnPrint;


            //s:=plp^.GetFullName;
            //ListView1.Items.Add(li);
            plp:=pdwg^.LayerTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.EndUpdate;
end;

procedure TLayerWindow.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
     Sender:=Sender;
end;

procedure TLayerWindow.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
     item:=item;
end;

procedure TLayerWindow.B1Click(Sender: TObject); // Процедура добавления слоя
begin
  //SGrid.RowCount:=SGrid.RowCount+1;
end;

procedure TLayerWindow.AplyClose(Sender: TObject);
begin
     close;
end;

procedure TLayerWindow.Aply(Sender: TObject);
begin
     if changedstamp then
     begin
           if assigned(UpdateVisibleProc) then UpdateVisibleProc;
           if assigned(redrawoglwndproc)then
                                            redrawoglwndproc;
     end;
end;

procedure TLayerWindow.B2Click(Sender: TObject); // Процедура удаления слоя
begin
  //SGrid.RowCount:=SGrid.RowCount-1;
end;

procedure TLayerWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     Aply(nil);
end;

initialization
  {$I layerwnd.lrs}

end.

