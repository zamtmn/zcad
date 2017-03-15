{ Version 000626. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit MathErr;

interface

{$I VCheck.inc}

uses
  SysUtils, VectErr;

procedure MathError(const Msg: String; const Data: array of const);

implementation

procedure MathError(const Msg: String; const Data: array of const);
{$IFDEF V_DELPHI}{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
          mov     eax, [ebp+4]
  end;
{$ENDIF}{$ENDIF}
begin
  raise EMathError.Create(ErrMsg(Msg, Data))
    {$IFDEF V_DELPHI}{$IFDEF WIN32}at ReturnAddr{$ENDIF}{$ENDIF};
end;

end.
