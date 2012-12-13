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

unit ucxmenumgr;
{$INCLUDE def.inc}
interface

uses
  umytreenode,commandlinedef,ExtCtrls,lclproc,Graphics,ActnList,{ComCtrls,StdCtrls,}Controls,Classes,menus,Forms,{$IFDEF FPC}lcltype,{$ENDIF}fileutil,{ButtonPanel,}Buttons,
  {strutils,}{$IFNDEF DELPHI}intftranslations,{$ENDIF}sysutils,strproc,varmandef,Varman,UBaseTypeDescriptor,gdbasetypes,shared,SysInfo,UGDBOpenArrayOfByte;

type
   tcxmenumgr=class
   CurrentCXMenu:^TmyPopupMenu;
   menupopupcount,notprocessedclosecount:GDBInteger;
   procedure PopUpMenu(var menu:TmyPopupMenu);
   procedure reset;
   procedure RegisterLCLMenu(var menu:TmyPopupMenu);
   procedure CloseNotify(Sender: TObject);
   procedure LCLCloseNotify(Sender: TObject);
   procedure PopUpNotify(Sender: TObject);
   procedure CloseCurrentMenu;
   procedure AsyncCloseCurrentMenu(Data: PtrInt);
   function ismenupopup:gdbboolean;
   end;
var
   cxmenumgr:tcxmenumgr=nil;
implementation
uses {commandline,}log{,sharedgdb};
procedure tcxmenumgr.RegisterLCLMenu(var menu:TmyPopupMenu);
begin
     menu.OnClose:=LCLCloseNotify;
     menu.OnPopup:=PopUpNotify;
end;
procedure tcxmenumgr.PopUpMenu(var menu:TmyPopupMenu);
begin
     if CurrentCXMenu<>nil then
     if CurrentCXMenu^<>nil then
                              CloseCurrentMenu;
     CurrentCXMenu:=@menu;
     CurrentCXMenu.OnClose:=CloseNotify;
     inc(menupopupcount);
     menu.PopUp;
end;
procedure tcxmenumgr.PopUpNotify(Sender: TObject);
begin
     inc(menupopupcount);
end;
procedure tcxmenumgr.reset;
begin
     notprocessedclosecount:=0;
end;

procedure tcxmenumgr.LCLCloseNotify(Sender: TObject);
begin
     dec(menupopupcount);
     dec(notprocessedclosecount);
end;
procedure tcxmenumgr.CloseNotify(Sender: TObject);
begin
     //CloseCurrentMenu;
     Application.QueueAsyncCall(AsyncCloseCurrentMenu, 0);
     dec(menupopupcount);
end;
procedure tcxmenumgr.AsyncCloseCurrentMenu(Data: PtrInt);
begin
     CloseCurrentMenu;
end;

procedure tcxmenumgr.CloseCurrentMenu;
begin
     if CurrentCXMenu<>nil then
     if CurrentCXMenu^<>nil then
                                begin
                                     freeandnil(CurrentCXMenu^);
                                     CurrentCXMenu:=nil;
                                end;
end;
function tcxmenumgr.ismenupopup:gdbboolean;
begin
     if CurrentCXMenu<>nil then
     if CurrentCXMenu^<>nil then
                                begin
                                     result:=true;
                                     exit;
                                end;
     if notprocessedclosecount<>0 then
                                begin
                                     result:=true;
                                     //notprocessedclosecount:=true;
                                     notprocessedclosecount:=0;
                                     exit;
                                end;
     result:=false;
end;

initialization
{$IFDEF DEBUGINITSECTION}LogOut('ucxmenumgr.initialization');{$ENDIF}
cxmenumgr:=tcxmenumgr.Create;
cxmenumgr.menupopupcount:=0;
cxmenumgr.notprocessedclosecount:=0;
finalization
freeandnil(cxmenumgr);
end.


