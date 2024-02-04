{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
unit uzcfdimstyles;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzcutils,gzundoCmdChgData,gzundoCmdChgMethods,uzcdrawing,LMessages,
  uzclog,uzedrawingsimple,uzcsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype, ActnList,

  uzeconsts,uzestylestexts,uzcdrawings,uzbtypes,varmandef,
  uzcsuptypededitors,

  uzestylesdim, uzeentdimension,

  uzbpaths,uzcinterface, uzcstrconsts,uzbstrproc,UBaseTypeDescriptor,
  uzcimagesmanager, usupportgui, ZListView,uzefontmanager,varman,uzctnrvectorstrings,
  gzctnrVectorTypes,uzeentity;

const
     NameColumn=0;
     LinearScaleColumn=1;
     TextStyleNameColumn=2;
     TextHeightColumn=3;
     DIMBLK1Column=4;
     DIMBLK2Column=5;
     DIMLDRBLKColumn=6;
     DIMASZColumn=7;

     ColumnCount=7+1;

type
  //TFTFilter=(TFTF_All,TFTF_TTF,TFTF_SHX);

  { TDimStylesForm}

  TDimStylesForm= class(TForm)
    CoolBar1: TCoolBar;
    DelStyle: TAction;
    MkCurrentStyle: TAction;
    InspectListItem: TAction;
    Panel1: TPanel;
    PurgeStyles: TAction;
    RefreshStyles: TAction;
    AddStyle: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    ButtonApplyClose: TBitBtn;
    DescLabel: TLabel;
    ListView1: TZListView;
    ToolBar1: TToolBar;
    ToolButton_Inspect: TToolButton;
    ToolButton_Add: TToolButton;
    ToolButton_Delete: TToolButton;
    ToolButton_MkCurrent: TToolButton;
    Separator1: TToolButton;
    ToolButton_Purge: TToolButton;
    ToolButton_Refresh: TToolButton;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure DimStyleInspect(Sender: TObject);
    procedure PurgeTStyles(Sender: TObject);
    procedure DimStyleAdd(Sender: TObject);
    procedure DeleteItem(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RefreshListitems(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MkCurrent(Sender: TObject);
    procedure MaceItemCurrent(ListItem:TListItem);
    procedure FillTextStyleSelector(currentitem:string;currentitempstyle:PGDBTextStyle);
    procedure onrsz(Sender: TObject);
    procedure countstyle(pdimstyle:PGDBDimStyle;out e,b,inDimStyles:Integer);
  private
    changedstamp:boolean;
    //EditedItem:TListItem;
    FontsSelector:TEnumData;
    SupportTypedEditors:TSupportTypedEditors;
    FontChange:boolean;
    IsUndoEndMarkerCreated:boolean;
    { private declarations }
    procedure UpdateItem2(Item:TObject);
    procedure CreateUndoStartMarkerNeeded;
    procedure CreateUndoEndMarkerNeeded;
    procedure doTStyleDelete(ProcessedItem:TListItem);

  public
    { public declarations }
    function IsShortcut(var Message: TLMKey): boolean; override;

    {Style name handle procedures}
    function GetStyleName(Item: TListItem):string;
    function CreateNameEditor(Item: TListItem;r: TRect):boolean;
    {Font name handle procedures}
    function GetTextStyleName(Item: TListItem):string;
    function CreateTextStyleNameEditor(Item: TListItem;r: TRect):boolean;
    //{Font path handle procedures}
    //function GetFontPath(Item: TListItem):string;
    {LinearScale handle procedures}
    function GetLinearScale(Item: TListItem):string;
    function CreateLinearScaleEditor(Item: TListItem;r: TRect):boolean;
    {TextHeight handle procedures}
    function GetTextHeight(Item: TListItem):string;
    function CreateTextHeightEditor(Item: TListItem;r: TRect):boolean;
    function GetDIMBLK1(Item: TListItem):string;
    function CreateDIMBLK1Editor(Item: TListItem;r: TRect):boolean;
    function GetDIMBLK2(Item: TListItem):string;
    function CreateDIMBLK2Editor(Item: TListItem;r: TRect):boolean;
    function GetDIMLDRBLK (Item: TListItem):string;
    function CreateDIMLDRBLKEditor(Item: TListItem;r: TRect):boolean;
    function GetDIMASZ (Item: TListItem):string;
    function CreateDIMASZEditor(Item: TListItem;r: TRect):boolean;
  end;

var
  DimStylesForm: TDimStylesForm;
  //FontsFilter:TFTFilter;
implementation
{$R *.lfm}
uses
  uzcfdimedit;

function TDimStylesForm.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,ActiveControl,nil,OldFunction,nil);
end;

procedure TDimStylesForm.CreateUndoStartMarkerNeeded;
begin
  zcPlaceUndoStartMarkerIfNeed(IsUndoEndMarkerCreated,'Change text styles');
end;
procedure TDimStylesForm.CreateUndoEndMarkerNeeded;
begin
  zcPlaceUndoEndMarkerIfNeed(IsUndoEndMarkerCreated);
end;

procedure TDimStylesForm.UpdateItem2(Item:TObject);
var
   ir:itrec;
   currentextstyle,plp:PGDBTextStyle;
begin
     if FontChange then
     begin
       plp:=drawings.GetCurrentDWG^.TextStyleTable.beginiterate(ir);
       if plp<>nil then
       repeat
            if plp^.Name=pstring(FontsSelector.Enums.getDataMutable(FontsSelector.Selected))^ then
             currentextstyle:=plp;
            plp:=drawings.GetCurrentDWG^.TextStyleTable.iterate(ir);
       until plp=nil;
          if  currentextstyle<>PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY then
          begin
                 ZCMsgCallBackInterface.TextMessage(pstring(FontsSelector.Enums.getDataMutable(FontsSelector.Selected))^,TMWOHistoryOut);

               CreateUndoStartMarkerNeeded;
               with TGDBPoinerChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pointer(PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY),nil,nil) do
               begin
               PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY:=currentextstyle;
               ComitFromObj;
               end;
          end;
     end;
     ListView1.UpdateItem2(TListItem(Item));
     FontChange:=false;
end;

{Style name handle procedures}
function TDimStylesForm.GetStyleName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBDimStyle(Item.Data)^.Name);
end;
function TDimStylesForm.CreateNameEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Name,'AnsiString',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
{Font name handle procedures}
function TDimStylesForm.GetTextStyleName(Item: TListItem):string;
begin
  //result:=ExtractFileName(PGDBDimStyle(Item.Data)^.pfont^.fontfile);
  result:=ExtractFileName(PGDBDimStyle(Item.Data)^.Text.DIMTXSTY^.Name);
