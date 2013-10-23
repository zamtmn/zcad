unit layerwnd;
{$INCLUDE def.inc}
{$mode objfpc}

interface

uses
  selectorwnd,ugdbltypearray,ugdbutil,log,lineweightwnd,colorwnd,ugdbsimpledrawing,zcadsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, Dialogs,GraphType,
  Buttons, ExtCtrls, StdCtrls, Grids, ComCtrls,LCLIntf,lcltype,

  gdbobjectsconstdef,UGDBLayerArray,UGDBDescriptor,gdbase,gdbasetypes,varmandef,

  zcadinterface,zcadstrconsts,strproc,shared,UBaseTypeDescriptor,imagesmanager,usupportgui;

type

  { TLayerWindow }

  TLayerWindow = class(TForm)
    AddLayerBtn: TSpeedButton;
    DeleteLayerBtn: TSpeedButton;
    Bevel1: TBevel;
    ButtonApplyClose: TBitBtn;
    Button_Apply: TBitBtn;
    LayerDescLabel: TLabel;
    ListView1: TListView;
    CurrentLayer:TListItem;
    MkCurrentBtn: TSpeedButton;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure LayerAdd(Sender: TObject);
    procedure LayerDelete(Sender: TObject);
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
    procedure MkCurrent(Sender: TObject);
    procedure onCDItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure onCDSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ProcessClick(ListItem:TListItem;SubItem:Integer;DoubleClick:Boolean);
    procedure Process(ListItem:TListItem;SubItem:Integer;DoubleClick:Boolean);
    procedure createeditor(ListView:TListView;ListItem:TListItem;SubItem:Integer;P:PAnsiString);
    procedure MaceItemCurrent(ListItem:TListItem);
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure asyncfreeeditor(Data: PtrInt);
    procedure freeeditor;
    procedure UpdateItem(Item: TListItem);
    procedure countlayer(player:PGDBLayerProp;out e,b:GDBInteger);
  private
    MouseDownItem:TListItem;
    MouseDownSubItem: Integer;
    DoubleClick:Boolean;
    changedstamp:boolean;
    PEditor:TPropEditor;
    EditedItem:TListItem;
    { private declarations }
  public
    { public declarations }
  end; 

var
  LayerWindow: TLayerWindow;
implementation
uses
    mainwindow;
{$R *.lfm}

{ TLayerWindow }

procedure TLayerWindow.FormCreate(Sender: TObject); // Процедура выполняется при отрисовке окна
begin
// Отрисовываем картинки на кнопках
IconList.GetBitmap(II_Plus, AddLayerBtn.Glyph);
IconList.GetBitmap(II_Minus, DeleteLayerBtn.Glyph);
IconList.GetBitmap(II_Ok, MkCurrentBtn.Glyph);
ListView1.SmallImages:=IconList;
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
procedure TLayerWindow.MaceItemCurrent(ListItem:TListItem);
begin
     if CurrentLayer<>ListItem then
     begin
     with PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(sysvar.dwg.DWG_CLayer^)^ do
     begin
          SysVar.dwg.DWG_CLayer^:={gdb.GetCurrentDWG^.LayerTable.GetIndexByPointer}(ListItem.Data);
          ComitFromObj;
     end;
     ListItem.ImageIndex:=II_Ok;
     CurrentLayer.ImageIndex:=-1;
     CurrentLayer:=ListItem;
     if not PGDBLayerProp(ListItem.Data)^._on then
                                                   MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
     changedstamp:=true;
     end;
end;
procedure FillSelector(SelectorWindow: TSelectorWindow);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
begin
     SelectorWindow.StartAddItems;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            if (pltp^.Mode<>TLTByBlock)and(pltp^.Mode<>TLTByLayer)then
                SelectorWindow.AddItem(strproc.Tria_AnsiToUtf8(pltp^.Name),strproc.Tria_AnsiToUtf8(pltp^.desk),pltp);

            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;
     SelectorWindow.EndAddItems;
