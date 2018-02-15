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
    procedure beforeinit;virtual;
    procedure AfterConstruction; override;
  public
    utfpresent:boolean;
    utflen:integer;
    procedure keypressmy(Sender: TObject; var Key: char);
    procedure SetMode(m:TCLineMode);virtual;
    procedure DoOnResize; override;
    procedure MyResize;
    procedure mypaint(sender:tobject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonPressed(Sender: TObject);

    destructor Destroy;override;
  end;
var
  CLine: TCLine;
  cmdedit:TEdit;
  prompt:TLabel;
  panel:tpanel;
  HistoryLine:TMemo;
  utflen:integer;

  HintText:TLabel;
  historychanged:boolean;

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

procedure TCLine.FormCreate(Sender: TObject);
var
   //bv:tbevel;
   //pint:PGDBInteger;
   sbutton:TmySpeedButton;
begin
    self.Constraints.MinHeight:=36;
    utfpresent:=false;
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

procedure TCLine.beforeinit;
begin
(*
  mode:=CLCOMMANDREDY;
  prompttext:='Команда>';
  prompt.initxywh(prompttext,@self,-1,clientheight-cheight-1,clientwidth+3,cheight+2,false);
  //prompt.setextstyle(0,WS_EX_ClientEdge);
  //prompt.setstyle(WS_Border,0);
  //GDBGetMem({$IFDEF DEBUGBUILD}'{C5652242-FC00-4B6B-9C44-3CFAADC6D918}',{$ENDIF}GDBPointer(cmdedit),sizeof(ZEditWithProcedure));
  cmdedit.initxywh('',@self,0,clientheight-cheight,clientwidth,cheight,false);
  cmdedit.setextstyle(0,WS_EX_ClientEdge);
  cmdedit.setstyle(WS_Border,0);
  cmdedit.onenter:=keypressmy;


  //GDBGetMem({$IFDEF DEBUGBUILD}'{1D86B21F-D1DE-4D07-82F3-AE8CEEAA25DF}',{$ENDIF}GDBPointer(HistoryLine),sizeof(zmemo));
  HistoryLine.initxywh('',@self,0,0,clientwidth,clientheight-cheight+1,false);
  HistoryLine.SetReadOnlyState(1);
  //HistoryLine.align:=al_client;
  //cmdedit^.align:=al_client;

  DMenu.initxywh('DisplayMenu',@MainForm,200,100,10,10,false);

//  dmenu.AddProcedure('test1','подсказка1',nil);
//  dmenu.AddProcedure('test2','подсказка2',nil);
//  dmenu.AddProcedure('test3 test3 test3 test3 test3','подсказка3',nil);
*)
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
     {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then}
     if assigned(HistoryLine) then
     begin
          a:=(s);
               if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+{UTF8}Length(a)
                                        else
                                            utflen:=2+utflen+{UTF8}Length(a);
          {$IFNDEF DELPHI}
          HistoryLine.Append(a);
          //CWindow.CWMemo.Append(a);
          {$ENDIF}
          //application.ProcessMessages;

          //HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
          //HistoryLine.SelLength:=2;
          historychanged:=true;
          //HistoryLine.SelLength:=0;
          //{CLine}HistoryLine.append(s);
          {CLine}//---------------------------------------------------------HistoryLine.repaint;
          //a:=CLine.HistoryLine.Lines[CLine.HistoryLine.Lines.Count];
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     //programlog.logoutstr('HISTORY: '+s,0,LM_Info);
end;
procedure HistoryOutStr(s:String);
begin
     HistoryOut(pansichar(s));
end;
procedure DisableCmdLine;
begin
  application.MainForm.ActiveControl:=nil;
  if assigned(uzcfcommandline.cmdedit) then
                                  begin
                                      uzcfcommandline.cmdedit.Enabled:=false;
                                  end;
  if assigned(HintText) then
                          begin
                            HintText.Enabled:=false;
                          end;
end;

procedure EnableCmdLine;
begin
  if assigned(uzcfcommandline.cmdedit) then
  if uzcfcommandline.cmdedit.IsVisible then
                                  begin
                                       uzcfcommandline.cmdedit.Enabled:=true;
                                       uzcfcommandline.cmdedit.SetFocus;
                                  end;
  if assigned(HintText) then
                            HintText.Enabled:=true;
end;

procedure HandleCmdLine(GUIMode:TZMessageID);
begin
     if GUIMode in [ZMsgID_GUIDisable{,ZMsgID_GUIDisableCMDLine}] then DisableCmdLine
else if GUIMode in [ZMsgID_GUIEnable{,ZMsgID_GUIEnableCMDLine}] then EnableCmdLine;
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
  utflen:=0;
  historychanged:=false;
  ZCADGUIManager.RegisterZCADFormInfo('CommandLine',rsCommandLineWndName,TCLine,rect(200,100,600,100),nil,nil,@CLine);

  ZCMsgCallBackInterface.RegisterHandler_HistoryOut(HistoryOutStr);
  //uzcinterface.HistoryOutStr:=HistoryOutStr;

  ZCMsgCallBackInterface.RegisterHandler_GUIMode(HandleCmdLine);

  ZCMsgCallBackInterface.RegisterHandler_StatusLineTextOut(StatusLineTextOut);
  //uzcinterface.StatusLineTextOut:=StatusLineTextOut;
  ZCMsgCallBackInterface.RegisterHandler_LogError(LogError);
  //uzcinterface.TMWOSilentShowError:=LogError;
end.
