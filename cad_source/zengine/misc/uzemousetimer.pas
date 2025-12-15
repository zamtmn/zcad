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

unit uzeMouseTimer;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  ExtCtrls,Types,Math;

type
  TMouseTimer=class
    public
      type
        TOnTimerProc=procedure(StartX,StartY,X,Y:Integer) of object;
        T3StateDo=(T3SDo,T3SCancel,T3SWait);
        TReason=(RMMove,RMDown,RMUp,RReSet,RLeave);
        TReasons=set of TReason;
    private
      fTmr:TTimer;
      fStartPos,fCurrentPos:TPoint;
      fCancelReasons:TReasons;
      fD:Integer;
      fOnTimerProc:TOnTimerProc;
      procedure CreateTimer(Interval:Cardinal);
      procedure ItTime(Sender:TObject);
    public
      constructor Create;
      destructor Destroy;override;
      procedure &Set(MP:TPoint;ADelta:Integer;ACancel:TReasons;AOnTimerProc:TOnTimerProc;Interval:Cardinal);
      procedure Cancel;
      procedure Touch(MP:TPoint;AReason:TReasons);
  end;

implementation

procedure TMouseTimer.CreateTimer(Interval:Cardinal);
begin
  if fTmr=nil then
    fTmr:=TTimer.Create(nil);
  fTmr.Interval:=Interval;
  fTmr.OnTimer:=ItTime;
  fTmr.Enabled:=True;
end;

procedure TMouseTimer.ItTime(Sender:TObject);
var
  OnTimerProc:TOnTimerProc;
  StartPos,CurrentPos:TPoint;
begin
  OnTimerProc:=fOnTimerProc;
  StartPos:=fStartPos;
  CurrentPos:=fCurrentPos;
  Cancel;
  if assigned(OnTimerProc) then
    OnTimerProc(StartPos.X,StartPos.Y,CurrentPos.X,CurrentPos.Y);
end;

constructor TMouseTimer.Create;
begin
  fTmr:=nil;
  fD:=0;
  fStartPos:=Point(0,0);
  fCurrentPos:=fStartPos;
end;

destructor TMouseTimer.Destroy;
begin
  fTmr.Free;
end;

procedure TMouseTimer.&Set(MP:TPoint;ADelta:Integer;ACancel:TReasons;AOnTimerProc:TOnTimerProc;Interval:Cardinal);
begin
  if fTmr=nil then
    fTmr:=TTimer.Create(nil)
  else
    if not (RReSet in fCancelReasons) then
      exit;
  Cancel;
  fStartPos:=MP;
  fCurrentPos:=MP;
  fD:=ADelta;
  fCancelReasons:=ACancel;
  fOnTimerProc:=AOnTimerProc;
  fTmr.OnTimer:=ItTime;
  fTmr.Interval:=Interval;
  fTmr.Enabled:=True;
 end;

procedure TMouseTimer.Cancel;
begin
  fTmr.Enabled:=false;
  fD:=0;
  fOnTimerProc:=nil;
end;

procedure TMouseTimer.Touch(MP:TPoint;AReason:TReasons);

  function Check:T3StateDo;
  var
    d:integer;
  begin
    if (AReason*fCancelReasons)<>[] then
      exit(T3SCancel);
    if fd<>0 then begin
      d:=max(abs(mp.X-fStartPos.X),abs(mp.Y-fStartPos.Y));
      if fd>=0 then begin
        if d>=fd then
          exit(T3SCancel);
      end else begin
        if d>=-fd then
          exit(T3SDo);
      end;
    end;
    result:=T3SWait;
  end;

begin
  if fd<>0 then begin
    fCurrentPos:=MP;
    case Check of
      T3SCancel:Cancel;
      T3SDo:begin
        ItTime(nil);
        Cancel;
      end;
      T3SWait:;
    end;
  end;
end;
initialization
end.
