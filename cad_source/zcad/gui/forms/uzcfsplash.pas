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
 uzcFileStructure,
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
    procedure doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
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
var
  fLogo:string;
begin
  inherited;
  self.DoubleBuffered:=true;
  Logo:=TImage.create(self);
  Logo.Align:=alclient;
  flogo:=ConcatPaths([GetRoCfgsPath,CFScomponentsDir,CFSlogopngFile]);
  if FileExists(flogo) then
    Logo.Picture.LoadFromFile(flogo);
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
       ZCSysParams.notsaved.otherinstancerun:=InstanceRunning(zcaduniqueinstanceid,true,true);
     SplashForm:=TSplashForm.CreateNew(nil);
     //SplashForm.cb:=TComboBox.CreateParented(SplashForm.Handle);
     SplashForm.cb:=TComboBox.Create(NIL);
     SplashForm.cb.ParentWindow := SplashForm.Handle;

     SplashForm.cb.hide;
     if not ZCSysParams.notsaved.otherinstancerun then
     if not ZCSysParams.saved.nosplash then
                                  SplashForm.show;
     application.ProcessMessages;
     ZCSysParams.notsaved.defaultheight:=SplashForm.cb.Height;
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
procedure TLogerSplashBackend.doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if (lp_IncPos and MsgOptions)<>0 then
  SplashTextOutProc(msg,false);
end;

initialization
  Application.Initialize;
  createsplash(ZCSysParams.saved.UniqueInstance);
  LogerSplashBackend.init;
  ProgramLog.addBackend(LogerSplashBackend,'',[]);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  removesplash;
end.
