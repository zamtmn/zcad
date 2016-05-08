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
 uzcguimanager,uzbpaths,Themes,buttons,uzcsysvars,uzcstrconsts,uzbstrproc,uzcsysinfo,lclproc,LazUTF8,sysutils,uzbtypesbase,
 StdCtrls,ExtCtrls,Controls,Classes,menus,Forms,fileutil,graphics,
 uzbtypes, uzbmemman,uzcdrawings,math,uzccommandsmanager,varman,languade,
 UGDBTracePropArray,varmandef,
 uzegeometry,uzcshared,uzctnrvectorgdbstring,uzcinterface,uzctreenode;

const
     cheight=48;
     commandsuffix='>';
     commandprefix=' ';
type
  TCWindow = class(TForm)
    public
    procedure AfterConstruction; override;
  end;
  TCLine = class({TPanel}TForm{Tcustomform})
    procedure beforeinit;virtual;
    procedure AfterConstruction; override;
  private
    mode:TCLineMode;
    //prompttext:ansistring;
  public

    //DMenu:TDMenuWnd;
    utfpresent:boolean;
    utflen:integer;
    aliases:TZctnrVectorGDBString;
    procedure keypressmy(Sender: TObject; var Key: char);
    procedure SetMode(m:TCLineMode);virtual;
    procedure DoOnResize; override;
    procedure MyResize;
    procedure HistoryAdd(s:string);
    procedure mypaint(sender:tobject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonPressed(Sender: TObject);

    destructor Destroy;override;
    function FindAlias(prefix:GDBString;comment,breacer:GDBString):GDBString;
  end;
var
  CLine: TCLine;
  CWindow:TCWindow;
implementation
uses uzglviewareadata,uzclog,strmy;
procedure TCWindow.AfterConstruction;
begin
    inherited;
    self.Width:=600;
    self.Position:=poScreenCenter{poMainFormCenter};

    caption:='Window';

    self.borderstyle:=bsSizeToolWin;
    CWMemo:=tmemo.create(self);
    CWMemo.scrollbars:=ssAutoBoth;
    CWMemo.align:=alclient;
    CWMemo.ReadOnly:=true;
    CWMemo.Parent := self;
end;

procedure TCLine.mypaint(sender:tobject);
begin
     canvas.Line(0,0,100,100);
end;

procedure TCLine.HistoryAdd(s:string);
var
   //l,ll:integer;
   ss:string;
begin
     ss:=(s);
     if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+UTF8Length(ss)
                                        else
                                            utflen:=2+utflen+UTF8Length(ss);
    //TTextStrings(CLine.HistoryLine.lines).add(ss);
    HistoryLine.Append(ss);
    CWMemo.Append(ss);
    //l:=HistoryLine.GetTextLen;
    HistoryLine.SelStart:=utflen;
    HistoryLine.SelLength:=2;

    CWMemo.SelStart:=utflen;
    CWMemo.SelLength:=2;

    //cline.HistoryLine.Invalidate;
    //application.ProcessMessages;

    //ss:=CLine.HistoryLine.Text;
    //CLine.HistoryLine.Text:=copy(CLine.HistoryLine.Text,1,length(CLine.HistoryLine.Text)-2);
    //CLine.HistoryLine.Lines.Strings[CLine.HistoryLine.Lines.Count-1]:='1212';
    //CLine.HistoryLine.ClearSelection; {тормоз}

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
    CWindow:=TCWindow.CreateNew(application);
    //CWindow.Show;
    SetCommandLineMode:=self.SetMode;
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

function TCLine.FindAlias(prefix:GDBString;comment,breacer:GDBString):GDBString;
var
   ps{,pspred}:pgdbstring;
   s:gdbstring;
   ir:itrec;
   c:boolean;
begin
     result:=prefix;
     prefix:=uppercase(prefix);
     ps:=aliases.beginiterate(ir);
     if (ps<>nil) then
     repeat
          if length(ps^)>length(prefix) then
          begin
          c:=false;
          if comment<>'' then
          if pos(comment,ps^)=1 then
                                   c:=true;
          if not c then
          begin
          if (uppercase(copy(ps^,1,length(prefix)))=prefix)
          then
              begin
                   s:=copy(ps^,length(prefix)+1,length(ps^)-length(prefix));
                   s:=readspace(s);
                   if pos(breacer,s)=1 then
                                           begin
                                             s:=copy(s,length(breacer)+1,length(s)-length(breacer));
                                             s:=readspace(s);
                                             result:=s;
                                             exit;
                                           end;
             end;
          end;
          end;
          ps:=aliases.iterate(ir);
     until ps=nil;
end;

procedure TCLine.keypressmy(Sender: TObject; var Key: char);
var code{,ch}: GDBInteger;
  len: double;
  temp: gdbvertex;
  v:vardesk;
  s,{xx,yy,zz,}expr:GDBString;
  tv:gdbvertex;
  parseresult:PTZctnrVectorGDBString;
  cmd,subexpr,superexpr:string;
  parsed:gdbboolean;
  command,operands:GDBString;
begin
    //ch:=ord(key);
    if ord(key)=13 then
    begin
    if (length(CmdEdit.text) > 0) then
    begin
      expr:=CmdEdit.text;
      ParseCommand(expr,command,operands);
      //if IsParsed('_realnumber'#0,expr,parseresult)then
      // expr:=expr;
      val(CmdEdit.text, len, code);
      //code:=1;
      cmd:=FindAlias(CmdEdit.text,';','=');
      if code = 0 then
      begin
      if assigned(drawings.GetCurrentDWG) then
      if assigned(drawings.GetCurrentDWG.wa.getviewcontrol) then
      begin
        if (drawings.GetCurrentDWG.wa.param.polarlinetrace = 1)and commandmanager.CurrentCommandNotUseCommandLine then
        begin
          tv:=pgdbvertex(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arrayworldaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum))^;
          tv:=uzegeometry.normalizevertex(tv);
          temp.x := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.x + len * tv.x * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
          temp.y := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.y + len * tv.y * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
          temp.z := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.z + len * tv.z * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
          commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,temp,MZW_LBUTTON,nil);
          //commandmanager.sendpoint2command(temp, poglwnd.md.mouse, 1,nil);
          //OGLwindow1.param.lastpoint:=temp;
        end
        else
        begin
             if commandmanager.pcommandrunning<>nil then
             begin
                  commandmanager.PushValue('','GDBDouble',@len);
                  commandmanager.pcommandrunning.CommandContinue;
             end;
        end;
      end
      end
      else if CmdEdit.text[1] = '$' then begin
                                              expr:=copy(CmdEdit.text, 2, length(CmdEdit.text) - 1);
                                              v:=evaluate(expr,SysUnit);
                                              //s:=valuetoGDBString(v.pvalue,v.ptd);
                                              s:=v.data.ptd^.GetValueAsString(v.data.Instance);
                                              v.data.Instance:=v.data.Instance;
                                              historyoutstr(Format(rsExprOutText,[expr,s]));
                                         end
      else if commandmanager.FindCommand(uppercase({cmd}command))<>nil then
          begin
               //CmdEdit.text:=FindAlias(CmdEdit.text,';','=');
               CmdEdit.text:='';
               commandmanager.executecommand(Cmd,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          end
      else begin
           cmd:=CmdEdit.text;
           superexpr:='';
           repeat
           subexpr:=GetPredStr(cmd,',');
           v:=evaluate(subexpr,SysUnit);
           parsed:=v.data.Instance<>nil;
           if parsed then
           begin
           s:=v.data.ptd^.GetValueAsString(v.data.Instance);
           if superexpr='' then
                               superexpr:=s
                           else
                               superexpr:=superexpr+','+s
           end;
           until (cmd='')or(not parsed);
           if parsed then
           begin
           historyoutstr(Format(rsExprOutText,[CmdEdit.text,superexpr]));
           if IsParsed('_realnumber'#0'_softspace'#0'=,_realnumber'#0'_softspace'#0'=,_realnumber'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,uzegeometry.CreateVertex(strtodouble(parseresult^.getData(0)),
                                                                                              strtodouble(parseresult^.getData(1)),
                                                                                              strtodouble(parseresult^.getData(2))),MZW_LBUTTON,nil);
                 if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
           end
           else if IsParsed('_realnumber'#0'_softspace'#0'=,_realnumber'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,uzegeometry.CreateVertex(strtodouble(parseresult^.getData(0)),
                                                                                              strtodouble(parseresult^.getData(1)),
                                                                                              0),MZW_LBUTTON,nil);
                 if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
           end
           else if IsParsed('_realnumber'#0'_softspace'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 if drawings.GetCurrentDWG.wa.param.polarlinetrace = 1 then
                 begin

                 tv:=pgdbvertex(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arrayworldaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum))^;
                 tv:=uzegeometry.normalizevertex(tv);
                 temp.x := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.x + strtodouble(parseresult^.getData(0)) * tv.x * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
                 temp.y := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.y + strtodouble(parseresult^.getData(0)) * tv.y * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
                 temp.z := drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].worldcoord.z + strtodouble(parseresult^.getData(0)) * tv.z * sign(ptraceprop(drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[drawings.GetCurrentDWG.wa.param.pointnum].arraydispaxis.getDataMutable(drawings.GetCurrentDWG.wa.param.axisnum)).tmouse);
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,temp,MZW_LBUTTON,nil);
                 end;

                 if parseresult<>nil then begin parseresult^.Done;GDBfreeMem(gdbpointer(parseresult));end;
           end
           end
              else
                  uzcshared.ShowError('Unable to parse line "'+subexpr+'"');
      end;
    end;
    CmdEdit.text:='';
    key:=#0;
    //CmdEdit.settext('');
    if assigned(drawings.GetCurrentDWG) then
    if assigned(drawings.GetCurrentDWG.wa.getviewcontrol) then
    begin
    //drawings.GetCurrentDWG.OGLwindow1.setfocus;
    drawings.GetCurrentDWG.wa.param.firstdraw := TRUE;
    drawings.GetCurrentDWG.wa.reprojectaxis;
    drawings.GetCurrentDWG.wa.{paint}draw;
    drawings.GetCurrentDWG.wa.asyncupdatemouse(0);
    //Application.QueueAsyncCall(drawings.GetCurrentDWG.wa.asyncupdatemouse,0);
    end;
    //redrawoglwnd;
    {poglwnd.loadmatrix;
    poglwnd.paint;}
    end;
end;
begin
  ZCADGUIManager.RegisterZCADFormInfo('CommandLine',rsCommandLineWndName,TCLine,rect(200,100,600,100),nil,nil,@CLine);
end.
