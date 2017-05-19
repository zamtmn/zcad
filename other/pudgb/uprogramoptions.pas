unit uprogramoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  {$Z1}
  TProgPaths=packed record
    _PathToDot:String;
  end;
  TLogger=packed record
    ScanerMessages:Boolean;
    ParserMessages:Boolean;
    Timer:Boolean;
    Notfounded:Boolean;
  end;
  PTProgramOptions=^TProgramOptions;
  TProgramOptions=packed record
    ProgPaths:TProgPaths;
    Logger:TLogger;
  end;
implementation
end.

