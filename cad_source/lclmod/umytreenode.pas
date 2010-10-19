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

unit umytreenode;
{$INCLUDE def.inc}
interface

uses
  ComCtrls,StdCtrls,Controls,Classes,menus,Forms,{$IFDEF FPC}lcltype{$ENDIF},fileutil,ButtonPanel,Buttons,
  strproc,varmandef,Varman,UBaseTypeDescriptor,gdbasetypes,shared,SysInfo;
type
    TmyPopupMenu = class (TPopupMenu)
                   end;
    TmyCommandToolButton=class(TToolButton)
                  public
                  FCommand:String;{**<Command to manager commands}
                  protected procedure Click; override;
                  end;
    TmyVariableToolButton=class(TToolButton)
                  public
                  FVariable:String;{**<Command to manager commands}
                  FBufer:DWord;
                  procedure AssignToVar(varname:string);
                  protected procedure Click; override;
                  end;
    {**Modified TMenuItem}
    TmyMenuItem = class (TMenuItem)
                       public
                       FCommand:String;{**<Command to manager commands}
                       constructor create(TheOwner: TComponent;_Caption,_Command:TTranslateString);
                       procedure SetCommand(_Caption,_Command:TTranslateString);
                       protected
                       procedure Click; override;
                  end;
    TCreatedNode = class of TTreeNode;
    TmyTreeNode=class(TTreeNode)
               public
                    FCategory:String;
                    FPopupMenu:TmyPopupMenu;
                    procedure Select;virtual;
                    function GetParams:Pointer;virtual;
                    function ContextPopup(const X,Y: Integer):boolean;virtual;
               end;
    TmyTreeView=class(TTreeView)
               public
               NodeType:TCreatedNode;
               function CreateNode: TTreeNode; override;
               constructor Create(AnOwner: TComponent); override;

               procedure DoSelectionChanged; override;
               protected procedure DoContextPopup(const MousePos: TPoint; var Handled: Boolean); override;

    end;
  PTFreedForm=^TFreedForm;
  TFreedForm = class(tform)
                         private
                         PVariable:PTFreedForm;
                         procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
                         public
                         constructor myCreate(TheOwner: TComponent; _var:Pointer);
                    end;
  TDialogForm = class(tform)
                         DialogPanel: TButtonPanel;
                         procedure AfterConstruction; override;
                    end;
  TInfoForm = class(TDialogForm)
                         Memo: TMemo;
                         procedure AfterConstruction; override;
                    end;
  TmyPageControl=class(TPageControl)
                 procedure ChangePage(NewPage:Integer);virtual;
                 protected
                 //procedure DoChange;override;
                 end;

PIterateCmpareFunc=function(node:TmyTreeNode;PExpr:Pointer):Boolean;


function IterateFind(Node:TmyTreeNode; CompareFunc:PIterateCmpareFunc;PExpr:Pointer;SubFind:Boolean):TmyTreeNode;
function IterateFindCategoryN (node:TmyTreeNode;PExpr:Pointer):Boolean;
function FindControlByType(_parent:TWinControl;_class:TClass):TControl;
procedure SetHeightControl(_parent:TWinControl;h:integer);
implementation
uses commandline,log,sharedgdb;
function FindControlByType(_parent:TWinControl;_class:TClass):TControl;
var
    i:integer;
begin
     for i := 0 to _parent.ControlCount - 1 do
      if typeof(_parent.Controls[i]) = _class then
                              begin
                                   result:=_parent.Controls[i];
                                   exit;
                              end;
     result:=nil;
end;
procedure SetHeightControl(_parent:TWinControl;h:integer);
var
    i:integer;
begin
     for i := 0 to _parent.ControlCount - 1 do
      if typeof(_parent.Controls[i]) = TBitBtn then
                              begin
                                   _parent.Controls[i].Height:=h;
                              end;
end;
procedure TDialogForm.AfterConstruction;
begin
     inherited;
     //self.BorderIcons:=[biMinimize,biMaximize];
     self.Width:=sysparam.screenx div 2;
     self.Height:=sysparam.screeny div 2;
     self.Position:=poScreenCenter;
     self.BorderStyle:=bsSizeToolWin;
     DialogPanel:=TButtonPanel.create(self);
     DialogPanel.Align:=alBottom;
     DialogPanel.Parent:=self;
end;
procedure TInfoForm.AfterConstruction;
begin
     inherited;
     Memo:=TMemo.create(self);
     Memo.Align:=alClient;
     Memo.Parent:=self;
end;


procedure TmyPageControl.ChangePage(NewPage:Integer);
begin
end;
{procedure TmyPageControl.DoChange;
begin
     inherited;
     ChangePage(ActivePageIndex);
end;}
procedure TmyVariableToolButton.AssignToVar(varname:string);
var
   pvd:pvardesk;
begin
     FVariable:=varname;
     pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          if pvd^.data.PTD=@GDBBooleanDescriptorOdj then
                                                        begin
                                                             self.Down:=PGDBBoolean(pvd^.data.Instance)^;
                                                        end
          else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInGDBBytes then
                                                                    begin
                                                                         fbufer:=0;
                                                                         Move(pvd^.data.Instance^, FBufer,pvd^.data.PTD^.SizeInGDBBytes);
                                                                         if fbufer<>0 then
                                                                                         self.Down:=true;
                                                                    end;
     end;
