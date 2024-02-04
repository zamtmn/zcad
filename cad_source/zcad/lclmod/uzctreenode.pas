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

unit uzctreenode;
{$INCLUDE zengineconfig.inc}
interface

uses
  {$IFDEF LCLWIN32}win32proc,{$endif}
  sysutils,Themes,ExtCtrls,lclproc,Graphics,ActnList,ComCtrls,
  Controls,Classes,menus,Forms,lcltype,LazUTF8,Buttons,
  uzcinterface,uzccommandsabstract,
  uzcutils,uzbpaths,uzctranslations,varmandef,
  uzccommandsmanager,uzclog,uzcdrawings,Varman,UBaseTypeDescriptor;
type
    TZAction=class(TAction)
                   public
                     imgstr:string;
                   public
                     constructor Create(AOwner: TComponent); override;
              end;
    TmyVariableAction=class(TZAction)
                      public
                        FVariable:String;
                        FBufer:DWord;
                        FMask:DWord;
                        procedure AssignToVar(varname:string;mask:DWord);
                        function Execute: Boolean; override;
                      end;
    TmyAction=class(TZAction)
                   public
                   command,options{,imgstr}:string;
                   pfoundcommand:PCommandObjectDef;
                   function Execute: Boolean; override;
                   procedure SetCommand(_Caption,_Command,_Options:TTranslateString);
              end;
    TmyButtonAction=class(TZAction)
                   public
                   button:TToolButton;
                   function Execute: Boolean; override;
              end;
    TMyActionListHelper = class helper for TActionList
      procedure AddMyAction(Action:TZAction);
      function LoadImage(imgfile:String):Integer;
      procedure SetImage(img,identifer:string;var action:TZAction);
    end;
    TmyCommandToolButton=class({Tmy}TToolButton)
                  public
                  FCommand:String;{**<Command to manager commands}
                  procedure Click; override;
                  end;
    TmyVariableToolButton=class({Tmy}TToolButton)
                  public
                  FVariable:String;{**<Command to manager commands}
                  FBufer:DWord;
                  FMask:DWord;
                  procedure AssignToVar(varname:string;mask:DWord);
                  procedure Click; override;
                  end;
    {**Modified TMenuItem}
    TmyMenuItem = class (TMenuItem)
                       public
                       FCommand:String;{**<Command to manager commands}
                       FSilent:Boolean;
                       constructor create(TheOwner: TComponent;_Caption,_Command:TTranslateString);overload;
                       procedure SetCommand(_Caption,_Command:TTranslateString);
                       procedure Click; override;
                  end;
    TCreatedNode = class of TTreeNode;
    TmyTreeNode=class(TTreeNode)
               public
                    FCategory:String;
                    FPopupMenu:TPopupMenu;
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
               protected procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    end;
    TZToolButton=class(TToolButton)
     protected
      procedure Paint; override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
      procedure MouseLeave;override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      procedure KillPopupTimer(Sender: TObject);
      procedure SetPopupTimer(Sender: TObject);
      procedure ShowPopUp(Sender: TObject);
    end;

  PTFreedForm=^TFreedForm;
  TFreedForm = class(tform)
                         private
                         PVariable:PTFreedForm;
                         public
                         procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);virtual;
                         constructor myCreate(TheOwner: TComponent; _var:Pointer);
                    end;
  TToolButtonForm = class(tform{tpanel})
                         procedure AfterConstruction; override;
                         //public
                         //procedure GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                         //                               Raw: boolean = false;
                         //                               WithThemeSpace: boolean = true); override;

                    end;
  TmyPageControl=class(TPageControl)
                 procedure ChangePage(NewPage:Integer);virtual;
                 protected
                 procedure DoChange;override;
                 end;
  TMySpeedButton = class(TCustomSpeedButton)
  protected
    function GetDrawDetails: TThemedElementDetails; override;
    procedure CalculatePreferredSize(var PreferredWidth,
           PreferredHeight: integer; {%H-}WithThemeSpace: Boolean); override;
  end;

