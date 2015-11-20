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

unit zcguimanager;
{$INCLUDE def.inc}


interface
uses usimplegenerics,
    memman,zcadsysvars,GDBase,GDBasetypes,gdbEntity,Types,Controls,Forms;
type
TZCADFormSetupProc=procedure(Form:TControl);
TZCADFormCreateProc=function:TForm;
PTFormInfoData=^TFormInfoData;
TFormInfoData=packed record
                          FormName,FormCaption:GDBString;
                          DefaultBounds:TRect;
                          FormClass:TClass;
                          SetupProc:TZCADFormSetupProc;
                          CreateProc:TZCADFormCreateProc;
                          PInstanceVariable:Pointer;
                    end;
TFormName2FormInfoDataMap=GKey2DataMap<GDBString,TFormInfoData,LessGDBString>;
TZCADGUIManager=class
                     FormsInfo:TFormName2FormInfoDataMap;
                     constructor Create;
                     destructor Destroy;virtual;
                     procedure RegisterZCADFormInfo(FormName,FormCaption:GDBString;const FormClass:TClass;const bounds:TRect;SetupProc:TZCADFormSetupProc;CreateProc:TZCADFormCreateProc;PInstanceVariable:pointer);
                     function GetZCADFormInfo(FormName:GDBString; out PFormInfoData:PTFormInfoData):boolean;
                     function CreateZCADFormInstance(var FormInfo:TFormInfoData):tobject;
                end;
var
  ZCADGUIManager:TZCADGUIManager;
implementation
uses
    uzclog;
function TZCADGUIManager.CreateZCADFormInstance(var FormInfo:TFormInfoData):tobject;
begin
     result:=FormInfo.FormClass.NewInstance;
end;

function TZCADGUIManager.GetZCADFormInfo(FormName:GDBString; out PFormInfoData:PTFormInfoData):boolean;
begin
     result:=FormsInfo.MyGetMutableValue(FormName,PFormInfoData);
end;

procedure TZCADGUIManager.RegisterZCADFormInfo(FormName,FormCaption:GDBString;const FormClass:TClass;const bounds:TRect;SetupProc:TZCADFormSetupProc;CreateProc:TZCADFormCreateProc;PInstanceVariable:pointer);
var
  FID:TFormInfoData;
begin
     fid.FormName:=FormName;
     fid.FormCaption:=FormCaption;
     fid.FormClass:=FormClass;
     fid.DefaultBounds:=bounds;
     fid.SetupProc:=SetupProc;
     fid.CreateProc:=CreateProc;
     fid.PInstanceVariable:=PInstanceVariable;
     FormsInfo.RegisterKey(FormName,fid);
end;

constructor TZCADGUIManager.Create;
begin
     inherited;
     FormsInfo:=TFormName2FormInfoDataMap.create;
end;

destructor TZCADGUIManager.Destroy;
begin
     FormsInfo.destroy;
     inherited;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcadguimanager.initialization');{$ENDIF}
  ZCADGUIManager:=TZCADGUIManager.Create;
finalization
  ZCADGUIManager.destroy;
end.
