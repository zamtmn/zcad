unit uzcflayers;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  UGDBNamedObjectsArray,uzcutils,gzundoCmdChgData,gzundoCmdChgMethods,uzcdrawing,uzepalette,uzcsuptypededitors,LMessages,uzcfselector,uzestyleslinetypes,uzeutils,uzclog,uzcflineweights,uzcfcolors,uzedrawingsimple,uzcsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype, ActnList,

  uzcgui2linetypes,uzeconsts,uzestyleslayers,uzcdrawings,uzbtypes,varmandef,

  uzcinterface, uzcstrconsts, uzbstrproc,UBaseTypeDescriptor,
  gzctnrVectorTypes,uzcimagesmanager, usupportgui, ZListView, uzcuitypes;

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

  { TLayersForm }

  TLayersForm = class(TForm)
    CoolBar1: TCoolBar;
    Panel1: TPanel;
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
    procedure countlayer(player:PGDBLayerProp;out e,b:Integer);

    procedure CreateUndoStartMarkerNeeded;
    procedure CreateUndoEndMarkerNeeded;
  private
    changedstamp:boolean;
    //PEditor:TPropEditor;
    //EditedItem:TListItem;
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
  LayersForm: TLayersForm;
implementation
{$R *.lfm}
procedure TLayersForm.CreateUndoStartMarkerNeeded;
begin
  zcPlaceUndoStartMarkerIfNeed(IsUndoEndMarkerCreated,'Change layers');
end;
procedure TLayersForm.CreateUndoEndMarkerNeeded;
begin
  zcPlaceUndoEndMarkerIfNeed(IsUndoEndMarkerCreated);
end;

function TLayersForm.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,ActiveControl,nil,OldFunction,nil);
end;

{layer name handle procedures}
function TLayersForm.createnameeditor(Item: TListItem;r: TRect):boolean;
begin
  //createeditor(Item,r,@PGDBLayerProp(Item.Data)^.Name);
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBLayerProp(Item.Data)^.Name,'AnsiString',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat);
end;
function TLayersForm.GetLayerName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBLayerProp(Item.Data)^.Name);
end;
{layer lock handle procedures}
function TLayersForm.IsLayerLock(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._lock;
end;
function TLayersForm.LayerLockClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBLayerProp(Item.Data)^._lock,nil,nil) do
     begin
       PGDBLayerProp(Item.Data)^._lock:=not PGDBLayerProp(Item.Data)^._lock;
       ComitFromObj;
     end;
end;
{layer on handle procedures}
function TLayersForm.IsLayerOn(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._on;
end;
function TLayersForm.LayerOnClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBLayerProp(Item.Data)^._on,nil,nil) do
     begin
       PGDBLayerProp(Item.Data)^._on:=not PGDBLayerProp(Item.Data)^._on;
       ComitFromObj;
     end;
end;
{layer freze handle procedures}
function TLayersForm.IsLayerFreze(Item: TListItem):boolean;
begin
     result:=false;
end;
{layer plot handle procedures}
function TLayersForm.IsLayerPlot(Item: TListItem):boolean;
begin
     result:=PGDBLayerProp(Item.Data)^._print;
end;
function TLayersForm.LayerPlotClick(Item: TListItem;r: TRect):boolean;
begin
     result:=true;
     CreateUndoStartMarkerNeeded;
     with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBLayerProp(Item.Data)^._print,nil,nil) do
     begin
       PGDBLayerProp(Item.Data)^._print:=not PGDBLayerProp(Item.Data)^._print;
       ComitFromObj;
     end;
end;
{layer color handle procedures}
procedure TLayersForm.ColorSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
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
function TLayersForm.GetColorName(Item: TListItem):string;
begin
     result:=GetColorNameFromIndex(PGDBLayerProp(Item.Data)^.color);
end;

