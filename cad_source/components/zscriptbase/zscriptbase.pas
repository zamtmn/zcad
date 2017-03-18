{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zscriptbase;

interface

uses
  varmandef, strmy, uabstractunit, typedescriptors, uzctypesdecorations, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zscriptbase', @Register);
end.
