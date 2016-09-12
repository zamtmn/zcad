unit uoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TOptions=record
    _File:String;
    _Paths:String;
    _CompilerOptions:String;
    TargetOS,TargetCPU:String;
  end;

  TLogWriter=procedure(msg:string) of object;

implementation

end.

