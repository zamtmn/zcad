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
  SysUtils,
  lineinfo,
  uzcstrconsts,gzctnrstl;

type
  TCrashInfoProvider=procedure(var f:system.text);
  TCrashInfoProviders=TMyVector<TCrashInfoProvider>;


function ProcessException (handlername:shortstring;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer):string;
procedure RegisterCrashInfoProvider(provider:TCrashInfoProvider);
//procedure RmoveCrashInfoProvider(provider:TCrashInfoProvider);

implementation

var
  OldExceptProc:TExceptProc=nil;
  CrashInfoProviders:TCrashInfoProviders=nil;

procedure RegisterCrashInfoProvider(provider:TCrashInfoProvider);
begin
   if not assigned(CrashInfoProviders) then
     CrashInfoProviders:=TCrashInfoProviders.Create;
   CrashInfoProviders.PushBack(provider);
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

function ProcessException (handlername:shortstring;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer):string;
var
  f:system.text;
  crashreportfilename,errmsg:shortstring;
  i:integer;
begin
  crashreportfilename:=GetTempDir+'zcadcrashreport.txt';
  system.Assign(f,crashreportfilename);
  if FileExists(crashreportfilename) then
                                        system.Append(f)
                                    else
                                        system.Rewrite(f);
  WriteLn(f,'');
  WriteLn(f,programname+' crashed((');WriteLn(f,'');
  WriteLn(f,handlername);
  WriteLn(f,'');

  if Obj is Exception then begin
    WriteLn(f,(Obj as Exception).Message);WriteLn(f,'');
  end else begin
    if Obj<>nil then begin
      WriteLn(f,obj.ClassName);WriteLn(f,'');
    end;
  end;

  myDumpExceptionBackTrace(f,_FrameCount,_Frames);

  system.close(f);

  if assigned(CrashInfoProviders) then
    for i:=0 to CrashInfoProviders.Size-1 do
      if @CrashInfoProviders[i]<>nil then begin
        system.Assign(f,crashreportfilename);
        system.Append(f);

        CrashInfoProviders[i](f);

        system.close(f);
      end;

  errmsg:=DateTimeToStr(Now);
  system.Assign(f,crashreportfilename);
  system.Append(f);
  WriteLn(f);
  WriteLn(f,'Date:');
  WriteLn(f,errmsg);
  WriteLn(f,'______________________________________________________________________________________');
  system.close(f);
  result:=crashreportfilename;
end;



Procedure ZCCatchUnhandledException (Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  ProcessException('Handled by UZCExceptions',Obj,Addr,_FrameCount,_Frames);
end;

initialization
  {
  //this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  StoreBackTraceStrFunc:=BackTraceStrFunc;
  BackTraceStrFunc:=@SysBackTraceStr;
  }
  {$if FPC_FULlVERSION>=30002}
  AllowReuseOfLineInfoData:=false;
  {$endif}

  OldExceptProc:=ExceptProc;
  ExceptProc:=@ZCCatchUnhandledException;
finalization
end.
