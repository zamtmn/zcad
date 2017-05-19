unit uoptions;

{$mode objfpc}{$H+}

interface

uses
  uprojectoptions, uprogramoptions;

type
  {$Z1}
  TOptions=packed record
    ProgramOptions:TProgramOptions;
    ProjectOptions:TProjectOptions;
  end;
implementation
end.