end;
function TDimStylesForm.CreateTextStyleNameEditor(Item: TListItem;r: TRect):boolean;
begin
  //FillFontsSelector(PGDBTextStyle(Item.Data)^.pfont^.fontfile,PGDBTextStyle(Item.Data)^.pfont);
  FillTextStyleSelector(PGDBDimStyle(Item.Data)^.Text.DIMTXSTY^.Name,PGDBDimStyle(Item.Data)^.Text.DIMTXSTY);
  FontChange:=true;
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,FontsSelector,'TEnumData',nil,r.Bottom-r.Top,drawings.GetUnitsFormat,false)
end;
//{Font path handle procedures}
//function TDimStylesForm.GetFontPath(Item: TListItem):string;
//begin
//  //result:=ExtractFilePath(PGDBTextStyle(Item.Data)^.pfont^.fontfile);
//end;
{Linear Scale handle procedures}
function TDimStylesForm.GetLinearScale(Item: TListItem):string;
begin
  result:=floattostr(PGDBDimStyle(Item.Data)^.Units.DIMLFAC);
end;
function TDimStylesForm.CreateLinearScaleEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Units.DIMLFAC,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
{Text Height handle procedures}
function TDimStylesForm.GetTextHeight(Item: TListItem):string;
begin
  result:=floattostr(PGDBDimStyle(Item.Data)^.Text.DIMTXT);
end;
function TDimStylesForm.CreateTextHeightEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Text.DIMTXT,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;

function TDimStylesForm.GetDIMBLK1(Item: TListItem):string;
var
   typemanager:PUserTypeDescriptor;
begin
  typemanager:=SysUnit^.TypeName2PTD('TArrowStyle');
  if typemanager<>nil then
    result:=typemanager^.GetUserValueAsString(@PGDBDimStyle(Item.Data)^.Arrows.DIMBLK1)
  else
    result:='Something wrong!'
end;
function TDimStylesForm.CreateDIMBLK1Editor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Arrows.DIMBLK1,'TArrowStyle',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;

function TDimStylesForm.GetDIMBLK2(Item: TListItem):string;
var
   typemanager:PUserTypeDescriptor;
begin
  typemanager:=SysUnit^.TypeName2PTD('TArrowStyle');
  if typemanager<>nil then
    result:=typemanager^.GetUserValueAsString(@PGDBDimStyle(Item.Data)^.Arrows.DIMBLK2)
  else
    result:='Something wrong!'
