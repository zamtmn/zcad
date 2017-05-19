unit udpropener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,LazFileUtils,
  uprojectoptions;

procedure DPROpen(var Options:TProjectOptions;const filename:string;const LogWriter:TLogWriter);

implementation

procedure DPROpen(var Options:TProjectOptions;const filename:string;const LogWriter:TLogWriter);
begin
  Options.Paths._File:=filename;
  Options.Paths._Paths:=ExtractFilePath(filename);
  Options.ParserOptions._CompilerOptions:='-Sd -Sc '+GetCompilerDefs;
end;

end.