PIterateCmpareFunc=function(node:TmyTreeNode;PExpr:Pointer):Boolean;


function IterateFind(Node:TmyTreeNode; CompareFunc:PIterateCmpareFunc;PExpr:Pointer;SubFind:Boolean):TmyTreeNode;
function IterateFindCategoryN (node:TmyTreeNode;PExpr:Pointer):Boolean;
function FindControlByType(_parent:TWinControl;_class:TClass):TControl;
function FindComponentByType(_owner:TComponent;_class:TClass):TComponent;
procedure SetHeightControl(_parent:TWinControl;h:integer);
var
  brocenicon:integer;
  PopUpTimer:TTimer=nil;
  ButtonPopUpInterval:integer=800;
//   ACN_ShowObjInsp:TmyAction=nil;
implementation

procedure TZToolButton.Paint;
var
  PaintRect:TRect;
  Details:TThemedElementDetails;
begin
  inherited;
  if assigned(PopupMenu) then begin
    Details:=ThemeServices.GetElementDetails({$IFDEF LCLWIN32}ttbSplitButtonDropDownNormal{$ENDIF}
                                             {$IFDEF LCLQT}tsDownNormal{$ENDIF}
                                             {$IFDEF LCLQT5}tsDownNormal{$ENDIF}
                                             {$IFDEF LCLQT6}tsDownNormal{$ENDIF}
                                             {$IFDEF LCLgtk2}ttbSplitButtonDropDownNormal{$ENDIF}
                                             {$IFDEF LCLgtk3}ttbSplitButtonDropDownNormal{$ENDIF}
                                             {$IFDEF LCLcocoa}ttbSplitButtonDropDownNormal{$ENDIF}
                                             );
    PaintRect:=ClientRect;
    {$IFDEF LCLWIN32}if WindowsVersion<wvVista then begin
                        PaintRect.Top:=PaintRect.Bottom;PaintRect.Left:=6*PaintRect.Right div 11//это работает в XP тут нужно подобрать коэффициенты
                     end else begin
                        PaintRect.Top:=2*PaintRect.Bottom div 3;PaintRect.Left:=2*PaintRect.Right div 3 //это XP висте и выше
                     end;{$ENDIF}
    {$IFDEF LCLQT}PaintRect.Top:=PaintRect.Bottom div 2;PaintRect.Left:=2*PaintRect.Right div 3;{$ENDIF}
    {$IFDEF LCLQT5}PaintRect.Top:=PaintRect.Bottom div 2;PaintRect.Left:=2*PaintRect.Right div 3;{$ENDIF}
    {$IFDEF LCLQT6}PaintRect.Top:=PaintRect.Bottom div 2;PaintRect.Left:=2*PaintRect.Right div 3;{$ENDIF}
    {$IFDEF LCLGTK2}PaintRect.Top:=2*PaintRect.Bottom div 3;PaintRect.Left:=PaintRect.Right div 2;{$ENDIF}
    {$IFDEF LCLGTK3}PaintRect.Top:=2*PaintRect.Bottom div 3;PaintRect.Left:=PaintRect.Right div 2;{$ENDIF}
    ThemeServices.DrawElement(Canvas.Handle,Details,PaintRect)
  end;
end;
procedure TZToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if assigned(PopupMenu) then begin
    SetPopupTimer(self);
  end;
end;
procedure TZToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if assigned(PopupMenu) then begin
    KillPopupTimer(self);
  end;
end;
procedure TZToolButton.MouseLeave;
begin
  inherited;
  KillPopupTimer(self);
end;
procedure TZToolButton.KillPopupTimer(Sender: TObject);
begin
  if assigned(PopUpTimer) then begin
   PopUpTimer.Enabled:=false;
   PopUpTimer.OnTimer:=nil;
  end;
end;

