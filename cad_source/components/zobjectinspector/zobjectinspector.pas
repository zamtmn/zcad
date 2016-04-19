{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zobjectinspector;

interface

uses
  zcobjectinspector, zcobjectinspectoreditors, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('zcobjectinspector', @zcobjectinspector.Register);
end;

initialization
  RegisterPackage('zobjectinspector', @Register);
end.
