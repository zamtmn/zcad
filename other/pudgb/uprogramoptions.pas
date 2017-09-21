unit uprogramoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  {$Z1}
  TProgPaths=packed record
    _PathToDot:String;
    _Temp:String;
  end;
  TVisBackend=(VB_GDI,VB_Opengl);
  TVisualizer=packed record
    VisBackend:TVisBackend;
  end;
  TLogger=packed record
    ScanerMessages:Boolean;
    ParserMessages:Boolean;
    Timer:Boolean;
    Notfounded:Boolean;
  end;
  TBehavior=packed record
    AutoSelectPages:Boolean;
    AutoClearPages:Boolean;
  end;
  PTProgramOptions=^TProgramOptions;
  TProgramOptions=packed record
    ProgPaths:TProgPaths;
    Behavior:TBehavior;
    Visualizer:TVisualizer;
    Logger:TLogger;
  end;
implementation
end.