procedure TZToolButton.SetPopupTimer(Sender: TObject);
begin
  if PopUpTimer=nil then
    PopUpTimer:=TTimer.Create(nil);
  PopUpTimer.Interval:=ButtonPopUpInterval;
  PopUpTimer.Enabled:=true;
  PopUpTimer.OnTimer:=Self.ShowPopUp;
end;
procedure TZToolButton.ShowPopUp(Sender: TObject);
begin
  if assigned(PopupMenu) then begin
    KillPopupTimer(nil);
    PopupMenu.PopUp;
  end;
end;

function TMySpeedButton.GetDrawDetails: TThemedElementDetails;

  function WindowPart: TThemedScrollBar;
    begin
      // no check states available
      Result := tsArrowBtnDownNormal;
      if not IsEnabled then
        Result := tsArrowBtnDownDisabled
      else
      if FState in [bsDown, bsExclusive] then
        Result := tsArrowBtnDownPressed
      else
      if FState = bsHot then
        Result := tsArrowBtnDownHot
      else
        Result := tsArrowBtnDownNormal;
    end;

  begin
    Result := ThemeServices.GetElementDetails(WindowPart);
  end;

  procedure TMySpeedButton.CalculatePreferredSize(var PreferredWidth,
    PreferredHeight: integer; WithThemeSpace: Boolean);
  begin
    with ThemeServices.GetDetailSize(ThemeServices.GetElementDetails(tsArrowBtnDownNormal)) do
    begin
      PreferredWidth:=cx;
      PreferredHeight:=1;
    end;
  end;
procedure TmyAction.SetCommand(_Caption,_Command,_Options:TTranslateString);
begin
     command:=_Command;
     options:=_Options;
     caption:=(_Caption);
     if _Command=''then
                       self.Enabled:=false
                   else
                       self.Enabled:=true;
end;
function TmyButtonAction.Execute: Boolean;
begin
     result:=false;
     if assigned(button) then
       if button.enabled then
         begin
           //button.
           if (button.Style = tbsCheck) then
                                     button.Down := not button.Down;
           button.Click;
           result:=true;
         end;
end;
function TmyVariableAction.Execute;
var
   pvd:pvardesk;
   accum:byte;
   pv,pm:pbyte;
   i:integer;
begin
  result:=true;
  pvd:=nil;
  if DWGUnit<>nil then
  pvd:=DWGUnit^.InterfaceVariables.findvardesc(FVariable);
  if pvd=nil then
  pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          if pvd^.data.PTD.getfacttypedef=@FundamentalBooleanDescriptorOdj then
                                                        begin
                                                             PBoolean(pvd^.data.Addr.Instance)^:=not PBoolean(pvd^.data.Addr.Instance)^;
                                                             Checked:=PBoolean(pvd^.data.Addr.Instance)^;
                                                        end
          else if fmask<>0 then
                               begin
                                    pv:=pvd^.data.Addr.Instance;
                                    pm:=@Fmask;
                                    accum:=0;
                                    for i:=1 to pvd^.data.PTD^.SizeInBytes do
                                     begin
                                          pv^:=pv^ xor pm^;
                                          accum:=accum or(pv^ and pm^);
                                          inc(pv);
                                          inc(pm);
                                     end;
                                    if accum<>0 then
                                                    Checked:=true
                                                else
                                                    Checked:=false;
                               end
     else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInBytes then
                                                               begin
                                                                    if not Checked then
                                                                    begin
                                                                    fbufer:=0;
                                                                    Move(pvd^.data.Addr.Instance^, FBufer,pvd^.data.PTD^.SizeInBytes);
                                                                    fillchar(pvd^.data.Addr.Instance^,pvd^.data.PTD^.SizeInBytes,0);
                                                                    if fbufer<>0 then
                                                                                    Checked:=false;
                                                                    end
                                                                    else
                                                                    begin
                                                                      if fbufer=0 then
                                                                                      fbufer:=1;
                                                                      begin
                                                                      Move( FBufer,pvd^.data.Addr.Instance^,pvd^.data.PTD^.SizeInBytes);
                                                                      fbufer:=0;
                                                                      Move(pvd^.data.Addr.Instance^, FBufer,pvd^.data.PTD^.SizeInBytes);

                                                                      if fbufer<>0 then
                                                                                      Checked:=true;
                                                                      end;
                                                                    end;
                                                               end;
     end;
     zcRedrawCurrentDrawing;
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionRedraw);
     //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