function TLayersForm.LayerColorClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
  if not assigned(ColorSelectForm)then
    Application.CreateForm(TColorSelectForm, ColorSelectForm);
  ZCMsgCallBackInterface.Do_BeforeShowModal(ColorSelectForm);
  mr:=ColorSelectForm.run(PGDBLayerProp(Item.Data)^.color,false);
  ZCMsgCallBackInterface.Do_AfterShowModal(ColorSelectForm);
  if mr=ZCmrOK then
    begin
      if PGDBLayerProp(Item.Data)^.color<>ColorSelectForm.ColorInfex then
        begin
           CreateUndoStartMarkerNeeded;
           with TGDBByteChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBLayerProp(Item.Data)^.color,nil,nil) do
           begin
             PGDBLayerProp(Item.Data)^.color:=ColorSelectForm.ColorInfex;
             ComitFromObj;
           end;
          //Item.SubItems[4]:=GetColorNameFromIndex(ColorSelectForm.ColorInfex);
          result:=true;
        end;
    end;
  freeandnil(ColorSelectForm);
end;
{layer LineType handle procedures}
procedure TLayersForm.LtSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
var
   //colorindex:integer;
   s:string;
   //y:integer;
   //textrect:TRect;
   ARect: TRect;
   //ts:TTextStyle;
begin
ARect:=ListViewDrawSubItem(state,aCanvas,Item,SubItem);
ARect := Item.DisplayRectSubItem( SubItem,drLabel);
s:=Tria_AnsiToUtf8(GetLTName(PGDBLayerProp(Item.Data)^.LT));
drawLT(aCanvas,ARect,s,PGDBLayerProp(Item.Data)^.LT);
end;
procedure FillSelector(SelectorWindow: TSelectorForm);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
begin
     SelectorWindow.StartAddItems;
     pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            if (pltp^.Mode<>TLTByBlock)and(pltp^.Mode<>TLTByLayer)then
                SelectorWindow.AddItem(Tria_AnsiToUtf8(pltp^.Name),Tria_AnsiToUtf8(pltp^.desk),pltp);

            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;
     SelectorWindow.EndAddItems;
end;
function TLayersForm.GetLineTypeName(Item: TListItem):string;
begin
     result:=Tria_AnsiToUtf8(GetLTName(PGDBLayerProp(Item.Data)^.LT));
end;

function TLayersForm.LayerLTClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
  if not assigned(SelectorForm)then
  Application.CreateForm(TSelectorForm, SelectorForm);
  FillSelector(SelectorForm);
  ZCMsgCallBackInterface.Do_BeforeShowModal(SelectorForm);
  mr:=SelectorForm.run;
  ZCMsgCallBackInterface.Do_AfterShowModal(SelectorForm);
  if mr=ZCmrOk then
                 begin
                      PGDBLayerProp(Item.Data)^.LT:=SelectorForm.data;
                      result:=true;
                 end;
  freeandnil(SelectorForm);
end;
{layer LineWidth handle procedures}
procedure TLayersForm.LWSubitemDraw(aCanvas:TCanvas; Item: TListItem; SubItem:Integer; State: TCustomDrawState);
var
   colorindex,ll:integer;
   s:string;
   //y:integer;
   //textrect:TRect;
   ARect: TRect;
   //ts:TTextStyle;
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
function TLayersForm.GetLineWeightName(Item: TListItem):string;
begin
     result:=GetLWNameFromLW(PGDBLayerProp(Item.Data)^.lineweight);
end;

function TLayersForm.LayerLWClick(Item: TListItem;r: TRect):boolean;
var
   mr:integer;
begin
  if not assigned(LineWeightSelectForm)then
  Application.CreateForm(TLineWeightSelectForm, LineWeightSelectForm);
  ZCMsgCallBackInterface.Do_BeforeShowModal(LineWeightSelectForm);
  mr:=LineWeightSelectForm.run(PGDBLayerProp(Item.Data)^.lineweight,false);
  ZCMsgCallBackInterface.Do_AfterShowModal(LineWeightSelectForm);
  if mr=ZCmrOk then
                 begin
                      PGDBLayerProp(Item.Data)^.lineweight:=LineWeightSelectForm.SelectedLW;
                      Item.SubItems[6]:=GetLWNameFromLW(LineWeightSelectForm.SelectedLW);
                      result:=true;
                 end;
  freeandnil(LineWeightSelectForm);
