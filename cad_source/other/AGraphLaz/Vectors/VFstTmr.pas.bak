{ Version 041204. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VFstTmr;

interface

{$I VCheck.inc}
{$IFDEF V_D3}{$WRITEABLECONST ON}{$ENDIF}

uses
  SysUtils, ExtType,
  {$IFDEF V_WIN}{$IFNDEF WIN32}WinTypes, WinProcs{$ELSE}Windows{$ENDIF}{$ENDIF}
  {$IFDEF LINUX}Libc{$ENDIF};

type
  TVFastTimer = class
  private
    FStarted: Bool;
    {$IFDEF WIN32}
    FHighResHard: Bool;
    FFreq, FStopTime, FStartTime: TLargeInteger;
    {$ENDIF}
    FStopTick, FStartTick: Int32;
  public
    {$IFDEF WIN32}
    constructor Create;
    {$ENDIF}
    procedure Start;
    { запустить таймер }
    procedure Stop;
    { остановить таймер }
    procedure Resume;
    { продолжить работу таймера (в отличие от Start, не сбрасывает время) }
    function UsedTime: Float;
    { если таймер запущен методом Start, то возвращает время с запуска таймера
      (в секундах/долях секунды); если таймер был запущен, а затем остановлен
      методом Stop, то возвращает длительность временного интервала между
      вызовами Start и Stop; если таймер не был запущен, то возвращает 0 }
    procedure Report;
    { выдает UsedTime в stdout }
    { reports UsedTime to the stdout }
  end;

function StdTmr: TVFastTimer;
{ возвращает ссылку на глобальный таймер }
{ returns a pointer to a global timer }

{$IFDEF LINUX}
function GetTickCount: UInt32;
{$ENDIF}

implementation

{$IFDEF WIN32}
constructor TVFastTimer.Create;
begin
  inherited Create;
  FHighResHard:=QueryPerformanceFrequency(FFreq);
end;
{$ENDIF}

procedure TVFastTimer.Start;
begin
  {$IFDEF WIN32}
  if FHighResHard then
    QueryPerformanceCounter(FStartTime)
  else
  {$ENDIF}
    FStartTick:=GetTickCount;
  FStarted:=True;
end;

procedure TVFastTimer.Stop;
begin
  {$IFDEF WIN32}
  if FHighResHard then
    QueryPerformanceCounter(FStopTime)
  else
  {$ENDIF}
    FStopTick:=GetTickCount;
  FStarted:=False;
end;

procedure TVFastTimer.Resume;
{$IFDEF WIN32}
var
  NewTime: TLargeInteger;
{$ENDIF}
begin
  if not FStarted then begin
    {$IFDEF WIN32}
    if FHighResHard then begin
      QueryPerformanceCounter(NewTime);
      {$IFDEF V_D4}
      Inc(FStartTime, Abs(NewTime - FStopTime));
      {$ELSE}
      {$IFDEF V_FREEPASCAL}
      Inc(Int64(FStartTime), Abs(Int64(NewTime) - Int64(FStopTime)));
      {$ELSE}
      Inc(FStartTime.QuadPart, Abs(NewTime.QuadPart - FStopTime.QuadPart));
      {$ENDIF}
      {$ENDIF}
    end
    else
    {$ENDIF}
      Inc(FStartTick, Abs(Int32(GetTickCount) - FStopTick));
    FStarted:=True;
  end;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function TVFastTimer.UsedTime: Float;
var
{$IFDEF WIN32}
  NewTime: TLargeInteger;
{$ENDIF}
  T2: Int32;
begin
  if FStarted then
    {$IFDEF WIN32}
    if FHighResHard then
      QueryPerformanceCounter(NewTime)
    else
    {$ENDIF}
      T2:=GetTickCount
  else
    {$IFDEF WIN32}
    if FHighResHard then
      NewTime:=FStopTime
    else
    {$ENDIF}
      T2:=FStopTick;
  {$IFDEF WIN32}
  if FHighResHard then
    {$IFDEF V_D4}
    Result:=Abs(NewTime - FStartTime) / FFreq
    {$ELSE}
    {$IFDEF V_FREEPASCAL}
    Result:=Abs(Int64(NewTime) - Int64(FStartTime)) / Int64(FFreq)
    {$ELSE}
    Result:=Abs(NewTime.QuadPart - FStartTime.QuadPart) / FFreq.QuadPart
    {$ENDIF}
    {$ENDIF}
  else
  {$ENDIF}
    Result:=Abs(T2 - FStartTick) / 1000;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

procedure TVFastTimer.Report;
begin
  writeln(UsedTime :0:2, ' sec');
end;

const
  FStdTmr: Pointer = nil; // Pointer instead of TVFastTimer is for Free Pascal

function StdTmr: TVFastTimer;
begin
  if FStdTmr = nil then
    FStdTmr:=TVFastTimer.Create;
  Result:=FStdTmr;
end;

{$IFDEF LINUX}
function GetTickCount: UInt32;
var
  tv: timeval;
begin
  gettimeofday(tv, nil);
  {$RANGECHECKS OFF}
  Result:=tv.tv_sec * 1000 + tv.tv_usec div 1000;
end;
{$ENDIF}

initialization
finalization
  FreeAndNil(FStdTmr);
end.
