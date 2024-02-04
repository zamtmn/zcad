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
unit uzcftextstyles;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzcutils,gzundoCmdChgData,gzundoCmdChgMethods,uzcdrawing,LMessages,uzefont,
  uzclog,uzedrawingsimple,uzcsysvars,Classes,SysUtils,
  FileUtil,LResources,Forms,Controls,Graphics,GraphType,
  Buttons,ExtCtrls,StdCtrls,ComCtrls,LCLIntf,lcltype, ActnList,

  uzeconsts,uzestylestexts,uzcdrawings,uzbtypes,varmandef,
  uzcsuptypededitors,

  uzbpaths,uzcinterface,uzcstrconsts,uzbstrproc,UBaseTypeDescriptor,
  uzcimagesmanager,usupportgui,ZListView,uzefontmanager,varman,uzctnrvectorstrings,
  gzctnrVectorTypes,uzeentity,uzeenttext;

const
     NameColumn=0;
     FontNameColumn=1;
     FontPathColumn=2;
     HeightColumn=3;
     WidthFactorColumn=4;
     ObliqueColumn=5;

     ColumnCount=5+1;

type
  TFTFilter=(TFTF_All,TFTF_TTF,TFTF_SHX);

  { TTextStylesForm }

  TTextStylesForm = class(TForm)
    CoolBar1: TCoolBar;
    DelStyle: TAction;
    MkCurrentStyle: TAction;
    Panel1: TPanel;
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
    procedure StyleAdd(Sender: TObject);
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
    procedure countstyle(ptextstyle:PGDBTextStyle;out e,b,inDimStyles:Integer);
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
    function GetFontName(Item: TListItem):string;
    function CreateFontNameEditor(Item: TListItem;r: TRect):boolean;
    {Font path handle procedures}
    function GetFontPath(Item: TListItem):string;
    {Height handle procedures}
    function GetHeight(Item: TListItem):string;
    function CreateHeightEditor(Item: TListItem;r: TRect):boolean;
    {Wfactor handle procedures}
    function GetWidthFactor(Item: TListItem):string;
    function CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
    {Oblique handle procedures}
    function GetOblique(Item: TListItem):string;
    function CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
  end;

var
  TextStylesForm: TTextStylesForm;
  FontsFilter:TFTFilter;
implementation
{$R *.lfm}
function TTextStylesForm.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,ActiveControl,nil,OldFunction,nil);
end;

procedure TTextStylesForm.GetFontsTypesComboValue;
begin
     FontTypeFilterComboBox.ItemIndex:=ord(FontsFilter);
end;

procedure TTextStylesForm.CreateUndoStartMarkerNeeded;
begin
  zcPlaceUndoStartMarkerIfNeed(IsUndoEndMarkerCreated,'Change text styles');
end;
procedure TTextStylesForm.CreateUndoEndMarkerNeeded;
begin
  zcPlaceUndoEndMarkerIfNeed(IsUndoEndMarkerCreated);
end;

procedure TTextStylesForm.UpdateItem2(Item:TObject);
var
   newfont:PGDBfont;
   //dbg:PGDBTextStyle;
begin
  //dbg:=PGDBTextStyle(TListItem(Item).Data);
  if FontChange then begin
    newfont:=FontManager.addFont(pstring(FontsSelector.Enums.getDataMutable(FontsSelector.Selected))^,'');
    if  (newfont<>PGDBTextStyle(TListItem(Item).Data)^.pfont)and(newfont<>nil) then begin
      CreateUndoStartMarkerNeeded;
      with TGDBPoinerChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pointer(PGDBTextStyle(TListItem(Item).Data)^.pfont),nil,nil) do begin
        PGDBTextStyle(TListItem(Item).Data)^.pfont:=newfont;
        ComitFromObj;
      end;
      with TStringChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBTextStyle(TListItem(Item).Data)^.FontFile,nil,nil) do begin
        PGDBTextStyle(TListItem(Item).Data)^.FontFile:=PGDBTextStyle(TListItem(Item).Data)^.pfont^.Name;
        ComitFromObj;
      end;
      with TStringChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBTextStyle(TListItem(Item).Data)^.FontFile,nil,nil) do begin
        PGDBTextStyle(TListItem(Item).Data)^.FontFamily:='';
        ComitFromObj;
      end;
    end;
  end;
  ListView1.UpdateItem2(TListItem(Item));
  FontChange:=false;
  FontTypeFilterComboBox.enabled:=true;
end;

{Style name handle procedures}
function TTextStylesForm.GetStyleName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBTextStyle(Item.Data)^.Name);
end;
function TTextStylesForm.CreateNameEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.Name,'AnsiString',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
{Font name handle procedures}
function TTextStylesForm.GetFontName(Item: TListItem):string;
begin
  if PGDBTextStyle(Item.Data)^.pfont<>nil then
    result:=ExtractFileName(PGDBTextStyle(Item.Data)^.pfont^.fontfile)
  else
    result:='TextStyle.pfont=nil(('