end;

procedure TmyVariableAction.AssignToVar(varname:string;mask:DWord);
var
   pvd:pvardesk;
   accum:byte;
   pv,pm:pbyte;
   i:integer;
   tBufer:DWord;
begin
//     if varname='DWG_DrawMode' then
//                                     varname:=varname;
     FVariable:=varname;
     Fmask:=mask;
     pvd:=nil;
     if DWGUnit<>nil then
     pvd:=DWGUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd=nil then
     pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          enabled:=true;
          if pvd^.data.PTD=@FundamentalBooleanDescriptorOdj then
                                                        begin
                                                             Checked:=PBoolean(pvd^.data.Addr.Instance)^;
                                                        end
          else if fmask<>0 then
                               begin
                                    pv:=pvd^.data.Addr.Instance;
                                    pm:=@Fmask;
                                    accum:=0;
                                    for i:=1 to pvd^.data.PTD^.SizeInBytes do
                                     begin
                                          accum:=accum or(pv^ and pm^);
                                          inc(pv);
                                          inc(pm);
                                     end;
                                    if accum<>0 then
                                                    self.Checked:=true
                                                else
                                                    self.Checked:=false;
                               end
          else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInBytes then
                                                                    begin
                                                                         TBufer:=0;
                                                                         Move(pvd^.data.Addr.Instance^, TBufer,pvd^.data.PTD^.SizeInBytes);
                                                                         if TBufer<>0 then
                                                                                         self.Checked:=true
                                                                                      else
                                                                                          self.Checked:=false;
                                                                    end;
     end
        else
            enabled:=false;
end;
constructor TZAction.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  DisableIfNoHandler:=False;
end;

function TmyAction.Execute: Boolean;
var
    s:string;
begin
     //inherited;
     s:=command+'('+options+')';
     {if assigned(pfoundcommand)then

                               else}
                                   ZCMsgCallBackInterface.Do_SetNormalFocus;
                                   commandmanager.executecommand(s,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
     result:=true;
end;
procedure TMyActionListHelper.AddMyAction(Action:TZAction);
begin
     AddAction(action);
end;

function TMyActionListHelper.LoadImage(imgfile:String):Integer;
var
    bmp:TBitmap;
begin
  if fileexists(utf8tosys(imgfile)) then
  begin
  bmp:=TBitmap.create;
  bmp.LoadFromFile(imgfile);
  bmp.Transparent:=true;
  if not assigned(Images) then
                              Images:=TImageList.Create(self);
  result:=Images.Add(bmp,nil);
  freeandnil(bmp);
  end
  else
      result:=-1;
end;

procedure TMyActionListHelper.SetImage(img,identifer:string;var action:TZAction);
//var
    //bmp:TBitmap;
begin
     if length(img)>1 then
     begin
          if img[1]<>'#' then
                              begin
                              action.imgstr:='';
                              action.ImageIndex:=LoadImage(ProgramPath+'menu/BMP/'+img);
                              if action.ImageIndex=-1 then
                                                  begin
                                                       action.ImageIndex:=brocenicon;
                                                  end;
                              if action.ImageIndex=-1 then
                                                  begin
                                                       action.imgstr:=img;
                                                  end;

                              {img:=sysparam.programpath+'menu/BMP/'+img;
                              if fileexists(img) then
                              begin
                              bmp:=TBitmap.create;
                              bmp.LoadFromFile(img);
                              bmp.Transparent:=true;
                              if not assigned(Images) then
                                                          Images:=TImageList.Create(self);
                              action.ImageIndex:=Images.Add(bmp,nil);
                              freeandnil(bmp);
                              action.imgstr:='';
                              end
                              else
                              begin
                              end;}
                              end
                          else
                              begin
                              //action.imgstr:=(system.copy(img,2,length(img)-1));
                              action.imgstr:=InterfaceTranslate(identifer,system.copy(img,2,length(img)-1));
                              end;
     end;
end;
function FindControlByType(_parent:TWinControl;_class:TClass):TControl;
var
    i:integer;
begin
     if assigned(_parent)then
     for i := 0 to _parent.ControlCount - 1 do
      if TClass(typeof(_parent.Controls[i])) = _class then
                              begin
                                   result:=_parent.Controls[i];
                                   exit;
                              end;
     result:=nil;
end;
function FindComponentByType(_owner:TComponent;_class:TClass):TComponent;
var
    i:integer;
begin
     if assigned(_owner)then
     for i := 0 to _owner.ComponentCount - 1 do
      if _owner.Components[i] is _class then
                              begin
                                   result:=_owner.Components[i];
                                   exit;
                              end;
     result:=nil;
end;
procedure SetHeightControl(_parent:TWinControl;h:integer);
var
    i:integer;
begin
     for i := 0 to _parent.ControlCount - 1 do
      if TClass(typeof(_parent.Controls[i])) = TBitBtn then
                              begin
                                   _parent.Controls[i].Height:=h;
                              end;
end;
procedure TToolButtonForm.AfterConstruction;

begin
    inherited;
    //Include(FControlFlags,cfPreferredSizeValid);
    autosize:=true;
end;

(*procedure TToolButtonForm.GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                               Raw: boolean = false;
                               WithThemeSpace: boolean = true);
begin
     //inherited;
     controls[0].GetPreferredSize(PreferredWidth, PreferredHeight,
                               Raw,
                               WithThemeSpace);
     {PreferredWidth:=18;
     PreferredHeight:=18}
end;*)
procedure TmyPageControl.ChangePage(NewPage:Integer);
begin
  ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionRedraw);
  //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
