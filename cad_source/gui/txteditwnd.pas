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

unit txteditwnd;
{$INCLUDE def.inc}
interface
uses
 gdbase{,UGDBDescriptor,math,commandline,varman},languade{,UGDBTracePropArray},ZButtonsGeneric,
  zforms,zmemos,ZEditsMultiline,ZEditsWithProcedure{,zbasicvisible,varmandef,shared},ZGUIsCT,ZStaticsText,sysinfo,memman,gdbasetypes;
type
  TEditWnd = object(zform)
    txt:PZEditMultiline;
    btn:PZButtonGeneric;
    procedure beforeinit;virtual;
    procedure BtnOKPress(sender:PZButtongeneric);virtual;
    procedure size;virtual;
  end;
implementation
procedure TEditWnd.beforeinit;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{0A3EB636-A44C-439A-A838-A928B9214B0E}',{$ENDIF}GDBPointer(txt),sizeof(ZEditMultiline));
  txt^.initxywh('',@self,0,0,clientwidth,clientheight-24,false);
  GDBGetMem({$IFDEF DEBUGBUILD}'{0A3EB636-A44C-439A-A838-A928B9214B0E}',{$ENDIF}GDBPointer(btn),sizeof(ZButtonGeneric));
  btn^.initxywh('OK','',@self,0,clientheight-24,clientwidth,24,false);
  btn^.onClickMethod:=BtnOKPress;
  //txt^.align:=al_client;
  //txt^.setstyle(SS_LEFT,SS_CENTER)
end;
procedure TEditWnd.BtnOKPress(sender:PZButtongeneric);
begin
     ExitCode:=ZWEC_OKButton;
     close;
end;
procedure TEditWnd.size;
//var pzb:pzbasic;
//    ir:itrec;
//    clw,clh:integer;
//    xratio,yratio:double;
begin
     inherited;
     txt^.setxywh(0,0,clientwidth,clientheight-24);
     btn^.setxywh(0,clientheight-24,clientwidth,24);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('texteditwnd.initialization');{$ENDIF}
end.