end;
function TTextStylesForm.CreateFontNameEditor(Item: TListItem;r: TRect):boolean;
begin
  if PGDBTextStyle(Item.Data)^.pfont<>nil then begin
    FillFontsSelector(PGDBTextStyle(Item.Data)^.pfont^.fontfile,PGDBTextStyle(Item.Data)^.pfont);
    FontChange:=true;
    FontTypeFilterComboBox.enabled:=false;
    result:=SupportTypedEditors.createeditor(ListView1,Item,r,FontsSelector,'TEnumData',nil,r.Bottom-r.Top,drawings.GetUnitsFormat,false)
  end;
end;
{Font path handle procedures}
function TTextStylesForm.GetFontPath(Item: TListItem):string;
begin
  if PGDBTextStyle(Item.Data)^.pfont<>nil then
    result:=ExtractFilePath(PGDBTextStyle(Item.Data)^.pfont^.fontfile)
  else
    result:='TextStyle.pfont=nil(('
end;
{Height handle procedures}
function TTextStylesForm.GetHeight(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.size);
end;
function TTextStylesForm.CreateHeightEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.size,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
{Wfactor handle procedures}
function TTextStylesForm.GetWidthFactor(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.wfactor);
end;
function TTextStylesForm.CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.wfactor,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
{Oblique handle procedures}
function TTextStylesForm.GetOblique(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.oblique);
end;
function TTextStylesForm.CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.oblique,'Double',@CreateUndoStartMarkerNeeded,r.Bottom-r.Top,drawings.GetUnitsFormat)
end;
procedure TTextStylesForm.FillFontsSelector(currentitem:string;currentitempfont:PGDBfont);
var i:integer;
    s:string;
    CurrentFontIndex:integer;
    //currTTFfont:TGeneralFontFileDesc;
    //currTTFfontPair:TFontName2FontFileMap.TPair;
    pair:TFontName2FontFileMap.TDictionaryPair;
    //iter:TFontName2FontFileMap.TIterator;