end;
procedure TmyPageControl.DoChange;
begin
     inherited;
     ChangePage(ActivePageIndex);
end;
{procedure TmyToolButton.CalculatePreferredSize(
                 var PreferredWidth, PreferredHeight: integer;
                 WithThemeSpace: Boolean);
var
    temp:integer;
begin
  if assigned(parent)then
  if parent is TToolbar then
                            begin
                                 if (style=tbsSeparator)
                                 or (style=tbsDivider) then
                                 if TToolbar(parent).Height>TToolbar(parent).Width then
                                 temp:=-14;

                            end;
     inherited;
     if assigned(parent)then
     if parent is TToolbar then
                               begin
                                    if (style=tbsSeparator)
                                    or (style=tbsDivider) then
                                    if TToolbar(parent).Height>TToolbar(parent).Width then
                                    begin
                                         temp:=PreferredWidth;
                                         PreferredWidth:=PreferredHeight;
                                         PreferredHeight:=temp;
                                    end;
                               end;
end;}

procedure TmyVariableToolButton.AssignToVar(varname:string;mask:DWord);
var
   pvd:pvardesk;
   accum:byte;
   pv,pm:pbyte;
   i:integer;
   tBufer:DWord;
begin
//     if varname='DWG_DrawMode' then
//                                     varname:=varname;
     FVariable:=varname;
     Fmask:=mask;
     pvd:=nil;
     if DWGUnit<>nil then
     pvd:=DWGUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd=nil then
     pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          enabled:=true;
          if pvd^.data.PTD=@FundamentalBooleanDescriptorOdj then
                                                        begin
                                                             self.Down:=PBoolean(pvd^.data.Addr.Instance)^;
                                                        end
          else if fmask<>0 then
                               begin
                                    pv:=pvd^.data.Addr.Instance;
                                    pm:=@Fmask;
                                    accum:=0;
                                    for i:=1 to pvd^.data.PTD^.SizeInBytes do
                                     begin
                                          accum:=accum or(pv^ and pm^);
                                          inc(pv);
                                          inc(pm);
                                     end;
                                    if accum<>0 then
                                                    self.Down:=true
                                                else
                                                    self.Down:=false;
                               end
          else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInBytes then
                                                                    begin
                                                                         TBufer:=0;
                                                                         Move(pvd^.data.Addr.Instance^, TBufer,pvd^.data.PTD^.SizeInBytes);
                                                                         if TBufer<>0 then
                                                                                         self.Down:=true
                                                                                      else
                                                                                          self.Down:=false;
                                                                    end;
     end
        else
            enabled:=false;
