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
unit uztbzcextensions;

{$mode delphi}{$H+}

interface

uses
  uztoolbarsmanager,uzmacros,uzxmlnodesutils,
  ActnList,Laz2_DOM,Menus,Forms,ComCtrls,Graphics,LazUTF8,
  StdCtrls,Controls,
  sysutils,Classes,
  uzcsysvars,uzbpaths,uzmenusmanager,uzctreenode,uzmenusdefaults,uzctranslations,
  usupportgui,uzccommandsmanager,uzcimagesmanager,uzcctrllayercombobox,
  uzcgui2color,uzeconsts,uzcfcolors,uzcuitypes,uzepalette,uzcdrawings,uzcinterface,
  uzcstrconsts,uzccommand_loadlayout,uzcgui2linetypes,uzestyleslinetypes,uzcinterfacedata,
  uzcgui2linewidth,uzcflineweights,uzcgui2textstyles,uzcgui2dimstyles;
type
  TZTBZCADExtensions=class
    class procedure TBActionCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBGroupActionCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBButtonCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBLayerComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBLayoutComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBColorComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBLTypeComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBLineWComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBTStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBDimStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    class procedure TBVariableCreateFunc(aNode: TDomNode; TB:TToolBar);
    class function TBCreateZCADToolBar(aName,atype: string):TToolBar;
    class procedure ZActionsReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    class procedure ZAction2VariableReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);

    class procedure DropDownColor(Sender:Tobject);
    class procedure DropUpColor(Sender:Tobject);
    class procedure DropUpLType(Sender:Tobject);
    class procedure DropDownLType(Sender:Tobject);
    class procedure FillColorCombo(cb:TCustomComboBox);
    class procedure FillLTCombo(cb:TCustomComboBox);
    class procedure FillLWCombo(cb:TCustomComboBox);
    class procedure ChangeCColor(Sender:Tobject);
    class procedure ChangeLType(Sender:Tobject);
    class procedure ChangeCLineW(Sender:Tobject);
    class procedure ChangeLayout(Sender:Tobject);


    class procedure CreateLayoutbox(tb:TToolBar);
  end;
implementation

uses uzcmainwindow;//Убрать нахуй это порно

class procedure TZTBZCADExtensions.TBActionCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _action:TZAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');
  _action:=TZAction(ZCADMainWindow.StandartActions.ActionByName(ActionName));
  if _action=nil then begin
    _action:=TmyAction.Create(TB);
    _action.ActionList:=ZCADMainWindow.StandartActions;
    _action.Name:=ActionName;
  end;
  with TToolButton.Create(tb) do
  begin
    Action:=_action;
    ShowCaption:=false;
    ShowHint:=true;
    if assigned(_action) then
      Caption:=_action.imgstr;
    Parent:=tb;
    Visible:=true;
  end;
end;
class procedure TZTBZCADExtensions.TBGroupActionCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  ActionIndex:integer;
  SubNode: TDomNode;
  i:integer;
  proxy:TPopUpMenyProxyAction;
  tbutton:TZToolButton;
  MPF:TMacroProcessFunc;
begin
  ActionIndex:=getAttrValue(aNode,'Index',0);
  tbutton:=TZToolButton.Create(tb);
  begin
    //tbutton.style:=tbsButtonDrop;
    tbutton.ShowCaption:=false;
    tbutton.ShowHint:=true;
    tbutton.PopupMenu:=TPopupMenu.Create(application);
    tbutton.PopupMenu.Images:=ZCADMainWindow.StandartActions.Images;
    {if assigned(_action) then
      Caption:=_action.imgstr;}
    tbutton.Parent:=tb;
    tbutton.Visible:=true;

    if assigned(aNode) then
      SubNode:=aNode.FirstChild;
    if assigned(SubNode) then
      while assigned(SubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(TMenuType.TMT_PopupMenu,ZCADMainWindow,SubNode.NodeName,SubNode,ZCADMainWindow.StandartActions,tmenuitem(tbutton.PopupMenu),mpf);
        SubNode:=SubNode.NextSibling;
      end;
    if (ActionIndex>=0)and(ActionIndex<tbutton.PopupMenu.Items.Count) then
      tbutton.action:=tbutton.PopupMenu.Items[ActionIndex].action;
    for i:=0 to tbutton.PopupMenu.Items.Count-1 do
    begin
      if assigned(tbutton.PopupMenu.Items[i].action)then begin
        proxy:=TPopUpMenyProxyAction.Create(Application);
        proxy.MainAction:=TAction(tbutton.PopupMenu.Items[i].action);
        proxy.ToolButton:=tbutton;
        proxy.Assign(tbutton.PopupMenu.Items[i].action);
        tbutton.PopupMenu.Items[i].action:=proxy;
        if proxy.MainAction.ImageIndex<>-1 then tbutton.caption:='';
      end;
    end;
    //Caption:='';
  end;
end;

procedure {TZCADMainWindow.}SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);
var
    bmp:Graphics.TBitmap;