begin
     CurrentFontIndex:=-1;
     FontsSelector.Enums.Free;
     if FontsFilter<>TFTF_SHX then begin
       for pair in FontManager.FontFiles do begin
       //iter:=FontManager.FontFiles.min;
       //if assigned(iter) then
       //repeat
          S:=pair.Value.FontFile;
          if S=currentitem then
            CurrentFontIndex:=FontsSelector.Enums.Count;
          S:={iter.Value.Name;//}extractfilename(S);
          FontsSelector.Enums.PushBackData(S);
       //until (not iter.Next);
       //if iter<>nil then
       //  iter.destroy;
       end;

       {for currTTFfontPair in FontManager.FontFiles do begin
         S:=currTTFfontPair.Value.FontFile;
         if S=currentitem then
           CurrentFontIndex:=FontsSelector.Enums.Count;
         S:=currTTFfontPair.Value.Name;//extractfilename(S);
         FontsSelector.Enums.PushBackData(S);
       end;}
       {for i:=0 to FontManager.ttffontfiles.Count-1 do
       begin
            S:=FontManager.ttffontfiles[i];
            if S=currentitem then
             CurrentFontIndex:=FontsSelector.Enums.Count;
            S:=extractfilename(S);
            FontsSelector.Enums.PushBackData(S);
       end;}
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

procedure TTextStylesForm.onrsz(Sender: TObject);
begin
//     Sender:=Sender;
     SupportTypedEditors.freeeditor;
end;

procedure TTextStylesForm.FormCreate(Sender: TObject);
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

  FontTypeFilterComboBox.ItemHeight:=DescLabel.ClientHeight-4;

  Panel1.Constraints.MinWidth:=ToolBar1.Left+ToolButton_Refresh.Left+ToolButton_Refresh.Width+CoolBar1.GrabWidth;

  setlength(ListView1.SubItems,ColumnCount);

  with ListView1.SubItems[NameColumn] do
  begin
       OnGetName:=@GetStyleName;
       OnClick:=@CreateNameEditor;
  end;
  with ListView1.SubItems[FontNameColumn] do
  begin
       OnGetName:=@GetFontName;
       OnClick:=@CreateFontNameEditor;
  end;
  with ListView1.SubItems[FontPathColumn] do
  begin
       OnGetName:=@GetFontPath;
  end;
  with ListView1.SubItems[HeightColumn] do
  begin
       OnGetName:=@GetHeight;
       OnClick:=@CreateHeightEditor;
  end;
  with ListView1.SubItems[WidthFactorColumn] do
  begin
       OnGetName:=@GetWidthFactor;
       OnClick:=@CreateWidthFactorEditor;
  end;
  with ListView1.SubItems[ObliqueColumn] do
  begin
       OnGetName:=@GetOblique;
       OnClick:=@CreateObliqueEditor;
  end;
end;
procedure TTextStylesForm.MaceItemCurrent(ListItem:TListItem);
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
procedure TTextStylesForm.MkCurrent(Sender: TObject);
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
procedure TTextStylesForm.FormShow(Sender: TObject);
begin
     GetFontsTypesComboValue;
     RefreshListItems(nil);
end;
procedure TTextStylesForm.RefreshListItems(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBTextStyle;
   li:TListItem;
   tscounter:integer;
begin
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=drawings.GetCurrentDWG;
     tscounter:=0;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.TextStyleTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;
            inc(tscounter);
            li.Data:=plp;
            ListView1.UpdateItem(li,drawings.GetCurrentDWG^.GetCurrentTextStyle);
            plp:=pdwg^.TextStyleTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
     DescLabel.Caption:=Format(rsCountTStylesFound,[tscounter]);
end;

procedure TextStyleCounter(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     if (PGDBObjEntity(PInstance)^.GetObjType=GDBMTextID)or(PGDBObjEntity(PInstance)^.GetObjType=GDBTextID) then
     if PCounted=PGDBObjText(PInstance)^.TXTStyleIndex then
                                                           inc(Counter);
end;
procedure TextStyleCounterInDimStyles(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     //if PCounted=PGDBDimStyle(PInstance)^.Text.DIMTXSTY then
     //                                                      inc(Counter);
end;
procedure TTextStylesForm.countstyle(ptextstyle:PGDBTextStyle;out e,b,inDimStyles:Integer);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(ptextstyle,e,@TextStyleCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(ptextstyle,b,@TextStyleCounter);
  inDimStyles:=0;
  pdwg^.DimStyleTable.IterateCounter(ptextstyle,inDimStyles,@TextStyleCounterInDimStyles);
end;
procedure TTextStylesForm.ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
var
   pstyle:PGDBTextStyle;
   //pdwg:PTSimpleDrawing;
   inent,inblock,indimstyles:integer;
begin
     if selected then
     begin
          //pdwg:=drawings.GetCurrentDWG;
          pstyle:=(Item.Data);
          countstyle(pstyle,inent,inblock,indimstyles);
          DescLabel.Caption:=Format(rsTextStyleUsedIn,[pstyle^.Name,inent,inblock,indimstyles]);
     end;
end;

procedure TTextStylesForm.StyleAdd(Sender: TObject);
var
   pstyle,pcreatedstyle:PGDBTextStyle;
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
                                     pstyle:=pdwg^.GetCurrentTextStyle;

  stylename:=pdwg^.TextStyleTable.GetFreeName(Tria_Utf8ToAnsi(rsNewTextStyleNameFormat),1);
  if stylename='' then
  begin
    ZCMsgCallBackInterface.TextMessage(rsUnableSelectFreeTextStylerName,TMWOShowError);
    exit;
  end;

  pdwg^.TextStyleTable.AddItem(stylename,pcreatedstyle);
  pcreatedstyle^:=pstyle^;
  pcreatedstyle^.Name:=stylename;

  domethod:=tmethod(@pdwg^.TextStyleTable.PushBackData);
  undomethod:=tmethod(@pdwg^.TextStyleTable.RemoveDataFromArray);
  CreateUndoStartMarkerNeeded;
  with specialize GUCmdChgMethods<PGDBTextStyle>.CreateAndPush(pcreatedstyle,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,nil) do
  begin
       //AfterAction:=false;
       //comit;
  end;

  ListView1.AddCreatedItem(pcreatedstyle,drawings.GetCurrentDWG^.GetCurrentTextStyle);
end;
procedure TTextStylesForm.doTStyleDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   pstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=drawings.GetCurrentDWG;
  pstyle:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.TextStyleTable.RemoveDataFromArray);
  undomethod:=tmethod(@pdwg^.TextStyleTable.PushBackData);
  CreateUndoStartMarkerNeeded;
  with specialize GUCmdChgMethods<PGDBTextStyle>.CreateAndPush(pstyle,domethod,undomethod,PTZCADDrawing(pdwg)^.UndoStack,nil) do
  begin
       //AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;

procedure TTextStylesForm.DeleteItem(Sender: TObject);
var
   pstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
   inEntities,inBlockTable,indimstyles:Integer;
   //domethod,undomethod:tmethod;
begin
  pdwg:=drawings.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     begin
                                     pstyle:=(ListView1.Selected.Data);
                                     countstyle(pstyle,inEntities,inBlockTable,indimstyles);
                                     if ListView1.Selected.Data=pdwg^.GetCurrentTextStyle then
                                     begin
                                       ZCMsgCallBackInterface.TextMessage(rsCurrentStyleCannotBeDeleted,TMWOShowError);
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

procedure TTextStylesForm.AplyClose(Sender: TObject);
begin
     close;
end;

procedure TTextStylesForm.FontsTypesChange(Sender: TObject);
begin
  FontsFilter:=TFTFilter(FontTypeFilterComboBox.ItemIndex);
end;

procedure TTextStylesForm.PurgeTStyles(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable,indimstyles:Integer;
   PCurrentStyle:PGDBTextStyle;
begin
     i:=0;
     purgedcounter:=0;
     PCurrentStyle:=drawings.GetCurrentDWG^.GetCurrentTextStyle;
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
     DescLabel.Caption:=Format(rsCountTStylesPurged,[purgedcounter]);
end;
procedure TTextStylesForm.Aply(Sender: TObject);
begin
     if changedstamp then
     begin
       ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionRedraw);
       //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
       zcRedrawCurrentDrawing;
     end;
end;

procedure TTextStylesForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
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

