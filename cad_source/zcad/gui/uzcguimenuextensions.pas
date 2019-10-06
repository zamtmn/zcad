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

unit uzcguimenuextensions;
{$INCLUDE def.inc}

interface
uses
  {LCL}
      Laz2_DOM,
       ActnList,LCLType,LCLProc,uzctranslations,LCLIntf,
       Forms, stdctrls, ExtCtrls, ComCtrls,Controls,Classes,SysUtils,LazUTF8,
       menus,graphics,
  {ZCAD BASE}
       uzbpaths,
       //UGDBOpenArrayOfByte,uzbmemman,uzbtypesbase,uzbtypes,
       uzegeometry,uzcsysvars,uzbstrproc,uzclog,
       varmandef, varman,UUnitManager,uzcsysinfo,uzcshared,strmy,uzestylesdim,
  {ZCAD SIMPLE PASCAL SCRIPT}
       languade,
  {ZCAD ENTITIES}
       uzeentity,uzestyleslayers,
       uzeblockdef,uzcdrawings,uzeenttext,
  {ZCAD COMMANDS}
       uzccommandsmanager,
  {GUI}
       uzmenusdefaults,uzmenusmanager,uztoolbarsmanager,uzcfcommandline,uzctreenode,uzcctrlcontextmenu,
       uzcimagesmanager,
  {}
       uzcguimanager;
type
  PTDummyMyActionsArray=^TDummyMyActionsArray;
  TDummyMyActionsArray=Array [0..0] of TmyAction;
  TFileHistory=Array [0..9] of TmyAction;
  TOpenedDrawings=Array [0..9] of TmyAction;
  TCommandHistory=Array [0..9] of TmyAction;

  ZMenuExt = class
    class procedure ZMenuExtMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtPopUpMenuReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtAction(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtFileHistory(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtCommandsHistory(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtCommand(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtToolBars(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtToolPalettes(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtDrawings(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtSampleFiles(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure ZMenuExtDebugFiles(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);

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
implementation

function FindMenuItem(name,localizedcaption:string;RootMenuItem:TMenuItem):TMenuItem;
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
end;

procedure bugfileiterator(filename:String);
var
    myitem:TmyMenuItem;
begin
  myitem:=TmyMenuItem.Create(localpm.localpm,'**'+extractfilename(filename),'Load('+filename+')');
  localpm.localpm.SubMenuImages:=ImagesManager.IconList;
  myitem.ImageIndex:=localpm.ImageIndex;
  localpm.localpm.Add(myitem);
end;


class procedure ZMenuExt.ZMenuExtSampleFiles(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex('Dxf');
  FromDirIterator(expandpath('*/sample'),'*.dxf','',@bugfileiterator,nil);
  FromDirIterator(expandpath('*/sample'),'*.dwg','',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;

class procedure ZMenuExt.ZMenuExtDebugFiles(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex('Dxf');
  FromDirIterator(expandpath('*../errors/'),'*.dxf','',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;


class procedure ZMenuExt.ZMenuExtAction(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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
    TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
end;

class procedure ZMenuExt.ZMenuExtMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
 var
  CreatedMenuItem:TMenuItem;
  line,localizedcaption:string;
  TBSubNode:TDomNode;
  newitem:boolean;
begin
    line:=getAttrValue(aNode,'Name','');
    localizedcaption:=InterfaceTranslate('menu~'+line,line);
    CreatedMenuItem:=FindMenuItem(line,localizedcaption,RootMenuItem);
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
    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    if (assigned(RootMenuItem))and newitem then
    begin
      if RootMenuItem is TMenuItem then
        RootMenuItem.Add(CreatedMenuItem)
      else
        TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
    end;
end;


class procedure ZMenuExt.ZMenuExtPopUpMenuReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
 var
  CreatedMenuItem:TPopupMenu;
  line:string;
  TBSubNode:TDomNode;
begin
    CreatedMenuItem:=TmyPopupMenu.Create(application);
    line:=getAttrValue(aNode,'Name','');
    CreatedMenuItem.Name:=MenuNameModifier+line;
    CreatedMenuItem.Images := actlist.Images;

    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        TMenuDefaults.TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,actlist,tmenuitem(CreatedMenuItem));
        TBSubNode:=TBSubNode.NextSibling;
      end;
    cxmenumgr.RegisterLCLMenu(CreatedMenuItem);
end;

class procedure ZMenuExt.ZMenuExtFileHistory(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
 i:integer;
 pstr:pstring;
 line:string;
 CreatedMenuItem:TMenuItem;
begin
  for i:=low(FileHistory) to high(FileHistory) do
  begin
       pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
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

class procedure ZMenuExt.ZMenuExtCommandsHistory(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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
                              TMyPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
  end;
end;

class procedure ZMenuExt.ZMenuExtCommand(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  CreatedMenuItem:TmyMenuItem;
  captionstr,comstr:string;
begin
  captionstr:=getAttrValue(aNode,'Caption','');
  comstr:=getAttrValue(aNode,'Command','');
  CreatedMenuItem:=TmyMenuItem.Create(RootMenuItem,InterfaceTranslate('menucommand~'+comstr,captionstr),comstr);
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
end;

class procedure ZMenuExt.ZMenuExtToolBars(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  ToolBarsManager.EnumerateToolBars(TTBRegisterInAPPFunc,RootMenuItem);
end;

class procedure ZMenuExt.ZMenuExtToolPalettes(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  ToolBarsManager.EnumerateToolPalettes(TTPRegisterInAPPFunc,RootMenuItem);
end;


class procedure ZMenuExt.ZMenuExtDrawings(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

class procedure ZMenuExt.TTBRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);
var
    pm1:TMenuItem;
    action:tmyaction;
begin
  action:=TmyAction.Create(fmf);
  action.Name:=ToolBarNameToActionName(aName);
  action.Caption:=aName;
  action.command:='ShowToolBar';
  action.options:=aName;
  action.DisableIfNoHandler:=false;
  actlist.AddMyAction(action);
  action.pfoundcommand:=commandmanager.FindCommand(action.command);
  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=action;
  TMenuItem(Data).Add(pm1);
end;
class procedure ZMenuExt.TTPRegisterInAPPFunc(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer);
var
    pm1:TMenuItem;
    action:tmyaction;
begin
  action:=TmyAction.Create(fmf);
  action.Name:=ToolPaletteNameToActionName(aName);
  action.Caption:=aName;
  action.command:='Show';
  action.options:=ToolPaletteNamePrefix+aName;
  action.DisableIfNoHandler:=false;
  actlist.AddMyAction(action);
  action.pfoundcommand:=commandmanager.FindCommand(action.command);
  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=action;
  TMenuItem(Data).Add(pm1);
end;

initialization
finalization
end.

