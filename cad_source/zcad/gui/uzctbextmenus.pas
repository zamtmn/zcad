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

unit uzctbextmenus;
{$INCLUDE zengineconfig.inc}

interface
uses
  {LCL}
    Laz2_DOM,
    ActnList,LCLType,LCLProc,uzctranslations,LCLIntf,
    Forms, ExtCtrls, ComCtrls,Controls,Classes,SysUtils,LazUTF8,
    menus,graphics,
  {ZCAD BASE}
    uzbpaths,
    uzegeometry,uzcsysvars,uzbstrproc,uzclog,
    uzsbVarmanDef, varman,UUnitManager,uzestylesdim,
  {ZCAD SIMPLE PASCAL SCRIPT}
       //languade,
  {ZCAD ENTITIES}
       uzeentity,uzestyleslayers,
       uzeblockdef,{uzcdrawings,}uzeenttext,
  {ZCAD COMMANDS}
       uzccommandsmanager,
  {GUI}
       uzmenusdefaults,uzmenusmanager,uztoolbarsmanager,uzcfcommandline,uzctreenode,uzcctrlcontextmenu,
       uzcimagesmanager,
  {}
       uzmacros,uzxmlnodesutils,
       uzcguimanager,
    uzcFileStructure;
type
  PTDummyMyActionsArray=^TDummyMyActionsArray;
  TDummyMyActionsArray=Array [0..0] of TmyAction;
  TFileHistory=Array [0..9] of TmyAction;
  TOpenedDrawings=Array [0..9] of TmyAction;
  TCommandHistory=Array [0..9] of TmyAction;

  ZMenuExt = class
    class procedure ZMenuExtMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtMainMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtPopUpMenuReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtAction(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtFileHistory(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtCommandsHistory(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtCommand(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtToolBars(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtToolPalettes(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtDrawings(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtSampleFiles(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure ZMenuExtDebugFiles(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);

    class procedure TTBRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);
    class procedure TTPRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);

  end;
  TFiletoMenuIteratorData=record
                                localpm:TMenuItem;
                                ImageIndex:Integer;
                          end;
var
  FileHistory:TFileHistory;
  CommandsHistory:TCommandHistory;
  OpenedDrawings:TOpenedDrawings;

  localpm:TFiletoMenuIteratorData;
function CreateTBShowAction(AAcnName:string;ATBName,ATBCaption:string;AAcnLst:TActionList):TmyAction;
implementation

const
  CDxfMask='*.dxf';
  CDwgMask='*.dwg';
  CDxf='Dxf';
  CParentDir='..';

{function FindMenuItem(name,localizedcaption:string;RootMenuItem:TMenuItem):TMenuItem;
var
  i:integer;
begin
  result:=nil;
  if RootMenuItem=nil then
    result:=TMenuItem(application.FindComponent(MenuNameModifier+name))
  else begin
    for i:=0 to RootMenuItem.Count-1 do begin
      if RootMenuItem.Items[i].Caption=localizedcaption then
        exit(RootMenuItem.Items[i]);
    end;
  end;
end;}

procedure bugfileiterator(filename:String);
var
    myitem:TmyMenuItem;
begin
  myitem:=TmyMenuItem.Create(localpm.localpm,'**'+extractfilename(filename),'Load('+filename+')');
  localpm.localpm.SubMenuImages:=ImagesManager.IconList;
  myitem.ImageIndex:=localpm.ImageIndex;
  localpm.localpm.Add(myitem);
end;


class procedure ZMenuExt.ZMenuExtSampleFiles(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex(CDxf);
  FromDirIterator(GetPathsInDistribPath(CFSexamplesDir),CDxfMask,'',@bugfileiterator,nil);
  FromDirIterator(GetPathsInDistribPath(CFSexamplesDir),CDwgMask,'',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;

class procedure ZMenuExt.ZMenuExtDebugFiles(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex(CDxf);
  FromDirIterator(ExpandPath(ConcatPaths([GetBinaryPath,CParentDir,CParentDir,CParentDir,CFSerrorsDir])),CDxfMask,'',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;

class procedure ZMenuExt.ZMenuExtMainMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
 var
  CreatedMenuItem:TMenuItem;
  RootMenu:TMenu;
  //createdmenu:TMenu;
  line,localizedcaption:string;
  TBSubNode:TDomNode;
  newitem:boolean;
begin
    line:=getAttrValue(aNode,'Name','');
    localizedcaption:=InterfaceTranslate('menu~'+line,line);

    if RootMenuItem=nil then begin
      RootMenu:=TMainMenu.Create(application);
      RootMenu.Images:=actlist.Images;
      RootMenu.Name:=MenuNameModifier+getAttrValue(aNode,'Name','');
      tobject(CreatedMenuItem):=RootMenu;
      //CreatedMenuItem:=RootMenuItem;
    end
    else
      CreatedMenuItem:=nil;
    //CreatedMenuItem:=FindMenuItem(line,localizedcaption,RootMenuItem);

    //newitem:=true;
    //if MT=TMenuType.TMT_PopupMenu then begin
    if CreatedMenuItem=nil then begin
      CreatedMenuItem:=TMenuItem.Create(application);
      newitem:=true;
    end else
      newitem:=false;
    if newitem then begin
      if RootMenuItem=nil then
        CreatedMenuItem.Name:=MenuNameModifier+line;
      CreatedMenuItem.Caption:=localizedcaption;
    end;
    //end else begin
    //  CreatedMenuItem:=RootMenuItem;
    //end;
    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem,mpf);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    if (assigned(RootMenuItem))and newitem then
    begin
      if RootMenuItem is TMenuItem then
        RootMenuItem.Add(CreatedMenuItem)
      else
         TMenu(TObject(RootMenuItem)).Items.Add(CreatedMenuItem);
    end;
end;
class procedure ZMenuExt.ZMenuExtPopUpMenuReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
 var
  CreatedMenuItem:TPopupMenu;
  line,localizedcaption:string;
  TBSubNode:TDomNode;
begin
    line:=getAttrValue(aNode,'Name','');
    localizedcaption:=InterfaceTranslate('menu~'+line,line);

    if RootMenuItem=nil then  begin
      CreatedMenuItem:=TPopupMenu.Create(application);
      CreatedMenuItem.Name:=MenuNameModifier+line;
      CreatedMenuItem.Images := actlist.Images;
    end else begin
      CreatedMenuItem:=TPopupMenu(TObject(RootMenuItem));
    end;

    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,TBSubNode.NodeName,TBSubNode,actlist,tmenuitem(tobject(CreatedMenuItem)),mpf);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    cxmenumgr.RegisterLCLMenu(CreatedMenuItem);
end;
class procedure ZMenuExt.ZMenuExtMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
//var
//  createdmenu:TMenu;
begin
    case MT of
      TMT_MainMenu:begin
                     {if RootMenuItem=nil then begin
                       createdmenu:=TMainMenu.Create(application);
                       createdmenu.Images:=actlist.Images;
                       createdmenu.Name:=MenuNameModifier+getAttrValue(aNode,'Name','');
                     end;}
                       ZMenuExt.ZMenuExtMainMenuItemReader(MT,fmf,aName,aNode,actlist,RootMenuItem{tmenuitem(createdmenu)},MPF);
                   end;
     TMT_PopupMenu:ZMenuExt.ZMenuExtPopUpMenuReader(MT,fmf,aName,aNode,actlist,RootMenuItem,MPF);
    end;
end;
class procedure ZMenuExt.ZMenuExtFileHistory(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
 i:integer;
 pstr:pstring;
 line:string;
 CreatedMenuItem:TMenuItem;
begin
  for i:=low(FileHistory) to high(FileHistory) do
  begin
       pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i)).data.Addr.Instance;
       if assigned(pstr)then
                            line:=pstr^
                        else
                            line:='';
       if line<>''then
                              begin
                              FileHistory[i].SetCommand(line,'Load',line);
                              FileHistory[i].visible:=true;
                              end
                        else
                            begin
                            FileHistory[i].SetCommand(line,'',line);
                            FileHistory[i].visible:=false
                            end;
       CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
       CreatedMenuItem.Action:=FileHistory[i];
       RootMenuItem.Add(CreatedMenuItem);
  end;
end;

class procedure ZMenuExt.ZMenuExtCommandsHistory(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
 i:integer;
 CreatedMenuItem:TMenuItem;
begin
  for i:=low(CommandsHistory) to high(CommandsHistory) do
  begin
       CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
       CreatedMenuItem.Action:=CommandsHistory[i];
       if RootMenuItem is TMenuItem then
                              RootMenuItem.Add(CreatedMenuItem)
                          else
                              TPopUpMenu(TObject(RootMenuItem)).Items.Add(CreatedMenuItem);
  end;
end;

class procedure ZMenuExt.ZMenuExtCommand(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  CreatedMenuItem:TmyMenuItem;
  captionstr,comstr,faceactionname:string;
  _action:TContainedAction;
begin
  captionstr:=getAttrValue(aNode,'Caption','');
  comstr:=getAttrValue(aNode,'Command','');
  if assigned(mpf)then
    mpf(comstr);
  faceactionname:=getAttrValue(aNode,'FaceAction','');
  if faceactionname<>'' then
    _action:=actlist.ActionByName(faceactionname)
  else
    _action:=nil;
  CreatedMenuItem:=TmyMenuItem.Create(RootMenuItem,InterfaceTranslate('menucommand~'+comstr,captionstr),comstr);
  if _action<>nil then
    CreatedMenuItem.Action:=_action;
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(TObject(RootMenuItem)).Items.Add(CreatedMenuItem);
end;

class procedure ZMenuExt.ZMenuExtAction(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  CreatedMenuItem:TMenuItem;
  _action:TContainedAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');

  _action:=actlist.ActionByName(ActionName);
  if _action=nil then begin
    _action:=TmyAction.Create(fmf);
    _action.ActionList:=actlist;
    _action.Name:=ActionName;
  end;

  CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
  CreatedMenuItem.Action:=_action;
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(TObject(RootMenuItem)).Items.Add(CreatedMenuItem);
end;

class procedure ZMenuExt.ZMenuExtToolBars(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  ToolBarsManager.EnumerateToolBars(TTBRegisterInAPPFunc,RootMenuItem);
end;

class procedure ZMenuExt.ZMenuExtToolPalettes(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  ToolBarsManager.EnumerateToolPalettes(TTPRegisterInAPPFunc,RootMenuItem);
end;


class procedure ZMenuExt.ZMenuExtDrawings(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  i:integer;
  CreatedMenuItem:TMenuItem;
begin
  for i:=low(OpenedDrawings) to high(OpenedDrawings) do
  begin
    CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
    CreatedMenuItem.Action:=OpenedDrawings[i];
    RootMenuItem.Add(CreatedMenuItem);
  end;
end;

function CreateTBShowAction({fmf:TForm;}AAcnName:string;ATBName,ATBCaption:string;AAcnLst:TActionList):TmyAction;
begin
  result:=TmyAction.Create({fmf}AAcnLst);
  result.Name:=AAcnName;
  result.Caption:=ATBCaption;
  result.command:='ShowToolBar';
  result.options:=ATBName;
  result.DisableIfNoHandler:=false;
  AAcnLst.AddMyAction(result);
  result.pfoundcommand:=commandmanager.FindCommand(result.command);
end;

class procedure ZMenuExt.TTBRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);
var
    pm1:TMenuItem;
    action:tmyaction;
    acnname:string;
begin
  acnname:=ToolBarNameToActionName(aName);
  action:=tmyaction(actlist.ActionByName(acnname));
  if action=nil then begin
    action:=TmyAction.Create(fmf);
    action.Name:=acnname;
    action.Caption:=aName;
    action.command:='ShowToolBar';
    action.options:=aName;
    action.DisableIfNoHandler:=false;
    actlist.AddMyAction(action);
    action.pfoundcommand:=commandmanager.FindCommand(action.command);
  end;
  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=action;
  TMenuItem(Data).Add(pm1);
end;
class procedure ZMenuExt.TTPRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);
var
    pm1:TMenuItem;
    action:tmyaction;
    acnname:string;
begin
  acnname:=ToolPaletteNameToActionName(aName);
  action:=tmyaction(actlist.ActionByName(acnname));
  if action=nil then begin
    action:=TmyAction.Create(fmf);
    action.Name:=ToolPaletteNameToActionName(aName);
    action.Caption:=aName;
    action.command:='Show';
    action.options:=ToolPaletteNamePrefix+aName;
    action.DisableIfNoHandler:=false;
    actlist.AddMyAction(action);
    action.pfoundcommand:=commandmanager.FindCommand(action.command);
  end;
  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=action;
  TMenuItem(Data).Add(pm1);
end;

initialization
  TMenuDefaults.RegisterMenuCreateFunc('SubMenu',ZMenuExt.ZMenuExtMainMenuItemReader);
  TMenuDefaults.RegisterMenuCreateFunc('Menu',ZMenuExt.ZMenuExtMenuItemReader);
  TMenuDefaults.RegisterMenuCreateFunc('Action',ZMenuExt.ZMenuExtAction);
  TMenuDefaults.RegisterMenuCreateFunc('FileHistory',ZMenuExt.ZMenuExtFileHistory);
  TMenuDefaults.RegisterMenuCreateFunc('LastCommands',ZMenuExt.ZMenuExtCommandsHistory);
  TMenuDefaults.RegisterMenuCreateFunc('Command',ZMenuExt.ZMenuExtCommand);
  TMenuDefaults.RegisterMenuCreateFunc('Toolbars',ZMenuExt.ZMenuExtToolBars);
  TMenuDefaults.RegisterMenuCreateFunc('ToolPalettes',ZMenuExt.ZMenuExtToolPalettes);
  TMenuDefaults.RegisterMenuCreateFunc('Drawings',ZMenuExt.ZMenuExtDrawings);
  TMenuDefaults.RegisterMenuCreateFunc('SampleFiles',ZMenuExt.ZMenuExtSampleFiles);
  TMenuDefaults.RegisterMenuCreateFunc('DebugFiles',ZMenuExt.ZMenuExtDebugFiles);

  TMenuDefaults.RegisterMenuCreateFunc('CreateMenu',TMenuDefaults.DefaultCreateMenu);
  TMenuDefaults.RegisterMenuCreateFunc('InsertMenuContent',TMenuDefaults.DefaultInsertMenuContent);
  TMenuDefaults.RegisterMenuCreateFunc('InsertMenu',TMenuDefaults.DefaultInsertMenu);
  TMenuDefaults.RegisterMenuCreateFunc('SetMainMenu',TMenuDefaults.DefaultSetMenu);
  TMenuDefaults.RegisterMenuCreateFunc('Separator',TMenuDefaults.DefaultCreateMenuSeparator);
finalization
end.

