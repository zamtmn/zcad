unit Benchmrk;

interface

{$I VCheck.inc}

{$IFDEF V_FREEPASCAL}
  {$DEFINE CONS}
{$ENDIF}
{$IFDEF LINUX}
  {$DEFINE CONS}
{$ENDIF}

{$IFDEF V_D6}{$J+}{$ENDIF}

uses
  {$IFDEF V_WIN}{$IFDEF WIN32}Windows{$ELSE}WinTypes, WinProcs{$ENDIF},
  Debug, {$ENDIF}ExtType;

procedure RunBenchMark(TestTime: Integer);

implementation

uses
  Int8g, UInt8g, Int16g, UInt16g, Int32g, UInt32g, Int64g,
  F32g, F64g, F80g,
  Int8v, UInt8v, Int16v, UInt16v, Int32v, UInt32v, Int64v,
  F32v, F64v, F80v,
  Int8m, UInt8m, Int16m, UInt16m, Int32m, UInt32m, Int64m,
  F32m, F64m, F80m, Aliasv, Aliasm,
  CheckCPU, SysUtils{$IFNDEF CONS}, Controls, Forms{$ENDIF};

{$IFDEF CONS}
procedure DebugLine(const S: String);
begin
  writeln(S);
end;
{$ENDIF}

var
  hProcess: THandle;

procedure RunBenchMark;
const
  TestCount = {$IFDEF V_32} 6 {$ELSE} 4 {$ENDIF};
  SizeToTest: array [0..TestCount - 1] of Integer =
    (10, 100, 1000, 10000{$IFDEF V_32}, 100000, 500000{$ENDIF});
  LocalCounter: Integer = 0;
var
  S: String;
  Counter, T: LongInt;
  StartTime: {$IFDEF V_WIN}LongInt{$ELSE}TDateTime{$ENDIF};
  {$IFDEF V_WIN}
  {$IFDEF WIN32}
  {$IFDEF V_DELPHI}
  CreationTime, ExitTime, KernelTime, UserTime: TFileTime;

  function ProcessTimePassed: Integer;
  var
    NewCreationTime, NewExitTime, NewKernelTime, NewUserTime: TFileTime;
  begin
    GetProcessTimes(hProcess, NewCreationTime, NewExitTime, NewKernelTime, NewUserTime);
    Result:=Round(Abs(Int64(NewUserTime) - Int64(UserTime)) / 10000);
  end;
  {$ENDIF}

  procedure StartTimer;
  begin
    Counter:=0;{$IFDEF V_DELPHI}
    LocalCounter:=0;
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      GetProcessTimes(hProcess, CreationTime, ExitTime, KernelTime, UserTime)
    else{$ENDIF}
      StartTime:=GetTickCount;
  end;

  {$ELSE} {WIN16}

  procedure StartTimer;
  begin
    Counter:=0;
    LocalCounter:=0;
    StartTime:=GetTickCount;
  end;

  {$ENDIF}

  {$ELSE}

  procedure StartTimer;
  begin
    Counter:=0;
    LocalCounter:=0;
    StartTime:=Time;
  end;

  {$ENDIF}

  function TimePassed: LongInt;
  const
    Limit = {$IFDEF V_WIN} 8 {$ELSE} 32 { "Time" is slow } {$ENDIF};
  begin
    if LocalCounter = 0 then begin
    {$IFDEF V_WIN}
    {$IFDEF V_DELPHI}{$IFDEF V_32}
      if Win32Platform = VER_PLATFORM_WIN32_NT then
        T:=ProcessTimePassed
      else
    {$ENDIF}{$ENDIF}
        T:=Abs(GetTickCount - StartTime);
    {$ELSE}
      T:=Trunc(Frac(Time - StartTime) * 24 * 3600 * 1000 { milliseconds per day });
    {$ENDIF}
      Result:=T;
    end
    else
      Result:=0;
    Inc(LocalCounter);
    if LocalCounter >= Limit then LocalCounter:=0;
  end;

  procedure TestInt8Vectors;
  type
    TFastVector = TInt8Vector;
  {$I Benchmrk.inc}

  procedure TestUInt8Vectors;
  type
    TFastVector = TUInt8Vector;
  {$I Benchmrk.inc}

  procedure TestInt16Vectors;
  type
    TFastVector = TInt16Vector;
  {$I Benchmrk.inc}

  procedure TestUInt16Vectors;
  type
    TFastVector = TUInt16Vector;
  {$I Benchmrk.inc}

  procedure TestInt32Vectors;
  type
    TFastVector = TInt32Vector;
  {$I Benchmrk.inc}

  procedure TestUInt32Vectors;
  type
    TFastVector = TUInt32Vector;
  {$I Benchmrk.inc}

  procedure TestInt64Vectors;
  type
    TFastVector = TInt64Vector;
  {$I Benchmrk.inc}

  procedure TestFloat32Vectors;
  type
    TFastVector = TFloat32Vector;
  {$I Benchmrk.inc}

  procedure TestFloat64Vectors;
  type
    TFastVector = TFloat64Vector;
  {$I Benchmrk.inc}

  procedure TestFloat80Vectors;
  type
    TFastVector = TFloat80Vector;
  {$I Benchmrk.inc}

  procedure TestFloat32Matrix;
  type
    TMatrix = TFloat32Matrix;
  {$I BnchMatr.inc}

  procedure TestFloat64Matrix;
  type
    TMatrix = TFloat64Matrix;
  {$I BnchMatr.inc}

  procedure TestFloat80Matrix;
  type
    TMatrix = TFloat80Matrix;
  {$I BnchMatr.inc}

