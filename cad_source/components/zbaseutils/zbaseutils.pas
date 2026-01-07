{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zbaseutils;

{$warn 5023 off : no warning about unused units}
interface

uses
  uzbLog, uzbNamedHandles, uzbNamedHandlesWithData, uzbHandles, uzbSets, 
  uzbexceptionscl, uzbexceptionsparams, uzbLogIntf, uzbLogDecorators, 
  uzbLogFileBackend, uzbCommandLineParser, uzbGetterSetter, uzbUsable, 
  uzbBaseUtils, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zbaseutils', @Register);
end.
