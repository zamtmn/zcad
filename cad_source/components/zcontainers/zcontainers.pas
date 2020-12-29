{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontainers;

{$warn 5023 off : no warning about unused units}
interface

uses
  gzctnrvector, gzctnrvectorsimple, gzctnrvectordata, gzctnrvectorobjects, 
  gzctnrvectorp, gzctnrvectorpdata, gzctnrvectorpobjects, 
  uzctnrvectorgdbstring, uzctnrvectorgdbpointer, UGDBTree, 
  UGDBOpenArrayOfByte, gzctnrtree, gzctnrstl, uzctnrobjectschunk, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zcontainers', @Register);
end.
