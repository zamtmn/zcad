{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zundostack;

interface

uses
  zebaseundocommands, zeundostack, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zundostack', @Register);
end.