end;
procedure TLayerWindow.Process(ListItem:TListItem;SubItem:Integer;DoubleClick:Boolean);
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
          -1:
             if DoubleClick then
             MaceItemCurrent(ListItem);
           0:
             if DoubleClick then
             createeditor(ListView1,ListItem,SubItem,@PGDBLayerProp(ListItem.Data)^.Name);
           1:begin
                   PGDBLayerProp(ListItem.Data)^._on:=not PGDBLayerProp(ListItem.Data)^._on;
                   if PGDBLayerProp(ListItem.Data)^._on then
                                    ListItem.SubItemImages[1]:=II_LayerOn
                                else
                                    begin
                                    ListItem.SubItemImages[1]:=II_LayerOff;
                                    if SysVar.dwg.DWG_CLayer^={gdb.GetCurrentDWG^.LayerTable.GetIndexByPointer}(ListItem.Data) then
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
                //mr:=DoShowModal(ColorSelectWND);
                if assigned(ShowAllCursorsProc) then
                                                    ShowAllCursorsProc;
                mr:=ColorSelectWND.run(PGDBLayerProp(ListItem.Data)^.color,false);
                if assigned(RestoreAllCursorsProc) then
                                                    RestoreAllCursorsProc;
                if mr=mrOk then
                               begin
                                    PGDBLayerProp(ListItem.Data)^.color:=ColorSelectWND.ColorInfex;
                                    ListItem.SubItems[4]:=GetColorNameFromIndex(ColorSelectWND.ColorInfex);
                               end;
                freeandnil(ColorSelectWND);
                changedstamp:=true;
             end;
           5:begin
                if not assigned(SelectorWindow)then
                Application.CreateForm(TSelectorWindow, SelectorWindow);
                FillSelector(SelectorWindow);
                if assigned(ShowAllCursorsProc) then
                                                    ShowAllCursorsProc;
                mr:=SelectorWindow.run;
                if assigned(RestoreAllCursorsProc) then
                                                    RestoreAllCursorsProc;
                if mr=mrOk then
                               begin
                                    PGDBLayerProp(ListItem.Data)^.LT:=SelectorWindow.data;
                               end;
                freeandnil(SelectorWindow);
                changedstamp:=true;
             end;
           6:begin
                if not assigned(LineWeightSelectWND)then
                Application.CreateForm(TLineWeightSelectWND, LineWeightSelectWND);
                if assigned(ShowAllCursorsProc) then
                                                    ShowAllCursorsProc;
                mr:={DoShowModal}(LineWeightSelectWND.run(PGDBLayerProp(ListItem.Data)^.lineweight,false));
                if assigned(RestoreAllCursorsProc) then
                                                    RestoreAllCursorsProc;
                if mr=mrOk then
                               begin
                                    PGDBLayerProp(ListItem.Data)^.lineweight:=LineWeightSelectWND.SelectedLW;
                                    ListItem.SubItems[6]:=GetLWNameFromLW(LineWeightSelectWND.SelectedLW);
                               end;
                freeandnil(LineWeightSelectWND);
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
           8:
             if DoubleClick then
             createeditor(ListView1,ListItem,SubItem,@PGDBLayerProp(ListItem.Data)^.desk);
     end;
end;
procedure TLayerWindow.createeditor(ListView:TListView;ListItem:TListItem;SubItem:Integer;P:PAnsiString);
var
   pos,si: integer;
   mr:integer;
begin
  Pos := -GetScrollPos (ListView.Handle, SB_HORZ);
  si := -1;
  while si < subitem do
  begin
    Inc (Si);
    Inc (Pos, ListView.Columns.Items[si].Width);
  end;
  si:=ListItem.DisplayRect(drBounds).Bottom-ListItem.DisplayRect(drBounds).Top-1;
  if peditor<>nil then
  begin
       Application.RemoveAsyncCalls(self);
       freeeditor;
  end;
  PEditor:=GDBAnsiStringDescriptorObj.CreateEditor(self.ListView1,pos,ListItem.Top,ListView1.Columns.Items[SubItem+1].Width,si,p,nil,true);
  PEditor.geteditor.SetFocus;
  PEditor.OwnerNotify:=@Notify;
  EditedItem:=ListItem;
end;

procedure TLayerWindow.Notify(Sender: TObject;Command:TMyNotifyCommand);
//var
   //pld:GDBPointer;
   //pdwg:PTDrawing;
