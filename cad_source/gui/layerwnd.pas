unit LayerWnd;
{$INCLUDE def.inc}
{$mode objfpc}{$H+}

interface

uses
  gdbpalette,usuptypededitors,LMessages,selectorwnd,ugdbltypearray,ugdbutil,log,lineweightwnd,colorwnd,ugdbsimpledrawing,zcadsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, Dialogs,GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype, ActnList,

  gdbobjectsconstdef,UGDBLayerArray,UGDBDescriptor,gdbase,gdbasetypes,varmandef,

  zcadinterface, zcadstrconsts, strproc, shared, UBaseTypeDescriptor,
  imagesmanager, usupportgui, ZListView;

const
     NameColumn=0;
     OnColumn=1;
     FrezeColumn=2;
     LockColumn=3;
     ColorColumn=4;
     LineTypeColumn=5;
     LineWeightColumn=6;
     PlotColumn=7;
     DescColumn=8;

     ColumnCount=8+1;

type

  { TTextStylesWindow }

  { TLayerWindow }

  TLayerWindow = class(TForm)
    RefreshLayers: TAction;
    AddLayer: TAction;
    DelLayer: TAction;
    MkCurrentLayer: TAction;
    PurgeLayers: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    ButtonApplyClose: TBitBtn;
    Button_Apply: TBitBtn;
    LayerDescLabel: TLabel;
    ListView1: TZListView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure LayerAdd(Sender: TObject);
    procedure LayerDelete(Sender: TObject);
    procedure _PurgeLayers(Sender: TObject);
    procedure doLayerDelete(ProcessedItem:TListItem);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure RefreshListItems(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MkCurrent(Sender: TObject);
    procedure MaceItemCurrent(ListItem:TListItem);
    procedure countlayer(player:PGDBLayerProp;out e,b:GDBInteger);

    procedure CreateUndoStartMarkerNeeded;
    procedure CreateUndoEndMarkerNeeded;
  private
    changedstamp:boolean;
    //PEditor:TPropEditor;
    EditedItem:TListItem;
    SupportTypedEditors:TSupportTypedEditors;
    IsUndoEndMarkerCreated:boolean;
    { private declarations }
  public
    { public declarations }

    {layer name handle procedures}
    function createnameeditor(Item: TListItem;r: TRect):boolean;
    function GetLayerName(Item: TListItem):string;
    {layer lock handle procedures}
    function IsLayerLock(Item: TListItem):boolean;
    function LayerLockClick(Item: TListItem;r: TRect):boolean;
    {layer on handle procedures}
    function IsLayerOn(Item: TListItem):boolean;
    function LayerOnClick(Item: TListItem;r: TRect):boolean;
    {layer freze handle procedures}
    function IsLayerFreze(Item: TListItem):boolean;
    {layer plot handle procedures}
    function IsLayerPlot(Item: TListItem):boolean;
    function LayerPlotClick(Item: TListItem;r: TRect):boolean;
    {layer color handle procedures}
    procedure ColorSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
    function GetColorName(Item: TListItem):string;
    function LayerColorClick(Item: TListItem;r: TRect):boolean;
    {layer LineType handle procedures}
    procedure LtSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
    function GetLineTypeName(Item: TListItem):string;
    function LayerLTClick(Item: TListItem;r: TRect):boolean;
    {layer LineWidth handle procedures}
    procedure LWSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
    function GetLineWeightName(Item: TListItem):string;
    function LayerLWClick(Item: TListItem;r: TRect):boolean;
    {layer description handle procedures}
    function createdesceditor(Item: TListItem;r: TRect):boolean;
    function GetDescName(Item: TListItem):string;

    function IsShortcut(var Message: TLMKey): boolean; override;
  end;

var
  LayerWindow: TLayerWindow;
implementation
uses
    mainwindow;
{$R *.lfm}
procedure TLayerWindow.CreateUndoStartMarkerNeeded;
begin
  if not IsUndoEndMarkerCreated then
   begin
    IsUndoEndMarkerCreated:=true;
    ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushStartMarker('Change layers');
   end;
end;
procedure TLayerWindow.CreateUndoEndMarkerNeeded;
begin
  if IsUndoEndMarkerCreated then
   begin
    IsUndoEndMarkerCreated:=false;
    ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushEndMarker;
   end;
end;

function TLayerWindow.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,ActiveControl,nil,OldFunction);
end;

