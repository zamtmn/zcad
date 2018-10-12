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

unit uzcfcommandline;
{$INCLUDE def.inc}
interface
uses
 uzcguimanager,uzbpaths,Themes,buttons,uzcsysvars,uzcstrconsts,uzbstrproc,
 uzcsysinfo,lclproc,LazUTF8,sysutils, StdCtrls,ExtCtrls,Controls,Classes,
 menus,Forms,fileutil,graphics, uzbtypes, uzbmemman,uzcdrawings,uzccommandsmanager,
 varman,languade,varmandef,
 uzegeometry,uzctnrvectorgdbstring,uzcinterface,uzctreenode,uzclog,strmy,
 uzccommandlineutil,uztoolbarsmanager;

const
     cheight=48;
type
  TCLine = class(TForm)
    procedure AfterConstruction; override;
  public
    //utfpresent:boolean;
    utflen:integer;
    procedure keypressmy(Sender: TObject; var Key: char);
    procedure SetMode(m:TCLineMode);virtual;
    procedure DoOnResize; override;
    procedure MyResize;
    procedure mypaint(sender:tobject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonPressed(Sender: TObject);
    function GetCLineFocusPriority:TControlWithPriority;

    destructor Destroy;override;
  end;
var
  CLine: TCLine;
  cmdedit:TEdit;
  prompt:TLabel;
  panel:tpanel;
  HistoryLine:TMemo;

  HintText:TLabel;
  //historychanged:boolean;

implementation

//var
//   historychanged:boolean;

procedure TCLine.mypaint(sender:tobject);
begin
     canvas.Line(0,0,100,100);
end;

procedure TCLine.SetMode(m:TCLineMode);
begin
     {if m=mode then
                   exit;}
     case m of
     CLCOMMANDREDY:
     begin
           prompt.Caption:=commandprefix+rsdefaultpromot+commandsuffix;
     end;
     CLCOMMANDRUN:
     begin
          prompt.Caption:=commandsuffix;
     end;
     end;
     mode:=m;
end;
procedure HandleCommandLineMode(GUIMode:TZMessageID);
begin
     if GUIMode=ZMsgID_GUICMDLineReadyMode then begin
       if assigned(CLine) then
         CLine.SetMode(CLCOMMANDREDY)
     end
else if GUIMode=ZMsgID_GUICMDLineRunMode then begin
     if assigned(CLine) then
       CLine.SetMode(CLCOMMANDRUN)
     end;
end;

procedure TCLine.ButtonPressed(Sender: TObject);
var
  menu:TmyPopupMenu;
begin
    menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'LASTCOMMANDSCXMENU'));
    if menu<>nil then
    begin
      menu.PopUp;
    end;
end;
function TCLine.GetCLineFocusPriority:TControlWithPriority;
begin
      result.priority:=UnPriority;
      result.control:=nil;

      if assigned(cmdedit) then
      if cmdedit.Enabled then
      if cmdedit.IsVisible then
      if cmdedit.CanFocus then begin
        result.priority:=CLinePriority;
        result.control:=cmdedit;
      end;
end;
procedure DisableCmdLine;
begin
  {if assigned(application.MainForm) then
    application.MainForm.ActiveControl:=nil;}
  if assigned(uzcfcommandline.cmdedit) then
                                  begin
                                      //if uzcfcommandline.cmdedit.Enabled<>false then
                                      //   ZCMsgCallBackInterface.Do_SetNormalFocus;
                                      uzcfcommandline.cmdedit.Enabled:=false;
                                  end;
  if assigned(prompt) then begin
    prompt.Enabled:=false;
    prompt.Color:=clBtnFace;
  end;
end;

