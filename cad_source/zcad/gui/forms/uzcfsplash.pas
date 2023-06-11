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

unit uzcfsplash;
{$INCLUDE zengineconfig.inc}
interface
uses
 uzcsysparams,uzbpaths,uniqueinstanceraw,uzcstrconsts,uzbstrproc,Forms,
 stdctrls, Controls, Graphics,ExtCtrls,LazUTF8,sysutils,
 uzbLogTypes,uzbLogDecorators,
 uzcLog;
type
  TSplashForm = class(TForm)
    txt:tlabel;
    Logo: TImage;
    cb:TComboBox;
    procedure TXTOut(s:String;pm:boolean);virtual;
    public
    procedure AfterConstruction; override;
  end;
var
   SplashForm:TSplashForm;

procedure createsplash(RunUniqueInstance:boolean);
procedure removesplash;
procedure SplashTextOutProc(s:string;pm:boolean);
implementation
type
  TLogerSplashBackend=object(TLogerBaseBackend)
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    constructor init;
  end;

var
  LogerSplashBackend:TLogerSplashBackend;

procedure SplashTextOutProc(s:string;pm:boolean);
begin
  if assigned(SplashForm) then
    SplashForm.TXTOut(s,{$IF DEFINED(MSWINDOWS)}false{$ELSE}true{$ENDIF});
end;

procedure TSplashForm.TXTOut;
begin
     self.txt.Caption:=rsVinfotext+#13#10+rsInitialization+#13#10+s;
     if pm then
               application.ProcessMessages
           else
               self.txt.repaint;
end;
procedure TSplashForm.AfterConstruction;
begin
  inherited;
  self.DoubleBuffered:=true;
  Logo:=TImage.create(self);
  Logo.Align:=alclient;
  if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ProgramPath)+'components/logo.png') then
                                                                 Logo.Picture.LoadFromFile((ProgramPath)+'components/logo.png');
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
     if RunUniqueInstance then
       sysparam.notsaved.otherinstancerun:=InstanceRunning(zcaduniqueinstanceid,true,true);
     SplashForm:=TSplashForm.CreateNew(nil);
     //SplashForm.cb:=TComboBox.CreateParented(SplashForm.Handle);
     SplashForm.cb:=TComboBox.Create(NIL);
     SplashForm.cb.ParentWindow := SplashForm.Handle;

     SplashForm.cb.hide;
     if not sysparam.notsaved.otherinstancerun then
     if not sysparam.saved.nosplash then
                                  SplashForm.show;
     application.ProcessMessages;
     sysparam.notsaved.defaultheight:=SplashForm.cb.Height;
end;
procedure removesplash;
begin
     if assigned(SplashForm) then
     begin
          SplashForm.cb.Destroy;
          SplashForm.hide;
          SplashForm.Free;
          SplashForm:=nil;
     end;
end;
procedure TLogerSplashBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if (lp_IncPos and MsgOptions)<>0 then
  SplashTextOutProc(msg,false);
end;
constructor TLogerSplashBackend.init;
begin
end;

initialization
  Application.Initialize;
  createsplash(SysParam.saved.UniqueInstance);
  LogerSplashBackend.init;
  ProgramLog.addBackend(LogerSplashBackend,'',[]);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  removesplash;
end.
