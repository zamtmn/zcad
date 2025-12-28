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

unit uzcfcommandline;

{$INCLUDE zengineconfig.inc}

interface

uses
  Themes,Buttons,lclproc,LazUTF8,SysUtils,StdCtrls,ExtCtrls,Controls,Classes,
  Menus,Forms,fileutil,Graphics,
  uzcsysvars,uzcstrconsts,uzbstrproc,uzcguimanager,uzbpaths,uzccommandsmanager,
  varman,varmandef,uzegeometry,uzctnrvectorstrings,uzcinterface,uzctreenode,
  uzclog,uzccommandlineutil,uztoolbarsmanager,uzmenusmanager,
  uzccommandsabstract,gzctnrVectorTypes,uzcctrlcommandlineprompt,
  uzeparsercmdprompt,uzbtypes,uzeTypes,uzcFileStructure;

const
     cheight=48;
type
  TCLine = class(TForm,ICommandLinePrompt)
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
  private
    procedure SetPrompt(APrompt:String);virtual;overload;
    procedure SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);virtual;overload;
  end;
var
  CLine: TCLine;
  cmdedit:TComboBox;
  prompt:TCommandLinePrompt;
  panel:tpanel;
  HistoryLine:TMemo;
  LastHistoryMsg:string='';
  LastSuffixMsg:string='';
  LastHistoryMsgRepeatCounter:integer=0;
implementation

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
           SetPrompt(commandprefix+rsdefaultpromot+commandsuffix);
           cmdedit.AutoComplete:=true;
           //cmdedit.AutoDropDown:=true;
     end;
     CLCOMMANDRUN:
     begin
          SetPrompt(commandsuffix);
          cmdedit.AutoComplete:=false;
          //cmdedit.AutoDropDown:=false;
     end;
     end;
     mode:=m;
end;
procedure HandleCommandLineMode(GUIMode:TzcMessageID);
begin
     if GUIMode=zcMsgUICMDLineReadyMode then begin
       if assigned(CLine) then
         CLine.SetMode(CLCOMMANDREDY)
     end
else if GUIMode=zcMsgUICMDLineRunMode then begin
     if assigned(CLine) then
       CLine.SetMode(CLCOMMANDRUN)
     end;
end;

procedure TCLine.ButtonPressed(Sender: TObject);
var
  menu:TPopupMenu;
begin
    menu:=MenusManager.GetPopupMenu('LASTCOMMANDSCXMENU',nil);
    if menu<>nil then
    begin
      menu.PopUp;
    end;
end;
function TCLine.GetCLineFocusPriority:TControlWithPriority;
begin
  if assigned(cmdedit) then
    if cmdedit.Enabled then
      if cmdedit.IsVisible then
        if cmdedit.CanFocus then
          exit(TControlWithPriority.CreateRec(cmdedit,CLinePriority));

  result:=TControlWithPriority.CreateRec(nil,UnPriority);
end;
procedure DisableCmdLine;
begin
  if assigned(uzcfcommandline.cmdedit) then
    uzcfcommandline.cmdedit.Enabled:=false;
  if assigned(prompt) then begin
    prompt.Enabled:=false;
    prompt.Color:=clBtnFace;
  end;
end;

procedure EnableCmdLine;
begin
  if assigned(uzcfcommandline.cmdedit) then
    uzcfcommandline.cmdedit.Enabled:=true;
  if assigned(prompt) then begin
    prompt.Enabled:=true;
    prompt.Color:=clDefault;
  end;
end;
procedure HideCmdLine;
begin
  DisableCmdLine;
  if assigned(panel) then
    panel.visible:=false;
  ZCStatekInterface.SetState(ZCSGUIChanged);
end;
procedure ShowCmdLine;
begin
  EnableCmdLine;
  if assigned(panel) then
    panel.visible:=true;
  ZCStatekInterface.SetState(ZCSGUIChanged);
end;
procedure HandleCmdLine(GUIMode:TzcMessageID);
begin
  if GUIMode in [zcMsgUICMDLineCheck] then begin
    if INTFCommandLineEnabled or ((prompt<>nil)and(prompt.Highlight.Count>0)) then
      ShowCmdLine
    else
      HideCmdLine;
  end;
  if GUIMode in [zcMsgUIDisable] then
    DisableCmdLine
  else if (GUIMode in [zcMsgUIEnable])then
    EnableCmdLine;
end;

procedure TCLine.SetPrompt(APrompt:String{;ATPromptResults:TCommandLinePrompt.TPromptResults});
begin
  prompt.SetHighLightedText(APrompt,[]{,-1});
  HandleCmdLine(zcMsgUICMDLineCheck);
end;

procedure TCLine.SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);
var
  pt:TCommandLinePromptOption;
  ts:TParserCommandLinePrompt.TParserString;
begin
  pt:=TCommandLinePromptOption.Create;
  ts:=APrompt.GetResult(pt);
  prompt.SetHighLightedText(ts,pt.Parts.Mutable[0][0..pt.Parts.Size-1]);
  pt.Free;
  HandleCmdLine(zcMsgUICMDLineCheck);
end;