procedure EnableCmdLine;
begin
  if assigned(uzcfcommandline.cmdedit) then
  if uzcfcommandline.cmdedit.IsVisible then
                                  begin
                                       //if uzcfcommandline.cmdedit.Enabled<>true then
                                       //  ZCMsgCallBackInterface.Do_SetNormalFocus;
                                       uzcfcommandline.cmdedit.Enabled:=true;
                                       //uzcfcommandline.cmdedit.SetFocus;
                                  end;
  if assigned(prompt) then begin
    prompt.Enabled:=true;
    prompt.Color:=clDefault;
  end;
end;

procedure HandleCmdLine(GUIMode:TZMessageID);
begin
     if GUIMode in [ZMsgID_GUICMDLineCheck] then begin
     if INTFCommandLineEnabled then
                                   EnableCmdLine
                               else
                                   DisableCmdLine;
     end;
     if GUIMode in [ZMsgID_GUIDisable] then
                                           DisableCmdLine
else if (GUIMode in [ZMsgID_GUIEnable])then
                                          EnableCmdLine;
end;
procedure TCLine.FormCreate(Sender: TObject);
var
   //bv:tbevel;
   //pint:PGDBInteger;
   sbutton:TmySpeedButton;
begin
    self.Constraints.MinHeight:=36;
    //utfpresent:=false;
    UTFLen:=0;
    //height:=100;
    //self.DoubleBuffered:=true;

    panel:=TPanel.create(self);
    panel.parent:=self;
    panel.top:=0;
    //panel.Constraints.MinHeight:=17;
    //panel.Constraints.MaxHeight:=17;
    panel.AutoSize:=true; ;
    panel.BorderStyle:=bsNone;
    panel.BevelOuter:=bvnone;
    panel.BorderWidth:=0;
    panel.Align:=alBottom;

    with TBevel.Create(self) do
    begin
         parent:={self}panel;
         top:=0;
         height:=2;
         Align:={alBottom}altop;
         //---------------BevelOuter:=bvraised;
    end;

    HistoryLine:=TMemo.create(self);
    HistoryLine.Align:=alClient;
    HistoryLine.ReadOnly:=true;
    HistoryLine.BorderStyle:=bsnone;
    HistoryLine.BorderWidth:=0;
    HistoryLine.ScrollBars:=ssAutoBoth;
    HistoryLine.Height:=self.clientheight-22;
    HistoryLine.parent:=self;
    //HistoryLine.:=

    //HistoryLine.DoubleBuffered:=true;

    panel.Color:=HistoryLine.Brush.Color;

    prompt:=TLabel.create(panel);
    prompt.Align:=alLeft;
    prompt.Layout:=tlCenter;
    //prompt.Width:=1;
    //prompt.BorderStyle:=sbsSingle;
    prompt.AutoSize:=true;
    //prompt.Caption:='Command';
    //prompt.Text:='Command';
    prompt.parent:=panel;
    //prompt.Canvas.Brush:=prompt.Canvas.Brush;

    sbutton:=TmySpeedButton.Create(self);
    sbutton.OnClick:=ButtonPressed;
    //sbutton.Width:=panel.Constraints.MinHeight;
    sbutton.Align:=alLeft;
    with ThemeServices.GetDetailSize(ThemeServices.GetElementDetails(tsArrowBtnDownNormal)) do
    begin
         if cx>0 then
                     sbutton.width:=cx
                 else
                     sbutton.width:=15;
    end;
    sbutton.Color:=panel.Color;
    sbutton.parent:=panel;

    cmdedit:=TEdit.create(panel);
    cmdedit.Align:=alClient;
    cmdedit.BorderStyle:=bsnone;
    cmdedit.BorderWidth:=0;
    //cmdedit.BevelOuter:=bvnone;
    cmdedit.parent:=panel;
    cmdedit.DoubleBuffered:=true;
    cmdedit.AutoSize:=true;
    {with cmdedit.Constraints do
    begin
         MaxHeight:=22;
    end;}
    {with prompt.Constraints do
    begin
         MaxHeight:=22;
    end;}
    SetMode(CLCOMMANDREDY);

    cmdedit.OnKeyPress:=keypressmy;

    BorderStyle:=BSsingle;
    BorderWidth:=0;
    //---------------BevelOuter:=bvnone;

      if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;
    aliases.init(100);
    aliases.loadfromfile(expandpath('*menu/default.cla'));

    //DMenu:=TDMenuWnd.Create(self);

    {pint:=SavedUnit.FindValue('DMenuX');
    if assigned(pint)then
                         DMenu.Left:=pint^;
    pint:=SavedUnit.FindValue('DMenuY');
    if assigned(pint)then
                         DMenu.Top:=pint^;}
    //CWindow:=TCWindow.CreateNew(application);
    //CWindow.Show;
    ZCMsgCallBackInterface.RegisterHandler_GUIMode(HandleCommandLineMode);
    HandleCmdLine(ZMsgID_GUICMDLineCheck);
   // SetCommandLineMode:=self.SetMode;