begin
     if length(img)>1 then
     begin
          if img[1]<>'#' then
                              begin
                              img:={SysToUTF8}(ProgramPath)+'menu/BMP/'+img;
                              bmp:=Graphics.TBitmap.create;
                              bmp.LoadFromFile(img);
                              bmp.Transparent:=true;
                              if not assigned(ppanel.Images) then
                                                                 ppanel.Images:=ZCADMainWindow.standartactions.Images;
                              b.ImageIndex:=
                              ppanel.Images.Add(bmp,nil);
                              freeandnil(bmp);
                              //-----------b^.SetImageFromFile(img)
                              end
                          else
                              begin
                              b.caption:=(system.copy(img,2,length(img)-1));
                              b.caption:=InterfaceTranslate(identifer,b.caption);
                              if autosize then
                               if utf8length(img)>3 then
                                                    b.Font.size:=11-utf8length(img);
                              end;
     end;
                              b.Height:=ppanel.ButtonHeight;
                              b.Width:=ppanel.ButtonWidth;
end;

class procedure TZTBZCADExtensions.TBButtonCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  command,img,_hint:string;
  CreatedButton:TmyCommandToolButton;
begin
  command:=getAttrValue(aNode,'Command','');
  img:=getAttrValue(aNode,'Img','');
  _hint:=getAttrValue(aNode,'Hint','');

  CreatedButton:=TmyCommandToolButton.Create(tb);
  CreatedButton.FCommand:=command;
   if _hint<>'' then
   begin
     _hint:=InterfaceTranslate('hint_panel~'+command,_hint);
     CreatedButton.hint:=_hint;
     CreatedButton.ShowHint:=true;
   end;
  SetImage(tb,CreatedButton,img,true,'button_command~'+command);
  CreatedButton.Parent:=tb;
end;

class procedure TZTBZCADExtensions.ZActionsReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
var
  acnname:string;
  action:tmyaction;
  actioncommand,actionshortcut,actionshortcuts,img:string;
begin
  acnname:=uppercase(getAttrValue(aNode,'Name',''));
  action:=tmyaction(actlist.ActionByName(acnname));
  if action=nil then begin
    action:=TmyAction.Create(actlist);
    action.ActionList:=actlist;
    action.Name:=acnname;
  end;
  action.Caption:=getAttrValue(aNode,'Caption','');
  action.Caption:=InterfaceTranslate(action.Name+'~caption',action.Caption);
  action.Hint:=getAttrValue(aNode,'Hint','');
  if action.Hint<>'' then
                         action.Hint:=InterfaceTranslate(action.Name+'~hint',action.Hint)
                     else
                         action.Hint:=action.Caption;
  actionshortcut:=getAttrValue(aNode,'ShortCut','');
  if actionshortcut<>'' then
                          action.ShortCut:=MyTextToShortCut(actionshortcut);
  actionshortcuts:=getAttrValue(aNode,'SecondaryShortCuts','');
  if actionshortcuts<>'' then begin
    repeat
          GetPartOfPath(actionshortcut,actionshortcuts,'|');
          action.SecondaryShortCuts.AddObject(actionshortcut,TObject(pointer(MyTextToShortCut(actionshortcut))));
    until actionshortcuts='';
  end;
  actioncommand:=getAttrValue(aNode,'Command','');
  ParseCommand(actioncommand,action.command,action.options);
  action.Category:=getAttrValue(aNode,'Category',CategoryOverrider);
  action.DisableIfNoHandler:=false;
  img:=getAttrValue(aNode,'Img','');
  action.ImageIndex:=ImagesManager.GetImageIndex(img);
  if action.ImageIndex=ImagesManager.defaultimageindex then begin
    action.ImageIndex:=-1;
    actlist.SetImage(img,action.Name+'~textimage',TZAction(action));
  end;
  action.pfoundcommand:=commandmanager.FindCommand(uppercase(action.command));
