{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zcontainers;

{$warn 5023 off : no warning about unused units}
interface

uses
  UGDBOpenArrayOfByte, uzctnrvectorrec, UGDBOpenArrayOfObjects, 
  UGDBOpenArrayOfPObjects, UGDBOpenArrayOfPointer, uzctnrvectorgdbstring, 
  UGDBTree, uzctnrvector, uzctnrvectorsimple, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zcontainers', @Register);
end.
