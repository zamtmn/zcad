{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcadcontrols;

interface

uses
  ZListView, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ZListView', @ZListView.Register);
end;

initialization
  RegisterPackage('zcadcontrols', @Register);
end.
