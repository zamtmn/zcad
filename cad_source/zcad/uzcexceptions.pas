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

unit uzcexceptions;
{$INCLUDE def.inc}
interface
uses
  SysUtils,lineinfo,gvector;

const
  InitialCrashReportFilename='crashreport.txt';

type
  TCrashInfoProvider=procedure(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
  TCrashInfoProviders=TVector<TCrashInfoProvider>;

procedure SetCrashReportFilename(fn:ansistring);
function GetCrashReportFilename:ansistring;
procedure ProcessException (Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
procedure RegisterCrashInfoProvider(provider:TCrashInfoProvider;atBegining:boolean=false);
procedure RmoveCrashInfoProvider(provider:TCrashInfoProvider);

implementation

var
  OldExceptProc:TExceptProc=nil;
  CrashInfoProviders:TCrashInfoProviders=nil;
  CrashReportFilename:ansistring;

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

procedure MyDumpExceptionBackTrace(var f:system.text; _FrameCount: Longint; _Frames: PCodePointer);
var
  FrameCount: integer;
  Frames: PPointer;
  FrameNumber:Integer;
begin
  WriteLn(f,'Stack trace:');
  myDumpAddr(ExceptAddr,f);
  FrameCount:=_FrameCount;
  Frames:=_Frames;
  for FrameNumber := 0 to FrameCount-1 do
    myDumpAddr(Frames[FrameNumber],f);
end;

procedure WriteStack(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
var
  errmsg:shortstring;
begin
  if Obj is Exception then begin
    WriteLn(f,'Crashed with message: ',(Obj as Exception).Message);WriteLn(f,'');
  end else begin
    if Obj<>nil then begin
      WriteLn(f,'Crashed in class: ',obj.ClassName);WriteLn(f,'');
    end;
  end;

  errmsg:=DateTimeToStr(Now);
  WriteLn(f,'Date: ',errmsg);
  WriteLn(f,'');

  myDumpExceptionBackTrace(f,_FrameCount,_Frames);
WriteLn(f,'');
end;

procedure ProcessException (Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
var
  f:system.text;
  i:integer;
begin
  if assigned(CrashInfoProviders) then
    for i:=0 to CrashInfoProviders.Size-1 do
      if @CrashInfoProviders[i]<>nil then begin
        system.Assign(f,CrashReportFilename);
        if FileExists(CrashReportFilename) then
          system.Append(f)
        else
          system.Rewrite(f);
         CrashInfoProviders[i](f,Obj,Addr,_FrameCount,_Frames);

        system.close(f);
      end;
end;



Procedure ZCCatchUnhandledException (Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  ProcessException(Obj,Addr,_FrameCount,_Frames);
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
   CrashReportFilename:=fn;
end;

function GetCrashReportFilename:ansistring;
begin
   result:=CrashReportFilename;
end;


initialization
  SetCrashReportFilename(GetTempDir+InitialCrashReportFilename);
  InstallHandler;
finalization
  UnInstallHandler;
  if Assigned(CrashInfoProviders) then
    FreeAndNil(CrashInfoProviders);
end.
