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

unit uzbexceptionscl;
{$mode delphi}
interface
uses
  SysUtils,lineinfo,gvector,
  uzbexceptionsparams;

type
  TCrashInfoProvider=procedure(var f:system.text;ARaiseList:PExceptObject);
  TCrashInfoProviders=TVector<TCrashInfoProvider>;

procedure SetCrashReportFilename(fn:ansistring);
function GetCrashReportFilename:ansistring;
procedure ProcessException (Obj : TObject;ARaiseList:PExceptObject);
procedure RegisterCrashInfoProvider(provider:TCrashInfoProvider;atBegining:boolean=false);
procedure RmoveCrashInfoProvider(provider:TCrashInfoProvider);

implementation

var
  OldExceptProc:TExceptProc=nil;
  CrashInfoProviders:TCrashInfoProviders=nil;
  CrashReportFile:ansistring;

procedure RegisterCrashInfoProvider(provider:TCrashInfoProvider;atBegining:boolean=false);
begin
   if not assigned(CrashInfoProviders) then
     CrashInfoProviders:=TCrashInfoProviders.Create;
   if atBegining then
     CrashInfoProviders.insert(0,provider)
   else
     CrashInfoProviders.PushBack(provider)
end;

procedure RmoveCrashInfoProvider(provider:TCrashInfoProvider);
var
  i:integer;
begin
   if assigned(CrashInfoProviders) then begin
     i:=0;
     while i<=CrashInfoProviders.Size-1 do begin
       if @CrashInfoProviders[i]=@provider then
         CrashInfoProviders.Erase(i);
     end;
   end;
end;


procedure myDumpAddr(Addr: Pointer;var f:system.text);
begin
    //BackTraceStrFunc:=StoreBackTraceStrFunc;//this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  try
    WriteLn(f,BackTraceStrFunc(Addr));
  except
    writeLn(f,SysBackTraceStr(Addr));
  end;
end;

procedure MyDumpExceptionBackTrace(var f:system.text;ARaiseList:PExceptObject);
var
  FrameNumber:Integer;
begin
  for FrameNumber := 0 to ARaiseList^.Framecount-1 do
    myDumpAddr(ARaiseList^.Frames[FrameNumber],f);
end;

procedure WriteStack(var f:system.text;ARaiseList:PExceptObject);
var
  Obj:TObject;
  Buf:ShortString;
  i:Integer;
begin
  if ARaiseList=nil then begin
    WriteLn(f,'WriteStack: Something wrong, RaiseList=nil ((');
    exit;
  end;

  Obj:=ARaiseList^.FObject;
  if Obj is Exception then begin
    WriteLn(f,'Crashed with message: ',(Obj as Exception).Message);//WriteLn(f,'');
  end else begin
    if Obj<>nil then begin
      WriteLn(f,'Crashed in class: ',obj.ClassName);//WriteLn(f,'');
    end;
  end;

  WriteLn(f,'ExceptAddr:');
  myDumpAddr(ExceptAddr,f);
  WriteLn(f,'Stack trace:');

  repeat
    myDumpExceptionBackTrace(f,ARaiseList);
    ARaiseList:=ARaiseList.Next;
  until ARaiseList=nil;

  WriteLn(f,'Stack end!');

  writeln(f,'ExceptionErrorMessage:');
  SetLength(Buf,ExceptionErrorMessage(ExceptObject,ExceptAddr,@Buf[1],255));
  for i:=0 to length(Buf) do
    if (Buf[i]=#10)or(Buf[i]=#13) then
      Buf[i]:=' ';
  WriteLn(f,'  ',Buf);

  WriteLn(f,'');
end;

procedure ProcessException (Obj : TObject;ARaiseList:PExceptObject);
var
  f:system.text;
  i:integer;
begin
  if assigned(CrashInfoProviders) then
    for i:=0 to CrashInfoProviders.Size-1 do
      if @CrashInfoProviders[i]<>nil then begin
        system.Assign(f,CrashReportFile);
        if FileExists(CrashReportFile) then
          system.Append(f)
        else
          system.Rewrite(f);
         CrashInfoProviders[i](f,ARaiseList);

        system.close(f);
      end;
end;



Procedure ZCCatchUnhandledException (Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer);
begin
  ProcessException(Obj,RaiseList);
end;

procedure InstallHandler;
begin
  RegisterCrashInfoProvider(WriteStack);

  //this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  //StoreBackTraceStrFunc:=BackTraceStrFunc;
  //BackTraceStrFunc:=@SysBackTraceStr;

  {$if FPC_FULlVERSION>=30002}
  AllowReuseOfLineInfoData:=false;
  {$endif}

  OldExceptProc:=ExceptProc;
  ExceptProc:=@ZCCatchUnhandledException;
end;

procedure UnInstallHandler;
begin
  ExceptProc:=OldExceptProc;
  OldExceptProc:=nil;
end;

procedure SetCrashReportFilename(fn:ansistring);
begin
   CrashReportFile:=fn;
end;

function GetCrashReportFilename:ansistring;
begin
   result:=CrashReportFile;
end;


initialization
  SetCrashReportFilename(CrashReportFileName);
  InstallHandler;
finalization
  UnInstallHandler;
  if Assigned(CrashInfoProviders) then
    FreeAndNil(CrashInfoProviders);
end.