begin
  if sender=PEditor then
  begin
    //pld:=peditor.PInstance;
    if Command=TMNC_EditingDone then
                                    begin
                                    Application.QueueAsyncCall(@asyncfreeeditor,0);
                                    end;
  end;
end;
procedure TLayerWindow.asyncfreeeditor(Data: PtrInt);
begin
  if peditor<>nil then
  begin
       freeeditor;
  end;
end;
procedure TLayerWindow.freeeditor;
begin
  //if peditor<>nil then
  begin
       peditor.Free;
       peditor:=nil;
       //freeandnil(peditor);
       ListView1.BeginUpdate;
       UpdateItem(EditedItem);
       ListView1.EndUpdate;
       EditedItem:=nil;
  end;
end;


procedure TLayerWindow.ProcessClick(ListItem:TListItem;SubItem:Integer;DoubleClick:Boolean);
var i:integer;
begin
     //ListView1.BeginUpdate;
     process(ListItem,SubItem,DoubleClick);
     for i:=0 to ListView1.Items.Count-1 do
     begin
          if ListView1.Items[i].Selected then
          if ListView1.Items[i]<>ListItem then
                                              process(ListView1.Items[i],SubItem,false);
     end;
     //ListView1.EndUpdate;
end;

procedure TLayerWindow.LWMouseDown(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
begin
     if Button=mbLeft then
     begin
     GetListItem(ListView1,x,y,MouseDownItem,MouseDownSubItem);
     {if ListView1.SelCount>1 then
     begin}
     if ssDouble in Shift then
                              doubleclick:=true
                          else
                              doubleclick:=false;
     {end
     else
         begin
         ProcessClick(MouseDownItem,MouseDownSubItem,false);
         MouseDownItem:=nil;
         MouseDownSubItem:=-1;
         end;}
     end;
end;

procedure TLayerWindow.MkCurrent(Sender: TObject);
var
   i:integer;
begin
  if assigned(ListView1.Selected)then
                                     MaceItemCurrent(ListView1.Selected)
                                 else
                                     MessageBox(@rsLayerMustBeSelected[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
end;

procedure TLayerWindow.onCDItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  {if (state<>[cdsSelected,cdsFocused])and(state<>[]) then
  begin
  Sender.canvas.Brush.Color:=clHighlight;
  Sender.canvas.Font.Color:=clHighlightText;
  end;}
end;
procedure TLayerWindow.onCDSubItem(Sender: TCustomListView; Item: TListItem;
  SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
var
   colorindex,ll:integer;
   s:string;
   canv:TCanvas;
   //plp:PGDBLayerProp;
   //Dest: PChar;
   y{,i}:integer;
   textrect:TRect;
   ARect: TRect;
   BrushColor,FontColor:TColor;
   ts:TTextStyle;
const
     cellsize=13;
     textoffset=cellsize+5;
begin
     BrushColor:=TCustomListView(sender).canvas.Brush.Color;
     FontColor:=TCustomListView(sender).canvas.Font.Color;
     DefaultDraw:=false;
     case SubItem of
     6:
       begin
            ARect:=ListViewDrawSubItem(state,sender.canvas,Item,SubItem);
            {textrect}ARect := Item.DisplayRectSubItem( SubItem,drLabel);
            s:=strproc.Tria_AnsiToUtf8(PGDBLtypeProp(PGDBLayerProp(Item.Data)^.LT)^.name);
            canv:=Sender.canvas;
            drawLT{superdrawdraw}(canv,ARect,s,PGDBLayerProp(Item.Data)^.LT);
       end;
     5:
                      begin
                           colorindex:=PGDBLayerProp(Item.Data)^.color;
                           s:=GetColorNameFromIndex(colorindex);

                           ARect:=ListViewDrawSubItem(state,sender.canvas,Item,SubItem);

                           textrect := Item.DisplayRectSubItem( SubItem,drLabel);
                           //ARect.Left:=ARect.Left+2;
                           //textrect:=ARect;
                           ts := TCustomListView(Sender).Canvas.TextStyle;
                           ts.Layout := tlCenter;
                           //ts.SystemFont := false;
                           //ts.Alignment := taRightJustify;
                           if colorindex in [1..255] then
                            begin
                                 textrect.Left:=textrect.Left+textoffset;
                                 //DrawText(TCustomListView(sender).canvas.Handle,@s[1],length(s),textrect,DT_LEFT or DT_SINGLELINE or DT_VCENTER);
                                 TCustomListView(sender).canvas.TextRect(textrect,textrect.Left,0,s,ts);
                                 //TCustomListView(Sender).Canvas.TextRect(Retang,Retang.Left,0,Item.SubItems[4],estilo);
                                 if colorindex in [1..255] then
                                                begin
                                                     TCustomListView(sender).canvas.Brush.Color:=RGBToColor(palette[colorindex].r,palette[colorindex].g,palette[colorindex].b);
                                                end
                                            else
                                                TCustomListView(sender).canvas.Brush.Color:=clWhite;
                                 y:=(ARect.Top+ARect.Bottom-cellsize)div 2;
                                 TCustomListView(sender).canvas.Rectangle(ARect.Left,y,ARect.Left+cellsize,y+cellsize);
                                 if colorindex=7 then
                                                begin
                                                     TCustomListView(sender).canvas.Brush.Color:=clBlack;
                                                     TCustomListView(sender).canvas.Polygon([point(ARect.Left,y),point(ARect.Left+cellsize-1,y),point(ARect.Left+cellsize-1,y+cellsize-1)]);
                                                 end
                            end
                           else
                           DrawText(sender.canvas.Handle,@s[1],length(s),textrect,DT_LEFT or DT_SINGLELINE or DT_VCENTER);
                           //TCustomListView(sender).canvas.TextRect(textrect,textrect.Left,0,s,estilo);
                           end;
4,3,2,8:
                      begin
                           ARect:=ListViewDrawSubItem(state,TCustomListView(sender).canvas,Item,SubItem);
                           TListView(Sender).SmallImages.Draw(Sender.Canvas,ARect.Left+(ARect.Right-ARect.Left)div 2-8,ARect.Top,Item.SubItemImages[SubItem-1],gdeNormal)
                      end;
7:
                      begin
                           ARect:=ListViewDrawSubItem(state,TCustomListView(sender).canvas,Item,SubItem);
                           colorindex:=PGDBLayerProp(Item.Data)^.lineweight;
                           s:=GetLWNameFromLW(colorindex);
                           if colorindex<0 then
                                      ll:=0
                                  else
                                      ll:=30;
                            //ARect.Left:=ARect.Left+2;
                            drawLW(TCustomListView(sender).canvas,ARect,ll,(colorindex) div 10,s);
                       end;
                  else
                      DefaultDraw:=true;
                  end;
      TCustomListView(sender).canvas.Brush.Color:=BrushColor;
      TCustomListView(sender).canvas.Font.Color:=FontColor;

end;

procedure TLayerWindow.LWMouseUp(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
var
   li:TListItem;
   //ht:THitTests;
   //
   //pt: TPoint;
   col: Integer;
   //pos: integer;
begin
     if Button=mbLeft then
     begin
     if GetListItem(ListView1,x,y,li,col) then
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
procedure TLayerWindow.UpdateItem(Item: TListItem);
var
   pdwg:PTSimpleDrawing;
   //ir:itrec;
   plp:PGDBLayerProp;
   //s:ansistring;
begin
     pdwg:=gdb.GetCurrentDWG;
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
                 Item.SubItems.Add({'Continuous'}strproc.Tria_AnsiToUtf8(PGDBLtypeProp(plp^.LT)^.name));
                 Item.SubItems.Add(GetLWNameFromLW(plp^.lineweight));
                 Item.SubItems.Add('');
                 Item.SubItems.Add(strproc.Tria_AnsiToUtf8(plp^.desk));
                 if plp^._on then
                                 Item.SubItemImages[1]:=II_LayerOn
                             else
                                 Item.SubItemImages[1]:=II_LayerOff;

                 Item.SubItemImages[2]:=10;

                 if plp^._lock then
                                 Item.SubItemImages[3]:=II_LayerLock
                             else
                                 Item.SubItemImages[3]:=II_LayerUnLock;
                 if plp^._print then
                                 Item.SubItemImages[7]:=II_LayerPrint
                             else
                                 Item.SubItemImages[7]:=II_LayerUnPrint;
end;

procedure TLayerWindow.FormShow(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
   //s:ansistring;
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

            UpdateItem(li);

            //s:=plp^.GetFullName;
            //ListView1.Items.Add(li);
            plp:=pdwg^.LayerTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
end;

procedure TLayerWindow.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
     Sender:=Sender;
end;
procedure TLayerWindow.countlayer(player:PGDBLayerProp;out e,b:GDBInteger);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(player,e,@LayerCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(player,b,@LayerCounter);
end;

procedure TLayerWindow.ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
var
   player,pcreatedlayer:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
   layername:string;
   counter:integer;
   li:TListItem;
   inent,inblock:integer;
begin
     if selected then
     begin
          pdwg:=gdb.GetCurrentDWG;
          player:=(Item.Data);
          countlayer(player,inent,inblock);
          LayerDescLabel.Caption:=Format(rsLayerUsedIn,[player^.Name,inent,inblock]);
     end;
end;

procedure TLayerWindow.LayerAdd(Sender: TObject); // Процедура добавления слоя
var
   player,pcreatedlayer:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
   layername:string;
   counter:integer;
   li:TListItem;
   domethod,undomethod:tmethod;
begin
     pdwg:=gdb.GetCurrentDWG;
     if assigned(ListView1.Selected)then
                                        player:=(ListView1.Selected.Data)
                                    else
                                        player:=pdwg^.LayerTable.GetCurrentLayer;

     counter:=0;
     repeat
          inc(counter);
          layername:=inttostr(counter);
          if length(layername)<2 then
                                     layername:='0'+layername;
          layername:='Layer'+layername;
     until pdwg^.LayerTable.getIndex(layername)=-1;

     pdwg^.LayerTable.AddItem(name,pcreatedlayer);
     pcreatedlayer^:=player^;
     pcreatedlayer^.Name:=layername;

     domethod:=tmethod(@pdwg^.LayerTable.AddToArray);
     undomethod:=tmethod(@pdwg^.LayerTable.RemoveFromArray);
     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGObjectChangeCommand2(pcreatedlayer,tmethod(domethod),tmethod(undomethod))^ do
     begin
          AfterAction:=false;
          //comit;
     end;


     ListView1.BeginUpdate;
     li:=ListView1.Items.Add;
     li.Data:=pcreatedlayer;
     UpdateItem(li);
     ListView1.SortColumn:=-1;
     ListView1.SortColumn:=1;
     if assigned(ListView1.Selected)then
     begin
         ListView1.Selected.Selected:=false;
         ListView1.Selected:=nil;
     end;
     ListView1.Selected:=li;
     ListView1.EndUpdate;
end;

procedure TLayerWindow.LayerDelete(Sender: TObject); // Процедура удаления слоя
var
   player,pcreatedlayer:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
   layername:string;
   e,b:GDBInteger;
   li:TListItem;
   domethod,undomethod:tmethod;
begin
  //ShowError(rsNotYetImplemented);
  pdwg:=gdb.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     begin
                                     player:=(ListView1.Selected.Data);
                                     countlayer(player,e,b);
                                     if (e+b)>0 then
                                                  begin
                                                       ShowError(rsUnableDelUsedLayer);
                                                       exit;
                                                  end;

                                     domethod:=tmethod(@pdwg^.LayerTable.RemoveFromArray);
                                     undomethod:=tmethod(@pdwg^.LayerTable.AddToArray);
                                     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGObjectChangeCommand2(player,tmethod(domethod),tmethod(undomethod))^ do
                                     begin
                                          AfterAction:=false;
                                          comit;
                                     end;


                                     //pdwg^.LayerTable.eraseobj(player);
                                     ListView1.Items.Delete(ListView1.Items.IndexOf(ListView1.Selected));
                                     LayerDescLabel.Caption:='';
                                     end
                                 else
                                     ShowError(rsLayerMustBeSelected);
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

procedure TLayerWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     Aply(nil);
end;

end.