end;
procedure TmyVariableToolButton.Click;
var
   pvd:pvardesk;
   accum:byte;
   pv,pm:pbyte;
   i:integer;
begin
  pvd:=nil;
  if DWGUnit<>nil then
  pvd:=DWGUnit^.InterfaceVariables.findvardesc(FVariable);
  if pvd=nil then
  pvd:=SysVarUnit^.InterfaceVariables.findvardesc(FVariable);
     if pvd<>nil then
     begin
          if pvd^.data.PTD=@FundamentalBooleanDescriptorOdj then
                                                        begin
                                                             PBoolean(pvd^.data.Addr.Instance)^:=not PBoolean(pvd^.data.Addr.Instance)^;
                                                             self.Down:=PBoolean(pvd^.data.Addr.Instance)^;
                                                        end
          else if fmask<>0 then
                               begin
                                    pv:=pvd^.data.Addr.Instance;
                                    pm:=@Fmask;
                                    accum:=0;
                                    for i:=1 to pvd^.data.PTD^.SizeInBytes do
                                     begin
                                          pv^:=pv^ xor pm^;
                                          accum:=accum or(pv^ and pm^);
                                          inc(pv);
                                          inc(pm);
                                     end;
                                    if accum<>0 then
                                                    self.Down:=true
                                                else
                                                    self.Down:=false;
                               end
     else if sizeof(FBufer)>=pvd^.data.PTD^.SizeInBytes then
                                                               begin
                                                                    if not self.Down then
                                                                    begin
                                                                    fbufer:=0;
                                                                    Move(pvd^.data.Addr.Instance^, FBufer,pvd^.data.PTD^.SizeInBytes);
                                                                    fillchar(pvd^.data.Addr.Instance^,pvd^.data.PTD^.SizeInBytes,0);
                                                                    if fbufer<>0 then
                                                                                    self.Down:=false;
                                                                    end
                                                                    else
                                                                    begin
                                                                      if fbufer=0 then
                                                                                      fbufer:=1;
                                                                      begin
                                                                      Move( FBufer,pvd^.data.Addr.Instance^,pvd^.data.PTD^.SizeInBytes);
                                                                      fbufer:=0;
                                                                      Move(pvd^.data.Addr.Instance^, FBufer,pvd^.data.PTD^.SizeInBytes);

                                                                      if fbufer<>0 then
                                                                                      self.Down:=true;
                                                                      end;
                                                                    end;
                                                               end;
     end;
     zcRedrawCurrentDrawing;
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionRedraw);
     //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
end;
procedure TmyCommandToolButton.click;
begin
     if action=nil then
                       commandmanager.executecommand(Fcommand,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
     inherited;
end;

procedure TmyMenuItem.Click;
var
  _action:TBasicAction;
begin
     _action:=Action;
     ACtion:=nil;
     if fsilent then
                    commandmanager.executecommandsilent(@Fcommand[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam)
                else
                    commandmanager.executecommand(Fcommand,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
     inherited;
     ACtion:=_action;
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
     FSilent:=false;
     SetCommand(_Caption,_Command);
end;


constructor TFreedForm.myCreate(TheOwner: TComponent; _var:Pointer);
begin
     inherited create(TheOwner);
     PVariable:=_var;
     self.FormStyle:=fsStayOnTop;
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
procedure TmyTreeView.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
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

     if selected<>nil then
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
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if PopUpTimer<>nil then
    FreeAndNil(PopUpTimer);

end.