end;
class procedure TZTBZCADExtensions.ZAction2VariableReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
var
  va:TmyVariableAction;
  actionvariable,actionshortcut,img:string;
  mask:DWord;
begin
  va:=TmyVariableAction.create(actlist);
  va.Name:=uppercase(getAttrValue(aNode,'Name',''));
  va.Caption:=getAttrValue(aNode,'Caption','');
  va.Caption:=InterfaceTranslate(va.Name+'~caption',va.Caption);
  va.Hint:=getAttrValue(aNode,'Hint','');
  if va.Hint<>'' then
                     va.Hint:=InterfaceTranslate(va.Name+'~hint',va.Hint)
                 else
                     va.Hint:=va.Caption;
  actionshortcut:=getAttrValue(aNode,'ShortCut','');
  if actionshortcut<>'' then
                            va.ShortCut:=MyTextToShortCut(actionshortcut);
  actionvariable:=getAttrValue(aNode,'Variable','');
  mask:=getAttrValue(aNode,'Mask',0);

  va.AssignToVar(actionvariable,mask);

  img:=getAttrValue(aNode,'Img','');
  va.ImageIndex:=ImagesManager.GetImageIndex(img);
  if va.ImageIndex=ImagesManager.defaultimageindex then begin
    va.ImageIndex:=-1;
    actlist.SetImage(img,va.Name+'~textimage',TZAction(va));
  end;

  va.AutoCheck:=true;
  va.Enabled:=true;
  va.ActionList:=actlist;
end;
class procedure TZTBZCADExtensions.TBLayerComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);

  LayerBox:=TZCADLayerComboBox.Create(tb);
  LayerBox.ImageList:=ImagesManager.IconList;

  LayerBox.Index_Lock:=ImagesManager.GetImageIndex('lock');
  LayerBox.Index_UnLock:=ImagesManager.GetImageIndex('unlock');
  LayerBox.Index_Freze:=ImagesManager.GetImageIndex('freze');;
  LayerBox.Index_UnFreze:=ImagesManager.GetImageIndex('unfreze');
  LayerBox.Index_ON:=ImagesManager.GetImageIndex('on');
  LayerBox.Index_OFF:=ImagesManager.GetImageIndex('off');

  LayerBox.fGetLayerProp:=ZCADMainWindow.GetLayerProp;
  LayerBox.fGetLayersArray:=ZCADMainWindow.GetLayersArray;
  LayerBox.fClickOnLayerProp:=ZCADMainWindow.ClickOnLayerProp;

  LayerBox.Width:=_Width;

  if _hint<>''then
  begin
       _hint:=InterfaceTranslate('hint_panel~LAYERCOMBOBOX',_hint);
       LayerBox.hint:=(_hint);
       LayerBox.ShowHint:=true;
  end;
  LayerBox.AutoSize:=false;
  LayerBox.Parent:=tb;
  LayerBox.Height:=10;
  ZCADMainWindow.updatescontrols.Add(LayerBox);
end;
procedure AddToBar(tb:TToolBar;b:TControl);
begin
     if tb.ClientHeight<tb.ClientWidth then
                                                   begin
                                                        //b.Left:=100;
                                                        //b.align:=alLeft
                                                   end
                                               else
                                                   begin
                                                        //b.top:=100;
                                                        //b.align:=alTop;
                                                   end;
    b.Parent:=tb;
