unit TestProc;

interface

{$I VCheck.inc}

uses
  SysUtils;

type
  ErrCodes = (EWrongResult, EExceptionExpected);
  ETestError = class(Exception);

procedure Error(ErrCode: ErrCodes);

implementation

procedure Error(ErrCode: ErrCodes);
{$IFDEF V_DELPHI}{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
          MOV     EAX, [EBP+4]
  end;
{$ENDIF}{$ENDIF}
begin
  Case ErrCode of
    EWrongResult:
      raise ETestError.Create('Wrong Result')
        {$IFDEF V_DELPHI}{$IFDEF WIN32}at ReturnAddr{$ENDIF}{$ENDIF};
    EExceptionExpected:
      raise ETestError.Create('Exception Expected')
        {$IFDEF V_DELPHI}{$IFDEF WIN32}at ReturnAddr{$ENDIF}{$ENDIF};
  End;
end;

end.
