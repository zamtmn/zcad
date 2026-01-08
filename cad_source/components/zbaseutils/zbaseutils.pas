{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zbaseutils;

{$warn 5023 off : no warning about unused units}
interface

uses
  uzbBaseUtils, uzbCommandLineParser, uzbexceptionscl, uzbexceptionsparams, 
  uzbGetterSetter, uzbHandles, uzbLog, uzbLogDecorators, uzbLogFileBackend, 
  uzbLogIntf, uzbLogTypes, uzbNamedHandles, uzbNamedHandlesWithData, uzbPaths, 
  uzbSets, uzbstrproc, uzbUsable, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zbaseutils', @Register);
end.
