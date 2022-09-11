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

unit uzcguimanager;
{$INCLUDE zengineconfig.inc}


interface
uses gzctnrSTL,uzclog,uzcsysvars,uzeentity,Types,Controls,
     Forms;
type
TZCADFormSetupProc=procedure(Form:TControl);
TZCADFormCreateProc=function(FormName:string):TForm;
PTFormInfoData=^TFormInfoData;
TFormInfoData=record
                          FormName,FormCaption:String;
                          DefaultBounds:TRect;
                          FormClass:TClass;
                          SetupProc:TZCADFormSetupProc;
                          CreateProc:TZCADFormCreateProc;
                          PInstanceVariable:Pointer;
                          DesignTimeForm:boolean;
                    end;
TFormName2FormInfoDataMap=GKey2DataMap<String,TFormInfoData{,LessString}>;
TZCADGUIManager=class
                     FormsInfo:TFormName2FormInfoDataMap;
                     constructor Create;
                     destructor Destroy;override;
                     procedure RegisterZCADFormInfo(FormName,FormCaption:String;const FormClass:TClass;const bounds:TRect;SetupProc:TZCADFormSetupProc;CreateProc:TZCADFormCreateProc;PInstanceVariable:pointer;DesignTimeForm:boolean=false);
                     function GetZCADFormInfo(FormName:String; out PFormInfoData:PTFormInfoData):boolean;
                     function CreateZCADFormInstance(var FormInfo:TFormInfoData):tobject;
                end;
var
  ZCADGUIManager:TZCADGUIManager;
implementation
function TZCADGUIManager.CreateZCADFormInstance(var FormInfo:TFormInfoData):tobject;
begin
     result:=FormInfo.FormClass.NewInstance;
end;

function TZCADGUIManager.GetZCADFormInfo(FormName:String; out PFormInfoData:PTFormInfoData):boolean;
begin
     result:=FormsInfo.MyGetMutableValue(FormName,PFormInfoData);
end;

procedure TZCADGUIManager.RegisterZCADFormInfo(FormName,FormCaption:String;const FormClass:TClass;const bounds:TRect;SetupProc:TZCADFormSetupProc;CreateProc:TZCADFormCreateProc;PInstanceVariable:pointer;DesignTimeForm:boolean=false);
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
     fid.DesignTimeForm:=DesignTimeForm;
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
  ZCADGUIManager:=TZCADGUIManager.Create;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ZCADGUIManager.destroy;
end.
