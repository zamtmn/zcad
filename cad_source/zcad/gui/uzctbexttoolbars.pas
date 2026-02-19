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
unit uzctbexttoolbars;

{$mode delphi}{$H+}

interface

uses
  uztoolbarsmanager,uzmacros,uzxmlnodesutils,
  ActnList,Laz2_DOM,Menus,Forms,ComCtrls,Graphics,LazUTF8,
  StdCtrls,Controls,
  sysutils,Classes,
  uzcsysvars,uzbpaths,uzmenusmanager,uzctreenode,uzmenusdefaults,uzcTranslations,
  usupportgui,uzccommandsmanager,uzcimagesmanager,uzcctrllayercombobox,
  uzcgui2color,uzeconsts,uzcfcolors,uzcuitypes,uzepalette,uzcdrawings,uzcinterface,
  uzcstrconsts,uzccommand_loadlayout,uzcgui2linetypes,uzestyleslinetypes,uzcinterfacedata,
  uzcgui2linewidth,uzcflineweights,uzcgui2textstyles,uzcgui2dimstyles,
  uzedrawingsimple,uzcdrawing,uzcuidialogs,uzbstrproc,
  uzestyleslayers,zUndoCmdChgBaseTypes,uzcutils,gzctnrVectorTypes,uzcCtrlFindEditBox,
  zUndoCmdChgTypes,uzcLog,uzcFileStructure;
const
  CToolBarCaptionTranslateFormat='toolbar_caption~%s';
type
  TMyToolbar=class(TToolBar)
    public
    destructor Destroy; override;
  end;
  TComboFiller=procedure(cb:TCustomComboBox) of object;

  TLayerComboBoxPopupFocusPriorityControl=class(TComponent)
    constructor Create(AOwner:TComponent);override;
    destructor Destroy; override;
    function GetLayerComboBoxPopupFocusPriority:TControlWithPriority;
  end;

  TZTBZCADExtensions=class
    class procedure TBActionCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBGroupActionCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBButtonCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBLayerComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBFindEditBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBLayoutComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBColorComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBLTypeComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBLineWComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBTStyleComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBDimStyleComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class procedure TBVariableCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    class function TBCreateZCADToolBar(fmf:TForm;aName,aCaption,atype: string):TToolBar;
    class procedure ZActionsReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    class procedure ZAction2VariableReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);

    class procedure DropDownColor(Sender:Tobject);
    class procedure CloseUp(Sender:Tobject);
    class procedure CloseUpColor(Sender:Tobject);
    class procedure CloseUpLType(Sender:Tobject);
    class procedure DropDownLType(Sender:Tobject);
    class procedure FillColorCombo(cb:TCustomComboBox);
    class procedure FillLTCombo(cb:TCustomComboBox);
    class procedure FillLWCombo(cb:TCustomComboBox);
    class procedure ChangeCColor(Sender:Tobject);
    class procedure ChangeLType(Sender:Tobject);
    class procedure ChangeCLineW(Sender:Tobject);
    class procedure ChangeLayout(Sender:Tobject);
    class function GetLayerProp(PLayer:Pointer;out lp:TLayerPropRecord):boolean;
    class function GetLayersArray(out la:TLayerArray):boolean;
    class function ClickOnLayerProp(PLayer:Pointer;NumProp:integer;out newlp:TLayerPropRecord):boolean;
    class procedure CloseLayerDropDown;

    class function CreateLayoutbox(tb:TToolBar):TComboBox;
  end;
implementation

var
  OLDColor:integer;

destructor TmyToolBar.Destroy;
var
  I: Integer;
  c:tcontrol;
begin
  for I := 0 to controlCount - 1 do
    begin
      c:=controls[I];
      if assigned(updatescontrols)  then
        updatescontrols.Remove(c);
      if assigned(updatesbytton)  then
        updatesbytton.Remove(c);
    end;
  inherited Destroy;
end;


procedure setlayerstate(PLayer:PGDBLayerProp;out lp:TLayerPropRecord);
begin
  lp._On:=player^._on;
  lp.Freze:=false;
  lp.Lock:=player^._lock;
  lp.Name:={Tria_AnsiToUtf8}(player.Name);
  lp.PLayer:=player;
end;

class procedure TZTBZCADExtensions.CloseLayerDropDown;
var
  cdwg:PTSimpleDrawing;
begin
  CDWG:=drawings.GetCurrentDWG;
  if cdwg<>nil then
    if not cdwg^.GetCurrentLayer^._on then
      zcUI.TextMessage(rsCurrentLayerOff,TMWOMessageBox);
      //zcMsgDlg(rsCurrentLayerOff,zcdiWarning,[],false,nil,rsWarningCaption);