end;
destructor TCLine.Destroy;
begin
     aliases.Done;
     inherited;
end;

procedure TCLine.AfterConstruction;
begin
    name:='MainForm123';
    oncreate:=FormCreate;
    inherited;
end;
procedure TCLine.MyResize;
begin
        if assigned(HistoryLine) then
                                         HistoryLine.Height:=self.clientheight-22;
end;

procedure TCLine.DoOnResize;
begin
     inherited;
     myresize;
end;

procedure TCLine.keypressmy(Sender: TObject; var Key: char);
var
   s:string;
begin
    if ord(key)=13 then
    begin
      s:=CmdEdit.text;
      processcommand(s);
      CmdEdit.text:=s;
    end;
end;

procedure HistoryOut(s: pansichar); export;
var
   a:string;
begin
  if assigned(HistoryLine) then
  begin
   a:=(s);
   if HistoryLine.Lines.Count=0 then
     CLine.utflen:=CLine.utflen+{$IFDEF WINDOWS}UTF8Length(a){$ELSE}Length(a){$ENDIF}
   else
     CLine.utflen:=2+CLine.utflen+{$IFDEF WINDOWS}UTF8Length(a){$ELSE}Length(a){$ENDIF};
   {$IFNDEF DELPHI}
   HistoryLine.Append(a);
   {$ENDIF}
   //{$IFDEF WINDOWS}
   HistoryLine.SelStart:=CLine.utflen;
   HistoryLine.SelLength:=2;
   HistoryLine.ClearSelection;
   //{$ENDIF}
  end;
end;
procedure HistoryOutStr(s:String);
begin
     HistoryOut(pansichar(s));
end;
procedure StatusLineTextOut(s:String);
begin
     if assigned(HintText) then
     HintText.caption:=(s);
     //HintText.{Update}repaint;
end;
procedure LogError(errstr:String); export;
begin
     {errstr:=rserrorprefix+errstr;
     if assigned(HistoryLine) then
     begin
     HistoryOutStr(errstr);
     end;}
     programlog.logoutstr(errstr,0,LM_Error);
end;
begin
  //historychanged:=false;
  ZCADGUIManager.RegisterZCADFormInfo('CommandLine',rsCommandLineWndName,TCLine,rect(200,100,600,100),nil,nil,@CLine);

  ZCMsgCallBackInterface.RegisterHandler_HistoryOut(HistoryOutStr);
  //uzcinterface.HistoryOutStr:=HistoryOutStr;

  ZCMsgCallBackInterface.RegisterHandler_GUIMode(HandleCmdLine);

  ZCMsgCallBackInterface.RegisterHandler_StatusLineTextOut(StatusLineTextOut);
  //uzcinterface.StatusLineTextOut:=StatusLineTextOut;
  ZCMsgCallBackInterface.RegisterHandler_LogError(LogError);
  ZCMsgCallBackInterface.RegisterHandler_GetFocusedControl(CLine.GetCLineFocusPriority);
  //uzcinterface.TMWOSilentShowError:=LogError;
end.
