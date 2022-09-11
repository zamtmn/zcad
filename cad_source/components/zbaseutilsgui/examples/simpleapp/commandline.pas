unit commandline;

{$mode ObjFPC}{$H+}

interface

uses
  uzbCommandLineParser;

var
  CommandLineParser:TCommandLineParser;

  av_on_initializationCLOH,logfileCLOH,lclCLOH,emCLOH,dmCLOH:TCLOptionHandle;

implementation

initialization
  CommandLineParser.Init;
  av_on_initializationCLOH:=CommandLineParser.RegisterArgument('av_on_initialization',AT_Flag);
  logfileCLOH:=CommandLineParser.RegisterArgument('logfile',AT_WithOperands);
  lclCLOH:=CommandLineParser.RegisterArgument('loglevel',AT_WithOperands);
  emCLOH:=CommandLineParser.RegisterArgument('enablemodule',AT_WithOperands);
  dmCLOH:=CommandLineParser.RegisterArgument('disablemodule',AT_WithOperands);
  CommandLineParser.ParseCommandLine;
finalization
  CommandLineParser.Done;
end.