end;

class function TZTBZCADExtensions.ClickOnLayerProp(PLayer:Pointer;NumProp:integer;out newlp:TLayerPropRecord):boolean;
var
  cdwg:PTSimpleDrawing;
  tcl:PGDBLayerProp;
begin
  CDWG:=drawings.GetCurrentDWG;
  result:=false;
  if cdwg<>nil then begin
    case numprop of
      0:begin
        with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(CDWG)^.UndoStack,
                                                       TChangedBoolean.CreateRec(PGDBLayerProp(PLayer)^._on),
                                                       TSharedEmpty(Default(TEmpty)),
                                                       TAfterChangeEmpty(Default(TEmpty)))do begin
          PGDBLayerProp(PLayer)^._on:=not(PGDBLayerProp(PLayer)^._on);
        end;
        if PLayer=cdwg^.GetCurrentLayer then
          if not PGDBLayerProp(PLayer)^._on then
            zcUI.TextMessage(rsCurrentLayerOff,TMWOHistoryOut);
        end;
      {1:;}
      2:begin
        with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(CDWG)^.UndoStack,
                                                       TChangedBoolean.CreateRec(PGDBLayerProp(PLayer)^._lock),
                                                       TSharedEmpty(Default(TEmpty)),
                                                       TAfterChangeEmpty(Default(TEmpty)))do
        begin
          PGDBLayerProp(PLayer)^._lock:=not(PGDBLayerProp(PLayer)^._lock);
        end;
        end;
      3:begin
        if CDWG.wa.param.seldesc.Selectedobjcount=0 then begin
          if assigned(sysvar.dwg.DWG_CLayer) then
            if sysvar.dwg.DWG_CLayer^<>Player then begin
              with TPoinerChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(CDWG)^.UndoStack,
                                                            TChangedPointer.CreateRec(sysvar.dwg.DWG_CLayer^),
                                                            TSharedEmpty.CreateRec(Default(TEmpty)),
                                                            TAfterChangeEmpty.CreateRec(Default(TEmpty))) do
              begin
                  sysvar.dwg.DWG_CLayer^:=Player;
              end;
            end;
          if not PGDBLayerProp(PLayer)^._on then
            zcUI.TextMessage(rsCurrentLayerOff,TMWOHistoryOut);
        end else begin
          tcl:=SysVar.dwg.DWG_CLayer^;
          SysVar.dwg.DWG_CLayer^:=Player;
          commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent',CDWG,drawings.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CLayer^:=tcl;
        end;
        zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
        result:=true;
      end;
    end;
    setlayerstate(PLayer,newlp);
    if not result then begin
      zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
      zcRedrawCurrentDrawing;
    end;
  end;
end;

class function TZTBZCADExtensions.GetLayersArray(out la:TLayerArray):boolean;
var
  cdwg:PTSimpleDrawing;
  pcl:PGDBLayerProp;
  ir:itrec;
  counter:integer;
begin
  result:=false;
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    if assigned(cdwg^.wa.getviewcontrol) then begin
      la:=[];
      setlength(la,cdwg^.LayerTable.Count);
      counter:=0;
      pcl:=cdwg^.LayerTable.beginiterate(ir);
      if pcl<>nil then
        repeat
          setlayerstate(pcl,la[counter]);
          inc(counter);
          pcl:=cdwg^.LayerTable.iterate(ir);
        until pcl=nil;
      setlength(la,counter);
      if counter>0 then
        result:=true;
    end;
  end;
end;
class function TZTBZCADExtensions.GetLayerProp(PLayer:Pointer;out lp:TLayerPropRecord):boolean;
var
  cdwg:PTSimpleDrawing;
begin
  if player=nil then begin
    result:=false;
    cdwg:=drawings.GetCurrentDWG;
    if cdwg<>nil then begin
      if assigned(cdwg^.wa) then begin
        if IVars.CLayer<>nil then begin
          setlayerstate(IVars.CLayer,lp);
          result:=true;
        end else
          lp.Name:=rsDifferent;
      end;
    end;
  end else begin
    result:=true;
    setlayerstate(PLayer,lp);
  end;
end;