end;
{layer description handle procedures}
function TLayersForm.createdesceditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBLayerProp(Item.Data)^.desk,'AnsiString',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat);
end;
function TLayersForm.GetDescName(Item: TListItem):string;
begin
     result:=PGDBLayerProp(Item.Data)^.desk;
end;



procedure TLayersForm.FormCreate(Sender: TObject);
begin
  ActionList1.Images:=ImagesManager.IconList;
  ToolBar1.Images:=ImagesManager.IconList;
  AddLayer.ImageIndex:=ImagesManager.GetImageIndex('plus');
  DelLayer.ImageIndex:=ImagesManager.GetImageIndex('minus');
  MkCurrentLayer.ImageIndex:=ImagesManager.GetImageIndex('ok');;
  PurgeLayers.ImageIndex:=ImagesManager.GetImageIndex('Purge');
  RefreshLayers.ImageIndex:=ImagesManager.GetImageIndex('Refresh');

  SupportTypedEditors:=TSupportTypedEditors.create;
  SupportTypedEditors.OnUpdateEditedControl:=@ListView1.UpdateItem2;
  IsUndoEndMarkerCreated:=false;

ListView1.SmallImages:=ImagesManager.IconList;
ListView1.DefaultItemIndex:=ImagesManager.GetImageIndex('ok');;

setlength(ListView1.SubItems,ColumnCount);

with ListView1.SubItems[NameColumn] do
begin
     OnClick:=@createnameeditor;
     OnGetName:=@GetLayerName;
end;
with ListView1.SubItems[LockColumn] do
begin
     OnImageIndex:=ImagesManager.GetImageIndex('lock');
     OffImageIndex:=ImagesManager.GetImageIndex('unlock');
     OnClick:=@LayerLockClick;
     IsOn:=@IsLayerLock;
end;
with ListView1.SubItems[FrezeColumn] do
begin
     OnImageIndex:=ImagesManager.GetImageIndex('freze');;
     OffImageIndex:=ImagesManager.GetImageIndex('unfreze');
     IsOn:=@IsLayerFreze;
end;
with ListView1.SubItems[OnColumn] do
begin
     OnImageIndex:=ImagesManager.GetImageIndex('on');
     OffImageIndex:=ImagesManager.GetImageIndex('off');
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
     OnImageIndex:=ImagesManager.GetImageIndex('print');
     OffImageIndex:=ImagesManager.GetImageIndex('unprint');
     IsOn:=@IsLayerPlot;
     OnClick:=@LayerPlotClick;
end;
with ListView1.SubItems[DescColumn] do
begin
     OnClick:=@createdesceditor;
     OnGetName:=@GetDescName;
end;
  Panel1.Constraints.MinWidth:=ToolBar1.Left+ToolButton6.Left+ToolButton6.Width+CoolBar1.GrabWidth;
end;
procedure TLayersForm.MaceItemCurrent(ListItem:TListItem);
begin
     if ListView1.CurrentItem<>ListItem then
     begin
       CreateUndoStartMarkerNeeded;
     with TGDBPoinerChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,sysvar.dwg.DWG_CLayer^,nil,nil) do
     begin
          SysVar.dwg.DWG_CLayer^:={drawings.GetCurrentDWG^.LayerTable.GetIndexByPointer}(ListItem.Data);
          ComitFromObj;
     end;
     //ListItem.ImageIndex:=II_Ok;
     //ListView1.CurrentItem.ImageIndex:=-1;
     //ListView1.CurrentItem:=ListItem;
     if not PGDBLayerProp(ListItem.Data)^._on then
                                                   ZCMsgCallBackInterface.TextMessage(rsCurrentLayerOff,TMWOMessageBox);
     //invalidate;
     end;
end;
procedure TLayersForm.MkCurrent(Sender: TObject);
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
                                     ZCMsgCallBackInterface.TextMessage(rsLayerMustBeSelected,TMWOMessageBox);
