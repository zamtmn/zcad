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
  //Forms,
  SysUtils,
  lineinfo,
  LazLogger,
  uzbpaths,uzcstrconsts,uzclog,uzcsysvars;

function ProcessException (handlername:shortstring;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer):string;

implementation

var
  OldExceptProc:TExceptProc;

procedure myDumpAddr(Addr: Pointer;var f:system.text);
//var
  //func,source:shortstring;
  //line:longint;
  //FoundLine:boolean;
begin
    //BackTraceStrFunc:=StoreBackTraceStrFunc;//this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  try
    WriteLn(f,BackTraceStrFunc(Addr));
  except
    writeLn(f,SysBackTraceStr(Addr));
  end;
end;

procedure MyDumpExceptionBackTrace2(var f:system.text; _FrameCount: Longint; _Frames: PCodePointer);
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

  myDumpExceptionBackTrace2(f,_FrameCount,_Frames);

  system.close(f);

  system.Assign(f,crashreportfilename);
  system.Append(f);
  WriteLn(f);
  WriteLn(f,'Latest log:');
  programlog.WriteLatestToFile(f);
  WriteLn(f,'Log end.');
  system.close(f);

  system.Assign(f,crashreportfilename);
  system.Append(f);
  WriteLn(f);
  WriteLn(f,'Build and runtime info:');
  Write(f,  '  ZCAD ');WriteLn(f,sysvar.SYS.SYS_Version^);
  Write(f,  '  Build with ');Write(f,sysvar.SYS.SSY_CompileInfo.SYS_Compiler);Write(f,' v');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerVer);
  Write(f,  '  Target CPU: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU);
  Write(f,  '  Target OS: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS);
  Write(f,  '  Compile date: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileDate);
  Write(f,  '  Compile time: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileTime);
  Write(f,  '  LCL version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_LCLVersion);
  Write(f,  '  Environment version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion);
  Write(f,  '  Program  path: ');WriteLn(f,ProgramPath);
  Write(f,  '  Temporary  path: ');WriteLn(f,TempPath);
  WriteLn(f,'end.');
  system.close(f);

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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');

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
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