class procedure TZTBZCADExtensions.TBActionCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _action:TZAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');
  _action:=TZAction(actlist.ActionByName(ActionName));
  if _action=nil then begin
    _action:=TmyAction.Create(TB);
    _action.ActionList:=actlist;
    _action.Name:=ActionName;
  end;
  with TZToolButton.Create(tb) do
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
class procedure TZTBZCADExtensions.TBGroupActionCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  ActionIndex:integer;
  SubNode: TDomNode;
  i:integer;
  proxy:TPopUpMenyProxyAction;
  tmpBtn:TZToolButton;
  MPF:TMacroProcessFunc;
begin
  ActionIndex:=getAttrValue(aNode,'Index',0);
  tmpBtn:=TZToolButton.Create(tb);
  begin
    tmpBtn.ShowCaption:=false;
    tmpBtn.ShowHint:=true;
    tmpBtn.PopupMenu:=TPopupMenu.Create(application);
    tmpBtn.PopupMenu.Images:=actlist.Images;
    tmpBtn.Parent:=tb;
    tmpBtn.Visible:=true;

    if assigned(aNode) then
      SubNode:=aNode.FirstChild;
    if assigned(SubNode) then
      while assigned(SubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(TMenuType.TMT_PopupMenu,fmf,SubNode.NodeName,SubNode,actlist,tmenuitem(tmpBtn.PopupMenu){,mpf});
        SubNode:=SubNode.NextSibling;
      end;
    if (ActionIndex>=0)and(ActionIndex<tmpBtn.PopupMenu.Items.Count) then
      tmpBtn.action:=tmpBtn.PopupMenu.Items[ActionIndex].action;
    for i:=0 to tmpBtn.PopupMenu.Items.Count-1 do
    begin
      if assigned(tmpBtn.PopupMenu.Items[i].action)then begin
        proxy:=TPopUpMenyProxyAction.Create(Application);
        proxy.MainAction:=TAction(tmpBtn.PopupMenu.Items[i].action);
        proxy.ToolButton:=tmpBtn;
        proxy.Assign(tmpBtn.PopupMenu.Items[i].action);
        tmpBtn.PopupMenu.Items[i].action:=proxy;
        if proxy.MainAction.ImageIndex<>-1 then tmpBtn.caption:='';
      end;
    end;
  end;
end;

procedure SetImage(actlist:TActionList;ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);
var
  bmp:Graphics.TBitmap;
begin
  if length(img)>1 then begin
    if img[1]<>'#' then begin
      img:=ConcatPaths([GetRoCfgsPath,'menu/BMP',img]);
      bmp:=Graphics.TBitmap.create;
      try
        bmp.LoadFromFile(img);
        bmp.Transparent:=true;
        if not assigned(ppanel.Images) then
          ppanel.Images:=actlist.Images;
        b.ImageIndex:=
        ppanel.Images.Add(bmp,nil);
      except
        programlog.LogOutStr(sysutils.format('Image "%s" not not found',[img]),LM_Error);
      end;
      bmp.free;
    end else begin
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

class procedure TZTBZCADExtensions.TBButtonCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
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
  SetImage(actlist,tb,CreatedButton,img,true,'button_command~'+command);
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
          action.SecondaryShortCuts.AddObject(actionshortcut,TObject(MyTextToShortCut(actionshortcut)));
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
class procedure TZTBZCADExtensions.TBFindEditBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _Width:integer;
  FindEditBox:TFindEditBox;
begin
  _Width:=getAttrValue(aNode,'Width',100);
  FindEditBox:=TFindEditBox.Create(tb);
  FindEditBox.style:=csDropDown;
  FindEditBox.Parent:=tb;
  FindEditBox.Width:=_Width;
  updatescontrols.Add(FindEditBox);
  enabledcontrols.Add(FindEditBox);
end;

constructor TLayerComboBoxPopupFocusPriorityControl.Create(AOwner:TComponent);
begin
  inherited;
   zcUI.RegisterHandler_GetFocusedControl(GetLayerComboBoxPopupFocusPriority);
end;

destructor TLayerComboBoxPopupFocusPriorityControl.Destroy;
begin
  inherited;
end;

function TLayerComboBoxPopupFocusPriorityControl.GetLayerComboBoxPopupFocusPriority:TControlWithPriority;
var
  dd:TZCADDropDownForm;
begin
  dd:=TZCADLayerComboBox(Owner).GetDropDown;
  if assigned(dd) then
    if dd.Enabled then
      if dd.IsVisible then
        if dd.CanFocus then
          exit(TControlWithPriority.CreateRec(dd,PopupPriority));

  result:=TControlWithPriority.CreateRec(nil,UnPriority);
end;

class procedure TZTBZCADExtensions.TBLayerComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  LayerBox:TZCADLayerComboBox;
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

  LayerBox.fGetLayerProp:=TZTBZCADExtensions.GetLayerProp;
  LayerBox.fGetLayersArray:=TZTBZCADExtensions.GetLayersArray;
  LayerBox.fClickOnLayerProp:=TZTBZCADExtensions.ClickOnLayerProp;
  LayerBox.fonCloseDropDown:=TZTBZCADExtensions.CloseLayerDropDown;

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
  updatescontrols.Add(LayerBox);
  enabledcontrols.Add(LayerBox);
  TLayerComboBoxPopupFocusPriorityControl.Create(LayerBox);
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
  updatescontrols.Add(result);
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
                               //ZCADMainWindow.ShowAllCursors(ColorSelectForm);
                               zcUI.Do_BeforeShowModal(nil);
                               try
                                 mr:=ColorSelectForm.run(SysVar.dwg.DWG_CColor^,true){showmodal};
                                 if mr=ZCmrOK then begin
                                   ColorIndex:=ColorSelectForm.ColorInfex;
                                   if assigned(Sender)then begin
                                     AddToComboIfNeed(tcombobox(Sender),palette[ColorIndex].name,TObject(ColorIndex));
                                     tcombobox(Sender).ItemIndex:=tcombobox(Sender).Items.Count-2;
                                   end;
                                 end else begin
                                   tcombobox(Sender).ItemIndex:=OldColor;
                                   ColorIndex:=-1;
                                 end;
                               finally
                                 zcUI.Do_AfterShowModal(nil);
                               end;
                               //ZCADMainWindow.RestoreCursors(ColorSelectForm);
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
     zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
     //setnormalfocus(nil);
     zcUI.Do_SetNormalFocus;
end;
class procedure TZTBZCADExtensions.DropDownColor(Sender:Tobject);
begin
     OldColor:=tcombobox(Sender).ItemIndex;
     tcombobox(Sender).ItemIndex:=-1;
end;
class procedure TZTBZCADExtensions.CloseUp(Sender:Tobject);
begin
   zcUI.Do_SetNormalFocus;
end;

class procedure TZTBZCADExtensions.CloseUpColor(Sender:Tobject);
begin
  if tcombobox(Sender).ItemIndex=-1 then
    tcombobox(Sender).ItemIndex:=OldColor;
  CloseUp(Sender);
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
  if sender is TComboBox then begin
    s:=ConcatPaths([GetRoCfgsPath,CFScomponentsDir,(sender as TComboBox).text+'.xml']);
    LoadLayoutFromFile(s);
  end;
end;


procedure addfiletoLayoutbox(const filename:String;pdata:pointer);
var
    s:string;
begin
  if assigned(pdata) then begin
    s:=ExtractFileName(filename);
    TComboBox(pdata).AddItem(copy(s,1,length(s)-4),nil);
  end;
end;


class function TZTBZCADExtensions.CreateLayoutbox(tb:TToolBar):TComboBox;
var
    s:string;

begin
  result:=TComboBox.Create(tb);
  result.Style:=csDropDownList;
  result.Sorted:=true;
  FromDirsIterator(GetPathsInCfgsPaths(CFScomponentsDir),'*.xml','',addfiletoLayoutbox,nil,pointer(result));
  result.OnChange:=ChangeLayout;
  result.OnCloseUp:=CloseUp;

  s:=extractfilename(sysvar.PATH.LayoutFile^);
  result.ItemIndex:=result.Items.IndexOf(copy(s,1,length(s)-4));
end;

class procedure TZTBZCADExtensions.TBColorComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  ColorBox:TComboBox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  ColorBox:=CreateCBox('ColorComboBox',tb,TSupportColorCombo.ColorBoxDrawItem,ChangeCColor,DropDownColor,CloseUpColor,FillColorCombo,_Width,_hint);
  enabledcontrols.Add(ColorBox);
end;
class procedure TZTBZCADExtensions.TBLayoutComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  LayoutBox:tcombobox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  //ColorBox:=CreateCBox('ColorComboBox',tb,TSupportColorCombo.ColorBoxDrawItem,ChangeCColor,DropDownColor,DropUpColor,FillColorCombo,_Width,_hint);
  {  if assigned(LayoutBox) then
    zcUI.TextMessage(format(rsReCreating,['LAYOUTBOX']),TMWOShowError);}
  LayoutBox:=CreateLayoutbox(TB);
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
     zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
     //setnormalfocus(nil);
     zcUI.Do_SetNormalFocus;
end;

class procedure TZTBZCADExtensions.CloseUpLType(Sender:Tobject);
begin
  TComboBox(Sender).ItemIndex:=0;
  CloseUp(Sender);
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

class procedure TZTBZCADExtensions.TBLTypeComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  LTypeBox:TComboBox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LTypeBox:=CreateCBox('LTypeComboBox',tb,TSupportLineTypeCombo.LTypeBoxDrawItem,ChangeLType,DropDownLType,CloseUpLType,FillLTCombo,_Width,_hint);
  enabledcontrols.Add(LTypeBox);
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
  zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
  //setnormalfocus(nil);
  zcUI.Do_SetNormalFocus;
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


class procedure TZTBZCADExtensions.TBLineWComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  LineWBox:TComboBox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LineWBox:=CreateCBox('LineWComboBox',tb,TSupportLineWidthCombo.LineWBoxDrawIVarsItem,ChangeCLineW,DropDownColor,CloseUpColor,FillLWCombo,_Width,_hint);
  enabledcontrols.Add(LineWBox);
end;
class procedure TZTBZCADExtensions.TBTStyleComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  TStyleBox:TComboBox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  TStyleBox:=CreateCBox('TStyleComboBox',tb,TSupportTStyleCombo.DrawItemTStyle,TSupportTStyleCombo.ChangeLType,TSupportTStyleCombo.DropDownTStyle,TZTBZCADExtensions.CloseUpLType,TSupportTStyleCombo.FillLTStyle,_Width,_hint);
  enabledcontrols.Add(TStyleBox);
end;
class procedure TZTBZCADExtensions.TBDimStyleComboBoxCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
  DimStyleBox:TComboBox;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  DimStyleBox:=CreateCBox('DimStyleComboBox',tb,TSupportDimStyleCombo.DrawItemTStyle,TSupportDimStyleCombo.ChangeLType,TSupportDimStyleCombo.DropDownTStyle,TZTBZCADExtensions.CloseUpLType,TSupportDimStyleCombo.FillLTStyle,_Width,_hint);
  enabledcontrols.Add(DimStyleBox);
end;

class function TZTBZCADExtensions.TBCreateZCADToolBar(fmf:TForm;aName,aCaption,atype: string):TToolBar;
begin
  result:=TmyToolBar.Create(fmf);
  aCaption:=InterfaceTranslate(format(CToolBarCaptionTranslateFormat,[aName]),aCaption);
  ToolBarsManager.SetupDefaultToolBar(aName,aCaption,atype,result);
end;

class procedure TZTBZCADExtensions.TBVariableCreateFunc(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
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
    SetImage(actlist,tb,b,_img,false,'button_variable~'+_varname);;
  end;
  //AddToBar(tb,b);
  b.Parent:=tb;
  updatesbytton.Add(b);
  if _shortcut<>'' then
  begin
    shortcut:=MyTextToShortCut(_shortcut);
    if shortcut>0 then
    begin
      baction:=TmyButtonAction.Create(actlist);
      baction.button:=b;
      baction.ShortCut:=shortcut;
      actlist.AddMyAction(baction);
    end;
  end;
end;

initialization
  ToolBarsManager.RegisterTBItemCreateFunc('Action',TZTBZCADExtensions.TBActionCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('GroupAction',TZTBZCADExtensions.TBGroupActionCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('Button',TZTBZCADExtensions.TBButtonCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('FindEditBox',TZTBZCADExtensions.TBFindEditBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LayerComboBox',TZTBZCADExtensions.TBLayerComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LayoutComboBox',TZTBZCADExtensions.TBLayoutComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('ColorComboBox',TZTBZCADExtensions.TBColorComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LTypeComboBox',TZTBZCADExtensions.TBLTypeComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LineWComboBox',TZTBZCADExtensions.TBLineWComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('TStyleComboBox',TZTBZCADExtensions.TBTStyleComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('DimStyleComboBox',TZTBZCADExtensions.TBDimStyleComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('Variable',TZTBZCADExtensions.TBVariableCreateFunc);
  ToolBarsManager.RegisterActionCreateFunc('ZAction',TZTBZCADExtensions.ZActionsReader);
  ToolBarsManager.RegisterActionCreateFunc('ZAction2Variable',TZTBZCADExtensions.ZAction2VariableReader);
  ToolBarsManager.RegisterTBCreateFunc('ToolBar',TZTBZCADExtensions.TBCreateZCADToolBar);
  ToolBarsManager.RegisterTBItemCreateFunc('Separator',ToolBarsManager.CreateDefaultSeparator);
  ToolBarsManager.RegisterActionCreateFunc('Group',ToolBarsManager.DefaultActionsGroupReader);
finalization
end.
