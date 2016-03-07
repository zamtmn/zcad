{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontrols;

{$warn 5023 off : no warning about unused units}
interface

uses
  ZListView, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ZListView', @ZListView.Register);
end;

initialization
  RegisterPackage('zcontrols', @Register);
end.
