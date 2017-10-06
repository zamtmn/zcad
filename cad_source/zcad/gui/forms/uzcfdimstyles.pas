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
unit uzcfdimstyles;
{$INCLUDE def.inc}
{$mode objfpc}{$H+}

interface

uses
  uzcutils,zcchangeundocommand,zcobjectchangeundocommand2,uzcdrawing,LMessages,uzefont,
  uzclog,uzedrawingsimple,uzcsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, Dialogs,GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype, ActnList,

  uzeconsts,uzestylestexts,uzcdrawings,uzbtypesbase,uzbtypes,varmandef,
  uzcsuptypededitors,

  uzestylesdim, uzeentdimension,

  uzbpaths,uzcinterface, uzcstrconsts, uzcsysinfo,uzbstrproc, uzcshared,UBaseTypeDescriptor,
  uzcimagesmanager, usupportgui, ZListView,uzefontmanager,varman,uzctnrvectorgdbstring,
  gzctnrvectortypes,uzeentity,uzeenttext;

const
     NameColumn=0;
     LinearScaleColumn=1;
     TextStyleNameColumn=2;
     TextHeightColumn=3;
     //WidthFactorColumn=4;
     //ObliqueColumn=5;

     ColumnCount=3+1;

type
  TFTFilter=(TFTF_All,TFTF_TTF,TFTF_SHX);

  { TDimStylesForm}

  TDimStylesForm= class(TForm)
    DelStyle: TAction;
    MkCurrentStyle: TAction;
    PurgeStyles: TAction;
    RefreshStyles: TAction;
    AddStyle: TAction;
    ActionList1: TActionList;
    FontTypeFilterComboBox: TComboBox;
    Bevel1: TBevel;
    ButtonApplyClose: TBitBtn;
    FontTypeFilterDesc: TLabel;
    DescLabel: TLabel;
    ListView1: TZListView;
    ToolBar1: TToolBar;
    ToolButton_Add: TToolButton;
    ToolButton_Delete: TToolButton;
    ToolButton_MkCurrent: TToolButton;
    Separator1: TToolButton;
    ToolButton_Purge: TToolButton;
    ToolButton_Refresh: TToolButton;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure FontsTypesChange(Sender: TObject);
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
    procedure FillFontsSelector(currentitem:string;currentitempfont:PGDBfont);
    procedure onrsz(Sender: TObject);
    procedure countstyle(pdimstyle:PGDBDimStyle;out e,b,inDimStyles:GDBInteger);
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
    procedure GetFontsTypesComboValue;
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
    //{Wfactor handle procedures}
    //function GetWidthFactor(Item: TListItem):string;
    //function CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
    //{Oblique handle procedures}
    //function GetOblique(Item: TListItem):string;
    //function CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
  end;

var
  DimStylesForm: TDimStylesForm;
  FontsFilter:TFTFilter;
implementation
{$R *.lfm}
function TDimStylesForm.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,ActiveControl,nil,OldFunction);
end;

procedure TDimStylesForm.GetFontsTypesComboValue;
begin
     FontTypeFilterComboBox.ItemIndex:=ord(FontsFilter);
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
   newfont:PGDBfont;
begin
     if FontChange then
     begin
          newfont:=FontManager.addFonf(FindInPaths(sysvarPATHFontsPath,pstring(FontsSelector.Enums.getDataMutable(FontsSelector.Selected))^));
          if  newfont<>PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY^.pfont then
          begin
               CreateUndoStartMarkerNeeded;
               with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pointer(PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY^.pfont))^ do
               begin
               PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY^.pfont:=newfont;
               ComitFromObj;
               end;
               with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBTextStyle(TListItem(Item).Data)^.dxfname)^ do
               begin
               PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY^.dxfname:=PGDBDimStyle(TListItem(Item).Data)^.Text.DIMTXSTY^.pfont^.Name;
               ComitFromObj;
               end;
          end;
     end;
     ListView1.UpdateItem2(TListItem(Item));
     FontChange:=false;
     FontTypeFilterComboBox.enabled:=true;
end;

{Style name handle procedures}
function TDimStylesForm.GetStyleName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBDimStyle(Item.Data)^.Name);
end;
function TDimStylesForm.CreateNameEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Name,'GDBAnsiString',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top)
end;
{Font name handle procedures}
function TDimStylesForm.GetTextStyleName(Item: TListItem):string;
begin
  //result:=ExtractFileName(PGDBDimStyle(Item.Data)^.pfont^.fontfile);
  result:=ExtractFileName(PGDBDimStyle(Item.Data)^.Text.DIMTXSTY^.pfont^.fontfile);
end;
function TDimStylesForm.CreateTextStyleNameEditor(Item: TListItem;r: TRect):boolean;
begin
  //FillFontsSelector(PGDBTextStyle(Item.Data)^.pfont^.fontfile,PGDBTextStyle(Item.Data)^.pfont);
  FillFontsSelector(PGDBDimStyle(Item.Data)^.Text.DIMTXSTY^.pfont^.fontfile,PGDBDimStyle(Item.Data)^.Text.DIMTXSTY^.pfont);
  FontChange:=true;
  FontTypeFilterComboBox.enabled:=false;
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,FontsSelector,'TEnumData',nil,r.Bottom-r.Top,false)
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
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Units.DIMLFAC,'GDBDouble',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top)
end;
{Text Height handle procedures}
function TDimStylesForm.GetTextHeight(Item: TListItem):string;
begin
  result:=floattostr(PGDBDimStyle(Item.Data)^.Text.DIMTXT);
