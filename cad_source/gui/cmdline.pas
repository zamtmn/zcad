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

unit cmdline;
{$INCLUDE def.inc}
interface
uses
 strproc,lclproc,sysutils,gdbasetypes,umytreenode,
 StdCtrls,ExtCtrls,ComCtrls,Controls,Classes,menus,Forms,{IFDEF FPClcltype,$ENDIF}fileutil,graphics,
 UDMenuWnd{,ZStaticsText},gdbase{,ZPanelsNoFrame}, memman,UGDBDescriptor,math,commandline,varman,languade,
 UGDBTracePropArray,{zforms,}{ZEditsWithProcedure}{,zbasicvisible,}varmandef,{ZGUIsCT,}{ZPanelsGeneric,}
 geometry,shared,UGDBStringArray{,zmemos};

resourcestring
              defaultpromot='Command';
              exprouttext='Expression %s return %s';
const
     cheight=18;
     commandsuffix='>';
     commandprefix=' ';
type
  TCLineMode=(CLCOMMANDREDY,CLCOMMANDRUN);
  TCWindow = class(TForm)
    private
    procedure AfterConstruction; override;
  end;
  TCLine = class({TPanel}TForm{Tcustomform})
    procedure beforeinit;virtual;
    procedure AfterConstruction; override;
  private
    mode:TCLineMode;
    prompttext:ansistring;
  public

    DMenu:TDMenuWnd;
    utfpresent:boolean;
    utflen:integer;
    aliases:GDBGDBStringArray;
    procedure keypressmy(Sender: TObject; var Key: char);
    procedure SetMode(m:TCLineMode);virtual;
    procedure DoOnResize; override;
    procedure MyResize;
    procedure HistoryAdd(s:string);
    procedure mypaint(sender:tobject);
    procedure FormCreate(Sender: TObject);

    destructor Destroy;override;
    function FindAlias(prefix:GDBString;comment,breacer:GDBString):GDBString;
  end;
var
  CLine: TCLine;
  CWindow:TCWindow;
implementation
uses mainwindow,oglwindowdef,log;
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
   l,ll:integer;
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
    l:=HistoryLine.GetTextLen;
    HistoryLine.SelStart:=utflen;
    HistoryLine.SelLength:=2;

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
           prompt.Caption:=commandprefix+defaultpromot+commandsuffix;
     end;
     CLCOMMANDRUN:
     begin
          prompt.Caption:=commandsuffix;
     end;
     end;
     mode:=m;
end;
procedure TCLine.FormCreate(Sender: TObject);
var
   bv:tbevel;
   pint:PGDBInteger;
begin
    self.Constraints.MinHeight:=36;
    utfpresent:=false;
    UTFLen:=0;
    //height:=100;
    //self.DoubleBuffered:=true;

    panel:=TPanel.create(self);
    panel.parent:=self;
    panel.top:=0;
    panel.Constraints.MinHeight:=14+2;
    panel.Constraints.MaxHeight:=14+2;
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

    cmdedit:=TEdit.create(panel);
    cmdedit.Align:=alClient;
    cmdedit.BorderStyle:=bsnone;
    cmdedit.BorderWidth:=0;
    //cmdedit.BevelOuter:=bvnone;
    cmdedit.parent:=panel;
    cmdedit.DoubleBuffered:=true;
    cmdedit.AutoSize:=true;
    with cmdedit.Constraints do
    begin
         MaxHeight:=22;
    end;
    with prompt.Constraints do
    begin
         MaxHeight:=22;
    end;
    SetMode(CLCOMMANDREDY);

    cmdedit.OnKeyPress:=keypressmy;

    BorderStyle:=BSsingle;
    BorderWidth:=0;
    //---------------BevelOuter:=bvnone;

      if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;
    aliases.init(100);
    aliases.loadfromfile(expandpath('*menu/default.cla'));

    DMenu:=TDMenuWnd.Create(self);//'DisplayMenu',@MainForm,200,100,10,10,false);

    pint:=SavedUnit.FindValue('DMenuX');
    if assigned(pint)then
                         DMenu.Left:=pint^;
    pint:=SavedUnit.FindValue('DMenuY');
    if assigned(pint)then
                         DMenu.Top:=pint^;
    CWindow:=TCWindow.Create(application);
    //CWindow.Show;
end;
destructor TCLine.Destroy;
begin
     aliases.FreeAndDone;
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
var code,ch: GDBInteger;
  len: double;
  temp: gdbvertex;
  v:vardesk;
  s,expr:GDBString;
  tv:gdbvertex;
begin
    ch:=ord(key);
    if ord(key)=13 then
    begin
    if (length(CmdEdit.text) > 0) then
    begin
      val(CmdEdit.text, len, code);
      if code = 0 then
      begin
      if assigned(gdb.GetCurrentDWG) then
      if assigned(gdb.GetCurrentDWG.OGLwindow1) then
      begin
        if gdb.GetCurrentDWG.OGLwindow1.param.polarlinetrace = 1 then
        begin
          tv:=pgdbvertex(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arrayworldaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum))^;
          tv:=geometry.normalizevertex(tv);
          temp.x := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.x + len * tv.x * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);
          temp.y := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.y + len * tv.y * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);
          temp.z := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.z + len * tv.z * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);

          gdb.GetCurrentDWG.OGLwindow1.sendcoordtocommandTraceOn(temp,MZW_LBUTTON,nil);
          //commandmanager.sendpoint2command(temp, poglwnd.md.mouse, 1,nil);
          //mainwindow.OGLwindow1.param.lastpoint:=temp;
        end;
      end
      end
      else if CmdEdit.text[1] = '$' then begin
                                              expr:=copy(CmdEdit.text, 2, length(CmdEdit.text) - 1);
                                              v:=evaluate(expr,SysUnit);
                                              //s:=valuetoGDBString(v.pvalue,v.ptd);
                                              s:=v.data.ptd^.GetValueAsString(v.data.Instance);
                                              v.data.Instance:=v.data.Instance;
                                              historyoutstr(Format(ExprOutText,[expr,s]));
                                         end
      else
          begin
               CmdEdit.text:=FindAlias(CmdEdit.text,';','=');
               commandmanager.executecommand(GDBPointer(CmdEdit.text));
          end;
    end;
    CmdEdit.text:='';
    key:=#0;
    //CmdEdit.settext('');
    if assigned(gdb.GetCurrentDWG) then
    if assigned(gdb.GetCurrentDWG.OGLwindow1) then
    begin
    //gdb.GetCurrentDWG.OGLwindow1.setfocus;
    gdb.GetCurrentDWG.OGLwindow1.param.firstdraw := TRUE;
    gdb.GetCurrentDWG.OGLwindow1.reprojectaxis;
    gdb.GetCurrentDWG.OGLwindow1.{paint}draw;
    end;
    //redrawoglwnd;
    {poglwnd.loadmatrix;
    poglwnd.paint;}
    end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('cmdline.initialization');{$ENDIF}
end.