end;
function CreateCBox(CBName:AnsiString;owner:TToolBar;DrawItem:TDrawItemEvent;Change,DropDown,CloseUp:TNotifyEvent;Filler:TComboFiller;w:integer;ts:AnsiString):TComboBox;
begin
  result:=TComboBox.Create(owner);
  result.Style:=csOwnerDrawFixed;
  SetComboSize(result,sysvar.INTF.INTF_DefaultControlHeight^-6,CBReadOnly);
  result.Clear;
  {result.readonly:=true;//now it deprecated, see in SetComboSize}
  result.DropDownCount:=50;
  if w<>0 then
              result.Width:=w;
  if ts<>''then
  begin
       ts:=InterfaceTranslate('combo~'+CBName,ts);
       result.hint:=(ts);
       result.ShowHint:=true;
  end;

  result.OnDrawItem:=DrawItem;
  result.OnChange:=Change;
  result.OnDropDown:=DropDown;
  result.OnCloseUp:=CloseUp;
  //result.OnMouseLeave:=setnormalfocus;

  if assigned(Filler)then
                         Filler(result);
  result.ItemIndex:=0;

  AddToBar(owner,result);
  ZCADMainWindow.updatescontrols.Add(result);
end;
procedure AddToComboIfNeed(cb:tcombobox;name:string;obj:TObject);
var
   i:integer;
begin
     for i:=0 to cb.Items.Count-1 do
       if cb.Items.Objects[i]=obj then
                                      exit;
     cb.items.InsertObject(cb.items.Count-1,name,obj);
end;
class procedure TZTBZCADExtensions.ChangeCColor(Sender:Tobject);
var
   ColorIndex,CColorSave,index:Integer;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     ColorIndex:=integer(tcombobox(Sender).items.Objects[index]);
     if ColorIndex=ClSelColor then
                           begin
                               if not assigned(ColorSelectForm)then
                               Application.CreateForm(TColorSelectForm, ColorSelectForm);
                               ZCADMainWindow.ShowAllCursors(ColorSelectForm);
                               mr:=ColorSelectForm.run(SysVar.dwg.DWG_CColor^,true){showmodal};
                               if mr=ZCmrOK then
                                              begin
                                              ColorIndex:=ColorSelectForm.ColorInfex;
                                              if assigned(Sender)then
                                              begin
                                              AddToComboIfNeed(tcombobox(Sender),palette[ColorIndex].name,TObject(ColorIndex));
                                              tcombobox(Sender).ItemIndex:=tcombobox(Sender).Items.Count-2;
                                              end;
                                              end
                                          else
                                              begin
                                                   tcombobox(Sender).ItemIndex:=OldColor;
                                                   ColorIndex:=-1;
                                              end;
                               ZCADMainWindow.RestoreCursors(ColorSelectForm);
                               freeandnil(ColorSelectForm);
                           end;
     if colorindex<0 then
                         exit;
     if drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CColor^:=ColorIndex;
     end
     else
     begin
          CColorSave:=SysVar.dwg.DWG_CColor^;
          SysVar.dwg.DWG_CColor^:=ColorIndex;
          commandmanager.ExecuteCommand('SelObjChangeColorToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CColor^:=CColorSave;
     end;
     //setvisualprop;
     ZCMsgCallBackInterface.Do_GUIaction(ZCADMainWindow,ZMsgID_GUIActionRebuild);
     //setnormalfocus(nil);
     ZCMsgCallBackInterface.Do_SetNormalFocus;
end;
class procedure TZTBZCADExtensions.DropDownColor(Sender:Tobject);
begin
     OldColor:=tcombobox(Sender).ItemIndex;
     tcombobox(Sender).ItemIndex:=-1;
end;
class procedure TZTBZCADExtensions.DropUpColor(Sender:Tobject);
begin
     if tcombobox(Sender).ItemIndex=-1 then
                                           tcombobox(Sender).ItemIndex:=OldColor;
end;

class procedure TZTBZCADExtensions.FillColorCombo(cb:TCustomComboBox);
var
   i:integer;
   ts:string;
begin
  cb.items.AddObject(rsByBlock, TObject(ClByBlock));
  cb.items.AddObject(rsByLayer, TObject(ClByLayer));
  for i := 1 to 7 do
  begin
       ts:=palette[i].name;
       cb.items.AddObject(ts, TObject(i));
  end;
  cb.items.AddObject(rsSelectColor, TObject(ClSelColor));
end;

class procedure TZTBZCADExtensions.ChangeLayout(Sender:Tobject);
var
    s:string;
begin
  s:=ProgramPath+'components/'+LayoutBox.text+'.xml';
  LoadLayoutFromFile(s);
end;


procedure addfiletoLayoutbox(filename:String);
var
    s:string;
begin
     s:=ExtractFileName(filename);
     LayoutBox.AddItem(copy(s,1,length(s)-4),nil);
end;


class procedure TZTBZCADExtensions.CreateLayoutbox(tb:TToolBar);
var
    s:string;
begin
  LayoutBox:=TComboBox.Create(tb);
  LayoutBox.Style:=csDropDownList;
  LayoutBox.Sorted:=true;
  FromDirIterator(ProgramPath+'components/','*.xml','',addfiletoLayoutbox,nil);
  LayoutBox.OnChange:=ChangeLayout;

  s:=extractfilename(sysvar.PATH.LayoutFile^);
  LayoutBox.ItemIndex:=LayoutBox.Items.IndexOf(copy(s,1,length(s)-4));

end;

class procedure TZTBZCADExtensions.TBColorComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  ColorBox:=CreateCBox('ColorComboBox',tb,TSupportColorCombo.ColorBoxDrawItem,ChangeCColor,DropDownColor,DropUpColor,FillColorCombo,_Width,_hint);
end;
class procedure TZTBZCADExtensions.TBLayoutComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  //ColorBox:=CreateCBox('ColorComboBox',tb,TSupportColorCombo.ColorBoxDrawItem,ChangeCColor,DropDownColor,DropUpColor,FillColorCombo,_Width,_hint);
    if assigned(LayoutBox) then
    ZCMsgCallBackInterface.TextMessage(format(rsReCreating,['LAYOUTBOX']),TMWOShowError);
  CreateLayoutbox(TB);
  LayoutBox.Parent:=TB;
  LayoutBox.AutoSize:=false;
  if _Width>0 then
    LayoutBox.Width:=_Width;
  if _hint<>''then
  begin
       _hint:=InterfaceTranslate('combo~LayoutComboBox',_hint);
       LayoutBox.hint:=(_hint);
       LayoutBox.ShowHint:=true;
  end;
  //LayoutBox.Align:=alRight;
end;
class procedure TZTBZCADExtensions.ChangeLType(Sender:Tobject);
var
   {LTIndex,}index:Integer;
   CLTSave,plt:PGDBLtypeProp;
begin
     index:=tcombobox(Sender).ItemIndex;
     plt:=PGDBLtypeProp(tcombobox(Sender).items.Objects[index]);
     //LTIndex:=drawings.GetCurrentDWG.LTypeStyleTable.GetIndexByPointer(plt);
     if plt=nil then
                         exit;
     if plt=lteditor then
                         begin
                              commandmanager.ExecuteCommand('LineTypes',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         end
     else
     begin
     if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
     end
     else
     begin
          CLTSave:=SysVar.dwg.DWG_CLType^;
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
          commandmanager.ExecuteCommand('SelObjChangeLTypeToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CLType^:=CLTSave;
     end;
     end;
     //setvisualprop;
     ZCMsgCallBackInterface.Do_GUIaction(ZCADMainWindow,ZMsgID_GUIActionRebuild);
     //setnormalfocus(nil);
     ZCMsgCallBackInterface.Do_SetNormalFocus;
end;

class procedure TZTBZCADExtensions.DropUpLType(Sender:Tobject);
begin
     tcombobox(Sender).ItemIndex:=0;
end;

class procedure TZTBZCADExtensions.DropDownLType(Sender:Tobject);
var
   i:integer;
begin
     if drawings.GetCurrentDWG=nil then exit;
     SetcomboItemsCount(tcombobox(Sender),drawings.GetCurrentDWG.LTypeStyleTable.Count+1);
     for i:=0 to drawings.GetCurrentDWG.LTypeStyleTable.Count-1 do
     begin
          tcombobox(Sender).Items.Objects[i]:=tobject(drawings.GetCurrentDWG.LTypeStyleTable.getDataMutable(i));
     end;
     tcombobox(Sender).Items.Objects[drawings.GetCurrentDWG.LTypeStyleTable.Count]:=LTEditor;
end;

class procedure TZTBZCADExtensions.TBLTypeComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LTypeBox:=CreateCBox('LTypeComboBox',tb,TSupportLineTypeCombo.LTypeBoxDrawItem,ChangeLType,DropDownLType,DropUpLType,FillLTCombo,_Width,_hint);
end;

class procedure TZTBZCADExtensions.FillLTCombo(cb:TCustomComboBox);
begin
  cb.items.AddObject(rsByBlock, TObject(0));
end;

class procedure TZTBZCADExtensions.ChangeCLineW(Sender:Tobject);
var tcl,index:Integer;
begin
  index:=tcombobox(Sender).ItemIndex;
  index:=integer(tcombobox(Sender).items.Objects[index]);
  if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
  then
  begin
      SysVar.dwg.DWG_CLinew^:=index;
  end
  else
  begin
           begin
                tcl:=SysVar.dwg.DWG_CLinew^;
                SysVar.dwg.DWG_CLinew^:=index;
                commandmanager.ExecuteCommand('SelObjChangeLWToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                SysVar.dwg.DWG_CLinew^:=tcl;
           end;
  end;
  //setvisualprop;
  ZCMsgCallBackInterface.Do_GUIaction(ZCADMainWindow,ZMsgID_GUIActionRebuild);
  //setnormalfocus(nil);
  ZCMsgCallBackInterface.Do_SetNormalFocus;
end;

class procedure TZTBZCADExtensions.FillLWCombo(cb:TCustomComboBox);
var
   i:integer;
   s:AnsiString;
begin
  cb.items.AddObject(rsByLayer, TObject(LnWtByLayer));
  cb.items.AddObject(rsByBlock, TObject(LnWtByBlock));
  cb.items.AddObject(rsdefault, TObject(LnWtByLwDefault));
  for i := low(lwarray) to high(lwarray) do
  begin
  s:=GetLWNameFromN(i);
       cb.items.AddObject(s, TObject(lwarray[i]));
  end;
end;


class procedure TZTBZCADExtensions.TBLineWComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LineWBox:=CreateCBox('LineWComboBox',tb,TSupportLineWidthCombo.LineWBoxDrawIVarsItem,ChangeCLineW,DropDownColor,DropUpColor,FillLWCombo,_Width,_hint);
end;
class procedure TZTBZCADExtensions.TBTStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  TStyleBox:=CreateCBox('TStyleComboBox',tb,TSupportTStyleCombo.DrawItemTStyle,TSupportTStyleCombo.ChangeLType,TSupportTStyleCombo.DropDownTStyle,TSupportTStyleCombo.CloseUpTStyle,TSupportTStyleCombo.FillLTStyle,_Width,_hint);
end;
class procedure TZTBZCADExtensions.TBDimStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  DimStyleBox:=CreateCBox('DimStyleComboBox',tb,TSupportDimStyleCombo.DrawItemTStyle,TSupportDimStyleCombo.ChangeLType,TSupportDimStyleCombo.DropDownTStyle,TSupportDimStyleCombo.CloseUpTStyle,TSupportDimStyleCombo.FillLTStyle,_Width,_hint);
end;

class function TZTBZCADExtensions.TBCreateZCADToolBar(aName,atype: string):TToolBar;
begin
  result:=TmyToolBar.Create(nil);
  ToolBarsManager.SetupDefaultToolBar(aName,atype, result);
end;

class procedure TZTBZCADExtensions.TBVariableCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _varname,_img,_hint,_shortcut:string;
  _mask:integer;
  b:TmyVariableToolButton;
  shortcut:TShortCut;
  baction:TmyButtonAction;
begin
  _varname:=getAttrValue(aNode,'VarName','');
  _img:=getAttrValue(aNode,'Img','');
  _hint:=getAttrValue(aNode,'Hint','');
  _shortcut:=getAttrValue(aNode,'ShortCut','');
  _mask:=getAttrValue(aNode,'Mask',0);

  b:=TmyVariableToolButton.Create(tb);
  b.Style:=tbsCheck;
  TmyVariableToolButton(b).AssignToVar(_varname,_mask);
  if _hint<>''then
  begin
    _hint:=InterfaceTranslate('hint_panel~'+_varname,_hint);
    b.hint:=(_hint);
    b.ShowHint:=true;
  end;
  b.ImageIndex:=ImagesManager.GetImageIndex(_img);
  if b.ImageIndex=ImagesManager.defaultimageindex then begin
    b.ImageIndex:=-1;
    SetImage(tb,b,_img,false,'button_variable~'+_varname);;
  end;
  //AddToBar(tb,b);
  b.Parent:=tb;
  ZCADMainWindow.updatesbytton.Add(b);
  if _shortcut<>'' then
  begin
    shortcut:=MyTextToShortCut(_shortcut);
    if shortcut>0 then
    begin
      baction:=TmyButtonAction.Create(ZCADMainWindow.StandartActions);
      baction.button:=b;
      baction.ShortCut:=shortcut;
      ZCADMainWindow.StandartActions.AddMyAction(baction);
    end;
  end;
end;


initialization
finalization
end.
