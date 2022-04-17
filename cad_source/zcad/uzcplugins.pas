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

unit uzcplugins;
{$INCLUDE zengineconfig.inc}
interface
uses sysutils, dynlibs, uzclog,gzctnrVector,uzeentity,
     LazLogger;
type
    {Export+}
  {REGISTERRECORDTYPE PluginVersionInfo}
  PluginVersionInfo=record
    PluginName: pansichar;
    PluginVersion: Integer;
  end;
  GetVersFunc=function: PluginVersionInfo;
  Initfunc=function: Integer;
  pmoduledesc=^moduledesc;
  {REGISTERRECORDTYPE moduledesc}
  moduledesc=record
    modulename:pansichar;
    modulehandle:thandle;
    ininfunction:function(path:pansichar):Integer;
    donefunction:function:Integer;
  end;
  arraymoduledesc=packed array[0..0] of moduledesc;
  popenarraymoduledesc=^openarraymoduledesc;
  {REGISTERRECORDTYPE openarraymoduledesc}
  openarraymoduledesc=record
    count:Integer;
    modarr:arraymoduledesc;
  end;
  {REGISTERRECORDTYPE copyobjectdesc}
  copyobjectdesc=record
                 oldnum,newnum:PGDBOBJENTITY;
                 end;
  copyobjectarray=packed array [0..0] of copyobjectdesc;
  pcopyobjectarraywm=^copyobjectarraywm;
  copyobjectarraywm=record
                          max:Integer;
                          copyobjectarray:copyobjectarray;
                    end;
  PGDBPluginsArray=^GDBPluginsArray;
  {REGISTEROBJECTTYPE GDBPluginsArray}
  GDBPluginsArray= object(GZVector<moduledesc>)
                        constructor init(m:Integer);
                        procedure loadplugins(path: String);
                  end;
     {Export-}

var //pmodule: popenarraymoduledesc;
    gdbplugins:GDBPluginsArray;
function getpmodule: Pointer;
//procedure loadplugins(path: String);
{procedure startup;
procedure finalize;}
{$IFDEF DELPHI}exports getpmodule;{$ENDIF}
implementation
constructor GDBPluginsArray.init;
begin
  inherited init(m);
end;
procedure GDBPluginsArray.loadplugins(path: String);
var
  sr: TSearchRec;
  dllhandle: thandle;
  gvp: GetVersFunc;
  registercommands: Initfunc;
  pv: PluginVersionInfo;
  temp:moduledesc;
begin
  programlog.logoutstr('GDBPlugins.LoadPlugins("'+path+'")',lp_IncPos,LM_Necessarily);
  if FindFirst(path + '*.dll', faAnyFile, sr) = 0 then
  begin
    repeat
      programlog.logoutstr('Found file '+path + sr.Name,0,LM_Necessarily);
      dllhandle := loadlibrary(pchar(path + sr.Name));
      if dllhandle <> 0 then
      begin
        programlog.logoutstr('File load...Ok',0,LM_Necessarily);
        @gvp := nil;
        @gvp := GetProcAddress(dllhandle, 'GetVersionInfo');
        if @gvp <> nil then
        begin
          pv := gvp;
          programlog.logoutstr('Plugin  version '+inttostr(pv.PluginVersion),0,LM_Necessarily);
          if pv.PluginVersion = 1 then
          begin
            temp.modulehandle := dllhandle;
            temp.modulename := pv.PluginName;
            @temp.ininfunction := GetProcAddress(dllhandle, 'Initialize');
            temp.ininfunction(pansichar(path));
            @temp.donefunction := GetProcAddress(dllhandle, 'Finalize');
            registercommands := GetProcAddress(dllhandle, 'RegisterCommands');
            registercommands;
            PushBackData(temp);
          end
          else
          begin
            freelibrary(dllhandle);
            programlog.logoutstr('Version incompatible',0,LM_Necessarily);
          end;

        end
        else
          begin
          programlog.logoutstr('No version info, unload'+inttostr(pv.PluginVersion),0,LM_Necessarily);
          freelibrary(dllhandle);
          end;

      end
      else
      begin
      programlog.logoutstr('File load error',0,LM_Necessarily);
      end;

    until FindNext(sr) <> 0;
    sysutils.FindClose(sr);
  end;
  programlog.logoutstr('end;',lp_DecPos,LM_Necessarily);
end;

function getpmodule: Pointer;
begin
  result:=@gdbplugins;
end;
procedure freeplugin(const p:pmoduledesc);
begin
     p^.donefunction;
     p^.modulename:='';
     freelibrary(p^.modulehandle);
end;
(*procedure startup;
begin
     gdbplugins.init(100);
end;
procedure finalize;
begin
     gdbplugins.FreewithprocAndDone(@freeplugin);
end;*)
initialization
gdbplugins.init(100);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  gdbplugins.Freewithproc(freeplugin);
  gdbplugins.done;
end.
