{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit fplnlib;

{$warn 5023 off : no warning about unused units}
interface

uses
  LNEnums_CAPI, LNObject_CAPI, Matrix4d_CAPI, NurbsCurve_CAPI, 
  NurbsSurface_CAPI, uLNLib, UV_CAPI, XYZ_CAPI, XYZW_CAPI, gLNLib, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('fplnlib', @Register);
end.
