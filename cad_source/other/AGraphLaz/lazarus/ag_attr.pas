{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ag_attr;

interface

uses
  AttrErr, AttrMap, AttrSet, AttrType, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ag_attr', @Register);
end.
