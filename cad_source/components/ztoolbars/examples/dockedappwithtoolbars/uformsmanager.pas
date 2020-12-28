unit uformsmanager;

interface
uses Generics.Collections,
     Types,Controls,
     Forms,LazLogger;
type
TFormSetupProc=procedure(Form:TControl);
PTFormInfoData=^TFormInfoData;
TFormInfoData=record
                          FormName:string;
                          DefaultBounds:TRect;
                          FormClass:TClass;
                          PInstanceVariable:Pointer;
                          SetupProc:TFormSetupProc;
                     end;
generic TMyDictionary<TKey, TValue>=class (specialize TDictionary<TKey, TValue>)
                                         function GetMutableValue(key:TKey; out pv:PValue):boolean;
end;
TFormName2FormInfoDataDic=specialize TMyDictionary<string,TFormInfoData>;
TFormsManager=class
                     FormsInfo:TFormName2FormInfoDataDic;
                     constructor Create;
                     destructor Destroy;override;
                     procedure RegisterZCADFormInfo(FormName:string;
                                                    DefaultBounds:TRect;
                                                    FormClass:TClass;
                                                    PInstanceVariable:Pointer=nil;
                                                    SetupProc:TFormSetupProc=nil);
                     function GetFormInfo(FormName:string; out PFormInfoData:PTFormInfoData):boolean;
                     function CreateFormInstance(var FormInfo:TFormInfoData):tobject;
                end;
var
  FormsManager:TFormsManager;
implementation
function TFormsManager.CreateFormInstance(var FormInfo:TFormInfoData):tobject;
begin
     result:=FormInfo.FormClass.NewInstance;
end;

function TMyDictionary.GetMutableValue(key:TKey; out pv:PValue):boolean;
var
  LIndex: SizeInt;
  LHash: UInt32;
begin
  LIndex := FindBucketIndex(FItems, Key, LHash);

  if LIndex < 0 then
    begin
      pv:=nil;
      result:=false;
    end
  else
    begin
      pv:=@FItems[LIndex].Pair.Value;
      result:=true;
    end;
end;

function TFormsManager.GetFormInfo(FormName:string; out PFormInfoData:PTFormInfoData):boolean;
begin
     result:=FormsInfo.GetMutableValue(FormName,PFormInfoData);
end;

procedure TFormsManager.RegisterZCADFormInfo(FormName:string;
                                             DefaultBounds:TRect;
                                             FormClass:TClass;
                                             PInstanceVariable:Pointer=nil;
                                             SetupProc:TFormSetupProc=nil);
var
  FID:TFormInfoData;
begin
     fid.FormName:=FormName;
     fid.DefaultBounds:=DefaultBounds;
     fid.FormClass:=FormClass;
     fid.PInstanceVariable:=PInstanceVariable;
     fid.SetupProc:=SetupProc;
     FormsInfo.add(FormName,fid);
end;

constructor TFormsManager.Create;
begin
     inherited;
     FormsInfo:=TFormName2FormInfoDataDic.create;
end;

destructor TFormsManager.Destroy;
begin
     FormsInfo.destroy;
     inherited;
end;

initialization
  FormsManager:=TFormsManager.Create;
finalization
  FormsManager.destroy;
end.