end;
function TDimStylesForm.CreateDIMBLK2Editor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Arrows.DIMBLK2,'TArrowStyle',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;

function TDimStylesForm.GetDIMLDRBLK (Item: TListItem):string;
var
   typemanager:PUserTypeDescriptor;
begin
  typemanager:=SysUnit^.TypeName2PTD('TArrowStyle');
  if typemanager<>nil then
    result:=typemanager^.GetUserValueAsString(@PGDBDimStyle(Item.Data)^.Arrows.DIMLDRBLK)
  else
    result:='Something wrong!'
end;
function TDimStylesForm.CreateDIMLDRBLKEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Arrows.DIMLDRBLK,'TArrowStyle',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;

function TDimStylesForm.GetDIMASZ(Item: TListItem):string;
begin
  result:=floattostr(PGDBDimStyle(Item.Data)^.Arrows.DIMASZ);
end;
function TDimStylesForm.CreateDIMASZEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Arrows.DIMASZ,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;

procedure TDimStylesForm.FillTextStyleSelector(currentitem:string;currentitempstyle:PGDBTextStyle);
var
    s:string;
    CurrentFontIndex:integer;
    pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBTextStyle;
begin

     FontsSelector.Enums.Free;
     CurrentFontIndex:=-1;
     pdwg:=drawings.GetCurrentDWG;

       plp:=pdwg^.TextStyleTable.beginiterate(ir);
       if plp<>nil then
       repeat
            S:= plp^.Name;
            if S=currentitem then
             CurrentFontIndex:=FontsSelector.Enums.Count;
            FontsSelector.Enums.PushBackData(S);
            plp:=pdwg^.TextStyleTable.iterate(ir);
       until plp=nil;
     FontsSelector.Selected:=CurrentFontIndex;
     FontsSelector.Enums.SortAndSaveIndex(FontsSelector.Selected);
end;

procedure TDimStylesForm.onrsz(Sender: TObject);
begin
//     Sender:=Sender;
     SupportTypedEditors.freeeditor;
end;

procedure TDimStylesForm.FormCreate(Sender: TObject);
begin
  ActionList1.Images:=ImagesManager.IconList;
  ToolBar1.Images:=ImagesManager.IconList;
  AddStyle.ImageIndex:=ImagesManager.GetImageIndex('plus');
  DelStyle.ImageIndex:=ImagesManager.GetImageIndex('minus');
  MkCurrentStyle.ImageIndex:=ImagesManager.GetImageIndex('ok');;
  PurgeStyles.ImageIndex:=ImagesManager.GetImageIndex('Purge');
  RefreshStyles.ImageIndex:=ImagesManager.GetImageIndex('Refresh');
  InspectListItem.ImageIndex:=ImagesManager.GetImageIndex('inspectlistitem');

  Panel1.Constraints.MinWidth:=ToolBar1.Left+ToolButton_Refresh.Left+ToolButton_Refresh.Width+CoolBar1.GrabWidth;

  ListView1.SmallImages:=ImagesManager.IconList;
  ListView1.DefaultItemIndex:=ImagesManager.GetImageIndex('ok');;

  FontsSelector.Enums.init(100);
  SupportTypedEditors:=TSupportTypedEditors.create;
  SupportTypedEditors.OnUpdateEditedControl:=@UpdateItem2;
  FontChange:=false;
  IsUndoEndMarkerCreated:=false;

  setlength(ListView1.SubItems,ColumnCount);

  with ListView1.SubItems[NameColumn] do
  begin
       OnGetName:=@GetStyleName;
       OnClick:=@CreateNameEditor;
  end;
  with ListView1.SubItems[TextStyleNameColumn] do
  begin
       OnGetName:=@GetTextStyleName;
       OnClick:=@CreateTextStyleNameEditor;
  end;
  with ListView1.SubItems[LinearScaleColumn] do
  begin
       OnGetName:=@GetLinearScale;
       OnClick:=@CreateLinearScaleEditor;
  end;
  with ListView1.SubItems[TextHeightColumn] do
  begin
       OnGetName:=@GetTextHeight;
       OnClick:=@CreateTextHeightEditor;
  end;
  with ListView1.SubItems[DIMBLK1Column] do
  begin
       OnGetName:=@GetDIMBLK1;
       OnClick:=@CreateDIMBLK1Editor;
  end;
  with ListView1.SubItems[DIMBLK2Column] do
  begin
       OnGetName:=@GetDIMBLK2;
       OnClick:=@CreateDIMBLK2Editor;
  end;
  with ListView1.SubItems[DIMLDRBLKColumn] do
  begin
       OnGetName:=@GetDIMLDRBLK;
       OnClick:=@CreateDIMLDRBLKEditor;
  end;
  with ListView1.SubItems[DIMASZColumn] do
  begin
       OnGetName:=@GetDIMASZ;
       OnClick:=@CreateDIMASZEditor;
  end;
  //DIMBLK1Column=4;
  //DIMBLK2Column=5;
  //DIMLDRBLKColumn=6;
  //DIMASZColumn=7;
