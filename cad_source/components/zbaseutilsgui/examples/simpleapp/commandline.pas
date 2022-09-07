unit commandline;

{$mode ObjFPC}{$H+}

interface

uses
  uzbCommandLineParser;

var
  CommandLineParser:TCommandLineParser;

  av_on_initializationCLOH:TCLOptionHandle;

implementation

initialization
  CommandLineParser.Init;
  av_on_initializationCLOH:=CommandLineParser.RegisterArgument('av_on_initialization',AT_Flag);
  CommandLineParser.ParseCommandLine;
finalization
  CommandLineParser.Done;
end.