end;
function TDimStylesForm.CreateTextHeightEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBDimStyle(Item.Data)^.Text.DIMTXT,'GDBDouble',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top)
end;
{Wfactor handle procedures}
//function TDimStylesForm.GetWidthFactor(Item: TListItem):string;
//begin
//  //result:=floattostr(PGDBTextStyle(Item.Data)^.prop.wfactor);
//end;
//function TDimStylesForm.CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
//begin
//  //result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.wfactor,'GDBDouble',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top)
//end;
//{Oblique handle procedures}
//function TDimStylesForm.GetOblique(Item: TListItem):string;
//begin
//  //result:=floattostr(PGDBTextStyle(Item.Data)^.prop.oblique);
//end;
//function TDimStylesForm.CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
//begin
//  //result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.oblique,'GDBDouble',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top)
//end;
procedure TDimStylesForm.FillFontsSelector(currentitem:string;currentitempfont:PGDBfont);
var i:integer;
    s:string;
    CurrentFontIndex:integer;
begin
     CurrentFontIndex:=-1;
     FontsSelector.Enums.Free;
     if FontsFilter<>TFTF_SHX then
     for i:=0 to FontManager.ttffontfiles.Count-1 do
     begin
          S:=FontManager.ttffontfiles[i];
          if S=currentitem then
           CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(S);
          FontsSelector.Enums.PushBackData(S);
     end;
     if FontsFilter<>TFTF_TTF then
     for i:=0 to FontManager.shxfontfiles.Count-1 do
     begin
          S:=FontManager.shxfontfiles[i];
          if S=currentitem then
           CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(S);
          FontsSelector.Enums.PushBackData(S);
     end;
     if CurrentFontIndex=-1 then
     begin
          CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(currentitempfont^.fontfile);
          FontsSelector.Enums.PushBackData(S);
     end;
     FontsSelector.Selected:=CurrentFontIndex;
     FontsSelector.Enums.SortAndSaveIndex(FontsSelector.Selected);
end;

procedure TDimStylesForm.onrsz(Sender: TObject);
begin
     Sender:=Sender;
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
  //with ListView1.SubItems[WidthFactorColumn] do
  //begin
  //     OnGetName:=@GetWidthFactor;
  //     OnClick:=@CreateWidthFactorEditor;
  //end;
  //with ListView1.SubItems[ObliqueColumn] do
  //begin
  //     OnGetName:=@GetOblique;
  //     OnClick:=@CreateObliqueEditor;
  //end;
end;
procedure TDimStylesForm.MaceItemCurrent(ListItem:TListItem);
begin
     if ListView1.CurrentItem<>ListItem then
     begin
     CreateUndoStartMarkerNeeded;
     with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,sysvar.dwg.DWG_CTStyle^)^ do
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
     GetFontsTypesComboValue;
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

procedure DimStyleCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if (PGDBObjEntity(PInstance)^.GetObjType=GDBAlignedDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBRotatedDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBDiametricDimensionID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBRadialDimensionID) then
     if PCounted=PGDBObjDimension(PInstance)^.PDimStyle then
          inc(Counter);
end;
procedure TextStyleCounterInDimStyles(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     //if PCounted=PGDBDimStyle(PInstance)^.Text.DIMTXSTY then
     //                                                      inc(Counter);
end;
procedure TDimStylesForm.countstyle(pdimstyle:PGDBDimStyle;out e,b,inDimStyles:GDBInteger);
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
  undomethod:=tmethod(@pdwg^.DimStyleTable.RemoveData);
  CreateUndoStartMarkerNeeded;
  ///////   не получилось запустить
  with PushCreateTGObjectChangeCommand2(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pcreatedstyle,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AfterAction:=false;
       //comit;
  end;

  ListView1.AddCreatedItem(pcreatedstyle,drawings.GetCurrentDWG^.GetCurrentDimStyle);
end;
procedure TDimStylesForm.doTStyleDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   pstyle:PGDBDimStyle;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  pstyle:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.DimStyleTable.RemoveData);
  undomethod:=tmethod(@pdwg^.DimStyleTable.PushBackData);
  CreateUndoStartMarkerNeeded;
  ///////   не получилось запустить
  with PushCreateTGObjectChangeCommand2(PTZCADDrawing(pdwg)^.UndoStack,pstyle,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;

procedure TDimStylesForm.DeleteItem(Sender: TObject);
var
   pstyle:PGDBDimStyle;
   pdwg:PTSimpleDrawing;
   inEntities,inBlockTable,indimstyles:GDBInteger;
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

procedure TDimStylesForm.FontsTypesChange(Sender: TObject);
begin
  FontsFilter:=TFTFilter(FontTypeFilterComboBox.ItemIndex);
end;

procedure TDimStylesForm.PurgeTStyles(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable,indimstyles:GDBInteger;
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
initialization
  FontsFilter:=TFTF_SHX;
end.