procedure TCLine.FormCreate(Sender: TObject);
var
   //bv:tbevel;
   //pint:PInteger;
   sbutton:TmySpeedButton;
   p:PCommandObjectDef;
   ir:itrec;
   clist:TZctnrVectorStrings;
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

    {with TBevel.Create(self) do begin
      parent:=panel;
      top:=0;
      height:=2;
      Align:=altop;
    end;}

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

    prompt:=TCommandLinePrompt.create(panel);
    prompt.OnClickNotify:=commandmanager.PromptTagNotufy;
    prompt.Align:=alLeft;
    prompt.Layout:=tlCenter;
    //prompt.Layout:=tlCenter;
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
    with ThemeServices.GetDetailSizeForPPI(ThemeServices.GetElementDetails(tsArrowBtnDownNormal),Screen.PixelsPerInch) do
    begin
         if cx>0 then
                     sbutton.width:=cx
                 else
                     sbutton.width:=15;
    end;
    sbutton.Color:=panel.Color;
    sbutton.parent:=panel;

    cmdedit:=TComboBox.create(panel);
    cmdedit.Name:='MainCommandLine';
    cmdedit.Caption:='';
    cmdedit.Style:=csDropDown;
    clist.init(200);
    p:=commandmanager.beginiterate(ir);
    if p<>nil then
    repeat
          clist.PushBackData(p^.CommandName);
          p:=commandmanager.iterate(ir);
    until p=nil;
    clist.sort;
    cmdedit.Items.Text:=clist.GetTextWithEOL;
    clist.done;
    cmdedit.AutoComplete:=true;
    cmdedit.AutoDropDown:={true}false;
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

    aliases.init(100);
    aliases.loadfromfile(FindFileInCfgsPaths(CFSmenuDir,CFSdefaultclaFile));

    //DMenu:=TDMenuWnd.Create(self);

    {pint:=SavedUnit.FindValue('DMenuX');
    if assigned(pint)then
                         DMenu.Left:=pint^;
    pint:=SavedUnit.FindValue('DMenuY');
    if assigned(pint)then
                         DMenu.Top:=pint^;}
    //CWindow:=TCWindow.CreateNew(application);
    //CWindow.Show;
    zcUI.RegisterHandler_GUIMode(HandleCommandLineMode);
    HandleCmdLine(zcMsgUICMDLineCheck);
    commandmanager.AddClPrompt(self);
end;
destructor TCLine.Destroy;
begin
  commandmanager.RemoveClPrompt(self);
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
      CmdEdit.text:='';
      processcommand(s);
    end;
end;

procedure HistoryOut(s:string);
var
  needclean:integer;
begin
  if assigned(HistoryLine) then begin
    if ((s<>LastHistoryMsg)or(rsMsgRepeatCountStr=''))or(INTFMessagesSuppressDoubles=T3SB_Fale) then begin
      LastHistoryMsg:=s;
      LastHistoryMsgRepeatCounter:=0;
      LastSuffixMsg:='';
      if HistoryLine.Lines.Count=0 then
        CLine.utflen:=CLine.utflen+UTF8Length(s)
      else
       CLine.utflen:=CLine.utflen+UTF8Length(s)+UTF8Length(HistoryLine.Lines.LineBreak);
      {$IFNDEF DELPHI}
      HistoryLine.Append(s);
      {$ENDIF}

      {$IFDEF LCLWIN32}
      HistoryLine.SelStart:=CLine.utflen;
      HistoryLine.SelLength:=length(HistoryLine.Lines.LineBreak);
      HistoryLine.ClearSelection;
      {$ENDIF}
    end else if INTFMessagesSuppressDoubles=T3SB_Default then begin
      inc(LastHistoryMsgRepeatCounter);
      needclean:=UTF8Length(LastSuffixMsg);
      LastSuffixMsg:=format(rsMsgRepeatCountStr,[LastHistoryMsgRepeatCounter+1]);

      if LastHistoryMsgRepeatCounter=1 then begin
        HistoryLine.Lines[HistoryLine.Lines.Count-1]:=HistoryLine.Lines[HistoryLine.Lines.Count-1]+LastSuffixMsg;
        CLine.utflen:=CLine.utflen+UTF8Length(LastSuffixMsg);

        HistoryLine.SelStart:=CLine.utflen;
        HistoryLine.SelLength:=2;
        HistoryLine.ClearSelection;
      end else begin
        HistoryLine.SelStart:=CLine.utflen-needclean;
        HistoryLine.SelLength:=needclean;
        HistoryLine.ClearSelection;
        CLine.utflen:=CLine.utflen-needclean;

        HistoryLine.Lines[HistoryLine.Lines.Count-1]:=HistoryLine.Lines[HistoryLine.Lines.Count-1]+LastSuffixMsg;
        CLine.utflen:=CLine.utflen+UTF8Length(LastSuffixMsg);
        HistoryLine.SelStart:=CLine.utflen;
        HistoryLine.SelLength:=2;
        HistoryLine.ClearSelection;
      end;
    end;
  end;
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

  zcUI.RegisterHandler_HistoryOut(HistoryOut);
  //uzcinterface.HistoryOutStr:=HistoryOutStr;

  zcUI.RegisterHandler_GUIMode(HandleCmdLine);
  //uzcinterface.StatusLineTextOut:=StatusLineTextOut;
  zcUI.RegisterHandler_LogError(LogError);
  zcUI.RegisterHandler_GetFocusedControl(CLine.GetCLineFocusPriority);
  //uzcinterface.TMWOSilentShowError:=LogError;
end.
