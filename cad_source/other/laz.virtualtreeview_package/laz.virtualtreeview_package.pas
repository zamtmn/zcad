{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit laz.virtualtreeview_package;

{$warn 5023 off : no warning about unused units}
interface

uses
  laz.VirtualTrees, laz.VTHeaderPopup, laz.RegisterVirtualTreeView, 
  laz.VTGraphics, laz.VTIDEEditors, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('laz.RegisterVirtualTreeView', 
    @laz.RegisterVirtualTreeView.Register);
end;

initialization
  RegisterPackage('laz.virtualtreeview_package', @Register);
end.