{layer name handle procedures}
function TLayerWindow.createnameeditor(Item: TListItem;r: TRect):boolean;
begin
  //createeditor(Item,r,@PGDBLayerProp(Item.Data)^.Name);
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBLayerProp(Item.Data)^.Name,'GDBAnsiString',@CreateUndoStartMarkerNeeded);
end;
function TLayerWindow.GetLayerName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBLayerProp(Item.Data)^.Name);
end;
{layer lock handle procedures}
function TLayerWindow.IsLayerLock(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._lock;
end;
function TLayerWindow.LayerLockClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(PGDBLayerProp(Item.Data)^._lock)^ do
     begin
       PGDBLayerProp(Item.Data)^._lock:=not PGDBLayerProp(Item.Data)^._lock;
       ComitFromObj;
     end;
end;
{layer on handle procedures}
function TLayerWindow.IsLayerOn(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._on;
end;
function TLayerWindow.LayerOnClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(PGDBLayerProp(Item.Data)^._on)^ do
     begin
       PGDBLayerProp(Item.Data)^._on:=not PGDBLayerProp(Item.Data)^._on;
       ComitFromObj;
     end;
end;
{layer freze handle procedures}
function TLayerWindow.IsLayerFreze(Item: TListItem):boolean;
begin
     result:=false;
end;
{layer plot handle procedures}
function TLayerWindow.IsLayerPlot(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._print;
end;
function TLayerWindow.LayerPlotClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(PGDBLayerProp(Item.Data)^._print)^ do
     begin
       PGDBLayerProp(Item.Data)^._print:=not PGDBLayerProp(Item.Data)^._print;
       ComitFromObj;
     end;
end;
{layer color handle procedures}
procedure TLayerWindow.ColorSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
var
   colorindex:integer;
   s:string;
   y:integer;
   textrect:TRect;
   ARect: TRect;
   ts:TTextStyle;
const
     cellsize=13;
     textoffset=cellsize+5;
begin
  colorIndex:=PGDBLayerProp(Item.Data)^.color;
  s:=GetColorNameFromIndex(colorindex);

  ARect:=ListViewDrawSubItem(state,aCanvas,Item,SubItem);

  textrect := Item.DisplayRectSubItem( SubItem,drLabel);
  ts := aCanvas.TextStyle;
  ts.Layout := tlCenter;
  if colorindex in [1..255] then
   begin
        textrect.Left:=textrect.Left+textoffset;
        aCanvas.TextRect(textrect,textrect.Left,0,s,ts);
        if colorindex in [1..255] then
         begin
           aCanvas.Brush.Color:=RGBToColor(palette[colorindex].RGB.r,palette[colorindex].RGB.g,palette[colorindex].RGB.b);
         end
        else
         aCanvas.Brush.Color:=clWhite;
        y:=(ARect.Top+ARect.Bottom-cellsize)div 2;
        aCanvas.Rectangle(ARect.Left,y,ARect.Left+cellsize,y+cellsize);
        if colorindex=7 then
         begin
           aCanvas.Brush.Color:=clBlack;
           aCanvas.Polygon([point(ARect.Left,y),point(ARect.Left+cellsize-1,y),point(ARect.Left+cellsize-1,y+cellsize-1)]);
         end
   end
  else
   DrawText(aCanvas.Handle,@s[1],length(s),textrect,DT_LEFT or DT_SINGLELINE or DT_VCENTER);
end;
function TLayerWindow.GetColorName(Item: TListItem):string;
begin
     result:=GetColorNameFromIndex(PGDBLayerProp(Item.Data)^.color);
end;

function TLayerWindow.LayerColorClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
  if not assigned(ColorSelectWND)then
    Application.CreateForm(TColorSelectWND, ColorSelectWND);
  if assigned(ShowAllCursorsProc) then
    ShowAllCursorsProc;
  mr:=ColorSelectWND.run(PGDBLayerProp(Item.Data)^.color,false);
  if assigned(RestoreAllCursorsProc) then
    RestoreAllCursorsProc;
  if mr=mrOk then
    begin
      if PGDBLayerProp(Item.Data)^.color<>ColorSelectWND.ColorInfex then
        begin
           CreateUndoStartMarkerNeeded;
           with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(PGDBLayerProp(Item.Data)^.color)^ do
           begin
             PGDBLayerProp(Item.Data)^.color:=ColorSelectWND.ColorInfex;
             ComitFromObj;
           end;
          //Item.SubItems[4]:=GetColorNameFromIndex(ColorSelectWND.ColorInfex);
          result:=true;
        end;
    end;
  freeandnil(ColorSelectWND);
end;
{layer LineType handle procedures}
procedure TLayerWindow.LtSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
var
   colorindex:integer;
   s:string;
   y:integer;
   textrect:TRect;
   ARect: TRect;
   ts:TTextStyle;
begin
ARect:=ListViewDrawSubItem(state,aCanvas,Item,SubItem);
ARect := Item.DisplayRectSubItem( SubItem,drLabel);
s:=strproc.Tria_AnsiToUtf8(GetLTName(PGDBLayerProp(Item.Data)^.LT));
drawLT(aCanvas,ARect,s,PGDBLayerProp(Item.Data)^.LT);
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
function TLayerWindow.GetLineTypeName(Item: TListItem):string;
begin
     result:=strproc.Tria_AnsiToUtf8(GetLTName(PGDBLayerProp(Item.Data)^.LT));
end;

function TLayerWindow.LayerLTClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
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
                      PGDBLayerProp(Item.Data)^.LT:=SelectorWindow.data;
                      result:=true;
                 end;
  freeandnil(SelectorWindow);
end;
{layer LineWidth handle procedures}
procedure TLayerWindow.LWSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
var
   colorindex,ll:integer;
   s:string;
   y:integer;
   textrect:TRect;
   ARect: TRect;
   ts:TTextStyle;
begin
  ARect:=ListViewDrawSubItem(state,aCanvas,Item,SubItem);
  colorindex:=PGDBLayerProp(Item.Data)^.lineweight;
  s:=GetLWNameFromLW(colorindex);
  if colorindex<0 then
             ll:=0
         else
             ll:=30;
   drawLW(aCanvas,ARect,ll,(colorindex) div 10,s);
end;
function TLayerWindow.GetLineWeightName(Item: TListItem):string;
begin
     result:=GetLWNameFromLW(PGDBLayerProp(Item.Data)^.lineweight);
end;

function TLayerWindow.LayerLWClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
  if not assigned(LineWeightSelectWND)then
  Application.CreateForm(TLineWeightSelectWND, LineWeightSelectWND);
  if assigned(ShowAllCursorsProc) then
                                      ShowAllCursorsProc;
  mr:=LineWeightSelectWND.run(PGDBLayerProp(Item.Data)^.lineweight,false);
  if assigned(RestoreAllCursorsProc) then
                                      RestoreAllCursorsProc;
  if mr=mrOk then
                 begin
                      PGDBLayerProp(Item.Data)^.lineweight:=LineWeightSelectWND.SelectedLW;
                      Item.SubItems[6]:=GetLWNameFromLW(LineWeightSelectWND.SelectedLW);
                      result:=true;
                 end;
  freeandnil(LineWeightSelectWND);
end;
{layer description handle procedures}
function TLayerWindow.createdesceditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBLayerProp(Item.Data)^.desk,'GDBAnsiString',@CreateUndoStartMarkerNeeded);
end;
function TLayerWindow.GetDescName(Item: TListItem):string;
begin
     result:=PGDBLayerProp(Item.Data)^.desk;
end;



procedure TLayerWindow.FormCreate(Sender: TObject);
begin
  ActionList1.Images:=IconList;
  ToolBar1.Images:=IconList;
  AddLayer.ImageIndex:=II_Plus;
  DelLayer.ImageIndex:=II_Minus;
  MkCurrentLayer.ImageIndex:=II_Ok;
  PurgeLayers.ImageIndex:=II_Purge;
  RefreshLayers.ImageIndex:=II_Refresh;

  SupportTypedEditors:=TSupportTypedEditors.create;
  SupportTypedEditors.OnUpdateEditedControl:=@ListView1.UpdateItem2;
  IsUndoEndMarkerCreated:=false;

ListView1.SmallImages:=IconList;
ListView1.DefaultItemIndex:=II_Ok;

setlength(ListView1.SubItems,ColumnCount);

with ListView1.SubItems[NameColumn] do
begin
     OnClick:=@createnameeditor;
     OnGetName:=@GetLayerName;
end;
with ListView1.SubItems[LockColumn] do
begin
     OnImageIndex:=II_LayerLock;
     OffImageIndex:=II_LayerUnLock;
     OnClick:=@LayerLockClick;
     IsOn:=@IsLayerLock;
end;
with ListView1.SubItems[FrezeColumn] do
begin
     OnImageIndex:=II_LayerFreze;
     OffImageIndex:=II_LayerUnFreze;
     IsOn:=@IsLayerFreze;
end;
with ListView1.SubItems[OnColumn] do
begin
     OnImageIndex:=II_LayerOn;
     OffImageIndex:=II_LayerOff;
     OnClick:=@LayerOnClick;
     IsOn:=@IsLayerOn;
end;
with ListView1.SubItems[ColorColumn] do
begin
     OnDraw:=@ColorSubitemDraw;
     OnClick:=@LayerColorClick;
     OnGetName:=@GetColorName;
end;
with ListView1.SubItems[LineTypeColumn] do
begin
     OnDraw:=@LtSubitemDraw;
     OnClick:=@LayerLTClick;
     OnGetName:=@GetLineTypeName;
end;
with ListView1.SubItems[LineWeightColumn] do
begin
     OnDraw:=@LWSubitemDraw;
     OnClick:=@LayerLWClick;
     OnGetName:=@GetLineWeightName;
end;
with ListView1.SubItems[PlotColumn] do
begin
     OnImageIndex:=II_LayerPrint;
     OffImageIndex:=II_LayerUnPrint;
     IsOn:=@IsLayerPlot;
     OnClick:=@LayerPlotClick;
end;
with ListView1.SubItems[DescColumn] do
begin
     OnClick:=@createdesceditor;
     OnGetName:=@GetDescName;
end;
end;
procedure TLayerWindow.MaceItemCurrent(ListItem:TListItem);
begin
     if ListView1.CurrentItem<>ListItem then
     begin
       CreateUndoStartMarkerNeeded;
     with PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(sysvar.dwg.DWG_CLayer^)^ do
     begin
          SysVar.dwg.DWG_CLayer^:={gdb.GetCurrentDWG^.LayerTable.GetIndexByPointer}(ListItem.Data);
          ComitFromObj;
     end;
     //ListItem.ImageIndex:=II_Ok;
     //ListView1.CurrentItem.ImageIndex:=-1;
     //ListView1.CurrentItem:=ListItem;
     if not PGDBLayerProp(ListItem.Data)^._on then
                                                   MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
     //invalidate;
     end;
end;
procedure TLayerWindow.MkCurrent(Sender: TObject);
begin
  if assigned(ListView1.Selected)then
                                     begin
                                     if ListView1.Selected<>ListView1.CurrentItem then
                                     begin
                                       MaceItemCurrent(ListView1.Selected);
                                       ListView1.MakeItemCorrent(ListView1.Selected);
                                       ListView1.UpdateItem2(ListView1.Selected);
                                     end;
                                     end
                                 else
                                     MessageBox(@rsLayerMustBeSelected[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
end;
procedure TLayerWindow.RefreshListItems(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
   li:TListItem;
begin
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.LayerTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;

            li.Data:=plp;

            ListView1.UpdateItem(li,gdb.GetCurrentDWG^.LayerTable.GetCurrentLayer);

            plp:=pdwg^.LayerTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
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
   player:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
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
   li:TListItem;
   domethod,undomethod:tmethod;
begin
     pdwg:=gdb.GetCurrentDWG;
     if assigned(ListView1.Selected)then
                                        player:=(ListView1.Selected.Data)
                                    else
                                        player:=pdwg^.LayerTable.GetCurrentLayer;

     layername:=pdwg^.LayerTable.GetFreeName(Tria_Utf8ToAnsi(rsNewLayerNameFormat),1);
     if layername='' then
     begin
       shared.ShowError(rsUnableSelectFreeLayerName);
       exit;
     end;

     pdwg^.LayerTable.AddItem(layername,pcreatedlayer);
     pcreatedlayer^:=player^;
     pcreatedlayer^.Name:=layername;

     domethod:=tmethod(@pdwg^.LayerTable.AddToArray);
     undomethod:=tmethod(@pdwg^.LayerTable.RemoveFromArray);
     with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGObjectChangeCommand2(pcreatedlayer,tmethod(domethod),tmethod(undomethod))^ do
     begin
          AfterAction:=false;
          //comit;
     end;

     ListView1.AddCreatedItem(pcreatedlayer,gdb.GetCurrentDWG^.LayerTable.GetCurrentLayer);
end;
procedure TLayerWindow.doLayerDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   player:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  player:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.LayerTable.RemoveFromArray);
  undomethod:=tmethod(@pdwg^.LayerTable.AddToArray);
  CreateUndoStartMarkerNeeded;
  with ptdrawing(pdwg)^.UndoStack.PushCreateTGObjectChangeCommand2(player,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;
procedure TLayerWindow._PurgeLayers(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable,indimstyles:GDBInteger;
   PCurrentLayer:PGDBLayerProp;
begin
     i:=0;
     purgedcounter:=0;
     PCurrentLayer:=gdb.GetCurrentDWG^.LayerTable.GetCurrentLayer;
     if ListView1.Items.Count>0 then
     begin
       repeat
          ProcessedItem:=ListView1.Items[i];
          countlayer(ProcessedItem.Data,inEntities,inBlockTable);
          if (ProcessedItem.Data<>PCurrentLayer)and((inEntities+inBlockTable)=0) then
          begin
           doLayerDelete(ProcessedItem);
           inc(purgedcounter);
          end
          else
           inc(i);
       until i>=ListView1.Items.Count;
     end;
     LayerDescLabel.Caption:=Format(rsCountTStylesPurged,[purgedcounter]);
end;

procedure TLayerWindow.LayerDelete(Sender: TObject); // Процедура удаления слоя
var
   player:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
   e,b:GDBInteger;
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

                                     doLayerDelete(ListView1.Selected);

                                     LayerDescLabel.Caption:='';
                                     end
                                 else
                                     ShowError(rsLayerMustBeSelected);
end;

procedure TLayerWindow.AplyClose(Sender: TObject);
begin
     close;
end;

procedure TLayerWindow.Aply(Sender: TObject) ;
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
     CreateUndoEndMarkerNeeded;
     SupportTypedEditors.Free;
end;

end.

