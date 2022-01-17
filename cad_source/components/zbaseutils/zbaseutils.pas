{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zbaseutils;

{$warn 5023 off : no warning about unused units}
interface

uses
  uzblog, uzbnamedhandles, uzbnamedhandleswithdata, uzbhandles, uzbsets, 
  uzbexceptionscl, uzbexceptionsparams, uzbLogIntf, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zbaseutils', @Register);
end.
