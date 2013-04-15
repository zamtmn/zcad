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

unit splashwnd;
{$INCLUDE def.inc}
interface
uses
 zcadinterface,zcadstrconsts,strproc,Forms, stdctrls, Controls, Graphics,ExtCtrls,
 gdbasetypes,SysInfo,fileutil,sysutils;
type
  TSplashWnd = class(TForm)
    txt:tlabel;
    Logo: TImage;
    procedure TXTOut(s:GDBstring;pm:boolean);virtual;
    private
    procedure AfterConstruction; override;
  end;
var
   SplashWindow:TSplashWnd;

procedure createsplash;
procedure removesplash;
procedure SplashTextOutProc(s:string;pm:boolean);
implementation
uses log;
procedure SplashTextOutProc(s:string;pm:boolean);
begin
     if assigned(SplashWindow) then
                                   SplashWindow.TXTOut(s,true);
end;

procedure TSplashWnd.TXTOut;
begin
     self.txt.Caption:=rsVinfotext+#13#10+rsInitialization+#13#10+s;
     if pm then
               application.ProcessMessages
           else
               self.txt.repaint;
end;
procedure TSplashWnd.AfterConstruction;
begin
  inherited;
  self.DoubleBuffered:=true;
  Logo:=TImage.create(self);
  Logo.Align:=alclient;
  if FileExists((sysparam.programpath)+'components/logo.png') then
                                                                 Logo.Picture.LoadFromFile({SysToUTF8}(sysparam.programpath)+'components/logo.png');
  Logo.Parent:=self;
  self.BorderStyle:=bsNone;
  self.Color:=clNone;
  self.FormStyle:=fsSplash;
  clientwidth:=400;
  clientheight:=300;
  self.Position:=poScreenCenter;
  txt:={tstatictext}tlabel.create(self);
  //txt.scrollbars:=ssAutoBoth;
  txt.align:=alnone;
  txt.Height:=60;
  txt.Width:=self.ClientWidth;

  txt.caption:='START!';
  txt.Parent := self;
end;
procedure createsplash;
begin
     SplashWindow:=TSplashWnd.CreateNew(nil);
     if not sysparam.nosplash then
                                  SplashWindow.show;
     application.ProcessMessages;
end;
procedure removesplash;
begin
     if assigned(SplashWindow) then
     begin
          SplashWindow.Free;
          SplashWindow:=nil;
     end;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('splashwnd.initialization');{$ENDIF}
  Application.Initialize;
  //RequireDerivedFormResource:=false;
  createsplash;
  SplashTextOut:=SplashTextOutProc;
finalization
  removesplash;
end.