end;
procedure TLayersForm.RefreshListItems(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
   li:TListItem;
begin
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.LayerTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;

            li.Data:=plp;

            ListView1.UpdateItem(li,drawings.GetCurrentDWG^.GetCurrentLayer);

            plp:=pdwg^.LayerTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
end;
procedure TLayersForm.countlayer(player:PGDBLayerProp;out e,b:Integer);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(player,e,@LayerCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(player,b,@LayerCounter);
end;

procedure TLayersForm.ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
var
   player:PGDBLayerProp;
   //pdwg:PTSimpleDrawing;
   inent,inblock:integer;
begin
     if selected then
     begin
          //pdwg:=drawings.GetCurrentDWG;
          player:=(Item.Data);
          countlayer(player,inent,inblock);
          LayerDescLabel.Caption:=Format(rsLayerUsedIn,[Tria_AnsiToUtf8(player^.Name),inent,inblock]);
     end;
end;

procedure TLayersForm.LayerAdd(Sender: TObject); // Процедура добавления слоя
var
   player,pcreatedlayer:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
   layername:string;
   //li:TListItem;
   domethod,undomethod:tmethod;
begin
     pdwg:=drawings.GetCurrentDWG;
     if assigned(ListView1.Selected)then
                                        player:=(ListView1.Selected.Data)
                                    else
                                        player:=pdwg^.GetCurrentLayer;

     layername:=pdwg^.LayerTable.GetFreeName(Tria_Utf8ToAnsi(rsNewLayerNameFormat),1);
     if layername='' then
     begin
       ZCMsgCallBackInterface.TextMessage(rsUnableSelectFreeLayerName,TMWOShowError);
       exit;
     end;
     if pdwg^.LayerTable.AddItem(layername,pcreatedlayer)=IsCreated then
      pcreatedlayer^.initnul;
     pcreatedlayer^:=player^;
     pcreatedlayer^.Name:=layername;

     domethod:=tmethod(@pdwg^.LayerTable.PushBackData);
     undomethod:=tmethod(@pdwg^.LayerTable.RemoveDataFromArray);
     with specialize GUCmdChgMethods<PGDBLayerProp>.CreateAndPush(pcreatedlayer,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,nil) do
     begin
          //AfterAction:=false;
          //comit;
     end;

     ListView1.AddCreatedItem(pcreatedlayer,drawings.GetCurrentDWG^.GetCurrentLayer);
end;
procedure TLayersForm.doLayerDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   player:PGDBLayerProp;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  player:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.LayerTable.RemoveDataFromArray);
  undomethod:=tmethod(@pdwg^.LayerTable.PushBackData);
  CreateUndoStartMarkerNeeded;
  with specialize GUCmdChgMethods<PGDBLayerProp>.CreateAndPush(player,domethod,undomethod,PTZCADDrawing(pdwg)^.UndoStack,nil) do
  begin
       //AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;
procedure TLayersForm._PurgeLayers(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable{,indimstyles}:Integer;
   PCurrentLayer:PGDBLayerProp;
begin
     i:=0;
     purgedcounter:=0;
     PCurrentLayer:=drawings.GetCurrentDWG^.GetCurrentLayer;
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

procedure TLayersForm.LayerDelete(Sender: TObject); // Процедура удаления слоя
var
   player:PGDBLayerProp;
   //pdwg:PTSimpleDrawing;
   e,b:Integer;
   //domethod,undomethod:tmethod;
begin
  //TMWOShowError(rsNotYetImplemented);
  //pdwg:=drawings.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     begin
                                     player:=(ListView1.Selected.Data);
                                     countlayer(player,e,b);
                                     if (e+b)>0 then
                                                  begin
                                                       ZCMsgCallBackInterface.TextMessage(rsUnableDelUsedLayer,TMWOShowError);
                                                       exit;
                                                  end;

                                     doLayerDelete(ListView1.Selected);

                                     LayerDescLabel.Caption:='';
                                     end
                                 else
                                     ZCMsgCallBackInterface.TextMessage(rsLayerMustBeSelected,TMWOShowError);
end;

procedure TLayersForm.AplyClose(Sender: TObject);
begin
     close;
end;

procedure TLayersForm.Aply(Sender: TObject) ;
begin
     if changedstamp then
     begin
       ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
       //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
       zcRedrawCurrentDrawing;
     end;
end;

procedure TLayersForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     Aply(nil);
     CreateUndoEndMarkerNeeded;
     SupportTypedEditors.Free;
end;

end.