end;
procedure TDimStylesForm.MaceItemCurrent(ListItem:TListItem);
begin
     if ListView1.CurrentItem<>ListItem then
     begin
     CreateUndoStartMarkerNeeded;
     with TGDBPoinerChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,sysvar.dwg.DWG_CTStyle^,nil,nil) do
     begin
          SysVar.dwg.DWG_CTStyle^:=ListItem.Data;
          ComitFromObj;
     end;
     end;
end;
procedure TDimStylesForm.MkCurrent(Sender: TObject);
begin
  if assigned(ListView1.Selected)then
                                     begin
                                     if ListView1.Selected<>ListView1.CurrentItem then
                                       begin
                                         MaceItemCurrent(ListView1.Selected);
                                         ListView1.MakeItemCorrent(ListView1.Selected);
                                         UpdateItem2(ListView1.Selected);
                                       end;
                                     end
                                 else
                                     ZCMsgCallBackInterface.TextMessage(rsStyleMustBeSelected,TMWOMessageBox);
end;
procedure TDimStylesForm.FormShow(Sender: TObject);
begin
     RefreshListItems(nil);
end;
procedure TDimStylesForm.RefreshListItems(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBDimStyle;
   li:TListItem;
   tscounter:integer;
begin
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=drawings.GetCurrentDWG;
     tscounter:=0;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.DimStyleTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;
            inc(tscounter);
            li.Data:=plp;
            ListView1.UpdateItem(li,drawings.GetCurrentDWG^.GetCurrentDimStyle);
            plp:=pdwg^.DimStyleTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
     DescLabel.Caption:=Format(rsCountDimStylesFound,[tscounter]);
end;

procedure DimStyleCounter(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     if (PGDBObjEntity(PInstance)^.GetObjType=GDBAlignedDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBRotatedDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBDiametricDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBRadialDimensionID) then
     if PCounted=PGDBObjDimension(PInstance)^.PDimStyle then
          inc(Counter);
end;
procedure TextStyleCounterInDimStyles(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     //if PCounted=PGDBDimStyle(PInstance)^.Text.DIMTXSTY then
     //                                                      inc(Counter);
end;
procedure TDimStylesForm.countstyle(pdimstyle:PGDBDimStyle;out e,b,inDimStyles:Integer);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(pdimstyle,e,@DimStyleCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(pdimstyle,b,@DimStyleCounter);
  inDimStyles:=0;
  //pdwg^.DimStyleTable.IterateCounter(pdimstyle,inDimStyles,@TextStyleCounterInDimStyles);
end;
procedure TDimStylesForm.ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
var
   pstyle:PGDBDimStyle;
   //pdwg:PTSimpleDrawing;
   inent,inblock,indimstyles:integer;
begin
     if selected then
     begin
          //pdwg:=drawings.GetCurrentDWG;
          pstyle:=(Item.Data);
          countstyle(pstyle,inent,inblock,indimstyles);
          DescLabel.Caption:=Format(rsDimStyleUsedIn,[pstyle^.Name,inent,inblock,indimstyles]);
     end;
end;

procedure TDimStylesForm.DimStyleAdd(Sender: TObject);
var
   pstyle,pcreatedstyle:PGDBDimStyle;
   pdwg:PTSimpleDrawing;
   stylename:string;
   //counter:integer;
   //li:TListItem;
   domethod,undomethod:tmethod;
begin
  pdwg:=drawings.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     pstyle:=(ListView1.Selected.Data)
                                 else
                                     pstyle:=pdwg^.GetCurrentDimStyle;

  stylename:=pdwg^.DimStyleTable.GetFreeName(Tria_Utf8ToAnsi(rsNewDimStyleNameFormat),1);
  if stylename='' then
  begin
    ZCMsgCallBackInterface.TextMessage(rsUnableSelectFreeDimStylerName,TMWOShowError);
    exit;
  end;
  //////////////////////

  pdwg^.DimStyleTable.AddItem(stylename,pcreatedstyle);
  pcreatedstyle^:=pstyle^;
  pcreatedstyle^.Name:=stylename;

  domethod:=tmethod(@pdwg^.DimStyleTable.PushBackData);
  undomethod:=tmethod(@pdwg^.DimStyleTable.RemoveDataFromArray);
  CreateUndoStartMarkerNeeded;
  ///////   не получилось запустить
  with specialize GUCmdChgMethods<PGDBDimStyle>.CreateAndPush(pcreatedstyle,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,nil) do
  begin
       //AfterAction:=false;
       //comit;
  end;

  ListView1.AddCreatedItem(pcreatedstyle,drawings.GetCurrentDWG^.GetCurrentDimStyle);
end;

procedure TDimStylesForm.DimStyleInspect(Sender: TObject);
var
   editForm:TDimStyleEditForm;
   //pdwg:PTSimpleDrawing;
begin
  //pdwg:=drawings.GetCurrentDWG;
  if assigned(ListView1.Selected)then begin
    uzcfdimedit.dimStyle:=(ListView1.Selected.Data);
    editForm:=TDimStyleEditForm.Create(Self);
    //pstyle:=(ListView1.Selected.Data);
    editForm.ShowModal;
    //editForm.Free;
  end else
    ZCMsgCallBackInterface.TextMessage(rsStyleMustBeSelected,TMWOShowError);
end;

procedure TDimStylesForm.doTStyleDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   pstyle:PGDBDimStyle;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  pstyle:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.DimStyleTable.RemoveDataFromArray);
  undomethod:=tmethod(@pdwg^.DimStyleTable.PushBackData);
  CreateUndoStartMarkerNeeded;
  ///////   не получилось запустить
  with specialize GUCmdChgMethods<PGDBDimStyle>.CreateAndPush(pstyle,domethod,undomethod,PTZCADDrawing(pdwg)^.UndoStack,nil) do
  begin
       //AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;

procedure TDimStylesForm.DeleteItem(Sender: TObject);
var
   pstyle:PGDBDimStyle;
   pdwg:PTSimpleDrawing;
   inEntities,inBlockTable,indimstyles:Integer;
   //domethod,undomethod:tmethod;
begin
  pdwg:=drawings.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     begin
                                     pstyle:=(ListView1.Selected.Data);
                                     countstyle(pstyle,inEntities,inBlockTable,indimstyles);
                                     if ListView1.Selected.Data=pdwg^.GetCurrentDimStyle then
                                     begin
                                       ZCMsgCallBackInterface.TextMessage(rsCurrentDimStyleCannotBeDeleted,TMWOShowError);
                                       exit;
                                     end;
                                     if (inEntities+inBlockTable+indimstyles)>0 then
                                                  begin
                                                       ZCMsgCallBackInterface.TextMessage(rsUnableDelUsedStyle,TMWOShowError);
                                                       exit;
                                                  end;

                                     doTStyleDelete(ListView1.Selected);

                                     DescLabel.Caption:='';
                                     end
                                 else
                                     ZCMsgCallBackInterface.TextMessage(rsStyleMustBeSelected,TMWOShowError);
end;

procedure TDimStylesForm.AplyClose(Sender: TObject);
begin
     close;
end;

//procedure TDimStylesForm.DimStyleInspect(Sender: TObject);
//begin
//
//end;

procedure TDimStylesForm.PurgeTStyles(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable,indimstyles:Integer;
   PCurrentStyle:PGDBDimStyle;
begin

     i:=0;
     purgedcounter:=0;
     PCurrentStyle:=drawings.GetCurrentDWG^.GetCurrentDimStyle;
     if ListView1.Items.Count>0 then
     begin
       repeat
          ProcessedItem:=ListView1.Items[i];
          countstyle(ProcessedItem.Data,inEntities,inBlockTable,indimstyles);
          if (ProcessedItem.Data<>PCurrentStyle)and((inEntities+inBlockTable+indimstyles)=0) then
          begin
           doTStyleDelete(ProcessedItem);
           inc(purgedcounter);
          end
          else
           inc(i);
       until i>=ListView1.Items.Count;
     end;
     DescLabel.Caption:=Format(rsCountDimStylesPurged,[purgedcounter]);

end;

procedure TDimStylesForm.Aply(Sender: TObject);
begin
     if changedstamp then
     begin
       ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionRedraw);//это новая замена следующей закоментированой строки
       //if assigned(UpdateVisibleProc) then UpdateVisibleProc;
       zcRedrawCurrentDrawing;
     end;
end;

procedure TDimStylesForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     Aply(nil);
     CreateUndoEndMarkerNeeded;
     FontsSelector.Enums.done;
     SupportTypedEditors.Free;
end;
//initialization
  //FontsFilter:=TFTF_SHX;
end.