var
  I: Integer;
begin
  {$IFDEF VDEBUG}
  DebugLine('To obtain the maximum results turn off VDEBUG condition in the file VCheck.inc'); 
  DebugLine('');
  {$ENDIF}
  DebugLine('Options:');
{$IFOPT R-}
  {$IFOPT Q-}
    {$IFDEF USE_ASM}
      DebugLine('Use ASM fragments');
      {$IFDEF USE_MMX}
      if MMXCPU then
        DebugLine('MMX CPU found - using MMX commands')
      else
        DebugLine('MMX CPU not found');
      {$ELSE}
      DebugLine('Don''t use MMX commands');
      {$ENDIF}
      DebugLine('Compiler options R-, Q-');
    {$ELSE}
      DebugLine('Don''t use ASM fragments');
      DebugLine('Don''t use MMX commands');
      DebugLine('Compiler options R-, Q-');
    {$ENDIF}
  {$ELSE}
    DebugLine('Don''t use ASM fragments');
    DebugLine('Don''t use MMX commands');
    DebugLine('Compiler options R-, Q+');
  {$ENDIF}
{$ELSE}
  DebugLine('Don''t use ASM fragments');
  DebugLine('Don''t use MMX commands');
  DebugLine('Compiler option R+');
{$ENDIF}
  DebugLine('');
  S:=  'Count     ';
  for I:=0 to TestCount - 1 do S:=S + Format('%8d', [SizeToTest[I]]);
  DebugLine(S);
  {$IFDEF V_WIN}{$IFDEF V_DELPHI}
  Screen.Cursor:=crHourglass;
  try
  {$ENDIF}{$ENDIF}
    DebugLine('TInt8Vector');
    TestInt8Vectors;
    DebugLine('TUInt8Vector');
    TestUInt8Vectors;
    DebugLine('TInt16Vector');
    TestInt16Vectors;
    DebugLine('TUInt16Vector');
    TestUInt16Vectors;
    DebugLine('TInt32Vector');
    TestInt32Vectors;
    DebugLine('TUInt32Vector');
    TestUInt32Vectors;
    {$IFDEF WIN32}
    {$IFDEF V_FREEPASCAL}
    DebugLine('TInt64Vector doesn''t work yet when using Free Pascal');
    {$ELSE}
    DebugLine('TInt64Vector');
    TestInt64Vectors;
    {$ENDIF}
    {$ENDIF}
    DebugLine('TFloat32Vector');
    TestFloat32Vectors;
    {$IFDEF V_32}
    DebugLine('TFloat64Vector');
    TestFloat64Vectors;
    DebugLine('TFloat80Vector');
    TestFloat80Vectors;
    {$ENDIF}
    DebugLine('TFloat32Matrix');
    TestFloat32Matrix;
    DebugLine('TFloat64Matrix');
    TestFloat64Matrix;
    DebugLine('TFloat80Matrix');
    TestFloat80Matrix;
  {$IFDEF V_WIN}{$IFDEF V_DELPHI}
  finally
    Screen.Cursor:=crDefault;
  end;
  {$ENDIF}{$ENDIF}
end;

{$IFDEF WIN32}
initialization
  hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION, False, GetCurrentProcessId);
finalization
  CloseHandle(hProcess);
{$ENDIF}
end.