end;
procedure TmyVariableToolButton.Click;
var
   pvd:pvardesk;
begin
     pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          if pvd^.data.PTD=@GDBBooleanDescriptorOdj then
                                                        begin
                                                             PGDBBoolean(pvd^.data.Instance)^:=not PGDBBoolean(pvd^.data.Instance)^;
                                                             self.Down:=PGDBBoolean(pvd^.data.Instance)^;
                                                        end
     else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInGDBBytes then
                                                               begin
                                                                    if not self.Down then
                                                                    begin
                                                                    fbufer:=0;
                                                                    Move(pvd^.data.Instance^, FBufer,pvd^.data.PTD^.SizeInGDBBytes);
                                                                    fillchar(pvd^.data.Instance^,pvd^.data.PTD^.SizeInGDBBytes,0);
                                                                    if fbufer<>0 then
                                                                                    self.Down:=false;
                                                                    end
                                                                    else
                                                                    begin
                                                                      if fbufer=0 then
                                                                                      fbufer:=1;
                                                                      begin
                                                                      Move( FBufer,pvd^.data.Instance^,pvd^.data.PTD^.SizeInGDBBytes);
                                                                      fbufer:=0;
                                                                      Move(pvd^.data.Instance^, FBufer,pvd^.data.PTD^.SizeInGDBBytes);

                                                                      if fbufer<>0 then
                                                                                      self.Down:=true;
                                                                      end;
                                                                    end;
                                                               end;
     end;
     redrawoglwnd;
end;
procedure TmyCommandToolButton.click;
begin
     commandmanager.executecommand(@Fcommand[1]);
     inherited;
end;

procedure TmyMenuItem.Click;
begin
     commandmanager.executecommand(@Fcommand[1]);
     inherited;
end;
procedure TmyMenuItem.SetCommand(_Caption,_Command:TTranslateString);
begin
     FCommand:=_Command;
     caption:=(_Caption);
     if _Command=''then
                       self.Enabled:=false
                   else
                       self.Enabled:=true;
end;

constructor TmyMenuItem.create(TheOwner: TComponent;_Caption,_Command:TTranslateString);
begin
     inherited create(TheOwner);
     SetCommand(_Caption,_Command);
end;


constructor TFreedForm.myCreate(TheOwner: TComponent; _var:Pointer);
begin
     inherited create(TheOwner);
     PVariable:=_var;
     self.onclose:=self.FormClose;
end;

procedure TFreedForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     CloseAction:=caFree;
     if CloseAction=caFree then
                               if assigned(PVariable) then
                                                          PVariable^:=nil;
end;

function TmyTreeNode.ContextPopup(const X,Y: Integer):boolean;
begin
     if assigned(FPopupMenu) then
                                 begin
                                      CommandManager.ContextCommandParams:=GetParams;
                                      FPopupMenu.popup(X, Y);
                                      result:=true;
                                 end
                             else
                                 result:=false;
end;
procedure TmyTreeView.DoContextPopup(const MousePos: TPoint; var Handled: Boolean);
var
   treenode:TmyTreeNode;
   ScrMousePos: TPoint;
begin
     inherited;
     if not handled then
     begin
          TTreeNode(treeNode) := GetNodeAt(MousePos.X, MousePos.Y);
          if assigned(treeNode) then
          begin
               ScrMousePos:=ClientToScreen(MousePos);
               Handled:=treenode.ContextPopup(ScrMousePos.X,ScrMousePos.Y);
          end;
     end;
end;
function IterateFindCategoryN (node:TmyTreeNode;PExpr:Pointer):Boolean;
begin
     if TmyTreeNode(node).FCategory=pstring(PExpr)^ then
                                            result:=true
                                        else
                                            result:=false;

end;
function IterateFind(Node:TmyTreeNode; CompareFunc:PIterateCmpareFunc;PExpr:Pointer;SubFind:Boolean):TmyTreeNode;
var
   q:boolean;
begin

  Result:=TmyTreeNode(Node.GetFirstChild);
  if result<>nil then
  repeat
        q:=CompareFunc(result,pexpr);

        if q then
                  exit;
        if subfind then
                       begin
                            result:=iterateFind(result,CompareFunc,pexpr,subfind);
                            if result<>nil then
                                               exit;
                       end;

        Result:=TmyTreeNode(Result.GetNextSibling);
  until result=nil;
end;
procedure TmyTreeNode.Select;
begin

end;
function TmyTreeNode.GetParams:Pointer;
begin
     result:=nil;
end;


constructor TmyTreeView.Create(AnOwner: TComponent);
begin
     inherited;
     NodeType:=TmyTreeNode;
end;
procedure TmyTreeView.DoSelectionChanged;
begin
     inherited;

     TmyTreeNode(Selected).Select;
end;

function TmyTreeView.CreateNode: TTreeNode;
begin
  Result := nil;
  if Assigned(OnCustomCreateItem) then
    OnCustomCreateItem(Self, Result);
  if Result = nil then
    Result := NodeType.Create(Items);
end;
initialization
{$IFDEF DEBUGINITSECTION}LogOut('umytreenode.initialization');{$ENDIF}
finalization
end.

