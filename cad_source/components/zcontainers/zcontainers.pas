{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontainers;

interface

uses
  gzctnrvector, gzctnrvectorsimple, gzctnrvectordata, gzctnrvectorobjects, 
  gzctnrvectorp, gzctnrvectorpdata, gzctnrvectorpobjects, 
  uzctnrvectorgdbstring, uzctnrvectorgdbpointer, UGDBTree, 
  UGDBOpenArrayOfByte, gzctnrtree, gzctnrstl, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zcontainers', @Register);
end.
