unit AVInInitializationSection;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils,
  commandline;

implementation
procedure test;
begin
  if CommandLineParser.HasOption(av_on_initializationCLOH) then
    pstring(nil)^:='';
end;


initialization
  test;
end.

