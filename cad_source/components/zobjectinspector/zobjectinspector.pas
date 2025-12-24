{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zobjectinspector;

{$warn 5023 off : no warning about unused units}
interface

uses
  uzObjectInspector, uzObjectInspectorManager, uzOIDecorations, uzOIEditors, 
  uzOIUI, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uzObjectInspector', @uzObjectInspector.Register);
end;

initialization
  RegisterPackage('zobjectinspector', @Register);
end.
