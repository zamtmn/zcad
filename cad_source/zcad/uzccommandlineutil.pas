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

unit uzccommandlineutil;
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,varmandef,uzctnrvectorstrings,uzccommandsmanager,
     gzctnrVectorTypes,sysutils,uzbstrproc,uzcdrawings,uzegeometry,math,
     UGDBTracePropArray,uzglviewareadata,languade,Varman,uzcinterface,uzcstrconsts,
     strmy,LCLProc,uzccommandsabstract,LazUtilities,uzbtypes;
const
     commandsuffix='>';
     commandprefix=' ';
type
  TCLineMode=(CLCOMMANDREDY,CLCOMMANDRUN);
var
  INTFCommandLineEnabled:Boolean=true;
  INTFMessagesSuppressDoubles:TGDB3StateBool=T3SB_Default;
  aliases:TZctnrVectorStrings;
  mode:TCLineMode;
procedure processcommand(var input:string);

implementation

function FindAlias(prefix:String;comment,breacer:String):String;
var
   ps:pString;
   s:String;
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

procedure processcommand(var input:string);
var
  len: double;
  temp: gdbvertex;
  v:vardesk;
  s,divider,preddivider,expr:String;
  tv:gdbvertex;
  parseresult:PTZctnrVectorStrings;
  cmd,subexpr,superexpr:string;
  parsed:Boolean;
  command,operands:String;
  relativemarker:boolean;
  l,a:double;
begin
  try
    if commandmanager.CurrCmd.pcommandrunning<>nil then begin
      if commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode=TGPMWaitInput then begin
        commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode:=TGPMInput;
        commandmanager.CurrCmd.pcommandrunning.IData.Input:=input;
        exit;
      end else if (commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode in SomethingWait)and(GPInput in commandmanager.CurrCmd.pcommandrunning.IData.PossibleResult) then begin
        commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode:=TGPMInput;
        commandmanager.CurrCmd.pcommandrunning.IData.Input:=input;
        exit;
      end;

    end;
    if (length(input) > 0) then
    begin
      expr:=input;
      ParseCommand(expr,command,operands);
      cmd:=FindAlias(input,';','=');

      if TryStrToFloat(input,len) then
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
             if commandmanager.CurrCmd.pcommandrunning<>nil then
             begin
                  commandmanager.PushValue('','Double',@len);
                  commandmanager.CurrCmd.pcommandrunning.CommandContinue(CommandManager.CurrCmd.Context);
             end;
        end;
      end
      end
      else if input[1] = '$' then begin
                                              expr:=copy(input, 2, length(input) - 1);
                                              v:=evaluate(expr,SysUnit);
                                              if v.data.ptd<>nil  then
                                              begin
                                                s:=v.data.ptd^.GetValueAsString(v.data.Addr.Instance);
                                                v.data.ptd^.MagicFreeInstance(v.data.Addr.Instance);
                                                //v.Instance:=v.Instance;
                                                ZCMsgCallBackInterface.TextMessage(Format(rsExprOutText,[expr,s]),TMWOHistoryOut);
                                              end;
                                         end
      else if commandmanager.FindCommand(uppercase({cmd}command))<>nil then
          begin
               //CmdEdit.text:=FindAlias(CmdEdit.text,';','=');
               input:='';
               commandmanager.executecommand(Cmd,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          end
      else begin
           cmd:=readspace(input);
           if length(cmd)>0 then
           begin
           if cmd[1]='@' then
           begin
             relativemarker:=true;
             cmd:=copy(cmd,2,length(cmd)-1);
           end
           else
             relativemarker:=false;
           superexpr:='';
           preddivider:='';
           repeat
           subexpr:=GetPredStr(cmd,[',','<'],divider);
           v:=evaluate(subexpr,SysUnit);
           parsed:=v.data.Addr.Instance<>nil;
           if parsed then
           begin
           s:=v.data.ptd^.GetValueAsString(v.data.Addr.Instance);
           if superexpr='' then
                               superexpr:=s
                           else
                               superexpr:=superexpr+preddivider+s
           end;
           preddivider:=divider;
           until (cmd='')or(not parsed);
           if parsed then
           begin
           ZCMsgCallBackInterface.TextMessage(Format(rsExprOutText,[input,superexpr]),TMWOHistoryOut);
           if IsParsed('_realnumber'#0'_softspace'#0'=,_realnumber'#0'_softspace'#0'=,_realnumber'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 begin
                 temp:=CreateVertex(strtodouble(parseresult^.getData(0)),strtodouble(parseresult^.getData(1)),strtodouble(parseresult^.getData(2)));
                 if relativemarker then
                 if drawings.GetCurrentDWG.wa.tocommandmcliccount>0 then
                   temp:=VertexAdd(temp,drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[0].worldcoord);
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,temp,MZW_LBUTTON,nil);
                 end;
                 if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
           end
           else if IsParsed('_realnumber'#0'_softspace'#0'=,_realnumber'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 begin
                 len:=drawings.GetCurrentDWG.wa.param.ontrackarray.total;
                 temp:=CreateVertex(strtodouble(parseresult^.getData(0)),strtodouble(parseresult^.getData(1)),0);
                 if relativemarker then
                 if drawings.GetCurrentDWG.wa.tocommandmcliccount>0 then
                   temp:=VertexAdd(temp,drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[0].worldcoord);
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,temp,MZW_LBUTTON,nil);
                 end;
                 if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
           end
           else if IsParsed('_realnumber'#0'_softspace'#0'=<_realnumber'#0,superexpr,parseresult)then
           begin
                 if drawings.GetCurrentDWG<>nil then
                 if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
                 begin
                 len:=drawings.GetCurrentDWG.wa.param.ontrackarray.total;
                 l:=strtodouble(parseresult^.getData(0));
                 a:=strtodouble(parseresult^.getData(1));
                 temp:=CreateVertex(l*cos(a*pi/180),l*sin(a*pi/180),0);
                 if relativemarker then
                 if drawings.GetCurrentDWG.wa.tocommandmcliccount>0 then
                   temp:=VertexAdd(temp,drawings.GetCurrentDWG.wa.param.ontrackarray.otrackarray[0].worldcoord);
                 commandmanager.sendcoordtocommandTraceOn(drawings.GetCurrentDWG.wa,temp,MZW_LBUTTON,nil);
                 end;
                 if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
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

                 if parseresult<>nil then begin parseresult^.Done;Freemem(Pointer(parseresult));end;
           end
           end
              else
                  ZCMsgCallBackInterface.TextMessage('Unable to parse line "'+subexpr+'"',TMWOShowError);
          end;
      end;
    end;
  finally
    input:='';
    if assigned(drawings.GetCurrentDWG) then
      if assigned(drawings.GetCurrentDWG.wa.getviewcontrol) then
      begin
        drawings.GetCurrentDWG.wa.param.firstdraw := TRUE;
        drawings.GetCurrentDWG.wa.reprojectaxis;
        drawings.GetCurrentDWG.wa.{paint}draw;
        drawings.GetCurrentDWG.wa.asyncupdatemouse(0);
      end;
  end;
end;

end.
