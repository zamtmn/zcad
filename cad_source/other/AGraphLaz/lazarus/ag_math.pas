{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ag_math;

interface

uses
  Gauss, Geom_2d, Geom_3d, Grevil, MathErr, Optimize, SLS_Iter, SVD, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ag_math', @Register);
end.
