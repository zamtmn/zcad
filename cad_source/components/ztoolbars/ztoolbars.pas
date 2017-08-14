{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ztoolbars;

{$warn 5023 off : no warning about unused units}
interface

uses
  uztoolbarsmanager, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ztoolbars', @Register);
end.
