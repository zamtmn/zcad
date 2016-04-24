{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontainers;

{$warn 5023 off : no warning about unused units}
interface

uses
  uzctnrvector, uzctnrvectorsimple, uzctnrvectordata, uzctnrvectorobjects, 
  uzctnrvectorp, uzctnrvectorpdata, uzctnrvectorpobjects, 
  uzctnrvectorgdbstring, UGDBTree, UGDBOpenArrayOfByte, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zcontainers', @Register);
end.
