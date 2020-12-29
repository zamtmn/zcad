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
{$INCLUDE def.inc}
interface
uses uzbtypesbase,sysutils, dynlibs, uzclog,uzbmemman,gzctnrvectordata,uzeentity,
     LazLogger;
type
    {Export+}
  {REGISTERRECORDTYPE PluginVersionInfo}
  PluginVersionInfo=record
    PluginName: pansichar;
    PluginVersion: GDBInteger;
  end;
  GetVersFunc=function: PluginVersionInfo;
  Initfunc=function: GDBInteger;
  pmoduledesc=^moduledesc;
  {REGISTERRECORDTYPE moduledesc}
  moduledesc=record
    modulename:pansichar;
    modulehandle:thandle;
    ininfunction:function(path:pansichar):GDBInteger;
    donefunction:function:GDBInteger;
  end;
  arraymoduledesc=packed array[0..0] of moduledesc;
  popenarraymoduledesc=^openarraymoduledesc;
  {REGISTERRECORDTYPE openarraymoduledesc}
  openarraymoduledesc=record
    count:GDBInteger;
    modarr:arraymoduledesc;
  end;
  {REGISTERRECORDTYPE copyobjectdesc}
  copyobjectdesc=record
                 oldnum,newnum:PGDBOBJENTITY;
                 end;
  copyobjectarray=packed array [0..0] of copyobjectdesc;
  pcopyobjectarraywm=^copyobjectarraywm;
  copyobjectarraywm=record
                          max:GDBInteger;
                          copyobjectarray:copyobjectarray;
                    end;
  PGDBPluginsArray=^GDBPluginsArray;
  {REGISTEROBJECTTYPE GDBPluginsArray}
  GDBPluginsArray= object(GZVectorData<moduledesc>)
                        constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                        procedure loadplugins(path: GDBString);
                  end;
     {Export-}

var //pmodule: popenarraymoduledesc;
    gdbplugins:GDBPluginsArray;
function getpmodule: GDBPointer;
//procedure loadplugins(path: GDBString);
{procedure startup;
procedure finalize;}
{$IFDEF DELPHI}exports getpmodule;{$ENDIF}
implementation
constructor GDBPluginsArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(moduledesc)});
end;
procedure GDBPluginsArray.loadplugins(path: GDBString);
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

function getpmodule: GDBPointer;
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
     gdbplugins.init({$IFDEF DEBUGBUILD}'{7893C445-EAE9-4361-B7AF-244513EE799F}',{$ENDIF}100);
end;
procedure finalize;
begin
     gdbplugins.FreewithprocAndDone(@freeplugin);
end;*)
initialization
gdbplugins.init({$IFDEF DEBUGBUILD}'{7893C445-EAE9-4361-B7AF-244513EE799F}',{$ENDIF}100);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  gdbplugins.Freewithproc(freeplugin);
  gdbplugins.done;
end.
