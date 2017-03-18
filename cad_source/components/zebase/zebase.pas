{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zebase;

interface

uses
  uzbtypesbase, uzbtypes, uzbmemman, uzbstrproc, uzbpaths, uzbgeomtypes, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zebase', @Register);
end.
